tsp::proc main {} {
	#tsp::procdef void
	#tsp::var l sorted
	#tsp::var f buf file
	#tsp::int len
	global	argv

	foreach file $argv {
		set f [open $file rb]

		
		set len [gets $f buf]
		while {$len >= 0} {
			lappend l $buf
			set len [gets $f buf]
		}
		close $f
	}

	
        set sorted [lsort $l]
	foreach buf $sorted {
		puts $buf
	}
}

proc run_sort {} {
    fconfigure stdout -buffering full -translation binary
    main
}
