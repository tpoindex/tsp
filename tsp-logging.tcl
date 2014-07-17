
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
proc ::tsp::getLoggedErrors {compUnitDict} {
    upvar $compUnitDict compUnit
    set errors [dict get $compUnit errors]
    if {[llength $errors] == 0} {
        return [list]
    } 
    set filename [dict get $compUnit file]
    set name [dict get $compUnit name]
    set result [list]
    foreach error $errors {
        lappend result "$filename:$name - $error"
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
proc ::tsp::getLoggedWarnings {compUnitDict} {
    upvar $compUnitDict compUnit
    set warnings [dict get $compUnit warnings]
    if {[llength $warnings] == 0} {
        return [list]
    } 
    set filename [dict get $compUnit file]
    set name [dict get $compUnit name]
    set result [list]
    foreach warning $warnings {
        lappend result "$filename:$name - $warning"
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


#########################################################
# log all of the errors and warnings from a compilation
# last compilation has index of "_"
#
proc ::tsp::logErrorsWarnings {compUnitDict} {
    upvar $compUnitDict compUnit
    set errors [::tsp::getLoggedErrors compUnit]
    set warnings [::tsp::getLoggedWarnings compUnit]
    set filename [dict get $compUnit file]
    set name [dict get $compUnit name]
    dict set ::tsp::COMPILER_LOG $filename,$name [dict create errors $errors warnings $warnings]
    dict set ::tsp::COMPILER_LOG  _              [dict create errors $errors warnings $warnings]
}

#########################################################
# print errors and warnins to a filehandle
# optional filehandle, defaults to stderr
# optional pattern, defaults to *,* (sourcefilename,procname)
#
proc ::tsp::printErrorsWarnings {{fd stderr} {patt *,*}} {
    set keys [lsort [dict keys $::tsp::COMPILER_LOG]]
    foreach key $keys {
        if {[string match $patt $key]} {
            puts $fd "$key ---------------------------------------------------------"
            puts $fd "    ERRORS --------------------------------------------------"
            foreach err [dict get $::tsp::COMPILER_LOG $key errors] {
                puts $fd "   $err"
            }
            puts $fd "    WARNINGS ------------------------------------------------"
            foreach warn [dict get $::tsp::COMPILER_LOG $key warnings] {
                puts $fd "    $warn"
            }
            puts $fd ""
        }
    }
}

