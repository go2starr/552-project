#!/bin/bash

for i in `cat all.list`; do ./testAsm.sh $i | grep "\(SUCCESS\|FAIL\)"; done;
