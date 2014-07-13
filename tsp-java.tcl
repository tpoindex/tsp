
# language specific procs - java 


# interpreter builtin commands that we can call directly
# exclude commands that are compiled by tsp::gen_command_*
# this should match the 

proc ::tsp::lang_init {} {
    set ::tsp::BUILTIN_TCL_COMMANDS [list]
    foreach cmd {
	    after		append		apply		array		binary		
	    break		case		catch		cd		clock		
	    close		continue	concat		dict		encoding		
	    eof			eval		error		exec		exit		
	    expr		fblocked	fconfigure	fcopy		file		
	    fileevent		flush		for		foreach		format		
	    gets		global		glob		if		incr		
	    info		interp		list		join		lappend		
	    lassign		lindex		linsert		llength		lrange		
	    lrepeat		lreplace	lreverse	lsearch		lset		
	    lsort		namespace	open		package		pid		
	    proc		puts		pwd		read		regsub		
	    rename		return		scan		seek				
	    socket		source		split		string		subst		
	    switch		tell		time		trace		unset		
	    update		uplevel		upvar		variable	vwait		
	    while		} {

	if {[info procs $cmd] eq $cmd} {
	    continue
	}

	if {! ([info commands ::tsp::gen_command_$cmd] eq $cmd) } {
	    lappend ::tsp::BUILTIN_TCL_COMMANDS $cmd
	}
    }
}

::tsp::lang_init
rename ::tsp::lang_init ""

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
# checks for null before release
#
proc ::tsp::lang_safe_release {obj} {
    return "if ($obj != null) $obj.release();\n"
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
    append result "    }\n"
    append result "    [::tsp::lang_new_var_int $targetVarName $sourceVarName]"
    if {$preserve} {
        append result "    [::tsp::lang_preserve $targetVarName]"
    }
    append result "} else {\n"
    append result "    TclInteger.set($targetVarName, (long) $sourceVarName);\n"
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
    append result "    }\n"
    append result "    [::tsp::lang_new_var_double $targetVarName $sourceVarName]"
    if {$preserve} {
        append result "    [::tsp::lang_preserve $targetVarName]"
    }
    append result "} else {\n"
    append result "    TclDouble.set($targetVarName, (double) $sourceVarName);\n"
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
    append result "    }\n"
    append result "    [::tsp::lang_new_var_string $targetVarName $sourceVarName]"
    if {$preserve} {
        append result "    [::tsp::lang_preserve $targetVarName]"
    }
    append result "} else {\n"
    append result "    TclString.empty($targetVarName);\n"  
    append result "    TclString.append($targetVarName, $sourceVarName);\n"
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
    append result "$targetVarName = $sourceVarName.duplicate());\n"
    if {$preserve} {
        append result [::tsp::lang_preserve $targetVarName]
    }
    return $result
}

