
#########################################################
# add indentation 
# assumes newlines are only in source text, not literals
# optionally override with n
# optionally add prefix string, only if n specified
proc ::tsp::indent {compUnitDict str {n -1} {prefix ""}} {
    upvar $compUnitDict compUnit
    set level [dict get $compUnit depth]
    if {$n > 0} {
        incr level $n
    }
    if {$level == 0} {
        return $str
    }
    set spaces [string repeat "    " $level]
    regsub -all \n $str "\n$spaces" str
    return $prefix$spaces$str
}

#########################################################
# incr depth (and indentation) level
#
proc ::tsp::incrDepth {compUnitDict {n 1}} {
    upvar $compUnitDict compUnit
    dict incr compUnit depth $n
}



#########################################################
# check a command string for nested commands
#
proc ::tsp::cmdStringHasNestedCommands {cmdStr} {
    set dummyUnit [::tsp::init_compunit dummy dummy dummy $cmdStr]
    set rc [catch {lassign [parse command $cmdStr {0 end}] cmdComments cmdRange cmdRest cmdTree}]
    if {$rc == 1 || [lindex $cmdRest 1] != 0} {
        # parse error or more than one command
        return 1
    }
    return [::tsp::treeHasNestedCommands dummyUnit $cmdTree]
}


#########################################################
# check a parsed tree for nested commands
#
proc ::tsp::treeHasNestedCommands {compUnitDict tree} {
    upvar $compUnitDict compUnit
    set cmdComponents [::tsp::parse_command compUnit $tree]
    set cmdFirstType [lindex [lindex $cmdComponents 0] 0]
    if {$cmdFirstType eq "invalid"} {
        return 1
    } else {
        return 0
    }
}



#########################################################
# generate code to spill variables into tcl interp
#
proc ::tsp::gen_spill_vars {compUnitDict volatile} {
    upvar $compUnitDict compUnit
    return [::tsp::lang_spill_vars compUnit $volatile]
}

#########################################################
# generate code to reload variables fromt tcl interp
#
proc ::tsp::gen_load_vars {compUnitDict volatile} {
    upvar $compUnitDict compUnit
    return [::tsp::lang_load_vars compUnit $volatile]
}

#########################################################
# generate code for a command
# return list of: type rhsVarName code
# where: type is one of ::tsp::RETURN_TYPES
#        rhsVarName is the name of a var that holds the
#            result of the command (can be null)
#        code is the generated code 
# 
proc ::tsp::gen_command {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set firstWordComponent [lindex [::tsp::parse_word compUnit [lindex $tree 0]] 0]
    lassign $firstWordComponent type word

    if {$type eq "backslash" || $type eq "command" || $type eq "invalid"} {
        ::tsp::addError compUnit "::tsp::gen_command - first word is cmd, backslash, or invalid"
        return [list void "" ""]
    } else {
        # set is special, it can have a nested command argument (only one)
        if {$word eq "set"} {
            return [::tsp::gen_command_set compUnit $tree]

        } elseif {[::tsp::treeHasNestedCommands compUnit $tree]} {
            ::tsp::addError compUnit "::tsp::gen_command - command has nested command argument"
            return [list void "" ""]
        }


        if {$type eq "text" && [info procs ::tsp::gen_command_$word] eq "::tsp::gen_command_$word"} {
            # command is compilable (if, while, string, lindex, etc.)
            ::tsp::reset_tmpvarsUsed compUnit
            return [::tsp::gen_command_$word compUnit $tree]

        } elseif {$type eq "text" && [dict exists $::tsp::COMPILED_PROCS $word]} {
            # command is previously compiled, invoke via direct type interface
            return [::tsp::gen_direct_tsp_compiled compUnit $tree]

        } elseif {$type eq "text" && [lsearch $::tsp::BUILTIN_TCL_COMMANDS $word] >= 0} {
            # command that is tcl built-in, invoke directly
            return [::tsp::gen_direct_tcl compUnit $tree]

        } else {
            # invoke via interp
            return [::tsp::gen_invoke_tcl compUnit $tree]
        }

    }

}


