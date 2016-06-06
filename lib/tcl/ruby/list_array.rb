module Tcl
  module Ruby
    class ListArray
      Array.public_instance_methods(false).each do |name|
        define_method(name) do |*args, &block|
          @ary.send(name, *args, &block)
        end
      end

      def initialize
        @ary = []
        @brackets = []
      end

      def clear
        @ary = []
        @brackets = []
      end

      def bracket_add(val)
        @brackets[@ary.size] ||= []
        @brackets[@ary.size] << val
      end

      def <<(buffer)
        @ary << buffer.dup unless buffer.empty?
        buffer.clear
        buffer.init
        self
      end

      def to_string
        @ary.map!(&:to_tcl_string)
        self
      end

      def to_list
        @ary.map(&:to_tcl_list).join(' ')
      end

      def replace
        @ary.size.times do |n|
          @ary[n] = yield(@ary[n]) unless @ary[n].brace?
        end
        # @ary.map! { |m| m.brace? ? m : yield(m) }
        self
      end

      def map!(&block)
        @ary.each(&:init)
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

      def to_h
        Hash[@ary.each_slice(2).to_a]
      end

      protected

      attr_accessor :ary
    end
  end
end
