

########################################
# compilation unit dictionary keys:
# file - name of file being sourced
# name - name of the proc
# args - list of args
# argTypes - list of corresponding arg types
# body - body
# returns - type
# vars - vars to type dict
# dirty - sub dict of native typed vars that need tmp obj updated before tcl invocation
# tmpvars - sub dict of temporary var types used
# tmpvars - sub dict of temporary var types used per command invocation
# volatile - vars to spill/reload into tcl interp, for one command only
# frame - true/false if new var frame is required
# force - true to force compilation
# buf - code buffer
# breakable - count of nested while/for/foreach, when > 1  break/continue are allowed
# depth - count of nesting level
# lineNum - current line number
# errors - list of errors
# warnings - list of warnings
# compileType - "" = compile if able, nocompile = don't compile, assertcompile = Tcl error if not compilable
# compiledReference - the Java class name or C function 


proc ::tsp::init_compunit {file name procargs body} {
   return [dict create \
        file $file \
        name $name \
        args $procargs \
        argTypes invalid \
        body $body \
        returns "" \
        vars "" \
        dirty "" \
        tmpvars [dict create boolean 0 int 0 double 0 string 0 var 0] \
        tmpvarsUsed [dict create boolean 0 int 0 double 0 string 0 var 0] \
        volatile "" \
        frame 0 \
        force "" \
        buf "" \
        breakable 0 \
        depth 0 \
        lineNum 1 \
        errors "" \
        warings "" \
        compileType "" \
        compiledReference ""] 
}

#########################################################
# compile a proc 

proc ::tsp::compile_proc {file name procargs body} {

    set compUnit [::tsp::init_compunit $file $name $procargs $body]

    set lastIdx [string length $body]
    incr lastIdx -1
    set range [list 0 $lastIdx]

    set result ""
    set rc [catch {set code [::tsp::parse_body compUnit $range]} result]

    if {$rc != 0} {
        if {$result eq "nocompile"} {
            uplevel ::tcl::proc $name $procargs $body
            return
        }
        # some other error
        error "parse_body error: $result"
    }

    set errors [dict get $compUnit errors]
    set numErrors [llength $errors]
    
    if {$numErrors > 0 } {
        if {$result eq "assertcompile"} {
            error "assertcompile: proc $name\nbut resulted in errors:\n$errors"
        }
        append ::tsp::tsp_log $errors
        uplevel ::tcl::proc $name $args $body
    } else {
        ::tsp::lang_emit compUnit $code 
        ::tsp::lang_compile compUnit
        ::tsp::lang_define $name $compiledProc
    }
   
}


