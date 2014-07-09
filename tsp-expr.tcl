
namespace eval ::tsp {

    if {$::tcl_platform(platform) eq "java"} {

        variable PLATFORM                java

        variable tclfunc_int_div         TclFunc.IntDiv
        variable tclfunc_int_mod         TclFunc.IntMod
        variable tclfunc_double_div      TclFunc.DoubleDiv
        variable tclfunc_str_lt          TclFunc.StringLt
        variable tclfunc_str_gt          TclFunc.StringGt
        variable tclfunc_str_le          TclFunc.StringLe
        variable tclfunc_str_ge          TclFunc.StringGe
        variable tclfunc_str_eq          TclFunc.StringEq
        variable tclfunc_str_ne          TclFunc.StringNe

        variable tclfunc_int_abs         TclFunc.IntAbs
        variable tclfunc_double_abs      TclFunc.DoubleAbs
        variable tclfunc_acos            TclFunc.Acos
        variable tclfunc_asin            TclFunc.Asin
        variable tclfunc_atan            TclFunc.Atan 
        variable tclfunc_atan2           TclFunc.Atan2
        variable tclfunc_ceil            TclFunc.Ceil
        variable tclfunc_cos             TclFunc.Cos
        variable tclfunc_cosh            TclFunc.Cosh
        variable tclfunc_exp             TclFunc.Exp
        variable tclfunc_floor           TclFunc.Floor
        variable tclfunc_fmod            TclFunc.Fmod
        variable tclfunc_hypot           TclFunc.Hypot
        variable tclfunc_log             TclFunc.Log
        variable tclfunc_log10           TclFunc.Log10
        variable tclfunc_double_pow      TclFunc.DoublePow
        variable tclfunc_double_int_pow  TclFunc.DoubleIntPow
        variable tclfunc_rand            TclFunc.Rand
        variable tclfunc_round           TclFunc.Round
        variable tclfunc_sin             TclFunc.Sin 
        variable tclfunc_sinh            TclFunc.Sinh
        variable tclfunc_sqrt            TclFunc.Sqrt
        variable tclfunc_int_srand       TclFunc.IntSrand
        variable tclfunc_tan             TclFunc.Tan
        variable tclfunc_tanh            TclFunc.Tanh

        variable VALUE_TRUE              true
        variable VALUE_FALSE             false

        variable INT_TYPE                long

    } else {

        variable PLATFORM                c

        variable tclfunc_int_div         TSP_tclfunc_int_div
        variable tclfunc_int_mod         TSP_tclfunc_int_mod
        variable tclfunc_double_div      TSP_tclfunc_double_div
        variable tclfunc_str_lt          TSP_tclfunc_str_lt
        variable tclfunc_str_gt          TSP_tclfunc_str_gt
        variable tclfunc_str_le          TSP_tclfunc_str_le
        variable tclfunc_str_ge          TSP_tclfunc_str_ge
        variable tclfunc_str_eq          TSP_tclfunc_str_eq
        variable tclfunc_str_ne          TSP_tclfunc_str_ne

        variable tclfunc_int_abs         TSP_tclfunc_int_abs
        variable tclfunc_double_abs      TSP_tclfunc_double_abs
        variable tclfunc_acos            TSP_tclfunc_acos
        variable tclfunc_asin            TSP_tclfunc_asin
        variable tclfunc_atan            TSP_tclfunc_atan 
        variable tclfunc_atan2           TSP_tclfunc_atan2
        variable tclfunc_ceil            TSP_tclfunc_ceil
        variable tclfunc_cos             TSP_tclfunc_cos
        variable tclfunc_cosh            TSP_tclfunc_cosh
        variable tclfunc_exp             TSP_tclfunc_exp
        variable tclfunc_floor           TSP_tclfunc_floor
        variable tclfunc_fmod            TSP_tclfunc_fmod
        variable tclfunc_hypot           TSP_tclfunc_hypot
        variable tclfunc_log             TSP_tclfunc_log
        variable tclfunc_log10           TSP_tclfunc_log10
        variable tclfunc_double_pow      TSP_tclfunc_double_pow
        variable tclfunc_double_int_pow  TSP_tclfunc_double_int_pow
        variable tclfunc_rand            TSP_tclfunc_rand
        variable tclfunc_round           TSP_tclfunc_round
        variable tclfunc_sin             TSP_tclfunc_sin 
        variable tclfunc_sinh            TSP_tclfunc_sinh
        variable tclfunc_sqrt            TSP_tclfunc_sqrt
        variable tclfunc_int_srand       TSP_tclfunc_int_srand
        variable tclfunc_tan             TSP_tclfunc_tan
        variable tclfunc_tanh            TSP_tclfunc_tanh

        variable VALUE_TRUE              1
        variable VALUE_FALSE             0

        variable INT_TYPE                TCL_WIDE_INT_TYPE

    }

