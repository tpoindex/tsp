tsp::proc main {} {
	#tsp::procdef void
	#tsp::var l sorted
	#tsp::string f buf file
	#tsp::int len
	global	argv

	foreach file $argv {
		set f [open $file r]

		# Takes 2.7 seconds/12.3
		set len [gets $f buf]
		while {$len >= 0} {
			lappend l $buf
			set len [gets $f buf]
		}
		close $f
	}

	# takes 7.9 seconds/12.3
        set sorted [lsort $l]
	foreach buf $sorted {
		puts $buf
	}
}

proc run_sort {} {
    fconfigure stdout -buffering full -translation binary
    main
}
