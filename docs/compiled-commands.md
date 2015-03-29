Compiled commands and limitations

  - Fall back to command/interp invocation

Here is the current list of TSP compiled commands.  Note that some commands
may include restrictions on what can be compiled.  For any command that
isn't currently compiled, or for any command usage that violates the
compiler restrictions, the Tcl builtin command is invoked.

Some commands are "lightly compiled", For these command, arguments are scanned
for variable name usage to ensure that the variables are spilled and loaded.

  - Compiled commands

    * Assignment command

      - set

    * Control commands

      - if
      - for
      - foreach
      - while
      - break
      - continue
      - catch
      - switch
      - return

    * Variable commands

      - global
      - upvar
      - variable
      - unset

    * List commands

      - lset 
      - lappend
      - llength
      - list
      - lindex

    * String commands

       - append
       - scan 
       - binary scan
       - string index
       - string length
       - string range

    * Arithmatic commands

       - expr
       - incr
  

  - Limitations

    * if - expression subject to expr limitations
    * for - expression subject to expr limitations
    * foreach - only a single list of iteration variables, and a single iterable value
    * while - expression subject to expr limitations
    * switch - no optional arguments, patterns and scripts must be a single list argument
    * lindex - indexes may only be an integer, 'end', 'end-integervar' or 'end-integerconst'
    * string range - indexes may only be an integer, 'end', 'end-integervar' or 'end-integerconst'
    * expr - no embedded commands or array references, no 'tsp::var' variables
