require 'spec_helper.rb'

RSpec.describe Tcl::Ruby::Interpreter do
  let(:f) { Tcl::Ruby::Interpreter.new }
  let(:path_wr) { 'spec/___test_file.txt' }
  let(:wfile) { ::StringIO.new('', 'w') }
  let(:path_rd) { 'spec/test.tcl' }
  let(:rfile) { ::StringIO.new("asdf\nwend", 'r') }
  describe '#parse inouts' do
    describe 'file open and close' do
      it 'can open and close file' do
        expect { f.parse('set fp [open "spec/test.tcl" "r"]; close $fp') }
          .not_to raise_error
      end
      it 'write some string to file' do
        expect(f).to receive(:open).with(path_wr, 'w', 0744).and_return(wfile)
        f.parse("set fp [open {#{path_wr}} {w}]; puts $fp AAAA; close $fp")
        expect(wfile.string).to eq "AAAA\n"
      end
      it 'read string from file' do
        f.parse("set fp [open {#{path_rd}} {r}]; set A [gets $fp]; close $fp")
        expect(f.variables('A')).to eq `head -n 1 #{path_rd}`
        f.parse("set fp [open {#{path_rd}} {r}]; gets $fp B; close $fp")
        expect(f.variables('B')).to eq `head -n 1 #{path_rd}`
      end
    end
    describe 'eof' do
      it 'should return 0 when fp is not eof, then return 1 if fp is eof' do
        expect(f).to receive(:open).with(path_rd, 'r', 0744).and_return(rfile)
        f.parse <<-EOS
        set fp [open #{path_rd} {r}]
        set A [eof $fp]
        gets $fp
        set B [eof $fp]
        gets $fp
        set C [eof $fp]
        close $fp
        EOS
        expect(f.variables('A')).to eq '0'
        expect(f.variables('B')).to eq '0'
        expect(f.variables('C')).to eq '1'
      end
    end
  end
end
