
# language specific procs

proc ::tsp::spill_vars {compUnitDict varList} {
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
            int*    {set objType TclInteger}
            bool*   {set objType TclBoolean}
            string* {set objType TclString}
            var -
            list_*  {}
            default {error "unknown var type: $type"}
        }
        if {$objType ne ""} {
            append buf "{\n"
            append buf "TclObject __obj = $objType.newInstance(" $var ");\n"
            append buf "__obj.preserve();\n"
            append buf "__interp.setVar(\"" $var "\", __obj, 0);\n"
            append buf "}\n"
        } else {
            append buf "$var.preserve();\n"
            append buf "__interp.setVar(\"" $var "\", $var, 0);\n"
        }
    }
}

proc ::tsp::preserve {obj} {
    return "$obj.preserve();\n"
}

proc ::tsp::release {obj} {
    return "$obj.release();\n"
}

proc ::tsp::var_to_obj {var type obj} {
    set buf ""
    switch $type {
        int*    {append buf "$obj = TclInteger.newInstance(" $var ");"}
        bool*   {append buf "$obj = TclBoolean.newInstance(" $var ");"}
        string* {append buf "$obj = TclString.newInstance(" $var ");"}
        var -
        list_*  {}
        default {error "unknown var type: $type"}
    }
    return $buf
}

proc ::tsp::obj_to_var {var type obj} {
    set buf ""
    switch $type {
        int*    {append buf "$var = TclInteger.getLong(__interp,  $obj);\n"}
        bool*   {append buf "$var = TclBoolean.get(__interp, $obj);\n"}
        string* {append buf "$var = $obj.toString();\n"}
        var -
        list_*  {}
        default {error "unknown var type: $type"}
    }
    return $buf
}

proc ::tsp::set_interp_var_obj {var obj} {
    set buf ""
    append buf "__interp.setVar(\"$var\",  $obj , 0);\n"
    return $buf
}

proc ::tsp::get_interp_var_obj {var obj} {
    set buf ""
    append buf "$obj = __interp.getVar(\"$var\", 0);\n"
    return $buf
}


proc ::tsp::reload_vars {compUnitDict varList} {
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


proc ::tsp::invoke_tcl_cmd {compUnitDict cmd varList assignVar} {
    upvar $compUnitDict compUnit

    set hasType [dict exists $compUnit var $assignVar]
    set assignType ""
    if {$hasType} {
        switch $type {
            int*    {set assignType TclInteger}
            bool*   {set assignType TclBoolean}
            string* {set assignType TclString}
            var     {set assignType TclObject}
            list_*  {set assignType TclList}
            default {error "unknown var type: $type"}
        }
    } else {
        error "invoke_cmd: undefined assign variable: $assignVar"
    }
    set arg 0
    set buf "{\n"
    append buf "TclList __cmdList = TclList.newInstance();\n"    
    append buf "__cmdList.preserve();\n"    
    append buf "TclObject __arg$arg = TclString.newInstance($cmd);\n"    
    append buf " __arg$arg.preserve();\n"    
    append buf "TclList.append(__interp, __cmdList, __arg$arg);\n"    
    foreach var $varList {
        incr arg
        set hasType [dict exists $compUnit var $var]
        if {$hasType} {
            set type [dict get $compUnit var $var]
        } else {
            error "invoke_cmd: undefined variable: $var"
        }
        append buf "TclObject __arg$arg = "
        switch $type {
            int*    {append buf "TclInteger.newInstance($var);\n"}
            bool*   {append buf "TclBoolean.newInstance($var);\n"}
            string* {append buf "TclString.newInstance($var);\n"}
            var -
            list_*  {}
            default {error "unknown var type: $type"}
        }
        append buf "__arg$arg.preserve();\n"
    }
    append buf "try {\n"
    append buf "  __interp.eval(__cmdList, 0);\n"
    if {$assignVar ne ""} {
        append buf "  TclObject __result = __interp.getResult();\n"
        if {$assignType eq "TclObject"} {
            append buf "  $var = $assignType.get(__interp, __result);\n"
        } else {
            append buf "  $var = $assignType.get(__interp, __result);\n"
        }
    }
    append buf "} catch (TclException __e) {\n"
    append buf "} finally {\n"
    for {set i 0} {$i <= $arg} {incr i} {
        append buf "__arg$arg.release();\n"
    }
    append buf "}\n"
    append buf "}\n"

    return $buf
}

proc ::tsp::release_vars {compUnitDict} {
    upvar $compUnitDict compUnit
    set buf ""
    set varList [dict get $compUnit vars]
    foreach var $varList {
        set type [dict get $compUnit var $var ]
        switch $type {
            list* -
            var {append buf "$var.release();\n}
        }
    }
    return $buf
}
