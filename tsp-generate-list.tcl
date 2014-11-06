
#  list commands
#  lappend, lindex, llength, lrange, lset, list, lreplace, linsert


#########################################################
# generate code for "lset" command (assumed to be first parse word)
# varName must be a var type; string, int, boolean, double cause compile error
# return list of: type rhsVarName code
# note: no need to set rhsVarName as dirty, since we don't shadow var types
#       and since we only "lightly" compile this command, gen_direct_tcl will
#       handle shadow vars
#
proc ::tsp::gen_command_lset {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 4} {
        ::tsp::addError compUnit "wrong # args: should be \"lset listVar index ?index...? value\""
        return [list void "" ""]
    }

    set code "\n/***** ::tsp::gen_command_lset */\n"
    set varname [::tsp::nodeText compUnit [lindex $tree 1]]

    if {$varname eq ""} {
        ::tsp::addError compUnit "lset varName not a text word"
        return [list void "" ""]
    }

    set type [::tsp::getVarType compUnit $varname]
    if {$type eq "array" || $type eq "string" || $type eq "boolean" || $type eq "int" || $type eq "double"} {
        ::tsp::addError compUnit "lset varName must be type var, defined as : $type"
        return [list void "" ""]
    }
    if {$type eq "undefined"} {
        if {[::tsp::isProcArg compUnit $varname]} {
            ::tsp::addError compUnit "proc argument variable \"$varname\" not previously defined"
            return [list void "" ""]
        } elseif {[::tsp::isValidIdent $varname]} {
            ::tsp::addWarning compUnit "variable \"${varname}\" implicitly defined as type: \"var\" (lset)"
            ::tsp::setVarType compUnit $varname var
            set type var
        } else {
            ::tsp::addError compUnit "invalid identifier: \"$varname\""
            return [list void "" ""]
        }

        set pre [::tsp::var_prefix $varname]
        append code [::tsp::lang_assign_empty_zero $pre$varname var]
        append code [::tsp::lang_preserve $pre$varname]
    } else {
        # varname exists
        # if varname was not previously included as volatile, spill variable here and add to volatile list
        if {[lsearch [dict get $compUnit volatile] $varname] == -1} {
            append code [::tsp::lang_spill_vars compUnit $varname] \n
            ::tsp::append_volatile_list compUnit $varname
        }
    }

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
# note: no need to set rhsVarName as dirty, since we don't shadow var types
#       we still will use shadow var/dirty checking for args
#
proc ::tsp::gen_command_lappend {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 2} {
        ::tsp::addError compUnit "wrong # args: should be \"lappend varName ?value value ...?\""
        return [list void "" ""]
    }
    
    set varname [::tsp::nodeText compUnit [lindex $tree 1]]

    if {$varname eq ""} {
        ::tsp::addError compUnit "lappend varName not a text word"
        return [list void "" ""]
    }

    set code "\n/***** ::tsp::gen_command_lappend */\n"
    set type [::tsp::getVarType compUnit $varname]
    if {$type eq "array" || $type eq "string" || $type eq "boolean" || $type eq "int" || $type eq "double"} {
        ::tsp::addError compUnit "append varName must be type var, defined as : $type"
        return [list void "" ""]
    }
    if {$type eq "undefined"} {
        if {[::tsp::isProcArg compUnit $varname]} {
            ::tsp::addError compUnit "proc argument variable \"$varname\" not previously defined"
            return [list void "" ""]
        } elseif {[::tsp::isValidIdent $varname]} {
            ::tsp::addWarning compUnit "variable \"${varname}\" implicitly defined as type: \"var\" (lappend)"
            ::tsp::setVarType compUnit $varname var
            set type var
        } else {
            ::tsp::addError compUnit "invalid identifier: \"$varname\""
            return [list void "" ""]
        }
        
        set pre [::tsp::var_prefix $varname]
        append code [::tsp::lang_assign_empty_zero $pre$varname var]
        append code [::tsp::lang_preserve $pre$varname]
    } else {
        # varname exists
        # if varname was not previously included as volatile, spill variable here and add to volatile list
        if {[lsearch [dict get $compUnit volatile] $varname] == -1} {
            append code [::tsp::lang_spill_vars compUnit $varname] \n
            ::tsp::append_volatile_list compUnit $varname
        }
    }


