require 'spec_helper.rb'

RSpec.describe Tcl::Ruby::Interpreter do
  describe '#parse array' do
    let(:f) { Tcl::Ruby::Interpreter.new }
    before(:each) do
      f.parse('array set ary {a b}')
      f.parse('set nonary {a b}')
    end
    describe 'set, get' do
      it 'should create new array' do
        expect(f.parse('array get ary a')).to eq 'a b'
      end
      it 'should replace array variables' do
        expect { f.parse('puts $ary(a)') }.to output("b\n").to_stdout
      end
      it 'should overwrite array variables' do
        f.parse('array set ary {a c}')
        expect(f.variables('ary')['a']).to eq 'c'
      end
      it 'should create with multiple elements' do
        f.parse('array set ary {a b c d e f g h}')
        [%w(a b), %w(c d), %w(e f), %w(g h)].each do |a|
          expect(f.variables('ary')[a[0]]).to eq a[1]
        end
        expect(f.parse('array get ary')).to eq 'a b c d e f g h'
      end
      it 'should return null-list with not-existed key' do
        expect(f.parse('array get ary c')).to eq ''
      end
      it 'should return null-list with non-array variable' do
        expect(f.parse('array get nonary a')).to eq ''
      end
      it 'should raise error replace array variables without ()' do
        expect { f.parse('puts $ary') }
          .to raise_error(Tcl::Ruby::TclVariableNotFoundError)
      end
      it 'should raise error replace non-array variables with ()' do
        expect { f.parse('puts $nonary(a)') }
          .to raise_error Tcl::Ruby::TclVariableNotFoundError
      end
      it 'should raise error when create array with odd-numbered list' do
        expect { f.parse('array set ary {a b c}') }
          .to raise_error Tcl::Ruby::TclArgumentError
      end
      it 'should raise error on adding array element to non-array variable' do
        expect { f.parse('array set nonary {a b}') }
          .to raise_error Tcl::Ruby::CommandError
      end
      it 'should get array with multiple replacement' do
        str = <<EOS
set abc(a.b) 100
set abc(a.c) 200
set index c
puts $abc(a.$index)
EOS
        expect { f.parse(str) }.to output("200\n").to_stdout
      end
    end

    describe 'exists' do
      it 'should return 1 to array' do
        expect(f.parse('array exists ary')).to eq '1'
      end
      it 'should return 0 to non-array' do
        expect(f.parse('array exists nonary')).to eq '0'
        expect(f.parse('array exists undef')).to eq '0'
      end
    end

    describe 'unset' do
      it 'should unset array' do
        expect(f.parse('array unset ary')).to eq ''
        expect { f.variables('ary') }.to raise_error(
          Tcl::Ruby::TclVariableNotFoundError)
      end
      it 'should unset array with pattern' do
        expect(f.parse('array unset ary a')).to eq ''
        expect(f.variables('ary')).not_to have_key('a')
      end
      it 'should not unset non-array' do
        expect(f.parse('array unset nonary')).to eq ''
        expect(f.variables('nonary')).to eq 'a b'
      end
    end
  end
end
