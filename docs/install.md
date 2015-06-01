
# Installation

## Requirements

### JTcl

JTcl 2.8.0+ is required.  http://github.com/jtcl-project/jtcl/releases

JTcl includes the *parser* and *hyde* extensions, so no other extensions are required.
TSP will likely be included in future versions of JTcl.

## C/Tcl

Tcl 8.6.3+ is required. 

Required Extensions: 

  - *parser*, verison 1.4.1  (included, see ../lib).  You must manually build and 
    install the parser extension.  Since parser only exists as a module of another
    project, it is included with TSP for convenience.

  - *critcl*, verison 3.1.15  https://github.com/andreas-kupries/critcl/releases


## Installing TSP

Simply unpack TSP into a directory normally included in your Tcl auto_path.

