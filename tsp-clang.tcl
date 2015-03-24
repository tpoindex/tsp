##################################################################33

# language specific procs - c
#package require tcc4tcl
package require critcl

# force critcl to load so we can capture the original PkgInit bodhy
catch {::critcl::cproc}
variable ::tsp::critcl_pkginit [info body ::critcl::PkgInit]


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
    variable BUILTIN_TCL_COMMANDS [list		 	           \
        after       append      apply       array       binary     \
        break       case        catch       cd          chan       \
        clock       close       concat      continue    dict       \
        encoding    eof         error       eval        exec       \
        exit        expr        fblocked    fconfigure  fcopy      \
        file        fileevent   flush       for         foreach    \
        format      gets        glob        global      if         \
        incr        info        interp      join        lappend    \
        lassign     lindex      linsert     list        llength    \
        load        lrange      lrepeat     lreplace    lreverse   \
        lsearch     lset        lsort       namespace   open       \
        package     pid         proc        puts        pwd        \
        read        regexp      regsub      rename      return     \
        scan        seek        set         socket      source     \
        split       string      subst       switch      tell       \
        time        trace       unload      unset       update     \
        uplevel     upvar       variable    vwait       while      \
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
        [list gets       ""         2  2      var      load]         \
        [list lassign    ""         2  end    var      load]         \
        [list lset       ""         1  1      var      spill/load]   \
        [list regexp     --        +2  end    var      spill/load]   \
        [list regsub     --        +3  end    var      spill/load]   \
        [list scan       ""         3  end    var      load]         \
    ]
}



##############################################
# translate a tsp type to a native type, note that
# we shouldn't see 'array' as a proc argument type
#
proc ::tsp::lang_xlate_native_type {tsp_type} {
    switch $tsp_type {
        boolean {return int}
        int     {return Tcl_WideInt}
        double  {return double}
        var     {return Tcl_Obj*}
        array   {return Tcl_Obj*}
        string  {return Tcl_DString*}
    }
    # rest are also java types
    return $tsp_type
}

##############################################
# return native boolean type
#
proc ::tsp::lang_type_boolean {} {
    return int
}

##############################################
# return native int type
#
proc ::tsp::lang_type_int {} {
    return Tcl_WideInt
}

##############################################
# return native double type
#
proc ::tsp::lang_type_double {} {
    return double
}

##############################################
# return native string type: String/DString
#
proc ::tsp::lang_type_string {} {
    return Tcl_DString
}

##############################################
# return native var type
#
proc ::tsp::lang_type_var {} {
    return Tcl_Obj*
}

##############################################
# return native null reference
#
proc ::tsp::lang_type_null {} {
    return NULL
}

##############################################
# declare a native boolean
#
proc ::tsp::lang_decl_native_boolean {varName} {
    return "int $varName = 0;\n"
}

##############################################
# declare a native int
#
proc ::tsp::lang_decl_native_int {varName} {
    return "Tcl_WideInt $varName = 0;\n"
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
    return "Tcl_DString* $varName;\n"
}

##############################################
# free a native string
#
proc ::tsp::lang_free_native_string {varName} {
    return "Tcl_DStringFree(${varName});\n"
}

##############################################
# declare a tclobj 
#
proc ::tsp::lang_decl_var {varName} {
    return "Tcl_Obj* $varName = NULL;\n"
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
    return "$varName = Tcl_NewBooleanObj($value);\n"
}

##############################################
# new tclobj var as integer
#
proc ::tsp::lang_new_var_int {varName value} {
    return "$varName = Tcl_NewWideIntObj((Tcl_WideInt) $value);\n"
}

##############################################
# new tclobj var as double
#
proc ::tsp::lang_new_var_double {varName value} {
    return "$varName = Tcl_NewDoubleObj((double) $value);\n"
}

##############################################
# new tclobj var as string obj
# str must either be a quoted string const or a native string var
proc ::tsp::lang_new_var_string {varName str} {
    if {[string range $str 0 0] eq "\""} {
        return "$varName = Tcl_NewStringObj($str,-1);\n"
    } else {
        return "$varName = Tcl_NewStringObj(Tcl_DStrigValue($str), Tcl_DStringLength($str));\n"
    }
}

##############################################
# free a tcl obj var
#
proc ::tsp::lang_free_var {varName} {
    return "$varName = NULL\n;"
}

##############################################
# convert a boolean from a string value
#
proc ::tsp::lang_convert_boolean_string {targetVarName sourceVarName errMsg} {
    append result "/* ::tsp::lang_convert_boolean_string */\n"
    
    if {[string range $sourceVarName 0 0] eq "\""} {
        append result "if ((*rc = Tcl_GetBoolean(interp, $sourceVarName, $targetVarName)) != TCL_OK) \{\n"
    } else {
        append result "if ((*rc = Tcl_GetBoolean(interp, $sourceVarName, Tcl_DStringValue($targetVarName))) != TCL_OK) \{\n"

    }
    append result "    Tcl_AppendResult(interp, [::tsp::lang_quote_string $errMsg], \"$sourceVarName\", (char *) NULL);\n"
    append result "    CLEANUP;\n"
    append result "    RETURN_VALUE_CLEANUP;\n"
    append result "    return RETURN_VALUE;\n"
    append result "\}\n"
    return $result
}

##############################################
# convert a boolean from a var value
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_convert_boolean_var {targetVarName sourceVarName errMsg} {
    append result "/* ::tsp::lang_convert_boolean_var */\n"

    append result "if ((*rc = Tcl_GetBooleanFromObj(interp, $sourceVarName, &$targetVarName)) != TCL_OK) \{\n"
    append result "    Tcl_AppendResult(interp, [::tsp::lang_quote_string $errMsg], Tcl_GetString($sourceVarName), (char *) NULL);\n"
    append result "    CLEANUP;\n"
    append result "    RETURN_VALUE_CLEANUP;\n"
    append result "    return RETURN_VALUE;\n"
    append result "\}\n"
    return $result
}

