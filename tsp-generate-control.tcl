#  compiled control commands:
#  for, while, foreach, if


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
    set bodyCode [::tsp::parse_body compUnit $bodyRange]

    append code $preCode
    append code "\n"
    append code "while ( " $exprCode " ) {\n"
    ::tsp::incrIndent compUnit
    append code [::tsp::indent compUnit $bodyCode]
    append code "\n"
    append code [::tsp::indent compUnit $postCode]
    ::tsp::incrIndent compUnit -1
    append code "\n}\n"

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
    set bodyCode [::tsp::parse_body compUnit $bodyRange]

    append code "while ( " $exprCode " ) {\n"
    ::tsp::incrIndent compUnit
    append code [::tsp::indent compUnit $bodyCode]
    ::tsp::incrIndent compUnit -1
    append code "\n}\n"
    return [list void "" $code]
}



#########################################################
# generate code for "if" command (assumed to be first parse word)
# only braced arguments are generated, anything else generates an error
# return list of: type rhsVarName code
#
proc ::tsp::gen_command_while {compUnitDict tree} {
    upvar $compUnitDict compUnit

    if {[llength $tree] < 3} {
        ::tsp::addError compUnit "wrong # args: should be \"if expression script ...\""
        return [list void "" ""]
    }


    set argMax [llength $tree]
    set thenSeen 0
    set elseSeen 0

    append code "if ( \n"
    
    set i 1
    # expect "condition"  "script" 
    while {$next < $argMax} {

        # get the condition
        set nextComponent [lindex [::tsp::parse_word compUnit [lindex $tree $i]] 0]
        lassign $nextComponent type rawtext text
        if {$type ne "text"} {
            ::tsp::addError compUnit "unexpected \"if\" argument: \"[string trim [string range $text 0 30]]\""
            return [list void "" ""]
        }
        if {[string range $text 0 0] ne "\{"} {
            ::tsp::addError compUnit "unbraced \"if\" argument: \"[string trim [string range $text 0 30]]\""
            return [list void "" ""]
        }
        # compile the expression
        set rc [catch {set exprTypeCode [::tsp::compileBooleanExpr compUnit $text]} result]
        if {$rc != 0} {
            ::tsp::addError compUnit "couldn't parse expr: \"$exprtext\", $result"
            return [list void "" ""]
        }
        lassign $exprTypeCode type exprCode
        append code $exprCode " ) \{\n\n"
        

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
            ::tsp::addError compUnit "unbraced \"if\" argument: \"[string trim [string range $text 0 30]]\""
            return [list void "" ""]
        } 
        set bodyRange [lindex [lindex $tree $i] 1]
        lassign $bodyRange start end
        incr start
        incr end -2
        set bodyRange [list $start $end]
        set bodyCode [::tsp::parse_body compUnit $bodyRange]
        ::tsp::incrIndent compUnit
        append code [::tsp::indent compUnit $bodyCode]
        ::tsp::incrIndent compUnit -1
        append code "\n\n\}"
        

        # set up for "elseif", or break on "else" or last arg.
        incr i
        if {$i = $argMax} {
            break
        }
        set nextComponent [lindex [::tsp::parse_word compUnit [lindex $tree $i]] 0]
        lassign $nextComponent type rawtext text
        if {$type eq "text" && $text eq "elseif"} {
            incr i
            if {$i >= ($argMax - 2)} {
                ::tsp::addError compUnit "\"elseif\" missing condition and/or script arguments"
                return [list void "" ""]
            }
            append " else if ( "
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
                ::tsp::addError compUnit "no script after \"if\" then"
                return [list void "" ""]
            }
            set nextComponent [lindex [::tsp::parse_word compUnit [lindex $tree $i]] 0]
            lassign $nextComponent type rawtext text
        }
        if {$type ne "text" || [string range $rawtext 0 0] ne "\{"} {
            ::tsp::addError compUnit "unbraced \"if\" argument: \"[string trim [string range $text 0 30]]\""
            return [list void "" ""]
        } 
        append code " else \{\n\n"
        set bodyRange [lindex [lindex $tree $i] 1]
        lassign $bodyRange start end
        incr start
        incr end -2
        set bodyRange [list $start $end]
        set bodyCode [::tsp::parse_body compUnit $bodyRange]
        ::tsp::incrIndent compUnit
        append code [::tsp::indent compUnit $bodyCode]
        ::tsp::incrIndent compUnit -1
        append code "\n\n\}\n"
    } 
    append code \n

    # should have used up all arguments by now.....
    if {$i < $argMax} { 
        ::tsp::addError compUnit "extra arguments after \"else\" argument"
        return [list void "" ""]
    }

    return [list void "" $code]
}






#foreach
#switch
#case
