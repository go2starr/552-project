#!/bin/bash

#
#  Compare the output from the proc_hier module and the wiscalculator simulator
#

# Run processor simulation
wsrun.pl -prog proc.asm proc_hier_bench `find ../../ | grep ".*\.v$"`

# Run emulator
wiscalculator_mumble loadfile_all.img > wiscalculator.out
cat wiscalculator.out | grep INUM > wiscalculator.inum.out

# Diff output
diff verilogsim.trace wiscalculator.inum.out
