module Tcl
  module Ruby
    class Interpreter
      private

      def ___array(*arg)
        send("___array_#{arg[0]}", *arg[1..-1])
      rescue ArgumentError => e
        raise(TclArgumentError, "array #{arg[0]}: #{e.message}")
      end

      def ___array_set(name, list)
        raise(CommandError, "#{name} is not array") unless
          @variables[name].is_a?(Hash) || !@variables.key?(name)
        l = parse(list, true).to_h
        @variables[name] ||= {}
        @variables[name].merge!(l)
      end

      def ___array_unset(name, pattern = nil)
        return '' unless @variables[name].is_a?(Hash)
        if pattern
          @variables[name].delete(pattern)
        else
          @variables.delete(name)
        end
        ''
      end

      def ___array_get(name, pattern = nil)
        return '' unless @variables[name].is_a?(Hash)
        if pattern
          return '' unless @variables[name].key?(pattern)
          "#{pattern} #{@variables[name][pattern]}"
        else
          @variables[name].flatten.join(' ')
        end
      end

      def ___array_exists(name)
        @variables[name].is_a?(Hash) ? '1' : '0'
      end
    end
  end
end
