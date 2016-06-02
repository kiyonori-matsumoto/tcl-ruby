module Tcl
  module Ruby
    class Interpreter
      private

      def ___array(arg)
        send("___array_#{arg[0]}", arg[1..-1])
      end

      def ___array_set(arg)
        name = arg[0]
        raise(CommandError, "#{name} is not array") unless
          @variables[name].is_a?(Hash) || !@variables.key?(name)
        l = parse(arg[1], true)
        raise(TclArgumentError, 'list must have an even number of elements') unless
          l.size.even?
        @variables[name] ||= {}
        @variables[name].merge!(Hash[*l])
      end

      def ___array_unset(arg)
        raise(TclArgumentError, 'array unset arrayName ?pattern?') unless
          (1..2).cover?(arg.size)
        name = arg[0]
        return '' unless @variables[name].is_a?(Hash)
        if arg.size == 2
          pattern = arg[1]
          @variables[name].delete(pattern)
        else
          @variables.delete(name)
        end
        ''
      end

      def ___array_get(arg)
        raise(TclArgumentError, 'array get arrayName ?pattern?') unless
          (1..2).cover?(arg.size)
        name = arg[0]
        return '' unless @variables[name].is_a?(Hash)
        if arg.size == 2
          pattern = arg[1]
          return '' unless @variables[name].key?(pattern)
          "#{pattern} #{@variables[name][pattern]}"
        else
          @variables[name].flatten.join(' ')
        end
      end

      def ___array_exists(arg)
        raise(TclArgumentError, 'array exists arrayName') unless arg.size == 1
        name = arg[0]
        @variables[name].is_a?(Hash) ? '1' : '0'
      end
    end
  end
end
