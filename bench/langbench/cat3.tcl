tsp::proc cat {file} {
	#tsp::procdef void -args var
	#tsp::int len
	#tsp::var f buf
	set f [open $file rb]
        fconfigure $f -buffersize 1000000 -buffering full 
        set buf [read $f 1000000]
	set len [string length $buf]
	while {$len != 0} { puts -nonewline $buf ; set buf [read $f 1000000] ; set len [string length $buf] }
	close $f
}

proc run_cat {} {
    global argv
    fconfigure stdout -buffering full -buffersize 1000000
    foreach file $argv {
	    cat $file
    }
}
