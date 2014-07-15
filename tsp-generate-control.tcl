#  compiled control commands:
#  for, while, foreach, if, break, continue, return, switch, case


#########################################################
# generate code for "for" command (assumed to be first parse word)
# only braced arguments are generated, anything else generates an error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_for {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] != 5} {
        ::tsp::addError compUnit "wrong # args: should be \"for start test next command\""
        return [list void "" ""]
    }

    set preComponent  [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
    set exprComponent [lindex [::tsp::parse_word compUnit [lindex $tree 2]] 0]
    set postComponent [lindex [::tsp::parse_word compUnit [lindex $tree 3]] 0]
    set bodyComponent [lindex [::tsp::parse_word compUnit [lindex $tree 4]] 0]

    
    lassign $preComponent type rawtext pretext
    if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
        ::tsp::addError compUnit "start code argument not a braced word"
        return [list void "" ""]
    }

    lassign $exprComponent type rawtext exprtext
    if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
        ::tsp::addError compUnit "test expr argument not a braced expression"
        return [list void "" ""]
    }

    lassign $postComponent type rawtext posttext
    if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
        ::tsp::addError compUnit "next code argument not a braced word"
        return [list void "" ""]
    }

    lassign $bodyComponent type rawtext bodytext
    if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
        ::tsp::addError compUnit "body code argument not a braced word"
        return [list void "" ""]
    }

    set rc [catch {set exprTypeCode [::tsp::compileBooleanExpr compUnit $exprtext]} result]
    if {$rc != 0} {
        ::tsp::addError compUnit "couldn't parse expr: \"$exprtext\", $result"
        return [list void "" ""]
    }
    
    lassign $exprTypeCode type exprCode

    set preRange [lindex [lindex $tree 1] 1]
    lassign $preRange start end
    incr start
    incr end -2
    set preRange [list $start $end]
    set preCode [::tsp::parse_body compUnit $preRange]

    set postRange [lindex [lindex $tree 3] 1]
    lassign $postRange start end
    incr start
    incr end -2
    set postRange [list $start $end]
    set postCode [::tsp::parse_body compUnit $postRange]

    set bodyRange [lindex [lindex $tree 4] 1]
    lassign $bodyRange start end
    incr start
    incr end -2
    set bodyRange [list $start $end]
    ::tsp::incrDepth compUnit
    set bodyCode [::tsp::parse_body compUnit $bodyRange]
    append code $preCode
    append code "\n"
    append code "while ( " $exprCode " ) {\n"
    append code [::tsp::indent compUnit $bodyCode]
    append code "\n"
    append code [::tsp::indent compUnit $postCode]
    append code "\n}\n"
    ::tsp::incrDepth compUnit -1

    return [list void "" $code]
}




#########################################################
# generate code for "while" command (assumed to be first parse word)
# only braced arguments are generated, anything else generates an error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_while {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] != 3} {
        ::tsp::addError compUnit "wrong # args: should be \"while test command\""
        return [list void "" ""]
    }

    # get expr component, make sure it is braced
    set exprComponent [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
    lassign $exprComponent type rawtext exprtext
    if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
        ::tsp::addError compUnit "expr argument not a braced expression"
        return [list void "" ""]
    }

    set rc [catch {set exprTypeCode [::tsp::compileBooleanExpr compUnit $exprtext]} result]
    if {$rc != 0} {
        ::tsp::addError compUnit "couldn't parse expr: \"$exprtext\", $result"
        return [list void "" ""]
    }
    
    lassign $exprTypeCode type exprCode

    # get body component make sure it is braced
    set bodyComponent [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
    lassign $bodyComponent type rawtext bodytext
    if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
        ::tsp::addError compUnit "body argument not a braced expression"
        return [list void "" ""]
    }

    set bodyRange [lindex [lindex $tree 2] 1]
    lassign $bodyRange start end
    incr start
    incr end -2
    set bodyRange [list $start $end]
    ::tsp::incrDepth compUnit
    set bodyCode [::tsp::parse_body compUnit $bodyRange]
    append code "while ( " $exprCode " ) {\n"
    append code [::tsp::indent compUnit $bodyCode]
    append code "\n}\n"
    ::tsp::incrDepth compUnit -1
    return [list void "" $code]
}



