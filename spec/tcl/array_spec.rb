require 'spec_helper.rb'

RSpec.describe Tcl::Ruby::Interpreter do
  describe '#parse' do
    describe 'array set, get' do
      let(:f) { Tcl::Ruby::Interpreter.new }
      before(:each) do
        f.parse('array set ary {a b}')
        f.parse('set nonary {a b}')
      end

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
    end
  end
end