    variable EXPR_TYPES [list boolean int double string stringliteral]

    variable UNARY_OPS [list  ~ ! ]
    variable UNARY_OR_BINARY_OPS [list - +  ]
    variable BINARY_OPS [list * / % + - << >> < > <= >= == != ^ | && || eq ne]
    variable TERNARY_OPS ?
    variable STRING_OPS  [list < > <= >= == != eq ne]
    variable  OP_STRING_XLATE
    array set OP_STRING_XLATE [list  < $tclfunc_str_lt    > $tclfunc_str_gt  <= $tclfunc_str_le  >= $tclfunc_str_ge   \
				    == $tclfunc_str_eq   != $tclfunc_str_ne  eq $tclfunc_str_eq  ne $tclfunc_str_ne ]

    variable OP_BOOLEAN_RESULT [list < > <= >= == != && || ]
    variable OP_INT_RESULT     [list ~ % << >> & ^ | ]
    variable OP_INT_OPERANDS   [list   % << >> & ^ | ]
    variable OP_BOOLEAN_OPERANDS [list && || ]

    variable FUNC_0ARGS [list rand ]
    variable FUNC_1ARG  [list abs acos asin atan ceil cos cosh double exp floor int log log10 round sin sinh sqrt srand tan tanh wide ]
    variable FUNC_2ARGS [list atan2 fmod hypot pow ] 

    variable ALL_FUNCS [concat $FUNC_0ARGS $FUNC_1ARG $FUNC_2ARGS]

    variable FUNC_INT_RESULT     [list int round wide ]
    variable FUNC_DOUBLE_RESULT  [list acos asin atan atan2 ceil cos cosh double exp floor fmod hypot log log10 pow rand sin sinh sqrt srand tan tanh ]
    variable FUNC_SAME_RESULT    [list abs ]

    # note: special handling for abs(int) vs abs(double)
    # note: special handling for pow(double,double) vs pow(double,int)
    # note: special handling for int(double) and int(wide)
    # note: special handling for round(int)
    # note: special handling for wide(double) and int(wide)
    # note: special handling for srand(double)
    variable  FUNC_XLATE
    array set FUNC_XLATE [list                    acos $tclfunc_acos   asin $tclfunc_asin   atan $tclfunc_atan  \
        		atan2 $tclfunc_atan2      ceil $tclfunc_ceil    cos $tclfunc_cos    cosh $tclfunc_cosh  \
        		  exp $tclfunc_exp       floor $tclfunc_floor  fmod $tclfunc_fmod  hypot $tclfunc_hypot \
        		  log $tclfunc_log       log10 $tclfunc_log10  rand $tclfunc_rand  round $tclfunc_round \
		          sin $tclfunc_sin        sinh $tclfunc_sinh   sqrt $tclfunc_sqrt    tan $tclfunc_tan   \
			 tanh $tclfunc_tanh  ] 

}


###########################################
# some simple test helps for development
proc ::tsp::xlate_expr {symbol} {
    return [::tsp::expand_expr $symbol]
}

proc printExpr {expr} {
    printExprTree $expr [list [parse expr $expr {0 end}]]
}
proc printExprTree {expr tree {level 0}} {
    incr level 2
    set indent [string repeat "  " $level]
    puts "${indent}----NODES: [llength $tree]"
    foreach node $tree {
        lassign $node type range subtree
        puts "$indent$type [parse getstring $expr $range]"
        if {$type eq "subexpr"} {
            printExprTree $expr $subtree $level
        }
    }
}