##############################################
# assign a tclobj var to an interp array using string name1/name2
#   targetArrayStr targetIdxStr must already be valid string constants
#   or string references.
#   the var list tclobjs are preserved and released
#   in a safe manner.   the first var in varlist is
#   the tclobj var value to assign.
#
proc ::tsp::lang_assign_array_var {targetArrayStr targetIdxStr varList} {
    set var [lindex $varList 0]
    append result "// ::tsp::lang_assign_array_var\n"
    append result "try {\n"
    foreach v $varList {
        append result "    [::tsp::lang_preserve $v]"
    }
    append result "    interp.setVar($targetArrayStr, $targetIdxStr, $var, 0);\n"
    append result "} catch (TclException te) {\n"
    append result "    throw te;\n"
    append result "} catch (TclRuntimeError tre) {\n"
    append result "    throw tre;\n"
    append result "} finally {\n"
    foreach v $varList {
        append result "    [::tsp::lang_release $v]"
    }
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
# increment a varname by an amount or a value
# targetVarName is assumed to be a native integer
# result is stored into varname and targetVarName
# throw runtime error if varname is var but not an integer, or
# if incrvar is a var but not an integer
#
proc ::tsp::lang_incr_var {targetVarName varName varType incrAmount incrVar incrType} {

    # 
    append result "\n"
    append result "\n"
    append result "\n"
    append result "\n"
    append result "\n"
    return $result
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
#
proc ::tsp::lang_invoke_builtin {cmd} {
    append code "//  ::tsp::lang_invoke_builtin\n"
    append code "(TSP_Util.getbuiltin_${cmd}()).cmdProc(interp, argObjvArray);\n"
#FIXME: perhaps use: ::tsp::lang_assign_var_var  cmdResultObj (interp.getResult())
# so that we properly release/preserve cmdResultObj
    append code "cmdResultObj = interp.getResult();\n"
    return [list cmdResultObj $code]
}


##############################################
# allocate a TclObject objv list
#
proc ::tsp::lang_alloc_objv_list {} {
    return "argObjvList = new TclList.newInstance();\n"
}


##############################################
# append a TclObject var to a TclObject objv list
#
proc ::tsp::lang_append_objv {obj} {
    return "TclList.append(null, argObjvList, $obj);\n"
}


##############################################
# invoke a tcl command via the interp
#  assumes argObjvList has been constructed
#  preverve and release argObjvList safely
#
proc ::tsp::lang_invoke_tcl {} {
    append code "//  ::tsp::lang_invoke_tcl\n"
    append code "try {\n"
    append code "    argObjvList.preserve();\n"
    append code "    interp.invoke(argObjvList, 0);\n"
    append code "} catch (TclException te) {\n"
    append code "    throw te;\n"
    append code "} finally{\n"
    append code "    argObjvList.release();\n"
#FIXME: perhaps use: ::tsp::lang_assign_var_var  cmdResultObj (interp.getResult())
# so that we properly release/preserve cmdResultObj
    append code "    cmdResultObj = interp.getResult();\n"
    append code "}\n"
    return [list cmdResultObj $code]
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
    append code "//  ::tsp::lang_invoke_tcl\n"
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
        set nativeType [::tsp::lang_xlate_native_type $type]
        append nativeTypedArgs $comma $nativeType " " $arg 
        append declProcArgs [::tsp::lang_decl_native_$type $arg]
        if {$type eq "var"} {
            append argVarAssignments [::tsp::lang_assign_var_var $arg  argv\[$i\]]
            append procArgsCleanup [::tsp::lang_safe_release $arg]
        } else {
            append argVarAssignments [::tsp::lang_convert_${type}_var $arg argv\[$i\] "can't convert arg $i to $type"]
        }
        incr i
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
        set returnSetResult ""
    }

    set procVarsDecls ""
    set procVarsCleanup ""
    foreach {var type} [dict get $compUnit vars] {
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
import tcl.pkg.tsp.util.*;
import tcl.pkg.tsp.math.*;

public class ${name}Cmd implements Command {
    TclObject\[\] emptyArgv = new TclObject\[0\];

    public void cmdProc(Interp interp, TclObject argv\[\]) throws TclException {
        $returnVarDecl
        // variables used by this command, assigned from argv array
        [::tsp::indent compUnit $declProcArgs 2 \n]

        if (argv.length != $numProcArgs) {
            throw new TclException(interp, "wrong # args: should be \\"$name [join [dict get $compUnit args]]\\"");
        }

        try {
            [::tsp::indent compUnit $argVarAssignments 3 \n]
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
            //frame = interp.newCallFrame(this, emptyArgv);

            // code must return a value, else will raise a compilation error
            [::tsp::indent compUnit $code 3]
        } catch (TclException te) {
            throw te;
        } finally {
            if (frame != null) {
                //frame.dispose();
            }

            // release "var" variables, if any
            [::tsp::indent compUnit $procVarsCleanup 3 \n]
        }
    }

} // end of ${name}Cmd 


}
# end of classTemplate

    return [subst $classTemplate]

}







# FIXME- below here
##############################################
# create result vars
#
proc ::tsp::lang_result_vars {compUnitDict} {
}

##############################################
# spill vars into interp
#
#FIXME  - needs rewrite
proc ::tsp::lang_spill_vars {compUnitDict varList} {
    upvar $compUnitDict compUnit

    set buf ""
    foreach var $varList {
        set hasType [dict exists $compUnit var $var]
        if {$hasType} {
            set type [dict get $compUnit var $var]
        } else {
            error "var $var is not defined"
        }
        set objType ""
        switch $type {
            int     {set objType TclInteger}
            boolean {set objType TclBoolean}
            double  {set objType TclDouble}
            string  {set objType TclString}
            var     {}
            default {error "unknown var type: $type"}
        }
        if {$objType ne ""} {
            append buf "{\n"
            append buf "TclObject obj = $objType.newInstance(" $var ");\n"
            append buf "obj.preserve();\n"
            append buf "interp.setVar(\"" $var "\", obj, 0);\n"
            append buf "}\n"
        } else {
            append buf "$var.preserve();\n"
            append buf "interp.setVar(\"" $var "\", $var, 0);\n"
        }
    }
}

##############################################
# convert a native type variable to a TclObject variable 
#
#FIXME  - needs rewrite

proc ::tsp::lang_var_to_obj {var type obj} {
    set buf ""
    switch $type {
        int     {append buf "$obj = TclInteger.newInstance(" $var ");"}
        boolean {append buf "$obj = TclBoolean.newInstance(" $var ");"}
        double  {append buf "$obj = TclDouble.newInstance(" $var ");"}
        string  {append buf "$obj = TclString.newInstance(" $var ");"}
        var     {append buf "$obj = $var;"}
        default {error "unknown var type: $type"}
    }
    return $buf
}

##############################################
# convert a TclObject variable into a typed variable
#
#FIXME  - needs rewrite
proc ::tsp::lang_obj_to_var {var type obj} {
    set buf ""
    switch $type {
        int     {append buf "$var = TclInteger.getLong(interp,  $obj);\n"}
        boolean {append buf "$var = TclBoolean.get(interp, $obj);\n"}
        double  {append buf "$var = TclDouble.get(interp, $obj);\n"}
        string  {append buf "$var = $obj.toString();\n"}
        var     {append buf "$var = $obj;"}
        default {error "unknown var type: $type"}
    }
    return $buf
}

##############################################
# set a interp variable from a TclObject
#
#FIXME  - needs rewrite
proc ::tsp::lang_set_interp_var_obj {var obj} {
    set buf ""
    append buf "interp.setVar(\"$var\",  $obj , 0);\n"
    return $buf
}

##############################################
# get a interp variable assign to a TclObject
#
#FIXME  - needs rewrite
proc ::tsp::lang_get_interp_var_obj {var obj} {
    set buf ""
    append buf "$obj = interp.getVar(\"$var\", 0);\n"
    return $buf
}


##############################################
# reload vars from interp
#
#FIXME  - needs rewrite
proc ::tsp::lang_reload_vars {compUnitDict varList} {
    upvar $compUnitDict compUnit

    set buf ""
    foreach var $varList {
        set hasType [dict exists $compUnit var $var]
        if {$hasType} {
            set type [dict get $compUnit var $var]
        } else {
            error "var $var type is not defined"
        }
        ::tsp::reload_var $compUnit $var $type
    }
}


##############################################
# invoke a tcl command 
#
#FIXME  - needs rewrite
proc ::tsp::lang_invoke_tcl_cmd {compUnitDict cmd varList assignVar} {
    upvar $compUnitDict compUnit

    set hasType [dict exists $compUnit var $assignVar]
    set assignType ""
    if {$hasType} {
        switch $type {
            int     {set assignType TclInteger}
            boolean {set assignType TclBoolean}
            double  {set assignType TclDouble}
            string  {set assignType TclString}
            var     {set assignType TclObject}
            default {error "unknown var type: $type"}
        }
    } else {
        error "invoke_cmd: undefined assign variable: $assignVar"
    }
    set arg 0
    set buf "{\n"
    append buf "TclList cmdList = TclList.newInstance();\n"    
    append buf "cmdList.preserve();\n"    
    append buf "TclObject arg$arg = TclString.newInstance($cmd);\n"    
    append buf " arg$arg.preserve();\n"    
    append buf "TclList.append(interp, cmdList, arg$arg);\n"    
    foreach var $varList {
        incr arg
        set hasType [dict exists $compUnit var $var]
        if {$hasType} {
            set type [dict get $compUnit var $var]
        } else {
            error "invoke_cmd: undefined variable: $var"
        }
        append buf "TclObject arg$arg = "
        switch $type {
            int     {append buf "TclInteger.newInstance($var);\n"}
            boolean {append buf "TclBoolean.newInstance($var);\n"}
            double  {append buf "TclDouble.newInstance($var);\n"}
            string  {append buf "TclString.newInstance($var);\n"}
            var     {}
            default {error "unknown var type: $type"}
        }
        append buf "arg$arg.preserve();\n"
    }
    append buf "try {\n"
    append buf "  interp.invoke(cmdList, 0);\n"
    if {$assignVar ne ""} {
        append buf "  TclObject result = interp.getResult();\n"
        if {$assignType eq "TclObject"} {
            append buf "  $var = $assignType.get(interp, result);\n"
        } else {
            append buf "  $var = $assignType.get(interp, result);\n"
        }
    }
    append buf "} catch (TclException e) {\n"
    append buf "} finally {\n"
    for {set i 0} {$i <= $arg} {incr i} {
        append buf "arg$arg.release();\n"
    }
    append buf "}\n"
    append buf "}\n"

    return $buf
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
            list* -
            var {append buf "$var.release();\n"}
        }
    }
    return $buf
}

