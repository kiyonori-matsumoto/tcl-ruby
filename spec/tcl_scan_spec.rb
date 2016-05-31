require 'rspec'
require_relative '../tcl_scan.rb'

RSpec.describe 'Tclp' do
  describe '#parse' do
    describe 'initialized with "command_exec = false"' do
      let(:tclp) { Tclp.new }
      it 'is able to parse normal' do
        str = 'set A B'
        expect(tclp.parse(str)).to eq %w(set A B)
      end

      it 'is able to parse parenthesis' do
        str = 'set A {B C D}'
        expect(tclp.parse(str)).to eq ['set', 'A', 'B C D']
      end

      it 'is able to parse dquote' do
        str = 'set A "B C D"'
        expect(tclp.parse(str)).to eq ['set', 'A', 'B C D']
      end

      it 'is able to parse dquart with backslash' do
        str = 'set A "B C \"D"'
        expect(tclp.parse(str)).to eq ['set', 'A', 'B C \"D']
      end

      it 'is able to parse multiline' do
        str = 'set A \
        B'
        expect(tclp.parse(str)).to eq %w(set A B)
      end

      it 'is able to parse if statement' do
        str = 'if {A < B} {set A B}'
        expect(tclp.parse(str)).to eq ['if', 'A < B', 'set A B']
      end

      it 'is able to multi-brackets' do
        str = 'set A {B C {D E}}'
        expect(tclp.parse(str)).to eq ['set', 'A', 'B C {D E}']
      end

      it 'is not able to parse unbarance parenthesises' do
        str = 'set A {B C {D E}'
        expect { tclp.parse(str) }.to raise_error ParseError
      end
    end

    describe 'initialized with "command_exec = true"' do
      let(:tclp) { Tclp.new(true) }
      it 'creates list' do
        str = 'list A B C'
        expect(tclp.parse(str)).to eq 'A B C'
      end

      it 'returns length of list' do
        str = 'llength {A B C}'
        expect(tclp.parse(str)).to eq 3
      end

      it 'returns lenght of list when semi-colon is included' do
        str = 'llength {B C ; DESF}'
        expect(tclp.parse(str)).to eq 4
      end

      it 'returns length of list when multiple parenthesis are' do
        str = 'llength {B C {D E}}'
        expect(tclp.parse(str)).to eq 3
      end
    end
  end
end
