
# language specific procs - java 
package require java
package require hyde

# set hyde options:
hyde::configure -compiler janinocp
hyde::configure -writecache 0
hyde::configure -runtime forcecompile


# BUILTIN_TCL_COMMANDS
# interpreter builtin commands that we can call directly
# note: this is all compiled commands, since some tsp_compiled
# command may defer to the builtin ones.

# SPILL_LOAD_COMMANDS
# commands that specify variables by name, requiring spill/load
# each element is a list of: command subcommand-or-option start end vartype spill-load-type.  
# if variable naem is not previously defined, it will be defined as the first type
# listed in vartype.  
# note: this list only for commands not otherwise compiled, and also not for array
# variable names, since they are always kept in the interp ("file stat"), 
# and not for introspection commands ("info").  See ::tsp::check_varname_args
# for details

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
        vwait       while						\
    ]

    variable SPILL_LOAD_COMMANDS [list                               \
	[list binary     scan       4  end    var      load]         \
        [list dict       append     2  2      var      spill/load]   \
        [list dict       incr       2  2      var      spill/load]   \
        [list dict       lappend    2  2      var      spill/load]   \
        [list dict       set        2  2      var      spill/load]   \
        [list dict       unset      2  2      var      spill/load]   \
        [list dict       update     2  2      var      spill/load]   \
        [list dict       with       2  2      var      spill/load]   \
        [list gets       ""         2  2      var      spill/load]   \
        [list lassign    ""         2  end    var      load]         \
        [list lset       ""         1  1      var      spill/load]   \
        [list regexp     --        +2  end    var      spill/load]   \
        [list regsub     --        +3  end    var      spill/load]   \
        [list scan       ""         3  end    var      load]         \
    ]
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
    return double
}

##############################################
# return native string type: String/DString
# FIXME - probably should be a StringBuffer/StringBuilder
#
proc ::tsp::lang_type_string {} {
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
# free a tcl obj var
#
proc ::tsp::lang_free_var {varName} {
    return "$varName = null\n;"
}

##############################################
# convert a boolean from a string value
#
proc ::tsp::lang_convert_boolean_string {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_boolean_string\n"
    
    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_convert_boolean_string(interp, $sourceVarName, [::tsp::lang_quote_string $errMsg]);\n"
        return $result
    }

    append result "try {\n"
    append result "    $targetVarName = Util.getBoolean(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + sourceVarName + \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert a boolean from a var value
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_convert_boolean_var {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_boolean_var\n"

    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_convert_boolean_var(interp, $sourceVarName, [::tsp::lang_quote_string $errMsg]);\n"
        return $result
    }

    append result "try {\n"
    append result "    $targetVarName = TclBoolean.get(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + $sourceVarName.toString() + \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert a int from a string value
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_convert_int_string {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_int_string\n"

    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_convert_int_string(interp, $sourceVarName, [::tsp::lang_quote_string $errMsg]);\n"
        return $result
    }

    append result "try {\n"
    append result "    $targetVarName = Util.getWideInt(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"

    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + $sourceVarName.toString()+ \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert a int from a boolean value
#
proc ::tsp::lang_convert_int_boolean {targetVarName sourceVarName {errMsg ""}} {
    append result "// ::tsp::lang_convert_int_boolean\n"
    append result "$targetVarName = $sourceVarName ? 1 : 0;\n"
    return $result
}

##############################################
# convert a int from a double value
#
proc ::tsp::lang_convert_int_double {targetVarName sourceVarName {errMsg ""}} {
    append result "// ::tsp::lang_convert_int_double\n"
    append result "$targetVarName = (long) $sourceVarName;\n"
    return $result
}

##############################################
# convert a double from a string value
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_convert_double_string {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_double_string\n"

    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_convert_double_string(interp, $sourceVarName, [::tsp::lang_quote_string $errMsg]);\n"
        return $result
    }

    append result "try {\n"
    append result "    $targetVarName = Util.getDouble(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + $sourceVarName.toString()+ \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert an int from a var value
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_convert_int_var {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_int_var\n"

    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_convert_int_var(interp, $sourceVarName, [::tsp::lang_quote_string $errMsg]);\n"
        return $result
    }

    append result "try {\n"
    append result "    $targetVarName = TclInteger.get(interp, $sourceVarName);\n"
    append result "} catch (TclException e) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + $sourceVarName.toString() + \"\\n caused by: \" + e.getMessage());\n"
    append result "}\n"
    return $result
}

