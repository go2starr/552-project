//Somayeh Sardashti
//April 9, 2009
//ECE/CS 552

These tests will check your 2-way set associative cache for different conditions and correct LRU replacement.

1) mem_2way1.addr: tests a Load Miss to way 0
        1. a Load Miss for address 348

2) mem_2way2.addr: tests a Load Miss to way 1
	1. a Load Miss for address 348
	2. a Load Miss for address 2396
	3. a Load Hit for 348

3) mem_2way3.addr: tests a Store Miss to way 0
	1. a Store Miss for address 348

4)  mem_2way4.addr: tests a Store Miss to way 1
	1. a Store Miss for address 348     
	2. a Store Miss for address 2396
	3. a Store Hit for address 348

5)  mem_2way5.addr: tests for Load Conflict Misses
	1. a Load Miss for address 348
	2. a Load Miss for address 2396
	3. a Load Miss for address 4444 with Eviction of 348

6)  mem_2way6.addr: tests for Store Conflict Misses         
        1. a Store Miss for address 348      
        2. a Store Miss for address 2396      
        3. a Store Miss for address 4444  with Dirty Eviction of 348

7) mem_2way7.addr: tests a 2-way set associative cache for LRU replacement
	1. a Store Miss for address 348
	2. a Load Hit for address 348 
	3. a Store Miss for address 2396
	4. a Load Hit for address 2396
	5. a Load Hit for address 384
	6. a Store Hit for address 348
	7. a Store Miss for address 4444 and Dirty Eviction of 2396
	8. a Load Miss for address 2396 and Dirty Eviction of 384
	9. a Load Hit for address 4444
	10. a Load Hit for address 4444
	11. a Store Hit for address 4444
	12. a Load Miss for address 384	and Eviction of 2396
	13. a Load Miss for address 2396 and Dirty Eviction of 4444
	14. a Load Miss for address 4444 and Eviction of 384
