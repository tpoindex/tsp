

########################################
# compilation unit dictionary keys:
# file - name of file being sourced
# name - name of the proc
# args - list of args
# argTypes - list of corresponding arg types
# body - body
# returns - type
# vars - vars to type dict
# finalSpill - vars spill into interp on method end, for upvar/global/variable defined vars
# dirty - sub dict of native typed vars that need tmp obj updated before tcl invocation
# tmpvars - sub dict of temporary var types used
# tmpvars - sub dict of temporary var types used per command invocation
# volatile - vars to spill/reload into tcl interp, for one command only
# frame - true/false if new var frame is required
# force - true to force compilation
# buf - code buffer, what is actually compiled
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
        finalSpill "" \
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
        warnings "" \
        compileType "" \
        compiledReference ""] 
}

#########################################################
# compile a proc 

proc ::tsp::compile_proc {file name procargs body} {

    set compUnit [::tsp::init_compunit $file $name $procargs $body]

    set procValid [::tsp::validProcName $name]
    if {$procValid ne ""} {
        ::tsp::addError compUnit compUnit $procValid
        ::tsp::logErrorsWarnings compUnit
        uplevel #0 [list ::proc $name $procargs $body]
        return
    }

    set result ""

    set rc [catch {set code [::tsp::parse_body compUnit {0 end}]} result]
    set errInf $result

    if {$rc != 0} {
        if {$result eq "nocompile"} {
            uplevel #0 [list ::proc $name $procargs $body]
            return
        } else {
            # some other error
            error "tsp internal error: parse_body error: $result\ncaused by:\n$errInf"
        }
    }

    set returnType [dict get $compUnit returns]
    if {$returnType eq ""} {
        ::tsp::addError compUnit "invalid proc definition, no return type specified, likely missing #::tsp::procdef"
        uplevel #0 [list ::proc $name $procargs $body]
        return
    }

    set errors [::tsp::getErrors compUnit]
    set numErrors [llength $errors]
    
    set compileResult [dict get $compUnit compileType]
    if {$numErrors > 0 } {
        if {$compileResult eq "assertcompile"} {
            ::tsp::logErrorsWarnings compUnit
            error "assertcompile: proc $name, but resulted in errors:\n$errors\n$errInf"
        } elseif {$compileResult eq "nocompile"} {
            # pragma says not to compile this proc, so no big deal
            # don't record any errors or warnings
            uplevel #0 [list ::proc $name $procargs $body]
        } else {
            ::tsp::logErrorsWarnings compUnit
            uplevel #0 [list ::proc $name $procargs $body]
        }
    } else {
        # parse_body ok, let's see if we can compile it
        set compilable [::tsp::lang_create_compilable compUnit $code]
        set rc [::tsp::lang_compile compUnit $compilable]
        if {$rc == 0} {
            ::tsp::lang_interp_define compUnit
            ::tsp::addCompiledProc compUnit
        } else {
            uplevel #0 [list ::proc $name $procargs $body]
        }

        ::tsp::logCompilable compUnit $compilable
        ::tsp::logErrorsWarnings compUnit
    }
   
}

#########################################################
# check if name is a legal identifier for compilation
# return "" if valid, other return error condition
#
proc ::tsp::validProcName {name} {
    if {! [::tsp::isValidIdent $name]} {
        return "invalid proc name: \"$name\" is not a valid identifier"
    }
    if {[lsearch [::tsp::getCompiledProcs] $name] >= 0} {
        return "invalid proc name: \"$name\" has been previously defined and compiled"
    }
    if {[lsearch ::tsp::BUILTIN_TCL_COMMANDS $name] >= 0} {
        return "invalid proc name: \"$name\" is builtin Tcl command"
    }
    return ""
}



#########################################################
# main tsp proc interface
#

proc ::tsp::proc {name argList body} {
    set scriptfile [info script]
    if {$scriptfile eq ""} {
        set scriptfile _
    }
    ::tsp::compile_proc $scriptfile $name $argList $body
    return ""
}


#########################################################
# set INLINE mode, whether we should inline generated code
# or use functions where possible.  value is true/false
#
proc ::tsp::setInline {value} {
    if {[string is -strict boolean $value]} {
        if {$value} {
            set ::tsp::INLINE 1
        } else {
            set ::tsp::INLINE 0
        }
    }
}
