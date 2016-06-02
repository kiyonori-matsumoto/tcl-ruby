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
        @ary << buffer.dup unless buffer.empty?
        buffer.clear
        self
      end

      def to_string
        @ary.map! { |e| _to_string(e) }
        self
      end

      def to_list
        @ary.map { |e| _to_list(e) }.join(' ')
      end

      def map!(&block)
        @ary.map!(&block)
        self
      end

      def map(&block)
        r = dup
        r.map!(&block)
        r
      end

      def [](arg)
        if arg.is_a?(Range)
          r = dup
          r.ary = r.ary[arg]
          r
        else
          @ary.[](arg)
        end
      end

      protected

      attr_accessor :ary

      private

      def _to_string(str)
        if str[0] == '{' && str[-1] == '}'
          str = str[1..-2]
        elsif str[0] == '"' && str[-1] == '"'
          str = str[1..-2]
        end
        str
      end

      def _to_list(str)
        if str == '' || str.match(/\s/)
          "{#{str}}"
        else
          str
        end
      end
    end
  end
end
