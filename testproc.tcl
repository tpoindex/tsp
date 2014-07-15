source tsp.tcl
set body {
    #::tsp::procdef returns: int args: int string
    #::tsp::vardef var sum 
    #if {$i > 0} then {
        #set i 0
    #} elseif {$i < 300} {
        #set i 300
    #} 
    #set i 10000

    #set sum $i
    #incr sum $sum
    while {$i < 10} {
     puts hi
     continue
    }
    #for {set i 0} {$i < 10} {incr i} {
     #puts hi
    #}

} ; format ""
set compUnit [::tsp::init_compunit FILE NAME {i s} $body] ; format ""
set code [::tsp::parse_body compUnit {0 end}] ; format ""
::tsp::lang_create_compilable compUnit $code




