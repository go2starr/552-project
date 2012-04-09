//Somayeh Sardashti
//April 9, 2009
//ECE/CS 552

These simple tests check your direct-map design for all possible conditions and corner cases.

1) mem1.addr: tests for a load miss
	1. a Load Miss for address 348
2) mem2.addr: tests for a load hit
	1. a Load Miss for address 348
	2. a Load Hit for address 348 
3) mem3.addr: tests for a store hit
	1. a Load Miss for address 348
	2. a Store Hit for address 348 
4) mem4.addr: tests for a store miss (cold miss)
	1. a Store Miss for address 348 
5) mem5.addr: tests for a load miss + Eviction
	1. a Load Miss for address 348
	2. a Load Miss for address 2396 + Eviction of 348
6) mem6.addr: tests for a load miss + Dirty eviction
	1. a Store Miss for address 348
	2. a Load Miss for address 2396 + Dirty Eviction of 348
7) mem7.addr: tests for a store miss + Eviction
	1. a Load Miss for address 348
	2. a Store Miss for address 2396 + Eviction of 348
8) mem8.addr: tests for a store miss + Dirty eviction
	1. a Store Miss for address 348
	2. a Store Miss for address 2396 + Dirty Eviction of 348