##############################################
# convert a int from a string value
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_convert_int_string {targetVarName sourceVarName errMsg} {
    append result "/* ::tsp::lang_convert_int_string */\n"

    if {[string range $sourceVarName 0 0] eq "\""} {
        append result "if ((*rc = TSP_Util_lang_convert_int_string(interp, $sourceVarName, $targetVarName)) != TCL_OK) \{\n"
    } else {
        append result "if ((*rc = TSP_Util_lang_convert_int_string(interp, $sourceVarName, Tcl_DStringValue($targetVarName))) != TCL_OK) \{\n"
    }
#FIXME: see Tcl_GetInt()   but convert use Tcl_GetWideIntFromObj instead.
    append result "    Tcl_AppendResult(interp, [::tsp::lang_quote_string $errMsg], Tcl_GetString($sourceVarName), (char *) NULL);\n"
    append result "    CLEANUP;\n"
    append result "    RETURN_VALUE_CLEANUP;\n"
    append result "    return RETURN_VALUE;\n"
    append result "\}\n"
    return $result
}

##############################################
# convert a int from a boolean value
#
proc ::tsp::lang_convert_int_boolean {targetVarName sourceVarName {errMsg ""}} {
    append result "/* ::tsp::lang_convert_int_boolean */\n"
    append result "$targetVarName = $sourceVarName ? 1 : 0;\n"
    return $result
}

##############################################
# convert a int from a double value
#
proc ::tsp::lang_convert_int_double {targetVarName sourceVarName {errMsg ""}} {
    append result "/* ::tsp::lang_convert_int_double */\n"
    append result "$targetVarName = (Tcl_WideInt) $sourceVarName;\n"
    return $result
}

##############################################
# convert a double from a string value
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_convert_double_string {targetVarName sourceVarName errMsg} {
    append result "/* ::tsp::lang_convert_double_string */\n"

    if {[string range $sourceVarName 0 0] eq "\""} {
        append result "if ((*rc = Tcl_GetDouble(interp, $sourceVarName, $targetVarName)) != TCL_OK) \{\n"
    } else {
        append result "if ((*rc = Tcl_GetDouble(interp, $sourceVarName, Tcl_DStringValue($targetVarName))) != TCL_OK) \{\n"

    }
    append result "    Tcl_AppendResult(interp, [::tsp::lang_quote_string $errMsg], \"$sourceVarName\", (char *) NULL);\n"
    append result "    CLEANUP;\n"
    append result "    RETURN_VALUE_CLEANUP;\n"
    append result "    return RETURN_VALUE;\n"
    append result "\}\n"
    return $result
}

##############################################
# convert an int from a var value
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_convert_int_var {targetVarName sourceVarName errMsg} {
    append result "/* ::tsp::lang_convert_int_var */\n"

    append result "if ((*rc = Tcl_GetWideIntFromObj(interp, $sourceVarName, &$targetVarName)) != TCL_OK) \{\n"
    append result "    Tcl_AppendResult(interp, [::tsp::lang_quote_string $errMsg], \"$sourceVarName\", (char *) NULL);\n"
    append result "    CLEANUP;\n"
    append result "    RETURN_VALUE_CLEANUP;\n"
    append result "    return RETURN_VALUE;\n"
    append result "\}\n"
    return $result
}

##############################################
# convert a double from a var value
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_convert_double_var {targetVarName sourceVarName errMsg} {
    append result "/* ::tsp::lang_convert_double_var */\n"

    append result "if ((*rc = Tcl_GetDoubleFromObj(interp, $sourceVarName, &$targetVarName)) != TCL_OK) \{\n"
    append result "    Tcl_AppendResult(interp, [::tsp::lang_quote_string $errMsg], \"$sourceVarName\", (char *) NULL);\n"
    append result "    CLEANUP;\n"
    append result "    RETURN_VALUE_CLEANUP;\n"
    append result "    return RETURN_VALUE;\n"
    append result "\}\n"
    return $result
}

##############################################
# convert a string from a boolean value
#
proc ::tsp::lang_convert_string_boolean {targetVarName sourceVarName {errMsg ""}} {
    append result "/* ::tsp::lang_convert_string_boolean */\n"
    append result "Tcl_DStringSetLength($targetVarName,0);\n"
    append result "Tcl_DStringAppend($targetVarName, ($sourceVarName ? : \"1\" : \"0\"), -1);\n"
    return $result
}

##############################################
# convert a string from an int value
#
proc ::tsp::lang_convert_string_int {targetVarName sourceVarName {errMsg ""}} {
    append result "/* ::tsp::lang_convert_string_int */\n"
    append result "TSP_Util_lang_convert_string_int(interp, &$targetVarName, $sourceVarName);\n"
#FIXME: see UpdateStringOfWideInt()
    return $result
}

##############################################
# convert a string from a double value
#
proc ::tsp::lang_convert_string_double {targetVarName sourceVarName {errMsg ""}} {
    append result "/* ::tsp::lang_convert_string_double */\n"
    append result "TSP_Util_lang_convert_string_double(interp, &$targetVarName, $sourceVarName);\n"
#FIXME: see Tcl_PrintDouble()
    return $result
}

##############################################
# convert a string from a string value
#
proc ::tsp::lang_convert_string_string {targetVarName sourceVarName {errMsg ""}} {
    append result "/* ::tsp::lang_convert_string_string */\n"
    append result "Tcl_DStringSetLength($targetVarName,0);\n"
    append result "Tcl_DStringAppend($targetVarName, Tcl_DStringValue($sourceVarName), Tcl_DStringLength($sourceVarName));\n"
    return $result
}

