require 'spec_helper.rb'

RSpec.describe Tcl::Ruby::Interpreter do
  describe '#parse' do
    describe 'initialized with "to_list = true"' do
      let(:tclp) { Tcl::Ruby::Interpreter.new }
      it 'is able to parse normal' do
        str = 'set A B'
        expect(tclp.parse(str, true)).to eq %w(set A B)
      end

      it 'is able to parse parenthesis' do
        str = 'set A {B C D}'
        expect(tclp.parse(str, true)).to eq ['set', 'A', '{B C D}']
      end

      it 'is able to parse dquote' do
        str = 'set A "B C D"'
        expect(tclp.parse(str, true)).to eq ['set', 'A', '"B C D"']
      end

      it 'is able to parse dquart with backslash' do
        str = 'set A "B C \"D"'
        expect(tclp.parse(str, true)).to eq ['set', 'A', '"B C \"D"']
      end

      it 'is able to parse multiline' do
        str = 'set A \
        B'
        expect(tclp.parse(str, true)).to eq %w(set A B)
      end

      it 'is able to parse if statement' do
        str = 'if {A < B} {set A B}'
        expect(tclp.parse(str, true)).to eq ['if', '{A < B}', '{set A B}']
      end

      it 'is able to multi-brackets' do
        str = 'set A {B C {D E}}'
        expect(tclp.parse(str, true)).to eq ['set', 'A', '{B C {D E}}']
      end

      it 'is not able to parse unbarance parenthesises' do
        str = 'set A {B C {D E}'
        expect { tclp.parse(str, true) }.to raise_error Tcl::Ruby::ParseError
      end
    end

    describe 'basic command parser' do
      let(:f) { Tcl::Ruby::Interpreter.new }
      P = Tcl::Ruby::ParseError
      it 'should raise error on unmatched parenthesises' do
        expect { f.parse('set A {bc') }.to raise_error P
      end
      it 'should raise error on extra-characters after close-quote' do
        expect { f.parse('set a "bc"d') }.to raise_error P
      end
      it 'should raise error on extra-characters after close-brace' do
        expect { f.parse('set a {bc}d') }.to raise_error P
        expect { f.parse('set a {bc}{b}') }.to raise_error P
      end
      it 'should not raise error on unmatched parenthesises' do
        expect { f.parse('set A b{c') }.not_to raise_error
      end
    end
  end
end
