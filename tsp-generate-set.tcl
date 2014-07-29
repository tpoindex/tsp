#FIXME: be consistent in quoting strings, esp those that are array index
#       probaby ok to quote them once when recognized

#FIXME: everywhere lang_decl_var is used, it probably leaks tclobjects.  this
#       happens in code that has block-level tclobjects, and are not released.
#       replace these with get_tmpvar so that they will be cleaned on exit

#########################################################
# generate a set command, the basic assignment command
# we only compile: 
#     set var arg
#    where var is:
#       text    e.g., a scalar var
#       arr(idx) 
#       arr($idx) 
#    where arg is:
#       \backslashed escape character 
#       text
#       interpolated text  e.g., "this $is \n$stuff" (string/var target only)
#       $var
#       $arr(idx)
#       $arr($idx)
#       [cmd text/$var text/$var ...] 
#    where idx is:
#       text
#       $var
#
# returns list of [void "" code] - note return type is always void, and assignment var is empty string
#
# NOTE that anywhere a tcl var is used, it is prefixed with "__" for native compilation, except
#      for "array" variables, which are only accessed in the interp.  This is done anytime we
#      call a lang specific proc (::tsp::lang_*], or generate lang indepedent code.
#
proc ::tsp::gen_command_set {compUnitDict tree} {
    upvar $compUnitDict compUnit
    
    set errors 0
    set body [dict get $compUnit body]
  
    set len [llength $tree]
    if {$len != 3} {
        ::tsp::addError compUnit "set command must have two args"
        return [list void "" ""]
    }
    set targetStr [parse getstring $body [lindex [lindex $tree 1] 1]]
    set sourceStr [parse getstring $body [lindex [lindex $tree 2] 1]]

    # check target, should be a single text, text_array_idxtext, or text_array_idxvar
    set targetComponents [::tsp::parse_word compUnit [lindex $tree 1]]
    set firstType [lindex [lindex $targetComponents 0] 0]
    if { !($firstType eq "text" || $firstType eq "text_array_idxtext" || $firstType eq "text_array_idxvar")} {
        set errors 1
        ::tsp::addError compUnit "set target is not a scalar or array variable name: \"$targetStr\""
    }

    # check source word components
    set sourceComponents [::tsp::parse_word compUnit [lindex $tree 2]]
    set firstType [lindex [lindex $sourceComponents 0] 0]
    if {$firstType eq "invalid"} {
        set errors 1
        ::tsp::addError compUnit "set arg 2 invalid: \"$sourceStr\""
    }

    # if it's a command, make sure no nested commands
    if {[llength $sourceComponents] == 1 && $firstType eq "command"} {
        set cmdStr [lindex [lindex $sourceComponents 0] 1]
        if {[::tsp::cmdStringHasNestedCommands $cmdStr]} {
            set errors 1
            ::tsp::addError compUnit "set arg 2 command has nested commands, command is array reference, or is unparsable: \"$cmdStr\""
        }
    }

    # if multiple sourceComponents it's an interpolated string, make sure no nested commands 
    if {[llength $sourceComponents] > 1} {
        foreach word $sourceComponents {
            set type [lindex $word 0]
            if {$type eq "command"} {
                set errors 1
                ::tsp::addError compUnit "set arg 2 interpolated string has nested command: \"$sourceStr\""
            }
        }
    }

    # determine target variable name a type
    set targetComponent [lindex $targetComponents 0]
    set targetWordType [lindex $targetComponent 0]
    set targetVarName ""
    set targetType invalid
    set targetArrayIdxtext ""
    set targetArrayIdxvar ""
    if {$targetWordType eq "text"} {
        set targetVarName [lindex $targetComponent 2]
        set targetType [::tsp::getVarType compUnit $targetVarName]
        # targetType could be undefined, if this is the first reference to this scalar
        # resolve later, but make sure it's a valid identifier
        if {$targetType eq "undefined"} {
            # make sure this can be a valid variable
            if {! [::tsp::isValidIdent $targetVarName] } {
                set errors 1
                ::tsp::addError compUnit "set arg 1 previously undefined variable not a valid identifer: \"$targetVarName\""
                return [list void "" ""]
            }
        }
    } elseif {$targetWordType eq "text_array_idxtext" || $targetWordType eq "text_array_idxvar"} {
        set targetVarName [lindex $targetComponents 1]
        set targetType [::tsp::getVarType compUnit $targetVarName]
        if {$targetType eq "undefined"} {
            # make sure this can be a valid variable
            if {! [::tsp::isValidIdent $targetVarName] } {
                set errors 1
                ::tsp::addError compUnit "set arg 1 previously undefined variable not a valid identifer: \"$targetVarName\""
                return [list void "" ""]
            } else {
                set targetType array
                ::tsp::setVarType compUnit $targetVarName array
            }
        } elseif {$targetType ne "array"} {
            # variable parsed as an array, but some other type
            set errors 1
            ::tsp::addError compUnit "set arg 1 \"$targetVarName\" previously defined as type: \"$targetType\", now referenced as array"
        }

        # is index a string or variable?
        if {$targetWordType eq "text_array_idxtext"} {
            set targetArrayIdxtext [lindex $targetComponents 2]
            set targetArrayIdxvarType string
        } else {
            set targetArrayIdxvar  [lindex $targetComponents 2]
            set targetArrayIdxvarType [::tsp::getVarType compUnit $targetArrayIdxvar]
            if {$targetArrayIdxvarType eq "array"} {
                # we don't support index variables as arrays
                set errors 1
                ::tsp::addError compUnit "set arg 1 index variable \"$targetArrayIdxvar\" cannot be an defined as \"array\""
            } elseif {$targetArrayIdxvarType eq "undefined"} {
                set errors 1
                ::tsp::addError compUnit "set arg 1 array index undefined identifer: \"$targetArrayIdxvar\""
            }
        }
    } else {
        set errors 1
        ::tsp::addError compUnit "set arg 1 unexpected target type: \"$targetWordType\""
    }

    if {$errors} {
        return [list void "" ""]
    }
    
    # determine source variable/expression and type
    set sourceText ""
    set sourceType ""
    set sourceVarName ""
    set sourceArrayIdxtext ""
    set sourceArrayIdxvar ""
    set sourceCode ""

    # is source an interpolated string?
    if {[llength $sourceComponents] > 1} {
        if {$targetType eq "array"} {
            return [list void "" [::tsp::gen_assign_array_interpolated_string compUnit $targetVarName \
			$targetArrayIdxtext $targetArrayIdxvar $targetArrayIdxvarType $targetType $sourceComponents ]]

        } else {
            set sourceType string
            set targetType [::tsp::gen_check_target_var compUnit $targetVarName $targetType $sourceType]
            # append source components into a single string or var assignment
            # check that target is either string or var or array
            if {$targetType eq "string" || $targetType eq "var"} {
                # will fail if embedded command or array is found 
                return [list void "" [::tsp::gen_assign_var_string_interpolated_string compUnit $targetVarName $targetType $sourceComponents]]
    
            } else {
                ::tsp::addError compUnit "set command arg 1 variable must be string or var for interpolated string assignment: \"$targetVarName\""
                return [list void "" ""]
            }
        }

    } else {

        set sourceComponent [lindex $sourceComponents 0]
        set sourceWordType [lindex $sourceComponent 0]

        if {$sourceWordType eq "backslash"} {
            # backslashed string to string or var assignment
            # subst the backslashed constant, so that we can quote as a native string
            set sourceText [subst [lindex $sourceComponent 1]]
            set sourceType string
            set targetType [::tsp::gen_check_target_var compUnit $targetVarName $targetType $sourceType]

            # generate assigment
            if {$targetType eq "string"} {
                return [list void "" [::tsp::lang_assign_string_const __$targetVarName $sourceText]]

            } elseif {$targetType eq "var"} {
                return [list void "" [::tsp::lang_assign_var_string __$targetVarName [::tsp::lang_quote_string $sourceText]]]

            } elseif {$targetWordType eq "text_array_idxtext" || $targetWordType eq "text_array_idxvar"} {
                return [list void "" [::tsp::gen_assign_array_text compUnit $targetVarName $targetArrayIdxtext \
				$targetArrayIdxvar $targetArrayIdxvarType $targetType $sourceText $sourceType]]

            } else {
                ::tsp::addError compUnit "set command arg 1 variable must be string, var, or array for backslash assignment: \"$targetVarName\""
                return [list void "" ""]
            }


        } elseif {$sourceWordType eq "text"} {
            # possibly could be a int, double, or boolean literal, otherwise string
            set sourceType [::tsp::literalExprTypes [lindex $sourceComponent 2]]
            if {$sourceType ne "int" && $sourceType ne "double"} {
                set sourceType string
            }
            set sourceText [lindex $sourceComponent 2]
            set targetType [::tsp::gen_check_target_var compUnit $targetVarName $targetType $sourceType]

            # generate assigment
            if {$targetWordType eq "text"} {
                return [list void "" [::tsp::gen_assign_scalar_text compUnit $targetVarName $targetType $sourceText $sourceType]]

            } elseif {$targetWordType eq "text_array_idxtext" || $targetWordType eq "text_array_idxvar"} {
                return [list void "" [::tsp::gen_assign_array_text compUnit $targetVarName $targetArrayIdxtext \
				$targetArrayIdxvar $targetArrayIdxvarType $targetType $sourceText $sourceType]]

            } else {
                if {$errors} {
                    return [list void "" ""]
                }
                error "unexpected target word type: $targetWordType"
            }
            

        } elseif {$sourceWordType eq "scalar"} {
            # assignment from native variable or var, possible type coersion 
            set sourceVarName [lindex $sourceComponent 1]
            set sourceType [::tsp::getVarType compUnit $sourceVarName]
            if {$sourceType eq "undefined"} {
                ::tsp::addError compUnit "set command arg 2 variable not defined: \"$sourceVarName\""
                return [list void "" ""]
            }
            set targetType [::tsp::gen_check_target_var compUnit $targetVarName $targetType $sourceType]

            # generate assigment
            if {$targetWordType eq "text"} {
                # don't generate assignment if target and source are the same
                if {$targetVarName eq $sourceVarName} {
                    ::tsp::addWarning compUnit "ignoring self assignment: target \"$targetVarName\"  source \"$sourceVarName\""
                    return [list void "" ""]
                }
                return [list void "" [::tsp::gen_assign_scalar_scalar compUnit $targetVarName $targetType $sourceVarName $sourceType]]

            } elseif {$targetWordType eq "text_array_idxtext" || $targetWordType eq "text_array_idxvar"} {
                return [list void "" [::tsp::gen_assign_array_scalar compUnit $targetVarName $targetArrayIdxtext \
				$targetArrayIdxvar $targetArrayIdxvarType $targetType $sourceVarName $sourceType]]

            } else {
                error "unexpected target word type: $targetWordType"
            }

        } elseif {$sourceWordType eq "array_idxtext"} {
            set sourceVarName [lindex $sourceComponent 1]
            set sourceType [::tsp::getVarType compUnit $sourceVarName]
            if {$sourceType ne "array"} {
                ::tsp::addError compUnit "set command arg 2 variable not defined, referenced as array: \"$sourceVarName\""
                return [list void "" ""]
            }
            set sourceArrayIdxtext [lindex $sourceComponent 2]
            set sourceType var
            # assignment from var, possible type coersion 
            set targetType [::tsp::gen_check_target_var compUnit $targetVarName $targetType $sourceType]

            # generate assigment
            if {$targetWordType eq "text"} {
		return [list void "" [::tsp::gen_assign_scalar_array compUnit  $targetVarName $targetType \
			$sourceVarName "" "" [::tsp::lang_quote_string $sourceArrayIdxtext]]]
		

            } elseif {$targetWordType eq "text_array_idxtext" || $targetWordType eq "text_array_idxvar"} {
                # don't generate assignment if target and source are the same
                if {$targetVarName eq $sourceVarName && $targetArrayIdxtext eq $sourceArrayIdxtext} {
                    ::tsp::addWarning compUnit "ignoring self assignment: target \"$targetVarName\($targetArrayIdxtext)\"  source \"$sourceVarName\($sourceArrayIdxtext)\""
                    return [list void "" ""]
                }
                return [list void "" [::tsp::gen_assign_array_array compUnit $targetVarName $targetArrayIdxtext \
				$targetArrayIdxvar $targetArrayIdxvarType $targetType $sourceVarName "" "" $sourceArrayIdxtext]]

            } else {
                error "unexpected target word type: $targetWordType"
            }

        } elseif {$sourceWordType eq "array_idxvar"} {
            set sourceVarName [lindex $sourceComponent 1]
            set sourceType [::tsp::getVarType compUnit $sourceVarName]
            if {$sourceType ne "array"} {
                ::tsp::addError compUnit "set command arg 2 variable not defined, referenced as array: \"$sourceVarName\""
                return [list void "" ""]
            }
            set sourceArrayIdxvar [lindex $sourceComponent 2]
            set sourceArrayIdxvarType [::tsp::getVarType compUnit $sourceArrayIdxvar]
            if {$sourceArrayIdxvarType eq "undefined"} {
                ::tsp::addError compUnit "set command arg 2 array index variable not defined: \"$sourceArrayIdxvar\""
                return [list void "" ""]
            }
            set sourceType var
            # assignment from var, possible type coersion 
            set targetType [::tsp::gen_check_target_var compUnit $targetVarName $targetType $sourceType]
            # generate assigment
            if {$targetWordType eq "text"} {
		return [list void "" [::tsp::gen_assign_scalar_array compUnit  $targetVarName $targetType \
			$sourceVarName $sourceArrayIdxvar $sourceArrayIdxvarType ""]]
		

            } elseif {$targetWordType eq "text_array_idxtext" || $targetWordType eq "text_array_idxvar"} {
                # don't generate assignment if target and source are the same
                if {$targetVarName eq $sourceVarName && $targetArrayIdxvar eq $sourceArrayIdxvar} {
                    ::tsp::addWarning compUnit "ignoring self assignment: target \"$targetVarName\($targetArrayIdxvar)\"  source \"$sourceVarName\($sourceArrayIdxvar)\""
                    return [list void "" ""]
                }
                return [list void "" [::tsp::gen_assign_array_array compUnit $targetVarName $targetArrayIdxtext \
				$targetArrayIdxvar $targetArrayIdxvarType $targetType $sourceVarName $sourceArrayIdxvar $sourceArrayIdxvarType ""]]

            } else {
                error "unexpected target word type: $targetWordType"
            }

        } elseif {$sourceWordType eq "command"} {
            # assignment from command execution
            set sourceCmd [lindex $sourceComponent 1]
            set sourceRange [lindex [lindex $tree 2] 1]
            # removing enclosing [ ] characters
            lassign $sourceRange start end
            incr start 1
            incr end -2
            set sourceRange [list $start $end]
            set rc [catch {lassign [parse command [dict get $compUnit body] $sourceRange] cmdComments cmdRange cmdRest cmdTree}]            
            if {$rc == 0} {
                set firstNode [lindex $cmdTree 0]
                set firstWordList [::tsp::parse_word compUnit $firstNode]
                lassign $firstNode firstNodeType firstNodeRange firstNodeSubtree
                set word [parse getstring $sourceCmd $firstNodeRange]
                if {[llength $firstWordList] == 1} {
                    lassign [::tsp::gen_command compUnit $cmdTree] sourceType sourceRhsVar sourceCode
                } else {
                    # if got here, this was probably marked as error in nested check
                    set error 1
                    ::tsp::addError compUnit "command parse error in ::tsp::gen_command_set: set var \[command  ...\]-  $firstNode"
                    return [list void "" ""]
                }

		if {$sourceType eq "void"} {
		    ::tsp::addWarning compUnit "ignoring void assignment from nested command: target \"$targetVarName\""
                    return [list void "" ""]
                }

                set targetType [::tsp::gen_check_target_var compUnit $targetVarName $targetType $sourceType]
                # generate assignment
                # mostly same as a scalar from scalar assignment
		set sourceVarName $sourceRhsVar
                append result "\n/***** ::tsp::generate_set assign from command */\n"
                append result "{\n"
                append code $sourceCode
		set targetType [::tsp::gen_check_target_var compUnit $targetVarName $targetType $sourceType]

		# generate assigment
		if {$targetWordType eq "text"} {
		    # don't generate assignment if target and source are the same
		    if {$targetVarName eq $sourceVarName} {
			::tsp::addWarning compUnit "ignoring self assignment: target \"$targetVarName\"  source \"$sourceVarName\""
			return [list void "" ""]
		    }
		    append code [::tsp::gen_assign_scalar_scalar compUnit $targetVarName $targetType $sourceVarName $sourceType]

		} elseif {$targetWordType eq "text_array_idxtext" || $targetWordType eq "text_array_idxvar"} {
		    append code [::tsp::gen_assign_array_scalar compUnit $targetVarName $targetArrayIdxtext \
				    $targetArrayIdxvar $targetArrayIdxvarType $targetType $sourceVarName $sourceType]

		} else {
		    error "unexpected target word type: $targetWordType"
		}
                append result [::tsp::indent compUnit $code 1]
                append result "\n}\n"
                return [list void "" $result]

            } else {
                set errors 1
                ::tsp::addError compUnit "error parsing set arg 2: $sourceCmd"
                return [list void "" ""]
            }


        } else {
            set errors 1
            ::tsp::addError compUnit "set arg 2 unexpected source type: \"$sourceWordType\""
        }
    }
    
    # if any errors, return here
    if {$errors} {
        return [list void "" ""]
    }

}



