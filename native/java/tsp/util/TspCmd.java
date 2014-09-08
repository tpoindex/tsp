package tsp.util;

import tcl.lang.Command;
import tcl.lang.TclObject;
import tcl.lang.TclString;
import tcl.lang.cmd.*;

public class TspCmd {


    public static final Command builtin_after = new tcl.lang.cmd.AfterCmd();
    public static final TclObject CmdStringObjAfter;
    static { CmdStringObjAfter = TclString.newInstance("after"); CmdStringObjAfter.preserve(); }

    public static final Command builtin_append = new tcl.lang.cmd.AppendCmd();
    public static final TclObject CmdStringObjAppend;
    static { CmdStringObjAppend = TclString.newInstance("append"); CmdStringObjAppend.preserve(); }

    public static final Command builtin_apply = new tcl.lang.cmd.ApplyCmd();
    public static final TclObject CmdStringObjApply;
    static { CmdStringObjApply = TclString.newInstance("apply"); CmdStringObjApply.preserve(); }

    public static final Command builtin_array = new tcl.lang.cmd.ArrayCmd();
    public static final TclObject CmdStringObjArray;
    static { CmdStringObjArray = TclString.newInstance("array"); CmdStringObjArray.preserve(); }

    public static final Command builtin_binary = new tcl.lang.cmd.BinaryCmd();
    public static final TclObject CmdStringObjBinary;
    static { CmdStringObjBinary = TclString.newInstance("binary"); CmdStringObjBinary.preserve(); }

    public static final Command builtin_break = new tcl.lang.cmd.BreakCmd();
    public static final TclObject CmdStringObjBreak;
    static { CmdStringObjBreak = TclString.newInstance("break"); CmdStringObjBreak.preserve(); }

    public static final Command builtin_case = new tcl.lang.cmd.CaseCmd();
    public static final TclObject CmdStringObjCase;
    static { CmdStringObjCase = TclString.newInstance("case"); CmdStringObjCase.preserve(); }

    public static final Command builtin_catch = new tcl.lang.cmd.CatchCmd();
    public static final TclObject CmdStringObjCatch;
    static { CmdStringObjCatch = TclString.newInstance("catch"); CmdStringObjCatch.preserve(); }

    public static final Command builtin_cd = new tcl.lang.cmd.CdCmd();
    public static final TclObject CmdStringObjCd;
    static { CmdStringObjCd = TclString.newInstance("cd"); CmdStringObjCd.preserve(); }

    public static final Command builtin_clock = new tcl.lang.cmd.ClockCmd();
    public static final TclObject CmdStringObjClock;
    static { CmdStringObjClock = TclString.newInstance("clock"); CmdStringObjClock.preserve(); }

    public static final Command builtin_close = new tcl.lang.cmd.CloseCmd();
    public static final TclObject CmdStringObjClose;
    static { CmdStringObjClose = TclString.newInstance("close"); CmdStringObjClose.preserve(); }

    public static final Command builtin_concat = new tcl.lang.cmd.ConcatCmd();
    public static final TclObject CmdStringObjConcat;
    static { CmdStringObjConcat = TclString.newInstance("concat"); CmdStringObjConcat.preserve(); }

    public static final Command builtin_continue = new tcl.lang.cmd.ContinueCmd();
    public static final TclObject CmdStringObjContinue;
    static { CmdStringObjContinue = TclString.newInstance("continue"); CmdStringObjContinue.preserve(); }

    public static final Command builtin_dict = new tcl.lang.cmd.DictCmd();
    public static final TclObject CmdStringObjDict;
    static { CmdStringObjDict = TclString.newInstance("dict"); CmdStringObjDict.preserve(); }

    public static final Command builtin_encoding = new tcl.lang.cmd.EncodingCmd();
    public static final TclObject CmdStringObjEncoding;
    static { CmdStringObjEncoding = TclString.newInstance("encoding"); CmdStringObjEncoding.preserve(); }

    public static final Command builtin_eof = new tcl.lang.cmd.EofCmd();
    public static final TclObject CmdStringObjEof;
    static { CmdStringObjEof = TclString.newInstance("eof"); CmdStringObjEof.preserve(); }

