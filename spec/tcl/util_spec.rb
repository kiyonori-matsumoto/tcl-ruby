require 'spec_helper.rb'

RSpec.describe Tcl::Ruby::Interpreter do
  let(:f) { Tcl::Ruby::Interpreter.new }
  describe '#commands' do
    it 'returns commands' do
      expect(f.commands).to include('set').and include('proc')
    end
    it 'change commands count when proc is added' do
      expect { f.parse('proc aaa bb {}') }.to change { f.commands }.by(['aaa'])
    end
    it 'change commands count when hooks is added' do
      expect { f.add_hook('hk') { |e| puts e } }
        .to change { f.commands }.by(['hk'])
    end
  end
end