#########################################################
# assign a scalar variable from text string
#
proc ::tsp::gen_assign_scalar_text {compUnitDict targetVarName targetType sourceText sourceType} {

    upvar $compUnitDict compUnit

    # set the target as dirty
    ::tsp::setDirty compUnit $targetVarName 

    # block level temp targetVarName and sourceVarName are a list of two elements "name istmp"
    # procedure wide temp targetVarName and sourceVarName are also recognized
    if {[llength $targetVarName] == 2 || [::tsp::is_tmpvar $targetVarName] || [string range $targetVarName 0 1] eq "__"} {
        set targetVarName [lindex $targetVarName 0]
        set targetPre ""
    } else {
        set targetPre __
    }

    append result "\n/***** ::tsp::gen_assign_scalar_text */\n"
    switch $targetType {
         boolean {
             switch $sourceType {
                 int {
                     append result "$targetPre$targetVarName = ([::tsp::lang_int_const $sourceText] != 0) ? [::tsp::lang_true_const] : [::tsp::lang_false_const];\n"
                     return $result
                 }
                 double {
                     append result "$targetPre$targetVarName = ([::tsp::lang_double_const $sourceText] != 0) ? [::tsp::lang_true_const] : [::tsp::lang_false_const];\n"
                     return $result
                 }
                 string {
                     if {[string is true $sourceText]} {
                         append result "$targetPre$targetVarName = [::tsp::lang_true_const];\n";
                         return $result
                     } elseif {[string is false]} {
                         append result "$targetPre$targetVarName = [::tsp::lang_false_const];\n";
                         return $result
                     } else {
                         ::tsp::addError compUnit "set arg 2 string is not a valid boolean value: \"$sourceText\""
                         return ""
                     }
                 }
                 error "unexpected sourceType: $sourceType"
             }
         }

         int {
             switch $sourceType {
                 int {
                     append result "$targetPre$targetVarName = [::tsp::lang_int_const $sourceText];\n"
                     return $result
                 }
                 double {
                     append result "$targetPre$targetVarName = ([::tsp::lang_type_int]) [::tsp::lang_double_const $sourceText];\n"
                     return $result
                 }
                 string {
                     ::tsp::addError compUnit "set arg 2 string not an $targetType value: \"$sourceText\""
                     return ""
                 }
                 error "unexpected sourceType: $sourceType"
             }
         }
         double {
             switch $sourceType {
                 int {
                     append result "$targetPre$targetVarName = (::tsp::lang_type_double) [::tsp::lang_int_const $sourceText];\n"
                     return $result
                 }
                 double {
                     append result "$targetPre$targetVarName = [::tsp::lang_double_const $sourceText];\n"
                     return $result
                 }
                 string {
                     ::tsp::addError compUnit "set arg 2 string not an $targetType value: \"$sourceText\""
                     return ""
                 }
                 error "unexpected sourceType: $sourceType"
             }
         }

         string {
             append result [::tsp::lang_assign_string_const $targetPre$targetVarName $sourceText]
             return $result
         }

         var {
             switch $sourceType {
                 int {
                     append result [::tsp::lang_assign_var_int  $targetPre$targetVarName $sourceText]
                     return $result
                 }
                 double {
                     append result [::tsp::lang_assign_var_double  $targetPre$targetVarName $sourceText]
                     return $result
                 }
                 string {
                     append result [::tsp::lang_assign_var_string  $targetPre$targetVarName [::tsp::lang_quote_string $sourceText]]
                     return $result
                 }
                 error "unexpected sourceType: $sourceType"
             }
         }
    }

    ::tsp::addError compUnit "set: error don't know how to assign $targetVarName $targetType from $sourceText $sourceType"
    return ""
}


