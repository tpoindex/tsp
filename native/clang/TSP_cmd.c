#ifndef _TCL
#include <tcl.h>
#endif

/* return a pointer to a user direct command function, assumes
   that user command puts the inner direct command into clientdata */
void*
TSP_User_getCmd(Tcl_Interp* interp, char* cmd) {
    Tcl_CmdInfo cmdInfo;
    int rc;
    Tcl_ObjCmdProc* objCmd;
    void* userCmd = NULL;
    rc = Tcl_GetCommandInfo(interp, cmd, &cmdInfo);
    if (rc == 0) {
        Tcl_Panic("TSP_User_getCmd: can't get command proc for %s", cmd);
    } else {
        objCmd = cmdInfo.objProc;
        rc = objCmd(&userCmd, interp, 0, NULL);
    }
     return userCmd;
}

/* return a pointer to a Tcl command function */
Tcl_ObjCmdProc*
TSP_Cmd_getCmd(Tcl_Interp* interp, char* cmd) {
    Tcl_CmdInfo cmdInfo;
    int rc;
    rc = Tcl_GetCommandInfo(interp, cmd, &cmdInfo);
    if (rc == 0) {
        Tcl_Panic("TSP_Cmd_getCmd: can't get command proc for %s", cmd);
    }
     return cmdInfo.objProc;
}


int
TSP_Cmd_builtin_after (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::after");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_after () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("after", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_append (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::append");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_append () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("append", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_apply (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::apply");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_apply () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("apply", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_break (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::break");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_break () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("break", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_case (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::case");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_case () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("case", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_catch (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::catch");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_catch () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("catch", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_cd (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::cd");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_cd () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("cd", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_clock (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::clock");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_clock () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("clock", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_close (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::close");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_close () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("close", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_concat (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::concat");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_concat () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("concat", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_continue (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::continue");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_continue () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("continue", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_encoding (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::encoding");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_encoding () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("encoding", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_eof (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::eof");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_eof () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("eof", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_error (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::error");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_error () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("error", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_eval (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::eval");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_eval () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("eval", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_exec (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::exec");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_exec () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("exec", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_exit (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::exit");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_exit () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("exit", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_expr (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::expr");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_expr () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("expr", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_fblocked (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::fblocked");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_fblocked () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("fblocked", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_fconfigure (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::fconfigure");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_fconfigure () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("fconfigure", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_fcopy (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::fcopy");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_fcopy () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("fcopy", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_fileevent (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::fileevent");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_fileevent () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("fileevent", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_flush (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::flush");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_flush () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("flush", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_for (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::for");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_for () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("for", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_foreach (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::foreach");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_foreach () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("foreach", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_format (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::format");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_format () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("format", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_gets (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::gets");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_gets () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("gets", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_glob (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::glob");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_glob () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("glob", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_global (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::global");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_global () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("global", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_if (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::if");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_if () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("if", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_incr (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::incr");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_incr () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("incr", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_interp (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::interp");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_interp () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("interp", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_join (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::join");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_join () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("join", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lappend (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lappend");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lappend () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lappend", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lassign (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lassign");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lassign () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lassign", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lindex (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lindex");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lindex () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lindex", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_linsert (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::linsert");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_linsert () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("linsert", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_list (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::list");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_list () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("list", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_llength (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::llength");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_llength () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("llength", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lmap (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lmap");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lmap () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lmap", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_load (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::load");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_load () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("load", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lrange (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lrange");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lrange () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lrange", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lrepeat (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lrepeat");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lrepeat () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lrepeat", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lreplace (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lreplace");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lreplace () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lreplace", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lreverse (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lreverse");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lreverse () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lreverse", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lsearch (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lsearch");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lsearch () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lsearch", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lset (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lset");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lset () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lset", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_lsort (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lsort");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_lsort () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("lsort", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_open (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::open");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_open () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("open", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_package (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::package");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_package () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("package", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_pid (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::pid");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_pid () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("pid", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_proc (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::proc");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_proc () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("proc", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_puts (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::puts");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_puts () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("puts", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_pwd (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::pwd");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_pwd () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("pwd", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_read (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::read");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_read () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("read", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_regexp (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::regexp");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_regexp () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("regexp", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_regsub (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::regsub");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_regsub () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("regsub", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_rename (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::rename");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_rename () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("rename", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_return (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::return");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_return () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("return", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_scan (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::scan");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_scan () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("scan", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_seek (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::seek");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_seek () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("seek", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_set (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::set");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_set () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("set", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_socket (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::socket");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_socket () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("socket", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_source (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::source");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_source () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("source", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_split (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::split");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_split () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("split", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_subst (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::subst");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_subst () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("subst", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_switch (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::switch");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_switch () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("switch", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_tailcall (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::tailcall");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_tailcall () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("tailcall", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_tell (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::tell");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_tell () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("tell", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_time (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::time");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_time () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("time", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_trace (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::trace");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_trace () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("trace", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_try (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::try");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_try () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("try", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_unload (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::unload");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_unload () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("unload", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_unset (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::unset");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_unset () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("unset", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_update (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::update");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_update () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("update", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_uplevel (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::uplevel");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_uplevel () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("uplevel", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_upvar (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::upvar");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_upvar () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("upvar", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_variable (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::variable");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_variable () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("variable", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_vwait (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::vwait");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_vwait () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("vwait", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_while (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::while");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_while () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("while", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_yield (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::yield");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_yield () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("yield", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_yieldto (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::yieldto");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_yieldto () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("yieldto", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}

int
TSP_Cmd_builtin_zlib (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::zlib");}
    return (cmdProc)(clientData, interp, objc, objv);
}
Tcl_Obj*
TSP_Cmd_builtinName_zlib () {
    static Tcl_Obj* cmdName = NULL;
    if (cmdName == NULL) {cmdName = Tcl_NewStringObj("zlib", -1); Tcl_IncrRefCount(cmdName); Tcl_IncrRefCount(cmdName);}
    return cmdName;
}


