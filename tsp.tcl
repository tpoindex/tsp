
package require parser

namespace eval ::tsp {
    # types allowed for variables and procs
    variable VAR_TYPES [list boolean int double string array var]
    variable NATIVE_TYPES [list boolean int double string]
    variable RETURN_TYPES [list void boolean int double string var]
  
    # compiler log for all procs
    variable COMPILER_LOG ""

    # dict of compiled procs, entries are [list returns argTypes compiledReference]
    variable COMPILED_PROCS [dict create]
} 

#FIXME: source command should be in pkgIndex.tcl
source tsp-compile.tcl  
source tsp-expr.tcl  
source tsp-parse.tcl  
source tsp-types.tcl
source tsp-generate.tcl
source tsp-generate-set.tcl
source tsp-generate-expr.tcl

if {$::tcl_platform(platform) eq "java"} {
    source tsp-java.tcl
} else {
    source tsp-clang.tcl
}




#########################################################
# add an error for the compUnit
#
proc ::tsp::addError {compUnitDict errorMsg} {
    upvar $compUnitDict compUnit
    dict lappend compUnit errors "[dict get $compUnit lineNum]: $errorMsg"
}


#########################################################
# get all of the logged warnings for the compUnit
#
proc ::tsp::getErrors {compUnitDict} {
    upvar $compUnitDict compUnit
    return [dict get $compUnit errors]
}


#########################################################
# get all of the logged errors for the compUnit with
# proc name and filename information
#
proc ::tsp::getLogErrors {compUnitDict} {
    upvar $compUnitDict compUnit
    set errors [dict get $compUnit errors]
    if {[llength $errors] == 0} {
        return [list]
    } 
    set filename [dict get $compUnit filename]
    set name [dict get $compUnit name]
    set result [list]
    foreach error $errors {
        lappend $result "$filename:$name - $error"
    }
    return $result
}


#########################################################
# add a warning for the compUnit
#
proc ::tsp::addWarning {compUnitDict warningMsg} {
    upvar $compUnitDict compUnit
    dict lappend compUnit warnings "[dict get $compUnit lineNum]: $warningMsg"
}


#########################################################
# get all of the current logged warnings for the compUnit

proc ::tsp::getWarnings {compUnitDict} {
    upvar $compUnitDict compUnit
    return [dict get $compUnit warnings]
}


#########################################################
# get all of the logged warnings for the compUnit with
# proc name and filename information
#
proc ::tsp::getLogWarnings {compUnitDict} {
    upvar $compUnitDict compUnit
    set warnings [dict get $compUnit warnings]
    if {[llength $warnings] == 0} {
        return [list]
    } 
    set filename [dict get $compUnit filename]
    set name [dict get $compUnit name]
    set result [list]
    foreach warning $warnings {
        lappend $result "$filename:$name - $warning"
    }
    return $result
}


#########################################################
# add the compUnit as a known compiled proc
#
proc ::tsp::addCompiledProc {compUnitDict} {
    upvar $compUnitDict compUnit
    set name [dict get $compUnit name]
    set returns [dict get $compUnit returns]
    set argTypes [dict get $compUnit argTypes]
    set compiledReference [dict get $compUnit compiledReference]
    dict set ::tsp::COMPILED_PROCS $name [list $returns $argTypes $compiledReference]
}

#########################################################
# check if name is a legal identifier for compilation
# return "" if valid, other return error condition
#
proc ::tsp::validProcName {name} {
    if {! [::tsp::isValidIdent $name]} {
        return "invalid proc name: \"$name\" is not a valid identifier"
    }
    if {[info commands ::tsp::gen_command_$name] eq $name} {
        return "invalid proc name: \"$name\" has been previously defined and compiled"
    }
    if {[info exists ::tsp::BUILTIN_TCL_COMMANDS($name)]} {
        return "invalid proc name: \"$name\" is builtin Tcl command"
    }
    return ""
}