#########################################################
# assign a scalar variable from a scalar
#
proc ::tsp::gen_assign_scalar_scalar {compUnitDict targetVarName targetType sourceVarName sourceType} {

    upvar $compUnitDict compUnit

    # set the target as dirty
    ::tsp::setDirty compUnit $targetVarName 

    # block level temp targetVarName and sourceVarName are a list of two elements "name istmp"
    # procedure wide temp targetVarName and sourceVarName are also recognized
    if {[llength $targetVarName] == 2 || [::tsp::is_tmpvar $targetVarName] || [string range $targetVarName 0 1] eq "__"} {
        set targetVarName [lindex $targetVarName 0]
        set targetPre ""
    } else {
        set targetPre __
    }

    if {[llength $sourceVarName] == 2 || [::tsp::is_tmpvar $sourceVarName] || [string range $sourceVarName 0 1] eq "__"} {
        set sourceVarName [lindex $sourceVarName 0]
        set sourcePre ""
    } else {
        set sourcePre __
    }

    append result "\n/***** ::tsp::gen_assign_scalar_scalar */\n"
    switch $targetType {
         boolean {
             switch $sourceType {
                 boolean {
                     append result "$targetPre$targetVarName = $sourcePre$sourceVarName;\n"
                     return $result
                 }
                 int -
                 double {
                     append result "$targetPre$targetVarName = ($sourcePre$sourceVarName != 0) ? [::tsp::lang_true_const] : [::tsp::lang_false_const];\n"
                     return $result
                 }
                 string {
                     set errMsg [::tsp::gen_runtime_error compUnit [::tsp::lang_quote_string "unable to convert string to boolean, \"$sourceVarName\", value: "]]
                     append result [::tsp::lang_convert_boolean_string $targetPre$targetVarName $sourcePre$sourceVarName $errMsg]
                     return $result
                 }
                 var {
                     set errMsg [::tsp::gen_runtime_error compUnit [::tsp::lang_quote_string "unable to convert var to boolean, \"$sourceVarName\", value: "]]
                     append result [::tsp::lang_convert_boolean_var $targetPre$targetVarName $sourcePre$sourceVarName $errMsg]
                     return $result
                 }
                 error "unexpected sourceType: $sourceType"
             }
         }

         int -
         double {
             switch $sourceType {
                 boolean {
                     append result "$targetPre$targetVarName = ($sourcePre$sourceVarName) ? 1 : 0;\n"
                     return $result
                 }
                 int -
                 double {
                     append result "$targetPre$targetVarName = ([::tsp::lang_type_$targetType]) $sourcePre$sourceVarName;\n"
                     return $result
                 }
                 string {
                     set errMsg [::tsp::gen_runtime_error compUnit [::tsp::lang_quote_string "unable to convert string to $targetType, \"$sourceVarName\", value: "]]
                     append result [::tsp::lang_convert_${targetType}_string $targetPre$targetVarName $sourcePre$sourceVarName $errMsg]
                     return $result
                 }
                 var {
                     set errMsg [::tsp::gen_runtime_error compUnit [::tsp::lang_quote_string "unable to convert var to $targetType, \"$sourceVarName\", value: "]]
                     append result [::tsp::lang_convert_${targetType}_var $targetPre$targetVarName $sourcePre$sourceVarName $errMsg]
                     return $result
                 }
                 error "unexpected sourceType: $sourceType"
             }
         }

         string {
             append result [::tsp::lang_convert_string_$sourceType $targetPre$targetVarName $sourcePre$sourceVarName]
             return $result
         }

         var {
             append result [::tsp::lang_assign_var_$sourceType  $targetPre$targetVarName $sourcePre$sourceVarName]
             return $result
         }
    }

    ::tsp::addError compUnit "set: error don't know how to assign $targetVarName $targetType from $sourceVarName $sourceType"
    return ""
}



