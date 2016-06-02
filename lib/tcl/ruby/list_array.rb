module Tcl
  module Ruby
    class ListArray
      Array.public_instance_methods(false).each do |name|
        next if name == '<<' || name == 'to_a'
        define_method(name) do |*args, &block|
          @ary.send(name, *args, &block)
        end
      end

      def initialize
        @ary = []
      end

      def <<(buffer)
        @ary << buffer.dup unless buffer.empty?
        buffer.clear
        self
      end

      def to_a
        @ary
      end
    end
  end
end