# set expr {$a + 3 * ((($b(c) * $b($d) - $b($d,$e)) / [llength $foo]) - ($c > 3 ? $x : -1)) * pow(2.0,4.0)}
# set tree [parse expr $expr {0 end}]
# printExprTree $expr [list $tree]
###########################################

#############
# isBooleanLiteral
# check if arg is a boolean literal 1/0, possibly inclosed in parens
proc ::tsp::isBooleanLiteral {arg} {
    set arg [string trim $arg "( )"]
    return [expr {$arg eq "1" || $arg eq "0"}]
}

#############
# produce_plus_minus - produce unary or binary minus op 
# return list {type expr}
#
proc ::tsp::produce_plus_minus {compUnitDict op expr tree} {
    upvar $compUnitDict compUnit
    if {[llength $tree] == 1} {
        return [::tsp::produce_unary_op compUnit $op $expr $tree]
    } elseif {[llength $tree] == 2} {
        return [::tsp::produce_binary_op compUnit $op $expr $tree]
    } else {
        error "::tsp::produce_plus_minus: plus_minus $tree"
    }
}

#############
# produce_unary_op minus plus logical_not bit_not
# return list {type code}
#
proc ::tsp::produce_unary_op {compUnitDict op expr tree} {
    upvar $compUnitDict compUnit
    if {[llength $tree] != 1} {
        error "::tsp::produce_unary_op: produce_unary_op expected one element, instead got: $tree"
    } 
    lassign [::tsp::produce_subexpr compUnit $expr $tree] type operand
    if {[string match string* $type]} {
        error "can't use non-numeric string as operand of: $op"
    }
    switch -exact -- $op {
        "-" { 
            if {[::tsp::typeIsBoolean $type]} {
                # rewrite boolean into int 0 or 1 
                set operand "($operand ? 1 : 0)"
                set type int
            } else {
                # type is unchanged
                set operand "(${operand})"
            }
        } 
        "+" { 
            set op "" 
            # type is unchanged, ignore plus sign 
        }
        "!" {
            if {(! [::tsp::typeIsBoolean $type]) && ([::tsp::typeIsNumeric $type])} {
                # rewrite to force into boolean
                set op ""
                set operand "$operand == 0 ? 1 : 0"
                set type boolean
            } elseif {[::tsp::typeIsBoolean $type]} {
                set type boolean
            } else {
                error "invalid type for operator $op: $type"
            }
        }
        "~" {
            if {[::tsp::typeIsInt $type]} {
                set type int
                set operand "${operand}"
            } elseif {[::tsp::typeIsBoolean $type]} {
                # rewrite boolean as int
                set operand "($operand ? 1 : 0)"
                set type int
            } else {
                error "invalid type for operator $op: $type"
            }
        }
    }
    append buf ( $op $operand )
    return [list $type $buf]
}


