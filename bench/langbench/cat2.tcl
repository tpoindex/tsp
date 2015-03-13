source ../../tsp.tcl
tsp::proc cat {file} {
	#tsp::procdef void -args string
	#tsp::int len cnt
	#tsp::string f buf
	set f [open $file r]
        set len [gets $f buf]
        set cnt 0
	while {$len >= 0} { puts $buf ; set len [gets $f buf] ; incr cnt}
	close $f
        puts stderr $cnt
}

tsp::printLog

proc run_cat {} {
    global argv
    fconfigure stdout -buffering full -translation binary 
    foreach file $argv {
puts stderr $file
	    cat $file
    }
}

run_cat
