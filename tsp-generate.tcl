
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
    
    foreach var $volatile {
        set type [::tsp::getVarType compUnit $var]

        # doooh!! really tempting to mark the var as clean, since we're loading
        # it into the shadow var, but since it might not convert to the native type
        # at runtime we don't want to mark it clean.  However, we can always convert
        # a to a string native type, so only in the case where var is a string can
        # we be sure.
        # Note: ::tsp::lang_load_vars should use shadow temp variables for native types

        if {$type eq "string"} {
            ::tsp::setDirty compUnit $var 0 
        } else {
            ::tsp::setDirty compUnit $var 1
        }
    }

    # now generate the code to load vars
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

        } elseif {$type eq "text" && ([dict exists $::tsp::COMPILED_PROCS $word] || $word eq [dict get $compUnit name])} {
            # command is previously compiled, invoke via direct type interface
            # also could be a recursive call of the currently compiled proc
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


##############################################
# build a native types list from a parse tree, 
# parse argTree is the command list in raw parse tree form
# returns a list of: argVarList preserveVarList code
#
proc ::tsp::gen_native_type_list {compUnitDict argTree procArgTypes} {
    upvar $compUnitDict compUnit
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

        if {[lindex $parsedWord 0 0] eq "scalar"} {
            # arg is a variable, check the type
            set var [lindex $parsedWord 0 1]
            set varType [::tsp::getVarType compUnit $var]   
            if {$varType eq $argType} {
                # perfect - we have same type of arg that proc requires
                if {$varType eq "var"} {
                    lappend preserveVarList __$var
                }
                lappend argVarList __$var
                incr idx
                continue
            }
        }

        # else arg is different type, or is var, or is array, or is a constant, so
        # we assign into a tmp var 

#FIXME: if argType eq var, then use shadow/dirty

        set argVar [::tsp::get_tmpvar compUnit $argType]
        set argVarComponents [list [list text $argVar $argVar]]
        set nodeComponents [::tsp::parse_word compUnit $node]
        set nodeType [lindex [lindex $nodeComponents 0] 0]
        if {$nodeType eq "invalid" || $nodeType eq "command"} {
            ::tsp::addError compUnit "lappend argument parsed as \"$nodeType\"
            return [list void "" ""]
        }
        set setTree ""
        append result [lindex [::tsp::produce_set compUnit $setTree $argVarComponents $nodeComponents] 2]

        lappend argVarList $argVar
        incr idx
    }
    return [list $argVarList $preserveVarList $result]
}