#########################################################
# assign a string or var from an interpolated string
#
# note: uses block level: "tmp"  "tmp2"
# FIXME: be smarter about combining backslash and strings, just append until a scalar is found or last of components
proc ::tsp::gen_assign_var_string_interpolated_string {compUnitDict targetVarName targetType sourceComponents} {

    upvar $compUnitDict compUnit

    # set the target as dirty
    ::tsp::setDirty compUnit $targetVarName 
    
    # block level temp targetVarName and sourceVarName are a list of two elements "name istmp"
    # procedure wide temp targetVarName and sourceVarName are also recognized
    if {[llength $targetVarName] == 2 || [::tsp::is_tmpvar $targetVarName] || [string range $targetVarName 0 1] eq "__"} {
        set targetVarName [lindex $targetVarName 0]
        set targetPre ""
    } else {
        set targetPre __
    }

    append result "\n/***** ::tsp::gen_assign_var_string_interpolated_string */\n"
    append result "{\n"
    append code [::tsp::lang_decl_native_string tmp]
    if {$targetType eq "var"} {
        append code [::tsp::lang_decl_native_string tmp2]
    }
    foreach component $sourceComponents {
        set compType [lindex $component 0]
        switch $compType {
            text -
            backslash {
                # subst the backslashed text, so that we can quote it for a native string
                set sourceText [subst [lindex $component 1]]
                append code [::tsp::lang_assign_string_const tmp $sourceText]
            }
            scalar {
                # assignment from native variable or var, possible type coersion
                set sourceVarName [lindex $component 1]
                set sourceType [::tsp::getVarType compUnit $sourceVarName]
                if {$sourceType eq "undefined"} {
                    ::tsp::addError compUnit "set command arg 2 interpolated string variable not defined: \"$sourceVarName\""
                    return [list ""]
                }
                append code [::tsp::gen_assign_scalar_scalar compUnit {tmp istmp} string $sourceVarName $sourceType]
            }
            default {
                ::tsp::addError compUnit "set arg 2 interpolated string cannot contain $compType, only text, backslash, or scalar variables"
                return ""
            }
        }
        if {$targetType eq "string"} {
            append code [::tsp::lang_append_string $targetPre$targetVarName tmp]
        } elseif {$targetType eq "var"} {
            append code [::tsp::lang_append_string tmp2 tmp]
        }
    }
    if {$targetType eq "var"} {
        append code [::tsp::gen_assign_scalar_scalar compUnit $targetVarName var {tmp2 istmp} string]
        append code [::tsp::lang_free_native_string tmp2]
    }
    append code [::tsp::lang_free_native_string tmp]
    append result [::tsp::indent compUnit $code 1]
    append result "\n}\n"
    return $result
}