#########################################################
# generate code for "if" command (assumed to be first parse word)
# only braced arguments are generated, anything else generates an error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_if {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 3} {
        ::tsp::addError compUnit "wrong # args: should be \"if expression script ...\""
        return [list void "" ""]
    }

    set argMax [llength $tree]
    append code "if ( "
    
    set i 1
    # expect "condition"  "script" 
    while {$i < $argMax} {

        # get the condition
        set nextComponent [lindex [::tsp::parse_word compUnit [lindex $tree $i]] 0]
        lassign $nextComponent type rawtext text
        if {$type ne "text"} {
            ::tsp::addError compUnit "unexpected \"if\" argument: \"[string trim [string range $rawtext 0 30]]\""
            return [list void "" ""]
        }
        if {[string range $rawtext 0 0] ne "\{"} {
            ::tsp::addError compUnit "unbraced \"if\" argument: \"[string trim [string range $rawtext 0 30]]\""
            return [list void "" ""]
        }
        # compile the expression
        set rc [catch {set exprTypeCode [::tsp::compileBooleanExpr compUnit $text]} result]
        if {$rc != 0} {
            ::tsp::addError compUnit "couldn't parse expr: \"$exprtext\", $result"
            return [list void "" ""]
        }
        lassign $exprTypeCode type exprCode
        append code $exprCode " ) \{\n"
        

        # get the script, passing over optional "then"
        incr i
        if {$i == $argMax} {
            ::tsp::addError compUnit "no script after \"if\" condition"
            return [list void "" ""]
        }
        set nextComponent [lindex [::tsp::parse_word compUnit [lindex $tree $i]] 0]
        lassign $nextComponent type rawtext text
        if {$type eq "text" && $text eq "then"} {
            incr i
            if {$i == $argMax} {
                ::tsp::addError compUnit "no script after \"if\" then"
                return [list void "" ""]
            }
            set nextComponent [lindex [::tsp::parse_word compUnit [lindex $tree $i]] 0]
            lassign $nextComponent type rawtext text
        }
        if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
            ::tsp::addError compUnit "unbraced \"if\" argument: \"[string trim [string range $rawtext 0 30]]\""
            return [list void "" ""]
        } 
        set bodyRange [lindex [lindex $tree $i] 1]
        lassign $bodyRange start end
        incr start
        incr end -2
        set bodyRange [list $start $end]
        set bodyCode [::tsp::parse_body compUnit $bodyRange]
        append code [::tsp::indent compUnit $bodyCode 1]
        append code "\n\}"
        

        # set up loop for "elseif" if any, or break 
        # on implied "?else? script" or last arg.
        incr i
        if {$i == ($argMax - 1)} {
            break
        }
        set nextComponent [lindex [::tsp::parse_word compUnit [lindex $tree $i]] 0]
        lassign $nextComponent type rawtext text
        if {$type eq "text" && $text eq "elseif"} {
            incr i
            if {$i >= ($argMax - 1)} {
                ::tsp::addError compUnit "\"elseif\" missing condition and/or script arguments"
                return [list void "" ""]
            }
            append code " else if ( "
            continue
        } else {
            break
        }
    }

    # process "else" script, if any
    if {$i < $argMax} {
        set nextComponent [lindex [::tsp::parse_word compUnit [lindex $tree $i]] 0]
        lassign $nextComponent type rawtext text
        if {$type eq "text" && $text eq "else"} {
            incr i
            if {$i == $argMax} {
                ::tsp::addError compUnit "no script after \"if\" else"
                return [list void "" ""]
            }
            set nextComponent [lindex [::tsp::parse_word compUnit [lindex $tree $i]] 0]
            lassign $nextComponent type rawtext text
        }
        if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
            ::tsp::addError compUnit "unbraced \"if\" argument: \"[string trim [string range $rawtext 0 30]]\""
            return [list void "" ""]
        } 
        append code " else \{\n"
        set bodyRange [lindex [lindex $tree $i] 1]
        lassign $bodyRange start end
        incr start
        incr end -2
        set bodyRange [list $start $end]
        set bodyCode [::tsp::parse_body compUnit $bodyRange]
        append code [::tsp::indent compUnit $bodyCode 1]
        append code "\n\}"
        incr i
    } 
    append code \n

    # should have used up all arguments by now.....
    if {$i < $argMax} { 
        ::tsp::addError compUnit "extra arguments after \"else\" argument"
        return [list void "" ""]
    }

    return [list void "" $code]
}



#########################################################
# generate code for "break" command (assumed to be first parse word)
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_break {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] > 1} {
        ::tsp::addError compUnit "wrong # args: should be \"break\""
        return [list void "" ""]
    }

    # make sure we are in a loop, as indicated by 'depth'
    if {[dict get $compUnit depth] < 1} {
        ::tsp::addError compUnit "\"break\" used outside of loop"
        return [list void "" ""]
    }
    return [list void "" "\nbreak;\n"]
}


#########################################################
# generate code for "continue" command (assumed to be first parse word)
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_continue {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] > 1} {
        ::tsp::addError compUnit "wrong # args: should be \"continue\""
        return [list void "" ""]
    }

    # make sure we are in a loop, as indicated by 'depth'
    if {[dict get $compUnit depth] < 1} {
        ::tsp::addError compUnit "\"continue\" used outside of loop"
        return [list void "" ""]
    }
    return [list void "" "\ncontinue;\n"]
}


#########################################################
# generate code for "return" command (assumed to be first parse word)
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_return {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set returnType [dict get $compUnit returns]

    if {$returnType eq "void"} {
        if {[llength $tree] > 1} {
            ::tsp::addError compUnit "wrong # args: proc return type declared as \"$returnType\", but \"return\" has arguments"
            return [list void "" ""]
        }
        return [list void "" \nreturn;\n"]
    }

    if {[llength $tree] != 2} {
        ::tsp::addError compUnit "wrong # args: proc return type declared as \"$returnType\", \"return\" requires exactly one argument"
        return [list void "" ""]
    }

    #FIXME: should probably check for proper return type, literal or variable, and
    #       not try to always assign into a temp var
    set body [dict get $compUnit body]
    set node [lindex $tree 1]
    set argrange [lindex $node 1]
    lassign $argrange start end
    set end [expr {$start + $end - 1}]
    set argtext [string range $body $start $end]
    set argVar [::tsp::get_tmpvar compUnit $returnType]
    set setBody "set $argVar $argtext"
    set dummyUnit [::tsp::init_compunit dummy dummy "" $setBody]
    lassign [parse command $setBody {0 end}] x x x setTree
    ::tsp::copyVars compUnit dummyUnit
    set argCode [::tsp::gen_command_set dummyUnit $setTree]
    set code [lindex $argCode 2]
    # vi return arg is a var, preserve it from being disposed/freed in this method/function
    if {$returnType eq "var"} {
        append code [::tsp::lang_preserve $argVar]\n
    }
    return [list void "" "\n${code}return $argVar;\n"]
}


#foreach
#switch
#case
