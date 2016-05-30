require "./tcl_rule.tab.rb"
require 'strscan'

class Tclp
  def initialize
    @yydebug = false
  end

  def parse(str)
    @q = []
    s = StringScanner.new(str)
    buffer = ""
    until s.empty?
      if s.scan(/{.*?(?<!\\)}/m)
        buffer << s[0]
      elsif s.scan(/".*?(?<!")"/m)
        buffer << s[0]
      elsif s.scan(/\\\n/m)
        # nothing
      elsif s.scan(/\\./)
        buffer << s[0]
      elsif s.scan(/\n|;/)
        @q.push [:IDENTIFIER, buffer] unless buffer.empty?
        @q.push [false, "END"]
        buffer = ""
        do_parse
        @q.clear
      elsif s.scan(/\s+/)
        @q.push [:IDENTIFIER, buffer ] unless buffer.empty?
        buffer = ""
      elsif s.scan(/\w+/)
        buffer << s[0]
      else
        raise ParseError.new("nothing matched, #{s.rest}")
      end
    end
    @q.push [:IDENTIFIER, buffer] unless buffer.empty?
    unless @q.empty?
      @q.push [false, "END"]
      do_parse
    end
  end

  def next_token
    @q.shift
  end
end

# parser = Tclp.new
# puts
# puts 'type "Q" to quit.'
# puts
# while true
#   puts
#   print '? '
#   str = gets.chop
#   break if /q/i =~ str
#   begin
#     puts "= #{parser.parse(str)}"
#   rescue ParseError
#     puts $!
#   end
# end
