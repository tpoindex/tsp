# invoke with jtcltsp.sh or tclsh8.6

set progs {cat grep hash hash2 loop proc fib sort wc}

set data [lindex $argv 0]
if {[string length $data] == 0} {
    set data /dev/null
}

if {[info command jaclloadjava] ne ""} {
    puts stderr [format %-8s jtsp*]
    set interp ../../jtcltsp.sh
} else {
    puts stderr [format %-8s ctsp*]
    set interp tclsh8.6
}

foreach prog $progs {
    #exec $interp RUN_PROG.tcl $prog $data
    exec $interp RUN_PROG.tcl $prog $data >/dev/null
}

puts stderr ""