##############################################
# convert a string from a var value
#
proc ::tsp::lang_convert_string_var {targetVarName sourceVarName {errMsg ""}} {
    append result "/* ::tsp::lang_convert_string_var */\n"
    append result "Tcl_DStringSetLength($targetVarName,0);\n"
    append result "TSP_Util_lang_convert_string_var(&$targetVarName, $sourceVarName);\n"
#FIXME: Tcl_GetStringFromObj, set DString as a result
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
    return "TSP_Util_lang_get_string_int($sourceVarName)"
}

##############################################
# get a string from a double value
#
proc ::tsp::lang_get_string_double {sourceVarName} {
    return "TSP_Util_lang_get_string_double($sourceVarName)"
}

##############################################
# get a string from a string value
#
proc ::tsp::lang_get_string_string {sourceVarName} {
    return "Tcl_DStringValue($sourceVarName)"
}

##############################################
# get a string from a var value
#
proc ::tsp::lang_get_string_var {sourceVarName} {
    return "Tcl_GetString($sourceVarName)"
}


##############################################
# preserve / incrRefCount a TclObject variable
#
proc ::tsp::lang_preserve {obj} {
    return "Tcl_IncrRefCount($obj);\n"
}

##############################################
# release / decrRefCount a TclObject variable
#
proc ::tsp::lang_release {obj} {
    return "Tcl_DecrRefCount($obj);\n"
}

##############################################
# safe release / decrRefCount a TclObject variable
# and set object to null.
# checks for null before release
#
proc ::tsp::lang_safe_release {obj} {
    return "if ($obj != NULL) { Tcl_DecrRefCount($obj); $obj = NULL; } \n"
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
    if {[string is wideinteger $n]} {
        append n LL
    }
    return $n
}