    public static final Command builtin_error = new tcl.lang.cmd.ErrorCmd();
    public static final TclObject CmdStringObjError;
    static { CmdStringObjError = TclString.newInstance("error"); CmdStringObjError.preserve(); }

    public static final Command builtin_eval = new tcl.lang.cmd.EvalCmd();
    public static final TclObject CmdStringObjEval;
    static { CmdStringObjEval = TclString.newInstance("eval"); CmdStringObjEval.preserve(); }

    public static final Command builtin_exec = new tcl.lang.cmd.ExecCmd();
    public static final TclObject CmdStringObjExec;
    static { CmdStringObjExec = TclString.newInstance("exec"); CmdStringObjExec.preserve(); }

    public static final Command builtin_exit = new tcl.lang.cmd.ExitCmd();
    public static final TclObject CmdStringObjExit;
    static { CmdStringObjExit = TclString.newInstance("exit"); CmdStringObjExit.preserve(); }

    public static final Command builtin_expr = new tcl.lang.cmd.ExprCmd();
    public static final TclObject CmdStringObjExpr;
    static { CmdStringObjExpr = TclString.newInstance("expr"); CmdStringObjExpr.preserve(); }

    public static final Command builtin_fblocked = new tcl.lang.cmd.FblockedCmd();
    public static final TclObject CmdStringObjFblocked;
    static { CmdStringObjFblocked = TclString.newInstance("fblocked"); CmdStringObjFblocked.preserve(); }

    public static final Command builtin_fconfigure = new tcl.lang.cmd.FconfigureCmd();
    public static final TclObject CmdStringObjFconfigure;
    static { CmdStringObjFconfigure = TclString.newInstance("fconfigure"); CmdStringObjFconfigure.preserve(); }

    public static final Command builtin_fcopy = new tcl.lang.cmd.FcopyCmd();
    public static final TclObject CmdStringObjFcopy;
    static { CmdStringObjFcopy = TclString.newInstance("fcopy"); CmdStringObjFcopy.preserve(); }

    public static final Command builtin_file = new tcl.lang.cmd.FileCmd();
    public static final TclObject CmdStringObjFile;
    static { CmdStringObjFile = TclString.newInstance("file"); CmdStringObjFile.preserve(); }

    public static final Command builtin_fileevent = new tcl.lang.cmd.FileeventCmd();
    public static final TclObject CmdStringObjFileevent;
    static { CmdStringObjFileevent = TclString.newInstance("fileevent"); CmdStringObjFileevent.preserve(); }

    public static final Command builtin_flush = new tcl.lang.cmd.FlushCmd();
    public static final TclObject CmdStringObjFlush;
    static { CmdStringObjFlush = TclString.newInstance("flush"); CmdStringObjFlush.preserve(); }

    public static final Command builtin_for = new tcl.lang.cmd.ForCmd();
    public static final TclObject CmdStringObjFor;
    static { CmdStringObjFor = TclString.newInstance("for"); CmdStringObjFor.preserve(); }

    public static final Command builtin_foreach = new tcl.lang.cmd.ForeachCmd();
    public static final TclObject CmdStringObjForeach;
    static { CmdStringObjForeach = TclString.newInstance("foreach"); CmdStringObjForeach.preserve(); }

    public static final Command builtin_format = new tcl.lang.cmd.FormatCmd();
    public static final TclObject CmdStringObjFormat;
    static { CmdStringObjFormat = TclString.newInstance("format"); CmdStringObjFormat.preserve(); }

    public static final Command builtin_gets = new tcl.lang.cmd.GetsCmd();
    public static final TclObject CmdStringObjGets;
    static { CmdStringObjGets = TclString.newInstance("gets"); CmdStringObjGets.preserve(); }

    public static final Command builtin_glob = new tcl.lang.cmd.GlobCmd();
    public static final TclObject CmdStringObjGlob;
    static { CmdStringObjGlob = TclString.newInstance("glob"); CmdStringObjGlob.preserve(); }

