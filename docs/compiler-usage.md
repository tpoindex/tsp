# Using the TSP Compiler

In order to use the TSP compiler, you must include the package.  This loads the compiler
into the `::tsp` namespace, and also loads supporting packages `parser`, `hyde` (jtcl), and
`critcl` (tclsh).

     package require tsp

## Commands 

### `tsp::proc` *name args body*

`tsp::proc` defines a TSP compiled proc.  The name of the proc must be a valid
TSP indentifer, and the argument list must not contain default aguments, or the
"args" argument.   At a minimum, a TSP proc requires that the `#tsp::procdef` 
annotation be specified, preferably at the beginning of the body.

### `tsp::debug` *?directory?*

`tsp::debug` specifies a directory to record compile errors.  For each `tsp::proc`, the compiler
log will be saved into a file.  The actual compiled code is also saved into a file.   If the
directory argument is not specified, a directory will be created and the full path of the directory
will be returned.


### `tsp::getCompiledProcs`

`tsp::getCompiledProcs` returns a list of previously compiled procs.


### `tsp::log` ?proc?*

`tsp::log` returns compiler logging information.  If the optional proc is
specified, only that proc's log is returned.  Otherwise, all compilation logging
is returned.  The most recent compiled
proc can also be specified with a single underscore **('_')**.


### `tsp::lastLog` 

`tsp::lastLog` returns logging information for the most recently compiled proc.  It is
a convienence for `tsp::log _`


### `tsp::printLog` *?outfd? ?proc?*

`tsp::printLog` prints the compiler log.  Optional outfd specifies a writable file handle, stderr
is the default.  Optional proc is specified, only that log is returned.  The most recent compiled
proc can also be specified with a single underscore **('_')**.


## Annotations

Annotations are comments inside of the `tsp::proc`.   Annotations may optionally be preceded
with a namespace separator `::`.

### `#tsp::procdef` *returntype -args argtype ... argtype*

`#tsp::procdef` defines the return type of the procedure and the argument types.  If a
proc has no arguments, the argtype list can be defined as "void", or the argtype list
omitted.  Return types can be any of boolean, int, double, string, var, or void.  The actual
code must use a "return" command with a value or variable of the correct type.  An
invalid return value will result in a compile failure, and revert the `tsp::proc` back to
a Tcl interpreted proc.  Additionally, implicit returns (no "return" command coded) is only
valid for return type of "void".  A void proc can also specific "return" without an value or
variable.

### `#tsp::def` *type varname ... varname*

`#tsp::def` defines variables of a given type.  Valid types for `#tsp::def` are boolean,
int, double, string, var, or array.  At least one varname must be included in the `#tsp::def`
annotation.  A `tsp::proc` can contain any number of `#tsp::def` annotation.  It is encouraged that 
`#tsp::def` annotations be defined at or near the top of the procedure.  In any case, the `#tsp::def`
annotation must be specified before the first usage of a variable.

### `#tsp::volatile` *varname ... varname*

`#tsp::volatile` specifies variables that should be spilled into the Tcl interpreter for
the next command, and reload when the command completes.  Use of `#tsp::volatile` before a
control command (if, while, switch, for, foreach) results in the variables spilled before the
command.  Variables are not spilled for each iteration of a for, foreach, or while command.
For absolute control, do not use `#tsp::volatile` before a control command.  Builtin commands
that use varnames instead of values will automatically be spilled and reloaded (e.g. scan, 
vwait, etc.)


### `#tsp::compile` *normal | none| assert | debug*

`#tsp::compile` annotation specifies how a tsp::proc should behave when compiler errors occur.

  * normal - the proc will be compiled, but if any compiler error occurs, the proc will
             be defined as an ordinary Tcl interpreter proc.  This is the default.

  * none - do not compile the proc.  

  * assert - raise a Tcl error if the proc cannot be compiled

  * debug - raise a Tcl error if the proc cannot be compiled.  If compiled without errors,
            the proc will be defined in the Tcl interpreter as a ordinary proc, but will
            include tracing on variables and the return values.  This can be useful to 
            isolate variable that may cause conversion errors.  See the Tracing section below.



## Trace compile type

Compile type *trace* is a special compilation mode. First, it works like *assert* to make sure the
proc can be compiled.  After compilation, the proc is defined as a normal Tcl procedure, but with
tracing and argument checking code enabled.  The tracing code is designed to log when conversion
errors would be raised when compiled as *normal* or *assert*.  Trace logging is written to stderr,
unless tsp::debug was called to specify a directory for logging, in which case a file named
"traces.nnnn" is created.  The suffix "nnnn" is the current clock epoch value.