##############################################
# double constant
# appends double designation for java
proc ::tsp::lang_double_const {n} {
    if {[string is wideinteger $n] || [string is double $n]} {
        append n d
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
    set code "/*::tsp::lang_assign_empty_zero */\n"
    switch $type {
        boolean {append code "$var = 0;\n"}
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
    append result "/* ::tsp::lang_array_get_array_idxvar */\n"

    append result "$targetObj = Tcl_GetVar2Ex(interp, $arrVar, [::tsp::lang_get_string_$idxVartype $idxVar], TCL_LEAVE_ERR_MSG);\n"
    append result "if ($targetObj == NULL) \{\n"
    append result "    /* Tcl_AppendResult(interp, [::tsp::lang_quote_string $errMsg], (char *) NULL);*/\n"
    append result "    CLEANUP;\n"
    append result "    RETURN_VALUE_CLEANUP;\n"
    append result "    return RETURN_VALUE;\n"
    append result "\}\n"
    return $result
}

##############################################
# assign a TclObject from a interp array with a text index or var index
# idxTxtVar should either be a quoted string, or a string
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_assign_var_array_idxtext {targetObj arrVar idxTxtVar errMsg} {
    append result "/* ::tsp::lang_array_get_array_idxtext */\n"

    append result "$targetObj = Tcl_GetVar2Ex(interp, $arrVar, $idxTxtVar, TCL_LEAVE_ERR_MSG);\n"
    append result "if ($targetObj == NULL) \{\n"
    append result "    /* Tcl_AppendResult(interp, [::tsp::lang_quote_string $errMsg], (char *) NULL);*/\n"
    append result "    CLEANUP;\n"
    append result "    RETURN_VALUE_CLEANUP;\n"
    append result "    return RETURN_VALUE;\n"
    append result "\}\n"
    return $result

    return $result
}

##############################################
# get a TclObject from a interp array with a scalar or var index
#
proc ::tsp::lang_array_get_array_idxvar {arrVar idxVar idxVartype} {
#FIXME: is this even used???? if not remove here and in tsp-java.tcl
    append result "/* ::tsp::lang_array_get_array_idxvar */\n"
    append result "interp.getVar($arrVar, [::tsp::lang_get_string_$idxVartype $idxVar], 0);"
    return $result
}


##############################################
# assign a native string from a literal constant
# note that errMsg should be passed unquoted (done here)
#
proc ::tsp::lang_assign_string_const {targetVarName sourceText} {
    append result "/* ::tsp::lang_assign_string_const */\n"
    append result "Tcl_DStringSetLength($targetVarName,0);\n" 
    append result "Tcl_DStringAppend($targetVarName, [::tsp::lang_quote_string $sourceText], -1);\n"
    return $result
}


##############################################
# assign a tclobj var from a boolean constant
#
proc ::tsp::lang_assign_var_boolean {targetVarName sourceVarName {preserve 1}} {
    append result "/* ::tsp::lang_assign_var_boolean */\n"

    append result "$targetVarName = TSP_Util_lang_assign_var_boolean($targetVarName, $sourceVarName);\n"
    return $result
}

##############################################
# assign a tclobj var from an int constant
#
proc ::tsp::lang_assign_var_int {targetVarName sourceVarName {preserve 1}} {
    append result "/* ::tsp::lang_assign_var_int */\n"

    append result "$targetVarName = TSP_Util_lang_assign_var_int($targetVarName, (TCL_LL_MODIFIER) $sourceVarName;\n"
    return $result
}

##############################################
# assign a tclobj var from an double constant
#
proc ::tsp::lang_assign_var_double {targetVarName sourceVarName {preserve 1}} {
    append result "/* ::tsp::lang_assign_var_double */\n"

    append result "$targetVarName = TSP_Util_lang_assign_var_double($targetVarName, (double) $sourceVarName);\n"
    return $result
}

##############################################
# assign a tclobj var from an native string 
#
proc ::tsp::lang_assign_var_string {targetVarName sourceVarName {preserve 1}} {
    append result "/* ::tsp::lang_assign_var_string */\n"

    append result "$targetVarName = TSP_Util_lang_assign_var_string($targetVarName, $sourceVarName);\n"
    return $result
}


##############################################
# assign a tclobj var from a tclobj var
#
proc ::tsp::lang_assign_var_var {targetVarName sourceVarName {preserve 1}} {
    append result "/* ::tsp::lang_assign_var_var */\n"

    append result "$targetVarName = TSP_Util_lang_assign_var_var($targetVarName, $sourceVarName);\n"
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
    append result "/* ::tsp::lang_assign_array_var */\n"

    append result "TSP_Util_lang_assign_array_var(interp, $targetArrayStr, $targetIdxStr, $var);\n"
    return $result
}


##############################################
# append a string to a native string
# source should either be a native string variable or
# quoted string constant
#
proc ::tsp::lang_append_string {targetVarName source} {
    append result "/* ::tsp::lang_append_string */\n"
    append result "$targetVarName = $targetVarName + $source;\n"
    return $result
}


##############################################
# append a string to a var
# source should either be a native string variable or
# quoted string constant
#
proc ::tsp::lang_append_var {targetVarName source} {
    append result "/* ::tsp::lang_append_var */\n"
    if {[string range $source 0 0] eq "\""} {
        append result "Tcl_AppendToObj($targetVarName, $source, -1);\n"
    } else {
        append result "Tcl_AppendToObj($targetVarName, Tcl_DStringValue($source), Tcl_DStringLength($source));\n"
    }
    return $result
}


##############################################
# append a TclObject var to list
#
proc ::tsp::lang_lappend_var {targetVarName sourceVarName} {
    append result "/* ::tsp::lang_lappend_var */\n"
    append result "Tcl_ListObjAppendElement(interp, $targetVarName, $sourceVarName);\n"
    return $result
}


##############################################
# duplicate a TclObject var if shared, or assign as
# empty if null
#
proc ::tsp::lang_dup_var_if_shared {targetVarName} {
    append result "/* ::tsp::lang_dup_var_if_shared */\n"
    append result "if ($targetVarName != NULL) \{\n"
    append result "    if (Tcl_IsShared($targetVarName)) \{\n"
    append result "        [::tsp::lang_release $targetVarName]"
    append result "        $targetVarName = Tcl_DuplicateObj($targetVarName);\n"
    append result "    \}\n"
    append result "\} else \{\n"
    append result "    [::tsp::lang_new_var_string $targetVarName {""}]"
    append result "\}\n"
    return $result
}



##############################################
# allocate a TclObject objv array
#
proc ::tsp::lang_alloc_objv_array {compUnitDict size} {
#FIXME: track argObjvArray size, only free/alloc when too small
    upvar $compUnitDict compUnit
    set cmdLevel [dict get $compUnit cmdLevel]
    ::tsp::addArgsPerLevel compUnit $cmdLevel $size
    #append result "if (argObjvArray_$cmdLevel != NULL) \{\n"
    #append result "    ckfree(argObjvArray_$cmdLevel);\n"
    #append result "\}\n"
    #append result "argObjvArray_$cmdLevel = ckalloc($size * sizeof(Tcl_Obj *));\n"
    #append result "argObjc_$cmdLevel = $size;\n"
    #return $result
    return ""
}

##############################################
# assign a TclObject var to a TclObject objv array
#
proc ::tsp::lang_assign_objv {compUnitDict n max obj} {
    upvar $compUnitDict compUnit
    set cmdLevel [dict get $compUnit cmdLevel]
    ::tsp::addArgsPerLevel compUnit $cmdLevel $max
    return "argObjvArray_$cmdLevel\[$n\] = $obj;\n"
}


##############################################
# invoke a builtin tcl command
#  assumes argObjvArray has been constructed
#
proc ::tsp::lang_invoke_builtin {compUnitDict cmd} {
    upvar $compUnitDict compUnit
    set cmdLevel [dict get $compUnit cmdLevel]

    append code "\n/*  ::tsp::lang_invoke_builtin */\n"
    append code "if ((*rc = (TSP_Cmd_builtin_$cmd) ((ClientData)NULL, interp,  argObjc_$cmdLevel, argObjvArray_$cmdLevel)) != TCL_OK) \{\n"
    append code "    CLEANUP;\n"
    append code "    RETURN_VALUE_CLEANUP;\n"
    append code "    return RETURN_VALUE;\n"
    append code "\}\n"

    append code [::tsp::lang_safe_release _tmpVar_cmdResultObj]
    append code "_tmpVar_cmdResultObj = Tcl_GetObjResult(interp);\n"
    append code [::tsp::lang_preserve _tmpVar_cmdResultObj] \n
    return [list _tmpVar_cmdResultObj $code]
}


##############################################
# allocate a TclObject objv list
#
proc ::tsp::lang_alloc_objv_list {varName} {
    return "$varName = Tcl_NewListObj(0, NULL);\n"
}


##############################################
# invoke a tcl command via the interp
#  assumes argObjvArray has been constructed
#
proc ::tsp::lang_invoke_tcl {compUnitDict} {
    upvar $compUnitDict compUnit
    set cmdLevel [dict get $compUnit cmdLevel]

    append code "\n/*  ::tsp::lang_invoke_tcl */\n"
    append code "Tcl_EvalObjv(interp, argObjc_$cmdLevel, argObjvArray_$cmdLevel, 0);\n"
    append code [::tsp::lang_safe_release _tmpVar_cmdResultObj]
    append code "_tmpVar_cmdResultObj = Tcl_GetObjResult(interp);\n"
    append code [::tsp::lang_preserve _tmpVar_cmdResultObj] \n
    return [list _tmpVar_cmdResultObj $code]
}


##############################################
# invoke a tcl command that is a previously compiled tsp proc
# argList should only be native types
# any args that are Tcl vars should be preserved/released
# 
proc ::tsp::lang_invoke_tsp_compiled {cmdName procType returnVar argList preserveArgList} {
    if {$procType eq "void"} {
        set invokeArgs "interp"
    } else {
        set invokeArgs "interp, &returnVar"
    }
    if {[string length $argList]} {
        append invokeArgs ", [join $argList ", "]"
    }
    append code "/*  ::tsp::lang_invoke_tsp_compiled */\n"
    if {$procType eq "var"} {
        append code [::tsp::lang_safe_release $returnVar]
    } elseif {$procType eq "string"} {
        append code "Tcl_DStringSetLength($returnVar, 0);\n"
    }
    append code "if ((*rc = TSP_User_${cmdName}_direct($invokeArgs)) != TCL_OK) \{\n"
    append code "    \n"
    append code "\}\n"
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
                append buf "if ($var != NULL) \{\n"
                append buf "    Tcl_DecrRefCount($var);\n"
                append buf "\}\n"
            }
            string { 
                append buf "Tcl_DStringFree($var);\n"
            }
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
    set procVarsDecls ""
    set procVarsCleanup ""
    set procStringsInit ""
    set declStringsInit ""
    set procStringsCleanup ""
    set declStringsCleanup ""
    set procStringsAlloc ""
    set copyStringArgs ""

    # create: assignments from proc args to scoped variables; 
    #         declarations of scoped variables
    #         cleanup code for arguments (var types)
    #         code to preserve var types in inner method
    foreach arg $procArgs {
        set type [lindex $procArgTypes $i]
        # rest of foreach needs i+1
        incr i
        set nativeType [::tsp::lang_xlate_native_type $type]
        if {$type eq "string"} { 
            # strings are passed as pointers
            append nativeTypedArgs $comma $nativeType " " Caller_$arg 
            append declProcArgs [::tsp::lang_decl_native_$type $arg]
            # and define as proc variables
            append procVarsDecls [::tsp::lang_decl_native_string $arg]
            append procStringsInit "Tcl_DStringInit($arg);\n"
            append declStringsInit "Tcl_DStringInit(&$arg);\n"
            append procStringsCleanup "Tcl_DStringCleanup($arg);\n"
            append declStringsCleanup "Tcl_DStringCleanup($arg);\n"
            # and copy from argument
            append copyStringArgs "Tcl_DStringAppend($arg, Tcl_DStringValue(Caller_$arg), Tcl_DStringLength(Caller_$arg));\n"
        } else {
            append nativeTypedArgs $comma $nativeType " " $arg 
            append declProcArgs [::tsp::lang_decl_native_$type $arg]
        }
        if {$type eq "var"} {
            append argVarAssignments [::tsp::lang_assign_var_var $arg  objv\[$i\]]
            append innerVarPreserves [::tsp::lang_preserve $arg]
        } else {
            append argVarAssignments [::tsp::lang_convert_${type}_var $arg objv\[$i\] "can't convert arg $i to $type"]
        }
        set comma ", "
    }

    # argVarAssignments need to use local 'rc' variable, not a pointer
    regsub -all {\*rc} $argVarAssignments {rc} argVarAssignments

    if {[string length $nativeTypedArgs]} {
        set nativeTypedArgs ", $nativeTypedArgs"
    }

    # create the inner method return assignment operation and declaration 
    set numProcArgs [llength $procArgs]
    set returnType [dict get $compUnit returns]
    set nativeReturnType [::tsp::lang_xlate_native_type $returnType]
    switch $returnType {
        var {
            set returnVar returnValue
            set returnVarDecl [::tsp::lang_decl_native_$returnType returnValue]
            set returnVarAssignment "returnValue = "
            set returnSetResult "Tcl_SetObjResult(interp, returnValue);"
            set returnAlloc ""
        } 
        string {
            # note that string return type returns a pointer to an alloc'ed Tcl_DString
            set returnVar returnValue
            set returnVarDecl [::tsp::lang_decl_native_$returnType returnValue]
            set returnVarAssignment "returnValue = "
            set returnSetResult "Tcl_DStringResult(interp, returnValue); ckfree(returnValue);"
            set returnAlloc "Tcl_DStringInit((returnValue = ckalloc((sizeof Tcl_DString)));"
        } 
        boolean {
            set returnVar returnValue
            set returnVarDecl [::tsp::lang_decl_native_$returnType returnValue]
            set returnVarAssignment "returnValue = "
            set returnSetResult "Tcl_SetObjResult(interp, Tcl_NewBooleanObj((int) returnValue));"
            set returnAlloc ""
        }
        double {
            set returnVar returnValue
            set returnVarDecl [::tsp::lang_decl_native_$returnType returnValue]
            set returnVarAssignment "returnValue = "
            set returnSetResult "Tcl_SetObjResult(interp, Tcl_NewDoubleObj((double) returnValue));"
            set returnAlloc ""
        }
        int {
            set returnVar returnValue
            set returnVarDecl [::tsp::lang_decl_native_$returnType returnValue]
            set returnVarAssignment "returnValue = "
            set returnSetResult "Tcl_SetObjResult(interp, Tcl_NewWideIntObj((Tcl_WideInt) returnValue));"
            set returnAlloc ""
        } 
        default {
            set returnVar ""
            set returnVarDecl ""
            set returnVarAssignment ""
            set returnSetResult "Tcl_ResetResult(interp);"
            set returnAlloc ""
        }
    }

    # create inner method proc vars and cleanup code (for vars and string)
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
        } elseif {$type eq "string"} {
            append procVarsDecls [::tsp::lang_decl_native_string $pre$var]
            append procStringsAlloc "Tcl_DString Proc_$pre$var;\n"
            append procStringsInit "Tcl_DStringInit(&Proc_$pre$var);\n"
            append procStringsInit "$pre$var = &Proc_$pre$var;\n"
            append procStringsCleanup "Tcl_DStringCleanup($pre$var);\n"
        } elseif {$type ne "array"} {
            append procVarsDecls [::tsp::lang_decl_native_$type $pre$var]
        }
    }
    
    # create the argObjvArrays, one for each level of command nesting
    set argObjvArrays ""
    set argObjvAlloc ""
    set argObjvFree ""
    set maxLevel [dict get $compUnit maxLevel]
    if {[llength [dict get $compUnit argsPerLevel]]} {
        for {set i 0} {$i <= $maxLevel} {incr i} {
            append argObjvArrays "\n    Tcl_Obj** argObjvArray_$i = NULL;"
            append argObjvArrays "\n    int       argObjc_$i = 0;"
            set size [lindex [dict get $compUnit argsPerLevel $i] end]
            append argObjvAlloc  "\n    argObjvArray_$i = ckalloc($size * sizeof(Tcl_Obj *));"
            append argObjvFree   "    ckfree(argObjvArray_$i);\n"
        }
    }

    append cleanup_defs "#define CLEANUP " \ \n
    append cleanup_defs [::tsp::indent compUnit [::tsp::lang_spill_vars compUnit [dict get $compUnit finalSpill]] 1 \n]
    append cleanup_defs [::tsp::indent compUnit [::tsp::lang_safe_release _tmpVar_cmdResultObj] 1 \n]
    append cleanup_defs [::tsp::indent compUnit $procVarsCleanup 1 \n]
    append cleanup_defs [::tsp::indent compUnit $procStringsCleanup 1 \n]
    append cleanup_defs [::tsp::indent compUnit $argObjvFree 1 \n]

    set arg_cleanup_defs ""
    if {[string length $declStringsCleanup]} {
        append arg_cleanup_defs "#define CLEANUP " \ \n
        append arg_cleanup_defs [::tsp::indent compUnit $declStringsCleanup 1 \n]
    } else {
        append arg_cleanup_defs "#define CLEANUP \n"
    }

    regsub "^\[ \n\]*" $cleanup_defs {} cleanup_defs
    regsub -all {\n *$} $cleanup_defs "\n" cleanup_defs
    regsub -all {\n} $cleanup_defs "\\\n" cleanup_defs
    append cleanup_defs "    Tcl_PopCallFrame(interp); \\\n" 
    append cleanup_defs "    ckfree((char*)frame) \n"

    regsub "^\[ \n\]*" $arg_cleanup_defs {} arg_cleanup_defs
    regsub -all {\n *$} $arg_cleanup_defs "\n" arg_cleanup_defs
    regsub -all {\n} $arg_cleanup_defs "\\\n" arg_cleanup_defs
    
    if {$returnType eq "void"} {
        set return_cleanup_def "#define RETURN_VALUE_CLEANUP"
        set return_var_def "#define RETURN_VALUE"
    } elseif {$returnType eq "string"} {
        set return_cleanup_def "#define RETURN_VALUE_CLEANUP ckfree(returnValue); returnValue = (Tcl_DString*)NULL"
        set return_var_def "#define RETURN_VALUE returnValue"
    } else {
        set return_cleanup_def "#define RETURN_VALUE_CLEANUP"
        set return_var_def "#define RETURN_VALUE returnValue"
    }

    # class template

    set cfileTemplate1 \
{

#include <tcl.h>

$cleanup_defs

$return_cleanup_def

$return_var_def

/* 
 * proc implementation (inner)
 *
 */
$nativeReturnType
TSP_UserDirect_${name}(Tcl_Interp* interp, int* rc  $nativeTypedArgs ) {
    int len;
    $returnVarDecl
    char* exprErr = NULL;
    Tcl_Obj* _tmpVar_cmdResultObj = NULL;
    Tcl_CallFrame* frame = NULL;
    [::tsp::indent compUnit \n$argObjvArrays 1 \n]

    /* stack allocated strings */
    [::tsp::indent compUnit \n$procStringsAlloc 1 \n]

    $returnAlloc

    /* variables defined in proc, plus temp vars */
    [::tsp::indent compUnit $procVarsDecls 1 \n]

    /* initialize string vars */
    [::tsp::indent compUnit $procStringsInit 1 \n]

    /* any "var" arguments need to be preserved, since they are released in CLEANUP */
    [::tsp::indent compUnit $innerVarPreserves 1 \n]

    /* any "string" arguments need to be copied (FIXME: investigate using COW for strings) */
    [::tsp::indent compUnit $copyStringArgs 1 \n]

    frame = (Tcl_CallFrame*) ckalloc(sizeof(Tcl_CallFrame));
    Tcl_PushCallFrame(interp, frame, Tcl_GetGlobalNamespace(interp), 1);

    *rc = TCL_OK;     

    /* code must return a value as defined by procdef (unless void), else will raise a compile error */
    [::tsp::indent compUnit $code 1]


}


/* redefine macros for the Tcl interface function */

#undef CLEANUP
#undef RETURN_VALUE_CLEANUP
#undef RETURN_VALUE

$arg_cleanup_defs
#define RETURN_VALUE_CLEANUP rc = rc
#define RETURN_VALUE rc

/* 
 * Tcl command interface 
 *
 */

}
# end of cfileTemplate1

    # defined by critcl::ccomand: 
    #   int TSP_UserCmd_${name}(ClientData unused, Tcl_Interp* interp, int objc, Tcl_Obj *const objv\[\]) 

    set cfileTemplate2 \
{


    int rc;
    /*::tsp::lang_builtin_refs */

    $returnVarDecl
    /* variables used by this command, assigned from objv array */
    [::tsp::indent compUnit $declProcArgs 1 \n]


    /* check arg count */
    if (objc != [expr {$numProcArgs + 1}]) {
        Tcl_WrongNumArgs(interp, 1, objv, "[join [dict get $compUnit args]]");
        return TCL_ERROR;
    }

    /* assign arg variable from objv array */
    [::tsp::indent compUnit $argVarAssignments 1 \n]

    rc = TCL_OK;
    /* invoke inner compile proc method */

    returnValue = TSP_UserDirect_${name}(interp, &rc ${nativeArgs});
    if (rc == TCL_OK) {
        $returnSetResult
    } else {
    }

    /* release string variables, if any  */
    CLEANUP;
    
    return rc;

}
# end of cfileTemplate2

    # critcl needs two pieces, one for ccode and another form ccommand, so return as a list

    #puts [subst $cfileTemplate1]
    #puts [subst $cfileTemplate2]

    return [list [subst $cfileTemplate1] [subst $cfileTemplate2]]
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
        # debugging critcl
        ::critcl::config lines 0
        ::critcl::config keepsrc 1
        ::critcl::cache ./.critcl
        ::critcl::clean_cache

        # redefine internal critcl print to not print
        ::proc ::critcl::print {args} {}

        #redefine internal critcl PkgInit to return a custom package name
        ::proc ::critcl::PkgInit {file} [list return Tsp_user_pkg_foo_${name}]

        # tcl 8.5 has wide ints, make that the min version
        ::critcl::tcl 8.5

        # cause compile to fail if return is not coded in execution branch
        ::critcl::cflags -Werror=return-type

        # create the code, first is the inner proc (ccode), second is the tcl interface (ccommand)
        ::critcl::ccode [lindex $code 0]
        ::critcl::ccommand ::$name {clientData interp objc objv} [lindex $code 1]

	# cause critcl to compile the code and load the resulting .so lib
        ::critcl::load

        dict set compUnit compiledReference tsp.cmd.${name}Cmd
        format "done"
    } result ]
    set errors [dict get [critcl::cresults] log]
