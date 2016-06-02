module Tcl
  module Ruby
    class Interpreter
      def command(arg)
        return @prev if arg[0][0] == '#'
        # return previous command result when comment statement executed
        arg = arg.map { |e| replace(e) }
        if @hooks.key?(arg[0])
          @hooks[arg[0]].call(arg[1..-1])
        elsif respond_to?("___#{arg[0]}", true)
          @prev = send("___#{arg[0]}", arg[1..-1])
        else
          raise(CommandError, "command not found, #{arg[0]}")
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
            raise(TclVariableNotFoundError, v.to_s, "variable is array") if @variables[v].is_a?(Hash)
            @variables[v]
          end
        end
        # replace commands
        l.gsub(/\[(.+)\]/) { parse(Regexp.last_match(1)) }
      end
    end
  end
end
