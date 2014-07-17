source tsp.tcl
set body {
    #::tsp::procdef returns: int args: int string
    #::tsp::vardef var sum 
    set i 10000
    set j $i
    return $i
    #puts hi
} ; format ""
set compUnit [::tsp::init_compunit FILE NAME {i s} $body] ; format ""
set code [::tsp::parse_body compUnit {0 end}] ; format ""
::tsp::lang_create_compilable compUnit $code



::tsp::proc foo {i s} {
    #::tsp::procdef returns: int args: int string
    set i 10000
    set j $i
    return $i
}


source tsp.tcl
proc callit {} {puts calledit}
::tsp::proc foo {} {
  #::tsp::procdef returns: void args:
  callit
}

