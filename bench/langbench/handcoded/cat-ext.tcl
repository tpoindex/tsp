
if {0} {

# run as:
#    tclsh8.6 cat-ext.tcl >/dev/null

# create /tmp/DATA as per langbench README, a million lines of text.
# first cd to the directory that hold your tcl8.6.x source code, 
# cut/paste the shell 'for' command into a terminal:

for i in 1 2 3 4 5 6 7 8 9 
do cat generic/*.[ch]
done | head -1000000 > /tmp/DATA

}


package require critcl

::critcl::config lines 0
::critcl::config keepsrc 1
::critcl::cflags -O3

::critcl::ccode {

Tcl_ObjCmdProc* 
GetObjCmd(Tcl_Interp* interp, char* cmd) {
    Tcl_CmdInfo cmdInfo;
    int rc;
    rc = Tcl_GetCommandInfo(interp, cmd, &cmdInfo);
    if (rc == 0) {
        Tcl_Panic("can't get command proc for %s", cmd);
    }
    return cmdInfo.objProc;
}

}

::critcl::ccommand ::cat-ext {clientData interp objc objv} {
    Tcl_CallFrame* frame;
    Tcl_Obj** argObjvArray;
    
    Tcl_Obj* OPEN = NULL;
    Tcl_Obj* CLOSE = NULL;
    Tcl_Obj* GETS = NULL;
    Tcl_Obj* PUTS = NULL;
    Tcl_Obj* BUF = NULL;
    Tcl_Obj* RB = NULL;
    Tcl_Obj* f = NULL;
    Tcl_Obj* file = NULL;
    Tcl_Obj* buf = NULL;
    Tcl_Obj* objResult = NULL;

    Tcl_WideInt len;
    int rc;

    Tcl_ObjCmdProc* cmdProcGets;
    Tcl_ObjCmdProc* cmdProcPuts;
    Tcl_ObjCmdProc* cmdProcOpen;
    Tcl_ObjCmdProc* cmdProcClose;
    

    if (objc != 2) {
        Tcl_AppendResult(interp, "not enough args, expecting 2", (char *) NULL);
        return TCL_ERROR;
    }

    OPEN  = Tcl_NewStringObj("open", -1);   Tcl_IncrRefCount(OPEN);
    CLOSE = Tcl_NewStringObj("close", -1);  Tcl_IncrRefCount(CLOSE);
    GETS  = Tcl_NewStringObj("gets", -1) ;  Tcl_IncrRefCount(GETS);
    PUTS  = Tcl_NewStringObj("puts", -1);   Tcl_IncrRefCount(PUTS);
    BUF   = Tcl_NewStringObj("buf", -1);    Tcl_IncrRefCount(BUF);
    RB    = Tcl_NewStringObj("rb", -1);     Tcl_IncrRefCount(RB);

    argObjvArray = (Tcl_Obj**) ckalloc(3 * sizeof(Tcl_Obj *));
    
    cmdProcGets = GetObjCmd(interp, "gets");
    cmdProcPuts = GetObjCmd(interp, "puts");
    cmdProcOpen = GetObjCmd(interp, "open");
    cmdProcClose = GetObjCmd(interp, "close");
    
    frame = (Tcl_CallFrame*) ckalloc(sizeof(Tcl_CallFrame));
    Tcl_PushCallFrame(interp, frame, Tcl_GetGlobalNamespace(interp), 1);


    file = objv[1];
    Tcl_IncrRefCount(file);
        
    argObjvArray[0] = OPEN;
    argObjvArray[1] = file;
    argObjvArray[2] = RB;
    
    if ((rc = (cmdProcOpen) ((ClientData)NULL, interp,  3, argObjvArray)) != TCL_OK) {
        Tcl_AppendResult(interp, "can't open file", (char *) NULL);
        goto error_exit;
    }

    f = Tcl_GetObjResult(interp);
    Tcl_IncrRefCount(f);
    
    argObjvArray[0] = GETS;
    argObjvArray[1] = f;
    argObjvArray[2] = BUF;
    
    if ((rc = (cmdProcGets) ((ClientData)NULL, interp,  3, argObjvArray)) != TCL_OK) {
        Tcl_AppendResult(interp, "can't read file", (char *) NULL);
        goto error_exit;
    }
    objResult = Tcl_GetObjResult(interp);
    Tcl_IncrRefCount(objResult);
    
    buf = Tcl_ObjGetVar2(interp, BUF, NULL, TCL_LEAVE_ERR_MSG);
    if (buf == NULL) {
	rc = TCL_ERROR;
        Tcl_AppendResult(interp, "cannot load buf from interp", (char*)NULL);
        goto error_exit;
    }
    Tcl_IncrRefCount(buf);

    if ((rc = Tcl_GetWideIntFromObj(interp, objResult, &len)) != TCL_OK) {
        Tcl_AppendResult(interp, "unable to convert result to int", (char *) NULL);
        goto error_exit;
    }
    
    
    
    while ( len >= 0 ) {
        
        argObjvArray[0] = PUTS;
        argObjvArray[1] = buf;
        if ((rc = (cmdProcPuts) ((ClientData)NULL, interp,  2, argObjvArray)) != TCL_OK) {
            Tcl_AppendResult(interp, "while: can't puts", (char*)NULL);
            goto error_exit;
        }
        
	argObjvArray[0] = GETS;
	argObjvArray[1] = f;
	argObjvArray[2] = BUF;
	
	if ((rc = (cmdProcGets) ((ClientData)NULL, interp,  3, argObjvArray)) != TCL_OK) {
            Tcl_AppendResult(interp, "while: can't read file", (char*)NULL);
	    goto error_exit;
	}
	objResult = Tcl_GetObjResult(interp);
	Tcl_IncrRefCount(objResult);
	
        Tcl_DecrRefCount(buf);
	buf = Tcl_ObjGetVar2(interp, BUF, NULL, TCL_LEAVE_ERR_MSG);
	if (buf == NULL) {
	    Tcl_AppendResult(interp, "while: cannot load buf from interp", (char*)NULL);
	    rc = TCL_ERROR;
	    goto error_exit;
	}
	Tcl_IncrRefCount(buf);

	if ((rc = Tcl_GetWideIntFromObj(interp, objResult, &len)) != TCL_OK) {
	    Tcl_AppendResult(interp, "while: unable to convert result to int", (char *) NULL);
	    goto error_exit;
	}
        
    }
    
    argObjvArray[0] = CLOSE;
    argObjvArray[1] = f;
    
    if ((rc = (cmdProcClose) ((ClientData)NULL, interp,  2, argObjvArray)) != TCL_OK) {
        goto error_exit;
    }
    
    rc = TCL_OK;

  error_exit:
    if (OPEN != NULL)  Tcl_DecrRefCount(OPEN);
    if (CLOSE != NULL) Tcl_DecrRefCount(CLOSE);
    if (GETS != NULL)  Tcl_DecrRefCount(GETS);
    if (PUTS != NULL)  Tcl_DecrRefCount(PUTS);
    if (BUF != NULL)   Tcl_DecrRefCount(BUF);
    if (RB != NULL)    Tcl_DecrRefCount(RB);
    if (f != NULL)     Tcl_DecrRefCount(f);
    if (file != NULL)  Tcl_DecrRefCount(file);
    if (buf != NULL)   Tcl_DecrRefCount(buf);
    if (objResult != NULL) Tcl_DecrRefCount(objResult);

    ckfree((char*) argObjvArray);
    Tcl_PopCallFrame(interp);
    ckfree((char*) frame);

    return rc;

}


::critcl::load

# langbench version
proc cat-lb {file} {
	set f [open $file rb]
	while {[gets $f buf] >= 0} { puts $buf }
	close $f
}

set times 5
fconfigure stdout -buffering full -translation binary

set file [lindex $argv 0]

# time original langbench version
set avg_micros [time {cat-lb $file} $times]
puts stderr "cat-lb:    [format %-8.2f [expr [lindex $avg_micros 0] / 1000000.0]]"

# time c extension version
set avg_micros [time {cat-ext $file} $times]
puts stderr "cat-ext:   [format %-8.2f [expr [lindex $avg_micros 0] / 1000000.0]]"