#########################################################
# assign an array variable from text string
# array index is either a text string, or a variable 
#
#FIXME: this should use shadow vars, and create/update if needed when var is dirty
#
proc ::tsp::gen_assign_array_text {compUnitDict targetVarName targetArrayIdxtext \
		targetArrayIdxvar targetArrayIdxvarType targetType sourceText sourceType} {

    upvar $compUnitDict compUnit
    
    # get a temp variable to work with
    set value [::tsp::get_tmpvar compUnit var]
    append code [::tsp::lang_safe_release $value]
    append result "\n/***** ::tsp::gen_assign_array_text */\n"
    if {$targetArrayIdxtext ne ""} {
        # constant string index
        if {$sourceType eq "string"} {
            append code [::tsp::lang_new_var_$sourceType  $value [::tsp::lang_quote_string $sourceText]]
            append code [::tsp::lang_preserve $value]
        } else {
            append code [::tsp::lang_new_var_$sourceType  $value $sourceText]
            append code [::tsp::lang_preserve $value]
        }
        append code [::tsp::lang_assign_array_var [::tsp::lang_quote_string $targetVarName] \
			[::tsp::lang_quote_string $targetArrayIdxtext] $value] 
        append result $code
        return $result
    } else {
        # variable index
        # we have to get a string from the scalar
        set idx [::tsp::get_tmpvar compUnit string]
        if {$sourceType eq "string"} {
            append code [::tsp::lang_new_var_$sourceType  $value [::tsp::lang_quote_string $sourceText]]
        } else {
            append code [::tsp::lang_new_var_$sourceType  $value $sourceText]
        }
        append code [::tsp::lang_convert_string_string $idx [::tsp::lang_get_string_$targetArrayIdxvarType __$targetArrayIdxvar]]
        append code [::tsp::lang_assign_array_var [::tsp::lang_quote_string $targetVarName] $idx $value]
        append result $code
        return $result
    }
}


