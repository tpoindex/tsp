Required libraries for TSP
==========================

The following packages are required for use with C/Tcl.

JTcl does not require any external packages, as the required
packages 'hyde' and 'parser' are included in the JTcl distribution.

critcl-3.1.13-patched 
    This is a patched version of Critcl that adds "::critcl::reset", which
    allows multiple compilations.  When the reset patch is merged into
    the main Critcl distribution, this will be replaced by the official
    version.  

    NOTE: if you already have Critcl installed as a package, you must 
    uninstall any previous version and install this patched verison.

    Original source:  https://github.com/andreas-kupries/critcl
    License: BSD, see critcl-3.1.13-patched/license.terms


tclparser-1.4.1
    Tclparser provides the 'parser' package.  This package is extracted from
    the TclPro open source project.

    Original source:  http://tclpro.cvs.sourceforge.net/viewvc/tclpro/tclparser/ 
    License:  BSD, see tclparser-1.4.1/license.terms
