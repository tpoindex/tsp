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

tsp::proc doit {lines} {
	#tsp::procdef int -args var
	#tsp::var buf words
	#tsp::int n i
	set buf ""
	set n 0
	foreach buf $lines {
		set words [wordsplit $buf]
		set i [llength $words]
		incr n $i
	}
	return $n
}

proc run_wc-x {} {
    global lines
    set total 0
    incr total [doit $lines]
    puts $total
}

proc init_wc-x {} {
    global lines argv
    set file [lindex $argv end]
    set fd [open $file rb]
    set size [file size $file]
    set buff [read $fd $size]
    set lines [split $buff \n]
    close $fd
}

