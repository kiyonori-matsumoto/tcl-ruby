module Tcl
  module Ruby
    class Interpreter
      def initialize
        @variables = {}
        @global = @variables
        @v_stack = []
        @hooks = {}
        @proc = {}
      end

      def variables(arg)
        raise TclVariableNotFoundError.new(arg, 'no such variables') unless
          @variables.key?(arg)
        @variables[arg]
      end

      def add_hook(name, &block)
        raise(ArgumentError, 'block is not given') unless block_given?
        @hooks[name.to_s] = block
      end

      def delete_hook(name)
        @hooks.delete(name.to_s)
      end

      private

      def parse_index_format(a)
        case a
        when /end-(\d+)/ then -1 - Regexp.last_match(1).to_i
        when /end/ then -1
        else a.to_i
        end
      end
    end
  end
end
