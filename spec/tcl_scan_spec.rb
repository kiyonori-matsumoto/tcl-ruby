require 'rspec'
require_relative '../tcl_scan.rb'

RSpec.describe 'Tclp' do
  describe 'parse' do
    let(:tclp) { Tclp.new }
    it 'is able to parse normal' do
      str = 'set A B'
      expect(tclp.parse(str)).to eq ['set', ['A', 'B']]
    end

    it 'is able to parse parenthesis' do
      str = 'set A {B C D}'
      expect(tclp.parse(str)).to eq ['set', ['A', '{B C D}']]
    end

    it 'is able to parse dquote' do
      str = 'set A "B C D"'
      expect(tclp.parse(str)).to eq ['set', ['A', '"B C D"']]
    end

    it 'is able to parse multiline' do
      str = 'set A \
      B'
      expect(tclp.parse(str)).to eq ['set', ['A', 'B']]
    end

    it 'is able to parse if statement' do
      str = 'if {A < B} {set A B}'
      expect(tclp.parse(str)).to eq ['if', ['{A < B}', '{set A B}']]
    end

    it 'is able to multi-brackets' do
      str = 'set A {B C {D E}}'
      expect(tclp.parse(str)).to eq ['set', ['A', '{B C {D E}}']]
    end

    it 'is not able to parse unbarance parenthesises' do
      str = 'set A {B C {D E}'
      expect { tclp.parse(str) }.to raise_error ParseError
    end
  end
end
