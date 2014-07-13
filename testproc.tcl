source tsp.tcl
set body {
    #::tsp::procdef returns: int args: int string
    #::tsp::vardef var sum 
    set sum $i
    incr i 8
    #while {$i < 10} {
     #puts "$s $sum"
     #puts hi
    #}
    #for {set i 0} {$i < 10} {incr i} {
     #puts hi
    #}
} ; format ""
set compUnit [::tsp::init_compunit FILE NAME {i s} $body] ; format ""
set code [::tsp::parse_body compUnit {0 end}] ; format ""
::tsp::lang_create_compilable compUnit $code




