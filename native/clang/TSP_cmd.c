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

/* return a pointer to a Tcl command info */
/* cmd info data is not preserved across multiple calls */

Tcl_CmdInfo*
TSP_Cmd_getCmdInfo(Tcl_Interp* interp, char* cmd) {
    static Tcl_CmdInfo cmdInfo;
    int rc;
    rc = Tcl_GetCommandInfo(interp, cmd, &cmdInfo);
    if (rc == 0) {
        Tcl_Panic("TSP_Cmd_getCmdInfo: can't get command proc for %s", cmd);
    }
     return &cmdInfo;
}


/* builtins command - a function that calls the builtin and fills in command obj name */

int
TSP_Cmd_builtin_after (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::after");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("after", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_append (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::append");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("append", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_apply (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::apply");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("apply", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_array (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::array");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("array", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_binary (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::binary");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("binary", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_break (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::break");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("break", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_case (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::case");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("case", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_catch (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::catch");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("catch", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_cd (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::cd");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("cd", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_chan (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::chan");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("chan", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_clock (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::clock");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("clock", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_close (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::close");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("close", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_concat (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::concat");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("concat", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_continue (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::continue");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("continue", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_dict (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::dict");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("dict", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_encoding (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::encoding");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("encoding", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_eof (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::eof");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("eof", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_error (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::error");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("error", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_eval (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::eval");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("eval", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_exec (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::exec");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("exec", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_exit (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::exit");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("exit", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_expr (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::expr");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("expr", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_fblocked (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::fblocked");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("fblocked", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_fconfigure (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::fconfigure");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("fconfigure", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_fcopy (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::fcopy");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("fcopy", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_file (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::file");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("file", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_fileevent (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::fileevent");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("fileevent", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_flush (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::flush");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("flush", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_for (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::for");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("for", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_foreach (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::foreach");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("foreach", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_format (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::format");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("format", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_gets (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::gets");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("gets", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_glob (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::glob");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("glob", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_global (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::global");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("global", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_if (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::if");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("if", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_incr (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::incr");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("incr", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_info (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::info");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("info", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_interp (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::interp");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("interp", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_join (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::join");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("join", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lappend (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lappend");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lappend", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lassign (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lassign");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lassign", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lindex (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lindex");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lindex", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_linsert (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::linsert");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("linsert", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_list (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::list");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("list", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_llength (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::llength");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("llength", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lmap (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lmap");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lmap", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_load (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::load");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("load", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lrange (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lrange");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lrange", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lrepeat (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lrepeat");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lrepeat", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lreplace (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lreplace");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lreplace", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lreverse (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lreverse");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lreverse", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lsearch (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lsearch");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lsearch", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lset (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lset");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lset", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lsort (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::lsort");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("lsort", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_namespace (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::namespace");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("namespace", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_open (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::open");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("open", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_package (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::package");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("package", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_pid (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::pid");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("pid", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_proc (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::proc");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("proc", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_puts (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::puts");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("puts", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_pwd (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::pwd");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("pwd", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_read (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::read");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("read", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_regexp (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::regexp");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("regexp", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_regsub (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::regsub");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("regsub", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_rename (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::rename");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("rename", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_return (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::return");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("return", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_scan (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::scan");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("scan", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_seek (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::seek");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("seek", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_set (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::set");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("set", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_socket (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::socket");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("socket", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_source (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::source");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("source", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_split (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::split");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("split", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_string (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::string");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("string", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_subst (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::subst");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("subst", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_switch (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::switch");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("switch", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_tailcall (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::tailcall");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("tailcall", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_tell (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::tell");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("tell", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_time (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::time");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("time", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_trace (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::trace");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("trace", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_try (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::try");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("try", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_unload (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::unload");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("unload", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_unset (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::unset");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("unset", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_update (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::update");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("update", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_uplevel (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::uplevel");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("uplevel", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_upvar (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::upvar");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("upvar", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_variable (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::variable");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("variable", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_vwait (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::vwait");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("vwait", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_while (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::while");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("while", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_yield (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::yield");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("yield", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_yieldto (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::yieldto");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("yieldto", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_zlib (ClientData dummy, Tcl_Interp* interp, int objc, struct Tcl_Obj *objv[]) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    static Tcl_Obj* cmdName = NULL;
    static ClientData clientData = NULL;
    if (cmdProc == NULL) {
        Tcl_CmdInfo* cmdInfo;
        cmdInfo = TSP_Cmd_getCmdInfo(interp, "::zlib");
        cmdProc = cmdInfo->objProc;
        clientData = cmdInfo->objClientData;
        cmdName = Tcl_NewStringObj("zlib", -1);
        Tcl_IncrRefCount(cmdName);  /* make cmdName safe */
        Tcl_IncrRefCount(cmdName);  /* from altercation  */
    }
    objv[0] = cmdName;
    return (cmdProc)(clientData, interp, objc, objv);
}


