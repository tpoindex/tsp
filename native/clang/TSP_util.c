#ifndef _TCL
#include <tcl.h>
#endif

int
TSP_Util_lang_convert_int_string(Tcl_Interp* interp, Tcl_DString* sourceVarName, Tcl_WideInt* targetVarName) {
    int rc;
    Tcl_Obj* obj = Tcl_NewStringObj(Tcl_DStringValue(sourceVarName), Tcl_DStringLength(sourceVarName));
    Tcl_IncrRefCount(obj);
    rc = Tcl_GetWideIntFromObj(interp, obj, targetVarName);
    Tcl_DecrRefCount(obj);
    return rc;
}

int
TSP_Util_lang_convert_int_string_const(Tcl_Interp* interp, char* sourceVarName, Tcl_WideInt* targetVarName) {
    int rc;
    Tcl_Obj* obj = Tcl_NewStringObj(sourceVarName, -1);
    Tcl_IncrRefCount(obj);
    rc = Tcl_GetWideIntFromObj(interp, obj, targetVarName);
    Tcl_DecrRefCount(obj);
    return rc;
}

void
TSP_Util_lang_convert_string_int(Tcl_Interp* interp, Tcl_DString** targetVarName, Tcl_WideInt sourceVarName) {
    char str[500];
    char *format = "%" TCL_LL_MODIFIER "d";
    if (*targetVarName != NULL) {
        Tcl_DStringFree(*targetVarName);
    }
    sprintf(str, format, sourceVarName);
    Tcl_DStringAppend(*targetVarName, str, -1);
}


void
TSP_Util_lang_convert_string_double(Tcl_Interp* interp, Tcl_DString** targetVarName, double sourceVarName) {
    char str[500];
    if (*targetVarName != NULL) {
        Tcl_DStringFree(*targetVarName);
    }
    Tcl_PrintDouble(interp, sourceVarName, str);
    Tcl_DStringAppend(*targetVarName, str, -1);
}

void
TSP_Util_lang_convert_string_var(Tcl_DString** targetVarName, Tcl_Obj* sourceVarName) {
    char* str;
    int len;
    if (*targetVarName != NULL) {
        Tcl_DStringFree(*targetVarName);
    }
    str = Tcl_GetStringFromObj(sourceVarName, &len);
    Tcl_DStringAppend(*targetVarName, str, len);
}

Tcl_DString*
TSP_Util_lang_get_string_int(Tcl_WideInt sourceVarName) {
    Tcl_DString* ds;
    ds = (Tcl_DString*) ckalloc(sizeof(Tcl_DString));
    Tcl_DStringInit(ds);
    TSP_Util_lang_convert_string_int(NULL, &ds, sourceVarName);
    return ds;
}

Tcl_DString*
TSP_Util_lang_get_string_double(double sourceVarName) {
    Tcl_DString* ds;
    ds = (Tcl_DString*) ckalloc(sizeof(Tcl_DString));
    Tcl_DStringInit(ds);
    TSP_Util_lang_convert_string_double(NULL, &ds, sourceVarName);
    return ds;
}

Tcl_Obj*
TSP_Util_lang_assign_var_boolean(Tcl_Obj* targetVarName, int sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_NewBooleanObj(sourceVarName);
    return targetVarName;
}

Tcl_Obj*
TSP_Util_lang_assign_var_int(Tcl_Obj* targetVarName, Tcl_WideInt sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_NewWideIntObj(sourceVarName);
    return targetVarName;
}

Tcl_Obj*
TSP_Util_lang_assign_var_double(Tcl_Obj* targetVarName, double sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_NewDoubleObj(sourceVarName);
    return targetVarName;
}

Tcl_Obj*
TSP_Util_lang_assign_var_string(Tcl_Obj* targetVarName, Tcl_DString* sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_NewStringObj(Tcl_DStringValue(sourceVarName), Tcl_DStringLength(sourceVarName));
    return targetVarName;
}

Tcl_Obj*
TSP_Util_lang_assign_var_string_const(Tcl_Obj* targetVarName, char* sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_NewStringObj(sourceVarName, -1);
    return targetVarName;
}

Tcl_Obj*
TSP_Util_lang_assign_var_var(Tcl_Obj* targetVarName, Tcl_Obj* sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_DuplicateObj(sourceVarName);
    return targetVarName;
}

int
TSP_Util_lang_assign_array_var(Tcl_Interp* interp, char* targetArrayStr, char* targetIdxStr, Tcl_Obj* var) {
    Tcl_Obj* obj;
    obj = Tcl_SetVar2Ex(interp, targetArrayStr, targetIdxStr, var, TCL_LEAVE_ERR_MSG);
    if (obj == NULL) {
        return TCL_ERROR;
    } else {
        return TCL_OK;
    }
}

/*
    append code "if ((*rc = (TSP_Cmd_builtin_$cmd) ((ClientData)NULL, interp,  argObjc_$cmdLevel, argObjvArray_$cmdLevel)) != TCL_OK) \{\n"

    append code "if ((*rc = TSP_User_${cmdName}_direct($invokeArgs)) != TCL_OK) {\n"

TSP_UserDirect_${name}(Tcl_Interp* interp, int* rc  $nativeTypedArgs

TSP_UserCmd_${name}(ClientData unused, Tcl_Interp* interp,

    if ((rc = TSP_UserDirect_${name}(interp ${nativeArgs})) == TCL_OK) {

    if {[string first TSP_Func_ $exprAssignment] == -1} {

        regsub -all {(TSP_Func_[^(]*\()(/*)} $exprAssignment {\1\&exprErr,\2} exprAssignment

*/
