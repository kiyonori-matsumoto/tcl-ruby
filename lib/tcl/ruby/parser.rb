require 'strscan'

module Tcl
  module Ruby
    class Interpreter
      EX_CHAR_CHECK = lambda do |s, t|
        (t && !s.check(/\s|\z/)) || (!t && !s.check(/\s|\z|;/))
      end.curry

      def parse(str, to_list = false)
        str << "\n"
        str.gsub!(/\\\n\s*/, ' ') # replace back-slash & linebreak & extra ws
        s = StringScanner.new(str)
        r = ListArray.new
        @pstack = [] # stack for brace, bracket, quote
        buffer = '' # ListElement.new('')'' # buffer for list element
        ret = nil # return value
        # rr = []
        until s.empty?
          if s.scan(/\\./) then buffer << s[0]
          elsif s.scan(/\#/) then parse_comments(s[0], buffer, r, s)
          elsif !to_list && s.scan(/\r\n|\r|\n|;/)
            ret = parse_command_ends(s[0], buffer, r) || ret
            # parse_command_ends(s[0], buffer, r, rr)
            # r = ListArray.new
          elsif s.scan(/\s/) then parse_blanks(s[0], buffer, r)
          elsif s.scan(/\S/)
            buffer << s[0]
            analyze_parentheses(buffer[-1], to_list, EX_CHAR_CHECK[s]) if
              buffer.parenthesis?
          end
        end
        check_pstack
        to_list ? r.to_string : ret
      end

      private

      def check_pstack
        raise(ParseError, "unmatched #{@pstack.last}s") if @pstack.any?
      end

      def parse_command_ends(bl, buffer, r)
        if @pstack.empty?
          r << buffer
          r.to_string
          ret = command(r)
          # rr << r
          r.clear
          # r = ListArray.new
          ret
        else
          buffer << bl
        end
      end

      def parse_blanks(bl, buffer, r)
        @pstack.empty? ? r << buffer : buffer << bl
      end

      def parse_comments(bl, buffer, r, s)
        if buffer.empty? && r.empty?
          s.scan(/.+$/)
        else
          buffer << bl
        end
      end

      def matched_parentheses(id, has_ex_char)
        if @pstack.last == id
          r = @pstack.pop
          if @pstack.empty? && has_ex_char
            raise(ParseError, "extra characters after close-#{id}")
          end
          r
        end
      end

      def analyze_braces(bl, to_list, extra_characters_check)
        if bl == '{'
          @pstack.push(:brace) if @pstack.last != :quote
        else
          matched_parentheses(:brace, extra_characters_check[to_list])
        end
      end

      def analyze_quotes(_bl, to_list, extra_characters_check)
        unless matched_parentheses(:quote, extra_characters_check[to_list])
          @pstack.push :quote if @pstack.last != :brace
        end
      end

      def analyze_brackets(bl)
        if bl == '[' && @pstack.last != :brace
          @pstack.push :bracket
        elsif @pstack.last == :bracket
          @pstack.pop
        end
      end

      def analyze_parentheses(bl, to_list, extra_characters_check)
        case bl
        when '{', '}' then analyze_braces(bl, to_list, extra_characters_check)
        when '[', ']' then analyze_brackets(bl) unless to_list
        when '"' then analyze_quotes(bl, to_list, extra_characters_check)
        end
      end
    end
  end
end
