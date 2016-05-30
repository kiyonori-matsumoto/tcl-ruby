class Calcp
  prechigh
    nonassoc UMINUS
    left '*' '/'
    left '+' '-'
  preclow
rule
  target: exp
        | /* none */ { result = 0 }

  exp: exp '+' exp { result += val[2] }
     | exp '-' exp { result -= val[2] }
     | exp '*' exp { result *= val[2] }
     | exp '/' exp { result /= val[2] }
     | '(' exp ')' { result = val[1] }
     | '-' NUMBER =UMINUS { result = -val[1] }
     | NUMBER
end
---- header
require 'strscan'

---- inner
def parse(str)
  @q = []
  str = StringScanner.new(str)
  until str.empty?
    if str.scan(/\s+/)
    elsif (s = str.scan(/\d+/))
      @q.push [:NUMBER, s.to_i]
    elsif (s = str.scan(/.|\n/))
      @q.push [s, s]
    end
  end
  @q.push [false, '$end']
  do_parse
end

def next_token
  @q.shift
end

---- footer

parser = Calcp.new
puts
puts 'type "Q" to quit.'
puts
while true
  puts
  print '? '
  str = gets.chop
  break if /q/i =~ str
  begin
    puts "= #{parser.parse(str)}"
  rescue ParseError
    puts $!
  end
end
