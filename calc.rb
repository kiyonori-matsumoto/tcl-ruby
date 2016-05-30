#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.14
# from Racc grammer file "".
#

require 'racc/parser.rb'

require 'strscan'

class Calcp < Racc::Parser

module_eval(<<'...end calc.y/module_eval...', 'calc.y', 23)
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

...end calc.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
     9,    10,     7,     8,     6,    18,     4,     3,    12,     5,
     9,    10,     7,     8,     4,     3,    13,     5,     4,     3,
   nil,     5,     4,     3,   nil,     5,     4,     3,   nil,     5,
     4,     3,   nil,     5,     9,    10,     9,    10 ]

racc_action_check = [
    11,    11,    11,    11,     1,    11,     3,     3,     4,     3,
     2,     2,     2,     2,     0,     0,     6,     0,    10,    10,
   nil,    10,     9,     9,   nil,     9,     8,     8,   nil,     8,
     7,     7,   nil,     7,    15,    15,    14,    14 ]

racc_action_pointer = [
     8,     4,     7,     0,    -1,   nil,    16,    24,    20,    16,
    12,    -3,   nil,   nil,    33,    31,   nil,   nil,   nil ]

racc_action_default = [
    -2,   -10,    -1,   -10,   -10,    -9,   -10,   -10,   -10,   -10,
   -10,   -10,    -8,    19,    -3,    -4,    -5,    -6,    -7 ]

racc_goto_table = [
     2,     1,   nil,    11,   nil,   nil,   nil,    14,    15,    16,
    17 ]

racc_goto_check = [
     2,     1,   nil,     2,   nil,   nil,   nil,     2,     2,     2,
     2 ]

racc_goto_pointer = [
   nil,     1,     0 ]

racc_goto_default = [
   nil,   nil,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 11, :_reduce_none,
  0, 11, :_reduce_2,
  3, 12, :_reduce_3,
  3, 12, :_reduce_4,
  3, 12, :_reduce_5,
  3, 12, :_reduce_6,
  3, 12, :_reduce_7,
  2, 12, :_reduce_8,
  1, 12, :_reduce_none ]

racc_reduce_n = 10

racc_shift_n = 19

racc_token_table = {
  false => 0,
  :error => 1,
  :UMINUS => 2,
  "*" => 3,
  "/" => 4,
  "+" => 5,
  "-" => 6,
  "(" => 7,
  ")" => 8,
  :NUMBER => 9 }

racc_nt_base = 10

racc_use_result_var = true

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "UMINUS",
  "\"*\"",
  "\"/\"",
  "\"+\"",
  "\"-\"",
  "\"(\"",
  "\")\"",
  "NUMBER",
  "$start",
  "target",
  "exp" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

module_eval(<<'.,.,', 'calc.y', 8)
  def _reduce_2(val, _values, result)
     result = 0 
    result
  end
.,.,

module_eval(<<'.,.,', 'calc.y', 10)
  def _reduce_3(val, _values, result)
     result += val[2] 
    result
  end
.,.,

module_eval(<<'.,.,', 'calc.y', 11)
  def _reduce_4(val, _values, result)
     result -= val[2] 
    result
  end
.,.,

module_eval(<<'.,.,', 'calc.y', 12)
  def _reduce_5(val, _values, result)
     result *= val[2] 
    result
  end
.,.,

module_eval(<<'.,.,', 'calc.y', 13)
  def _reduce_6(val, _values, result)
     result /= val[2] 
    result
  end
.,.,

module_eval(<<'.,.,', 'calc.y', 14)
  def _reduce_7(val, _values, result)
     result = val[1] 
    result
  end
.,.,

module_eval(<<'.,.,', 'calc.y', 15)
  def _reduce_8(val, _values, result)
     result = -val[1] 
    result
  end
.,.,

# reduce 9 omitted

def _reduce_none(val, _values, result)
  val[0]
end

end   # class Calcp


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
