# Miscellaneous

## Profiling existing Tcl programs

Since TSP requires comment-based annotations for compilation and
use of a limited subset of Tcl, it may be impractical to alter 
an entire program.  Use of a profiler can help to isolate the most
runtime intensive Tcl procedures for refactoring into the TSP 
Tcl subset.  

One such profiler is included in Tcllib, the `profiler` module.
It performs proc-based profiling to identify candidate procs for
refactoring.  Other profilers can be found on the Tcl Wiki.

## Internals

TSP uses the `parser` extension to parse Tcl commands and expressions.
TSP is fairly intolerant of invalid Tcl code, and fails quickly when
encountering such code.

Otherwise, TSP will try to continue parsing after a limitation has
been parsed, in order to uncover other TSP limitations.


## Shadow variables, dirty checking, var constant

TSP performs some minor optimizations, particularly allocating *shadow* var
variables (i.e., Tcl_Obj/TclObject) to use when calling builtin Tcl commands, or any
other command invoked via the Tcl interp.  Usage is tracked (*dirty checking*), 
and if the variable has not been altered from one Tcl invocation to another, 
the shadow variable is assumed to be *clean*, and will not be reloaded with 
the native value.  

TSP also makes constants for var variables used in calls to the Tcl interpreter.
Any literal string, integer, double, or boolean used in a Tcl call is initialized
once and used thereafter.

## Code generation

Code generation is fairly simplistic, a nearly direct translation of
Tcl code into C or Java.  Other than shadow variables, dirty checking,
and constant var variables, little other optimization is done.  This can emit native
code that seems unnecessary, such as assigning a result to a temporary 
variable, and then another assignment from the temporary variable to the target.  
No need to worry, the Java and C compilers are way better at code optimization 
than TSP, and can eliminate such transformations.

Common modules generate code for both Java and C.  Low level modules
perform the code generation for each native language.  Both C and Java
compiled procs consist of two native language functions/methods - one
that serves as the Tcl interface, for instances when the command is
invoked by a non-compiled Tcl command.  The other function/method is
the direct interface to the compiled code using natively typed 
arguments.

Invoking Tcl builtin commands is done by getting a reference to the 
Tcl C or Java function/object implementing the command.  In the case of
Java, this is done at compile time.  For C, this is done once at runtime,
as C/Tcl ensemble commands require the ClientData information in
addition to the actual C function address.

Likewise, invoking a previously compiled proc with the Java backend
makes used of Java's dynamic linking resolution.  For C, the 
previously compiled function is found at runtime by querying the
interpreter to find the proc's Tcl interface function.  The Tcl 
interface function is invoked with a ClientData pointer; the
Tcl interface function recognizes this pattern and assigns the
address of the direct function into the caller's ClientData.
From then on, the calling function can invoke the callee's 
direct function via a function pointer.


## Native compilation

TSP makes use of Critcl for C code compilation, and Hyde for Java
code compilation.  Currently, TSP compiles each proc separately (future
version may compile a whole sourced file at a time.)


## Comparison to previous Tcl compilers

### TJC - Tcl to Java compiler (DeJong, 2006)

Similarities:

  * Both are primarily written in Tcl
  * Both use the `parser` extension for Tcl parsing
  
Differences:

  * TSP produces C or Java; TJC produces only Java.
  * TSP uses native types; TJC uses Tcl Objects.
  * TSP compiles a subset of Tcl, and restricts Tcl semantics;  TJC implements Tcl semantics.
  * TSP avoids the Tcl interpreter as much as possible; TJC uses the Tcl interpreter extensively
  * TSP currently compiles on the fly only; TJC can also be used in an ahead-of-time configuration.
  * TSP uses type annotations for variable typing; TJC uses TclObjects for local variables.

### Koski Compiler (Koski, 1996)

Similarities:
  * Both produce native code where possible.

Differences:

  * TSP is written primarily in Tcl; Koski is written in C.
  * TSP produces C or Java; TJC produces only C.
  * TSP uses type annotations for variable typing; Koski performs type inference.
  * TSP compiles on the fly only; Koski uses ahead-of-time compilation.
  * Koski compiler has been dormant and is considered historical.

### Parenthetcl (Strickland, 2004)

Similarities:

  * Both use a type system for native variables

Differences:

  * TSP is written primarily in Tcl; Parenthetcl is written in C.
  * TSP uses comment-based type annotations, and is upwardly compatible with ordinary Tcl; 
    Parenthetcl uses language-based type annotations, and is not compatible with Tcl.
  * TSP compiles on the fly only; Parenthetcl uses ahead-of-time compilation.
  * Parenthetcl has been dormant since 2006 and is considered historical.


### Tclc (Baur, 2006)

Differences:

  * TSP is written primarily in Tcl; Tclc is written in Haskell.
  * Tclc has been dormant since 2011 and is considered historical.


### Other Tcl compilers

The following Tcl compilers are either been succeeded by Tcl 8.0+, or are
inactive/historical.  The only exceptions are TyCL and TclBDD/llvm which
are under development.

  * ICEM CFD compiler (Rouse/Christopher, 1995)
  * "Compiler" (Otto, 2000)
  * kt2c (Cuthbert, 2000)
  * TclVM (Vitale, 2004)
  * TyCL (Buss, 2012)
  * TclBDD/Quadcode/llvm (Kenny/Fellows, 2015)
