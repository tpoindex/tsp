# Tcl Static Prime

Tcl Static Prime (TSP) is an experimental compiler for the Tcl langauge 
that produces C or Java code, which is then compiled on-the-fly during 
execution of a Tcl program.   TSP is a currently a work-in-progress;
it's performance varies greatly depending the Tcl commands that are
currently compiled.

TSP compiles a typed subset of Tcl.  Proc definitions and variables are 
typed by comment-based annotations.  Native types supported are boolean, 
int (64-bit integers), double, string, and var (TclObjects for lists, dicts,
etc.)

TSP language restrictions include restricting all arithmatic expressions
(expr, if, while, etc) to using boolean, int, double, and string data types.
Additionally, expressions may not include array references or nested commands.
TSP also assumes that builtin Tcl commands are not re-defined, as builtin 
commands are compiled to C or Java,  or the native command implementation is 
invoked directly, bypassing the Tcl interpreter.  


TSP is written entirely in Tcl, with support libraries written in C and Java.


# Docs

  1. [Introduction](https://github.com/tpoindex/tsp/blob/master/docs/introduction.md)
  2. [Features](https://github.com/tpoindex/tsp/blob/master/docs/tsp-lang-features.md)
  3. [Type System](https://github.com/tpoindex/tsp/blob/master/docs/type-system.md)
  4. [Compiled Commands](https://github.com/tpoindex/tsp/blob/master/docs/compiled-commands.md)
  5. [Runtime](https://github.com/tpoindex/tsp/blob/master/docs/runtime.md)
  6. [Compiler Usage](https://github.com/tpoindex/tsp/blob/master/docs/compiler-usage.md)
  7. [Future Improvements](https://github.com/tpoindex/tsp/blob/master/docs/future-improvements.md)
  8. [Install](https://github.com/tpoindex/tsp/blob/master/docs/install.md)
  9. [Misc.](https://github.com/tpoindex/tsp/blob/master/docs/misc.md)


Wiki (Q & A, discussion, other): http://wiki.tcl.tk/Tcl%20Static%20Prime
