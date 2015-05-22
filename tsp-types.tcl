
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
        error "can't define var as an empty string\n[::tsp::currentLine compUnit]\n[::tsp::error_stacktrace]"
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
# return true if var is a native type
# 
proc ::tsp::varIsNativeType {compUnitDict name} {
    upvar $compUnitDict compUnit
    return [expr {[lsearch $::tsp::NATIVE_TYPES [::tsp::getVarType compUnit $name]] >= 0}]
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
# get list of dirty variables, these variabls have been set
# by set or other commands, so any tmp vars will need to be
# refreshed before giving them to the interp
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
# get list of clean variables, these variables have not been
# set since the last assignment
# 
proc ::tsp::getCleanList {compUnitDict} {
    upvar $compUnitDict compUnit

    set result [list]
    foreach {name isdirty} [dict get $compUnit dirty] {
        if {! $isdirty} {
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
# parse comments or tsp pragma commands 
#
# #::tsp::procdef <type> -args <type> ... <type>?
# #::tsp::def <type> <var> ?<var> ... <var>?
# #::tsp::volatile <var> ?<var> ... <var>?
# #::tsp::compile   normal|none|assert|trace     

proc ::tsp::parse_pragma {compUnitDict comments} {

    upvar $compUnitDict compUnit

    set lines [split $comments \n]
    foreach line $lines {
        set prag [string trim $line " \t#:"]
        switch -glob -- $prag {

            "tsp::procdef*" {
                if {[catch {llength $prag}]} {
                    ::tsp::addError compUnit "::tsp::procdef pragma not a proper list: $line"
                } else {
                    ::tsp::parse_procDefs compUnit $prag
                }
            }
            
            "tsp::array*"  -
            "tsp::boolean*"  -
            "tsp::double*"  -
            "tsp::int*"  -
            "tsp::string*"  -
            "tsp::var*"  {
                if {[catch {llength $prag}]} {
                    ::tsp::addError compUnit "::tsp::def pragma not a proper list: $line"
                } else {
                    ::tsp::parse_varDefs compUnit $prag
                }
            }
            
            "tsp::volatile*"  {
                if {[catch {llength $prag}]} {
                    ::tsp::addError compUnit "::tsp::volatile pragma not a proper list: $line"
                } else {
                    ::tsp::parse_volatileDefs compUnit $prag
                }
            }
            
            "tsp::compile*"  {
                if {[catch {llength $prag}]} {
                    ::tsp::addError compUnit "::tsp::compile pragma not a proper list: $line"
                } else {
                    ::tsp::parse_compileDefs compUnit $prag
                }
            }
            
        }

        dict incr compUnit lineNum 
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
        ::tsp::addError compUnit "::tsp::procdef: invalid proc definition, missing return type"
        return
    }
    set type [lindex $def 1]
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
    set procArgsLen [llength $procArgs]

    if {$len == 2} {
        if {$procArgsLen == 0} {
            # no definded args, valid (but only in the case where proc args are void
            return
        } else {
            ::tsp::addError compUnit "::tsp::procdef: invalid proc definition: missing \"-args\" option"
            ::tsp::addError compUnit "::tsp::procdef: invalid proc definition: \
                number of arg types: 0 does not match number of args: $procArgsLen"
            return
        }
    }

    set argsKeyword [lindex $def 2]
    if {$argsKeyword ne "-args"} {
        ::tsp::addError compUnit "::tsp::procdef: invalid proc definition: missing \"-args\" option"
        return
    }

    set defArgs [lrange $def 3 end]
    set defArgsLen [llength $defArgs]
    if {$defArgsLen == 1 && $defArgs eq "void" && $procArgsLen == 0} {
        # void is allowed
        return
    } elseif {$defArgs eq "void" && $procArgsLen > 0} {
        ::tsp::addError compUnit "::tsp::procdef: invalid proc definition: \
                number of arg types: 0 does not match number of args: \"void\""
    }

    if {$defArgsLen != $procArgsLen} {
        ::tsp::addError compUnit "::tsp::procdef: invalid proc definition: \
            number of arg: types $defArgsLen does not match number of args: $procArgsLen"
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
# #tsp::def <type> <var> ?<var> ... <var>?

proc ::tsp::parse_varDefs {compUnitDict def} {
    upvar $compUnitDict compUnit

    set len [llength $def]
    if {$len < 2} {
        ::tsp::addError compUnit "::tsp::def: invalid def, missing variables"
        return
    }

    set types $::tsp::VAR_TYPES

    set type [lindex [split [lindex $def 0] :] end]
    set found [lsearch $types $type]
    if {$found < 0} {
        ::tsp::addError compUnit "::tsp::def: invalid var type: \"$type\""
        return
    }

    set var_list [lrange $def 1 end]
    foreach var $var_list {
        set isValid [::tsp::isValidIdent $var]
        if {! $isValid} {
            ::tsp::addError compUnit "::tsp::def: var is not valid identifier: \"$var\""
        } else {
            set exists [dict exists $compUnit vars $var]
            if {$exists} {
                set previous [dict get $compUnit vars $var]
                if {$previous ne $type} {
                    ::tsp::addError compUnit "::tsp::def: var already defined: \"$var\" as type \"$previous\""
                }
            } else {
		::tsp::setVarType compUnit $var $type
            }
        }
    }
}


#########################################################
# parse a volatile definition
# #tsp::volatile var var var ....

proc ::tsp::parse_volatileDefs {compUnitDict def} {
    upvar $compUnitDict compUnit

    set vars [lrange $def 1 end]
    foreach var $vars {
        set isValid [::tsp::isValidIdent $var]
        if {! $isValid} {
            ::tsp::addError compUnit "::tsp::volatile var is not valid identifier: \"$var\""
        }
    }
    ::tsp::append_volatile_list compUnit $vars
}


#########################################################
# add variables to volatile list
# ensure variables are not repeated

proc ::tsp::append_volatile_list {compUnitDict varList} {
    upvar $compUnitDict compUnit
    set vlist [dict get $compUnit volatile]
    set vlist [lsort -unique [concat $vlist $varList]]
    dict set compUnit volatile $vlist
}


#########################################################
# parse a compile definition
# #tsp::compile normal|assert|none|trace

proc ::tsp::parse_compileDefs {compUnitDict def} {
    upvar $compUnitDict compUnit

    set prevType [dict get $compUnit compileType]
    set type [lindex $def 1]
    if {[lsearch {"" normal none assert trace} $type] == -1} {
        ::tsp::addError compUnit "invalid ::tsp::compile type: \"$type\", must be one of normal, none, assert, trace"
    } else {
        if {$type eq ""} {
            set type normal
        }
        if {$prevType ne "" && $prevType ne $type} {
            ::tsp::addError compUnit "cannot set ::tsp::compile as \"$type\", was previously set as: \"$prevType\""
        } else {
            dict set compUnit compileType $type   
        }
    }
}


#########################################################
#
# check if var is a proc arg
#
proc ::tsp::isProcArg {compUnitDict var} {
    upvar $compUnitDict compUnit
    return [expr {[lsearch -exact [dict get $compUnit args] $var] >= 0}]
}


#########################################################
# check if id is a valid identifier
# valid identifiers look like C/Java identifiers
# begins with an alpha or underscore, remainder are
# alpha, number, or underscore
# 
proc ::tsp::isValidIdent {id} {
    #tsp::proc returns: bool args: string id 
    
    return [regexp {^[a-zA-Z_][a-zA-Z0-9_]*$} $id]
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
# get a native constant var
# constants are defined as: _constant_$n
 
proc ::tsp::get_constvar {n} {
    return _constant_$n
}

#########################################################
#
# reset tmp vars used per command invocation 
# does not effect "shadow" vars or locked tmpvars

proc ::tsp::reset_tmpvarsUsed {compUnitDict} {
    upvar $compUnitDict compUnit
    
    dict set compUnit tmpvarsUsed [dict create boolean 0 int 0 double 0 string 0 var 0 ]
}

#########################################################
#
# get and/or generate a temp var by type, and also defined as a var
# compUnit key "tmpvars" is the maximum number of temp vars used 
# in the entire proc. "tmpvarsUsed" is the total number of temp
# vars used for any one command invocation.
# note: temp vars defined as: _tmpVar_${type}_${n}
# optional varName argument creates "shadow" vars (created as: _tmpVar__$var), 
# so that we can optimize converting native type vars into TclObject var types

proc ::tsp::get_tmpvar {compUnitDict type {varName ""}} {
    upvar $compUnitDict compUnit

    if {[lsearch $::tsp::VAR_TYPES $type] < 0 || $type eq "array"} {
        error "::tsp::get_tmpvar - invalid var type $type\n[::tsp::currentLine compUnit]\n[::tsp::error_stacktrace]"
    }

    if {$varName eq ""} {
	# get next temp var number and generate name
	set n [dict get $compUnit tmpvarsUsed $type]
	incr n
	set name _tmpVar_${type}_${n}
	dict set compUnit tmpvarsUsed $type $n

	# check if used vars by type is greater than max
	set max [dict get $compUnit tmpvars $type]
	if {$n > $max} {
	    # define this temp var and update max
	    ::tsp::setVarType compUnit $name $type
	    dict set compUnit tmpvars $type $n
	}

        # check if this varname is locked, recurse to get the next one
        if {[::tsp::islocked_tmpvar compUnit $name]} {
            set name [::tsp::get_tmpvar compUnit $type]
        }

    } else {
        set name _tmpVar__$varName
        set existing [::tsp::getVarType compUnit $name]
        if {$existing eq "undefined"} {
            ::tsp::setVarType compUnit $name $type
        } elseif {$existing ne $type} {
            error "redefined temp var $varName, was type: $existing, trying to set as $type\n[::tsp::currentLine compUnit]\n[::tsp::error_stacktrace]"
        }
    }
    return $name
}


#########################################################
#
# lock and unlock tmp var - some control structures need 
# to use tmpvar beyond a single command (foreach, etc.)
#
proc ::tsp::lock_tmpvar {compUnitDict varName} {
    upvar $compUnitDict compUnit
    if {! [::tsp::islocked_tmpvar compUnit $varName]} {
        dict lappend compUnit tmpvarsLocked $varName
    }
    return
}

proc ::tsp::islocked_tmpvar {compUnitDict varName} {
    upvar $compUnitDict compUnit
    set idx [lsearch [dict get $compUnit tmpvarsLocked] $varName]
    return [expr {$idx >= 0}]
}

proc ::tsp::unlock_tmpvar {compUnitDict varName} {
    upvar $compUnitDict compUnit
    set idx [lsearch [dict get $compUnit tmpvarsLocked] $varName]
    if {$idx >= 0} {
        dict set compUnit tmpvarsLocked [lreplace [dict get $compUnit tmpvarsLocked] $idx $idx]
    }
    return
}

#########################################################
#
# test if name is a temp var or other internal var

proc ::tsp::is_tmpvar {name} {
    return [regexp {^_tmpVar_|^_constant_} $name]
}


#########################################################
#
# test if name is a already prefixed user var

proc ::tsp::is_prefixedvar {name} {
    return [regexp {^__} $name]
}


#########################################################
#
# return the prefix for user variables 
# if name is a temp var or already prefixed, return null string
# otherwise, return "__" as the compiled name prefix for
# user variables

proc ::tsp::var_prefix {name} {
    if {[::tsp::is_tmpvar $name] || [::tsp::is_prefixedvar $name]} {
        return ""
    } else {
        return "__"
    }
}
