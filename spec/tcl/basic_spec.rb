require 'spec_helper.rb'

A = Tcl::Ruby::TclArgumentError

RSpec.describe Tcl::Ruby::Interpreter do
  describe '#parse' do
    let(:f) { Tcl::Ruby::Interpreter.new }
    describe 'comment' do
      it 'should do nothing' do
        expect(f.parse('# AAAAA')).to be_nil
      end
      it 'act with semi-colon' do
        expect(f.parse("set A 1; # aaaa; set A 2\n")).to eq '1'
      end
    end

    describe 'set' do
      it 'returns set-value' do
        expect(f.parse('set a 1')).to eq '1'
      end
    end

    describe 'if' do
      before(:each) do
        f.parse('set B 2')
      end
      it 'should act correctly' do
        expect(f.parse('if "$B==2" {set A 1}')).to eq '1'
      end
      it 'should act with 0' do
        expect(f.parse('if 1 [list set A 1]')).to eq '1'
        expect(f.parse('if 0 {set B 1}')).to be_nil
      end
      it 'should act correctly on if-else statement' do
        expect(f.parse('if {$B == 3} {set A 1} else {set A 2}')).to eq '2'
      end
      it 'should act correctly on if-elseif-else statement' do
        expect(f.parse('if {$B==3} then {set A 1} elseif {$B==2} then {set A 2} {set A 3}')).to eq '2'
      end
      it 'should act correctly on if-elseif-elseif-else statement' do
        expect(f.parse('if {$B==4} {set A 1} elseif {$B==3} {set A 2} elseif {$B==2} {set A 3} else {set A 4}')).to eq '3'
      end
    end

    describe 'for' do
      before(:each) do
        f.parse('set B 0')
      end
      it 'should act correctly' do
        f.parse('for {set A 0} {$A < 10} {incr A} {set B [expr $B + 1]}')
        expect(f.variables('B')).to eq '10'
      end
      it 'should act with break statement' do
        f.parse <<-EOS
        for {set A 0} {$A < 10} {incr A} {if {$A == 5} break; set B [expr $B + 1];}
        EOS
        expect(f.variables('B')).to eq '5'
      end
      it 'should act with continue statement' do
        f.parse <<-EOS
        for {set A 0} {$A < 10} {incr A} {if {$A == 5} continue; set B [expr $B + 1];}
        EOS
        expect(f.variables('B')).to eq '9'
      end
    end

    describe 'incr' do
      it 'should act with undefined variable' do
        expect(f.parse('incr undefined')).to eq '1'
        expect(f.variables('undefined')).to eq '1'
      end
    end

    describe 'foreach' do
      before(:each) do
        f.parse('set A {A B C D}')
        f.parse('set X {}')
      end
      it 'should act' do
        f.parse('foreach Z $A {lappend X $Z}')
        expect(f.variables('X')).to eq 'A B C D'
      end
      it 'should act with multiple assertions' do
        f.parse('foreach {i j} {A B C D E F G} {lappend X $j}')
        expect(f.variables('X')).to eq 'B D F {}'
      end
    end

    describe 'while' do
      before(:each) do
        f.parse('set B 0')
      end
      it 'should act' do
        f.parse('while {$B < 10} {incr B}')
        expect(f.variables('B')).to eq '10'
      end
    end

    describe 'proc' do
      it 'should act' do
        f.parse('proc aaaa {} { puts zzzz }')
        expect { f.parse('aaaa') }.to output("zzzz\n").to_stdout
      end
      it 'should act with arguments' do
        f.parse('proc aaaa {z} {global a; set a $z}')
        expect(f.parse('aaaa ninja')).to eq 'ninja'
        expect(f.variables('a')).to eq 'ninja'
      end
      it 'should not act with wrong # of arguments' do
        f.parse('proc aaaa {z} { global a; set a $z}')
        expect { f.parse('aaaa') }.to raise_error Tcl::Ruby::TclArgumentError
        expect { f.parse('aaaa 1 2') }
          .to raise_error Tcl::Ruby::TclArgumentError
      end
      it 'should return varue' do
        f.parse('proc aaaa {} { return 100 }')
        expect(f.parse('aaaa')).to eq '100'
      end
      it 'should act with multi_globals' do
        f.parse('proc aaaa {z} { if {$z == 1} { return 1 }; global a; incr a [aaaa [expr $z - 1]]; return $a }')
        expect(f.parse('aaaa 10')).to eq '256'
      end
    end

    describe 'format' do
      it 'returns format string' do
        expect(f.parse 'format "%02d" 3').to eq '03'
      end
      it 'returns format string with multiple args' do
        expect(f.parse 'format "%-3s %0.3f" "N" 2.5').to eq 'N   2.500'
      end
      it 'should raise error on format mismatch' do
        expect { f.parse 'format "%-3s %0.3f" "N"' }
          .to raise_error Tcl::Ruby::TclArgumentError
      end
    end

    describe 'eval' do
      it 'evaluate list' do
        expect(f.parse 'eval [list set A 1]').to eq '1'
      end
      it 'evaluate multiple arguments' do
        expect(f.parse 'eval {set A 1} {;} {set B 3}').to eq '3'
        expect(f.variables('A')).to eq '1'
        expect(f.variables('B')).to eq '3'
      end
      it 'should raise error on wrong argument count' do
        expect { f.parse 'eval' }.to raise_error A
      end
    end
  end
end