#############
# produce_binary_op
# return list {type expr}
#
proc ::tsp::produce_binary_op {compUnitDict op expr tree} {
    upvar $compUnitDict compUnit
    if {[llength $tree] != 2} {
        error "::tsp::produce_binary_op: produce_binary_op expected two elements, instead got: $tree"
    }
    set first [lindex $tree 0]
    set second [lindex $tree 1]
    lassign [::tsp::produce_subexpr compUnit $expr $first]  firstType  firstOperand
    lassign [::tsp::produce_subexpr compUnit $expr $second] secondType secondOperand

    # if both types are string, then rewrite into string compare
    if {[string match string* $firstType] && [string match string* $secondType]} {
        if {[lsearch -exact $::tsp::STRING_OPS $op] >= 0} {
            # turn string comparison into function call
            set func $::tsp::OP_STRING_XLATE($op)
            if {$firstType eq "stringliteral"} {
                set firstOperand \"${firstOperand}\"
            }
            if {$secondType eq "stringliteral"} {
                set secondOperand \"${secondOperand}\"
            }
            return [list boolean "${func}($firstOperand, $secondOperand)"]
        } else {
            error "can't apply string types to operator: $op"
        }
    } 

    # if either type is a string, then raise an error
    if {[string match string* $firstType] || [string match string* $secondType]} {
       error "can't mix $firstType and $secondType with operator: $op"
    }


    # check for boolean only operators
    if {[lsearch -exact $::tsp::OP_BOOLEAN_OPERANDS $op] >= 0} {
        # make sure first and second operands are boolean, coerce into boolean expression
        if {![::tsp::typeIsBoolean $firstType] && [::tsp::typeIsNumeric $firstType]} {
            set firstType boolean
            set firstOperand "($firstOperand != 0)"
        }
        if {![::tsp::typeIsBoolean $secondType] && [::tsp::typeIsNumeric $secondType]} {
            set secondType boolean
            set secondOperand "($secondOperand != 0)"
        }
        # all of these operator return boolean type
        return [list boolean "($firstOperand $op $secondOperand)"]
    }

    # check for int only operators
    if {[lsearch -exact $::tsp::OP_INT_OPERANDS $op] >= 0} {
        # doubles are not allowed for this operator
        if {$firstType eq "double" || $secondType eq "double"} {
            error "invalid type for operator $op: $firstType"
        }
        # check for special case '%'
        if {$op eq "%"} {
            return [list int "${::tsp::tclfunc_int_mod}($firstOperand, $secondOperand)"]
        }
        return [list int "($firstOperand $op $secondOperand)" ]
    }

    # general case for remaining operators, int or double operations

    # promote any boolean to int, for values that are not literal "0" or "1"
    if {[::tsp::typeIsBoolean $firstType]} {
	set firstType int
	set firstOperand "($firstOperand ? 1 : 0)"
    }
    if {[::tsp::typeIsBoolean $secondType]} {
	set secondType int
	set secondOperand "($secondOperand ? 1 : 0)"
    }

    # determine return type
    if {[lsearch -exact $::tsp::OP_BOOLEAN_RESULT $op] >= 0} {
        set type boolean
    } else {
        # should be both ints for int result, or if either is double, make it double
        if {[::tsp::typeIsInt $firstType] && [::tsp::typeIsInt $secondType]} {
	    set type int
        } elseif {[::tsp::typeIsDouble $firstType] || [::tsp::typeIsDouble $secondType]} {
	    set type double
        } else {
	    error "couldn't figure out type of $op : $firstType $secondType"
        }
    }

    # check for special case '/'
    if {$op eq "/"} {
        if {$type eq "int"} {
            return [list int "${::tsp::tclfunc_int_div}($firstOperand, $secondOperand)"]
        } elseif {$type eq "double"} {
            return [list double "${::tsp::tclfunc_double_div}($firstOperand, $secondOperand)"]
        } else {
            error "unexpected type for op: /"
        }
    }
 
    set buf "($firstOperand $op $secondOperand)"
    return [list $type $buf]
}


#############
# produce_ternary_op
# return list {type expr}
#
proc ::tsp::produce_ternary_op {compUnitDict op expr tree} {
    upvar $compUnitDict compUnit
    if {[llength $tree] != 3} {
        error "::tsp::produce_ternary_op: produce_ternary_op expected three elements, instead got: $tree"
    }
    set first [lindex $tree 0]
    set second [lindex $tree 1]
    set third [lindex $tree 2]

    lassign [::tsp::produce_subexpr compUnit $expr $first]  firstType  firstOperand
    lassign [::tsp::produce_subexpr compUnit $expr $second] secondType secondOperand
    lassign [::tsp::produce_subexpr compUnit $expr $third]  thirdType  thirdOperand

    # check if firstType is a boolean operation
    # if is not boolean, convert to boolean expression
    if {[string match string* $firstType]} {
        error "ternary relation cannot be a string"
    }
    if {(! [::tsp::typeIsBoolean $firstType]) &&  [::tsp::typeIsNumeric $firstType] } {
        # rewrite to force into boolean
        set firstOperand "($firstOperand != 0)"
    }

    # make sure types are both numeric or both string, promote boolean to int
    if {[::tsp::typeIsNumeric $secondType] && [::tsp::typeIsNumeric $thirdType]} {
        if {[::tsp::typeIsDouble $secondType] || [::tsp::typeIsDouble $thirdType]} {
            set type double
        } else {
            set type int
        }
    } elseif {[::tsp::typeIsBoolean $secondType] && [::tsp::typeIsBoolean $thirdType]} {
        set type boolean
    } elseif {[string match string* $secondType] && [string match string* $thirdType]} {
        set type string
        if {$secondType eq "stringliteral"} {
            set secondOperand \"${secondOperand}\"
        }    
        if {$thirdType eq "stringliteral"} {
            set thirdOperand \"${thirdOperand}\"
        }    
    } else {
        # second and third types are a mix of boolean and/or string,
        # raise an error
        error "ternary results are mixed: second operand: \"($secondType) $secondOperand\"  third operand: \"($thirdType) $thirdOperand\""
    }


    set buf (
    set sp " "
    append buf $firstOperand
    append buf $sp ? $sp
    append buf $secondOperand
    append buf $sp : $sp
    append buf $thirdOperand
    append buf )
    return [list $type $buf]
}

