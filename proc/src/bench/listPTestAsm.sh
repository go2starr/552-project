#!/bin/bash

for i in `cat $1`; do
    FILE=`echo $i | sed -E "s/.*\/(.*)(\/.*\.list)/\\1/"`.summary.log
    echo Removing old log file: $FILE...
    rm -f $FILE

    echo # newline
    for j in `cat $i`; do
        echo Running tests for input file: $j...
        ./ptestAsm.sh $j | grep "\(SUCC\|FAIL\|PASS\)" 
#| tee -a $FILE
    done
done
