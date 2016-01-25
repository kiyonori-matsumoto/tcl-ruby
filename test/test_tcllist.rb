require "test/unit"
require "./tcl.rb"

class TestTclList < Test::Unit::TestCase
  def setup
    @tcllist = Tcl::TclList.new
  end

  def test_01
    @tcllist << "set A B"
    r = @tcllist.split_into_words
    assert_equal("A", r[1])
    assert_equal("B", r[2])
    @tcllist = Tcl::TclList.new "set C $D"
    r = @tcllist.replace(@tcllist.split_into_words)
    @tcllist = Tcl::TclList.new "set E [expr 1 + 2]"
    r = @tcllist.replace(@tcllist.split_into_words)
    p r

  end
end
