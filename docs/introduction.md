Introduction

  - Brief description and example code

Tcl Static Prime (tsp) is a compiler for the Tcl langauge that produces C or Java code, which 
is then compiled on-the-fly during execution of a Tcl program.  TSP compiles select 
Tcl *procs*, not an entire program.  The result is generally much 


  - Fallback to Tcl proc if compilation fails
  - Use of native types
  - TSP pragmas (annotations) for proc and variable definitions
  - Subset of Tcl language
  - Trends of other systems: asm.js, typescript.js, python type annotations proposal, mira (ruby)
  - Use of profiler to target procs
  - Importance of Unit testing

