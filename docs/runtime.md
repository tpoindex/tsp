Runtime differences

TSP compiled procs have several runtime differences from the Tcl interpreter.

  - Variables only spilled to interp when necessary

TSP bypasses the Tcl interpreter to a great extent.  Variables in a TSP compiled
proc are not automatically defined in the Tcl interpreter.  The major exception
to this feature are array variables, which are defined and accessed in the Tcl
interpreter.  

  - Implicit volatile variables

Since many Tcl commands operate on a *variable name*, and not a value, TSP
compiled procs will "spill" and "load" variables to and from the Tcl interpreter.
This happens automatically for select Tcl commands.  Other programmer defined
procs require that the invoking code arrange for variables to be spilled and
reloaded.

  - Volatile to spill/load varivles to interp

TSP supports an annotation to mark variables as "volatile" to spill variables to
the Tcl interpreter for a single command, and to reload those variables back into
native types after a command finishes.   

Conversion exceptions can occur when reloading variables back into native types.
For instance, if a command is ivoked that "upvar"s a variable and changes its
type into a value that cannot be converted to the native type of the variable, a 
runtime conversion will occur.

  - Global, upvar, variable

Global, upvar, and variable commands are supported in TSP by loading the defined
variables into native variables when the global, upvar, or variable command is 
encountered.  When a TSP compiled proc is exited, these variables are spilled back
into the Tcl interpreter so that the values are updated.  During the execution of
a TSP compiled proc, variables are not automatically spilled, so any traces defined
in an invoking procedure will not fire as expected.

  - Traces

Tracing variables, commands, and execution of commands in TSP compiled procs will 
probably not work as expected, since many commands are compiled away, and variables are
kept as native types.


  - Builtin commands call directly when possible

TSP will also bypass the Tcl interpreter when invoking builtin Tcl commands.  Code is
emitted to directly call builting Tcl commands.   

  - Previous compiled procs invoked directly when possible

Previously compiled TSP procs are also invoked directly, bypassing both the Tcl interpreter and
the Tcl command interface.   Each TSP compiled procedure has a direct interface in which 
procedure arguments are explicitly defined.  When one TSP compiled procedure invokes another
TSP compiled procedure, and the arugment number and types match, the direct interface is used.

  - Threading unsupported

TSP compiled procs are not thread safe, so use of Tcl thread package must be avoided 
when invoking TSP compiled procs.

