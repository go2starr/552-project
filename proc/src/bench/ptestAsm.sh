#!/bin/bash

#
#  Compare the output from the proc_hier module and the wiscalculator simulator
#

# Check args
if test $# -ne 1
then
    echo Usage: ptestAsm.sh FILENAME.asm
    exit 0
fi

wsrun_mumble.pl -pipe -prog $1  proc_hier_pbench `find ../../ | grep ".*\.v$"
