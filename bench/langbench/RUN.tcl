# this must run with tclsh8.6, since we use 'exec' options
# not in jtcl



set progs {cat grep hash loop proc fib sort wc}

# make sure some data file is specified
set data [lindex $argv 0]
if {[string length $data] == 0} {
    puts "a DATA file must be specified on the command line, see README.tsp"
    exit
}

puts stderr "lang	cat	grep	hash	loop	proc	fib	sort	wc"


# determine which interp to use with tsp: "jtsp"  or "ctsp" 
set interp ""
catch { set interp $env(TSP_INTERP) ; set orig_interp $interp }
if {$interp eq "jtsp"} {
    puts -nonewline stderr [format %-8s jtcl]
    set runtime ../../jtcltsp.sh
} elseif {$interp eq "ctsp"} {
    puts -nonewline stderr [format %-8s ctcl]
    set runtime tclsh8.6
} else {
    puts stderr "env var TSP_INTERP must be: jtsp or ctsp"
    exit 1
}
 

# run first with plain interp
# set the env interp so that RUN_PROG runs with pure interp version
# if RUN_PROG doesn't see jtsp or ctsp, it doesn't source the tsp compiler
set env(TSP_INTERP) interp-only

# now run the benchmark
foreach prog $progs {
    exec -ignorestderr $runtime RUN_PROG.tcl $prog $data >/dev/null </dev/null 
}

puts stderr ""


# now run with tsp compiled procs

set env(TSP_INTERP) $orig_interp

# print out the name of interp we are using
set interp $env(TSP_INTERP)
if {$interp eq "jtsp"} {
    puts -nonewline stderr [format %-8s j+tsp]
    set interp ../../jtcltsp.sh
} elseif {$interp eq "ctsp"} {
    puts -nonewline stderr [format %-8s c+tsp]
    set interp tclsh8.6
} else {
    puts stderr "env var TSP_INTERP must be: jtsp or ctsp"
    exit 1
}

foreach prog $progs {
    exec -ignorestderr $runtime RUN_PROG.tcl $prog $data >/dev/null </dev/null 
}

puts stderr ""
