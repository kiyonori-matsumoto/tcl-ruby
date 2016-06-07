require 'spec_helper.rb'

A = Tcl::Ruby::TclArgumentError
RSpec.describe Tcl::Ruby::Interpreter do
  describe '#parse string' do
    let(:f) { Tcl::Ruby::Interpreter.new }
    describe 'length' do
      it 'is able to parse length' do
        expect(f.parse 'string length "asdf   d"').to eq 8
      end
      it 'should raise error by wrong argument counts' do
        expect { f.parse 'string length' }
          .to raise_error A
        expect { f.parse 'string length 1 2' }
          .to raise_error A
      end
    end

    describe 'equal' do
      it 'should be 1 on same strings' do
        expect(f.parse 'string equal "abcd" abcd').to eq '1'
      end
      it 'should be 0 on different strings' do
        expect(f.parse 'string equal "bbb" "bbc"').to eq '0'
      end
      it 'should act with length' do
        expect(f.parse 'string equal -length 2 "bbb" "bbc"').to eq '1'
      end
      it 'should act with nocase' do
        expect(f.parse 'string equal -nocase "aaa" "AAA"').to eq '1'
      end
      it 'should raise error by mismatch argument count' do
        expect { f.parse 'string equal -length 2 -nocase "aaa"' }
          .to raise_error A
        expect { f.parse 'string equal ccc ddd eee' }
          .to raise_error A
        expect { f.parse 'string equal -lengtn 3 ccc ddd' }
          .to raise_error A
      end
    end

    describe 'index' do
      it 'returns the content on index' do
        expect(f.parse 'string index "Maga zine" 5').to eq 'z'
        expect(f.parse 'string index "asdf" 3').to eq 'f'
      end
      it 'returns the content on index with end' do
        expect(f.parse 'string index "asdf" end').to eq 'f'
        expect(f.parse 'string index "asdf" end-2').to eq 's'
      end
      it 'should raise error by mismatch argument count' do
        expect { f.parse 'string index "asdf"' }.to raise_error A
        expect { f.parse 'string index "asdf" 1 2' }.to raise_error A
      end
    end

    describe 'map' do
      it 'maps string' do
        expect(f.parse 'string map {abc 1 ab 2 a 3 1 0} 1abcaababcabababc').to eq '01321221'
      end
      it 'maps string with nocase' do
        expect(f.parse 'string map -nocase {ABC 1 aB 2 A 3 1 0} 1abcaababcabababc').to eq '01321221'
      end
      it 'should raise error by mismatch argument count' do
        expect { f.parse 'string map {1 2}' }.to raise_error A
        expect { f.parse 'string map -nocase {1 2} 123 4' }.to raise_error A
      end
    end

    describe 'range' do
      it 'returns ranged string' do
        expect(f.parse 'string range "firefox is strong" 4 15').to eq 'fox is stron'
      end
      it 'returns ranged string with end format' do
        expect(f.parse 'string range "House" end-3 end-1').to eq 'ous'
      end
      it 'returns empty string when first is larger than last' do
        expect(f.parse 'string range "house" 4 3').to eq ''
      end
      it 'should raise error by wrong argument counts' do
        expect { f.parse 'string range "aaa" 1 ' }.to raise_error A
        expect { f.parse 'string range "aaa" 1 2 3' }.to raise_error A
      end
    end

    describe 'repeat' do
      it 'returns repeated string' do
        expect(f.parse 'string repeat AAA 3').to eq 'AAAAAAAAA'
      end
      it 'should raise error by wrong argument counts' do
        expect { f.parse 'string repeat "aaa" ' }.to raise_error A
        expect { f.parse 'string repeat "aaa" 2 3' }.to raise_error A
      end
    end

    describe 'tolower' do
      it 'returns downcased string' do
        expect(f.parse 'string tolower AAA').to eq 'aaa'
      end
      it 'returns downcased string when first is specified' do
        expect(f.parse 'string tolower AAAA 2').to eq 'AAaa'
      end
      it 'returns downcased string when first and last are specified' do
        expect(f.parse 'string tolower AAAA 2 2').to eq 'AAaA'
      end
      it 'returns downcased string when first and last are specifieyd by end format' do
        expect(f.parse 'string tolower ASXCBV end-3 end').to eq 'ASxcbv'
      end
    end

    describe 'toupper' do
      it 'returns upcased string with first and last' do
        expect(f.parse 'string toupper asdf 1 2').to eq 'aSDf'
      end
    end

    describe 'totitle' do
      it 'returns capitalized string with first and last' do
        expect(f.parse 'string totitle ninja 1 2').to eq 'nInja'
      end
    end

    describe 'trim' do
      it 'replace redundant white-spaces' do
        expect(f.parse "string trim \" \t  asdf  \n \r \"").to eq 'asdf'
      end
      it 'replaces redundant specified chars' do
        expect(f.parse 'string trim "zzz1234zzzdz" dz').to eq '1234'
      end
      it 'should raise error on wrong argument counts' do
        expect { f.parse 'string trim ' }.to raise_error A
        expect { f.parse 'string trim aaaaaa aa a' }.to raise_error A
      end
    end

    describe 'trimleft' do
      it 'replace redundant white-spaces' do
        expect(f.parse "string trimleft \" \t  asdf  \n \r \"").to eq "asdf  \n \r "
      end
      it 'replaces redundant specified chars' do
        expect(f.parse 'string trimleft "zzz1234zzzdz" dz').to eq '1234zzzdz'
      end
      it 'should raise error on wrong argument counts' do
        expect { f.parse 'string trimleft ' }.to raise_error A
        expect { f.parse 'string trimleft aaaaaa aa a' }.to raise_error A
      end
    end

    describe 'trimright' do
      it 'replace redundant white-spaces' do
        expect(f.parse "string trimright \" \t  asdf  \n \r \"").to eq " \t  asdf"
      end
      it 'replaces redundant specified chars' do
        expect(f.parse 'string trimright "zzz1234zzzdz" dz').to eq 'zzz1234'
      end
      it 'should raise error on wrong argument counts' do
        expect { f.parse 'string trimright ' }.to raise_error A
        expect { f.parse 'string trimright aaaaaa aa a' }.to raise_error A
      end
    end
  end
end
