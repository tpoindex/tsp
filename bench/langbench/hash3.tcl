tsp::proc hash {} {
	#tsp::procdef void
	#tsp::array d
	#tsp::var argv file f buf
	#tsp::boolean iseof
	global	argv
	
	array set d {}
	foreach file $argv {
		set f [open $file rb]
		set buf [gets $f]
		set iseof [eof $f]
		while {! $iseof} {
			set d($buf) 1
			set buf [gets $f]
			set iseof [eof $f]
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
