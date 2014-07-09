
#########################################################
# parse the next script body, may recurse for if, while, for, foreach, etc.
# return generated code 

proc ::tsp::parse_body {compUnitDict range} {
    upvar $compUnitDict compUnit

    set body [dict get $compUnit body]
    set gencode ""

    lassign $range firstIdx lastIdx
    if {$lastIdx eq "end"} {
        set lastIdx [string length $body]
    }

    while {$lastIdx > 0} {
        # reset volatile list, if any
        dict set compUnit volatile [list]

        # parse the next comments and command
        set parseResults [parse command $body $range]
        lassign $parseResults commentRange commandRange restRange tree
        
        # process comments for tsp pragmas
        lassign $commentRange commentFirst commentLast
        if {$commentLast > 0} {
            set toRange [list 0 $commentFirst]
            set lines [parse getstring $body $toRange]
            set lineNum [regexp -all \n $lines]
            dict set compUnit lineNum $lineNum

            set comment [parse getstring $body $commentRange]
            ::tsp::parse_pragma compUnit $comment
        }
        
        # process the command
        lassign $commandRange commandFirst commandLast

        if {$commandLast > 0} {

            # get line number in procedure
            set toRange [list 0 $commandFirst]
            set lines [parse getstring $body $toRange]
            set lineNum [regexp -all \n $lines]
            dict set compUnit lineNum $lineNum

            # append the tcl command that we're compiling
            append gencode [::tsp::source_comments compUnit $commandRange]

            # check if we can compile
            # first node must be a simple text word or scalar variable
            set firstNode [lindex $tree 0]
            set firstWordList [::tsp::parse_word compUnit $firstNode]
            lassign $firstNode firstNodeType firstNodeRange firstNodeSubtree
            set word [parse getstring $body $firstNodeRange]
            set cmdCode ""
            if {[llength $firstWordList] == 1} {
                set wordComponent [lindex $firstWordList 0]
                set type [lindex $wordComponent 0]
                if {$type eq "text" || $type eq "scalar"} {
                    lassign [::tsp::gen_command compUnit $tree] cmdType cmdRhsVar cmdCode
                } else {
                    ::tsp::addError compUnit "command is not a simple word or scalar: $word"
                }
            } else {
                ::tsp::addError compUnit "command is not a simple word or scalar: $word"
            }
            
            # if tsp::volatile pragma found, or command added variables as volatile, 
            # spill variables into tcl interp before command
            set volatile [lsort -unique [dict get $compUnit volatile]]
            set volatileLen [llength $volatile]
            if {$volatileLen > 0} {
                append gencode [::tsp::gen_spill_vars compUnit $volatile]
            }

            # generated command code
            append gencode $cmdCode

            # reload volatile variables that were spilled into tcl
            if {$volatileLen > 0} {
                append gencode [::tsp::gen_reload_vars compUnit $volatile]
            }
        }

        # continue parsing
        set range $restRange
	lassign $range firstIdx lastIdx
    }

    # if any errors, return null string, else return the generated code
    if {[llength [::tsp::getErrors compUnit]] > 0}  {
        return ""
    } else {
        return $gencode
    }
}

#########################################################
#  source_comments - take lines of proc comments or commands
#  and make into native comments
#
proc ::tsp::source_comments {compUnitDict range} {
    upvar $compUnitDict compUnit
    set text [parse getstring [dict get $compUnit body] $range]
    set name [dict get $compUnit name]
    set line [dict get $compUnit lineNum]
    regsub -all "\n|\r|\t"  $text " " text
    regsub -all \\*/     $text "* /" text
    return "\n/******** $name $line: [string trim $text] */\n"
}

