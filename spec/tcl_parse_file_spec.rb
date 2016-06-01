require 'rspec'
require_relative '../lib/tcl_ruby.rb'

RSpec.describe TclField do
  describe 'parse long string' do
    let(:f) { TclField.new }
    it 'should parse all commands inside file' do
      open('./spec/test.tcl') do |file|
        f.parse(file.read)
      end
      expect(f.variables('A')).to eq '3'
      expect(f.variables('B')).to eq '5'
      expect(f.variables('C')).to eq '15'
      expect(f.variables('x')).to eq '362880'
    end
  end
end
