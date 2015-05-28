

# tsp namespace and tsp::proc for native testing, define
# tsp::procs as a normal Tcl procs for Tcl interpreter timing.
# after the tsp compiler is sourced, the procs will be sourced
# again to be compiled into java or c.

namespace eval tsp {
    ::proc proc {name args body} {namespace eval :: [list proc $name $args $body]}
}


catch {set interp $env(TSP_INTERP)}
if {$interp eq "jtsp"} {
    source ../../tsp.tcl
} elseif {$interp eq "ctsp"} {
    source ../../tsp.tcl
} else {
    # run with plain interp
}


#set warmup_iters 10
#set timing_iters 3
set warmup_iters 1
set timing_iters 1

set pgm [lindex $argv 0]
set timing_argv [lrange $argv 1 end]
set warmup_argv README.tsp
set argv $warmup_argv

source $pgm.tcl
catch {init_$pgm}

# warmup
time run_$pgm $warmup_iters


# time it
set argv $timing_argv
catch {init_$pgm}
set avg_micros [time run_$pgm $timing_iters]
puts -nonewline stderr [format %-8.2f [expr [lindex $avg_micros 0] / 1000000.0]]


exit 0

