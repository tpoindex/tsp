
# language specific procs - java 
package require java
package require hyde

# hyde options
hyde::configure -writecache 0
hyde::configure -runtime forcecompile


# interpreter builtin commands that we can call directly
# note: this is all compiled commands, since some tsp_compiled
# command may defer to the builtin ones.

namespace eval ::tsp {
    variable BUILTIN_TCL_COMMANDS [list					\
        after       append      apply       array       binary      	\
        break       case        catch       cd          clock       	\
        close       concat      continue    dict        encoding    	\
        eof         error       eval        exec        exit        	\
        expr        fblocked    fconfigure  fcopy       file        	\
        fileevent   flush       for         foreach     format      	\
        gets        glob        global      if          incr        	\
        info        interp      join        lappend     lassign     	\
        lindex      linsert     list        llength     lrange      	\
        lrepeat     lreplace    lreverse    lsearch     lset        	\
        lsort       namespace   open        package     pid         	\
        proc        puts        pwd         read        regexp      	\
        regsub      rename      return      scan        seek        	\
        set         socket      source      split       string      	\
        subst       switch      tell        time        trace       	\
        unset       update      uplevel     upvar       variable    	\
        vwait       while						]
}

# BUILTIN_TCL_COMMANDS was derived as:
# foreach cmd [lsort [info commands]] { 
#     if {[info procs $cmd] eq $cmd || [string match jacl* $cmd]} continue
#     puts $cmd
# }




##############################################
# translate a tsp type to a native type, note that
# we shouldn't see 'array' as a proc argument type
#
proc ::tsp::lang_xlate_native_type {tsp_type} {
    switch $tsp_type {
        int    {return long}
        var    {return TclObject}
        array  {return TclObject}
        string {return String}
    }
    # rest are also java types
    return $tsp_type
}

##############################################
# return native boolean type
#
proc ::tsp::lang_type_boolean {} {
    return boolean
}

##############################################
# return native int type
#
proc ::tsp::lang_type_int {} {
    return long
}

##############################################
# return native double type
#
proc ::tsp::lang_type_double {} {
    return long
}

##############################################
# return native string type: String/DString
# FIXME - probably should be a StringBuffer/StringBuilder
#
proc ::tsp::lang_type_string {} {
    return String
}

##############################################
# return native raw string type: String/char[]
#
proc ::tsp::lang_type_rawstring {} {
    return String
}

##############################################
# return native var type
#
proc ::tsp::lang_type_var {} {
    return TclObject
}

##############################################
# return native null reference
#
proc ::tsp::lang_type_null {} {
    return null
}

##############################################
# declare a native boolean
#
proc ::tsp::lang_decl_native_boolean {varName} {
    return "boolean $varName = false;\n"
}

##############################################
# declare a native int
#
proc ::tsp::lang_decl_native_int {varName} {
    return "long $varName = 0;\n"
}

##############################################
# declare a native double
#
proc ::tsp::lang_decl_native_double {varName} {
    return "double $varName = 0;\n"
}

##############################################
# declare a native string
#
proc ::tsp::lang_decl_native_string {varName} {
    return "String $varName = \"\";\n"
}

##############################################
# declare a native rawstring
#
proc ::tsp::lang_decl_native_rawstring {varName} {
    return "String $varName = \"\";\n"
}

##############################################
# free a native string
#
proc ::tsp::lang_free_native_string {varName} {
    return "$varName = null;\n"
}

##############################################
# declare a tclobj 
#
proc ::tsp::lang_decl_var {varName} {
    return "TclObject $varName = null;\n"
}

##############################################
# declare a native tclobj, same as ::tsp::lang_decl_var 
#
proc ::tsp::lang_decl_native_var {varName} {
    return [::tsp::lang_decl_var $varName]
}

##############################################
# new tclobj var as boolean
#
proc ::tsp::lang_new_var_boolean {varName value} {
    return "$varName = TclBoolean.newInstance($value);\n"
}

##############################################
# new tclobj var as integer
#
proc ::tsp::lang_new_var_int {varName value} {
    return "$varName = TclInteger.newInstance((long) $value);\n"
}

##############################################
# new tclobj var as double
#
proc ::tsp::lang_new_var_double {varName value} {
    return "$varName = TclDouble.newInstance((double) $value);\n"
}

##############################################
# new tclobj var as string obj
# str must either be a quoted string const or a native string var
proc ::tsp::lang_new_var_string {varName str} {
    return "$varName = TclString.newInstance($str);\n"
}

##############################################
# new assign a native rawstring, str should
# either be a quoted const or a rawstring reference
#
proc ::tsp::lang_assign_native_rawstring {varName str} {
    return "$varName = $str;\n"
}

