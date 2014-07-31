
#  var scope commands
#  upvar, global, variable


#########################################################
# generate code for "upvar" command (assumed to be first parse word)
# pick out variables that will need to be loaded on proc entry, and
# spilled on proc exit.  actual upvar command is passed to ::tsp::gen_direct_tcl
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_upvar {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set len [llength $tree]
    if {$len < 3} {
        ::tsp::addError compUnit "wrong # args: should be \"upvar ?level? othervar localVar ?otherVar localVar?\""
        return [list void "" ""]
    }
    
    if {$len % 2 == 0} {
        # contains level option
        set levelComponent [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
        lassign $levelComponent type rawtext text
        if {$type ne "text" || ![regexp {(#)?\d+} $text]} {
            ::tsp::addError compUnit "can't parse \"upvar ?level?\" as valid level specifier"
            return [list void "" ""]
        }
        set idx 2
    } else {
        set idx 1
    }

    append code "\n/***** ::tsp::gen_command_upvar */\n"

    # generate the code to call the command
    set directResult [::tsp::gen_direct_tcl compUnit $tree]
    append code [lindex $directResult 2]
    
    set upvared [list]

    # check that local variables are defined, if not define them as var
    # generate code to get vars from interp after the real upvar command code

    foreach {otherVarComponent localVarComponent} [lrange $tree $idx end] {
        lassign [lindex [::tsp::parse_word compUnit $otherVarComponent] 0] typeOther rawOther otherVar 
        lassign [lindex [::tsp::parse_word compUnit $localVarComponent] 0] typeLocal rawLocal localVar
        if {$typeLocal ne "text"} {
            ::tsp::addError compUnit "upvar local \"$rawLocal\" not a text var name"
            return [list void "" ""]
        }
        set type [::tsp::getVarType compUnit $localVar]
        if {$type eq "undefined"} {
            if {! [::tsp::isValidIdent $localVar]} {
                ::tsp::addError compUnit "upvar local variable \"$localVar\" not defined, and not a valid identifier"
                return [list void "" ""]
            }
            ::tsp::addWarning compUnit "variable \"${localVar}\" implicitly defined as type: \"var\""
            ::tsp::setVarType compUnit $localVar var
            set type var
        }
        lappend upvared $localVar
    }

    if {[llength $upvared] > 0} {
        append code "\n/**** load upvared: $upvared */\n"
        append code [::tsp::lang_load_vars compUnit $upvared]
    }

    # add upvared variables to the finalSpill
    set existing [dict get $compUnit finalSpill]
    foreach var $upvared {
        if {[lsearch $existing $var] == -1} {
            dict lappend compUnit finalSpill $var
        }
    }

    return [list void "" $code]
}




#########################################################
# generate code for "global" command (assumed to be first parse word)
# pick out variables that will need to be loaded on proc entry, and
# spilled on proc exit.  actual global command is passed to ::tsp::gen_direct_tcl
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_global {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set len [llength $tree]
    if {$len < 2} {
        ::tsp::addError compUnit "wrong # args: should be \"global varName ?varName?\""
        return [list void "" ""]
    }
    
    append code "\n/***** ::tsp::gen_command_global */\n"

    # generate the code to call the command
    set directResult [::tsp::gen_direct_tcl compUnit $tree]
    append code [lindex $directResult 2]
    
    set upvared [list]

    # check that local variables are defined, if not define them as var
    # generate code to get vars from interp after the real global command code

    foreach {localVarComponent} [lrange $tree 1 end] {
        lassign [lindex [::tsp::parse_word compUnit $localVarComponent] 0] typeLocal rawLocal localVar
        if {$typeLocal ne "text"} {
            ::tsp::addError compUnit "global \"$rawLocal\" not a text var name"
            return [list void "" ""]
        }
        set type [::tsp::getVarType compUnit $localVar]
        if {$type eq "undefined"} {
            if {! [::tsp::isValidIdent $localVar]} {
                ::tsp::addError compUnit "global variable \"$localVar\" not defined, and not a valid identifier"
                return [list void "" ""]
            }
            ::tsp::addWarning compUnit "variable \"${localVar}\" implicitly defined as type: \"var\""
            ::tsp::setVarType compUnit $localVar var
            set type var
        }
        lappend upvared $localVar
    }

    if {[llength $upvared] > 0} {
        append code "\n/* load global: $upvared */\n"
        append code [::tsp::lang_load_vars compUnit $upvared]
    }

    # add upvared variables to the finalSpill
    set existing [dict get $compUnit finalSpill]
    foreach var $upvared {
        if {[lsearch $existing $var] == -1} {
            dict lappend compUnit finalSpill $var
        }
    }

    return [list void "" $code]
}



#########################################################
# generate code for "variable" command (assumed to be first parse word)
# pick out variables that will need to be loaded on proc entry, and
# spilled on proc exit.  actual variable command is passed to ::tsp::gen_direct_tcl
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_variable {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set len [llength $tree]
    if {$len < 2} {
        ::tsp::addError compUnit "wrong # args: should be \"variable ?name value? name ?value?\""
        return [list void "" ""]
    }
    
    append code "\n/***** ::tsp::gen_command_variable */\n"

    # generate the code to call the command
    set directResult [::tsp::gen_direct_tcl compUnit $tree]
    append code [lindex $directResult 2]
    
    set upvared [list]

    # check that local variables are defined, if not define them as var
    # generate code to get vars from interp after the real variable command code

    foreach {localVarComponent valueComponent} [lrange $tree 1 end] {
        lassign [lindex [::tsp::parse_word compUnit $localVarComponent] 0] typeLocal rawLocal localVar
        if {$typeLocal ne "text"} {
            ::tsp::addError compUnit "variable local \"$rawLocal\" not a text var name"
            return [list void "" ""]
        }
        set type [::tsp::getVarType compUnit $localVar]
        if {$type eq "undefined"} {
            if {! [::tsp::isValidIdent $localVar]} {
                ::tsp::addError compUnit "variable local variable \"$localVar\" not defined, and not a valid identifier"
                return [list void "" ""]
            }
            ::tsp::addWarning compUnit "variable \"${localVar}\" implicitly defined as type: \"var\""
            ::tsp::setVarType compUnit $localVar var
            set type var
        }
        lappend upvared $localVar
    }

    if {[llength $upvared] > 0} {
        append code "\n/**** load variable: $upvared */\n"
        append code [::tsp::lang_load_vars compUnit $upvared]
    }

    # add upvared variables to the finalSpill
    set existing [dict get $compUnit finalSpill]
    foreach var $upvared {
        if {[lsearch $existing $var] == -1} {
            dict lappend compUnit finalSpill $var
        }
    }

    return [list void "" $code]
}



