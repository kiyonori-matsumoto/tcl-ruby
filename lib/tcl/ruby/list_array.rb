require 'forwardable'

module Tcl
  module Ruby
    class ListArray
      extend Forwardable

      def_delegators :@ary, :find

      Array.public_instance_methods(false).each do |name|
        define_method(name) do |*args, &block|
          @ary.send(name, *args, &block)
        end
      end

      def uniq!(&block)
        @ary = @ary.reverse.uniq(&block).reverse
        self
      end

      def uniq(&block)
        dup.uniq!(&block)
      end

      def find_index_all
        raise ArgumentError unless block_given?
        r = []
        @ary.each_with_index do |e, idx|
          r << idx.to_s if yield(e)
        end
        r
      end

      def initialize(ary = [])
        @ary = Array(ary).map(&:to_s)
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
        raise(TclArgumentError, 'list must have an even number of elements') if
          @ary.size.odd?
        Hash[@ary.each_slice(2).to_a]
      end

      protected

      attr_accessor :ary
    end
  end
end
