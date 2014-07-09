
#########################################################
# get a variable type, or "undefined" if not defined
# 
proc ::tsp::getVarType {compUnitDict var} {
    upvar $compUnitDict compUnit
    set result "undefined"
    catch {set result [dict get $compUnit vars $var]}
    return $result
}

#########################################################
# set a variable type
# 
proc ::tsp::setVarType {compUnitDict var type} {
    upvar $compUnitDict compUnit
    if {[string length $var] == 0} {
        error "can't define var as an empty string"
    }
    if {[catch {set previousType [dict get $compUnit vars $var]}] == 0} {
        if {$previousType ne $type} {
	    return "redefinition of var \"$var\" from \"$previousType\" to \"$type\""
        }
    } else {
        dict set compUnit vars $var $type
    }
    return ""
}

#########################################################
# set (or clear) a native type variable as dirty, but not for tmpvars
# 
proc ::tsp::setDirty {compUnitDict name {isdirty 1}} {
    upvar $compUnitDict compUnit

    if { ! [::tsp::is_tmpvar $name]} {
        set type [::tsp::getVarType compUnit $name]
        if {[lsearch $::tsp::NATIVE_TYPES $type] >= 0} {
            dict set compUnit dirty $name $isdirty
        }
    }
    return ""
}

#########################################################
# get list of dirty variables
# 
proc ::tsp::getDirtyList {compUnitDict} {
    upvar $compUnitDict compUnit

    set result [list]
    foreach {name isdirty} [dict get $compUnit dirty] {
        if {$isdirty} {
            lappend result $name
        }
    }
    return $result
}

#########################################################
# copy compUnit's variable list to another compUnit
# 
proc ::tsp::copyVars {fromCompUnitDict toCompUnitDict} {
    upvar $fromCompUnitDict fromCompUnit
    upvar $toCompUnitDict toCompUnit
    dict set toCompUnit vars [dict get $fromCompUnit vars]
}

#########################################################
# parse comments, looking for tsp pragmas
#
# #::tsp::procdef returns: <type> ?args: <type> ... <type>?
# #::tsp::vardef <type> <var> ?<var> ... <var>?
# #::tsp::volatile <var> ?<var> ... <var>?
# #::tsp::assertcompile    -- proc must compile, or raise error
# #::tsp::nocompile        -- parse, but don't compile proc

proc ::tsp::parse_pragma {compUnitDict comments} {

    upvar $compUnitDict compUnit

    set lines [split $comments \n]
    foreach line $lines {
        set line [string trim $line]

        set prag $line
        regexp {^([^\s]*)(\s)} $line match prag
        switch -- $prag {

            "#tsp::procdef" -
            "#::tsp::procdef"  {
                if {[catch {llength $line}]} {
                    ::tsp::addError compUnit "::tsp::procdef pragma not a proper list: $line"
                } else {
                    ::tsp::parse_procDefs compUnit $line
                }
            }
            
            "#tsp::vardef" -
            "#::tsp::vardef"  {
                if {[catch {llength $line}]} {
                    ::tsp::addError compUnit "::tsp::vardef pragma not a proper list: $line"
                } else {
                    ::tsp::parse_varDefs compUnit $line
                }
            }
            
            "#tsp::volatile" -
            "#::tsp::volatile"  {
                if {[catch {llength $line}]} {
                    ::tsp::addError compUnit "::tsp::volatile pragma not a proper list: $line"
                } else {
                    set vars [lrange $line 1 end]
                    dict set compUnit volatile $vars
                }
            }
            
            "#tsp::assertcompile" -
            "#::tsp::assertcompile"  {
                set previousType [dict get $compUnit compileType]
                if {$previousType ne "" && $previousType ne "assertcompile"} {
                    ::tsp::addError compUnit "cannot set ::tsp::assertcompile', was previously set as: \"$previousType\""
                } else {
                    dict set compUnit compileType assertcompile
                }
            }
            
            "#tsp::nocompile" -
            "#::tsp::nocompile"  {
                set previousType [dict get $compUnit compileType]
                if {$previousType ne "" && $previousType ne "nocompile"} {
                    ::tsp::addError compUnit "cannot set ::tsp::nocompile', was previously set as: \"$previousType\""
                } else {
                    dict set compUnit compileType nocompile
                }
                
            }
                    
        }

        set lineNum [dict get $compUnit lineNum]
        dict set compUnit lineNum [incr lineNum]
    } 
}

