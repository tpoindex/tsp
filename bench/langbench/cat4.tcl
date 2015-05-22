tsp::proc cat {file} {
	#tsp::procdef void -args var
	#tsp::boolean iseof
	#tsp::var f buf
	set f [open $file rb]
        set buf [gets $f]
        set iseof [eof $f]
	while {! $iseof} { puts $buf ; set buf [gets $f] ; set iseof [eof $f] }
	close $f
}

proc run_cat {} {
    global argv
    fconfigure stdout -buffering full -translation binary 
    foreach file $argv {
	    cat $file
    }
}
