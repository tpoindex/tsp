
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
    set argVar [::tsp::get_tmpvar compUnit string]
    set argVarComponents [list [list text $argVar $argVar]]
    foreach node [lrange $tree 2 end] {

        # assign arg into a tmp string type
        set appendNodeComponents [::tsp::parse_word compUnit $node]
        set appendNodeType [lindex [lindex $appendNodeComponents 0] 0]
        if {$appendNodeType eq "invalid" || $appendNodeType eq "command"} {
            ::tsp::addError compUnit "lappend argument parsed as \"$appendNodeType\""
            return [list void "" ""]
        }
        set setTree ""
        append code [lindex [::tsp::produce_set compUnit $setTree $argVarComponents $appendNodeComponents] 2]

        append code [::tsp::lang_append_var  __$varname $argVar]
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

    # FIXME - implements simple cases
    # compile scan for simple cases of %d %ld %Ld %f %e %g and one var


    set varlist [list]
    foreach node [lrange $tree 3 end] {
        set nodeComponents [::tsp::parse_word compUnit $node]
        set nodeType [lindex $nodeComponents 0 0]
        if {[llength $nodeComponents] == 1 && $nodeType eq "text"} {
            lassign [lindex $nodeComponents 0] nodeType varname text
            if {[::tsp::isValidIdent $varname]} {
                set vartype [::tsp::getVarType compUnit $varname]
                if {$vartype ne "undefined"} {
                    # make sure variable will be loaded after command finishes
                    lappend varlist $varname
                } else {
                    # identifier not defined, bail
                }
            } else {
                # bad identifier, bail
            }
        } else {
            # not simple text, can't be a var we use
        }
    }

    # make sure variable will be loaded after command finishes
    ::tsp::append_volatile_list compUnit $varlist

    return [::tsp::gen_direct_tcl compUnit $tree]
}

 
#########################################################
# generate code for "binary scan" command (assumed to be first parse word)
# just look at vars to make sure they get loaded after the command
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_binary {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 4} {
        ::tsp::addError compUnit "wrong # args: should be \"binary scan value formatString ?varName varName ...?\""
        return [list void "" ""]
    }

    set subcommandNode [lindex $tree 1]
    set subcommandNodeComponents [::tsp::parse_word compUnit $subcommandNode]
    lassign [lindex $subcommandNodeComponents 0] type rawtext text
    if {[llength $subcommandNodeComponents] == 1 && $type eq "text"} {
        if {$rawtext eq "scan"} {
            set varlist [list]
            foreach node [lrange $tree 4 end] {
                set nodeComponents [::tsp::parse_word compUnit $node]
                set nodeType [lindex $nodeComponents 0 0]
                if {[llength $nodeComponents] == 1 && $nodeType eq "text"} {
                    lassign [lindex $nodeComponents 0] nodeType varname text
                    if {[::tsp::isValidIdent $varname]} {
                        set vartype [::tsp::getVarType compUnit $varname]
                        if {$vartype ne "undefined"} {
                            # make sure variable will be loaded after command finishes
                            lappend varlist $varname
                        } else {
                            # identifier not defined, bail
                        }
                    } else {
                        # bad identifier, bail
                    }
                } else {
                    # not simple text, can't be a var we use
                }
            }
        }
    }

    # make sure variable will be loaded after command finishes
    ::tsp::append_volatile_list compUnit $varlist

    return [::tsp::gen_direct_tcl compUnit $tree]
}



#########################################################
# generate code for "string" command (assumed to be first parse word)
# lang_string determines whether or not the subcommand is compiled 
# default is to invoke interp string command
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_string {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set result [::tsp::lang_string compUnit $tree]

    if {[llength $result] > 0} {
        return $result
    } else {
        return [::tsp::gen_direct_tcl compUnit $tree]
    }
}


