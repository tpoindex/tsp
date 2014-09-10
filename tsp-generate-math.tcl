# compiled math commands:
# expr, incr

#########################################################
# generate code for "expr" command (assumed to be first parse word)
# only braced arguments are generated, anything else generates an error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_expr {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] != 2} {
        ::tsp::addError compUnit "wrong # args: should be \"expr arg\""
        return [list void "" ""]
    }

    set exprComponent [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
    lassign $exprComponent type rawtext exprtext
    if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
        ::tsp::addError compUnit "expr argument not a braced expression"
        return [list void "" ""]
    }

    set rc [catch {set exprTypeCode [::tsp::compileExpr compUnit $exprtext]} result]
    if {$rc != 0} {
        ::tsp::addError compUnit "couldn't parse expr: \"$exprtext\", $result"
        return [list void "" ""]
    }
    
    lassign $exprTypeCode type exprCode
    set tmpVar [::tsp::get_tmpvar compUnit $type]
    set code [::tsp::lang_expr "$tmpVar = $exprCode;"]
    return [list $type $tmpVar $code]
}


#########################################################
# generate code for "incr" command (assumed to be first parse word)
# return list of: type rhsVarName code
# FIXME:  support array targets?
#
proc ::tsp::gen_command_incr {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 2 || [llength $tree] > 3} {
        ::tsp::addError compUnit "wrong # args: should be \"incr varName ?increment?\""
        return [list void "" ""]
    }

    set varname [::tsp::nodeText compUnit [lindex $tree 1]]
    if {$varname eq ""} {
        ::tsp::addError compUnit "incr varName argument requires a scalar varName"
        return [list void "" ""]
    }

    set vartype [::tsp::getVarType compUnit $varname]
    if {$vartype eq "undefined"} {
        # previously undefined, make it an int
        set vartype int
        ::tsp::setVarType compUnit $varname int
        ::tsp::addWarning compUnit "variable \"$varname\" implicitly defined as \"int\""
    }

    if {$vartype ne "int" && $vartype ne "var"} {
        ::tsp::addError compUnit "incr argument varName must be type \"int\" or \"var\""
        return [list void "" ""]
    }
   
    set incrAmount 1
    set incrvar ""
    set incrtype ""
    if {[llength $tree] == 3} {
        set incrComponent [lindex [::tsp::parse_word compUnit [lindex $tree 2]] 0]
        lassign $incrComponent type incrvar incrtext
        if {$type eq "text"} {
            # make sure text is an integer
            if {[::tsp::literalExprTypes $incrtext] ne "int"} {
                ::tsp::addError compUnit "incr amount argument is not an integer: \"$incrtext\""
                return [list void "" ""]
            }
            set incrAmount $incrtext
            set incrvar ""
        } elseif {$type eq "scalar"} {
            set incrtype [::tsp::getVarType compUnit $incrvar]
            if {$incrtype ne "int" && $incrtype ne "var"} {
                ::tsp::addError compUnit "incr amount argument varName must be type \"int\" or \"var\""
                return [list void "" ""]
            }
        } else {
            ::tsp::addError compUnit "incr amount argument must be a integer or a scalar variable"
            return [list void "" ""]
        }
    }

    # check if either varname or incrvar are temp variables, otherwise prefix user vars with "__"
    if {! [::tsp::is_tmpvar $varname]} {
        set varname __$varname
    }

    if {$incrvar ne ""} {
        if {! [::tsp::is_tmpvar $incrvar]} {
            set incrvar __$incrvar
        }
    }

    # if target is a var, use a temp var for increment and assignment rhsVar
    if {$vartype eq "var"} {
        set rhsVar [::tsp::get_tmpvar compUnit int]
        set errMsg [::tsp::gen_runtime_error compUnit [::tsp::lang_quote_string "unable to convert var to int, \"$varname\", value: "]]
        append code [::tsp::lang_convert_int_var $rhsVar $varname $errMsg]
    } else {
        set rhsVar $varname
    }

    # if incr var is a var, use a temp var for increment 
    if {$incrvar ne ""} {
        if {$incrtype eq "var"} {
            set incrsource [::tsp::get_tmpvar compUnit int]
            set errMsg [::tsp::gen_runtime_error compUnit [::tsp::lang_quote_string "unable to convert var to int, \"$incrvar\", value: "]]
            append code [::tsp::lang_convert_int_var $incrsource $incrvar $errMsg]
        } else {
            set incrsource $incrvar
        }
    } else {
        set incrsource $incrAmount
    }
    
    append code "$rhsVar = $rhsVar + ($incrsource);\n"

    # if target var is a var, update the var with the incr amount
    if {$vartype eq "var"} {
        append code [::tsp::lang_assign_var_int $varname $rhsVar]
    }

    # native var has been assigned, so mark it as dirty
    ::tsp::setDirty compUnit $varname

    return [list int $rhsVar $code]
}



