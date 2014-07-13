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

    # make sure all expressions and scripts are braced
    set i 1
    for {set i 1] {$i < $argMax} {incr i} {
        set argComponent [lindex [::tsp::parse_word compUnit [lindex $tree $i]] 0]
    }

    set argMax [llength $tree]
    set thenSeen 0
    set elseSeen 0
    
    # expect condition script 
    while {$next < $argMax} {
        set exprComponent [lindex [::tsp::parse_word compUnit [lindex $tree 1]] 0]
    }

}
