module Tcl
  module Ruby
    class Interpreter
      private

      def ___llength(list)
        parse(list, true).size
      end

      def ___list(*arg)
        ListArray.new(arg).to_list
      end

      def ___lindex(list, *indexes)
        return list if indexes.nil? || indexes.size == 0
        l = list
        indexes.each do |as|
          parse(as, true).each do |a|
            l = parse(l, true)
            pos = parse_index_format(a)
            l = l[pos]
          end
        end
        l || ''
      end

      def ___join(list, separator = ' ')
        parse(list, true).join(separator)
      end

      def ___linsert(list, index, element, *elements)
        l = parse(list, true)
        l.insert(parse_index_format(index), element, *elements)
        l.to_list
      end

      def ___lrange(list, first, last)
        first = parse_index_format first
        last = parse_index_format last
        l = parse(list, true)
        l[first..last].to_list
      end

      def ___lappend(var_name, *values)
        l = parse(variables(var_name), true)
        l.push(*values)
        @variables[var_name] = l.to_list
      end
    end
  end
end