    public static final Command builtin_global = new tcl.lang.cmd.GlobalCmd();
    public static final TclObject CmdStringObjGlobal;
    static { CmdStringObjGlobal = TclString.newInstance("global"); CmdStringObjGlobal.preserve(); }

    public static final Command builtin_if = new tcl.lang.cmd.IfCmd();
    public static final TclObject CmdStringObjIf;
    static { CmdStringObjIf = TclString.newInstance("if"); CmdStringObjIf.preserve(); }

    public static final Command builtin_incr = new tcl.lang.cmd.IncrCmd();
    public static final TclObject CmdStringObjIncr;
    static { CmdStringObjIncr = TclString.newInstance("incr"); CmdStringObjIncr.preserve(); }

    public static final Command builtin_info = new tcl.lang.cmd.InfoCmd();
    public static final TclObject CmdStringObjInfo;
    static { CmdStringObjInfo = TclString.newInstance("info"); CmdStringObjInfo.preserve(); }

    public static final Command builtin_interp = new tcl.lang.cmd.InterpCmd();
    public static final TclObject CmdStringObjInterp;
    static { CmdStringObjInterp = TclString.newInstance("interp"); CmdStringObjInterp.preserve(); }

    public static final Command builtin_join = new tcl.lang.cmd.JoinCmd();
    public static final TclObject CmdStringObjJoin;
    static { CmdStringObjJoin = TclString.newInstance("join"); CmdStringObjJoin.preserve(); }

    public static final Command builtin_lappend = new tcl.lang.cmd.LappendCmd();
    public static final TclObject CmdStringObjLappend;
    static { CmdStringObjLappend = TclString.newInstance("lappend"); CmdStringObjLappend.preserve(); }

    public static final Command builtin_lassign = new tcl.lang.cmd.LassignCmd();
    public static final TclObject CmdStringObjLassign;
    static { CmdStringObjLassign = TclString.newInstance("lassign"); CmdStringObjLassign.preserve(); }

    public static final Command builtin_lindex = new tcl.lang.cmd.LindexCmd();
    public static final TclObject CmdStringObjLindex;
    static { CmdStringObjLindex = TclString.newInstance("lindex"); CmdStringObjLindex.preserve(); }

    public static final Command builtin_linsert = new tcl.lang.cmd.LinsertCmd();
    public static final TclObject CmdStringObjLinsert;
    static { CmdStringObjLinsert = TclString.newInstance("linsert"); CmdStringObjLinsert.preserve(); }

    public static final Command builtin_list = new tcl.lang.cmd.ListCmd();
    public static final TclObject CmdStringObjList;
    static { CmdStringObjList = TclString.newInstance("list"); CmdStringObjList.preserve(); }

    public static final Command builtin_llength = new tcl.lang.cmd.LlengthCmd();
    public static final TclObject CmdStringObjLlength;
    static { CmdStringObjLlength = TclString.newInstance("llength"); CmdStringObjLlength.preserve(); }

    public static final Command builtin_lrange = new tcl.lang.cmd.LrangeCmd();
    public static final TclObject CmdStringObjLrange;
    static { CmdStringObjLrange = TclString.newInstance("lrange"); CmdStringObjLrange.preserve(); }

    public static final Command builtin_lrepeat = new tcl.lang.cmd.LrepeatCmd();
    public static final TclObject CmdStringObjLrepeat;
    static { CmdStringObjLrepeat = TclString.newInstance("lrepeat"); CmdStringObjLrepeat.preserve(); }

    public static final Command builtin_lreplace = new tcl.lang.cmd.LreplaceCmd();
    public static final TclObject CmdStringObjLreplace;
    static { CmdStringObjLreplace = TclString.newInstance("lreplace"); CmdStringObjLreplace.preserve(); }

    public static final Command builtin_lreverse = new tcl.lang.cmd.LreverseCmd();
    public static final TclObject CmdStringObjLreverse;
    static { CmdStringObjLreverse = TclString.newInstance("lreverse"); CmdStringObjLreverse.preserve(); }