#########################################################
# parse a word, allowed are:
# {text}
# "text" or {text}
# "text $var"
# "text $arr(idx)"
# [command args]
# subtree should be a tree of {word range subtree}
# return a list of word components:
# {text string unquotedstring} 
# {backslash char} 
# {scalar var}
# {command script}
# {array_idxtext arr idx} 
# {array_idxvar arr var} 
# {text_array_idxtext arr idx string}
# {text_array_idxvar arr var string}
# or {invalid msg}
#
# see isArrayText below for transformation of text arrname name into:
# {text_array_idxtext arr idx string} {text_array_idxvar arr var string}

proc ::tsp::parse_word {compUnitDict subtree {check_array 1}} {
    upvar $compUnitDict compUnit
    set result [list]

    set body [dict get $compUnit body]

    lassign $subtree type idx subtree 
    set wordStr [parse getstring $body $idx]
    if {$type eq "simple"} {
        set textIdx [lindex [lindex $subtree 0] 1]
        set unquotedStr [parse getstring $body $textIdx]
        if {$check_array} {
            return [::tsp::isArrayText [list [list text $wordStr $unquotedStr]] $unquotedStr]
        } else {
            return [list [list text $wordStr $unquotedStr]]
        }
    } elseif {$type eq "command"} {
        return [list command [::tsp::trimCommand $wordStr]]
    } elseif {$type ne "word"} {
        return [list invalid "unknown node $type"]
    }
    foreach node $subtree {
        lassign $node nodetype nodeidx nodesubtree
        if {$nodetype eq "text"} {
            set text [parse getstring $body $nodeidx]
            set unquotedStr [parse getstring $body $nodeidx]
            lappend result [list text $text $unquotedStr]
        } elseif {$nodetype eq "backslash"} {
            set text [parse getstring $body $nodeidx]
            lappend result [list backslash $text]
        } elseif {$nodetype eq "variable"} {
            set var [::tsp::parse_var compUnit $node]
            set varResult [lindex $var 0]
            if {$varResult eq "invalid"} {
                return [list invalid "parse_var error: $var"]
            } else {
                lappend result $var
            }
        } elseif {$nodetype eq "command"} {
            lappend result [list command [::tsp::trimCommand [parse getstring $body $nodeidx]]]
        } else {
            return [list invalid "unknown node $nodetype"]
        }
    }

    if {$check_array} {
        return [::tsp::isArrayText $result $wordStr]
    } else {
        return $result
    }
}


#########################################################
# trim [ and ] from a command string
proc ::tsp::trimCommand {str} {
    set str [string trim $str]
    if {[string range $str 0 0] eq {[}} {
        set str [string range $str 1 end]
    }
    if {[string range $str end end] eq {]}} {
        set str [string range $str 0 end-1]
    }
    return $str
}

#########################################################
# isArrayText
# check if text parse_word componet result list can be an 
# array name (e.g. target of a 'set')
# arr()     array with null index
# arr(foo)  array with text index
# arr($bar) array with variable index
# return {text_array_idxtext arr idx str} {text_array_idxvar arr var str}  or
# original componentList if not an array target
proc ::tsp::isArrayText {componentList str} {
    set firstComponent [lindex $componentList 0]
    set firstType [lindex $firstComponent 0]
    if {$firstType eq "text"} {
        # prefix string with a dollar sign, and parse again
        set testStr \$$str 
        set dummyUnit [::tsp::init_compunit dummy dummy dummy $testStr]
        set rc [catch {lassign [parse command $testStr {0 end}] x x x subtree}]
        if {$rc == 0} {
            # parse successful, now parse into components
            set result [::tsp::parse_word dummyUnit [lindex $subtree 0] 0]
            set numComponents [llength $result]
            set firstResult [lindex $result 0]
            set arg1 ""
            set arg2 ""
            lassign $firstResult type arg1 arg2
            if {$numComponents == 1 && ($type eq "array_idxtext" || $type eq "array_idxvar")} {
                # it's an array, change it to a text_array_idx... type
                set type "text_$type"
                return [list $type $arg1 $arg2 $str] 
            } else {
                # not an array var 
                return $componentList
            }
        } else {
            return $componentList
        }
    } else {
        return $componentList
    }
}



