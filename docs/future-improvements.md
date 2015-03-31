# Todo - Future improvements for the TSP compiler.

In no particular order:

## Additonal compiled builtin commands - especially `string`, `scan`, others

Compile more of the `string` subcommands.  Compile `scan` for simple cases
of user coded conversions from string/var to int or double.

## Allow `tsp::var` and `tsp::array` varialbles in expressions

We can accomodate var and array types in expression by converting to a temporary
typed variable before the parsing the expression.  Convert to int or double
as var permits.  Raise Tcl error on bad conversion.

## Allow proc to live in a namespace, possibly with limitations

This effects proc definition and `variable` commands.
