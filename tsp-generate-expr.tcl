

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
    set code "$tmpVar = $exprCode ;"
    return [list $type $tmpVar $code]
}


