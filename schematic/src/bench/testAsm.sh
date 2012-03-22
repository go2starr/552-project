#!/bin/bash

#
#  Compare the output from the proc_hier module and the wiscalculator simulator
#

# Check args
if test $# -ne 1
then
    echo Usage: testAsm.sh FILENAME.asm
    exit 0
fi


# Run processor simulation
wsrun.pl -prog $1 proc_hier_bench `find ../../ | grep ".*\.v$"`

# Run emulator
wiscalculator_mumble loadfile_all.img > wiscalculator.out
cat wiscalculator.out | grep INUM > wiscalculator.inum.out

# Diff output
echo
echo
echo
echo ================== DIFF ======================
diff verilogsim.trace wiscalculator.inum.out
