
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
 
    set pre [::tsp::var_prefix $varname]
    set code "\n/***** ::tsp::gen_command_append */\n"

    if {$type eq "var"} {
        # note - this is dead code for now, since we invoke gen_direct_tcl for 
        #        var types now (see a few lines above)
        # dup if shared obj, or assign empty var if null
        append code [::tsp::lang_dup_var_if_shared $pre$varname]
    }

    set argVar [::tsp::get_tmpvar compUnit string]
    set argVarComponents [list [list text $argVar $argVar]]
    foreach node [lrange $tree 2 end] {

        # assign arg into a tmp string type
        set appendNodeComponents [::tsp::parse_word compUnit $node]
        set appendNodeType [lindex [lindex $appendNodeComponents 0] 0]
        if {$appendNodeType eq "invalid"} {
            ::tsp::addError compUnit "append argument parsed as \"$appendNodeType\""
            return [list void "" ""]
        }
        set setTree ""
        append code [lindex [::tsp::produce_set compUnit $setTree $argVarComponents $appendNodeComponents] 2]

        if {$type eq "var"} {
            append code [::tsp::lang_append_var  $pre$varname $argVar]
        } elseif {$type eq "string"} {
            append code [::tsp::lang_append_string  $pre$varname $argVar]
        } else {
            error "::tsp::gen_command_append - unexpected varname type: $type\n[::tsp::currentLine compUnit]\n[::tsp::error_stacktrace]"
        }
    }
    
    # return the value
    return [list $type $pre$varname $code]
}



#########################################################
# generate code for "scan" command (assumed to be first parse word)
# varName must be a string or var type; int, boolean, double cause compile error
# return list of: type rhsVarName code
#
# FIXME: this is probably obsoleted by spill/load checking

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
# FIXME: this is probably obsoleted by spill/load checking

proc ::tsp::gen_command_binary {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 4} {
        ::tsp::addError compUnit "wrong # args: should be \"binary scan value formatString ?varName varName ...?\""
        return [list void "" ""]
    }

    set varlist [list]
    set subcommandNode [lindex $tree 1]
    set subcommandNodeComponents [::tsp::parse_word compUnit $subcommandNode]
    lassign [lindex $subcommandNodeComponents 0] type rawtext text
    if {[llength $subcommandNodeComponents] == 1 && $type eq "text"} {
        if {$rawtext eq "scan"} {
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

    set result ""
    set errMsg ""
    set rc 0

    # quick arg length check, all string commands need at least 3 args
    if {[llength $tree] < 3} {
        ::tsp::addError compUnit "string command doesn't have enough arguments"
        return [list void "" ""]
    }

    # get the string subcommand
    set subcommandNode [lindex $tree 1]
    set subcommandNodeComponents [::tsp::parse_word compUnit $subcommandNode]
    lassign [lindex $subcommandNodeComponents 0] type rawtext text

    if {[llength $subcommandNodeComponents] == 1 && $type eq "text"} {
        set cmd $rawtext
        
        switch $cmd {
            bytelength { }
            compare    { }
            equal      { }
            first      { }
            index      { set rc [catch {set result [::tsp::gen_string_index compUnit $tree]} errMsg] }
            is         { }
            last       { }
            length     { set rc [catch {set result [::tsp::gen_string_length compUnit $tree]} errMsg] }
            map        { }
            match      { }
            range      { set rc [catch {set result [::tsp::gen_string_range compUnit $tree]} errMsg] }
            repeat     { }
            replace    { }
            tolower    { }
            toupper    { }
            totitle    { }
            trim       { }
            trimleft   { }
            trimright  { }
            wordend    { }
            wordstart  { }
        }
    } else {
        ::tsp::addWarning compUnit "string subcommand is not simple text"
        return [::tsp::gen_direct_tcl compUnit $tree]
    }

    if {$rc != 0} {
        ::tsp::addError compUnit $errMsg
        return [list void "" ""]
    }

    if {[llength $result] > 0} {
        return $result
    } else {
        return [::tsp::gen_direct_tcl compUnit $tree]
    }
}


#########################################################
# generate code for "string index"
# raise error if wrong arguments, etc.
# return list of: type rhsVarName code
#
proc ::tsp::gen_string_index {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] != 4} {
        ::tsp::addError compUnit "#wrong # args: should be \"string index string charIndex\""
        return [list void "" ""]
    }

    # if string is a scalar var, return null, so that builtin proc will handle it
    set node [lindex $tree 2]
    lassign [lindex [::tsp::parse_word compUnit $node] 0] type textOrVar text
    if {$type eq "scalar" && [::tsp::getVarType compUnit $textOrVar] eq "var"} {
        return ""
    }

    set code "/***** ::tsp::gen_command_string_index */\n"
    
    # get the string
    set strResult [::tsp::get_string compUnit [lindex $tree 2]]
    lassign $strResult result strVar convertCode
    if {$result ==  0} {
        ::tsp::addError compUnit "unable to get string argument: $strVar"
        return [list void "" ""]
    }  else {
        set pre [::tsp::var_prefix $strVar]
        set strVar $pre$strVar
    }
    append code $convertCode
    
    # get the index 
    set idxResult [::tsp::get_index compUnit [lindex $tree 3]]
    lassign $idxResult idxValid idxRef idxIsFromEnd convertCode

    if {! $idxValid} {
        ::tsp::addError compUnit "unable to get string index argument: $idxRef"
    } else {
        if {[::tsp::literalExprTypes $idxRef] eq "stringliteral"} {
            # not a int literal, so it must be a scalar
            set pre [::tsp::var_prefix $idxRef]
            set idxRef $pre$idxRef
        }
        append code $convertCode
    }

    set returnVar [::tsp::get_tmpvar compUnit string]
    append code [::tsp::lang_string_index $returnVar $idxRef $idxIsFromEnd $strVar]
    return [list string $returnVar $code]
}



