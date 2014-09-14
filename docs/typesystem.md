
Type system

  - Native types

Tcl uses pragmas to annotate proc arguments and variables for type definitions.
TSP compiled types are:


    * boolean (Java boolean or C int)
    * int (Java long or C long long)
    * double (double in both Java and C)
    * string (Java String or C TclDString)
    * var - (JTcl TclObject or Tcl/C TclObj)

  - Arrays - uses interpreter variables

Array variables are not defined in compiled code.  Instead, they are defined and
accessed in the Tcl interpreter.  Array elements of course are TclObjects, and can
hold any specific TclObject data type.

  - Conversions and conversion errors

TSP will perform automatic conversions as necessary, the same as the Tcl interpreter. 
The major difference is when the conversion happens.  In ordinary Tcl, conversion
takes place when a particular command expects a Tcl variable to be of a certain
type (e.g. late binding.)   For example, the "llength" command expects it's argument to be a TclList, if
it isn't, then the llength command tries to convert the TclObject to a TclList.

For TSP compiled procs, that conversion is done when the variable is assigned, thus
potentially generating a conversion error much earlier.  This includes even the invocation
of a Tcl procedure by a compiled or non-compiled code when a procedure argument can
not be converted.  

Conversions:
  
       from: 	integer		double		boolean		string		var

   to: integer 	  -    		int()		true->1		is int?		is int?
						false->0

       double	double()	   -		true->1.0	is double?	is double?
						false->0.0

       boolean  0->false	0->false	   -		is boolean?	is boolean?
                else->true	else->true

       string	   -		   -		   -		   -		   -

       var   	   -		   -		   -		   -		   -


	The notation "is type?" uses type appropriate Tcl functions to perform conversions.
 	In the case of string or var to boolean, any of the Tcl recognized values for true/false
	can be used, true: any int or double not zero, "true", "yes"  false: 0, 0.0, "false", "no"




  - Implicit declarations

TSP will automatically assign variable types based on their usage, if not previously defined.
For instance, if a previously undefined variable is assigned from the results of a "llength",
it will be defined as an integer type.  


  - Variables defined on proc entry

TSP compiled procs define variables statically on procedure invocation, unlike Tcl where the 
variable is defined the first time it is assigned.  This could potentially cause subtle 
differences where the Tcl code may depend on whether the variable is defined in the Tcl
interpreter.  Note that the "info" command itself may not function as expected for TSP 
compiled procs anyway, as variables are automatically exported to the Tcl interpreter.


