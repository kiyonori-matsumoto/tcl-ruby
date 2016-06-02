require 'spec_helper.rb'

RSpec.describe Tcl::Ruby::Interpreter do
  describe '#add_hook' do
    def test_aaaa(arg)
      puts arg[0]
    end
    let(:f) { Tcl::Ruby::Interpreter.new }
    let(:hook) { 'test_1234' }
    before(:each) do
      f.add_hook(hook) { |arg| puts arg[0] }
    end
    it 'hooks my function with blocks, then delete hook' do
      hook = 'test_1234'
      f.add_hook(hook) { |arg| puts arg[0] }
      expect { f.parse("#{hook} aaaa") }.to output("aaaa\n").to_stdout
      f.delete_hook(hook)
      expect { f.parse("#{hook} aaaa") }.to raise_error Tcl::Ruby::CommandError
    end

    it 'hooks my function with method' do
      f.add_hook('test_aaaa', &method(:test_aaaa))
      expect { f.parse('test_aaaa 1234') }.to output("1234\n").to_stdout
    end

    it 'hooks my function with lambda, overwrite' do
      f.add_hook('test_1234', &-> (arg) { puts arg[1] })
      expect { f.parse('test_1234 aaaa bbbb') }.to output("bbbb\n").to_stdout
    end

    it 'hooks my function with symbol name' do
      f.add_hook(:abcd) { |arg| puts arg[0] }
      expect { f.parse('abcd aaaa') }.to output("aaaa\n").to_stdout
    end
  end
end
