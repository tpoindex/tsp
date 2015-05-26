tsp::proc wordsplit {str} {
	#tsp::procdef var -args string
	#tsp::var list char
	#tsp::string word
	#tsp::boolean is_space
	#tsp::int strlen len i
	set list {}
	set word {}
        set strlen [string length $str]
	for {set i 0} {$i < $strlen} {incr i} {
                set char [string index $str $i]
		set is_space [string is space $char]
		if {$is_space} {
			set len [string length $word]
			if {$len > 0} {
				lappend list $word
			}
			set word {}
		} else {
			append word $char
		}
	}
	set len [string length $word]
	if {$len > 0} {
		lappend list $word
	}
	return $list
}

tsp::proc doit {file} {
	#tsp::procdef int -args var
	#tsp::var f buf words
	#tsp::int n i
	#tsp::boolean iseof
	set f [open $file r]
	fconfigure $f -translation binary
	set buf ""
	set n 0
	set buf [gets $f]
	set iseof [eof $f]
	while {! $iseof} {
		set words [wordsplit $buf]
		set i [llength $words]
		incr n $i
		set buf [gets $f]
		set iseof [eof $f]
	}
	close $f
	return $n
}

proc run_wc {} {
    global argv
    set total 0
    foreach file $argv {
	    incr total [doit $file]
    }
    puts $total
}
