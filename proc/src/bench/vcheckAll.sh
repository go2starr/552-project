#!/bin/bash

mkdir -p vcheck

for i in `find ../../src/ -iname "*.v" ! -iname "*bench.v" ! -iname "t_*"`; do 
    FILENAME=`echo $i | sed -E "s/.*\/(.*)/\\1/"`check.out
    echo $FILENAME
    
    rm -f vcheck/$FILENAME
    vcheck $i > vcheck/$FILENAME; 
done;
