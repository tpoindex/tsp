tsp::proc fib {n} {
	#tsp::procdef int -args int
	#tsp::int fib_2 fib_1
	if {$n < 2} {return 1}
        set fib_2 [fib [expr {$n -2}]]
        set fib_1 [fib [expr {$n -1}]]
	set result [expr {$fib_2 + $fib_1}]
	return $result
}

proc run_fib {} {
    set i 0
    while {$i <= 30} {
	    puts "n=$i => [fib $i]"
	    incr i
    }
}
