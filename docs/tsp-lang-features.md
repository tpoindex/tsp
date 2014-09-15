
Tcl Language Subset

  - Limited subset of Tcl, upwardly compatible with standard Tcl

TSP requires that compiled procs use a limited subset of the Tcl language rules.
This subset is entirely upwardly compatible with standard Tcl (other than the 
semantics of variable type conversion discussed earlier.)  

  - Use of nested commands [ ] limited to "set" command

The most notable difference between Tcl and TSP is the use of command substitution
with brackets, "{cmd]"  In TSP, brackets may only be used as a special case of the
"set" command.  


  - Expr uses only native types, not all expr operators/functions implemented
  - Expansion operator not suported {*}
  - Namespace not supported
  - Limitation on proc name and variable names
  - Procedure default arguments and "args" not supported
  - Quoted word substitutions " "
     


