package tsp.util;

import tcl.lang.*;

public class TspUtil {
    
    // ********************************************************************************************
    //
    // conversion and interp var assign/get 
    //

    public static boolean lang_convert_boolean_string(Interp interp, String sourceVarName, String errMsg) 
            throws TclException {
        try {
            boolean value = Util.getBoolean(interp, sourceVarName);
            return value;
        } catch (TclException e) {
            throw new TclException(interp, errMsg + "\ncaused by: " + e.getMessage());
        }
    }

    public static boolean lang_convert_boolean_var(Interp interp, TclObject sourceVarName, String errMsg)  
            throws TclException {
        try {
            boolean value = TclBoolean.get(interp, sourceVarName);
            return value;
        } catch (TclException e) {
            throw new TclException(interp, errMsg + "\ncaused by: " + e.getMessage());
        }
    }

    public static long lang_convert_int_string(Interp interp, String sourceVarName, String errMsg)
            throws TclException {
        try {
            long value = Util.getWideInt(interp, sourceVarName);
            return value;
        } catch (TclException e) {
            throw new TclException(interp, errMsg + "\ncaused by: " + e.getMessage());
        }
    }

    public static double lang_convert_double_string(Interp interp, String sourceVarName, String errMsg)
            throws TclException {
        try {
            double value = Util.getDouble(interp, sourceVarName);
            return value;
        } catch (TclException e) {
            throw new TclException(interp, errMsg + "\ncaused by: " + e.getMessage());
        }
    }


    @SuppressWarnings("deprecation")
    public static long lang_convert_int_var(Interp interp, TclObject sourceVarName, String errMsg)
            throws TclException {
        try {
            long value = TclInteger.get(interp, sourceVarName);
            return value;
        } catch (TclException e) {
            throw new TclException(interp, errMsg);
        }
    }

    public static double lang_convert_double_var(Interp interp, TclObject sourceVarName, String errMsg)
            throws TclException {
        try {
            double value = TclDouble.get(interp, sourceVarName);
            return value;
        } catch (TclException e) {
            throw new TclException(interp, errMsg);
        }
    }

    public static TclObject lang_assign_var_array_idxvar(Interp interp, String arrVar, String idxVar, String errMsg)
            throws TclException {
        try {
            TclObject value = interp.getVar(arrVar, idxVar, 0);
            return value;
        } catch (TclException te) {
            throw new TclException(interp, errMsg);
        }
    }

    public static TclObject lang_assign_var_boolean(TclObject targetVarName, boolean sourceVarName) {
        if (targetVarName != null) {
            targetVarName.release();
        } 
        targetVarName = TclBoolean.newInstance(sourceVarName);
        targetVarName.preserve();
        return targetVarName;
    }

    public static TclObject lang_assign_var_int(TclObject targetVarName, long sourceVarName) {
        if (targetVarName != null) {
            if (targetVarName.isShared()) {
                targetVarName.release();
                targetVarName = TclInteger.newInstance((long) sourceVarName);
                targetVarName.preserve();
            } else {
                TclInteger.set(targetVarName, (long) sourceVarName);
            }
        } else {
            targetVarName = TclInteger.newInstance((long) sourceVarName);
            targetVarName.preserve();
        }
        return targetVarName;
    }

    public static TclObject lang_assign_var_double(TclObject targetVarName, double sourceVarName) {
        if (targetVarName != null) {
            if (targetVarName.isShared()) {
                targetVarName.release();
                targetVarName = TclDouble.newInstance(sourceVarName);
                targetVarName.preserve();
            } else {
                TclDouble.set(targetVarName, sourceVarName);
            }
        } else {
            targetVarName = TclDouble.newInstance((long) sourceVarName);
            targetVarName.preserve();
        }
        return targetVarName;
    }

    public static TclObject lang_assign_var_string(TclObject targetVarName, String sourceVarName) {
        if (targetVarName != null) {
            if (targetVarName.isShared()) {
                targetVarName.release();
                targetVarName = TclString.newInstance(sourceVarName);
                targetVarName.preserve();
            } else {
                TclString.empty(targetVarName);
                TclString.append(targetVarName, sourceVarName);
            }
        } else {
            targetVarName = TclString.newInstance(sourceVarName);
            targetVarName.preserve();
        }
        return targetVarName;
    }

    public static TclObject lang_assign_var_var(TclObject targetVarName, TclObject sourceVarName) {
        if (targetVarName != null) {
            targetVarName.release();
        }
        targetVarName = sourceVarName;
        targetVarName.preserve();
        return targetVarName;
    }

    public static void lang_assign_array_var(Interp interp, String targetArrayStr, String targetIdxStr, TclObject var) 
            throws TclException {
        try {
            var.preserve();
            interp.setVar(targetArrayStr, targetIdxStr, var, 0);
        } catch (TclException te) {
            throw te;
        } catch (TclRuntimeError tre) {
            throw tre;
        } finally {
            var.release();
        }
    }


    // ********************************************************************************************
    //
    // runtime support
    //

    // push a new callframe by wiring up interp fields (why isn't this a CallFrame constructor?)
    public static CallFrame pushNewCallFrame(Interp interp) {
        CallFrame frame = interp.newCallFrame();
        frame.level = (interp.varFrame == null) ? 1 : (interp.varFrame.level + 1);
        frame.caller = interp.frame;
        frame.callerVar = interp.varFrame;
        interp.frame = frame;
        interp.varFrame = frame;
        return frame;
    }

}








