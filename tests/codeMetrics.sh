#!/bin/bash

# count lines, words, characters of tcl, java, or c code 
# after removing - 
#  1. blank lines of tabs or spaces
#  2. comment lines, w/ or w/o leading tabs or spaces
#  3. leading tabs and spaces
#  4. leading tabs and spaces
#  5. trailing tabs and spaces

wc=wc
# check for -c argument, just cat the bare file instead
if [ "$1" = "-c" ] ; then
    wc=cat
    shift
fi

maxlen=20
for file in $* ; do
    if [ ! -f $file ] ; then
        echo "can't find file: $file"
        exit
    fi
    fnamelen=`echo "$file" | wc -c`
    if [ $fnamelen -gt $maxlen ] ; then
        maxlen=$fnamelen
    fi
done

for file in $* ; do
    echo "$file" | awk -v maxlen=$maxlen '{printf "%-*.*s ",maxlen,maxlen,$0}'
    case "$file" in
	*.tcl)
	    cat "$file" | egrep -v '^[ 	]*$' | egrep -v '^[	 ]*#.*' | sed -e 's/[	 ]*//' -e 's/[	 ]*$//' | $wc
	    ;;
	*.java)
	    cat "$file" | egrep -v '^[ 	]*$' | egrep -v '^[	 ]*//.*' | egrep -v '^[	 ]*/\*.*' | sed -e 's/[	 ]*//' -e 's/[   ]*$//'  | $wc
	    ;;
	*.c)
	    cat "$file" | egrep -v '^[ 	]*$' | egrep -v '^[	 ]*//.*' | egrep -v '^[	 ]*/\*.*' | sed -e 's/[	 ]*//' -e 's/[   ]*$//'  | $wc
	    ;;
    esac
done
