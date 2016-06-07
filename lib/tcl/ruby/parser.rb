require 'strscan'

module Tcl
  module Ruby
    class Interpreter
      EX_CHAR_CHECK = lambda do |s, t|
        (t && !s.check(/\s|\z/)) || (!t && !s.check(/\s|\z|;/))
      end.curry

      def parse(str, to_list = false)
        str2 = (str + "\n").gsub(/\\\n\s*/, ' ') # replace \ & \n & extra ws
        @s = StringScanner.new(str2)
        @list_array = ListArray.new
        @pstack = [] # stack for brace, bracket, quote
        @buffer = '' # ListElement.new('')'' # buffer for list element
        @commands = []
        until @s.empty?
          if @s.scan(/\\./) then @buffer << @s[0]
          elsif @s.scan(/\#/) then parse_comments
          elsif !to_list && @s.scan(/\r\n|\r|\n|;/) then parse_command_ends
          elsif @s.scan(/\s/) then parse_blanks
          elsif @s.scan(/\S/)
            @buffer << @s[0]
            analyze_parentheses(to_list, EX_CHAR_CHECK[@s]) if
              @buffer.parenthesis?
          end
        end
        check_pstack
        to_list ? @list_array.to_string : command(@commands)
      end

      private

      def check_pstack
        raise(ParseError, "unmatched #{@pstack.last}s") if @pstack.any?
      end

      def parse_command_ends
        bl = @s[0]
        if @pstack.empty?
          @list_array << @buffer
          @list_array.to_string
          @commands << @list_array.dup
          @list_array.clear
        else
          @buffer << bl
        end
      end

      def parse_blanks
        @pstack.empty? ? @list_array << @buffer : @buffer << @s[0]
      end

      def parse_comments
        if @buffer.empty? && @list_array.empty?
          @s.scan(/.+$/)
        else
          @buffer << @s[0]
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

      def analyze_braces(to_list, extra_characters_check)
        if @buffer[-1] == '{'
          @pstack.push(:brace) if @pstack.last != :quote
        else
          matched_parentheses(:brace, extra_characters_check[to_list])
        end
      end

      def analyze_quotes(to_list, extra_characters_check)
        unless matched_parentheses(:quote, extra_characters_check[to_list])
          @pstack.push :quote if @pstack.last != :brace
        end
      end

      def analyze_brackets
        if @buffer[-1] == '[' && @pstack.last != :brace
          @pstack.push :bracket
        elsif @pstack.last == :bracket
          @pstack.pop
        end
      end

      def analyze_parentheses(to_list, extra_characters_check)
        bl = @buffer[-1]
        case bl
        when '{', '}' then analyze_braces(to_list, extra_characters_check)
        when '[', ']' then analyze_brackets unless to_list
        when '"' then analyze_quotes(to_list, extra_characters_check)
        end
      end
    end
  end
end
