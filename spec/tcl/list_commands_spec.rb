require 'spec_helper.rb'

RSpec.describe Tcl::Ruby::Interpreter do
  describe 'execution of list commands' do
    let(:f) { Tcl::Ruby::Interpreter.new }
    it 'creates list' do
      str = 'list A B C'
      expect(f.parse(str)).to eq 'A B C'
    end

    it 'creates list with null-list' do
      expect(f.parse('set a [list {} {} {}]')).to eq '{} {} {}'
    end

    it 'returns length of list' do
      str = 'llength {A B C}'
      expect(f.parse(str)).to eq 3
    end

    it 'returns length of null-list' do
      expect(f.parse('llength {}')).to eq 0
    end

    it 'returns lenght of list when semi-colon is included' do
      str = 'llength {B C ; DESF}'
      expect(f.parse(str)).to eq 4
    end

    it 'returns length of list when multiple parenthesis are' do
      str = 'llength {B C {D E}}'
      expect(f.parse(str)).to eq 3
    end

    it 'returns index of list' do
      expect(f.parse('lindex {A B C} 1')).to eq 'B'
      expect(f.parse('lindex {A {B C} D} 1')).to eq 'B C'
    end

    it 'returns nothing out of list' do
      expect(f.parse('lindex {A B C} 4')).to eq ''
    end

    it 'returns list element on various sample' do
      expect(f.parse('lindex {a b c}')).to eq 'a b c'
      expect(f.parse('lindex {a b c} {}')).to eq 'a b c'
      expect(f.parse('lindex {a b c} 0')).to eq 'a'
      expect(f.parse('lindex {a b c} 2')).to eq 'c'
      expect(f.parse('lindex {a b c} end')).to eq 'c'
      expect(f.parse('lindex {a b c} end-1')).to eq 'b'
      expect(f.parse('lindex {{a b c} {d e f} {g h i}} 2 1')).to eq 'h'
      expect(f.parse('lindex {{a b c} {d e f} {g h i}} {2 1}')).to eq 'h'
      expect(f.parse('lindex {{{a b} {c d}} {{e f} {g h}}} 1 1 0')).to eq 'g'
      expect(f.parse('lindex {{{a b} {c d}} {{e f} {g h}}} {1 1 0}')).to eq 'g'
    end

    it 'returns joined string' do
      expect(f.parse('join {A B C}')).to eq 'A B C'
      expect(f.parse('join {A B DDD} ","')).to eq 'A,B,DDD'
    end

    it 'returns inserted list' do
      expect(f.parse('linsert {A B C} 2 D')).to eq 'A B D C'
      expect(f.parse('linsert {A  B  C} 1 D E')).to eq 'A D E B C'
      expect(f.parse('linsert {a b {c d} e} 1 {d e}')).to eq 'a {d e} b {c d} e'
      expect { f.parse('linsert {A B C} 1') }
        .to raise_error Tcl::Ruby::TclArgumentError
    end

    it 'returns ranged list' do
      expect(f.parse('lrange {A B C D} 0 2')).to eq 'A B C'
      expect(f.parse('lrange {A B C D} -1 1')).to eq 'A B'
      expect(f.parse('lrange {A  B  ZED  {D T}} 2 6')).to eq 'ZED {D T}'
      expect(f.parse('lrange {A B C} 2 1')).to eq ''
      expect { f.parse('lrange {A B C} 2') }
        .to raise_error Tcl::Ruby::TclArgumentError
    end
  end
end
