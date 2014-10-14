package provide tsp 0.1

package require parser

namespace eval ::tsp {
    # types allowed for variables and procs
    variable VAR_TYPES [list boolean int double string array var]
    variable NATIVE_TYPES [list boolean int double string]
    variable RETURN_TYPES [list void boolean int double string var]
  
    # compiler log for all procs, keys are "filename,procname" errors|warnings, entries are list of: errors/warnings
    # most recent compilation has key of _
    variable COMPILER_LOG [dict create]

    # dict of compiled procs, entries are list of: returns argTypes compiledReference
    variable COMPILED_PROCS [dict create]

    # directory name of debug output, if any
    variable DEBUG_DIR ""

    # output of traces, default stderr
    # when ::tsp::debug is called, a file is created in that directory
    variable TRACE_FD stderr

    # the last traced proc that returned a value (or void), so the we can check their return types
    variable TRACE_PROC ""

    # inline - whether to inline code or use utility methods/functions where applicable
    variable INLINE 0

    # other ::tsp namespace variables are set in language specific files, 
    # e.g., tsp-java.tcl, tsp-clang.tcl
} 

source [file join [file dirname [info script]] tsp-logging.tcl]
source [file join [file dirname [info script]] tsp-compile.tcl]
source [file join [file dirname [info script]] tsp-trace.tcl]
source [file join [file dirname [info script]] tsp-expr.tcl]
source [file join [file dirname [info script]] tsp-parse.tcl]
source [file join [file dirname [info script]] tsp-types.tcl]
source [file join [file dirname [info script]] tsp-generate.tcl]
source [file join [file dirname [info script]] tsp-generate-set.tcl]
source [file join [file dirname [info script]] tsp-generate-math.tcl]
source [file join [file dirname [info script]] tsp-generate-control.tcl]
source [file join [file dirname [info script]] tsp-generate-var.tcl]
source [file join [file dirname [info script]] tsp-generate-list.tcl]
source [file join [file dirname [info script]] tsp-generate-string.tcl]

# source the language specific module
if {$::tcl_platform(platform) eq "java"} {
    source [file join [file dirname [info script]] tsp-java.tcl]
} else {
    source [file join [file dirname [info script]] tsp-clang.tcl]
}