#########################################################
# generate an invocation to a previously compiled proc (or a recursive
# invocation of the current proc)
# tree is a raw parse tree for the command
# returns list of [type rhsvar code]
#
proc ::tsp::gen_direct_tsp_compiled {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set result ""
    set cmdComponent [lindex [::tsp::parse_word compUnit [lindex $tree 0]] 0]
    set cmdName [lindex $cmdComponent 1]

    if {$cmdName eq [dict get $compUnit name]} { 
        set proc_info  [list [dict get $compUnit returns] [dict get $compUnit argTypes] {} ]
    } else {
        set proc_info  [dict get $::tsp::COMPILED_PROCS $cmdName]
    }
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
# use the static reference to the command name as a small optimization
# returns list of [type rhsvar code]
#
proc ::tsp::gen_direct_tcl {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set cmdComponent [lindex [::tsp::parse_word compUnit [lindex $tree 0]] 0]
    set cmdName [lindex $cmdComponent 1]
    
    append result "\n/***** ::tsp::gen_direct_tcl $cmdName */\n"
    append result [::tsp::gen_objv_array compUnit $tree [::tsp::lang_builtin_cmd_obj $cmdName]]
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
# get temp "var" type and conversion code.
# if varName is a scalar and a native type, use a shadow var and
# only assign if dirty.
# returns: list of: tmpvar conversion_code
# or in the case of error:
# returns: list of: invalid ""
#
proc ::tsp::getTmpVarAndConversion {compUnitDict node} {
    upvar $compUnitDict compUnit
    set result ""
    set nodeComponents [::tsp::parse_word compUnit $node]
    set nodeType [lindex [lindex $nodeComponents 0] 0]
    set nodeVarOrOther [lindex [lindex $nodeComponents 0] 1]
    if {$nodeType eq "invalid" || $nodeType eq "command"} {
	::tsp::addError compUnit "objv argument parsed as \"$nodeType\" "
	return [list void "" ""]
    } elseif {$nodeType eq "scalar" && [lsearch $::tsp::NATIVE_TYPES [::tsp::getVarType compUnit $nodeVarOrOther]] >= 0} {
	# use shadow tmpvar, and only assign current native value if dirty
	set argVar [::tsp::get_tmpvar compUnit var $nodeVarOrOther]
	if {[lsearch [::tsp::getCleanList compUnit] $nodeVarOrOther] == -1} {
	    # var is not clean (or not present, generate an assignment and mark it clean
	    set argVarComponents [list [list text $argVar $argVar]]
	    set setTree ""
	    append result [lindex [::tsp::produce_set compUnit $setTree $argVarComponents $nodeComponents] 2]
	    ::tsp::setDirty compUnit $nodeVarOrOther 0
	} else {
	    # var is clean no need to re-assign
            set result "/* shadow var $nodeVarOrOther marked as clean */\n"
	}
    } else {
	# just grab a regular temp var and generate an assignment
	set argVar [::tsp::get_tmpvar compUnit var]
	set argVarComponents [list [list text $argVar $argVar]]
	set setTree ""
	append result [lindex [::tsp::produce_set compUnit $setTree $argVarComponents $nodeComponents] 2]
    }
    return [list $argVar $result]
}


##############################################
# build an objv array from a parse tree, 
# parse argTree is the command list in raw parse tree form
# optional "firstObj" is used to populate a builtin Tcl command 
# name TclString object, in the case we are called from ::tsp::gen_direct_tcl
# returns code
#
proc ::tsp::gen_objv_array {compUnitDict argTree {firstObj {}}} {
    upvar $compUnitDict compUnit
    set result ""
    ::tsp::reset_tmpvarsUsed compUnit
    set max [llength $argTree]
    
    append result [::tsp::lang_alloc_objv_array $max]

    set idx 0
    foreach node $argTree {
        if {$idx == 0 && $firstObj ne ""} {
            set argVar $firstObj
        } else {
            lassign [::tsp::getTmpVarAndConversion $compUnitDict $node] argVar conversionCode
            if {$argVar eq "invalid"} {
                return [list void "" ""]
            }
            append result $conversionCode
        }

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
proc ::tsp::gen_objv_list {compUnitDict argTree varName} {
    upvar $compUnitDict compUnit
    set result ""
    set max [llength $argTree]
    
    append result [::tsp::lang_alloc_objv_list $varName]
    set argVar [::tsp::get_tmpvar compUnit var]

    foreach node $argTree {
        append result [::tsp::lang_safe_release $argVar]
        set argVarComponents [list [list text $argVar $argVar]]
        set appendNodeComponents [::tsp::parse_word compUnit $node]
        set appendNodeType [lindex [lindex $appendNodeComponents 0] 0]
        if {$appendNodeType eq "invalid" || $appendNodeType eq "command"} {
            ::tsp::addError compUnit "lappend argument parsed as \"$appendNodeType\"
            return [list void "" ""]
        }
        set setTree ""
        append result [lindex [::tsp::produce_set compUnit $setTree $argVarComponents $appendNodeComponents] 2]

        append result [::tsp::lang_lappend_var $varName $argVar]
    }
    return $result
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


#########################################################
# parse a string node, node is from [parse command], valid are:
# returns: list of: invalid reason
# returns: list of: valid strRef code
# where valid is "1" if valid, "0" if invalid
# strRef is either string variable
# code is populated if any type conversion is needed, otherwise empty string.
#
proc ::tsp::get_string {compUnitDict node} {
    upvar $compUnitDict compUnit

    set strComponents [::tsp::parse_word compUnit $node]
    if {[llength $strComponents] == 1} {
        lassign [lindex $strComponents 0] type textOrVar text
        if {$type eq "scalar"} {
            set varName $textOrVar
            set varType [::tsp::getVarType compUnit $varName]
            if {$varType eq "undefined"} {
                return [list 0 "variable is undefined: $varName"]
            } elseif {$varType eq "string"} {
                if {! [::tsp::is_tmpvar $varName]} {
                    set varName __$varName
                }
                return [list 1 $varName ""]
            } else {
                if {! [::tsp::is_tmpvar $varName]} {
                    set varName __$varName
                }
                set strVar [::tsp::get_tmpvar compUnit string]
                set convertCode [::tsp::lang_convert_string_$varType $strVar $varName "can't convert to string from type: $varType"]
                return [list 1 $strVar $convertCode]
            }
        } elseif {$type eq "text"} {
            set strVar [::tsp::get_tmpvar compUnit string]
            set convertCode [::tsp::lang_assign_string_const $strVar $text]
            return [list 1 $strVar $convertCode]
        } else {
            return [list 0 "::tsp::get_string: unexpected parse type: $type" ""]
        }
    } else {
        # interpolated text or array var
        set strVar [::tsp::get_tmpvar compUnit string]
        set strVarComponents [list [list text $strVar $strVar]]
        set convertCode [lindex [::tsp::produce_set compUnit "" $strVarComponents $strComponents] 2]
        if {$convertCode eq ""} {
            return [list 0 "can't convert to string from node: $strComponents" ""]
        } else {
            return [list 1 $strVar $convertCode]
        }
    }
    error "::tsp::get_string: unexpected result"
}

#########################################################
# parse a index, node is from [parse command], valid are:
# an integer literal
# a scalar of type int
# end-integer
# end-scalar
# returns: list of: invalid reason
# returns: list of: valid indexRef endMinus code
# where valid is "1" if valid, "0" if invalid
# indexRef is either an integer literal or a scalar int.
# endMinus is 1 if "end-x", 0 otherwise.
# code is populated if any type conversion is needed, otherwise empty string.
#
proc ::tsp::get_index {compUnitDict node} {
    upvar $compUnitDict compUnit

    set nodeComponents [::tsp::parse_word compUnit $node]
    set firstType [lindex $nodeComponents 0 0]
    if {[llength $nodeComponents] == 1} {
        if {$firstType eq "text"} {
            lassign [lindex $nodeComponents 0] type rawtext text
            if {$rawtext eq "end"} {
                return [list 1 0 1 ""]
            } elseif {[regexp {^end-([0-9]+)$} $rawtext match intvalue]} {
                return [list 1 $intvalue 1 ""]
            } elseif {[::tsp::literalExprTypes $rawtext] eq "int"} {
                return [list 1 $rawtext 0 ""]
            } else {
                return [list 0 "can't parse index: $rawtext"]
            }
        } elseif {$firstType eq "scalar"} {
            lassign [lindex $nodeComponents 0] type varname
            set type [::tsp::getVarType compUnit $varname]
            if {$type eq "int"} {
                if {! [::tsp::is_tmpvar $varname]} {
                    set varname __$varname
                }
                return [list 1 $varname 0 ""]
            } else {
                set intVar [::tsp::get_tmpvar compUnit int]
                if {! [::tsp::is_tmpvar $varname]} {
                    set varname __$varname
                }
                set code [::tsp::lang_convert_int_$type $intVar $varname "can't convert from $type to int"]
                return [list 1 $intVar 0 $code]
            }
        }
    } elseif {[llength $nodeComponents] == 2} {
        lassign $nodeComponents firstNode secondNode
        lassign $firstNode firstType rawtext text
        lassign $secondNode secondType varname
        set type [::tsp::getVarType compUnit $varname]
        if {$firstType eq "text" && $rawtext eq "end-" && $secondType eq "scalar"} {
            if {$type eq "int"} {
                if {! [::tsp::is_tmpvar $varname]} {
                    set varname __$varname
                }
                return [list 1 $varname 1 ""]
            } else {
                set intVar [::tsp::get_tmpvar compUnit int]
                if {! [::tsp::is_tmpvar $varname]} {
                    set varname __$varname
                }
                set code [::tsp::lang_convert_int_$type $intVar $varname]
                return [list 1 $intVar 1 $code]
            }
        } else {
            return [list 0 "can't parse node as an index"]
        }
    } else {
        return [list 0 "can't parse node as an index"]
    }
}



#########################################################
# check which commands define/use variables by name, rather than by value.
# if a command it found, return "load" or "spill/load" if variables need
# only loading after the command ("scan", "binary scan", etc.), or spilling 
# to interp before the command as well ("lset", etc.).  Only for 
# commands that are not otherwise compiled, e.g. "append", "lappend", etc.
# are compiled and perform their own function
#
proc ::tsp::check_varname_args {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set cmdLength [llength $tree]
    set cmdNode [lindex $tree 0]
    set cmdNodeComponents [::tsp::parse_word compUnit $cmdNode]
    if {[llength $cmdNodeComponents] > 1 || [lindex $cmdNodeComponents 0 0] ne "text"} { 
        return ""
    }
    set cmd [lindex $cmdNodeComponents 0 1]

    foreach spillElement $::tsp::SPILL_LOAD_COMMANDS {
        lassign $spillElement spillCmd subcmdOption start end vartype spilltype
        set spillNames  [list $spilltype $vartype]

        if {$spillCmd eq $cmd} {
            # subcommand, pickout the varnames by absolute index
            if {$subcmdOption eq ""} {
                foreach node [lrange $tree $start $end] {
                    set varname [::tsp::nodeText compUnit $node]
                    if {$varname ne ""} {
                        if {[::tsp::getVarType compUnit $varname] eq "undefined"} {
                            ::tsp::addWarning compUnit "\"$varname\" implicitly defined as type \"$vartype\" by command \"$cmd\""
                            ::tsp::setVarType compUnit $varname $vartype
                        }
                        lappend spillNames $varname
                    }
                }
                return $spillNames

            } elseif {$subcmdOption eq "--"} {
                # end of options, pickout the varnames by relative index 
                for {set i 1} {$i < $cmdLength} {incr i} {
                    set node [lindex $tree $i]
                    set nodeComponents [::tsp::parse_word compUnit $node]
                    if {[llength $nodeComponents] == 1 && [lindex $nodeComponents 0 0] eq "text"} {
                        set rawtext [lindex $nodeComponents 0 1]
                        if {[string range $rawtext 0 0] eq "-"} {
                            continue
                        }
                        if {$start ne "end"} {
                            incr start $i
                        }
                        if {$end ne "end"} {
                            incr end $i
                        }
                        foreach node [lrange $tree $start $end] {
                            set varname [::tsp::nodeText compUnit $node]
                            if {[::tsp::getVarType compUnit $varname] eq "undefined"} {
                                ::tsp::addWarning compUnit "\"$varname\" implicitly defined as type \"$vartype\" by command \"$cmd\""
                                ::tsp::setVarType compUnit $varname $vartype
                            }
                            if {$varname ne ""} {
                                lappend spillNames $varname
                            }
                        }
                        return $spillNames
                    }
                }   

            } elseif {[string range $subcmdOption 0 0] eq "-"} {
                # end of options, pickout the varnames by relative index
                for {set i 1} {$i < $cmdLength} {incr i} {
                    set node [lindex $tree $i]
                    set nodeComponents [::tsp::parse_word compUnit $node]
                    if {[llength $nodeComponents] == 1 && [lindex $nodeComponents 0 0] eq "text"} {
                        set rawtext [lindex $nodeComponents 0 1]
                        if {[string range $rawtext 0 0] eq $subcmdOption} {
                            if {$start ne "end"} {
                                incr start $i
                            }
                            if {$end ne "end} {
                                incr end $i
                            }
                            foreach node [lrange $tree $start $end] {
                                set varname [::tsp::nodeText compUnit $node]
                                if {[::tsp::getVarType compUnit $varname] eq "undefined"} {
                                    ::tsp::addWarning compUnit "\"$varname\" implicitly defined as type \"$vartype\" by command \"$cmd\""
                                    ::tsp::setVarType compUnit $varname $vartype
                                }
                                if {$varname ne ""} {
                                    lappend spillNames $varname
                                }
                            }
                            return $spillNames
                        }
                    }
                }   
            } else {
                # whole command, pick out the varnames by absolute index
                foreach node [lrange $tree $start $end] {
                    set varname [::tsp::nodeText compUnit $node]
                    if {[::tsp::getVarType compUnit $varname] eq "undefined"} {
                        ::tsp::addWarning compUnit "\"$varname\" implicitly defined as type \"$vartype\" by command \"$cmd\""
                        ::tsp::setVarType compUnit $varname $vartype
                    }
                    if {$varname ne ""} {
                        lappend spillNames $varname
                    }
                }
                return $spillNames
            }
        }
    }
    return ""
}

#########################################################
# return rawtext if and only if it is a single node, text
# and not quoted.
#
proc ::tsp::nodeText {compUnitDict node} {
    upvar $compUnitDict compUnit
    set nodeComponents [::tsp::parse_word compUnit $node]
    if {[llength $nodeComponents] > 1 || [lindex $nodeComponents 0 0] ne "text"} {
        return ""
    }
    lassign [lindex $nodeComponents 0] type rawtext text
    if {$rawtext eq $text && [::tsp::isValidIdent $rawtext]} {
        return $rawtext
    } 
    return ""
}