    public static final Command builtin_lsearch = new tcl.lang.cmd.LsearchCmd();
    public static final TclObject CmdStringObjLsearch;
    static { CmdStringObjLsearch = TclString.newInstance("lsearch"); CmdStringObjLsearch.preserve(); }

    public static final Command builtin_lset = new tcl.lang.cmd.LsetCmd();
    public static final TclObject CmdStringObjLset;
    static { CmdStringObjLset = TclString.newInstance("lset"); CmdStringObjLset.preserve(); }

    public static final Command builtin_lsort = new tcl.lang.cmd.LsortCmd();
    public static final TclObject CmdStringObjLsort;
    static { CmdStringObjLsort = TclString.newInstance("lsort"); CmdStringObjLsort.preserve(); }

    public static final Command builtin_namespace = new tcl.lang.cmd.NamespaceCmd();
    public static final TclObject CmdStringObjNamespace;
    static { CmdStringObjNamespace = TclString.newInstance("namespace"); CmdStringObjNamespace.preserve(); }

    public static final Command builtin_open = new tcl.lang.cmd.OpenCmd();
    public static final TclObject CmdStringObjOpen;
    static { CmdStringObjOpen = TclString.newInstance("open"); CmdStringObjOpen.preserve(); }

    public static final Command builtin_package = new tcl.lang.cmd.PackageCmd();
    public static final TclObject CmdStringObjPackage;
    static { CmdStringObjPackage = TclString.newInstance("package"); CmdStringObjPackage.preserve(); }

    public static final Command builtin_pid = new tcl.lang.cmd.PidCmd();
    public static final TclObject CmdStringObjPid;
    static { CmdStringObjPid = TclString.newInstance("pid"); CmdStringObjPid.preserve(); }

    public static final Command builtin_puts = new tcl.lang.cmd.PutsCmd();
    public static final TclObject CmdStringObjPuts;
    static { CmdStringObjPuts = TclString.newInstance("puts"); CmdStringObjPuts.preserve(); }

    public static final Command builtin_pwd = new tcl.lang.cmd.PwdCmd();
    public static final TclObject CmdStringObjPwd;
    static { CmdStringObjPwd = TclString.newInstance("pwd"); CmdStringObjPwd.preserve(); }

    public static final Command builtin_read = new tcl.lang.cmd.ReadCmd();
    public static final TclObject CmdStringObjRead;
    static { CmdStringObjRead = TclString.newInstance("read"); CmdStringObjRead.preserve(); }

    public static final Command builtin_regexp = new tcl.lang.cmd.RegexpCmd();
    public static final TclObject CmdStringObjRegexp;
    static { CmdStringObjRegexp = TclString.newInstance("regexp"); CmdStringObjRegexp.preserve(); }

    public static final Command builtin_regsub = new tcl.lang.cmd.RegsubCmd();
    public static final TclObject CmdStringObjRegsub;
    static { CmdStringObjRegsub = TclString.newInstance("regsub"); CmdStringObjRegsub.preserve(); }

    public static final Command builtin_rename = new tcl.lang.cmd.RenameCmd();
    public static final TclObject CmdStringObjRename;
    static { CmdStringObjRename = TclString.newInstance("rename"); CmdStringObjRename.preserve(); }

    public static final Command builtin_return = new tcl.lang.cmd.ReturnCmd();
    public static final TclObject CmdStringObjReturn;
    static { CmdStringObjReturn = TclString.newInstance("return"); CmdStringObjReturn.preserve(); }

    public static final Command builtin_scan = new tcl.lang.cmd.ScanCmd();
    public static final TclObject CmdStringObjScan;
    static { CmdStringObjScan = TclString.newInstance("scan"); CmdStringObjScan.preserve(); }

    public static final Command builtin_seek = new tcl.lang.cmd.SeekCmd();
    public static final TclObject CmdStringObjSeek;
    static { CmdStringObjSeek = TclString.newInstance("seek"); CmdStringObjSeek.preserve(); }

    public static final Command builtin_set = new tcl.lang.cmd.SetCmd();
    public static final TclObject CmdStringObjSet;
    static { CmdStringObjSet = TclString.newInstance("set"); CmdStringObjSet.preserve(); }

