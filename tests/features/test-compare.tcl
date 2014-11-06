# test interpreted vs compiled results

proc I_VS_C {name args body cmdargs} {
    proc I_$name $args $body
    ::tsp::proc C_$name $args $body
    if {[info proc C_$name] eq "C_$name"} {
        ::tsp::printLog stdout C_$name
    } else {
        set I_result [eval I_$name $cmdargs]
        set C_result [eval C_$name $cmdargs]
        if {$I_result ne $C_result} {
            puts stdout "$name : results differ: interp: $I_result  compiled: $C_result"
        }
    }
}

