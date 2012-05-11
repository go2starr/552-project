#!/bin/bash

wsrun_mumble.pl -addr $1 mem_system_perfbench `find $PROC_DIR/proc | grep ".*\.v$"`
