
set scalarVarTypes  [list bb  boolean ii  int dd  double ss  string vv  var]
set scalarVarTypes2 [list bb2 boolean ii2 int dd2 double ss2 string vv2 var]

#################################################################################################################333
#################################################################################################################333
puts {
package require tcltest

set dir ..
source ../tsp.tcl

source tsp-lang.test

# parse a command string, return a compUnit dict
proc __parse {body} {
    return [parse command $body {0 end}]
}

proc __initCompUnit {body args} {
    set compUnit [::tsp::init_compunit filename name procargs $body]
    foreach {var type} $args {
        ::tsp::setVarType compUnit $var $type
    }
    return $compUnit
}

proc __compress {s} {
    regsub -all  {[[:space:]][[:space:]]+} $s " " s
    return $s 
}

}



#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign scalar from interpolated string

}

set i 0
set patt {::tcltest::test generate-set-interpolated-$type1-$type2-$i] {generate set interp string target $type1 source $type2} -setup {
} -body { 
    set body {set $var1 "hello \\n \$$var2"}
    set compUnit [__initCompUnit \$body $var1 $type1 $var2 $type2] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree]
    expr {[lindex \$result 2] ne ""} 
} -result {1}


}

foreach {var1 type1} {s string v var} {
    foreach {var2 type2} $scalarVarTypes {
        incr i
        puts [subst -nocommands $patt]
    }
}


#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign array idxtext from interpolated string

}

set i 0
set patt {::tcltest::test generate-set-interpolated-array-idxtext-$type-$i] {generate set interp string array idxtext source $type} -setup {
} -body { 
    set body {set xx(yy) "hello \\n \$$var2"}
    set compUnit [__initCompUnit \$body $var $type] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree ]
    expr {[lindex \$result 2] ne ""}
} -result {1}


}

foreach {var type} $scalarVarTypes {
    incr i
    puts [subst -nocommands $patt]
}



#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign array idxvar from interpolated string

}

set i 0
set patt {::tcltest::test generate-set-interpolated-array-idxvar-$type1-$type2-$i] {generate set interp string array idxvar target idxtype $type1 source $type2} -setup {
} -body { 
    set body {set xx(\$$var1) "hello \\n \$$var2"}
    set compUnit [__initCompUnit \$body $var1 $type1 $var2 $type2] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree ]
    expr {[lindex \$result 2] ne ""}
} -result {1}


}

foreach {var1 type1} $scalarVarTypes {
    foreach {var2 type2} $scalarVarTypes2 {
        incr i
        puts [subst -nocommands $patt]
    }
}





#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign string from backslash

}

set i 0
set patt {::tcltest::test generate-set-scalar-backslash-$type-$i] {generate set scalar backslash $type} -setup {
} -body { 
    set body {set $var \\n}
    set compUnit [__initCompUnit \$body $var $type] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree ]
    expr {[lindex \$result 2] ne ""}
} -result {1}


}

foreach {var type} {ss string vv var} {
    incr i
    puts [subst -nocommands $patt]
}





#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign array idxtext from backslash

}

set i 0
set patt {::tcltest::test generate-set-array-idxtext-backslash-$type-$i] {generate set array idxtest backslash $type} -setup {
} -body { 
    set body {set xx(xx) \\n}
    set compUnit [__initCompUnit \$body ] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree ]
    expr {[lindex \$result 2] ne ""}
} -result {1}


}

incr i
puts [subst -nocommands $patt]



#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign array idxvar from backslash

}

set i 0
set patt {::tcltest::test generate-set-array-idxtext-backslash-$type-$i] {generate set array idxtest backslash $type} -setup {
} -body { 
    set body {set xx(\$ss) \\n}
    set compUnit [__initCompUnit \$body ss string] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree ]
    expr {[lindex \$result 2] ne ""}
} -result {1}


}

incr i
puts [subst -nocommands $patt]







#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign scalar from implicitly typed text

}

set i 0
set patt {::tcltest::test generate-set-implicitly-typed-target-$i] {generate set implicitly typed target $text} -setup {
} -body { 
    set body {set xx $text}
    set compUnit [__initCompUnit \$body ] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree ]
    expr {[lindex \$result 2] ne ""}
} -result {1}


}

foreach {text} {string 1 3.14 {"string"} {"1.0"} {"3.14"}} {
    incr i
    puts [subst -nocommands $patt]
}





#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign scalar from scalar

}

set i 0
set patt {::tcltest::test generate-set-scalar-scalar-$type1-$type2-$i] {generate set scalar $type1 $type2} -setup {
} -body { 
    set body {set $var1 \$$var2}
    set compUnit [__initCompUnit \$body $var1 $type1 $var2 $type2] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree ]
    expr {[lindex \$result 2] ne ""}
} -result {1}


}

foreach {var1 type1} $scalarVarTypes {
    foreach {var2 type2} $scalarVarTypes2 {
        incr i
        puts [subst -nocommands $patt]
    }
}





#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign scalar from scalar avoid self assignment

}

set i 0
set patt {::tcltest::test generate-set-scalar-self-$type-$i] {generate set scalar self assignment $type} -setup {
} -body { 
    set body {set $var \$$var}
    set compUnit [__initCompUnit \$body $var $type] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree ]
    expr {[lindex \$result 2] ne ""}
} -result {0}


}

foreach {var type} $scalarVarTypes {
    incr i
    puts [subst -nocommands $patt]
}





#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign array idxtext from scalar

}

set i 0
set patt {::tcltest::test generate-set-array-idxtext-scalar-$type-$i] {generate set array idxtext scalar $type} -setup {
} -body { 
    set body {set xx(xx) \$$var}
    set compUnit [__initCompUnit \$body $var $type] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree ]
    expr {[lindex \$result 2] ne ""}
} -result {1}


}

foreach {var type} $scalarVarTypes {
    incr i
    puts [subst -nocommands $patt]
}





#################################################################################################################333
#################################################################################################################333
puts {
############################################################
# assign array idxvar from scalar

}

set i 0
set patt {::tcltest::test generate-set-array-idxvar-scalar-$type1-$type2-$i] {generate set array idxvar scalar $type1 $type2} -setup {
} -body { 
    set body {set xx(\$$var1) \$$var2}
    set compUnit [__initCompUnit \$body $var1 $type1 $var2 $type2] 
    lassign [parse command \$body {0 end}] x x x tree 
    set result [::tsp::gen_command_set compUnit \$tree ]
    expr {[lindex \$result 2] ne ""}
} -result {1}


}

foreach {var1 type1} $scalarVarTypes {
    foreach {var2 type2} $scalarVarTypes2 {
        incr i
        puts [subst -nocommands $patt]
    }
}

