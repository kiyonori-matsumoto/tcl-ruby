require 'strscan'

module Tcl
  module Ruby
    class Interpreter
      def parse(str, to_list = false)
        str.gsub!(/\\\n\s*/, ' ')
        s = StringScanner.new(str)
        r = ListArray.new
        pdepth = ddepth = bdepth = 0
        buffer = ''
        ret = nil
        until s.empty?
          if s.scan(/\\./)
            buffer << s[0]
          elsif !to_list && s.scan(/\r\n|\r|\n|;/)
            if pdepth == 0 && ddepth == 0 && bdepth == 0
              r << buffer
              ret = command(r) unless r.empty?
              r = ListArray.new
            else
              buffer << s[0]
            end
          elsif s.scan(/\s+/)
            if pdepth == 0 && ddepth == 0 && bdepth == 0
              r << buffer
            else
              buffer << s[0]
            end
          else
            buffer <<
              if s.scan(/{/)
                pdepth += 1 if buffer == '' || pdepth != 0
                s[0]
              elsif s.scan(/}/)
                ret = s[0]
                pdepth -= 1 if pdepth != 0
                raise(ParseError, 'extra characters after close-brace') if
                  buffer[0] == '{' && pdepth == 0 &&
                  ((to_list && !s.check(/\s|\z/)) || (!to_list && !s.check(/\s|\z|;/)))
                ret
              elsif !to_list && pdepth == 0 && s.scan(/\[/)
                bdepth += 1
                s[0]
              elsif !to_list && pdepth == 0 && s.scan(/\]/)
                bdepth -= 1
                s[0]
              elsif s.scan(/"/)
                ret = s[0]
                ddepth = 1 - ddepth if buffer == '' || buffer[0] == '"'
                raise(ParseError, 'extra characters after close-quote') if
                  buffer[0] == '"' && ddepth == 0 && !s.check(/\s|\z/)
                ret
              elsif s.scan(/\S/)
                s[0]
              else
                raise(ParseError, "parse error #{s.rest}")
              end
          end
        end
        r << buffer
        raise(ParseError, 'unmatched parenthesises') if
        ddepth != 0 || pdepth != 0 || bdepth != 0
        if to_list
          r.to_string
        else
          ret = command(r) unless r.empty?
          ret
        end
      end
    end
  end
end
