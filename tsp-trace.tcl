#########################################################
# commands to support trace debugging, when compileType is "trace"
#


#########################################################
# return tracing commands and define a global leave trace on the proc
#
proc ::tsp::init_traces {compUnitDict name returnType} {
    upvar $compUnitDict compUnit

    # append checking for args
    set i 0
    set types [dict get $compUnit argTypes]
    foreach var [dict get $compUnit args] {
        set type [lindex $types $i]
        append traces "::tsp::trace_arg $name $var $type \[::set $var\]" \n
        incr i
    }

    # trace the "return" command inside the proc
    append traces "trace add execution return leave \"::tsp::trace_return $name $returnType\"" \n

    foreach {var type} [dict get $compUnit vars] {
        if {[::tsp::is_tmpvar $var]} {
            continue
        }
        append traces "trace add variable $var write \"::tsp::trace_var $name $var $type\"" \n
    }

    # add a global trace to evaluate the return type cancel the "return" tracing (until the next traced proc)
    # this has to be eval'ed in the calling proc, after the proc is defined
    set procTrace "trace add execution $name leave \"::tsp::trace_return_check $name $returnType\""

    return [list $traces $procTrace]
}


#########################################################
#
# get an abbreviated stack trace, borrows from http://wiki.tcl.tk/16183
#
proc ::tsp::stacktrace {} {
    set stack "Stack trace:\n"
    set indent 1
    for {set i 1} {$i < [info level]} {incr i} {
        set lvl [info level -$i]
        set pname [lindex $lvl 0]
        if {[string first ::tsp:: $pname 0] == 0} {
            continue
        }
        append stack [string repeat " " $indent]$pname
        incr indent
        foreach value [lrange $lvl 1 end] arg [info args $pname] {
            if {$value eq ""} {
                info default $pname $arg value
            }
            append stack " $arg='[string range $value 0 20][expr {[string length $value] > 20 ? " ..." : ""}]'"
        }
        append stack \n
    }
    return $stack
}


#########################################################
#
# trace_arg - not really called from trace, just check args
#
proc ::tsp::trace_arg {procName argName argType value} {
    set typeList [::tsp::literalTypes $value]
    
    switch -- $argType {
        int     {if {[::tsp::typeIsInt     $typeList]} {return}}
        double  {if {[::tsp::typeIsDouble  $typeList] || [::tsp::typeIsInt     $typeList]} {return}}
        boolean {if {[::tsp::typeIsBoolean $typeList]} {return}}
        string  {return}
        var     {return}
    }
    set value "[string range $value 0 20][expr {[string length $value] > 20 ? " ..." : ""}]"
    append msg "-------------------------------------------------------------------------------------" \n
    append msg "PROC ARG: proc: $procName\targ: $argName\tdefined: $argType\tvalue: $value\ttypes: $typeList" \n
    append msg [::tsp::stacktrace] \n
    puts $::tsp::TRACE_FD $msg
    flush $::tsp::TRACE_FD
}

#########################################################
#
# trace_var - check that var was set correctly for type
#
proc ::tsp::trace_var {procName varName varType name1 name2 op} {
    if {! [dict exists $::tsp::COMPILER_LOG $procName]} {
        return
    }
    if {$name2 ne ""} {
        # it's an array, so anything goes
        return
    }
    set value [uplevel "::set $varName"]
    set typeList [::tsp::literalTypes $value]
    
    switch -- $varType {
        int     {if {[::tsp::typeIsInt     $typeList]} {return}}
        double  {if {[::tsp::typeIsDouble  $typeList] || [::tsp::typeIsInt     $typeList]} {return}}
        boolean {if {[::tsp::typeIsBoolean $typeList]} {return}}
        string  {return}
        var     {return}
    }
    set value "[string range $value 0 20][expr {[string length $value] > 20 ? " ..." : ""}]"
    append msg "-------------------------------------------------------------------------------------" \n
    append msg "VAR ASSIGN: proc: $procName\tvar: $varName\tdefined: $varType\tvalue: $value\ttypes: $typeList" \n
    append msg [::tsp::stacktrace] \n
    puts $::tsp::TRACE_FD $msg
    flush $::tsp::TRACE_FD
}


#########################################################
#
# trace_return - record the most current return type
#
proc ::tsp::trace_return {procName returnType command code result op} {
    if {! [dict exists $::tsp::COMPILER_LOG $procName]} {
        puts $::tsp::TRACE_FD "NOT COMPILED PROC: ::tsp::trace_return $procName $returnType $command $code $result $op"
        return
    }
    set ::tsp::TRACE_PROC [list $procName $returnType $result]
}


#########################################################
#
# trace_return_check - check the most current return type 
# and cancel return tracing
#
proc ::tsp::trace_return_check {procName procReturnType command code result op} {

    set returnName [lindex $::tsp::TRACE_PROC 0]
    set returnType [lindex $::tsp::TRACE_PROC 1]
    set value      [lindex $::tsp::TRACE_PROC 2]

    set ::tsp::TRACE_PROC ""

    # remove the trace 
    trace remove execution return leave "::tsp::trace_return $procName $procReturnType"

    if {$procReturnType eq "void" && $value eq ""} {
        return
    }

    if {$returnName eq ""} {
        set value "[string range $value 0 20][expr {[string length $value] > 20 ? " ..." : ""}]"
        append msg "-------------------------------------------------------------------------------------" \n
        append msg "PROC RETURN: proc: $procName\texiting without return command, expected return type: $procReturnType" \n
        append msg [::tsp::stacktrace] \n
        puts $::tsp::TRACE_FD  $msg
        flush $::tsp::TRACE_FD
    }

    set typeList [::tsp::literalTypes $value]
        switch -- $returnType {
        int     {if {[::tsp::typeIsInt     $typeList]} {return}}
        double  {if {[::tsp::typeIsDouble  $typeList] || [::tsp::typeIsInt     $typeList]} {return}}
        boolean {if {[::tsp::typeIsBoolean $typeList]} {return}}
        string  {return}
        var     {return}
    }

    set value "[string range $value 0 20][expr {[string length $value] > 20 ? " ..." : ""}]"
    append msg "-------------------------------------------------------------------------------------" \n
    append msg "PROC RETURN: proc: $procName\treturn type defined: $procReturnType\tvalue: $value\ttypes: $typeList" \n
    append msg [::tsp::stacktrace] \n
    puts $::tsp::TRACE_FD  $msg
    flush $::tsp::TRACE_FD

}