#########################################################
# generate an invocation to a previously compiled proc
# tree is a raw parse tree for the command
# returns list of [type rhsvar code]
#
proc ::tsp::gen_direct_tsp_compiled {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set result ""
    set cmdComponent [lindex [::tsp::parse_word compUnit [lindex $tree 0]] 0]
    set cmdName [lindex $cmdComponent 1]

    set proc_info  [dict get $::tsp::COMPILED_PROCS $cmdName]
    lassign $proc_info procType procArgTypes procRef
    
    set argTree [lrange $tree 1 end]
    if {[llength $argTree] != [llength $procArgTypes]} {
        ::tsp::addError compUnit "cannot invoke previously compiled proc \"$cmdName\", \
            wrong number of args, [llength $procArgTypes] required, [llength $argTree] supplied."
        return list [void "" ""]
    }

    append result "\n/***** ::tsp::gen_direct_tsp_compiled $cmdName */\n"
    lassign [::tsp::gen_native_type_list compUnit $argTree $procArgTypes] argVarList preserveVarList code
    append result $code

    # get a tmp var that holds return value 
    # note - ::tsp::reset_tmpvarsUsed was called in ::tsp_gen_native_type_list
    if {$procType ne "void"} {
        set returnVar [::tsp::get_tmpvar compUnit $procType]
    } else {
        set returnVar ""
    }

    append result [::tsp::lang_invoke_tsp_compiled $cmdName $procType $returnVar $argVarList $preserveVarList]

    return [list $procType $returnVar $result]
}

#########################################################
# generate a tcl invocation
# tree is a raw parse tree for the command
# cmd may should be builtin tcl command that is known in ::tsp::BUILTIN_TCL_COMMANDS
# returns list of [type rhsvar code]
#
proc ::tsp::gen_direct_tcl {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set cmdComponent [lindex [::tsp::parse_word compUnit [lindex $tree 0]] 0]
    set cmdName [lindex $cmdComponent 1]
    
    append result "\n/***** ::tsp::gen_direct_tcl $cmdName */\n"
    append result [::tsp::gen_objv_array compUnit $tree]
    lassign [::tsp::lang_invoke_builtin $cmdName] cmdResultVar code
    append result $code

    return [list var $cmdResultVar $result]
}


#########################################################
# generate a tcl invocation to execute a command
# tree is a raw parse tree for the command
# invoke tcl command via Interp.invoke() or Tcl_EvalObjv()
# returns list of [type rhsvar code]
#
proc ::tsp::gen_invoke_tcl {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set cmdComponent [lindex [::tsp::parse_word compUnit [lindex $tree 0]] 0]
    set cmdName [lindex $cmdComponent 1]
    
    append result "\n/***** ::tsp::gen_invoke_tcl $cmdName */\n"
    append result [::tsp::gen_objv_array compUnit $tree]
    lassign [::tsp::lang_invoke_tcl] cmdResultVar code
    append result $code

    return [list var $cmdResultVar $result]
}

##############################################
# build a native types list from a parse tree, 
# parse argTree is the command list in raw parse tree form
# returns a list of: argVarList preserveVarList code
#
proc ::tsp::gen_native_type_list {compUnitDict argTree procArgTypes} {
    upvar $compUnitDict compUnit
    set body [dict get $compUnit body]
    set result ""
    set argVarList [list]
    set preserveVarList [list]
    ::tsp::reset_tmpvarsUsed compUnit

    set idx 0
    foreach node $argTree {
        set argType [lindex $procArgTypes $idx]
        set parsedWord [::tsp::parse_word compUnit $node]

#FIXME: do we need to copy C DString into a new string arg?
#       if so, make a check of arg type "string" here, and allow to
#       fall into coercion code

        if {[lindex $parsedWord 0] eq "scalar"} {
            # arg is a variable, check the type
            set var [lindex $parsedWord 1]
            set varType [::tsp::getVarType compUnit $var]   
            if {$varType eq $argType} {
                # perfect - we have same type of arg that proc requires
                if {$varType eq "var"} {
                    lappend preserveVarList $var
                }
                lappend argVarList $var
                incr idx
                continue
            }
        }

        # else arg is different type, or is var, or is array, or is a constant, so
        # we assign into a tmp var 

        set argrange [lindex $node 1]
        lassign $argrange start end
        set end [expr {$start + $end - 1}]
        set argtext [string range $body $start $end]
        set argVar [::tsp::get_tmpvar compUnit $argType]
        set setBody "set $argVar $argtext"
        set dummyUnit [::tsp::init_compunit dummy dummy "" $setBody]
        lassign [parse command $setBody {0 end}] x x x setTree
        ::tsp::copyVars compUnit dummyUnit
        set argCode [::tsp::gen_command_set dummyUnit $setTree]
        append result [lindex $argCode 2]
        append result [::tsp::lang_assign_objv $idx $argVar]
        lappend argVarList $argVar
        incr idx
    }
    return [list $argVarList $preserveVarList $result]
}

