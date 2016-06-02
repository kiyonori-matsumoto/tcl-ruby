module Tcl
  module Ruby
    class Interpreter
      def command(arg)
        return @prev if arg[0][0] == '#'
        # return previous command result when comment statement executed
        arg.map! { |e| replace(e) }
        arg.to_string
        name = arg[0]
        if @proc.key?(name)
          exec_proc(arg[1..-1], @proc[name])
        elsif @hooks.key?(name)
          @hooks[name].call(arg[1..-1])
        elsif respond_to?("___#{name}", true)
          @prev = send("___#{name}", arg[1..-1])
        else
          raise(CommandError, "command not found, #{name}")
        end
      end

      def replace(list)
        return list if list[0] == '{'
        # replace variable
        l = list.gsub(/\$\{(.+?)\}|\$([\w()]+)/) do
          v = Regexp.last_match(Regexp.last_match(1) ? 1 : 2)
          h = vv = nil
          if (m = v.match(/\((\w+)\)\z/))
            h = m[1]
            vv = v
            v = vv.sub(/\((\w+)\)\z/, '')
          end
          raise(TclVariableNotFoundError, v.to_s, 'no such variable') unless
            @variables.key?(v)
          if h
            raise(TclVariableNotFoundError, vv.to_s, "variable isn't array") unless @variables[v].is_a?(Hash)
            @variables[v][h].to_s
          else
            raise(TclVariableNotFoundError, v.to_s, 'variable is array') if @variables[v].is_a?(Hash)
            @variables[v]
          end
        end
        # replace commands
        l = l.gsub(/\[(.+)\]/) { parse(Regexp.last_match(1)) }
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
