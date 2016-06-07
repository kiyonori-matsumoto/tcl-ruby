require 'spec_helper'

describe Tcl::Ruby::OptionParser do
  let(:op) { Tcl::Ruby::OptionParser }
  let(:opts) { ['length?', 'nocase'] }
  describe 'parse' do
    it 'does nothing' do
      arg = ['{1234}', '5']
      expect { op.parse(opts, arg) }.not_to change { arg.count }
    end
    it 'should parse length options' do
      arg = ['-length', '15', '1234']
      ret = nil
      expect { ret = op.parse(opts, arg) }.to change { arg.count }.by(-2)
      expect(ret).to have_key('length')
      expect(ret['length']).to eq '15'
    end
    it 'should parse nocase options' do
      arg = ['-nocase', '15', '1234']
      ret = nil
      expect { ret = op.parse(opts, arg) }.to change { arg.count }.by(-1)
      expect(ret).to have_key('nocase')
      expect(ret['nocase']).to be true
    end
    it 'should parse multiple options' do
      arg = ['-nocase', '-length', '15', '1234']
      ret = nil
      expect { ret = op.parse(opts, arg) }.to change { arg.count }.by(-3)
      expect(ret['length']).to eq '15'
      expect(ret['nocase']).to be true
    end
  end
end
