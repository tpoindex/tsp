
#  string commands
#  append, scan, format, string 


#########################################################
# generate code for "append" command (assumed to be first parse word)
# varName must be a string or var type; int, boolean, double cause compile error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_append {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 2} {
        ::tsp::addError compUnit "wrong # args: should be \"append varName ?value value ...?\""
        return [list void "" ""]
    }

    # varname must be text, must exists
    set varComponent [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
    lassign $varComponent type rawtext varname
    if {$type ne "text"} {
        ::tsp::addError compUnit "append varName not a text word: \"$rawtext\""
        return [list void "" ""]
    }
    set type [::tsp::getVarType compUnit $varname]
    if {$type eq "undefined"} {
        ::tsp::addError compUnit "append varName is not defined"
        return [list void "" ""]
    }
    if {$type eq "array" || $type eq "boolean" || $type eq "int" || $type eq "double"} {
        ::tsp::addError compUnit "append varName must be type string or var, defined as : $type"
        return [list void "" ""]
    }

    set code "\n/***** ::tsp::gen_command_append */\n"
    set tmpvar [::tsp::get_tmpvar compUnit string]
    set body [dict get $compUnit body]
    foreach node [lrange $tree 2 end] {
        # append to string or var
        set argrange [lindex $node 1]
        lassign $argrange start end
        set end [expr {$start + $end - 1}]
        set argtext [string range $body $start $end]
        set setBody "set $tmpvar $argtext"
        set dummyUnit [::tsp::init_compunit dummy dummy "" $setBody]
        lassign [parse command $setBody {0 end}] x x x setTree
        ::tsp::copyVars compUnit dummyUnit
        set setCode [::tsp::gen_command_set dummyUnit $setTree]
        append code [lindex $setCode 2]
        append code [::tsp::lang_append_$type __$varname $tmpvar]
    }
    
    # return the value
    return [list $type __$varname $code]
}



#########################################################
# generate code for "scan" command (assumed to be first parse word)
# varName must be a string or var type; int, boolean, double cause compile error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_scan {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 3} {
        ::tsp::addError compUnit "wrong # args: should be \"scan string format ?varName varName ...?\""
        return [list void "" ""]
    }

#FIXME - compile scan for simple cases of %d %ld $Ld %f %e %g
# current impl just invokes tcl scan

    return [::tsp::gen_invoke_tcl compUnit $tree]
}



#FIXME: format, simple cases
#FIXME: string - optimize by using generated code.
