set A 3; #initialize with 3
set B 5; #initialize with 5
set C [expr $A * $B]
# comment out here
if {$A == 3} {
  set D $C
}
for {set i 1; set x 1} {$i < 10} {incr i} {
  set x [expr $x * $i]
}
set x
