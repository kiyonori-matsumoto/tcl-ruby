require './tcl_rule.tab.rb'
require 'strscan'
require './tcl_commands.rb'

class Tclp
  include TclCommands
  def initialize(command_exec = false)
    @yydebug = false
    @command_exec = command_exec
  end

  def parse(str, _command_exec = true)
    @q = []
    s = StringScanner.new(str)
    buffer = ''
    until s.empty?
      if s.scan(/(?<big>(?<!\\){([^{}]*?(\g<big>)*[^{}]*?)(?<!\\)})/m)
        buffer << s[0][1..-2]
      elsif s.scan(/".*?(?<!\\)"/m)
        buffer << s[0][1..-2]
      elsif s.scan(/\\\n/m)
        unless buffer.empty?
          @q.push [:IDENTIFIER, buffer]
          buffer = ''
        end
      elsif s.scan(/\\./)
        buffer << s[0]
      elsif s.scan(/\n|;/)
        @q.push [:IDENTIFIER, buffer] unless buffer.empty?
        @q.push [:EOL, '']
        @q.push [false, 'END']
      elsif s.scan(/\s+/)
        @q.push [:IDENTIFIER, buffer] unless buffer.empty?
        buffer = ''
      elsif s.scan(/\w+/)
        buffer << s[0]
      else
        raise ParseError.new("nothing matched, #{s.rest}")
      end
    end
    @q.push [:IDENTIFIER, buffer] unless buffer.empty?
    unless @q.empty?
      @q.push [:EOL, '']
      @q.push [false, 'END']
      do_parse
    end
  end

  def next_token
    @q.shift
  end

  def tcl_exec(arg)
    if @command_exec
      send("___#{arg[0]}", arg[1..-1])
    else
      arg # return as array
    end
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