#########################################################
# parse a proc definition
# #tsp::proc returns: <type> ?args: <type> ... <type>?

proc ::tsp::parse_procDefs {compUnitDict def} {
    upvar $compUnitDict compUnit

    if {[dict get $compUnit returns] ne ""} {
        ::tsp::addError compUnit "::tsp::procdef: attempt to redefine proc: $def"
        return
    }
    
    set validReturnTypes $::tsp::RETURN_TYPES
    set validArgTypes $::tsp::VAR_TYPES

    set len [llength $def]
    if {$len < 2} {
        ::tsp::addError compUnit "::tsp::procdef: invalid proc definition, missing \"returns:\" keyword"
        return
    }
    set returnsKeyword [lindex $def 1]
    if {$returnsKeyword ne "returns:"} {
        ::tsp::addError compUnit "::tsp::procdef: invalid proc definition: missing \"returns:\" keyword"
        return
    }
    set type [lindex $def 2]
    if {$type eq ""} {
        set type missing
    }
    set found [lsearch $validReturnTypes $type]
    if {$found < 0} {
        ::tsp::addError compUnit "::tsp::procdef: invalid return type: $type"
        return
    }
    dict set compUnit returns $type
    set argTypesList [list]
    set procArgs [dict get $compUnit args]

    set argsKeyword [lindex $def 3]
    if {$argsKeyword ne "args:"} {
        ::tsp::addError compUnit "::tsp::procdef: invalid proc definition: missing \"args:\" keyword"
        return
    }

    set defArgs [lrange $def 4 end]
    set defArgsLen [llength $defArgs]
    set procArgsLen [llength $procArgs]
    if {$defArgsLen != $procArgsLen} {
        ::tsp::addError compUnit "::tsp::procdef: invalid proc definition: \
            number of arg types $defArgsLen does not match number of args $procArgsLen"
    } else {
        set i -1
        foreach arg $procArgs {
            incr i
            set isValid [::tsp::isValidIdent $arg]
            if {! $isValid} {
                ::tsp::addError compUnit "::tsp::procdef: proc arg is not valid identifier: $arg"
            }
            set type [lindex $defArgs $i]
            set found [lsearch $validArgTypes $type]
            if {$found < 0} {
                ::tsp::addError compUnit "::tsp::procdef: invalid proc definition: arg $arg type \"$type\" is invalid"
            } else {
                set exists [dict exists $compUnit vars $arg]
                if {$exists} {
                    set previous [dict get $compUnit vars $arg]
                    if {$previous ne $type} {
                        ::tsp::addError compUnit "::tsp::procdef: var already defined: arg \"$arg\" as type \"$previous\""
                    }
                } else {
		    ::tsp::setVarType compUnit $arg $type
                    lappend argTypesList $type
                }
            }
        }
        dict set compUnit argTypes $argTypesList
    }
}


#########################################################
# parse a variable definition
# #tsp::vardef <type> <var> ?<var> ... <var>?

