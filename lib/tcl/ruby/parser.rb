require 'strscan'

module Tcl
  module Ruby
    class Interpreter
      BRCKTS = %w({ [ ").freeze

      def parse(str, to_list = false)
        ex_char_check = lambda do |s, t|
          (t && !s.check(/\s|\z/)) || (!t && !s.check(/\s|\z|;/))
        end.curry

        str.gsub!(/\\\n\s*/, ' ')
        s = StringScanner.new(str)
        r = ListArray.new
        @pstack = []
        buffer = ''
        ret = nil
        until s.empty?
          if s.scan(/\\./)
            buffer << s[0]
          elsif s.scan(/\#/)
            if buffer.empty? && r.empty?
              s.scan(/.+$/) # skip till end of line
            else
              buffer << s[0]
            end
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
            analyze_brackets(buffer[-1], to_list, ex_char_check[s]) if
              BRCKTS.find_index(buffer[0])
          end
        end
        r << buffer
        raise(ParseError, 'unmatched parenthesises') if @pstack.any?
        if to_list
          r.to_string
        else
          ret = command(r) || ret
        end
      end

      private

      def analyze_brackets(bl, to_list, check)
        case bl
        when '{' then @pstack.push(:brace) if @pstack.last != :quote
        when '}'
          @pstack.pop if @pstack.last == :brace
          raise(ParseError, 'extra characters after close-brace') if
            @pstack.empty? && check[to_list]
        when '[' then @pstack.push(:bracket) if
          !to_list && @pstack.last != :brace
        when ']' then @pstack.pop if @pstack.last == :bracket
        when '"'
          if @pstack.last == :quote
            @pstack.pop
            raise(ParseError, 'extra characters after close-quote') if
              @pstack.empty? && check[to_list]
          elsif @pstack.last != :brace
            @pstack.push :quote
          end
        end
      end
    end
  end
end
