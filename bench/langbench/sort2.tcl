tsp::proc main {} {
	#tsp::procdef void
	#tsp::var l sorted
	#tsp::var f buf file
	#tsp::boolean iseof
	global	argv

	foreach file $argv {
		set f [open $file rb]

		
		set buf [gets $f]
		set iseof [eof $f]
		while {! $iseof} {
			lappend l $buf
			set buf [gets $f]
			set iseof [eof $f]
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
