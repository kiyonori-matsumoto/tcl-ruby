require "test/unit"
require "./tcl.rb"

class TestTclList < Test::Unit::TestCase
  def setup
  end

  def test_01
    @t = Tcl::List.new("set B [set A 1]")
    p @t.parse
    assert_equal(@t.val["A"].to_s, "1")
    assert_equal(@t.val["B"].to_s, "1")
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
    assert_equal(@t.val["D"].to_s, "How Big a {Cub!} ")
    assert_equal(@t.val["D"][3].to_s, "Cub!")
    @t = Tcl::List.new("set E \"this is a pen!\"\nset F \"[expr 3 * 2]\"")
    p @t.parse
    assert_equal(@t.val["F"].to_s, "6")
    @t.setCommand("set C test").parse
    assert_equal(@t.val["C"].to_s, "test")
    assert_equal(@t.val["F"].to_s, "6")
    p @t.setCommand("set G [list Index  Panda  Tomato]").parse
    assert_equal(@t.val["G"][0].to_s, "Index")
    p @t.setCommand("set G [list Index Panda [list Tomato Lemon] Apple]").parse
    p @t.setCommand("string first a 123456789abcdef").parse
    p @t.setCommand("llength [list 1 2 3 4 5]").parse
    p @t.setCommand("lappend G Chili").parse

  end
end
