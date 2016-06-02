module Tcl
  module Ruby
    class ListArray
      Array.public_instance_methods(false).each do |name|
        next if name == '<<'
        define_method(name) do |*args, &block|
          @ary.send(name, *args, &block)
        end
      end

      def initialize
        @ary = []
      end

      def <<(buffer)
        raise(ParseError, 'extra characters after close-quote') if
          buffer[0] == '"' && buffer[-1] != '"'
        raise(ParseError, 'extra characters after close-brace') if
          buffer[0] == '{' && buffer[-1] != '}'
        @ary << buffer
        self
      end
    end
  end
end
