
# Tcl Language Subset

## Limited subset of Tcl, upwardly compatible with standard Tcl

TSP requires that compiled procs use a limited subset of the Tcl language rules.
This subset is entirely upwardly compatible with standard Tcl (other than the 
semantics of variable type conversion discussed earlier.)  

For limitations for compiling specific commands, see compiled-commands.md.

# Summary of limitations

## Expressions use only native types, not all expr operators/functions implemented

The **expr** command and logical expressions used in **for** and **while** only 
operate on native types (boolean, int, double, string.)
If a *var* or *array* type in encounterd during expression parsing, the compilation will
fail.  

String variables should only be used in logical comparison **eq** and **ne**, or with logical
operators ** == != < <= > >= ** .  When using string types, both sides of the operator must be
strings.  

Standard Tcl operators and functions are supported: **cos(), sin(), rand(),** etc., with 
the exception that **in** and **ni** operators are not supported.

Expression must be enclosed by braces, quoted or bare expressions cannot be compiled.

```


    # illegal expressions
    set n [ expr "$a $s $c" ]        ;# invalid: expression not enclosed by braces

    #tsp::var v
    if {$v + $x($c)} {               ;# invalid: var type and array references not allowed
    }

    while {[string length $s]} {     ;# invalid: nested command not allowed
    }
```

## Expansion syntax not suported {*}

The Tcl 8.5+ list expansion syntax **{*}** is not supported, since this introduces
a level of additional runtime interpretation.

```
    lappend foo {*}$s                ;# invalid: expansion syntax not allows
```

## Namespace not supported for proc names

Currently, procedures can only be defined in the global namespace.

```
    tsp::proc ::pkg::foo {} {        ;# invalid: namespace procname not allowed
        #tsp::procdef void
    }
```

## Limitation on proc name and variable names

Procedure names and variable names inside of procedures must follow strict naming conventions.
Valid identifiers consist of a upper or lower case character A-Z or an underscore, and the following
characters can only contain those characters, plus digits 0-9.  Procedure and variable names
are compiled into native code without using a translation table, so names must be valid in the 
target language.

```
    tsp::proc foo.bar {} {           ;# invalid: characters other than _ in proc name
        #tsp::procdef void
        set {bing baz} "hello"       ;# invalid: whitespace in variable name
    }
```

## Procedure default arguments and **args** not supported

Procedure arguments may not contain default values, and the use of **args** as the last procedure 
argument is not supported.

```
    tsp::proc foo {a {b 0} args} {   ;# invalid: default argument value and 'args' argument not allowed
        #tsp::procdef void
    }
```

## String and list indices

String and list commands that use indices (e.g., **string range**, **lindex**) may only specify
indices as a literal integer constant, a integer variable,  a variable that can be converted
to an integer, or the literal **end-** with an integer constant or variable.  

```
    set idx "end-$i"
    puts [string index $str $idx]    ;# invalid: "end-n" specifier only allowed as literal

    puts [string index $str end-$i]  ;# OK
```

## Return must be used for all code paths

An explicit return statement must be encountered in all code paths, returning
a constant or variable of the defined proc return type (or a value or variable that can
be converted to the return type.)  The only exception is for procs defined as
**void**, in which the end of proc can be encountered without an explicit return.

```
    tsp::proc foo {} {
        #tsp::procdef int
        set n 1                      ;# invalid: return must be coded
    }
```

## Code bodies for if, while, for, foreach, switch, catch must be enclosed by braces 

Code enclosed by double quotes, or bare code is not compilable, as this implies
possible substitution by the Tcl interpreter.

```
    if {$i > 0} "puts hello_$world"  ;# invalid: runtime interpolation of body

    if {$i > 0} {puts hello_$world}  ;# OK
```


