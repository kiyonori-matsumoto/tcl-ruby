require 'spec_helper.rb'

RSpec.describe Tcl::Ruby::Interpreter do
  describe 'parse long string' do
    let(:f) { Tcl::Ruby::Interpreter.new }
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