proc ::tsp::parse_varDefs {compUnitDict def} {
    upvar $compUnitDict compUnit

    set len [llength $def]
    if {$len < 3} {
        ::tsp::addError compUnit "::tsp::vardef: invalid def, missing type and/or variables"
        return
    }

    set types $::tsp::VAR_TYPES

    set type [lindex $def 1]
    set found [lsearch $types $type]
    if {$found < 0} {
        ::tsp::addError compUnit "::tsp::vardef: invalid var type: \"$type\""
        return
    }

    set var_list [lrange $def 2 end]
    foreach var $var_list {
        set isValid [::tsp::isValidIdent $var]
        if {! $isValid} {
            ::tsp::addError compUnit "::tsp::vardef: var is not valid identifier: \"$var\""
        } else {
            set exists [dict exists $compUnit vars $var]
            if {$exists} {
                set previous [dict get $compUnit vars $var]
                if {$previous ne $type} {
                    ::tsp::addError compUnit "::tsp::vardef: var already defined: \"$var\" as type \"$previous\""
                }
            } else {
		::tsp::setVarType compUnit $var $type
            }
        }
    }
}

#########################################################
# check if id is a valid identifier
# valid identifiers look like C/Java identifiers, except that
# id cannot begin with two underscores (e.g. "__xxx"), which are
# reserved for tsp internal identifiers
# 

#FIXME - exclude lang specific list of reserved words

proc ::tsp::isValidIdent {id} {
    #tsp::proc returns: bool args: string id 
    
    if {[string match __* $id]} {
        return 0
    } 
    return [regexp {^[a-zA-Z_][a-zA-Z0-9_]*$} $id]
}


#########################################################
# implicitly define a variable and type
# 

proc ::tsp::implicit_def {compUnitDict cmdList} {

    #tsp::nocompile

    upvar $compUnitDict compUnit
    
    set cmd [lindex $cmdList 0]

    #FIXME - allow user defined proc to determine type
    catch {::tsp::implicit_def_$cmd compUnit $cmdList} 
}


#########################################################
# check for simple bare word types
# 

proc ::tsp::implicit_bareType {arg} {
    #tsp::proc returns: string args: string
    foreach type {int double boolean} {
        set isType [string is $type -strict $arg]
        if {$isType} {
            return $type
        }
    }
    return ""
}


#########################################################
# implicitly define var defined in 'append'
# 

proc ::tsp::implicit_def_append {compUnitDict cmdList} {
    upvar $compUnitDict compUnit
    lassign [parse command $cmdList {0 end}] commIdx cmdIdx restIdx tree
    set len [llength $tree]
    if {$len < 3} {
        return
    }

    lassign [lindex $tree 1] parseType parseIdx parseTree
    if {$parseType ne "simple"} {
        return
    }
    set var [parse getstring $cmdList $parseIdx]
    ::tsp::setVarType compUnit $var string
    ::tsp::addWarning compUnit "variable $var implicitly defined as string"
}

#########################################################
# implicitly define var defined in 'incr'
# 

proc ::tsp::implicit_def_incr {compUnitDict cmdList} {
    upvar $compUnitDict compUnit
    lassign [parse command $cmdList {0 end}] commIdx cmdIdx restIdx tree
    set len [llength $tree]
    if {$len < 2} {
        return
    }

    lassign [lindex $tree 1] parseType parseIdx parseTree
    if {$parseType ne "simple"} {
        return
    }
    set var [parse getstring $cmdList $parseIdx]
    ::tsp::setVarType compUnit $var int
    ::tsp::addWarning compUnit "variable $var implicitly defined as int"
}

#########################################################
# implicitly define var defined in 'lappend'
# 

proc ::tsp::implicit_def_incr {compUnitDict cmdList} {
    upvar $compUnitDict compUnit
    lassign [parse command $cmdList {0 end}] commIdx cmdIdx restIdx tree
    set len [llength $tree]
    if {$len < 2} {
        return
    }

    lassign [lindex $tree 1] parseType parseIdx parseTree
    if {$parseType ne "simple"} {
        return
    }
    set var [parse getstring $cmdList $parseIdx]
    ::tsp::setVarType compUnit $var var
    ::tsp::addWarning compUnit "variable $var implicitly defined as var"
}