##############################################
# build an objv array from a parse tree, 
# parse argTree is the command list in raw parse tree form
# returns code
#
proc ::tsp::gen_objv_array {compUnitDict argTree} {
    upvar $compUnitDict compUnit
    set body [dict get $compUnit body]
    set result ""
    ::tsp::reset_tmpvarsUsed compUnit
    set max [llength $argTree]
    
    append result [::tsp::lang_alloc_objv_array $max]

    set idx 0
    foreach node $argTree {
        set argrange [lindex $node 1]
        lassign $argrange start end
        set end [expr {$start + $end - 1}]
        set argtext [string range $body $start $end]
        set argVar [::tsp::get_tmpvar compUnit var]
        set setBody "set $argVar $argtext"
        set dummyUnit [::tsp::init_compunit dummy dummy "" $setBody]
        lassign [parse command $setBody {0 end}] x x x setTree
        ::tsp::copyVars compUnit dummyUnit
        set argCode [::tsp::gen_command_set dummyUnit $setTree]
        append result [lindex $argCode 2]
        #append result [::tsp::preserve $argVar]
        append result [::tsp::lang_assign_objv $idx $argVar]
        incr idx
    }
    return $result
}


##############################################
# build an objv list from a parse tree, 
# parse argTree is the command list in raw parse tree form
# returns code
#
proc ::tsp::gen_objv_list {compUnitDict argTree} {
    upvar $compUnitDict compUnit
    set body [dict get $compUnit body]
    set result ""
    ::tsp::reset_tmpvarsUsed compUnit
    set max [llength $argTree]
    
    append result [::tsp::lang_alloc_objv_list]

    foreach node $argTree {
        set argrange [lindex $node 1]
        lassign $argrange start end
        set end [expr {$start + $end - 1}]
        set argtext [string range $body $start $end]
        set argVar [::tsp::get_tmpvar compUnit var]
        set setBody "set $argVar $argtext"
        set dummyUnit [::tsp::init_compunit dummy dummy "" $setBody]
        lassign [parse command $setBody {0 end}] x x x setTree
        ::tsp::copyVars compUnit dummyUnit
        ::tsp::setVarType dummyUnit $argVar var
        set argCode [::tsp::gen_command_set dummyUnit $setTree]
        append result [lindex $argCode 2]
        #append result [::tsp::preserve $argVar]
        append result [::tsp::lang_append_objv $argVar]
    }
    return $result
}


#########################################################
# check if target variable is undefined, if so then make
#     it same as sourcetype
#
proc ::tsp::gen_check_target_var {compUnitDict targetVarName targetType sourceType} {
    upvar $compUnitDict compUnit
    if {$targetType eq "undefined" && $sourceType ne "void"} {
        set targetType $sourceType
        ::tsp::addWarning compUnit "variable \"$targetVarName\" implicitly defined as type \"$sourceType\""
        ::tsp::setVarType compUnit $targetVarName $targetType
    }
    return $targetType
}

#########################################################
# generate a runtime error message that includes source
#  file, proc name, line number
#
proc ::tsp::gen_runtime_error {compUnitDict msg} {
    upvar $compUnitDict compUnit
    set file [dict get $compUnit file]
    set proc [dict get $compUnit name]
    set line [dict get $compUnit lineNum]
    return "tsp runtime error, file: \"$file\" proc: \"$proc\" line: $line - $msg"
}






proc ::tsp::gen_command_if {compUnitDict tree} {
}
proc ::tsp::gen_command_foreach {compUnitDict tree} {
}
proc ::tsp::gen_command_break {compUnitDict tree} {
}
proc ::tsp::gen_command_continue {compUnitDict tree} {
}
proc ::tsp::gen_command_return {compUnitDict tree} {
}
proc ::tsp::gen_command_incr {compUnitDict tree} {
}
proc ::tsp::gen_command_list {compUnitDict tree} {
}

