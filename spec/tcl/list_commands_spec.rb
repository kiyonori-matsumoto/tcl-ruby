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
      expect(f.parse(str)).to eq '3'
    end

    it 'returns length of null-list' do
      expect(f.parse('llength {}')).to eq '0'
    end

    it 'returns lenght of list when semi-colon is included' do
      str = 'llength {B C ; DESF}'
      expect(f.parse(str)).to eq '4'
    end

    it 'returns length of list when multiple parenthesis are' do
      str = 'llength {B C {D E}}'
      expect(f.parse(str)).to eq '3'
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

    describe 'concat' do
      it 'returns concat string' do
        expect(f.parse('concat a b {c d e} {f {g h}}')).to eq 'a b c d e f {g h}'
        expect(f.parse('concat " a b {c    " d "  e} f"')).to eq 'a b {c d e} f'
      end
    end

    describe 'lsort' do
      it 'sorts list without option' do
        expect(f.parse('lsort {a b d c e}')).to eq 'a b c d e'
      end
      it 'sorts list with integer option' do
        expect(f.parse('lsort -integer {1 2 3 30 4}')).to eq '1 2 3 4 30'
      end
      it 'sorts list with real option' do
        expect(f.parse('lsort -real {2 1 3 3.1 30 4}')).to eq '1 2 3 3.1 4 30'
        expect(f.parse('lsort       {2 1 3 3.1 30 4}')).to eq '1 2 3 3.1 30 4'
      end
      it 'sorts list reversed with decreasing option' do
        expect(f.parse('lsort -decreasing {a b d c e}')).to eq 'e d c b a'
      end
      it 'returns uniqued list with unique option' do
        expect(f.parse('lsort -unique {a b b a c}')).to eq 'a b c'
      end
      it 'returns sorted list with index option' do
        expect(f.parse('lsort -index 1 {{1 z} {2 a}} ')).to eq '{2 a} {1 z}'
        expect(f.parse('lsort -index 0 -unique {{1 a} {1 b}}')).to eq '{1 b}'
      end
    end

    describe 'lsearch' do
      it 'searches list element' do
        expect(f.parse 'lsearch {a b c d e} c').to eq '2'
      end
      it 'searches list element with -inline option' do
        expect(f.parse 'lsearch -inline {a b c d e} c').to eq 'c'
      end
      it 'searches list elements with -all option' do
        expect(f.parse 'lsearch -all {a b a b c} a').to eq '0 2'
      end
      it 'searches list elements with both -all and -inline options' do
        expect(f.parse 'lsearch -all -inline {a b a b c} a').to eq 'a a'
      end
      it 'searches list elements with globe style' do
        expect(f.parse 'lsearch -all -inline {a12 b23 c34} {a*}').to eq 'a12'
        expect(f.parse 'lsearch -all -inline {a aa ab ac bc} {a?}').to eq 'aa ab ac'
      end
      it 'searches list with regexp option' do
        expect(f.parse 'lsearch -all -inline -regexp {a12 b23 c34} {.1.}').to eq 'a12'
      end
      it 'searches list with not option' do
        expect(f.parse 'lsearch -all -inline -not -regexp {a12 b23 c34} {.1.}').to eq 'b23 c34'
        expect(f.parse 'lsearch -not {a b c d e} c').to eq '0'
        expect(f.parse 'lsearch -inline -not {a b c d e} c').to eq 'a'
      end
    end
  end
end