    public static final Command builtin_socket = new tcl.lang.cmd.SocketCmd();
    public static final TclObject CmdStringObjSocket;
    static { CmdStringObjSocket = TclString.newInstance("socket"); CmdStringObjSocket.preserve(); }

    public static final Command builtin_source = new tcl.lang.cmd.SourceCmd();
    public static final TclObject CmdStringObjSource;
    static { CmdStringObjSource = TclString.newInstance("source"); CmdStringObjSource.preserve(); }

    public static final Command builtin_split = new tcl.lang.cmd.SplitCmd();
    public static final TclObject CmdStringObjSplit;
    static { CmdStringObjSplit = TclString.newInstance("split"); CmdStringObjSplit.preserve(); }

    public static final Command builtin_string = new tcl.lang.cmd.StringCmd();
    public static final TclObject CmdStringObjString;
    static { CmdStringObjString = TclString.newInstance("string"); CmdStringObjString.preserve(); }

    public static final Command builtin_subst = new tcl.lang.cmd.SubstCmd();
    public static final TclObject CmdStringObjSubst;
    static { CmdStringObjSubst = TclString.newInstance("subst"); CmdStringObjSubst.preserve(); }

    public static final Command builtin_switch = new tcl.lang.cmd.SwitchCmd();
    public static final TclObject CmdStringObjSwitch;
    static { CmdStringObjSwitch = TclString.newInstance("switch"); CmdStringObjSwitch.preserve(); }

    public static final Command builtin_tell = new tcl.lang.cmd.TellCmd();
    public static final TclObject CmdStringObjTell;
    static { CmdStringObjTell = TclString.newInstance("tell"); CmdStringObjTell.preserve(); }

    public static final Command builtin_time = new tcl.lang.cmd.TimeCmd();
    public static final TclObject CmdStringObjTime;
    static { CmdStringObjTime = TclString.newInstance("time"); CmdStringObjTime.preserve(); }

    public static final Command builtin_trace = new tcl.lang.cmd.TraceCmd();
    public static final TclObject CmdStringObjTrace;
    static { CmdStringObjTrace = TclString.newInstance("trace"); CmdStringObjTrace.preserve(); }

    public static final Command builtin_unset = new tcl.lang.cmd.UnsetCmd();
    public static final TclObject CmdStringObjUnset;
    static { CmdStringObjUnset = TclString.newInstance("unset"); CmdStringObjUnset.preserve(); }

    public static final Command builtin_update = new tcl.lang.cmd.UpdateCmd();
    public static final TclObject CmdStringObjUpdate;
    static { CmdStringObjUpdate = TclString.newInstance("update"); CmdStringObjUpdate.preserve(); }

    public static final Command builtin_uplevel = new tcl.lang.cmd.UplevelCmd();
    public static final TclObject CmdStringObjUplevel;
    static { CmdStringObjUplevel = TclString.newInstance("uplevel"); CmdStringObjUplevel.preserve(); }

    public static final Command builtin_upvar = new tcl.lang.cmd.UpvarCmd();
    public static final TclObject CmdStringObjUpvar;
    static { CmdStringObjUpvar = TclString.newInstance("upvar"); CmdStringObjUpvar.preserve(); }

    public static final Command builtin_variable = new tcl.lang.cmd.VariableCmd();
    public static final TclObject CmdStringObjVariable;
    static { CmdStringObjVariable = TclString.newInstance("variable"); CmdStringObjVariable.preserve(); }

    public static final Command builtin_vwait = new tcl.lang.cmd.VwaitCmd();
    public static final TclObject CmdStringObjVwait;
    static { CmdStringObjVwait = TclString.newInstance("vwait"); CmdStringObjVwait.preserve(); }

    public static final Command builtin_while = new tcl.lang.cmd.WhileCmd();
    public static final TclObject CmdStringObjWhile;
    static { CmdStringObjWhile = TclString.newInstance("while"); CmdStringObjWhile.preserve(); }

}
