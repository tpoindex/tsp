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
       return userCmd;
    }
}

/* return a pointer to a Tcl command function */
Tcl_ObjCmdProc*
TSP_Cmd_getCmd(Tcl_Interp* interp, char* cmd) {
    Tcl_CmdInfo cmdInfo;
    int rc;
    rc = Tcl_GetCommandInfo(interp, cmd, &cmdInfo);
    if (rc == 0) {
        Tcl_Panic("TSP_Cmd_getCmd: can't get command proc for %s", cmd);
    } else {
        return cmdInfo.objProc;
    }
}


int
TSP_Cmd_builtin_after (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::after");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_append (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::append");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_apply (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::apply");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_break (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::break");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_case (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::case");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_catch (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::catch");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_cd (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::cd");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_close (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::close");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_concat (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::concat");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_continue (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::continue");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_encoding (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::encoding");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_eof (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::eof");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_error (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::error");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_eval (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::eval");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_exec (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::exec");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_exit (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::exit");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_expr (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::expr");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_fblocked (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::fblocked");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_fconfigure (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::fconfigure");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_fcopy (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::fcopy");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_fileevent (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::fileevent");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_flush (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::flush");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_foreach (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::foreach");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_format (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::format");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_gets (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::gets");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_glob (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::glob");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_global (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::global");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_if (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::if");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_incr (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::incr");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_interp (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::interp");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_join (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::join");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lappend (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lappend");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lassign (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lassign");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lindex (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lindex");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_linsert (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::linsert");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_list (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::list");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_llength (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::llength");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lrange (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lrange");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lmap (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lmap");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lrepeat (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lrepeat");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lreplace (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lreplace");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lreverse (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lreverse");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lsearch (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lsearch");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lset (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lset");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_lsort (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::lsort");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_open (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::open");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_package (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::package");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_proc (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::proc");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_puts (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::puts");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_pwd (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::pwd");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_read (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::read");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_regexp (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::regexp");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_regsub (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::regsub");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_rename (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::rename");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_return (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::return");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_scan (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::scan");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_seek (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::seek");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_set (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::set");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_socket (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::socket");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_source (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::source");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_split (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::split");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_subst (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::subst");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_switch (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::switch");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_tell (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::tell");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_time (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::time");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_trace (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::trace");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_try (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::try");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_unset (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::unset");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_update (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::update");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_uplevel (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::uplevel");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_upvar (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::upvar");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_variable (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::variable");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_vwait (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::vwait");}
    return (cmdProc)(clientData, interp, objc, objv);
}

int
TSP_Cmd_builtin_while (ClientData clientData, Tcl_Interp* interp, int objc, struct Tcl_Obj *const *objv) {
    static Tcl_ObjCmdProc* cmdProc = NULL;
    if (cmdProc == NULL) {cmdProc = TSP_Cmd_getCmd(interp, "::while");}
    return (cmdProc)(clientData, interp, objc, objv);
}