##############################################
# convert a double from a var value
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_convert_double_var {targetVarName sourceVarName errMsg} {
    append result "// ::tsp::lang_convert_double_var\n"

    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_convert_double_var(interp, $sourceVarName, [::tsp::lang_quote_string $errMsg]);\n"
        return $result
    }

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
# assign empty/zero
# 
proc ::tsp::lang_assign_empty_zero {var type} {
    set code "//::tsp::lang_assign_empty_zero\n"
    switch $type {
        boolean {append code "$var = false;\n"}
        int -
        double {append code "$var = 0;\n"}
        string {append code [::tsp::lang_convert_string_string $var {""}]}
        var {append code [::tsp::lang_safe_release $var]
            append code [::tsp::lang_new_var_string $var {""}]
        }
    }
    return $code
}



##############################################
# assign a TclObject from a interp array with a scalar or var index
# note that errMsg should be passed unquoted (done here)
# arrVar is already a quoted string
#
proc ::tsp::lang_assign_var_array_idxvar {targetObj arrVar idxVar idxVartype errMsg} {
    append result "// ::tsp::lang_array_get_array_idxvar\n"

    if {! $::tsp::INLINE} {
        append result "$targetObj = TspUtil.lang_assign_var_array_idxvar(interp, $arrVar, [::tsp::lang_get_string_$idxVartype $idxVar], [::tsp::lang_quote_string $errMsg]);\n"
        return $result
    }

    append result "try {\n"
    append result "    $targetObj = interp.getVar($arrVar, [::tsp::lang_get_string_$idxVartype $idxVar], 0);\n"
    append result "} catch (TclException te) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + sourceVarName + \"\\ncaused by: \" + te.getMessage());\n"
    append result "}\n"

    return $result
}

##############################################
# assign a TclObject from a interp array with a text index or var index
# idxTxtVar should either be a quoted string, or a string
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_assign_var_array_idxtext {targetObj arrVar idxTxtVar errMsg} {
    append result "// ::tsp::lang_array_get_array_idxtext\n"

    if {! $::tsp::INLINE} {
        append result "$targetObj = TspUtil.lang_assign_var_array_idxtext(interp, $arrVar, $idxTxtVar, [::tsp::lang_quote_string $errMsg]);\n"
        return $result
    }

    append result "try {\n"
    append result "    $targetObj = interp.getVar($arrVar, $idxTxtVar, 0);\n"
    append result "} catch (TclException te) {\n"
    append result "    throw new TclException(interp, [::tsp::lang_quote_string $errMsg] + \"\\ncaused by: \" + te.getMessage());\n"
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
# note that errMsg should be passed unquoted (done here)
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

    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_assign_var_boolean($targetVarName, $sourceVarName);\n"
        return $result
    }

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

    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_assign_var_int($targetVarName, (long) $sourceVarName);\n"
        return $result
    }

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

    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_assign_var_double($targetVarName, (double) $sourceVarName);\n"
        return $result
    }

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

    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_assign_var_string($targetVarName, $sourceVarName);\n"
        return $result
    }

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

    if {! $::tsp::INLINE} {
        append result "$targetVarName = TspUtil.lang_assign_var_var($targetVarName, $sourceVarName);\n"
        return $result
    }

    append result "if ($targetVarName != null) {\n"
    append result "    [::tsp::lang_release $targetVarName]"
    append result "}\n"
    append result "$targetVarName = $sourceVarName;\n"

    # older code - duplicate source into target
    #append result "$targetVarName = $sourceVarName.duplicate();\n"

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

    if {! $::tsp::INLINE} {
        append result "TspUtil.lang_assign_array_var(interp, $targetArrayStr, $targetIdxStr, $var);\n"
        return $result
    }

    append result "try {\n"
    append result "    [::tsp::lang_preserve $var]"
    append result "    interp.setVar($targetArrayStr, $targetIdxStr, $var, 0);\n"
    append result "} catch (TclException te) {\n"
    append result "    throw te;\n"
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
    append result "// ::tsp::lang_append_string\n"
    append result "$targetVarName = $targetVarName + $source;\n"
    return $result
}


##############################################
# append a string to a var
# source should either be a native string variable or
# quoted string constant
#
proc ::tsp::lang_append_var {targetVarName source} {
    append result "// ::tsp::lang_append_var\n"
    append result "TclString.append($targetVarName, $source);\n"
    return $result
}


