#!/bin/bash

for i in `cat $1`; do ./ptestAsm.sh $i | grep "\(SUCC\|FAIL\|PASS\)"; done;
