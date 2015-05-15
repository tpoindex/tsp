tsp::proc hash {} {
	#tsp::procdef void
	#tsp::array d
	#tsp::var argv file f buf one
	#tsp::int len
	global	argv
	
        set one 1
	array set d {}
	foreach file $argv {
		set f [open $file rb]
		set len [gets $f buf]
		while {$len >= 0} {
			set d($buf) $one
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