#############
# produce_func
# return {type expr}
#
proc ::tsp::produce_func {compUnitDict op expr tree} {
    upvar $compUnitDict compUnit
    if {[lsearch -exact $::tsp::FUNC_INT_RESULT $op] >= 0} {
        set type int
    } elseif {[lsearch -exact $::tsp::FUNC_DOUBLE_RESULT $op] >= 0} {
        set type double
    } elseif {[lsearch -exact $::tsp::FUNC_SAME_RESULT $op] >= 0} {
        # special case return type, only applies to abs()
        set type ""
    } else {
        error "don't know about function $op"
    }

    if {[llength $tree] == 0 && [lsearch -exact $::tsp::FUNC_0ARGS $op] >= 0} {
        set op $::tsp::FUNC_XLATE($op)
        append buf $op ()

    } elseif {[llength $tree] == 1 && [lsearch -exact $::tsp::FUNC_1ARG $op] >= 0} {
        lassign [::tsp::produce_subexpr compUnit $expr [lindex $tree 0]] firstType firstOperand
        if {[string match string* $firstType]} {
            error "arg type cannot be string for function: $op"
        }
        if {[::tsp::typeIsBoolean $firstType]} {
            # type is boolean, promote to int
            set firstType int
            set firstOperand "($firstOperand ? 1 : 0)"
        }
        if {$op eq "abs"} {
            if {[::tsp::typeIsDouble $firstType]} {
                set type double
                set op $::tsp::tclfunc_double_abs
            } else {
                set type int
                set op $::tsp::tclfunc_int_abs
            }
        } elseif {$op eq "srand"} {
	    if {[::tsp::typeIsDouble $firstType]} {
	        set op $::tsp::tclfunc_int_srand
                set firstOperand "(int)$firstOperand"
            }
        } elseif {$op eq "int" || $op eq "wide"} {
            if {[::tsp::typeIsInt $firstType]} {
                return [list int $firstOperand]
            }
            if {[::tsp::typeIsDouble $firstType]} {
                return [list int "(${::tsp::INT_TYPE})$firstOperand"]
            } else {
                error "couldn't figure out type $firstType for func: int or wide"
            } 
        } elseif {$op eq "round"} {
            if  {[::tsp::typeIsInt $firstType]} {
                return [list int $firstOperand]
            }
            if  {[::tsp::typeIsDouble $firstType]} {
                return [list int ${::tsp::tclfunc_round}(${firstOperand})]
            } else {
                error "couldn't figure out type $firstType for func: round"
            }
        } else {
            set op $::tsp::FUNC_XLATE($op)
        }
        append buf $op ( $firstOperand )

    } elseif {[llength $tree] == 2 && [lsearch -exact $::tsp::FUNC_2ARGS $op] >= 0} {

        lassign [::tsp::produce_subexpr compUnit $expr [lindex $tree 0]] firstType firstOperand
        lassign [::tsp::produce_subexpr compUnit $expr [lindex $tree 1]] secondType secondOperand
        if {[string match string* $firstType]} {
            error "first arg cannot be string for function: $op"
        }
        if {[string match string* $secondType]} {
            error "second arg cannot be string for function: $op"
        }
        
        # if either are boolean, promote to int
        if {[::tsp::typeIsBoolean $firstType]} {
            set firstType int
            set firstOperand "($firstOperand 1 : 0)"
        }
        if {[::tsp::typeIsBoolean $secondType]} {
            set secondType int
            set secondOperand "($secondOperand 1 : 0)"
        }
        
        if {$op eq "pow"} {
            # expect both operands are double 
            set op $::tsp::tclfunc_double_pow
            if {$firstType eq "int"} {
                set firstOperand "(double)$firstOperand"
            }
            if {$secondType eq "int"} {
                # second operand is int, for case of negative first operand 
                set op $::tsp::tclfunc_double_int_pow
            }
        } else {
            set op $::tsp::FUNC_XLATE($op)
        }
        append buf $op ( $firstOperand ", " $secondOperand )

    } else {
        error "invalid function: $op with [llength $tree] argument(s)"
    }
    return [list $type $buf]
}