#########################################################
# assign an array variable from scalar
# array index is either a text string, or a variable 
#
#FIXME: this should use shadow vars, and create/update if needed when var is dirty
#
proc ::tsp::gen_assign_array_scalar {compUnitDict targetVarName targetArrayIdxtext \
		targetArrayIdxvar targetArrayIdxvarType targetType sourceVarName sourceType} {

    upvar $compUnitDict compUnit
    
    append result "\n/***** ::tsp::gen_assign_array_scalar */\n"
    if {$targetArrayIdxtext ne ""} {
        # constant string index
        if {$sourceType eq "var"} {
            set value  __$sourceVarName
        } else {
            set value [::tsp::get_tmpvar compUnit var]
            append code [::tsp::lang_decl_var $value]
            append code [::tsp::lang_new_var_$sourceType  $value __$sourceVarName]
            append code [::tsp::lang_preserve $value]
        }
        append code [::tsp::lang_assign_array_var [::tsp::lang_quote_string $targetVarName] \
			[::tsp::lang_quote_string $targetArrayIdxtext] $value] 
        append result $code
        return $result
    } else {
        # variable index
        # we have to get a string from the scalar
        set idx [::tsp::get_tmpvar compUnit string]
        if {$sourceType eq "var"} {
            set value __$sourceVarName
        } else {
            set value [::tsp::get_tmpvar compUnit var]
            append code [::tsp::lang_safe_release $value]
            append code [::tsp::lang_new_var_$sourceType  value __$sourceVarName]
            append code [::tsp::lang_preserve $value]
        }
        append code [::tsp::lang_convert_string_string $idx  [::tsp::lang_get_string_$targetArrayIdxvarType __$targetArrayIdxvar]]
        append code [::tsp::lang_assign_array_var [::tsp::lang_quote_string $targetVarName] $idx $value]
        append result $code
        return $result
    }
}


