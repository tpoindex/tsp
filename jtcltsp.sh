#!
/bin/rm -rf ./hyde/
#dir=`dirname $0`
#dir=`readlink -f $dir`
export TCLLIBPATH=$dir
#export CLASSPATH=$dir/native/java
jtcl $*
