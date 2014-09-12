Introduction

  - Brief description and example code
  - Use of native types
  - TSP pragmas (annotations) for proc and variable definitions
  - Subset of Tcl language
  - Fallback to Tcl proc if compilation fails
  - Use of profiler to target procs  
  - Importance of Unit testing


Type system

  - Native types
    * boolean
    * int
    * double
    * string
    * var - also for lists, dicts
  - Arrays - uses interpreter variables


Tcl Language Subset

  - Limited subset of Tcl, upwardly compatible with standard Tcl
  - Use of nested commands [ ] limited to "set" command
  - Expr uses only native types, not all expr operators/functions implemented
  - Expansion operator not suported {*}
  - Namespace not supported
  - Limitation on proc name and variable names
  - Quoted word substitutions " "
  - Conversions and conversion errors
  - Implicit declarations
  - Variables defined on proc entry
     

Runtime differences

  - Variables only spilled to interp when necessary
  - Volatile to spill/load varivles to interp
  - Implicit volatile variables
  - Global, upvar, variable
  - Builtin commands call directlhy when possible
  - Previous compiled procs invoked directly when possible


Using the Compiler 

  - tsp::proc
  - Pragmas
    * #tsp::compile
    * #tsp::procdef
    * #tsp::def
    * #tsp::volatile
  - tsp::debug
  - tsp::printErrorsWarnings
  - Trace compile type 


Compiled commands and limitations

  - Fall back to command/interp invocation
  - Compiled commands
    * set
    * Control commands
    * Variable commands
    * List commands
    * String commands
  - Lightly-compiled commands
  

Benchmark results

  - TclBench
  - langbench
  - Shootout


Comparison to previous compilers

  - ICEMFD compiler (Rouse/Christopher, 1996)
  - TclC (Koski, 1996)
  - kt2c (Cuthbert, 2000)
  - TclVM (Vitale, 2004)
  - Parenthetcl (Strickland, 2004)
  - TJC (DeJong, 2005)
  - Tclc (Bauer, 2011)


Internals

  - Tcl parser extension
  - hyde / critcl / tcc4tcl
  - Compilation Unit dict
  - Parser utilities - parse_word, parse_body
  - Code generation
  - Expr generation
  - Temporary variables
  - Invoke Tcl commands, direct and interp 
  - Optimization of native to var temporary variables
  