##############################################
# append a TclObject var to list
#
proc ::tsp::lang_lappend_var {targetVarName sourceVarName} {
    append result "// ::tsp::lang_lappend_var\n"
    append result "TclList.append(interp, $targetVarName, $sourceVarName);\n"
    return $result
}


##############################################
# duplicate a TclObject var if shared, or assign as
# empty if null
#
proc ::tsp::lang_dup_var_if_shared {targetVarName} {
    append result "// ::tsp::lang_dup_var_if_shared\n"
    append result "if ($targetVarName != null) {\n"
    append result "    if ($targetVarName.isShared()) {\n"
    append result "        [::tsp::lang_release $targetVarName]"
    append result "        $targetVarName = $targetVarName.duplicate();\n"
    append result "    }\n"
    append result "} else {\n"
    append result "    [::tsp::lang_new_var_string $targetVarName {""}]"
    append result "}\n"
    return $result
}



##############################################
# allocate a TclObject objv array
#
proc ::tsp::lang_alloc_objv_array {compUnitDict size} {
    upvar $compUnitDict compUnit
    set cmdLevel [dict get $compUnit cmdLevel]
    return "argObjvArray_$cmdLevel = new TclObject\[$size\];\n"
}

##############################################
# assign a TclObject var to a TclObject objv array
#
proc ::tsp::lang_assign_objv {compUnitDict n obj} {
    upvar $compUnitDict compUnit
    set cmdLevel [dict get $compUnit cmdLevel]
    return "argObjvArray_$cmdLevel\[$n\] = $obj;\n"
}


##############################################
# invoke a builtin tcl command
#  assumes argObjvArray has been constructed
#
proc ::tsp::lang_invoke_builtin {compUnitDict cmd} {
    upvar $compUnitDict compUnit
    set cmdLevel [dict get $compUnit cmdLevel]

    append code "\n//  ::tsp::lang_invoke_builtin\n"
    append code "TspCmd.builtin_$cmd.cmdProc(interp, argObjvArray_$cmdLevel);\n"

    #append code "builtin_$cmd.cmdProc(interp, argObjvArray_$cmdLevel);\n"
    #append code "(new tcl.lang.cmd.[string totitle $cmd]Cmd()).cmdProc(interp, argObjvArray_$cmdLevel);\n"
    #append code "(TspUtil.builtin_${cmd}).cmdProc(interp, argObjvArray_$cmdLevel);\n"

    append code [::tsp::lang_safe_release _tmpVar_cmdResultObj]
    append code "_tmpVar_cmdResultObj = interp.getResult();\n"
    append code [::tsp::lang_preserve _tmpVar_cmdResultObj] \n
    return [list _tmpVar_cmdResultObj $code]
}


##############################################
# allocate a TclObject objv list
#
proc ::tsp::lang_alloc_objv_list {varName} {
    return "$varName = TclList.newInstance();\n"
}


##############################################
# invoke a tcl command via the interp
#  assumes argObjvArray has been constructed
#
proc ::tsp::lang_invoke_tcl {compUnitDict} {
    upvar $compUnitDict compUnit
    set cmdLevel [dict get $compUnit cmdLevel]

    append code "\n//  ::tsp::lang_invoke_tcl\n"
    append code "interp.invoke(argObjvArray_$cmdLevel, 0);\n"
    append code [::tsp::lang_safe_release _tmpVar_cmdResultObj]
    append code "_tmpVar_cmdResultObj = interp.getResult();\n"
    append code [::tsp::lang_preserve _tmpVar_cmdResultObj] \n
    return [list _tmpVar_cmdResultObj $code]
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
    if {$procType eq "var"} {
        append code [::tsp::lang_safe_release $returnVar]
    }
    if {$procType eq "void"} {
        append code "tsp.cmd.${cmdName}Cmd.__${cmdName}($invokeArgs);\n"
    } else {
        append code "$returnVar = tsp.cmd.${cmdName}Cmd.__${cmdName}($invokeArgs);\n"
    }
    return $code
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
    foreach var {_tmpVar_cmdResultObj argObjvList} {
    }
}


