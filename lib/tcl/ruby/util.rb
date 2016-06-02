module Tcl
  module Ruby
    class Interpreter
      def initialize
        @variables = {}
        @hooks = {}
        @proc = {}
      end

      def variables(arg)
        raise(TclVariableNotFoundError, "can't read $#{arg}, no such variables") unless @variables.key?(arg)
        @variables[arg]
      end

      def add_hook(name, &block)
        raise(ArgumentError, 'block is not given') unless block_given?
        @hooks[name.to_s] = block
      end

      def delete_hook(name)
        @hooks.delete(name.to_s)
      end
    end
  end
end
