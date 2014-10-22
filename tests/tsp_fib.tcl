
package require tsp
hyde::configure -compiler javac

tsp::proc tsp_fib {n} {
    #tsp::procdef int -args int
    if {$n < 2} {
        return $n
    }
    #tsp::int n1 n2
    incr n -1
    set n1 [tsp_fib $n]
    incr n -1
    set n2 [tsp_fib $n]
    set n [expr {$n1 + $n2}]
    return $n
}

for {set i 0} {$i < 10} {incr i} {
    puts "fib $i - [tsp_fib $i]"
}
