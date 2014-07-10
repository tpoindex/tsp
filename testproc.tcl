source tsp.tcl
set body {
#::tsp::procdef returns: int args: int string
#::tsp::vardef int sum 
set sum [expr {$i +1}]
puts "$s $sum"
}
set compUnit [::tsp::init_compunit FILE NAME {i s} $body]
set code [::tsp::parse_body compUnit {0 end}]

::tsp::lang_create_compilable compUnit $code