#########################################################
# assign an array var from an interpolated string
#
proc ::tsp::gen_assign_array_interpolated_string {compUnitDict targetVarName targetArrayIdxtext targetArrayIdxvar targetArrayIdxvarType targetType sourceComponents} {
    upvar $compUnitDict compUnit

    append result "\n/***** ::tsp::gen_assign_array_interpolated_string */\n"
    set sourceVar [::tsp::get_tmpvar compUnit var]
    append code [::tsp::lang_safe_release $sourceVar]
    append code [::tsp::gen_assign_var_string_interpolated_string compUnit $sourceVar var $sourceComponents]
    append code [::tsp::lang_preserve $sourceVar]
    append code [::tsp::gen_assign_array_scalar compUnit $targetVarName $targetArrayIdxtext \
                                $targetArrayIdxvar $targetArrayIdxvarType $targetType $sourceVar var]
    append result $code
    return $result
}


#########################################################
# assign an scalar from an array
# sourceArrayIdx is either a quoted string, or a string 
#
proc ::tsp::gen_assign_scalar_array {compUnitDict targetVarName targetType sourceVarName sourceArrayIdxvar sourceArrayIdxvarType sourceArrayIdxtext} {

    upvar $compUnitDict compUnit
  
    # set the target as dirty
    ::tsp::setDirty compUnit $targetVarName 

    append result "\n/***** ::tsp::gen_assign_scalar_array */\n"
    set targetVar [::tsp::get_tmpvar compUnit var]
    append code [::tsp::lang_safe_release $targetVar]
    if {$sourceArrayIdxtext ne ""} {
        set errMsg [::tsp::gen_runtime_error compUnit [::tsp::lang_quote_string "unable to get var from array \"$sourceVarName\", index \"$sourceArrayIdxtext\" "]]
        append code [::tsp::lang_assign_var_array_idxtext $targetVar [::tsp::lang_quote_string $sourceVarName] $sourceArrayIdxtext $errMsg]
    } else {
        set errMsg [::tsp::gen_runtime_error compUnit [::tsp::lang_quote_string "unable to get var from array \"$sourceVarName\", index var \"$sourceArrayIdxvar\" "]]
        append code [::tsp::lang_assign_var_array_idxvar $targetVar [::tsp::lang_quote_string $sourceVarName] __$sourceArrayIdxvar $sourceArrayIdxvarType $errMsg]
    }
    append code [::tsp::lang_preserve $targetVar]
    append code [::tsp::gen_assign_scalar_scalar compUnit $targetVarName $targetType $targetVar var]
    append result $code
    return $result
}

