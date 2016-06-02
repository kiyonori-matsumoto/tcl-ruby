require 'spec_helper'
require 'strscan'

RSpec.describe StringScanner do
  describe '#check' do
    let(:scan) { StringScanner.new('Test String') }
    it 'should not change pointer value' do
      expect { scan.check(/Test/) }.not_to change(scan, :pos)
      expect { scan.scan(/Test/) }.to change(scan, :pos).by 4
    end
  end
end
