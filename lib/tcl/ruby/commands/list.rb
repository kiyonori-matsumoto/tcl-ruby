module Tcl
  module Ruby
    class Interpreter
      private

      def ___concat(*arg)
        arg.map(&:strip).join(' ')
      end

      def ___llength(list)
        parse(list, true).size.to_s
      end

      def ___list(*arg)
        ListArray.new(arg).to_list
      end

      def ___lindex(list, *indexes)
        return list if indexes.nil? || indexes.empty?
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

      def ___lsort(*args)
        opts = {}
        if args.size > 1
          opts = OptionParser.parse(
            ['ascii', 'dictionary', 'integer', 'real', 'command?', 'increasing',
             'decreasing', 'index?', 'unique'], args
          )
        end
        __lsort_body(*args, opts)
      end

      def __lsort_body(list, opts)
        l = parse(list, true)
        func = lsort_func_name(opts)
        sort_func = func
        if opts['index']
          index = parse_index_format(opts['index'])
          sort_func = -> (x) { parse(x, true)[index].send(func) }
        end
        l.uniq!(&sort_func) if opts['unique']
        l.sort_by!(&sort_func)
        l.reverse! if opts['decreasing']
        ListArray.new(l).to_list
      end

      def lsort_func_name(opts)
        if opts['directionary'] then :upcase
        elsif opts['integer'] then :to_i
        elsif opts['real'] then :to_f
        else :to_s
        end
      end

      def ___lsearch(*args)
        opts = {}
        if args.size > 2
          opts = OptionParser.parse(
            ['all', 'ascii', 'decreasing', 'dictionary', 'exact', 'glob',
             'increasing', 'inline', 'integer', 'not', 'real', 'regexp',
             'sorted', 'start?'], args
          )
        end
        __lsearch_body(*args, opts)
      end

      def __lsearch_body(list, pattern, opts)
        func = lsearch_func_name(opts)
        block = lsearch_search_func(pattern, opts)
        l = parse(list, true)
        v = l.send(func, &block.call(!opts['not']))
        ListArray.new(v).to_list
      end

      def lsearch_func_name(opts)
        case [opts['all'], opts['inline']]
        when [true, true] then :select
        when [true, nil] then :find_index_all
        when [nil, true] then :find
        else :index
        end
      end

      def lsearch_search_func(pattern, opts)
        if opts['regexp'] then -> (b, x) { !!(x =~ /#{pattern}/) == b }
        elsif opts['exact'] then -> (b, x) { (x == pattern) == b }
        else
          ptn = pattern.gsub(/\*/, '.*').tr('?', '.')
                       .gsub(/\\(.)/) { Regexp.last_match(1) }
          -> (b, x) { !!(x =~ /\A#{ptn}\z/) == b }
        end.curry
      end
    end
  end
end
