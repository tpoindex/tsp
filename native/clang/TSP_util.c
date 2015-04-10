#ifndef _TCL
#include <tcl.h>
#endif


/*********************************************************************************************/
/* convert to an int from a string */
int
TSP_Util_lang_convert_int_string(Tcl_Interp* interp, Tcl_DString* sourceVarName, Tcl_WideInt* targetVarName) {
    int rc;
    Tcl_Obj* obj = Tcl_NewStringObj(Tcl_DStringValue(sourceVarName), Tcl_DStringLength(sourceVarName));
    Tcl_IncrRefCount(obj);
    rc = Tcl_GetWideIntFromObj(interp, obj, targetVarName);
    Tcl_DecrRefCount(obj);
    return rc;
}


/*********************************************************************************************/
/* convert to an int from a string const */
int
TSP_Util_lang_convert_int_string_const(Tcl_Interp* interp, char* sourceVarName, Tcl_WideInt* targetVarName) {
    int rc;
    Tcl_Obj* obj = Tcl_NewStringObj(sourceVarName, -1);
    Tcl_IncrRefCount(obj);
    rc = Tcl_GetWideIntFromObj(interp, obj, targetVarName);
    Tcl_DecrRefCount(obj);
    return rc;
}


/*********************************************************************************************/
/* convert to a string from an int */
void
TSP_Util_lang_convert_string_int(Tcl_Interp* interp, Tcl_DString** targetVarName, Tcl_WideInt sourceVarName) {
    char str[500];
    char *format = "%" TCL_LL_MODIFIER "d";
    if (*targetVarName != NULL) {
        Tcl_DStringSetLength(*targetVarName, 0);
    } else {
        *targetVarName = (Tcl_DString*) ckalloc(sizeof(Tcl_DString));;
        Tcl_DStringInit(*targetVarName);
    }
    sprintf(str, format, sourceVarName);
    Tcl_DStringAppend(*targetVarName, str, -1);
}



/*********************************************************************************************/
/* convert to a string from a double */
void
TSP_Util_lang_convert_string_double(Tcl_Interp* interp, Tcl_DString** targetVarName, double sourceVarName) {
    char str[500];
    if (*targetVarName != NULL) {
        Tcl_DStringSetLength(*targetVarName, 0);
    } else {
        *targetVarName = (Tcl_DString*) ckalloc(sizeof(Tcl_DString));;
        Tcl_DStringInit(*targetVarName);
    }
    Tcl_PrintDouble(interp, sourceVarName, str);
    Tcl_DStringAppend(*targetVarName, str, -1);
}


/*********************************************************************************************/
/* convert to a string from a var */
void
TSP_Util_lang_convert_string_var(Tcl_DString** targetVarName, Tcl_Obj* sourceVarName) {
    char* str;
    int len;
    if (*targetVarName != NULL) {
        Tcl_DStringSetLength(*targetVarName, 0);
    } else {
        *targetVarName = (Tcl_DString*) ckalloc(sizeof(Tcl_DString));;
        Tcl_DStringInit(*targetVarName);
    }
    str = Tcl_GetStringFromObj(sourceVarName, &len);
    Tcl_DStringAppend(*targetVarName, str, len);
}


/*********************************************************************************************/
/* get a string from an int */
Tcl_DString*
TSP_Util_lang_get_string_int(Tcl_WideInt sourceVarName) {
    Tcl_DString* ds;
    ds = (Tcl_DString*) ckalloc(sizeof(Tcl_DString));
    Tcl_DStringInit(ds);
    TSP_Util_lang_convert_string_int(NULL, &ds, sourceVarName);
    return ds;
}


/*********************************************************************************************/
/* get a string from an double */
Tcl_DString*
TSP_Util_lang_get_string_double(double sourceVarName) {
    Tcl_DString* ds;
    ds = (Tcl_DString*) ckalloc(sizeof(Tcl_DString));
    Tcl_DStringInit(ds);
    TSP_Util_lang_convert_string_double(NULL, &ds, sourceVarName);
    return ds;
}


/*********************************************************************************************/
/* assign a var from a boolean */
Tcl_Obj*
TSP_Util_lang_assign_var_boolean(Tcl_Obj* targetVarName, int sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_NewBooleanObj(sourceVarName);
    return targetVarName;
}


/*********************************************************************************************/
/* assign a var from an int */
Tcl_Obj*
TSP_Util_lang_assign_var_int(Tcl_Obj* targetVarName, Tcl_WideInt sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_NewWideIntObj(sourceVarName);
    return targetVarName;
}


/*********************************************************************************************/
/* assign a var from an double */
Tcl_Obj*
TSP_Util_lang_assign_var_double(Tcl_Obj* targetVarName, double sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_NewDoubleObj(sourceVarName);
    return targetVarName;
}


/*********************************************************************************************/
/* assign a var from an string */
Tcl_Obj*
TSP_Util_lang_assign_var_string(Tcl_Obj* targetVarName, Tcl_DString* sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_NewStringObj(Tcl_DStringValue(sourceVarName), Tcl_DStringLength(sourceVarName));
    return targetVarName;
}


/*********************************************************************************************/
/* assign a var from an string const */
Tcl_Obj*
TSP_Util_lang_assign_var_string_const(Tcl_Obj* targetVarName, char* sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_NewStringObj(sourceVarName, -1);
    return targetVarName;
}


/*********************************************************************************************/
/* assign a var from a var */
Tcl_Obj*
TSP_Util_lang_assign_var_var(Tcl_Obj* targetVarName, Tcl_Obj* sourceVarName) {
    if (targetVarName != NULL) {
        Tcl_DecrRefCount(targetVarName);
    }
    targetVarName = Tcl_DuplicateObj(sourceVarName);
    return targetVarName;
}


/*********************************************************************************************/
/* assign an array & element from a var */
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


/*********************************************************************************************/
/* compare two Tcl_DStrings */
int
TSP_Util_string_compare(Tcl_DString* s1, Tcl_DString* s2) {
    char* string2;
    int length2;

    return TSP_Util_string_compare_const(s1, Tcl_DStringValue(s2), Tcl_DStringLength(s2));
}

/*********************************************************************************************/
/* compare a Tcl_DString to a const string. use negative length to find first null in string2 */
int
TSP_Util_string_compare_const(Tcl_DString* s1, char* string2, int length2) {
    char* string1;
    int length1;
    int length;
    int match;

    string1 = Tcl_DStringValue(s1);
    length1 = Tcl_DStringLength(s1);

    length1 = Tcl_NumUtfChars(string1, length1);
    length2 = Tcl_NumUtfChars(string2, length2);
    
    length = (length1 < length2) ? length1 : length2;
    match = Tcl_UtfNcmp(string1, string2, (unsigned) length);
    if (match == 0) {
        match = length1 - length2;
    }
    return match;
}


