#!/bin/bash

for i in `find .. | grep ".*bench.v$" | grep -o "t_.*bench"`; do
    vtest $i | tee -a test.out;
done;
