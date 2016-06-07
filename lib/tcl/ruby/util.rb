module Tcl
  module Ruby
    class Interpreter
      def initialize
        @variables = {}
        @global = @variables
        @v_stack = []
        @hooks = {}
        @proc = {}
        @files = {}
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

      def commands
        r = []
        r.concat private_methods.select { |e| e.match(/^___/) }
                                .map { |e| e[3..-1] }
        r.concat @proc.keys
        r.concat @hooks.keys
        r
      end

      private

      def parse_index_format(a)
        case a
        when /end-(\d+)/ then -1 - Regexp.last_match(1).to_i
        when /end/ then -1
        else
          r = a.to_i
          r < 0 ? 0 : r
        end
      end

      def get_fp(id, delete: false)
        if @files.key?(id)
          delete ? @files.delete(id) : @files[id]
        else
          raise(CommandError, "cannnot find channel named #{id}")
        end
      end
    end
  end
end