puts "---------------------------------------------------------"
puts "rc = $rc"
puts "result = $result"
puts "errors = $errors"
puts "---------------------------------------------------------"
    if {$rc} {
        ::tsp::addError compUnit "error compiling $name:\n$result\n$errors"
    }
    critcl::reset

    # reset the PkgInit proc for other critcl usage
    ::proc ::critcl::PkgInit {file} $::tsp::critcl_pkginit
    return $rc
}


##############################################
# define a compiledReference in the interp
#
proc ::tsp::lang_interp_define {compUnitDict} {
    # this is handled by critcl
    return
}


##############################################
# build a list of builtin command references
# for c, this goes into TSP_cmd
#
proc ::tsp::lang_builtin_refs {} {
    append result "#ifndef _TCL\n"
    append result "#include <tcl.h>\n"
    append result "#endif\n\n"

    append result "void*\n"
    append result "TSP_User_getCmd(Tcl_Interp* interp, char* cmd) \{\n"
    append result "    Tcl_CmdInfo cmdInfo;\n"
    append result "    int rc;\n"
    append result "    Tcl_ObjCmdProc* objCmd;\n"
    append result "    void* userCmd = NULL;\n"
    append result "    rc = Tcl_GetCommandInfo(interp, cmd, &cmdInfo);\n"
    append result "    if (rc == 0) \{\n"
    append result "        Tcl_Panic(\"TSP_User_getCmd: can't get command proc for %s\", cmd);\n"
    append result "    \} else \{\n"
    append result "       objCmd = cmdInfo.objProc;\n"
    append result "       rc = objCmd(&userCmd, interp, 0, NULL);\n"
    append result "       return userCmd;\n"
    append result "    \}\n"
    append result "\}\n\n"

    append result "Tcl_ObjCmdProc*\n"
    append result "TSP_Cmd_getCmd(Tcl_Interp* interp, char* cmd) \{\n"
    append result "    Tcl_CmdInfo cmdInfo;\n"
    append result "    int rc;\n"
    append result "    rc = Tcl_GetCommandInfo(interp, cmd, &cmdInfo);\n"
    append result "    if (rc == 0) \{\n"
    append result "        Tcl_Panic(\"TSP_Cmd_getCmd: can't get command proc for %s\", cmd);\n"
    append result "    \} else \{\n"
    append result "        return cmdInfo.objProc;\n"
    append result "    \}\n"
    append result "\}\n\n\n"

    foreach cmd $::tsp::BUILTIN_TCL_COMMANDS {
        append result "int\n"
        append result "TSP_Cmd_builtin_$cmd (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) \{\n"
        append result "    static Tcl_ObjCmdProc* cmdProc = NULL;\n"
        append result "    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, \"::$cmd\");}\n" 
        append result "    return (cmdProc)(clientData, interp, objc, objv);\n"
        append result "\}\n\n"
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
    if {[string first TSP_Func_ $exprAssignment] == -1} {
        return $exprAssignment
    } else {
        append result "exprErr = NULL;"
        # add first argument as exprErr pointer for functions
        regsub -all {(TSP_Func_[^(]*\()(/*)} $exprAssignment {\1\&exprErr,\2} exprAssignment
        # but fix for functions that have no args :-)
        regsub -all {&exprErr,\)} $exprAssignment {)} exprAssignment
        append result "$exprAssignment"
        append result "if (exprErr != NULL) \{\n"
        append result "    Tcl_ResetResult(interp);\n"
        append result "    Tcl_AppendResult(interp, exprErr, (char*)NULL);\n"
        append result "    *rc = TCL_ERROR;\n"
        append result "    CLEANUP;\n"
        append result "    RETURN_VALUE_CLEANUP;\n"
        append result "\}\n"
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

    set buf "/* ::tsp::::tsp::lang_spill_vars $varList */\n"
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

        append buf "/* interp.setVar $var */\n"
        if {$type eq "var"} {
            append buf "if ($pre$var == NULL) \{\n"
            append buf "    $pre$var = Tcl_NewStringObj(\"\");\n"
            append buf "    Tcl_IncrRefCount($pre$var);\n"
            append buf "\}\n"
            append buf "Tcl_SetVar2Ex(interp, [::tsp::lang_quote_string  $var], NULL, $pre$var, 0);\n"
        } else {
            switch $type {
                boolean {set newobj "Tcl_NewBooleanObj($pre$var)"}
                int     {set newobj "Tcl_NewWideIntObj($pre$var)"}
                double  {set newobj "Tcl_NewDoubleObj($pre$var)"}
                string  {set newobj "Tcl_NewStringObj(Tcl_DStringValue($pre$var), Tcl_DStringLength($pre$var))"}
            }
            append buf "Tcl_SetVar2Ex(interp,[::tsp::lang_quote_string  $var], NULL, $newobj, 0);\n"
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
            append buf "/* ::tsp::lang_load_vars  interp.getVar $var */\n"
            append buf [::tsp::lang_safe_release $interpVar]
            append buf "$interpVar = Tcl_GetVar2Ex(interp,[::tsp::lang_quote_string $var], NULL, 0);\n"
            append buf "if ($interpVar != NULL) \{\n"
            append buf "    [::tsp::lang_preserve $interpVar]"
            if {! $isvar} {
                # for not-var types, convert into native type
                append buf [::tsp::indent compUnit [::tsp::lang_convert_${type}_var $pre$var $interpVar "can't convert var \"$var\" to type: \"$type\""] 1]
            } 
            append buf "\n\} else \{\n"
            append buf "[::tsp::indent compUnit [::tsp::lang_assign_empty_zero $pre$var $type] 1]\n"
            if {$isvar} {
                append buf "[::tsp::indent compUnit [::tsp::lang_preserve $pre$var] 1]\n"
            }
            append buf "\}\n"
        } else {
            # no try/catch here - if variable is deleted, or cannot be converted, allow TclException to be thrown.
            # program needs to catch for this case
            append buf "/* ::tsp::lang_load_vars  interp.getVar $var */\n"
            append buf [::tsp::lang_safe_release $interpVar]
            append buf "$interpVar = Tcl_GetVar2Ex(interp,[::tsp::lang_quote_string $var], NULL, 0);\n"
            append buf "if ($interpVar == NULL) \{\n"
            append buf "    Tcl_AppendResult(interp, [::tsp::lang_quote_string "cannot load $var from interp"], (char*)NULL);\n"
            append buf "    *rc = TCL_ERROR;\n"
            append buf "    CLEANUP;\n"
            append buf "    RETURN_VALUE_CLEANUP;\n"
            append buf "\}\n"
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
    append code "/* lang_llength */\n"
    append code "if ((rc = Tcl_ListObjLength(interp, $argVar, &len) == TCL_OK) \{\n"
    append code "    $returnVar = len;\n"
    append code "\} else \{\n"
    append code "    Tcl_AppendResult(interp, errMsg, (char*)NULL);\n"
    append code "    *rc = TCL_ERROR;\n"
    append code "    CLEANUP;\n"
    append code "    RETURN_VALUE_CLEANUP;\n"
    append code "\}\n"
    return $code
}


##############################################
# lindex TclObject var
# implement the tcl 'lindex' command
#
proc ::tsp::lang_lindex {returnVar argVar idx isFromEnd {errMsg {""}}} {
    #FIXME: should we just let getLength() provide the error message?
    append code "/* lang_lindex */\n"
    append code "try \{\n"
    if {$isFromEnd} {
        append code "    int listLength = TclList.getLength(interp, $argVar);\n"
        append code "    $returnVar = TclList.index(interp, $argVar, (int) (listLength - 1 - $idx));\n"
    } else {
        append code "    $returnVar = TclList.index(interp, $argVar, (int) $idx);\n"
    }
    append code "    if ($returnVar == NULL) \{\n"
    append code "        [::tsp::lang_new_var_string $returnVar {""}]"
    append code "    \}\n"
    append code "    $returnVar.preserve();\n"
    append code "\} catch (TclException te) \{\n"
    append code "    throw new TclException(interp, $errMsg);\n"
    append code "\}\n"
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
            # code to assign one variable, the rest as NULL/zero, execute body
            set target [lindex $varList 0]
            set targetType [::tsp::getVarType compUnit $target]
            set rest [lrange $varList 1 end]
            
            set dataListPre [::tsp::var_prefix $dataList]
            set targetPre   [::tsp::var_prefix $target]

            if {$targetType eq $dataListType} {
                append code "$target = $dataListPre$dataList;\n"
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
proc ::tsp::lang_return {compUnitDict argVar} {
    upvar $compUnitDict compUnit
    set returnType [dict get $compUnit returns]
    switch $returnType {
        string {append code "Tcl_DStringAppend(returnValue, Tcl_DStringValue($argVar), Tcl_DStringLength($argVar));\n"}
        var    {append code "*returnValue = Tcl_DuplicateObj($argVar);\n"}
        default {append code "returnValue = $argVar;\n"}
    }
    append code "*rc = TCL_OK;\n"
    append code "CLEANUP;\n"
    append code "RETURN_VALUE_CLEANUP;\n"
    append code "return RETURN_VALUE;\n"
    return $code
}


