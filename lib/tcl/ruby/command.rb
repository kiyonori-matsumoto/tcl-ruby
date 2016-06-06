require 'strscan'

module Tcl
  module Ruby
    class Interpreter
      private

      def command(arg)
        return nil if arg.empty?
        arg.replace(&method(:replace))
        name = "___#{arg[0]}"
        if @proc.key?(arg[0]) then exec_proc(arg[1..-1], @proc[arg[0]])
        elsif @hooks.key?(arg[0]) then @hooks[arg[0]].call(arg[1..-1])
        elsif respond_to?(name, true) then send(name, arg[1..-1])
        else
          raise(CommandError, "command not found, #{arg[0]}")
        end
      end

      def replace(list)
        # replace commands
        list = replace_commands(list)

        # replace variable
        replace_variable(list)
      end

      def replace_commands(list)
        l = list.dup
        s = StringScanner.new(l)
        buffer = nil
        depth = 0
        until s.empty?
          if s.scan(/\\./m)
            buffer << s[0] if buffer
          elsif s.scan(/\[/)
            if depth == 0
              pos = s.pos - 1
              buffer = ''
            end
            depth += 1
            buffer << s[0]
          elsif s.scan(/\]/)
            depth -= 1
            buffer << s[0]
            if depth == 0
              l[pos, buffer.length] = parse(buffer[1..-2]).to_s
              s.string = l
              buffer = nil
            end
          elsif s.scan(/[^\[\]\\]+/m)
            buffer << s[0] if buffer
          end
        end
        raise(ParseError, 'unmatched brackets') if depth != 0
        l
      end

      def replace_variable(elem)
        elem.gsub(/\$\{(.+?)\}|\$(\w+\([^\s)]+\))|\$(\w+)/) do |_|
          v = Regexp.last_match(1) || Regexp.last_match(2) ||
              Regexp.last_match(3)
          h = nil
          vv = v.dup
          v.sub!(/\(([^\s)]+)\)\z/) { |_m| h = Regexp.last_match(1); '' }
          raise TclVariableNotFoundError.new(v, 'no such variable') unless
            @variables.key?(v)
          if h # variable specified is hash
            raise TclVariableNotFoundError.new(vv, "variable isn't array") unless @variables[v].is_a?(Hash)
            h = replace_variable(h) # analyze var_string on parenthesis
            @variables[v][h]
          else
            raise TclVariableNotFoundError.new(v, 'variable is array') if
              @variables[v].is_a?(Hash)
            @variables[v]
          end
        end
      end

      def exec_proc(arg, proc_info)
        proc_arg = parse(proc_info[0], true)
        raise(TclArgumentError, proc_arg.to_s) if proc_arg.size != arg.size
        @variables[:___global].each do |v| # FIXME: Buggy
          @global[v] = @variables[v]
        end if @variables.key?(:___global)
        @v_stack.push(@variables)
        @variables = {}
        arg.zip(proc_arg).each do |v|
          @variables[v[1]] = v[0]
        end
        ret = catch(:return) do
          parse(proc_info[1])
        end
        @variables[:___global].each do |v| # FIXME: Buggy
          @global[v] = @variables[v]
        end if @variables.key?(:___global)
        @variables = @v_stack.pop
        ret
      end
    end
  end
end
