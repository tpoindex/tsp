tsp::proc cat {file} {
	#tsp::procdef void -args var
	#tsp::int len
	#tsp::string f buf
	set f [open $file r]
        set len [gets $f buf]
	while {$len >= 0} { puts $buf ; set len [gets $f buf] }
	close $f
}

proc run_cat {} {
    global argv
    fconfigure stdout -buffering full -translation binary 
    foreach file $argv {
	    cat $file
    }
}
