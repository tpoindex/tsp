

# tsp namespace and tsp::proc for native testing, define
# tsp::procs as a normal Tcl procs for Tcl interpreter timing.
# after the tsp compiler is sourced, the procs will be sourced
# again to be compiled into java or c.

namespace eval tsp {
    ::proc proc {name args body} {namespace eval :: [list proc $name $args $body]}
}


# small data - 32 bytes (also used for warmup)
set smalldata ABCDEFGHIJKLMNOPQRSTUVWXYZ012345

# medium data - roughly 4k
set meddata [string repeat [string repeat  ABCDEFGHIJKLMNOPQRSTUVWXYZ 2] 80]

# big data - roughly 64k
set bigdata [string repeat [string repeat  ABCDEFGHIJKLMNOPQRSTUVWXYZ 100] 25]

# huge data - roughly 256k
set hugedata [string repeat [string repeat  ABCDEFGHIJKLMNOPQRSTUVWXYZ 100] 100]


if {$::tcl_platform(platform) eq "java"} {
    set warmup 10000
    set tclver "jtcl [package require JTcl]"
} else {
    set warmup 1
    set tclver "tcl [info patchlevel]"
}

# run the interpreter timings first
source tsp_md5.tcl

proc time_md5 {tclver} {
    global warmup smalldata meddata bigdata hugedata

    # warmup
    # for c/tcl - warmup compiles proc into byte code
    # for jtcl  - warmup allows java bytecode to be compiled
    puts stderr "$tclver warming up, $warmup iterations..."
    for {set i 0} {$i < $warmup} {incr i} {
        tsp_md5 $smalldata
    }
    set iters 10 
    puts -nonewline stderr "timing (averaging $iters iterations) ....."
    
    puts -nonewline stderr " small"
    set small_time [lindex [time {tsp_md5 $smalldata} $iters] 0]
    
    puts -nonewline stderr " medium"
    set med_time   [lindex [time {tsp_md5 $meddata} $iters]   0]
    
    puts -nonewline stderr " big"
    set big_time   [lindex [time {tsp_md5 $bigdata} $iters]    0]
    
    puts -nonewline stderr " huge"
    set huge_time  [lindex [time {tsp_md5 $hugedata} $iters]   0]
    
    puts stderr ""
    puts stderr "[format %-74.74s $tclver--------------------------------------------------------------------]"
    puts stderr " msg size:  ---32 bytes---  ---4k bytes---  --64k bytes---  --256k bytes--"
    puts -nonewline stderr " avg secs: "
    puts -nonewline stderr " [format %14.7f [expr {$small_time / 1000000.0}]] " 
    puts -nonewline stderr " [format %14.7f [expr {$med_time   / 1000000.0}]] "
    puts -nonewline stderr " [format %14.7f [expr {$big_time   / 1000000.0}]] "
    puts -nonewline stderr " [format %14.7f [expr {$huge_time  / 1000000.0}]] "
    puts stderr ""
    puts stderr "[format %-74.74s ----------------------------------------------------------------------------------------]"
}

puts stderr "md5 timings for $tclver"
time_md5 $tclver

# now source tsp.tcl and re-source tsp_md5.tcl to compile it
puts stderr "compiling with tsp..."
source ../../tsp.tcl
source tsp_md5.tcl

puts stderr "md5 timings for $tclver+tsp"
time_md5 $tclver+tsp

