require 'rspec'
require_relative '../lib/tcl_ruby.rb'

RSpec.describe 'TclField' do
  describe 'replace' do
    let(:f) { TclField.new }
    before(:each) do
      f.parse('set A 1')
    end
    it 'should read and write variable' do
      expect(f.variables('A')).to eq '1'
      expect(f.parse('set A')).to eq '1'
    end

    it 'is not able to get unwritten variable' do
      expect { f.variables('B') }.to raise_error TclField::TclError
    end

    it 'should replace variables' do
      f.parse('set B {1 2 3}')
      expect(f.parse('llength $B')).to eq 3
    end

    it 'should replace variables only once' do
      f.parse('set B {$A}')
      expect(f.parse('set C $B')).to eq '{$A}'
      expect(f.parse('set C ${B}')).to eq '{$A}'
      expect(f.variables('C')).to eq '$A'
    end

    it 'should replace command' do
      expect(f.parse('llength [list A B C]')).to eq 3
      expect(f.parse('set C [llength [list A B C D {E}]]')).to eq '5'
      expect(f.variables('C')).to eq '5'
    end

    it 'should not replace variables and commands under "{"' do
      expect(f.parse('set B {$A}')).to eq '{$A}'
      expect(f.parse('llength {[list A B C]}')).to eq 4
    end

    it 'should replace variables and commands under "' do
      expect(f.parse('set B "$A"')).to eq '"1"'
      expect(f.parse('llength "[list A B C]"')).to eq 3
    end
  end
end
