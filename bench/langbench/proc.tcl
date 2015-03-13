tsp::proc j {v1 v2 v3 v4 v5} { 
  #tsp::procdef int -args int int int int int
  return [expr {$v1 + $v2 + $v3 + $v4 + $v5}] 
}
tsp::proc i {v1 v2 v3 v4} { 
  #tsp::procdef int -args int int int int
  return [j $v1 $v2 $v3 $v4 5] 
}
tsp::proc h {v1 v2 v3} { 
  #tsp::procdef int -args int int int
  return [i $v1 $v2 $v3 4] 
}
tsp::proc g {v1 v2} { 
  #tsp::procdef int -args int int
  return [h $v1 $v2 3] 
}
tsp::proc f {val} { 
  #tsp::procdef int -args int
  return [g $val 2] 
}
tsp::proc e {val} { 
  #tsp::procdef int -args int
  return [f $val] 
}
tsp::proc d {val} { 
  #tsp::procdef int -args int
  return [e $val] 
}
tsp::proc c {val} { 
  #tsp::procdef int -args int
  return [d $val] 
}
tsp::proc b {val} { 
  #tsp::procdef int -args int
  return [c $val] 
}
tsp::proc a {val} {
  #tsp::procdef int -args int
   return [b $val] 
}
tsp::proc main {} {
	#tsp::procdef void
	#tsp::int n x
	set n 100000
	while {$n > 0} { set x [a $n]; incr n -1 }
	puts $x
}

proc run_proc {} {
    main
}