#########################################################
# generate code for "string length"
# raise error if wrong arguments, etc.
# return list of: type rhsVarName code
#
proc ::tsp::gen_string_length {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] != 3} {
        ::tsp::addError compUnit "#wrong # args: should be \"string length string\""
        return [list void "" ""]
    }

    # if string is a scalar var, return null, so that builtin proc will handle it
    set node [lindex $tree 2]
    lassign [lindex [::tsp::parse_word compUnit $node] 0] type textOrVar text
    if {$type eq "scalar" && [::tsp::getVarType compUnit $textOrVar] eq "var"} {
        return ""
    }

    set code "/***** ::tsp::gen_command_string_length */\n"
    
    # get the string
    set strResult [::tsp::get_string compUnit [lindex $tree 2]]
    lassign $strResult result strVar convertCode
    if {$result ==  0} {
        ::tsp::addError compUnit "unable to get string argument: $strVar"
        return [list void "" ""]
    }  else {
        set pre [::tsp::var_prefix $strVar]
        set strVar $pre$strVar
    }
    append code $convertCode
    
    # get the length 
    set returnVar [::tsp::get_tmpvar compUnit int]
    append code [::tsp::lang_string_length $returnVar $strVar]
    return [list int $returnVar $code]
}


#########################################################
# generate code for "string range"
# raise error if wrong arguments, etc.
# return list of: type rhsVarName code
#
proc ::tsp::gen_string_range {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] != 5} {
        ::tsp::addError compUnit "#wrong # args: should be \"string range string first last\""
        return [list void "" ""]
    }

    # if string is a scalar var, return null, so that builtin proc will handle it
    set node [lindex $tree 2]
    lassign [lindex [::tsp::parse_word compUnit $node] 0] type textOrVar text
    if {$type eq "scalar" && [::tsp::getVarType compUnit $textOrVar] eq "var"} {
        return ""
    }

    set code "/***** ::tsp::gen_command_string_range */\n"
    
    # get the string
    set strResult [::tsp::get_string compUnit [lindex $tree 2]]
    lassign $strResult result strVar convertCode
    if {$result ==  0} {
        ::tsp::addError compUnit "unable to get string argument: $strVar"
        return [list void "" ""]
    }  else {
        set pre [::tsp::var_prefix $strVar]
        set strVar $pre$strVar
    }
    append code $convertCode
    
    # get the first index 
    set idxResult [::tsp::get_index compUnit [lindex $tree 3]]
    lassign $idxResult firstIdxValid firstIdxRef firstIdxIsFromEnd convertCode

    if {! $firstIdxValid} {
        ::tsp::addError compUnit "unable to get string index argument: $firstIdxRef"
        return [list void "" ""]
    } else {
        if {[::tsp::literalExprTypes $firstIdxRef] eq "stringliteral"} {
            set pre [::tsp::var_prefix $firstIdxRef]
            set firstIdxRef $pre$firstIdxRef
        }
        append code $convertCode
    }
    
    # get the last index 
    set idxResult [::tsp::get_index compUnit [lindex $tree 4]]
    lassign $idxResult lastIdxValid lastIdxRef lastIdxIsFromEnd convertCode

    if {! $lastIdxValid} {
        ::tsp::addError compUnit "unable to get string index argument: $lastIdxRef"
        return [list void "" ""]
    } else {
        if {[::tsp::literalExprTypes $lastIdxRef] eq "stringliteral"} {
            # not a int literal, so it must be a scalar
            set pre [::tsp::var_prefix $lastIdxRef]
            set lastIdxRef $pre$lastIdxRef
        }
        append code $convertCode
    }

    set returnVar [::tsp::get_tmpvar compUnit string]
    append code [::tsp::lang_string_range $returnVar $firstIdxRef $firstIdxIsFromEnd $lastIdxRef $lastIdxIsFromEnd $strVar]
    return [list string $returnVar $code]
}


