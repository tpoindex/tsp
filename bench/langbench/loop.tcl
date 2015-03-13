tsp::proc doit {n} {
	#tsp::procdef void -args int
	while {$n > 0} { incr n -1 }
}

proc run_loop {} {
    doit 1000000
}