#########################################################
# implicitly define var defined in 'lset'
# 

proc ::tsp::implicit_def_lset {compUnitDict cmdList} {
    upvar $compUnitDict compUnit
    lassign [parse command $cmdList {0 end}] commIdx cmdIdx restIdx tree
    set len [llength $tree]
    if {$len < 2} {
        return
    }

    lassign [lindex $tree 1] parseType parseIdx parseTree
    if {$parseType ne "simple"} {
        return
    }
    set var [parse getstring $cmdList $parseIdx]
    ::tsp::setVarType compUnit $var var
    ::tsp::addWarning compUnit "variable $var implicitly defined as var"
}

#########################################################
# implicitly define var defined in 'scan' (simple case of 'scan $str %d var')
# 

proc ::tsp::implicit_def_scan {compUnitDict cmdList} {
    upvar $compUnitDict compUnit
    lassign [parse command $cmdList {0 end}] commIdx cmdIdx restIdx tree
    set len [llength $tree]
    if {$len != 4} {
        return
    }

    lassign [lindex $tree 3] parseType parseIdx parseTree
    if {$parseType ne "simple"} {
        return
    }
    set var [parse getstring $cmdList $parseIdx]
    set fmt [lindex $cmdList 2]
    switch -- $fmt {
        %d -
        %o -
        %x -
        %i -
        %c {
	    ::tsp::setVarType compUnit $var int
            ::tsp::addWarning compUnit "variable $var implicitly defined as int"
        }
        %e -
        %f -
        %g {
	    ::tsp::setVarType compUnit $var double
            ::tsp::addWarning compUnit "variable $var implicitly defined as double"
        }
    }
}

#########################################################
# implicitly define var defined in 'set'
# 

proc ::tsp::implicit_def_set {compUnitDict cmdList} {
    upvar $compUnitDict compUnit
    
    lassign [parse command $cmdList {0 end}] commIdx cmdIdx restIdx tree
    set len [llength $tree]
    if {$len < 3} {
        return
    }

    lassign [lindex $tree 1] parseType parseIdx parseTree
    if {$parseType ne "simple"} {
        return
    }
    set var [parse getstring $cmdList $parseIdx]

    lassign [lindex $tree 2] parseType parseIdx parseTree
    set arg [parse getstring $cmdList $parseIdx]

    # check for simple types: int double boolean

    set type [::tsp::implicit_bareType $arg]
    if {$type ne ""} {
	::tsp::setVarType compUnit $var $type
        ::tsp::addWarning compUnit "variable $var implicitly defined as $type"
        return
    } 

    # check for string: " " { }  or list command: [list ? ?] 
    set firstChar [string range $arg 0 0]
    set lastChar [string range $arg end end]
    
    if {($firstChar eq {"} && $lastChar eq {"}) || ($firstChar eq "{" && $lastChar eq "}")} {
	::tsp::setVarType compUnit $var string
        ::tsp::addWarning compUnit "variable $var implicitly defined as string"
        return
    }

    if {($firstChar eq {[} && $lastChar eq {]})} {
        set arg [string range $arg 1 end-1]
        set arg [string trim $arg]
        set rc [catch {llength $arg} llen]
        if {$rc == 0 && $llen >= 1} {
            # parsed as a list, as we expected
            set subCmd [lindex $arg 0]
            if {$subCmd ne "list"} {
                # not the list command, make type a var
		::tsp::setVarType compUnit $var var
                ::tsp::addWarning compUnit "variable $var implicitly defined as var"
                return
            }
            set arg [lrange $arg 1 end]
            set firstArg [lindex $arg 0]
            set firstType [::tsp::implicit_bareType $firstArg]
            if {$firstType eq "" } {
                # not a simple type
		::tsp::setVarType compUnit $var var
                ::tsp::addWarning compUnit "variable $var implicitly defined as var"
                return
            } else {
                set rest [lrange $arg 1 end] 
                foreach nextArg $rest {
                    set nextType [::tsp::implicit_bareType $nextArg]
                    if {$firstType ne $nextType} {
                        # differing types, make it list of var
			::tsp::setVarType compUnit $var var
                        ::tsp::addWarning compUnit "variable $var implicitly defined as var"
                        return
                    }
                }
                # all list args are of the same type
		::tsp::setVarType compUnit $var var
                ::tsp::addWarning compUnit "variable $var implicitly defined as var"
            }
        } else {
            # not a list, so just make it a var
	    ::tsp::setVarType compUnit $var var
            ::tsp::addWarning compUnit "variable $var implicitly defined as var"
        }
    } else {
        # var is a string
	::tsp::setVarType compUnit $var string
        ::tsp::addWarning compUnit "variable $var implicitly defined as string"
    }

}


