
Mem System Template Readme:

example.addr is an example memory trace file

Trace Format and Example:
write 	read 	address		Data 
1 		0 		348 		24
0 		1 		348 		0

loadfile* are files to initialize your memory with

clkrst.v is a modified clkrst which will simulate 1 million cycles before termination

Other verilog Files are described in hw5 / four banked memory module / cache module

test-traces folder contains the the required memory traces

cache_mem_modules folder contains all provided cache and four-banked memory files
You may copy these files up a directory. : )