#############
# produce_op
# return list {type expr}
#
proc ::tsp::produce_op {compUnitDict op expr tree} {
    upvar $compUnitDict compUnit

    if {($op eq "-") || ($op eq "+")} {
        return [::tsp::produce_plus_minus compUnit $op $expr $tree]
    } elseif {[lsearch -exact $::tsp::UNARY_OPS $op] >= 0} {
        return [::tsp::produce_unary_op compUnit $op $expr $tree]
    } elseif {[lsearch -exact $::tsp::BINARY_OPS $op] >= 0} {
        return [::tsp::produce_binary_op compUnit $op $expr $tree]
    } elseif {[lsearch -exact $::tsp::TERNARY_OPS $op] >= 0} {
        return [::tsp::produce_ternary_op compUnit $op $expr $tree]
    } else {
        return [::tsp::produce_func compUnit $op $expr $tree]
    }
}


#############
# produce_subexpr - compile a subexpr into code
# is called recursively, and from other produce_* procs
# return list {type expr}
#
# FIXME: if parse returns "text" node, see if string needs variable substitution
# FIXME: be careful on rewriting boolean, int, etc, looking text strings into 
#        a native type
proc ::tsp::produce_subexpr {compUnitDict expr tree} {
    upvar $compUnitDict compUnit
    if {[llength $tree] == 0} {
        # FIXME: check if expr is just a numeric value???
        # if so, determine type and return
        set type [::tsp::literalExprTypes $expr]
        if {[::tsp::typeIsNumeric $type]} {
            return [list $type $expr]
        }
        # fall back - parse expr 
        set tree [lindex [parse expr $expr {0 end}] 2]
    }
    if {[lindex $tree 0] eq "subexpr"} {
        set tree [lindex $tree 2]
    }
    set rest ""
    set rest [lassign $tree node]
    set tree $rest
    lassign $node type range subtree
    set nodeexpr [parse getstring $expr $range]
    if {$type eq "subexpr" && [llength $subtree] == 1} {
        # variable or text
        set thing [lindex $subtree 0]
        lassign  $thing thingtype thingrange thingsubtree
        set thingtext [parse getstring $expr $thingrange]
        if {$thingtype eq "variable"} {
            set thingtext [string range $thingtext 1 end]
            set type [::tsp::getVarType compUnit $thingtext]
            set idx [lsearch -exact $::tsp::EXPR_TYPES $type]
            if {$idx == -1} {
                error "variable \"$thingtext\" not type of boolean, int, double, or string: \"$type\" in expression: $nodeexpr"
            }
            # NOTE that we change the variable for native compilation by prefixing with "__"
            return [list $type __$thingtext]
        } elseif {$thingtype eq "text"} {
            set type [::tsp::literalExprTypes $thingtext]
            return [list $type $thingtext]
        } else {
            error "::tsp::produce_subexpr: expected variable or text, instead got: $type"
        }
    } elseif {$type eq "operator"} {
        return [::tsp::produce_op compUnit $nodeexpr $expr $tree]
    } elseif {$type eq "variable"} {
        set nodeexpr [string range $nodeexpr 1 end]
        set type [::tsp::getVarType compUnit $nodeexpr]
        set idx [lsearch -exact $::tsp::EXPR_TYPES $type]
        if {$idx == -1} {
            error "variable \"$nodeexpr\" not type of boolean, int, double, or string: \"$type\" in expression: $nodeexpr"
        }
        # NOTE that we change the variable for native compilation by prefixing with "__"
        return [list $type __$nodeexpr]
    } elseif {$type eq "text"} {
        set type [::tsp::literalExprTypes $nodeexpr]
        return [list $type $nodeexpr]
    } elseif {$type eq "subexpr"} {
        lassign [::tsp::produce_subexpr compUnit $nodeexpr $tree] type result
        return [list $type "(${result})"]
    }
    error "::tsp::produce_subexpr: unexpected node: $type"
}



