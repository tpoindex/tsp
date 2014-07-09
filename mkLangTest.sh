#!
grep '^proc' tsp-java.tcl |awk '{print $1 " " $2 " {args} {return [list " $2 " $args]}" }' >tsp-lang.test
