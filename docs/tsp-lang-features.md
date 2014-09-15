
Tcl Language Subset

  - Limited subset of Tcl, upwardly compatible with standard Tcl

TSP requires that compiled procs use a limited subset of the Tcl language rules.
This subset is entirely upwardly compatible with standard Tcl (other than the 
semantics of variable type conversion discussed earlier.)  

  - Use of nested commands [ ] limited to "set" command

The most notable difference between Tcl and TSP is the use of command substitution
with brackets, "{cmd]"  In TSP, brackets may only be used as a special case of the
"set" command.   Command substitution is also not supported inside of 
unquoted or double quoted string interpolation.


  - Expr uses only native types, not all expr operators/functions implemented

Math and logical expressions only operate on native types (boolean, int, double, string.)
If a "var" or "array" type in encounterd during expression parsing, the compilation will
fail.  

String variables should only be used in logical comparison "eq" and "ne".

The "in" and "ni" operators to test if an element is contained in a list is not supported.


  - Expansion operator not suported {*}

The Tcl 8.5+ list expansion operator "{*}" is not supported, since this introduces
a level of additional runtime interpretation.

  - Namespace not supported

Currently, procedures can only be defined in the global namespace.

  - Limitation on proc name and variable names

Procedure names and variable names inside of procedures must follow strict naming conventions.
Valid identifiers consist of a upper or lower case character A-Z or an underscore, and the following
characters can only contain those characters, plus digits 0-9.  Procedure and variable names
are compiled into native code without using a translation table, so names must be valid in the 
target language.

  - Procedure default arguments and "args" not supported

Procedure arguments may not contain default values, and the use of "args" as the last procedure 
argument is not supported.

     


