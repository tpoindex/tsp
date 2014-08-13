
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
# get the names of the compile proces
#
proc ::tsp::getCompiledProcs {} {
    return [dict keys $::tsp::COMPILED_PROCS]
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
    
    if {$::tsp::DEBUG_DIR eq ""} {
        return
    }
    set path [file join $::tsp::DEBUG_DIR $filename,$name.log]
    set fd [open $path w]
    ::tsp::printErrorsWarnings $fd $filename,$name
    close $fd 
}

#########################################################
# log the compilable source, only if debug directory is set
#
proc ::tsp::logCompilable {compUnitDict compilable} {
    if {$::tsp::DEBUG_DIR eq ""} {
        return
    }
    upvar $compUnitDict compUnit
    set filename [dict get $compUnit file]
    set name [dict get $compUnit name]
    
    set path [file join $::tsp::DEBUG_DIR $filename,$name.src]
    set fd [open $path w]
    puts $fd $compilable
    close $fd 
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


#########################################################
# make a tmp directory, partially borrowed from wiki.tcl.tk/772
#
proc ::tsp::mktmpdir {} {

    if {[catch {set tmp $::env(java.io.tmpdir)}] && \
        [catch {set tmp $::env(TMP)}] && \
        [catch {set tmp $::env(TEMP)}]} {
 
        if {$::tcl_platform(platform) eq "windows"} {
            set tmp C:/temp
        } else {
            set tmp /tmp
        }
    }

    set chars abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
    for {set i 0} {$i < 10} {incr i} {
        set path $tmp/tcl_
        for {set j 0} {$j < 10} {incr j} {
            append path [string index $chars [expr {int(rand() * 62)}]]
        }
        if {![file exists $path]} {
            file mkdir $path
            return $path
        }
    }
    error "failed to find an unused temporary directory name"
}


#########################################################
# set a directory for debug
#
proc ::tsp::debug {{dir ""}} {
    if {$::tsp::DEBUG_DIR ne ""} {
        error "debug directory already set as: $::tsp::DEBUG_DIR"
    }
    if {$dir eq ""} {
        set dir [::tsp::mktmpdir]
    } else {
        if {! [file isdirectory $dir] || ! [file writable $dir]} {
            error "debug pathname \"$dir\" not writable, or is not a directory"
        }
    }
    set ::tsp::DEBUG_DIR $dir
}

