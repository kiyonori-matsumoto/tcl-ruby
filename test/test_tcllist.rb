require "test/unit"
require "./tcl.rb"

class TestTclList < Test::Unit::TestCase
  def setup
  end

  def test_01
    @t = Tcl::List.new("set B [set A 1]")
    p @t.parse
    assert_equal(@t.val["A"].to_s, "1")
    @t = Tcl::List.new("set C [expr 4 + [expr 5 * 2]]")
    p @t.parse
    p @t.val["C"]
    assert_equal(@t.val["C"].to_s, "14")
    @t = Tcl::List.new("set D {How Big a Cub!}")
    p @t.parse
    p @t.val["D"][2]
    assert_equal(@t.val["D"][2].to_s, "a")
    @t = Tcl::List.new("set D {How Big a {Cub!} }")
    p @t.parse
    p @t.val["D"][3]
    @t = Tcl::List.new("set E \"this is a pen!\"\nset F \"[expr 3 * 2]\"")
    p @t.parse
    p @t.val["F"]


  end
end
