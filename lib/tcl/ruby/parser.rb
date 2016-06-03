require 'strscan'

module Tcl
  module Ruby
    class Interpreter
      BRCKTS = %w({ [ ").freeze

      def parse(str, to_list = false)
        str.gsub!(/\\\n\s*/, ' ')
        s = StringScanner.new(str)
        r = ListArray.new
        @pstack = []
        buffer = ''
        ret = nil
        until s.empty?
          if s.scan(/\\./)
            buffer << s[0]
          elsif !to_list && s.scan(/\r\n|\r|\n|;/)
            if @pstack.empty?
              r << buffer
              ret = command(r) || ret
              r = ListArray.new
            else
              buffer << s[0]
            end
          elsif s.scan(/\s+/)
            @pstack.empty? ? r << buffer : buffer << s[0]
          else
            buffer << s.scan(/\S/) || raise(ParserError, 'parse error')
            analyze_brackets(buffer[0], buffer[-1], to_list, s) if
              BRCKTS.find_index(buffer[0])
          end
        end
        r << buffer
        raise(ParseError, "unmatched parenthesises #{@pstack}") if
          @pstack.any?
        if to_list
          r.to_string
        else
          ret = command(r) || ret
          ret
        end
      end

      def analyze_brackets(b0, bl, to_list, s)
        case bl
        when '{' then @pstack.push(:brace) if
          @pstack[-1] != :quote
        when '}'
          @pstack.pop if @pstack[-1] == :brace
          raise(ParseError, 'extra characters after close-brace') if
            b0 == '{' && @pstack.empty? &&
            ((to_list && !s.check(/\s|\z/)) ||
             (!to_list && !s.check(/\s|\z|;/)))
        when '[' then @pstack.push(:bracket) if
          !to_list && @pstack[-1] != :brace
        when ']' then @pstack.pop if !to_list && @pstack[-1] == :bracket
        when '"'
          if @pstack[-1] != :brace
            if @pstack[-1] != :quote
              @pstack.push(:quote)
            else
              @pstack.pop
            end
          end
          raise(ParseError, 'extra characters after close-quote') if
            b0 == '"' && @pstack.empty? && !s.check(/\s|\z/)
        end
      end
    end
  end
end
