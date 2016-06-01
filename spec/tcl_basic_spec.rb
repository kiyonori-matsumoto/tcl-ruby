require 'rspec'
require_relative '../lib/tcl_ruby.rb'

RSpec.describe 'TclField' do
  describe '#parse' do
    let(:f) { TclField.new }
    describe 'comment' do
      it 'should do nothing' do
        expect(f.parse('# AAAAA')).to be_nil
      end
    end

    describe 'if' do
      before(:each) do
        f.parse('set B 2')
      end
      it 'should act correctly' do
        expect(f.parse('if {1 == 1} {set A 1}')).to eq "1"
      end

      it 'should act correctly on if-else statement' do
        expect(f.parse('if {$B == 3} {set A 1} else {set A 2}')).to eq '2'
      end

      it 'should act correctly on if-elseif-else statement' do
        expect(f.parse('if {$B==3} then {set A 1} elseif {$B==2} then {set A 2} {set A 3}')).to eq '2'
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
  end
end
