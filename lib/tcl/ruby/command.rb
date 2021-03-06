require 'strscan'

module Tcl
  module Ruby
    class Interpreter

      def parse(str, to_list = false)
        parsed_ary = Parser.parse(str, to_list)
        to_list ? parsed_ary : command(parsed_ary)
      end

      alias p parse

      private

      def command(cmds)
        ret = nil
        cmds.each do |arg|
          next if arg.empty?
          arg.replace(&method(:replace))
          name = "___#{arg[0]}"
          if @proc.key?(arg[0]) then ret = exec_proc(arg[1..-1], @proc[arg[0]])
          elsif @hooks.key?(arg[0]) then ret = @hooks[arg[0]].call(arg[1..-1])
          elsif respond_to?(name, true)
            begin
              ret = send(name, *arg[1..-1])
            rescue ArgumentError => e
              raise(TclArgumentError, "#{arg[0]}: #{e.message}")
            end
          else
            raise(CommandError, "command not found, #{arg[0]}")
          end
        end
        ret
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
        elem.gsub!(/\$\{(.+?)\}|\$(\w+\([^\s)]+\))|\$(\w+)/) do |_|
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
        elem
      end

      def exec_proc(arg, proc_info)
        proc_arg = parse(proc_info[0], true)
        raise(TclArgumentError, proc_arg.to_s) if proc_arg.size != arg.size
        @variables[:___global].each do |v| # backup globals
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
        @variables[:___global].each do |v| # write back
          @global[v] = @variables[v]
        end if @variables.key?(:___global)
        @variables = @v_stack.pop
        @variables[:___global].each do |v| # re-copy global
          @variables[v] = @global[v]
        end if @variables.key?(:___global)
        ret
      end
    end
  end
end
