# Compiled commands and limitations

This is the current list of TSP compiled commands.  Note that some commands
may include restrictions on what can be compiled.  For any command that
isn't currently compiled, or for any command usage that violates the
compiler restrictions, the Tcl builtin command is invoked.

Some commands are "lightly compiled", For these command, arguments are scanned
for variable name usage to ensure that the variables are spilled and loaded.

## Compiled commands

  * Assignment command
    * set

  * Control commands
    * if (^1)
    * for (^1)
    * foreach (^1)
    * while (^1)
    * break
    * continue
    * catch
    * switch (^1)
    * return (^1)

  * Variable commands
    * global
    * upvar (^1)
    * variable
    * unset (^1)

  * List commands
    * lset  (^2) 
    * lappend
    * llength
    * list
    * lindex (^1)

  * String commands
    * append
    * scan  (^2)
    * binary scan  (^2)
    * string index (^1)
    * string length
    * string range (^1)

  * Arithmatic commands
    * expr
    * incr
  
 > ^1 - indicates limitations on arguments/style

 > ^2 - indicates lightly compiled, automatic volatile variable handling


## Limitations

  * set - causes immediate conversion if target and source are different types.
  * if - see expr limitations; then/elsecode bodies must be enclosed in braces;
  * for - see expr limitations (applies to all expression arguments); code body must be 
    enclosed in braces. 
  * foreach - only a single list of iteration variables, and a single iterable value; code body must
    be enclosed in braces.
  * while - see expr limitations; code body must be enclosed in braces.
  * switch - no optional arguments, patterns and scripts must be a single list argument enclosed in braces.
  * return - no optional arguments, must be coded for non-void proc types.
  * lindex - indexes may only be an integer, `end`, `end-integervar` or `end-integerconst`.
  * string range - indexes may only be an integer, `end`, `end-integervar` or `end-integerconst`.
  * expr - no embedded commands or array references, no 'tsp::var' variables; no list operators `in` or `ni`;
    string arguments can only be used on both sides of a logical operator; tcl mathfunc specifiers not supported.
  * return - no options supported; must be coded for any non-void proc.

