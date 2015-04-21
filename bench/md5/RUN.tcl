

# fake namespace tsp::proc for native testing
namespace eval tsp {::proc proc {name args body} {namespace eval :: [list proc $name $args $body]}}


# small string - used for warmup
set smallstring ABCDEFGHIJKLMNOPQRSTUVWXYZ012345

# medium string roughly 4k
set medstring [string repeat [string repeat  ABCDEFGHIJKLMNOPQRSTUVWXYZ 2] 80]

# big string roughly 64k
set bigstring [string repeat [string repeat  ABCDEFGHIJKLMNOPQRSTUVWXYZ 100] 25]


if {$::tcl_platform(platform) eq "java"} {
    set is_jtcl 1
    set warmup 10000
    set tclver "jtcl [package require JTcl]"
} else {
    set is_jtcl 0
    set warmup 1
    set tclver "tcl  [info patchlevel]"
}

source tsp_md5.tcl

proc time_md5 {tclver} {
    global warmup smallstring medstring bigstring

    # warmup
    # for c/tcl - warmup compiles proc into byte code
    # for jtcl  - warmup allows java bytecode to be compiled
    puts stderr "$tclver warming up, $warmup iterations..."
    for {set i 0} {$i < $warmup} {incr i} {
        tsp_md5 $smallstring
    }
    
    puts -nonewline stderr timing...
    
    puts -nonewline stderr " small"
    set small_time [lindex [time {tsp_md5 $smallstring} 10] 0]
    
    puts -nonewline stderr " medium"
    set med_time   [lindex [time {tsp_md5 $medstring} 2]    0]
    
    puts -nonewline stderr " big"
    set big_time   [lindex [time {tsp_md5 $bigstring} 1]    0]
    
    puts stderr ""
    puts stderr "[format %18s $tclver] results (seconds): ---32 bytes---  ---4k bytes---  --64k bytes---"
    puts -nonewline stderr "[format %18s ""     ]                   "
    puts -nonewline stderr " [format %14.7f [expr {$small_time / 1000000.0}]] " 
    puts -nonewline stderr " [format %14.7f [expr {$med_time   / 1000000.0}]] "
    puts -nonewline stderr " [format %14.7f [expr {$big_time   / 1000000.0}]] "
    puts stderr ""
}

puts stderr "md5 timings for $tclver"
time_md5 $tclver

# if running jtcl, time for tjc
if {$is_jtcl} {
    package require TJC
    TJC::compile tsp_md5 -readyvar tjc_done
    vwait tjc_done
    puts stderr "md5 timings for $tclver/tjc"
    time_md5 $tclver/tjc
}

# now source tsp.tcl and re-source tsp_md5.tcl to compile it
puts stderr "compiling with tsp..."
source ../../tsp.tcl
source tsp_md5.tcl

puts stderr "md5 timings for $tclver/tsp"
time_md5 $tclver/tsp

