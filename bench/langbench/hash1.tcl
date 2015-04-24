tsp::proc hash {} {
	#tsp::procdef void
	#tsp::var argv d file f buf
	#tsp::int len
	global	argv

	set d [dict create]
	foreach file $argv {
		set f [open $file r]
		set len [gets $f buf]
		while {$len >= 0} {
			dict set d $buf 1
			set len [gets $f buf]
		}
		close $f
	}
}

proc run_hash {} {
    hash
    set f [open "/proc/[pid]/status"]
    while {[gets $f buf] >= 0} {
    	if {[regexp {^Vm[RD]} $buf]} { puts $buf }
    }
}