#########################################################
# assign an array from an array
# 
proc ::tsp::gen_assign_array_array {compUnitDict targetVarName targetArrayIdxtext targetArrayIdxvar targetArrayIdxvarType targetType sourceVarName sourceArrayIdxvar sourceArrayIdxvarType sourceArrayIdxtext } {

    upvar $compUnitDict compUnit
  
    append result "\n/***** ::tsp::gen_assign_array_array */\n"
    set assignVar [::tsp::get_tmpvar compUnit var]
    append code [::tsp::lang_safe_release $assignVar]
    if {$sourceArrayIdxtext ne ""} {
        set errMsg [::tsp::gen_runtime_error compUnit [::tsp::lang_quote_string "unable to get var from array \"$sourceVarName\", index \"$sourceArrayIdxtext\" "]]
        append code [::tsp::lang_assign_var_array_idxtext $assignVar [::tsp::lang_quote_string $sourceVarName] [::tsp::lang_quote_string $sourceArrayIdxtext] $errMsg]
    } else {
        set errMsg [::tsp::gen_runtime_error compUnit [::tsp::lang_quote_string "unable to get var from array \"$sourceVarName\", index var \"$sourceArrayIdxvar\" "]]
        append code [::tsp::lang_assign_var_array_idxvar $assignVar [::tsp::lang_quote_string $sourceVarName] __$sourceArrayIdxvar $sourceArrayIdxvarType $errMsg]
    }
    
    append code [::tsp::lang_preserve $assignVar]
    append code [::tsp::gen_assign_array_scalar compUnit $targetVarName $targetArrayIdxtext \
                $targetArrayIdxvar $targetArrayIdxvarType $targetType $assignVar var ]
    append result $code
    return $result
}




