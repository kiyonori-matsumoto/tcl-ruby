module Tcl
  module Ruby
    class Interpreter
      def initialize
        @variables = {}
        @hooks = {}
      end

      def delete_parenthesis(str)
        if str[0] == '{' && str[-1] == '}'
          str = str[1..-2]
        elsif str[0] == '"' && str[-1] == '"'
          str = str[1..-2]
        else
          return str
        end
        str
      end

      def variables(arg)
        raise(TclError, "can't read $#{arg}, no such variables") unless @variables.key?(arg)
        delete_parenthesis(@variables[arg])
      end

      def add_hook(name, &block)
        raise(ArgumentError, "block is not given") unless block_given?
        @hooks[name.to_s] = block
      end

      def delete_hook(name)
        @hooks.delete(name.to_s)
      end
    end
  end
end