##############################################
# create_compilable - create class/function definition with
#   tcl interface and with direct interface
#
proc ::tsp::lang_create_compilable {compUnitDict code} {
    upvar $compUnitDict compUnit
    set name [dict get $compUnit name]

    # create a list of proc argument names, prepended with __
    set procArgs ""
    foreach arg [dict get $compUnit args] {
        lappend procArgs __$arg
    }

    # get the list of proc argument types
    set procArgTypes [dict get $compUnit argTypes]
   
    # create the java proc arguments
    set nativeArgs [join $procArgs ", "]
    if {[string length $nativeArgs]} {
        set nativeArgs ", $nativeArgs"
    }


    set nativeTypedArgs ""
    set declProcArgs ""
    set argVarAssignments ""
    set innerVarPreserves ""
    set procArgsCleanup ""
    set comma ""
    set i 0

    # create: assignments from proc args to scoped variables; 
    #         declarations of scoped variables
    #         cleanup code for arguments (var types)
    #         code to preserve var types in inner method
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
            append innerVarPreserves [::tsp::lang_preserve $arg]
        } else {
            append argVarAssignments [::tsp::lang_convert_${type}_var $arg argv\[$i\] "can't convert arg $i to $type"]
        }
        set comma ", "
    }
    if {[string length $nativeTypedArgs]} {
        set nativeTypedArgs ", $nativeTypedArgs"
    }

    # create the inner method return assignment operation and declaration 
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

    # create inner method proc vars and cleanup code (for vars)
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
    
    # create the argObjvArrays, one for each level of command nesting
    set argObjvArrays ""
    set maxLevel [dict get $compUnit maxLevel]
    for {set i 0} {$i <= $maxLevel} {incr i} {
        append argObjvArrays "\n        TclObject\[\] argObjvArray_$i = null;"
    }

    # class template

    set classTemplate \
{package tsp.cmd;

import tcl.lang.*;
import tcl.lang.cmd.*;
import tsp.util.*;

public class ${name}Cmd implements Command {

//::tsp::lang_builtin_refs

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
            // release var variables, if any (includes _tmp variables)
            [::tsp::indent compUnit $procArgsCleanup 3 \n]
        }
        
    }

    public static $nativeReturnType __${name}(Interp interp $nativeTypedArgs) throws TclException {
        TclObject _tmpVar_cmdResultObj = null;
        CallFrame frame = null;
        $argObjvArrays

        // variables defined in proc, plus temp vars
        [::tsp::indent compUnit $procVarsDecls 2 \n]

        // any "var" arguments need to be preserved, since they are released in finally block
        [::tsp::indent compUnit $innerVarPreserves 2 \n]

        try {
            frame = TspUtil.pushNewCallFrame(interp);
            if (frame == null) {
                throw new TclException(interp,"tsp internal error - pushNewCallFrame() returned null");
            }
            // code must return a value as defined by procdef (unless void), else will raise a compilation error
            [::tsp::indent compUnit $code 3]

        } catch (TclException te) {
            throw te;
        } finally {

            [if {[string length [::tsp::lang_spill_vars compUnit [dict get $compUnit finalSpill]]] > 0} {
            subst {
            // spill variables that are global, upvar, or variable back into interp
            try {
                [::tsp::indent compUnit [::tsp::lang_spill_vars compUnit [dict get $compUnit finalSpill]] 4 \n]

            } catch (TclException fte) {
                // have to ignore at this point
            }

            } ; # inner subst
            }]
            frame.dispose();

            // release var variables, if any (includes _tmp variables)
            [::tsp::lang_safe_release _tmpVar_cmdResultObj]
            [::tsp::indent compUnit $procArgsCleanup 3 \n]
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
    set name [dict get $compUnit name]
    set rc [catch {
        hyde::jclass ${name}Cmd -package tsp.cmd -source $code
        dict set compUnit compiledReference tsp.cmd.${name}Cmd
    } result ]
    if {$rc} {
        ::tsp::addError compUnit $result
    }
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
# for java, this goes into TspCmd
#
proc ::tsp::lang_builtin_refs {} {
    set result ""
    foreach cmd $::tsp::BUILTIN_TCL_COMMANDS {
        if {[info procs $cmd] eq $cmd || [string match jacl* $cmd]} continue
        append result "    public static final Command builtin_$cmd = new tcl.lang.cmd.[string totitle $cmd]Cmd();\n"
        append result "    public static final TclObject CmdStringObj[string totitle $cmd];\n"
        append result "    static { CmdStringObj[string totitle $cmd] = TclString.newInstance(\"$cmd\"); CmdStringObj[string totitle $cmd].preserve(); }\n\n"
    }
    return $result
}


##############################################
# return a builtin command string object
# note - no checking if cmd is actually a builtin command
#
proc ::tsp::lang_builtin_cmd_obj {cmd} {
    return TspCmd.CmdStringObj[string totitle $cmd];
}


##############################################
# produce a compile expression assignment. 
# simple expression produced as is,
# if using any TspFunc methods, wrap in try/catch because those can throw exceptions
#
proc ::tsp::lang_expr {exprAssignment} {
    if {[string first TspFunc. $exprAssignment] == -1} {
        return $exprAssignment
    } else {
        append result "try {\n"
        append result "    $exprAssignment"
        append result "\n} catch (Exception e) {\n"
        append result "    TspFunc.ExprError(interp, e.getMessage()); // sets interp error code and throws a new TclException\n"
        append result "}\n"
        append result "\n"
        return $result
    }
}


##############################################
# spill vars into interp, used for ::tsp::volatile,
# compiled commands that use varName arguments, and
# spilling final var values for upvar/global/variable.
# returns code
# NOTE: TclException throw if variable is already defined as an array in the interp
#
proc ::tsp::lang_spill_vars {compUnitDict varList} {
    upvar $compUnitDict compUnit

    if {[llength $varList] == 0} {
        return ""
    }

    set buf "// ::tsp::::tsp::lang_spill_vars $varList\n"
    foreach var $varList {
        set type [::tsp::getVarType compUnit $var]
        if {$type eq "undefined"} {
            if {[::tsp::isProcArg compUnit $var]} {
                ::tsp::addError compUnit "proc argument variable \"$var\" not previously defined"
                return ""
            } elseif {[::tsp::isValidIdent $var]} {
                ::tsp::addWarning compUnit "variable \"${var}\" implicitly defined as type: \"var\" (volatile spill)"
                ::tsp::setVarType compUnit $var var
                set type var
            } else {
                ::tsp::addError compUnit "invalid identifier: \"$var\""
                return ""
            }
        }
        if {$type eq "array"} {
            # array variables are already in interp
            continue
        }
        # woot! setVar is overloaded by type, so no need to convert to anything else
        # probably shouldn't get tmpvars here, but get prefix anyway
        set pre [::tsp::var_prefix $var]

        append buf "// interp.setVar $var \n"
        if {$type eq "var"} {
            append buf "if ($pre$var == null) \{\n"
            append buf "    $pre$var = TclString.newInstance(\"\");\n"
            append buf "    $pre$var.preserve();\n"
            append buf "\}\n"
            append buf "interp.setVar([::tsp::lang_quote_string  $var], null, $pre$var, 0);\n"
        } else {
            append buf "interp.setVar([::tsp::lang_quote_string  $var], null, $pre$var, 0);\n"
        }
    }
    return $buf
}


##############################################
# load vars from interp, use for reloading vars after
# ::tsp::volatile, compiled commands that use varName arguments,
# and loading initial variables after upvar/global/variable
# NOTE: must use shadow variables for native types, see below
# NOTE: TclException throw if variable is unset or can't convert to native type
# returns code
#
proc ::tsp::lang_load_vars {compUnitDict varList setEmptyWhenNotExists} {
    upvar $compUnitDict compUnit

    set buf ""
    foreach var $varList {
        set type [::tsp::getVarType compUnit $var]
        if {$type eq "undefined"} {
            if {[::tsp::isProcArg compUnit $var]} {
                ::tsp::addError compUnit "proc argument variable \"$var\" not previously defined"
                return ""
            } elseif {[::tsp::isValidIdent $var]} {
                ::tsp::addWarning compUnit "variable \"${var}\" implicitly defined as type: \"var\" (volatile load)"
                ::tsp::setVarType compUnit $var var
                set type var
            } else {
                ::tsp::addError compUnit "invalid identifier: \"$var\""
                return ""
            }
        }
        if {$type eq "array"} {
            # array variables are already in interp
            continue
        }
        # probably shouldn't get tmpvars here, but get prefix anyway
        set pre [::tsp::var_prefix $var]
        
        if {$type eq "var"} {
            set interpVar $pre$var
            set isvar 1
        } else {
            # use shadow variable for native types 
            # NOTE: SEE ::tsp::gen_load_vars where only "string" types are set clean
            set interpVar [::tsp::get_tmpvar compUnit var $var]
            set isvar 0
        }

        if {$setEmptyWhenNotExists} {
            append buf "// ::tsp::lang_load_vars  interp.getVar $var\n"
            append buf [::tsp::lang_safe_release $interpVar]
            append buf "try \{\n"
            append buf "    $interpVar = interp.getVar([::tsp::lang_quote_string $var], 0);\n"
            append buf "    [::tsp::lang_preserve $interpVar]"
            if {! $isvar} {
                # for not-var types, convert into native type
                append buf [::tsp::indent compUnit [::tsp::lang_convert_${type}_var $pre$var $interpVar "can't convert var \"$var\" to type: \"$type\""] 1]
            } 
            append buf "\n\} catch (TclException e) \{\n"
            append buf "[::tsp::indent compUnit [::tsp::lang_assign_empty_zero $pre$var $type] 1]\n"
            if {$isvar} {
                append buf "[::tsp::indent compUnit [::tsp::lang_preserve $pre$var] 1]\n"
            }
            append buf "\}\n"
        } else {
            # no try/catch here - if variable is deleted, or cannot be converted, allow TclException to be thrown.
            # program needs to catch for this case
            append buf "// ::tsp::lang_load_vars  interp.getVar $var\n"
            append buf [::tsp::lang_safe_release $interpVar]
            append buf "$interpVar = interp.getVar([::tsp::lang_quote_string $var], 0);\n"
            append buf "[::tsp::lang_preserve $interpVar]"
            if {! $isvar} {
                # for not-var types, convert into native type
                append buf [::tsp::lang_convert_${type}_var $pre$var $interpVar "can't convert var \"$var\" to type: \"$type\""]
            } 
        }
    }
    return $buf
}


################################################################################################
# specific language implemented compiled commands below here
#

##############################################
# llength TclObject var
# implement the tcl 'llength' command
#
proc ::tsp::lang_llength {returnVar argVar {errMsg {""}}} {
    #FIXME: should we just let getLength() provide the error message?
    append code "// lang_llength\n"
    append code "try {\n"
    append code "    $returnVar = TclList.getLength(interp, $argVar);\n"
    append code "} catch (TclException te) {\n"
    append code "    throw new TclException(interp, $errMsg);\n"
    append code "}\n"
    return $code
}


##############################################
# lindex TclObject var
# implement the tcl 'lindex' command
#
proc ::tsp::lang_lindex {returnVar argVar idx isFromEnd {errMsg {""}}} {
    #FIXME: should we just let getLength() provide the error message?
    append code "// lang_lindex\n"
    append code "try {\n"
    if {$isFromEnd} {
        append code "    int listLength = TclList.getLength(interp, $argVar);\n"
        append code "    $returnVar = TclList.index(interp, $argVar, (int) (listLength - 1 - $idx));\n"
    } else {
        append code "    $returnVar = TclList.index(interp, $argVar, (int) $idx);\n"
    }
    append code "    if ($returnVar == null) {\n"
    append code "        [::tsp::lang_new_var_string $returnVar {""}]"
    append code "    }\n"
    append code "    $returnVar.preserve();\n"
    append code "} catch (TclException te) {\n"
    append code "    throw new TclException(interp, $errMsg);\n"
    append code "}\n"
    return $code
}


##############################################
# string index
# implement the tcl 'string index' command
# returnVar and argVar are string vars
#
proc ::tsp::lang_string_index {returnVar idx isFromEnd argVar} {
    append code "// lang_string_index\n"
    # note: make this a new string, in java 1.6 and early 1.7 versions, substring() doesn't create new string,
    # so ensure that we're not keeping references to large some char[] buf 
    if {$isFromEnd} {
        append code "if (($argVar.length() - 1 - $idx >= 0) && ($argVar.length() - 1 - $idx < $argVar.length())) \{\n"
        append code "    $returnVar = new String((int) $argVar.substring($argVar.length() - 1 - $idx, (int) $argVar.length() - $idx));\n"
    } else {
        append code "if (($idx >= 0) && ($idx < $argVar.length())) \{\n"
        append code "    $returnVar = new String($argVar.substring((int) $idx, (int) $idx + 1));\n"
    }
    append code "\} else \{\n"
    append code "    $returnVar = \"\";\n"
    append code "\}\n"
    return $code
}


##############################################
# string length
# implement the tcl 'string length' command
# returnVar is int and argVar is string
#
proc ::tsp::lang_string_length {returnVar argVar} {
    append code "// lang_string_length\n"
    append code "$returnVar = $argVar.length();\n"
    return $code
}


##############################################
# string range
# implement the tcl 'string range' command
# returnVar and argVar are string vars
#
proc ::tsp::lang_string_range {returnVar firstIdx firstIsFromEnd lastIdx lastIsFromEnd argVar} {
    append code "// lang_string_range\n"
    # note: make this a new string, in java 1.6 and early 1.7 versions, substring() doesn't create new string,
    # so ensure that we're not keeping references to large some char[] buf 
    # using local temp vars, so enclose in a block
    append code "\{\n"
    append code "    int strLen = $argVar.length();\n"
    if {$firstIsFromEnd} {
        append code "    long firstIdx = (strLen - 1 - ($firstIdx)) < 0 ? 0 : (strLen - 1 - ($firstIdx));\n"
    } else {
        append code "    long firstIdx = ($firstIdx) < 0 ? 0 : $firstIdx;\n"
    }
    if {$lastIsFromEnd} {
        append code "    long lastIdx = (strLen - 1 - ($lastIdx));\n"
    } else {
        append code "    long lastIdx = $lastIdx;\n"
    }
    append code "    if (firstIdx >= strLen || firstIdx > lastIdx || lastIdx < 0 || strLen == 0) \{\n"
    append code "        $returnVar = \"\";\n"
    append code "    \} else \{\n"
    append code "        if (lastIdx >= strLen) \{\n"
    append code "            lastIdx = strLen - 1;\n"
    append code "        \}\n"
    append code "        $returnVar = $argVar.substring((int) firstIdx, (int) lastIdx + 1);\n"
    append code "    \}\n"
    append code "\}\n"
    return $code
}


##############################################
# generate a catch command
# implement the tcl 'catch' command
#
proc ::tsp::lang_catch {compUnitDict returnVar bodyCode var varType} {
    upvar $compUnitDict compUnit
    append code "// ::tsp::lang_catch\n"
    append code "interp.resetResult();\n"
    append code "try \{\n"
    append code "[::tsp::indent compUnit $bodyCode]\n\n"
    append code "    // ::tsp::lang_catch: rc = 0, success \n"
    append code "    $returnVar = 0;\n"
    append code "\} catch (TclException te) \{\n"
    append code "    // ::tsp::lang_catch: rc = 1, error \n"
    append code "    $returnVar = 1;\n"
    append code "\}\n"
    if {$var ne ""} {
        if {$varType eq "var"} {
            append code [::tsp::lang_assign_${varType}_var $var interp.getResult()]
        } else {
            append code [::tsp::lang_convert_${varType}_var $var interp.getResult() "unable to convert var to $varType"]
        }
    }
    return $code
}


##############################################
# generate a switch command.
# implement the tcl 'switch' command
# switchVar is a scalar, pattScriptList is list of patterns and scripts
#
proc ::tsp::lang_switch {compUnitDict switchVar switchVarType pattCodeList} {
    upvar $compUnitDict compUnit

    set pre [::tsp::var_prefix $switchVar]
    if {$switchVarType eq "var"} {
        set switchVar $pre$switchVar.toString()
    } else {
        set switchVar $pre$switchVar
    }
    append code "// ::tsp::lang_switch\n"
    set match ""
    set or ""
    set else ""
    foreach {patt script} $pattCodeList {
        if {$patt eq "default"} {
            append match " $or true /*default*/ "
        } else {
            if {$switchVarType eq "string" || $switchVarType eq "var"} {
                append match "$or ([::tsp::lang_quote_string $patt].equals($switchVar)) "
            } elseif {$switchVarType eq "boolean"} {
                if {$patt} {
                    append match "$or (true == $switchVar) "
                } else {
                    append match "$or (false == $switchVar) "
                }
            } else {
                # int or double
                append match "$or ($patt == $switchVar) "
            }
	}

        if {$script eq "-"} {
            set or ||
        } else {
            append code "${else}if ( $match ) \{\n"
            append code [::tsp::indent compUnit $script 1]
            append code "\n\} "
            set else "else "
            set match ""
            set or ""
        }

    }
    append code "\n"
    return $code
}


##############################################
# generate a while command. 
# implement the tcl 'while' and 'for' commands.  uses a boolean
# boolean var to control loop because the exprCode may raise an exception.
# loopVar - a boolean temp variable, should be locked
# expr - assumed to be unwraped by lang_expr, that is done here. expr must
#        return a boolean result.
# body is already indented compiled code of the body
#
proc ::tsp::lang_while {compUnitDict loopVar expr body} {
    upvar $compUnitDict compUnit

    append code "// ::tsp::lang_while\n"

    append code "\n// evaluate condition \n"
    append code [::tsp::lang_expr "$loopVar = $expr;"] \n\n
    append code "while ( " $loopVar " ) {\n"
    append code $body
    append code "\n    // evaluate condition \n"
    append code [::tsp::indent compUnit [::tsp::lang_expr "$loopVar = $expr;"]]
    append code "\n}\n"

    return $code
}


##############################################
# generate a foreach command.
# implement the tcl 'foreach' command
# idxVar - int tmpvar to use as an index, should be locked
# lenVar - int tmpvar to use as list length, should be locked
# dataVar - var tmpvar to use as list var for literal list
# varList is list of vars to be assigned from list elements
# dataList is scalar var of data or dataString is literal data string
# body is already indented compiled code of the body
# Note: use block scoped idx and len variables (can't use tmp variables)
#
proc ::tsp::lang_foreach {compUnitDict idxVar lenVar dataVar varList dataList dataString body} {
    upvar $compUnitDict compUnit

    append code "// ::tsp::lang_foreach\n"
    
    # dataList or dataString?
    if {$dataList ne ""} {
        set dataListType [::tsp::getVarType compUnit $dataList]
        if {$dataListType eq "boolean" || $dataListType eq "int" || $dataListType eq "double"} {
            # code to assign one variable, the rest as null/zero, execute body
            set target [lindex $varList 0]
            set targetType [::tsp::getVarType compUnit $target]
            set rest [lrange $varList 1 end]
            
            set dataListPre [::tsp::var_prefix $dataList]
            set targetPre   [::tsp::var_prefix $target]

            if {$targetType eq $dataListType} {
                append code "$target = $dataLisPre$dataList;\n"
            } else {
                append code "[::tsp::lang_convert_${targetType}_${dataListType} $targetPre$target $dataListPre$dataList "unable to convert $dataListType to $targetType"]"
            }
            # zero out any remaining vars
            foreach v $rest {
                set type [::tsp::getVarType compUnit $v]
                set vPre [::tsp::var_prefix $v]
                append code "[::tsp::lang_assign_empty_zero $vPre$v $type]"
            }
            append code $body
            return $body

        } else {
            set dataListPre [::tsp::var_prefix $dataList]
            if {$dataListType eq "string"} {
                append code "[::tsp::lang_safe_release $dataList]\n"
                append code "[::tsp::lang_new_var_string $dataVar $dataListPre$dataList]\n"
                append code "[::tsp::lang_preserve $dataVar]\n"
            } else {
                # must be var
                set dataVar $dataListPre$dataList
            }
        }
    } else {
        # assumed to be a braced list string literal
        append code "[::tsp::lang_safe_release $dataVar]\n"
        append code "[::tsp::lang_new_var_string $dataVar [::tsp::lang_quote_string $dataString]]\n"
        append code "[::tsp::lang_preserve $dataVar]\n"
    }

    append code "$idxVar = 0; // idx\n"
    append code "$lenVar = TclList.getLength(interp, $dataVar); // list length\n"
    append code "while ($idxVar < $lenVar) \{\n"
    foreach var $varList {
        set varPre [::tsp::var_prefix $var]
        set type [::tsp::getVarType compUnit $var]
        append code "    // set var $var\n"
        append code "    if ($idxVar < $lenVar) \{\n"
        if {$type eq "var"} {
            append code "[::tsp::indent compUnit [::tsp::lang_assign_var_var $varPre$var "TclList.index(interp, $dataVar, (int) ${idxVar}++)"] 1]" \n
        } else {
            append code "[::tsp::indent compUnit [::tsp::lang_convert_${type}_var $varPre$var "TclList.index(interp, $dataVar, (int) ${idxVar}++)" "unable to convert var to $type"] 1]" \n
        }
        append code "    \} else \{\n"
        append code "[::tsp::indent compUnit [::tsp::lang_assign_empty_zero $varPre$var $type] 1]\n"
        append code "    \}\n"
    }
    append code "    // foreach body \n"
    append code [::tsp::indent compUnit $body]
    append code "\n    // foreach body end \n"
    append code "\n\}\n"

    return $code
}


##############################################
# generate a string command.
# implement the tcl 'string' command
# various subcommands may or may not be compiled,
# default is to return "", so that gen_command_string
# will invoke the tcl string command
#
proc ::tsp::lang_string {compUnitDict tree} {
    upvar $compUnitDict compUnit

    return [list]
}


##############################################
# generate a return command
#
proc ::tsp::lang_return {compUnit argVar} {
    return "return $argVar;\n"
}