##############################################
# free a  native rawstring
#
proc ::tsp::lang_free_native_rawstring {varName} {
    return "$varName = null;\n"
}

##############################################
# free a tcl obj var
#
proc ::tsp::lang_free_var {varName} {
    return "$varName = null\n;"
}

##############################################
# get a native rawstring from a tclobj var
#
proc ::tsp::lang_get_native_rawstring_var {varName} {
    return "TclObject.toString($varName)"
}

##############################################
# convert a boolean from a string value
#
proc ::tsp::lang_convert_boolean_string {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_boolean_string\n"
    append result "try {\n"
    append result "    $targetVarName = Util.getBoolean(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + sourceVarName + \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert a boolean from a var value
# note that errMsg should be passed unquoetd (done here)
#
proc ::tsp::lang_convert_boolean_var {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_boolean_var\n"
    append result "try {\n"
    append result "    $targetVarName = TclBoolean.get(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + $sourceVarName.toString() + \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert a int from a string value
# note that errMsg should be passed unquoetd (done here)
#
proc ::tsp::lang_convert_int_string {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_int_string\n"
    append result "try {\n"
    append result "    $targetVarName = Util.getWideInt(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"

    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + $sourceVarName.toString()+ \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert a double from a string value
# note that errMsg should be passed unquoetd (done here)
#
proc ::tsp::lang_convert_double_string {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_double_string\n"
    append result "try {\n"
    append result "    $targetVarName = Util.getDouble(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + $sourceVarName.toString()+ \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert an int from a var value
# note that errMsg should be passed unquoetd (done here)
#
proc ::tsp::lang_convert_int_var {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_int_var\n"
    append result "try {\n"
    append result "    $targetVarName = TclInteger.get(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + $sourceVarName.toString() + \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert a double from a var value
# note that errMsg should be passed unquoetd (done here)
#
proc ::tsp::lang_convert_double_var {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_double_var\n"
    append result "try {\n"
    append result "    $targetVarName = TclDouble.get(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + $sourceVarName.toString() + \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert a string from a boolean value
#
proc ::tsp::lang_convert_string_boolean {targetVarName sourceVarName {errMsg ""}} {
    append result "// ::tsp::lang_convert_string_boolean\n"
    append result "$targetVarName = $sourceVarName ? : \"1\" : \"0\";\n"
    return $result
}

##############################################
# convert a string from an int value
#
proc ::tsp::lang_convert_string_int {targetVarName sourceVarName {errMsg ""}} {
    append result "// ::tsp::lang_convert_string_int\n"
    append result "$targetVarName = \"\" + $sourceVarName;\n"
    return $result
}

##############################################
# convert a string from a double value
#
proc ::tsp::lang_convert_string_double {targetVarName sourceVarName {errMsg ""}} {
    append result "// ::tsp::lang_convert_string_double\n"
    append result "$targetVarName = \"\" + $sourceVarName;\n"
    return $result
}

##############################################
# convert a string from a string value
#
proc ::tsp::lang_convert_string_string {targetVarName sourceVarName {errMsg ""}} {
    append result "// ::tsp::lang_convert_string_string\n"
    append result "$targetVarName = $sourceVarName;\n"
    return $result
}

##############################################
# convert a string from a var value
#
proc ::tsp::lang_convert_string_var {targetVarName sourceVarName {errMsg ""}} {
    append result "// ::tsp::lang_convert_string_var\n"
    append result "$targetVarName = $sourceVarName.toString();\n"
    return $result
}

##############################################
# convert a var from a var value, this is here for
# easy of substitution, calls lang_assign_var_var
#
proc ::tsp::lang_convert_var_var {targetVarName sourceVarName {errMsg ""}} {
    return [::tsp::lang_assign_var_var $targetVarName $sourceVarName]
}

##############################################
# get string from a boolean value
#
proc ::tsp::lang_get_string_boolean {sourceVarName} {
    return "$sourceVarName ? : \"1\" : \"0\""
}

##############################################
# get a string from an int value
#
proc ::tsp::lang_get_string_int {sourceVarName} {
    return "\"\" + $sourceVarName"
}

##############################################
# get a string from a double value
#
proc ::tsp::lang_get_string_double {sourceVarName} {
    return "\"\" + $sourceVarName"
}

##############################################
# get a string from a string value
#
proc ::tsp::lang_get_string_string {sourceVarName} {
    return "$sourceVarName"
}

##############################################
# get a string from a var value
#
proc ::tsp::lang_get_string_var {sourceVarName} {
    return "$sourceVarName.toString()"
}


##############################################
# preserve / incrRefCount a TclObject variable
#
proc ::tsp::lang_preserve {obj} {
    return "$obj.preserve();\n"
}

##############################################
# release / decrRefCount a TclObject variable
#
proc ::tsp::lang_release {obj} {
    return "$obj.release();\n"
}

##############################################
# safe release / decrRefCount a TclObject variable
# and set object to null.
# checks for null before release
#
proc ::tsp::lang_safe_release {obj} {
    return "if ($obj != null) { $obj.release(); $obj = null; } \n"
}


##############################################
# quote string
# return a valid string constant with quotes
#
proc ::tsp::lang_quote_string {str} {
    append result \"
    foreach ch [split $str {}] {
        scan $ch %c val
        if {$val >=32 && $val <= 127} {
            if {$ch eq "\\" || $ch eq "\""} {
                append result \\
            }
            append result $ch
        } else {
            switch -- $ch {
                "\b" {append result \\b}
                "\t" {append result \\t}
                "\n" {append result \\n}
                "\f" {append result \\f}
                "\r" {append result \\r}
                default {
                     append result \\u
                     append result [format %04x $val]
                }
            } 
        } 
    }
    append result \"
    return $result
}

##############################################
# int constant
# appends long designation for java
proc ::tsp::lang_int_const {n} {
    if {[string is wide $n]} {
        append n L
    }
    return $n
}

##############################################
# double constant
# appends double designation for java
proc ::tsp::lang_double_const {n} {
    if {[string is wide $n] || [string is double $n]} {
        append n D
    }
    return $n
}


##############################################
# boolean true constant
# 
proc ::tsp::lang_true_const {} {
    return $::tsp::VALUE_TRUE
}

##############################################
# boolean false constant
# 
proc ::tsp::lang_false_const {} {
    return $::tsp::VALUE_FALSE
}



##############################################
# assign a TclObject from a interp array with a scalar or var index
# note that errMsg should be passed unquoetd (done here)
#
proc ::tsp::lang_assign_var_array_idxvar {targetObj arrVar idxVar idxVartype errMsg} {
    append result "// ::tsp::lang_array_get_array_idxvar\n"
    append result "try {\n"
    append result "    $targetObj = interp.getVar($arrVar, [::tsp::lang_get_string_$idxVartype $idxVar], 0);\n"
    append result "} catch (TclException te) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + sourceVarName + \"\\ncaused by: \" + te.getMessage());\n"
    append result "} catch (TclRuntimeError tre) {\n"
    append result "    throw tre;\n"
    append result "} finally {\n"
    append result "}\n"

    return $result
}

##############################################
# assign a TclObject from a interp array with a text index or var index
# idxTxtVar should either be a quoted string, or a rawstring reference
# note that errMsg should be passed unquoetd (done here)
#
proc ::tsp::lang_assign_var_array_idxtext {targetObj arrVar idxTxtVar errMsg} {
    append result "// ::tsp::lang_array_get_array_idxtext\n"
    append result "try {\n"
    append result "    $targetObj = interp.getVar($arrVar, $idxTxtVar, 0);\n"
    append result "} catch (TclException te) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + \"\\ncaused by: \" + te.getMessage());\n"
    append result "} catch (TclRuntimeError tre) {\n"
    append result "    throw tre;\n"
    append result "} finally {\n"
    append result "}\n"
    return $result
}

##############################################
# get a TclObject from a interp array with a scalar or var index
#
proc ::tsp::lang_array_get_array_idxvar {arrVar idxVar idxVartype} {
    append result "// ::tsp::lang_array_get_array_idxvar\n"
    append result "interp.getVar($arrVar, [::tsp::lang_get_string_$idxVartype $idxVar], 0);"
    return $result
}


##############################################
# assign a native string from a literal constant
# note that errMsg should be passed unquoetd (done here)
#
proc ::tsp::lang_assign_string_const {targetVarName sourceText} {
    append result "// ::tsp::lang_assign_string_const\n"
    append result "$targetVarName = [::tsp::lang_quote_string $sourceText];\n"
    return $result
}


##############################################
# assign a tclobj var from a boolean constant
#
# FIXME: TclBoolean should have public set() method, just like TclInteger, TclDouble, etc.??
proc ::tsp::lang_assign_var_boolean {targetVarName sourceVarName {preserve 1}} {
    append result "// ::tsp::lang_assign_var_boolean\n"
    append result "if ($targetVarName != null) {\n"
    append result "    [::tsp::lang_release $targetVarName]"
    append result "}\n"
    append result [::tsp::lang_new_var_boolean $targetVarName $sourceVarName]
    if {$preserve} {
        append result [::tsp::lang_preserve $targetVarName]
    }
    return $result
}

##############################################
# assign a tclobj var from an int constant
#
proc ::tsp::lang_assign_var_int {targetVarName sourceVarName {preserve 1}} {
    append result "// ::tsp::lang_assign_var_int\n"
    append result "if ($targetVarName != null) {\n"
    append result "    if ($targetVarName.isShared()) {\n"
    append result "        [::tsp::lang_release $targetVarName]"
    append result "        [::tsp::lang_new_var_int $targetVarName $sourceVarName]"
    if {$preserve} {
        append result "        [::tsp::lang_preserve $targetVarName]"
    }
    append result "    } else {\n"
    append result "        TclInteger.set($targetVarName, (long) $sourceVarName);\n"
    append result "    }\n"
    append result "} else {\n"
    append result "    [::tsp::lang_new_var_int $targetVarName $sourceVarName]"
    if {$preserve} {
        append result "    [::tsp::lang_preserve $targetVarName]"
    }
    append result "}\n"
    return $result
}

##############################################
# assign a tclobj var from an double constant
#
proc ::tsp::lang_assign_var_double {targetVarName sourceVarName {preserve 1}} {
    append result "// ::tsp::lang_assign_var_double\n"
    append result "if ($targetVarName != null) {\n"
    append result "    if ($targetVarName.isShared()) {\n"
    append result "        [::tsp::lang_release $targetVarName]"
    append result "        [::tsp::lang_new_var_double $targetVarName $sourceVarName]"
    if {$preserve} {
        append result "        [::tsp::lang_preserve $targetVarName]"
    }
    append result "    } else {\n"
    append result "        TclDouble.set($targetVarName, (double) $sourceVarName);\n"
    append result "    }\n"
    append result "} else {\n"
    append result "    [::tsp::lang_new_var_double $targetVarName $sourceVarName]"
    if {$preserve} {
        append result "    [::tsp::lang_preserve $targetVarName]"
    }
    append result "}\n"
    return $result
}

##############################################
# assign a tclobj var from an native string 
#
proc ::tsp::lang_assign_var_string {targetVarName sourceVarName {preserve 1}} {
    append result "// ::tsp::lang_assign_var_string\n"
    append result "if ($targetVarName != null) {\n"
    append result "    if ($targetVarName.isShared()) {\n"
    append result "        [::tsp::lang_release $targetVarName]"
    append result "        [::tsp::lang_new_var_string $targetVarName $sourceVarName]"
    if {$preserve} {
        append result "        [::tsp::lang_preserve $targetVarName]"
    }
    append result "    } else {\n"
    append result "        TclString.empty($targetVarName);\n"  
    append result "        TclString.append($targetVarName, $sourceVarName);\n"
    append result "    }\n"
    append result "} else {\n"
    append result "    [::tsp::lang_new_var_string $targetVarName $sourceVarName]"
    if {$preserve} {
        append result "    [::tsp::lang_preserve $targetVarName]"
    }
    append result "}\n"
    return $result
}


##############################################
# assign a tclobj var from a tclobj var
#
proc ::tsp::lang_assign_var_var {targetVarName sourceVarName {preserve 1}} {
    append result "// ::tsp::lang_assign_var_var\n"
    append result "if ($targetVarName != null) {\n"
    append result "    [::tsp::lang_release $targetVarName]"
    append result "}\n"
    # FIXME - probably don't have to duplicate soourceVarName object
    #         just assign and preserve()
    append result "$targetVarName = $sourceVarName.duplicate();\n"
    if {$preserve} {
        append result [::tsp::lang_preserve $targetVarName]
    }
    return $result
}

##############################################
# assign a tclobj var to an interp array using string name1/name2
#   targetArrayStr targetIdxStr must already be valid string constants
#   or string references.
#   the var is the object to assign into the array,
#   which is preserved and released
#
proc ::tsp::lang_assign_array_var {targetArrayStr targetIdxStr var} {
    append result "// ::tsp::lang_assign_array_var\n"
    append result "try {\n"
    append result "    [::tsp::lang_preserve $var]"
    append result "    interp.setVar($targetArrayStr, $targetIdxStr, $var, 0);\n"
    append result "} catch (TclException te) {\n"
    append result "    throw te;\n"
    append result "} catch (TclRuntimeError tre) {\n"
    append result "    throw tre;\n"
    append result "} finally {\n"
    append result "    [::tsp::lang_release $var]"
    append result "}\n"
    return $result
}


##############################################
# append a string to a native string
# source should either be a native string variable or
# quoted string constant
#
proc ::tsp::lang_append_string {targetVarName source} {
    return "$targetVarName = $targetVarName + $source;\n"
}


##############################################
# allocate a TclObject objv array
#
proc ::tsp::lang_alloc_objv_array {size} {
    return "argObjvArray = new TclObject\[$size\];\n"
}

##############################################
# assign a TclObject var to a TclObject objv array
#
proc ::tsp::lang_assign_objv {n obj} {
    return "argObjvArray\[$n\] = $obj;\n"
}


##############################################
# invoke a builtin tcl command
#  assumes argObjvArray has been constructed
# NOTE - return assign var as list of {cmdResultObj istmp}
#        to prevent it from being prefixed
#
proc ::tsp::lang_invoke_builtin {cmd} {
    append code "//  ::tsp::lang_invoke_builtin\n"
    #FIXME: use a static class to hold all builtin commands
    append code "builtin_$cmd.cmdProc(interp, argObjvArray);\n"
    #append code "(new tcl.lang.cmd.[string totitle $cmd]Cmd()).cmdProc(interp, argObjvArray);\n"
    #append code "(TspUtil.builtin_${cmd}).cmdProc(interp, argObjvArray);\n"
    #FIXME: perhaps use: ::tsp::lang_assign_var_var  cmdResultObj (interp.getResult())
    # so that we properly release/preserve cmdResultObj
    append code [::tsp::lang_safe_release cmdResultObj]
    append code "cmdResultObj = interp.getResult();\n"
    append code [::tsp::lang_preserve cmdResultObj]
    return [list {cmdResultObj istmp} $code]
}


##############################################
# allocate a TclObject objv list
#
proc ::tsp::lang_alloc_objv_list {} {
    return "argObjvList = TclList.newInstance();\n"
}


##############################################
# append a TclObject var to a TclObject objv list
#
proc ::tsp::lang_append_objv {obj} {
    return "TclList.append(null, argObjvList, $obj);\n"
}


##############################################
# invoke a tcl command via the interp
#  assumes argObjvArray has been constructed
# NOTE - return assign var as list of {cmdResultObj istmp}
#        to prevent it from being prefixed
#
proc ::tsp::lang_invoke_tcl {} {
    append code "//  ::tsp::lang_invoke_tcl\n"
    append code "interp.invoke(argObjvArray, 0);\n"
    #FIXME: perhaps use: ::tsp::lang_assign_var_var  cmdResultObj (interp.getResult())
    # so that we properly release/preserve cmdResultObj
    append code [::tsp::lang_safe_release cmdResultObj]
    append code "cmdResultObj = interp.getResult();\n"
    append code [::tsp::lang_preserve cmdResultObj]
    return [list {cmdResultObj istmp} $code]
}


##############################################
# invoke a tcl command that is a previously compiled tsp proc
# argList should only be native types
# any args that are Tcl vars should be preserved/released
# 
proc ::tsp::lang_invoke_tsp_compiled {cmdName procType returnVar argList preserveArgList} {
    set invokeArgs "interp"
    if {[string length $argList]} {
        append invokeArgs ", [join $argList ", "]"
    }
    append code "//  ::tsp::lang_invoke_tsp_compiled\n"
    append code "try {\n"
    append code "\n"
    if {$procType eq "void"} {
        append code "    tsp.cmd.${cmdName}Cmd.${cmdName}($invokeArgs);\n"
    } else {
        append code "    $returnVar = tsp.cmd.${cmdName}Cmd.${cmdName}($invokeArgs);\n"
    }
    append code "} catch (TclException te) {\n"
    if {$procType eq "var"} {
        append code "    $returnVar = TclString.newInstance(\"\");\n"
        append code "    $returnVar.preserve();\n"
    } elseif {$procType eq "string"} {
        append code "    $returnVar = \"\";\n"
    }
    append code "    throw te;\n"
    append code "} finally{\n"
    foreach v $preserveArgList {
        append code "    $v.release();\n"
    }
    append code "}\n"
    return $code
}


##############################################
# generate a foreach command.
# varlistComponent and listComponent are results of
# ::tsp::parse_word
# body is already indented compiled code of the body
#
proc ::tsp::lang_foreach {compUnitDict varlistComponent listComponent body} {
# get list length as int
# while varidx < listlength
# assign vars from list
# append body

    upvar $compUnitDict compUnit

    append code "// ::tsp::lang_foreach\n"

    set idx [::tsp::get_tmpvar compUnit int]
    set len [::tsp::get_tmpvar compUnit int]

    lassign $varlistComponent varType varRawText varText
    lassign $listComponent listType listRawText listText
    
    if {$listComponent eq "scalar"} {
        set listVar $listText
        set listVarType [::tsp::getVarType compUnit $listVar]
        if {$listVarType eq "boolean" || $listVarType eq "int" || $listVarType eq "double"} {
            # code to assign one variable, the rest as null/zero, execute body
FIXHERE
AND RETURN
        } else {
            if {$type eq "string"} {
                set listVar [::tsp::get_tmpvar compUnit var]
                append code "[::tsp::lang_safe_release $listVar]\n"
                append code "[::tsp::lang_new_var_string $listVar $listRawText]\n"
                append code "[::tsp::lang_preserve $listVar]\n"
            } else {
                # must be var
                set listVar $listRawText
            }
        }
    } else {
        # assumed to be a braced list
        # FIXME: can we just iterate/flatten through this literal list instead?
        set listVar [::tsp::get_tmpvar compUnit var]
        set listVarType var
        append code "[::tsp::lang_safe_release $listVar]\n"
        append code "[::tsp::lang_new_var_string $listVar [::tsp::lang_quote_string $listText]]\n"
        append code "[::tsp::lang_preserve $listVar]\n"
    }
    append code "$len = TclList.getLength(interp, $listvar);\n"


ASSIGN VARS and RETURN

    set var [::tsp::get_tmpvar compUnit var]
}

##############################################
# release var/string/temp var
#
proc ::tsp::lang_release_vars {compUnitDict} {
    upvar $compUnitDict compUnit
    set buf ""
    set varList [dict get $compUnit vars]
    foreach var $varList {
        set type [dict get $compUnit var $var ]
        switch $type {
            var {
                append buf "if ($var != null) {\n"
                append buf "    $var.release();\n"
                append buf "}\n"
            }
            string {}
        }
    }
    return $buf
}


##############################################
# standard vars - define variables used at runtime, but not
#   those defined as internal method arguments, block defined
#   or native array types
#
proc ::tsp::lang_standard_vars {compUnitDict} {
    upvar $compUnitDict compUnit
    foreach var {cmdResultObj argObjvList} {
    }
}


##############################################
# create_compilable - create class/function definition with
#   tcl interface and with direct interface
#
proc ::tsp::lang_create_compilable {compUnitDict code} {
    upvar $compUnitDict compUnit
    set name [dict get $compUnit name]
    set procArgs ""
    foreach arg [dict get $compUnit args] {
        lappend procArgs __$arg
    }
    set procArgTypes [dict get $compUnit argTypes]
    set nativeArgs [join $procArgs ", "]
    if {[string length $nativeArgs]} {
        set nativeArgs ", $nativeArgs"
    }
    set nativeTypedArgs ""
    set declProcArgs ""
    set argVarAssignments ""
    set procArgsCleanup ""
    set comma ""
    set i 0
    foreach arg $procArgs {
        set type [lindex $procArgTypes $i]
        # rest of foreach needs i+1
        incr i
        set nativeType [::tsp::lang_xlate_native_type $type]
        append nativeTypedArgs $comma $nativeType " " $arg 
        append declProcArgs [::tsp::lang_decl_native_$type $arg]
        if {$type eq "var"} {
            append argVarAssignments [::tsp::lang_assign_var_var $arg  argv\[$i\]]
            append procArgsCleanup [::tsp::lang_safe_release $arg]
        } else {
            append argVarAssignments [::tsp::lang_convert_${type}_var $arg argv\[$i\] "can't convert arg $i to $type"]
        }
        set comma ", "
    }
    if {[string length $nativeTypedArgs]} {
        set nativeTypedArgs ", $nativeTypedArgs"
    }
    set numProcArgs [llength $procArgs]
    set returnType [dict get $compUnit returns]
    set nativeReturnType [::tsp::lang_xlate_native_type $returnType]
    if {$returnType ne "void"} {
        set returnVarDecl [::tsp::lang_decl_native_$returnType returnValue]
        set returnVarAssignment "returnValue = "
        set returnSetResult "interp.setResult(returnValue);"
    } else {
        set returnVarDecl ""
        set returnVarAssignment ""
        set returnSetResult "interp.resetResult();"
    }

    set procVarsDecls ""
    set procVarsCleanup ""
    foreach {var} [lsort [dict keys [dict get $compUnit vars]]] {
        set type [::tsp::getVarType compUnit $var]
        if {[lsearch $procArgs __$var] >= 0} {
            continue
        }
        if {[::tsp::is_tmpvar $var]} {
            set pre ""
        } else {
            set pre __
        }
        if {$type eq "var"} {
            append procVarsDecls [::tsp::lang_decl_var $pre$var]
            append procVarsCleanup [::tsp::lang_safe_release $pre$var]
        } elseif {$type ne "array"} {
            append procVarsDecls [::tsp::lang_decl_native_$type $pre$var]
        }
    }
    

    set classTemplate {
package tsp.cmd;
import tcl.lang.*;
import tcl.lang.cmd.*;
//import tcl.pkg.tsp.util.*;
//import tcl.pkg.tsp.math.*;

public class ${name}Cmd implements Command {

[::tsp::lang_builtin_refs]

    // push a new callframe by wiring up interp fields (why isn't this a CallFrame constructor?)
    private static CallFrame pushNewCallFrame(Interp interp) {
	CallFrame frame = interp.newCallFrame();
	frame.level = (interp.varFrame == null) ? 1 : (interp.varFrame.level + 1);
	frame.caller = interp.frame;
	frame.callerVar = interp.varFrame;
	interp.frame = frame;
	interp.varFrame = frame;
	return frame;
    }

    public void cmdProc(Interp interp, TclObject argv\[\]) throws TclException {
        $returnVarDecl
        // variables used by this command, assigned from argv array
        [::tsp::indent compUnit $declProcArgs 2 \n]

        if (argv.length != [expr {$numProcArgs + 1}]) {
            throw new TclException(interp, "wrong # args: should be \\"$name [join [dict get $compUnit args]]\\"");
        }

        try {
            // assign arg variable from argv array
            [::tsp::indent compUnit $argVarAssignments 3 \n]
            // invoke inner compile proc method
            ${returnVarAssignment}__${name}(interp ${nativeArgs});
            $returnSetResult
        } catch (TclException te) {
            throw te;
        } finally {
            // release "var" arguments, if any
            [::tsp::indent compUnit $procArgsCleanup 3 \n]
        }
        
    }

    public static $nativeReturnType __${name}(Interp interp $nativeTypedArgs) throws TclException {
        TclObject cmdResultObj = null;
        TclObject argObjvList = null;
        TclObject\[\] argObjvArray = null;
        CallFrame frame = null;

        // variables defined in proc, plus temp vars
        [::tsp::indent compUnit $procVarsDecls 2 \n]

        try {
            frame = pushNewCallFrame(interp);
            if (frame == null) {
                throw new TclException(interp,"tsp internal error - pushNewCallFrame() returned null");
            }
            // code must return a value, else will raise a compilation error
            [::tsp::indent compUnit $code 3]
        } catch (TclException te) {
            throw te;
        } finally {
            frame.dispose();
            // release "var" variables, if any
            [::tsp::indent compUnit $procVarsCleanup 3 \n]
        }
    }

} // end of ${name}Cmd 


}
# end of classTemplate

    return [subst $classTemplate]

}



##############################################
# compile a class/function
# on successful compile, set the compiledReference in the compUnit
#
proc ::tsp::lang_compile {compUnitDict code} {
    upvar $compUnitDict compUnit
    dict set compUnit buf $code

    #FIXME - should use "hyde::jclass -source" when it is supported

    # #################
    # find a file we can write the code 
    set patt [file join $::env(java.io.tmpdir) $::env(user.name)_[pid]_]
    set name [dict get $compUnit name]
    set dirname ${patt}[expr {int(rand()*10000)}]
    while {[file exists $dirname]} {
        set dirname ${patt}[expr {int(rand()*10000)}]
    }
    file mkdir $dirname
    set filename [file join $dirname ${name}Cmd.java]
    set fd [open $filename w]
    puts $fd $code
    close $fd
    # #################
    
    set rc [catch {
        hyde::jclass ${name}Cmd -package tsp.cmd -include $filename
        dict set compUnit compiledReference tsp.cmd.${name}Cmd
    } result ]
    if {$rc} {
        ::tsp::addError compUnit $result
    }
    file delete $filename
    file delete $dirname
    return $rc
}


##############################################
# define a compiledReference in the interp
#
proc ::tsp::lang_interp_define {compUnitDict} {
    upvar $compUnitDict compUnit
    set class [dict get $compUnit compiledReference]
    set name [dict get $compUnit name]
    [java::getinterp] createCommand $name [java::new $class]
}

##############################################
# build a list of builtin command references
# ignore commands that are tsp compiled
# FIXME: this should be generated into a statically compiled class tsp.util.TspUtil
#
proc ::tsp::lang_builtin_refs {} {
    set result ""
    foreach cmd $::tsp::BUILTIN_TCL_COMMANDS {
        if {[info procs ::tsp::gen_command_$cmd] ne "::tsp::gen_command_$cmd"} {
            append result "    public static final Command builtin_$cmd = new tcl.lang.cmd.[string totitle $cmd]Cmd();\n"
        }
    }
    return $result
}


##############################################
# wrap an expression assignment to catch math errors
#
#FIXME: catch body belongs in tsp.util.TspUtil, as not to repeat code
proc ::tsp::lang_expr {exprAssignment} {
    append result "try {\n"
    append result "    $exprAssignment"
    append result "} catch (TclException te) {\n"
    append result "    String msg = te.getMessage();\n"
    append result "    if (msg != null && msg.equals(TspFunc.DIVIDE_BY_ZERO)) {\n"
    append result "        interp.setErrorCode(TclString().newInstance(\"ARITH DIVZERO {divide by zero}\"));\n"
    append result "        throw new TclException(interp, \"divide by zero\")\n"
    append result "    } else if (msg != null && msg.equals(TspFunc.DOMAIN_ERROR)) {\n"
    append result "        interp.setErrorCode(TclString().newInstance(\"ARITH DOMAIN {domain error: argument not in valid range}\"));\n"
    append result "        throw new TclException(interp, \"domain error: argument not in valid range\");\n"
    append result "    } else { \n"
    append result "        throw te;\n"
    append result "   }\n"
    append result "} catch (Exception ex) {\n"
    append result "   throw new TclException(interp, \"expr caught Java Exception: \" + ex.getMessage())\n"
    append result "}\n"
    append result "\n"
    return $result
}



##############################################
# spill vars into interp, used for ::tsp::volatile,
# compiled commands that use varName arguments, and
# spilling final var values for upvar/global/variable.
# returns code
#
proc ::tsp::lang_spill_vars {compUnitDict varList} {
    upvar $compUnitDict compUnit

    set buf "// ::tsp::::tsp::lang_spill_vars $varList\n"
    foreach var $varList {
        set type [::tsp::getVarType compUnit $var]
        if {$type eq "undefined"} {
            set type var
            :tsp::setVarType compUnit $var $type
        }
        if {$type eq "array"} {
            # array variables are already in interp
            continue
        }
        # woot! setVar is overloaded by type, so no need to convert to anything else
        # probably shouldn't get tmpvars here, but check anyway
        if {[llength $var] == 2 || [::tsp::is_tmpvar $var] || [string range $var 0 1] eq "__"} {
            set var [lindex $var 0]
            set pre ""
        } else {
            set pre __
        }
        append buf "// interp.setVar $var \n"
        append buf "interp.setVar([::tsp::lang_quote_string  $var], null, $pre$var, 0);\n"
    }
    return $buf
}



##############################################
# load vars from interp, use for reloading vars after
# ::tsp::volatile, compiled commands that use varName arguments,
# and loading initial variables after upvar/global/variable
# returns code
#
proc ::tsp::lang_load_vars {compUnitDict varList} {
    upvar $compUnitDict compUnit

    set buf ""
    foreach var $varList {
        set type [::tsp::getVarType compUnit $var]
        if {$type eq "undefined"} {
            set type var
            :tsp::setVarType compUnit $var $type
        }
        if {$type eq "array"} {
            # array variables are already in interp
            continue
        }
        # probably shouldn't get tmpvars here, but check anyway
        if {[llength $var] == 2 || [::tsp::is_tmpvar $var] || [string range $var 0 1] eq "__"} {
            set var [lindex $var 0]
            set pre ""
        } else {
            set pre __
        }
        if {$type eq "var"} {
            set interpVar $pre$var
        } else {
            #FIXME: use dirty checking, reset shadowed vars as not dirty here
            #FIXME: code a ::tsp::get_shadow_var proc
            set interpVar [::tsp::get_tmpvar compUnit var $var]
        }
        append buf "// interp.getVar $var\n"
        append buf [::tsp::lang_safe_release $interpVar]
        append buf "try {\n"
        append buf "    $interpVar = null;\n"
        append buf "    $interpVar = interp.getVar([::tsp::lang_quote_string $var], 0);\n"
        append buf "} catch (TclException te) {\n"
        append buf "    // missing variable checked outside of try/catch\n"
        append buf "}\n"
        append buf "if ($interpVar != null) {\n"
        append buf [::tsp::indent compUnit  [::tsp::lang_convert_${type}_var $pre$var $interpVar "can't convert var \"$var\" to type: \"$type\""] 1] 
        #FIXME: in some cases, an empty var is expected, such as upvar or global and the global
        #       doesn't yet exists.  other cases, such as a volatile spill/load is a likely error (??)
        #       add a flag for var exists checking 
        if {$type eq "var"} {
            append buf "\n\} else {\n"
            append buf "    [::tsp::lang_new_var_string $pre$var \"\"]"
            append buf "    [::tsp::lang_preserve $pre$var]"
            append buf "}\n"
        }
        append buf "\n}\n"
    }
    return $buf
}




