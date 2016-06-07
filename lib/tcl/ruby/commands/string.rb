require 'strscan'

module Tcl
  module Ruby
    class Interpreter
      private

      def ___string(*arg)
        send("___string_#{arg[0]}", *arg[1..-1])
      rescue ArgumentError => e
        raise(TclArgumentError, "string #{arg[0]}: #{e.message}")
      end

      def ___string_length(str)
        str.length
      end

      def ___string_equal(*arg)
        opts = {}
        if arg.size != 2
          opts = OptionParser.parse(['nocase', 'length?'], arg)
          raise(TclArgumentError, 'string equal ?-nocase? ?-length int? string1 string2') unless arg.size == 2
        end
        __string_equal_body(*arg, opts)
      end

      def __string_equal_body(str1, str2, opts = {})
        if opts.key?('nocase')
          str1 = str1.upcase
          str2 = str2.upcase
        end
        if opts.key?('length')
          range = (0...opts['length'].to_i)
          (str1[range] == str2[range]) ? '1' : '0'
        else
          (str1 == str2) ? '1' : '0'
        end
      end

      def ___string_index(str, index)
        str[parse_index_format(index)]
      end

      def ___string_map(*arg)
        opts = {}
        if arg.size != 2
          opts = OptionParser.parse(['nocase'], arg)
          raise(TclArgumentError, 'string map ?-nocase? charMap string') unless arg.size == 2
        end
        __string_map_body(*arg, opts)
      end

      def __string_map_body(char_map, str, opts = {})
        h = parse(char_map, true).to_h
        scan = StringScanner.new str
        rstr = ''
        until scan.empty?
          r = h.each do |k, v|
            next unless (opts['nocase'] && scan.scan(/#{k}/i)) ||
                        scan.scan(/#{k}/)
            rstr << v
            break false
          end
          rstr << scan.scan(/./) if r
        end
        rstr
      end

      def ___string_range(str, first, last)
        first = parse_index_format first
        last = parse_index_format last
        str[first..last]
      end

      def ___string_repeat(str, count)
        str * count.to_i
      end

      def ___string_tolower(str, first = 0, last = nil)
        last ||= str.size
        __string_tosomething(str, first, last, :downcase)
      end

      def __string_tosomething(str, first, last, modifier)
        first = parse_index_format first
        last  = parse_index_format last
        str[first..last] = str[first..last].send(modifier)
        str
      end

      def ___string_totitle(str, first = 0, last = -1)
        __string_tosomething(str, first, last, :capitalize)
      end

      def ___string_toupper(str, first = 0, last = -1)
        __string_tosomething(str, first, last, :upcase)
      end

      def ___string_trim(str, chars = '\s')
        __string_trimmer(str, chars, 3)
      end

      def ___string_trimleft(str, chars = '\s')
        __string_trimmer(str, chars, 1)
      end

      def ___string_trimright(str, chars = '\s')
        __string_trimmer(str, chars, 2)
      end

      def __string_trimmer(str, chars, mode)
        str.sub!(/\A[#{chars}]+/, '') if mode & 1 != 0
        str.sub!(/[#{chars}]+\z/, '') if mode & 2 != 0
        str
      end
    end
  end
end
