package provide tsp 0.1

# for dev - set the dir variable if not previously set
if {[info vars dir] ne "dir"} {
   set dir .
}

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

    # other ::tsp namespace variables are set in language specific files, 
    # e.g., tsp-java.tcl, tsp-clang.tcl
} 

source [file join $dir tsp-logging.tcl]
source [file join $dir tsp-compile.tcl]
source [file join $dir tsp-expr.tcl]
source [file join $dir tsp-parse.tcl]
source [file join $dir tsp-types.tcl]
source [file join $dir tsp-generate.tcl]
source [file join $dir tsp-generate-set.tcl]
source [file join $dir tsp-generate-math.tcl]
source [file join $dir tsp-generate-control.tcl]
source [file join $dir tsp-generate-var.tcl]
source [file join $dir tsp-generate-list.tcl]
source [file join $dir tsp-generate-string.tcl]

# source the language specific module
if {$::tcl_platform(platform) eq "java"} {
    source [file join $dir tsp-java.tcl]
} else {
    source [file join $dir tsp-clang.tcl]
}

