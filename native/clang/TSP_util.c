
int
TSP_Util_lang_convert_int_string(Tcl_Interp* interp, Tcl_DString* sourceVarName, Tcl_WideInt* targetVarName) {
    int rc;
    Tcl_Object obj = Tcl_NewString(interp, Tcl_DStringValue(sourceVarName), Tcl_DStringLength(sourceVarName));
    Tcl_IncrRefCount(obj);
    rc = Tcl_GetWideIntFromObj(interp, obj, targetVarName);
    Tcl_DecrRefCount(obj);
    return rc;
}

void
TSP_Util_lang_convert_string_int(Tcl_Interp* interp, Tcl_DString* targetVarName, Tcl_WideInt sourceVarName) {
    char str[500];
    char *format = "%d" TCL_LL;
    sprintf(str, format, sourceVarName);
    Tcl_DString(targetVarName, str, -1);
}


void
TSP_Util_lang_convert_string_double(interp, Tcl_DString targetVarName, double sourceVarName) {

}

    append result "TSP_Util_lang_convert_string_var(&$targetVarName, $sourceVarName);\n"

    return TSP_Util_lang_get_string_int($sourceVarName)"

    return TSP_Util_lang_get_string_double($sourceVarName)"

    append result "$targetVarName = TSP_Util_lang_assign_var_boolean($targetVarName, $sourceVarName);\n"

    append result "$targetVarName = TSP_Util_lang_assign_var_int($targetVarName, (TCL_LL_MODIFIER) $sourceVarName;\n"

    append result "$targetVarName = TSP_Util_lang_assign_var_double($targetVarName, (double) $sourceVarName);\n"

    append result "$targetVarName = TSP_Util_lang_assign_var_string($targetVarName, $sourceVarName);\n"

    append result "$targetVarName = TSP_Util_lang_assign_var_var($targetVarName, $sourceVarName);\n"

    append result "TSP_Util_lang_assign_array_var(interp, $targetArrayStr, $targetIdxStr, $var);\n"

    append code "if ((*rc = (TSP_Cmd_builtin_$cmd) ((ClientData)NULL, interp,  argObjc_$cmdLevel, argObjvArray_$cmdLevel)) != TCL_OK) \{\n"

    append code "if ((*rc = TSP_User_${cmdName}_direct($invokeArgs)) != TCL_OK) {\n"

TSP_UserDirect_${name}(Tcl_Interp* interp, int* rc  $nativeTypedArgs

TSP_UserCmd_${name}(ClientData unused, Tcl_Interp* interp,

    if ((rc = TSP_UserDirect_${name}(interp ${nativeArgs})) == TCL_OK) {

    if {[string first TSP_Func_ $exprAssignment] == -1} {

        regsub -all {(TSP_Func_[^(]*\()(/*)} $exprAssignment {\1\&exprErr,\2} exprAssignment
