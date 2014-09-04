#!
echo '
 foreach path [split $::env(CLASSPATH) $::env(path.separator)] {
   if {[string match *jtcl-*jar [file tail $path]]} {puts $path; break}
 }
' | jtclni
