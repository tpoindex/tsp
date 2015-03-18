tsp::proc grep {file} {
	#tsp::procdef void -args var
	#tsp::string f buf
	#tsp::int len
	#tsp::boolean matched
	set f [open $file r]
	set buf ""
	set len [gets $f buf]
	while {$len >= 0} {
		set matched [regexp -- {[^A-Za-z]fopen\(.*\)} $buf]
		if {$matched} { puts $buf }
		set len [gets $f buf]
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
