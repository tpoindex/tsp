tsp::proc grep {file} {
	#tsp::procdef void -args var
	#tsp::var f buf
	#tsp::boolean matched iseof
	set f [open $file rb]
	set buf [gets $f]
	set iseof [eof $f]
	while {! $iseof} {
		set matched [regexp -- {[^A-Za-z]fopen\(.*\)} $buf]
		if {$matched} { puts $buf }
		set buf [gets $f]
		set iseof [eof $f]
	}
	close $f
}

proc run_grep {} {
    global argv
    fconfigure stdout -translation binary 
    foreach file $argv {
	    grep $file
    }
}
