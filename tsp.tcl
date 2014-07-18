
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

    # other ::tsp namespace variables are set in language specific files, 
    # e.g., tsp-java.tcl, tsp-clang.tcl
} 

#FIXME: source command should be in pkgIndex.tcl
source tsp-logging.tcl
source tsp-compile.tcl  
source tsp-expr.tcl  
source tsp-parse.tcl  
source tsp-types.tcl
source tsp-generate.tcl
source tsp-generate-set.tcl
source tsp-generate-math.tcl
source tsp-generate-control.tcl

if {$::tcl_platform(platform) eq "java"} {
    source tsp-java.tcl
} else {
    source tsp-clang.tcl
}