#############
# compileExpr - compile an expr string into code
# parse the expr string into a tree of subexpr
# return list of {type expr}
#
proc ::tsp::compileExpr {compUnitDict expr} {
    upvar $compUnitDict compUnit
    set tree [parse expr $expr {0 end}]
    lassign [::tsp::produce_subexpr compUnit $expr $tree] type result
    if {$type eq "stringliteral"} {
        regsub -all {"} $result {\"} result
	return [list string \"${result}\"]
    } else {
        return [list $type $result]
    }
}

#############
# compileBooleanExpr - compile an expr string into code with boolean result
# for use in for and while commands
# throws error if string is returned, otherwise coerce into boolean if needed
# return list of {type expr}
#
proc ::tsp::compileBooleanExpr {compUnitDict expr} {
    upvar $compUnitDict compUnit
    lassign [::tsp::compileExpr compUnit $expr] type result
    if {$type eq "string"} {
        error "string result cannot be coerced into boolean: $result"
    } elseif {$type eq "boolean"} {
        return [list $type $result]
    } else {
	return [list boolean "$result != 0 ? 1 : 0"]
    }
}


#############
# test_expr - 
# see if an expression can be compiled
# disallowed are array references and commands
# return list of {valid codebuf}
#
proc ::tsp::test_expr {expr} {
    set rc [catch { set tree [parse expr $expr {0 end}] } result]
    if {$rc != 0} {
        return [list 0 $result]
    }
    set results [::tsp::isValidExpr $expr [list $tree]]
    lassign $results invalid buf
    if {$invalid} {
        return [list 0 $buf]
    }
    return [list 1 $buf]
}


#############
# isValidExpr - check if expr node tree contains valid expressions
# specically, array references and command substitution is disallowed
# return list {numInvalidExpr invalidCodeBuf}
#
proc ::tsp::isValidExpr {expr tree} {
    set notvalid 0
    set buf {}
    foreach node $tree {
        lassign $node type range subtree
        set nodeexpr [parse getstring $expr $range]
        if {$type eq "command"} {
            incr notvalid
            lappend buf "embedded command: $nodeexpr"
        } elseif {$type eq "variable"} {
            set var [parse getstring $expr $range]
            lassign [parse command $var {0 end}] cmnts cmds rest tree
            set vartree [lindex [lindex [lindex $tree 0] 2] 0]
            set compvar [::tsp::init_compunit {} {} {} $var]
            set result [::tsp::parse_var compvar $vartree]
            lassign $result vartype varname
            if {$vartype ne "scalar"} {
                incr notvalid
		lappend buf "array variable: $var"
            }
            set isValid [::tsp::isValidIdent $varname]
            if {! $isValid} {
                incr notvalid
                lappend buf "invalid identifier: $var"
            }
        } elseif {$type eq "subexpr"} {
            set result [::tsp::isValidExpr $expr $subtree]
            lassign $result subinvalids subbuf
            if {$subinvalids > 0} {
                incr notvalid $subinvalids
                foreach b $subbuf {
                    lappend buf $b
                }
            }
        } elseif {$type eq "operator"} {
            #lappend buf "operator: $nodeexpr"
        } elseif {$type eq "text"} {
            #lappend buf "text: $nodeexpr"
        } else {
            error "unknown expr node: $type $nodeexpr"
        }
    }
    return [list $notvalid $buf]
}