#########################################################
# parse a variable tree, allowed are:
#  $var
#  $arr(idx)
#  $arr($idx)
#  subtree should be a tree of {variable range subtree}
#  return {scalar var} or {array_idxtext arrayname string} or {array_idxvar arrayname varname} or invalid
proc ::tsp::parse_var {compUnitDict subtree} {
    upvar $compUnitDict compUnit

    set body [dict get $compUnit body]

    lassign $subtree type idx subtree 
    if {$type ne "variable"} {
        return [list invalid "not a variable subtree, was $type"]
    }
    set varlen [llength $subtree]
    if {$varlen == 1} {
        lassign [lindex $subtree 0] type idx null 
        set varname [parse getstring $body $idx]
        set isValid [::tsp::isValidIdent $varname]
        if {! $isValid} {
            return [list invalid "var $varname is not a valid identifier"]
        }
        return [list scalar $varname]
    } elseif {$varlen == 2} {
        lassign $subtree arrtree idxtree
        lassign $arrtree arrtype arridx arrtree
        if {$arrtype ne "text"} {
            return [list invalid "array has complex index"]
        }
        set arrname [parse getstring $body $arridx]
        set isValid [::tsp::isValidIdent $arrname]
        if {! $isValid} {
            return [list invalid "array $arrname is not a valid identifier"]
        }
        lassign $idxtree idxtype idxidx idxtree
        if {$idxtype eq "text"} {
            set idxtext [parse getstring $body $idxidx]
            return [list array_idxtext  $arrname $idxtext]
        } elseif {$idxtype eq "variable" && [lindex [lindex $idxtree 0] 0] eq "text"} {
            set idxidx [lindex [lindex $idxtree 0] 1]
            set idxvar [parse getstring $body $idxidx]
            set isValid [::tsp::isValidIdent $idxvar]
            if {! $isValid} {
                return [list invalid "array index variable $idxvar is not a valid identifier"]
            }
            return [list array_idxvar $arrname $idxvar]
        } else {
            # FIXME - perhaps support complex indices sometime, e.g. $arry($var1,$var2)
            return [list invalid "array has complex index"]
        }
    } else {
        # FIXME - perhaps support complex indices sometime, e.g. $arry($var1,$var2)
        return [list invalid "array has complex index"]
    }
}


#########################################################
# parse a command that we can compile, either a standalone command, or as
# a argument to "set"
# cmd arg $arg ....
# $cmd arg arg ....
# where cmd is simple text or a scalar var
# where arg is not a nested command
proc ::tsp::parse_command {compUnitDict tree} {
    upvar $compUnitDict compUnit

    set wordNum 0
    set result [list]

    foreach subtree $tree {
        incr wordNum
        set wordResult [::tsp::parse_word compUnit $subtree]
        set wordType [lindex [lindex $wordResult 0] 0]
        if {$wordNum == 1} {
            if {($wordType ne "text" && $wordType ne "scalar") || [llength $wordResult] > 1} {
	        return [list invalid "command is not simple text or scalar variable: $wordResult"]
            }
        }
        foreach wordElement $wordResult {
            set wordType [lindex [lindex $wordElement 0] 0]
            if {$wordType eq "invalid" || $wordType eq "command"} {
	        return [list invalid "arg $wordNum invalid word: $wordResult"]
            }
        }
        lappend result $wordResult
    }
    return $result
}



#########################################################
# examine a list returned from parse_word, see if anything is invalid
proc ::tsp::isComplex {parseList} {
    set num 0
    foreach elem $parseList {
        incr num
        set type [lindex $elem 0]
        if {$type eq "invalid" || $type eq "array_idxtext" || $type eq "array_idxvar" || $type eq "command"} {
            return $num
        }
    }
    return 0
}


