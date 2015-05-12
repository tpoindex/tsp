tsp::proc wordsplit {str} {
	#tsp::procdef var -args var
	#tsp::var list char word splitstr
	#tsp::boolean is_space
	#tsp::int len
	set list {}
	set word {}
	set splitstr [split $str {}]
	foreach char $splitstr {
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
	#tsp::int n len i
	set f [open $file r]
	fconfigure $f -translation binary
	set buf ""
	set n 0
	set len [gets $f buf]
	while {$len >= 0} {
		set words [wordsplit $buf]
		set i [llength $words]
		incr n $i
		set len [gets $f buf]
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
