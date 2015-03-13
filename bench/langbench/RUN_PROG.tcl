#!/usr/bin/tclsh

lappend auto_path ../..
catch {source ../../tcl.tsp}
if { [ catch {package require tsp} ] } {
    # fake namespace tsp::proc for testing
    namespace eval tsp {::proc proc {name args body} {namespace eval :: [list proc $name $args $body]}}
}


set warmup_iters 10
set timing_iters 3

set pgm [lindex $argv 0]
set argv [lrange $argv 1 end]

source $pgm.tcl

# warmup
time run_$pgm $warmup_iters


# time it
set avg_micros [time run_$pgm $timing_iters]
puts -nonewline stderr [format %-8.2f [expr [lindex $avg_micros 0] / 1000000.0]]


