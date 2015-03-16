#!/bin/bash

# remove comments from tcl, java, or c

for file in $* ; do
    case "$file" in
	*.tcl)
	    cat "$file" | egrep -v '^[	 ]*#.*' 
	    ;;
	*.java)
	    cat "$file" | egrep -v '^[	 ]*//.*' | egrep -v '^[	 ]*/\*.*' 
	    ;;
	*.c)
	    cat "$file" | egrep -v '^[	 ]*//.*' | egrep -v '^[	 ]*/\*.*' 
	    ;;
    esac
done
