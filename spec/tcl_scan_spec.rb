require 'rspec'
require_relative '../lib/tcl_ruby.rb'

RSpec.describe 'TclField' do
  describe '#parse' do
    describe 'initialized with "to_list = true"' do
      let(:tclp) { TclField.new }
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
        expect { tclp.parse(str, true) }.to raise_error TclField::ParseError
      end
    end
  end
end
