module Tcl
  module Ruby
    class Interpreter
      private

      def ___array(arg)
        send("___array_#{arg[0]}", arg[1..-1])
      end

      def ___array_set(arg)
        name = delete_parenthesis(arg[0])
        raise(CommandError, "#{name} is not array") unless
          @variables[name].is_a?(Hash) || !@variables.key?(name)
        l = parse(delete_parenthesis(arg[1]), true)
        raise(TclArgumentError, 'list must have an even number of elements') unless
          l.size.even?
        @variables[name] ||= {}
        @variables[name].merge!(Hash[*l])
      end

      def ___array_get(arg)
        raise(TclArgumentError, 'arry get arrayName ?pattern?') unless
          (1..2).cover?(arg.size)
        name = delete_parenthesis(arg[0])
        pattern = delete_parenthesis(arg[1])
        return '' unless @variables[name].is_a?(Hash)
        return '' unless @variables[name].key?(pattern)
        "#{pattern} #{@variables[name][pattern]}"
      end
    end
  end
end