#FIXME: use shadow var and dirty checking
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

        # note - TclList.append with preserve() the argVar
        set pre [::tsp::var_prefix $varname]
        append code [::tsp::lang_lappend_var  $pre$varname $argVar]
    }
    
    # return the value
    set pre [::tsp::var_prefix $varname]
    return [list var $pre$varname $code]
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
        set pre [::tsp::var_prefix $argVar]
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
            # convert the string into a tmp var
            #FIXME: use shadow var and dirty checking
            set argTmpVar [::tsp::get_tmpvar compUnit var]
            append code [::tsp::lang_assign_var_string $argTmpVar $pre$argVar]
            set argVar $argTmpVar
        } elseif {$argType eq "var"} {
            set argVar $pre$argVar
        } else {
            error "llength: unexpected type: $argType \n[::tsp::error_stacktrace]"
        }
        
    } else {
        # it's text, or an array reference, convert into a var
        set argTmpVar [::tsp::get_tmpvar compUnit var]
        set argTmpComponents [list [list text $argTmpVar $argTmpVar]]

        set setTree ""
        append code [lindex [::tsp::produce_set compUnit $setTree $argTmpComponents $argComponents] 2]

        set argVar $argTmpVar
    }

    set returnVar [::tsp::get_tmpvar compUnit int]
    append code [::tsp::lang_llength $returnVar $argVar \
        [::tsp::lang_quote_string [::tsp::gen_runtime_error compUnit "llength: can't convert argument to a list"]]]
    return [list int $returnVar $code]

}


#########################################################
# generate code for "list" command (assumed to be first parse word)
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_list {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set code "\n/***** ::tsp::gen_command_list */\n"

    set varName [::tsp::get_tmpvar compUnit var]
    append code [::tsp::lang_safe_release $varName]
    append code [::tsp::gen_objv_list compUnit [lrange $tree 1 end] $varName]
    return [list var $varName $code]
    
}


#########################################################
# generate code for "lindex" command (assumed to be first parse word)
# varName must be a var type 
# only compile simple case of one index, and only where index is an int or integer constant
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_lindex {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 2} {
        ::tsp::addError compUnit "wrong # args: should be \"lindex list ?index...?\""
        return [list void "" ""]
    }

    set code "\n/***** ::tsp::gen_command_lindex */\n"

    if {[llength $tree] != 3} {
        # no index or multiple indexes, pass this to the lindex command
        # generate the code to call the command, and append to existing code
        set directResult [::tsp::gen_direct_tcl compUnit $tree]
        lassign [lindex $directResult] type rhsvar
        append code [lindex $directResult 2]
        return [list $type $rhsvar $code]
    }

    # list argument, make sure it is a list
    # we'll assign it to another var if already a var :-(
#FIXME: use shadow var and dirty checking
    set argComponents [::tsp::parse_word compUnit [lindex $tree 1]]
    set argTmpVar [::tsp::get_tmpvar compUnit var]
    set argTmpComponents [list [list text $argTmpVar $argTmpVar]]
    set setTree ""
    append code [lindex [::tsp::produce_set compUnit $setTree $argTmpComponents $argComponents] 2]


    # index component, can either be an int type or an integer constant, anything else,
    # let lindex have at it.
    set idxResult [::tsp::get_index compUnit [lindex $tree 2]]
    lassign $idxResult idxValid idxRef idxIsFromEnd convertCode

    if {! $idxValid} {
        set directResult [::tsp::gen_direct_tcl compUnit $tree]
        lassign [lindex $directResult] type rhsvar
        append code [lindex $directResult 2]
        return [list $type $rhsvar $code]
    } else {
        if {[::tsp::literalExprTypes $idxRef] eq "stringliteral"} {
            # not a int literal, so it must be a scalar
            set pre [::tsp::var_prefix $idxRef]
            set idxRef $pre$idxRef
        }
        append code $convertCode
    }

    set returnVar [::tsp::get_tmpvar compUnit var]
    append code [::tsp::lang_lindex $returnVar $argTmpVar $idxRef $idxIsFromEnd \
        [::tsp::lang_quote_string [::tsp::gen_runtime_error compUnit "lindex: can't convert argument to a list or index out of bounds"]]]

    return [list var $returnVar $code]
}


