require 'rspec'
require_relative '../lib/tcl_ruby.rb'

RSpec.describe TclField do
  describe '#add_hook' do
    let(:f) { TclField.new }
    def test_aaaa(arg)
      puts arg[0]
    end
    it 'hooks my function' do
      f.add_hook('test_1234', -> (arg) { puts arg[0] })
      expect { f.parse('test_1234 aaaa') }.to output("aaaa\n").to_stdout
    end
    it 'hooks my method' do
      f.add_hook('test_aaaa', method(:test_aaaa))
      expect { f.parse('test_aaaa 1234') }.to output("1234\n").to_stdout
    end
  end
end
