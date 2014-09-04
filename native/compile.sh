#!
jtcljar=`./get_jtcl_jar.sh`
cd java
javac  -Xlint:deprecation -cp "$jtcljar" tsp/util/*.java
