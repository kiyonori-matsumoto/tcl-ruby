module Tcl
  module Ruby
    class Interpreter
      private

      def ___llength(arg)
        raise(CommandError, 'llength list') if arg.size != 1
        parse(arg[0], true).size
      end

      def ___list(arg)
        arg.to_list
      end

      def ___lindex(arg)
        return arg[0] if arg[1].nil? || arg[1] == ''
        l = arg[0]
        arg[1..-1].each do |as|
          parse(as, true).each do |a|
            l = parse(l, true)
            pos = case a
                  when /end-(\d+)/ then l.size - 1 - Regexp.last_match(1).to_i
                  when /end/ then l.size - 1
                  else a.to_i
                  end
            return '' unless (0...l.size).cover?(pos)
            l = l[pos]
          end
        end
        l
      end

      def ___join(arg)
        raise(CommandError, 'join list joinString?') unless
          (1..2).cover? arg.size
        separator = arg[1] || ' '
        parse(arg[0], true).join(separator)
      end

      def ___linsert(arg)
        raise(CommandError, 'linsert list insertposition elements') unless
          arg.size >= 3
        l = parse(arg[0], true)
        l.insert(arg[1].to_i, *arg[2..-1])
        l.to_list
      end

      def ___lrange(arg)
        raise(CommandError, 'lrange list first last') unless arg.size == 3
        first = arg[1].to_i
        first = 0 if first < 0
        last = arg[2].to_i
        l = parse(arg[0], true)
        if first <= last
          l[first..last].to_list
        else
          ''
        end
      end

      def ___lappend(arg)
        l = parse(variables(arg[0]), true)
        l.push(*arg[1..-1])
        @variables[arg[0]] = l.to_list
      end
    end
  end
end
