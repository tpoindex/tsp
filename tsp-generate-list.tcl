
#  list commands
#  lappend, lindex, llength, lrange, lset, list, lreplace, linsert


#########################################################
# generate code for "lset" command (assumed to be first parse word)
# varName must be a var type; string, int, boolean, double cause compile error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_lset {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 4} {
        ::tsp::addError compUnit "wrong # args: should be \"lset listVar index ?index...? value\""
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
        ::tsp::addError compUnit "can't read \"$varname\": no such variable"
        return [list void "" ""]
    }
    if {$type eq "array" || $type eq "string" || $type eq "boolean" || $type eq "int" || $type eq "double"} {
        ::tsp::addError compUnit "lset varName must be type var, defined as : $type"
        return [list void "" ""]
    }
    
    set code "\n/***** ::tsp::gen_command_lset */\n"
    # if varname was not previously included as volatile, spill variable here and add to volatile list
    if {[lsearch [dict get $compUnit volatile] $varname] == -1} {
        append code [::tsp::lang_spill_vars compUnit $varname] \n
        ::tsp::append_volatile_list compUnit $varname
    }

    # generate the code to call the command, and append to existing code
    set directResult [::tsp::gen_direct_tcl compUnit $tree]
    lassign [lindex $directResult] type rhsvar
    append code [lindex $directResult 2]

    return [list $type $rhsvar $code]
}


#########################################################
# generate code for "lappend" command (assumed to be first parse word)
# varName must be a var type; string, int, boolean, double cause compile error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_lappend {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 2} {
        ::tsp::addError compUnit "wrong # args: should be \"lappend varName ?value value ...?\""
        return [list void "" ""]
    }

    # varname must be text, must exists
    set varComponent [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
    lassign $varComponent type rawtext varname
    if {$type ne "text"} {
        ::tsp::addError compUnit "append varName not a text word: \"$rawtext\""
        return [list void "" ""]
    }

    set code "\n/***** ::tsp::gen_command_lappend */\n"
    set type [::tsp::getVarType compUnit $varname]
    if {$type eq "array" || $type eq "string" || $type eq "boolean" || $type eq "int" || $type eq "double"} {
        ::tsp::addError compUnit "append varName must be type var, defined as : $type"
        return [list void "" ""]
    }
    if {$type eq "undefined"} {
        ::tsp::addWarning compUnit "lappend varName \"$varname\" defined as var"
        append code [::tsp::lang_assign_empty_zero $varname var]
    }

    # if varname was not previously included as volatile, spill variable here and add to volatile list
    if {[lsearch [dict get $compUnit volatile] $varname] == -1} {
        append code [::tsp::lang_spill_vars compUnit $varname] \n
        ::tsp::append_volatile_list compUnit $varname
    }


    # append to var
    set argVar [::tsp::get_tmpvar compUnit var]
    set argVarComponents [list [list text $argVar $argVar]]
    foreach node [lrange $tree 2 end] {

        # assign arg into a tmp var type
        set appendNodeComponents [::tsp::parse_word compUnit $node]
        set appendNodeType [lindex [lindex $appendNodeComponents 0] 0]
        if {$appendNodeType eq "invalid" || $appendNodeType eq "command"} {
            ::tsp::addError compUnit "lappend argument parsed as \"$appendNodeType\"
            return [list void "" ""]
        }
        set setTree ""
        append code [lindex [::tsp::produce_set compUnit $setTree $argVarComponents $appendNodeComponents] 2]

        append code [::tsp::lang_lappend_var  __$varname $argVar]
    }
    
    # return the value
    return [list var __$varname $code]
}



#########################################################
# generate code for "llength" command (assumed to be first parse word)
# varName must be a var type; string, int, boolean, double cause compile error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_llength {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] != 2} {
        ::tsp::addError compUnit "wrong # args: should be \"llength list\""
        return [list void "" ""]
    }

    set code "\n/***** ::tsp::gen_command_llength */\n"
    
    set argComponents [::tsp::parse_word compUnit [lindex $tree 1]]
    set argComponentType [lindex [lindex $argComponents 0] 0]

    if {$argComponentType eq "invalid" || $argComponentType eq "command"} {
        ::tsp::addError compUnit "invalid argument for llength, parsed as: $argComponentType"
        return [list void "" ""]
    }
    if {$argComponentType eq "scalar"} {
        set argVar [lindex [lindex $argComponents 0] 1]
        set argType [::tsp::getVarType compUnit $argVar]
        if {$argType eq "boolean" || $argType eq "int" || $argType eq "double"} {
            # these have a length of 1 :-)
            append code "/* llength of $argType : 1*/\n"
            return [list int 1 $code]
        } elseif {$argType eq "array"} {
            ::tsp::addError compUnit "llength argument must be type var, defined as : $argType"
            return [list void "" ""]
        } elseif {$argType eq "undefined"} {
            ::tsp::addWarning compUnit "llength argument \"$argVar\" is undefined"
            return [list void "" ""]
        } elseif {$argType eq "string"} {
            # conver the string into a tmp var
            set argTmpVar [::tsp::get_tmpvar compUnit var]
            append code [::tsp::lang_assign_var_string $argTmpVar $argVar]
            set argVar $argTmpVar
        } elseif {$argType eq "var"} {
            set argVar __$argVar
        } else {
            error "llength: unexpected type: $argType"
        }
        
    } else {
        # it's text, or an array reference, convert into a var
        set argTmpVar [::tsp::get_tmpvar compUnit var]
        set argTmpComponents [list [list scalar $argTmpVar]]

        set setTree ""
        append code [lindex [::tsp::produce_set compUnit $setTree $argTmpComponents $argComponents] 2]

        set argVar $argTmpVar
    }

    set returnVar [::tsp::get_tmpvar compUnit int]
    append code [::tsp::lang_llength $returnVar $argVar \
        [::tsp::lang_quote_string [::tsp::gen_runtime_error compUnit "llength: can't convert argument to a list"]]]
    return [list int $returnVar $code]

}




#FIXME: compile other list commands
