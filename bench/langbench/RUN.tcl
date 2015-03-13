#!/usr/local/bin/tclsh8.6

set progs {cat grep hash loop proc fib sort wc}

# make sure some data file is specified
set data [lindex $argv 0]
if {[string length $data] == 0} {
    set data /dev/null
}

puts stderr "lang	cat	grep	hash	loop	proc	fib	sort	wc"

# determine which interp to use with tsp: "jtsp"  or "ctsp" 
set interp ""
catch {set interp $env(TSP_INTERP)}
if {$interp eq "jtsp"} {
    puts -nonewline stderr [format %-8s jtsp*]
    set interp ../../jtcltsp.sh
} elseif {$interp eq "ctsp"} {
    puts -nonewline stderr [format %-8s ctsp*]
    set interp tclsh8.6
} else {
    puts stderr "env var TSP_INTERP must be: jtsp or ctsp"
    exit 1
}


foreach prog $progs {
    exec -ignorestderr $interp RUN_PROG.tcl $prog $data >/dev/null </dev/null 
}

puts stderr ""
