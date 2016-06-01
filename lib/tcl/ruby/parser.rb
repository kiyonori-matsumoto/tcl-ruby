require 'strscan'
module Tcl
  module Ruby
    class TclField
      def parse(str, to_list = false)
        s = StringScanner.new(str)
        r = []
        pdepth = ddepth = bdepth = 0
        buffer = ''
        ret = nil
        until s.empty?
          if s.scan(/\\./m)
            buffer << s[0] unless s[0][1] =~ /\s/
          elsif !to_list && s.scan(/\r\n|\r|\n|;/)
            if pdepth == 0 && ddepth == 0 && bdepth == 0
              r << buffer unless buffer.empty?
              buffer = ''
              ret = command(r) unless r.empty?
              r = []
            else
              buffer << s[0]
            end
          elsif s.scan(/\s+/)
            if pdepth == 0 && ddepth == 0 && bdepth == 0
              r << buffer unless buffer.empty?
              buffer = ''
            else
              buffer << s[0]
            end
          else
            if s.scan(/{/)
              pdepth += 1 if ddepth == 0
            elsif s.scan(/}/)
              pdepth -= 1 if ddepth == 0
            elsif !to_list && s.scan(/\[/)
              bdepth += 1
            elsif !to_list && s.scan(/\]/)
              bdepth -= 1
            elsif s.scan(/"/)
              ddepth = 1 - ddepth if pdepth == 0
            elsif s.scan(/\S/)
              # nil
            else
              raise(ParseError, "parse error #{s.rest}")
            end
            buffer << s[0]
          end
        end
        r << buffer unless buffer.empty?
        ret = command(r) if !r.empty? && !to_list
        raise(ParseError, 'unmatched parenthesises') if ddepth != 0 ||
                                                        pdepth != 0 || bdepth != 0
        if to_list
          r
        else
          ret
        end
      end
    end
  end
end
