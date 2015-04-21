#!/bin/bash

grep ::tsp::lang *|egrep -v '^proc'| sed -e 's/^\(.*\)\(::tsp::lang\)/\2/' | sed -e 's/\([^ ]*\)\( .*\)/\1/' | sed -e 's/\(^[a-zA-Z:{}_$*]*\)\(.*\)/\1/' | sort -u


