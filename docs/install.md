
# Installation

## Requirements

TSP can be used with C/Tcl and/or JTcl.

### JTcl

JTcl 2.8.0+ is required.  http://github.com/jtcl-project/jtcl/releases

JTcl includes the *parser* and *hyde* extensions, so no other extensions are required.

## C/Tcl

Tcl 8.6.3+ is required. 

Required Extensions: 

  - *parser*, verison 1.4.1  (included, see ../lib).  You must manually build and 
    install the parser extension.  Since parser only exists as a module of another
    project, it is included with TSP for convenience.

  - *critcl*, verison 3.1.15  https://github.com/andreas-kupries/critcl/releases


## Installing TSP

Simply unpack TSP into a directory normally included in your Tcl auto_path.  If you 
wish to try out TSP first, unpack in any directory, and add that directory to your
Tcl auto_path before requiring tsp:

```
  lappend auto_path /dir/where/you/unpacked/tsp
  package require tsp
```

Additionally, for JTcl usage, you must compile the runtime support classes.

```
   cd native
  ./compile.sh
```

When using C/Tcl, runtime C files are currently compiled on-the-fly.

