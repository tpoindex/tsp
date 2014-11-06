# basic compilation tests

package require tsp
puts "debug dir: [tsp::debug]" 
#hyde::configure -compiler javac

source test-compare.tcl 

###################################################################
# return types

I_VS_C basic_0001 {} {
    #tsp::procdef int
    return 1
} {}

I_VS_C basic_0002 {} {
    #tsp::procdef boolean
    return 1
} {}

I_VS_C basic_0003 {} {
    #tsp::procdef double
    return 1.23
} {}

I_VS_C basic_0004 {} {
    #tsp::procdef string
    return hello
} {}

I_VS_C basic_0005 {} {
    #tsp::procdef var
    return world
} {}


###################################################################
# arguments

I_VS_C basic_0011 {x} {
    #tsp::procdef int -args int
    return $x
} {22}

I_VS_C basic_0012 {x} {
    #tsp::procdef boolean -args boolean
    return $x
} {0}

I_VS_C basic_0013 {x} {
    #tsp::procdef double -args double
    return $x
} {3.3}

I_VS_C basic_0014 {x} {
    #tsp::procdef string -args string
    return $x
} {dog}

I_VS_C basic_0015 {x} {
    #tsp::procdef var -args var
    return $x
} {cat}



