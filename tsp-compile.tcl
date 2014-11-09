

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
# tmpvarsUsed - sub dict of temporary var types used per command invocation, per type
# tmpvarsLocked - list of tmpvars locked, per type
# volatile - vars to spill/reload into tcl interp, for one command only
# frame - true/false if new var frame is required
# force - true to force compilation
# buf - code buffer, what is actually compiled
# breakable - count of nested while/for/foreach, when > 1  break/continue are allowed
# depth - count of block nesting level (if/while/for/foreach etc.)
# cmdLevel - count of nested commands (per outer word boundary)
# maxLevel - max level of nexted commands
# lineNum - current line number
# errors - list of errors
# warnings - list of warnings
# compileType - normal = compile if able, none = don't compile, assert = Tcl error if not compilable, trace = enable Tcl tracing
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
        tmpvarsLocked "" \
        volatile "" \
        frame 0 \
        force "" \
        buf "" \
        breakable 0 \
        depth 0 \
        cmdLevel 0 \
        maxLevel 0 \
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
        ::tsp::addError compUnit $procValid
        ::tsp::logErrorsWarnings compUnit
        uplevel #0 [list ::proc $name $procargs $body]
        return
    }

    set code ""
    set errInf ""

 
    set rc [ catch {set compileResult [::tsp::parse_body compUnit {0 end}] } errInf] 

    if {$rc != 0} {
        error "tsp internal error: parse_body error: $errInf"
    }
    
    lassign compileResults bodyType bodyRhs code

    set errors [::tsp::getErrors compUnit]
    set numErrors [llength $errors]
    set returnType [dict get $compUnit returns]
    set compileType [dict get $compUnit compileType]

    if {$compileType eq "none"} {
        ::tsp::addWarning compUnit "compileType $compileType"
        ::tsp::logErrorsWarnings compUnit
        uplevel #0 [list ::proc $name $procargs $body]
        return
    }

    if {$returnType eq ""} {
        ::tsp::addError compUnit "invalid proc definition, no return type specified, likely missing #::tsp::procdef"
        ::tsp::logErrorsWarnings compUnit
        if {$compileType eq "none" || $compileType eq "normal" || $compileType eq ""} {
            uplevel #0 [list ::proc $name $procargs $body]
            return
        } else {
            # else compileType is assert or trace, raise an error
            error "invalid proc definition, no return type specified, likely missing #::tsp::procdef"
        }
        return
    }

    
    if {$numErrors > 0 } {
        if {$compileType eq "assert" || $compileType eq "trace"} {
            error "compile type: $compileType, proc $name, but resulted in errors:\n[join $errors \n]"
            uplevel #0 [list ::proc $name $procargs $body]
        } else {
            # it's normal (or undefined), just define it
            uplevel #0 [list ::proc $name $procargs $body]
        }
        ::tsp::logErrorsWarnings compUnit
    } else {
        if {$compileType eq "trace"} {
            # define proc with tracing commands
            lassign [::tsp::init_traces compUnit $name $returnType] traces procTrace
            append traces $body
            uplevel #0 [list ::proc $name $procargs $traces]
            uplevel #0 $procTrace
            ::tsp::logErrorsWarnings compUnit
        } else {
            # parse_body ok, let's see if we can compile it
            set compilable [::tsp::lang_create_compilable compUnit $code]
            ::tsp::logCompilable compUnit $compilable
            set rc [::tsp::lang_compile compUnit $compilable]
            if {$rc == 0} {
                ::tsp::lang_interp_define compUnit
                ::tsp::addCompiledProc compUnit
            } else {
                # compile error, define as regular proc
                uplevel #0 [list ::proc $name $procargs $body]
            }

        }
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