#########################################################
# test a val to see what types it can be 
# 

proc ::tsp::literalTypes {val} {
    set result [list stringliteral]
    if {[string is wide -strict $val]} {
        lappend result int
    }
    if {[string is double -strict $val]} {
        lappend result double
    }
    if {[string is boolean -strict $val]} {
        lappend result boolean
    }
    return $result
}

#########################################################
# test a val to see what types it can be for expr

proc ::tsp::literalExprTypes {val} {
    if {[string is wide -strict $val]} {
        return int
    } 
    if {[string is double -strict $val]} {
        return double
    }
    return stringliteral
}


#########################################################
#
# test a type list for various types

proc ::tsp::typeIsString {typeList} {
    return [expr {[lsearch $typeList string] >= 0}]
}

proc ::tsp::typeIsBoolean {typeList} {
    return [expr {[lsearch $typeList boolean] >= 0}]
}

proc ::tsp::typeIsInt {typeList} {
    return [expr {[lsearch $typeList int] >= 0}]
}

proc ::tsp::typeIsDouble {typeList} {
    return [expr {[lsearch $typeList double] >= 0}]
}

proc ::tsp::typeIsNumeric {typeList} {
    return [expr {[::tsp::typeIsInt $typeList] || [::tsp::typeIsDouble $typeList]}]
}



#########################################################
#
# reset tmp vars used per invocation 

proc ::tsp::reset_tmpvarsUsed {compUnitDict} {
    upvar $compUnitDict compUnit
    
    dict set compUnit tmpvarsUsed [dict create boolean 0 int 0 double 0 string 0 var 0 ]
}

#########################################################
#
# get and/or generate a temp var by type, and also defined as a var
# note: temp vars defined as: ____tmpVar_${type}_${n}
# optional var suffix creates "shadow" vars

proc ::tsp::get_tmpvar {compUnitDict type {var ""}} {
    upvar $compUnitDict compUnit

    if {[lsearch $::tsp::VAR_TYPES $type] < 0 || $type eq "array"} {
        error "::tsp::get_tmpvar - invalid var type $type"
    }

    if {$var eq ""} {

	# get next var name and generate name
	set n [dict get $compUnit tmpvarsUsed $type]
	incr n
	set name ____tmpVar__${type}_${n}
	dict set compUnit tmpvarsUsed $type $n

	# check if used vars by type is greater than max
	set max [dict get $compUnit tmpvars $type]
	if {$n > $max} {
	    # define this temp var and update max
	    ::tsp::setVarType compUnit $name $type
	    dict set compUnit tmpvars $type $n
	}
    } else {
        set name ____tmpVar_$var
        set existing [::tsp::getVarType compUnit $name]
        if {$existing eq "undefined"} {
            ::tsp::setVarType compUnit $name $type
        } elseif {$existing ne $type} {
            error "redefined temp var $var, was type: $existing, trying to set as $type"
        }
    }
    return $name
}



#########################################################
#
# test if name is a temp var

proc ::tsp::is_tmpvar {name} {
    return [regexp {^____tmpVar_} $name]
}


