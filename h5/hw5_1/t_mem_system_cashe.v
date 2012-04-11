`include "testbench.v"

module t_mem_system_cashe();
     //Inputs
     reg [15:0] addr, data_in;
     reg        rd, wr, createdump, clk, rst;

     // Outputs
     wire [15:0] data_out;
     wire        done, stall, cache_hit, err;
     
     //Band aid fix
     integer no_errs;

     /* Mem FSM states */
     parameter ERR = 0;
     parameter IDLE = 1;
     parameter COMPRD = 2;
     parameter MEMRD = 3;
     parameter WAITSTATE = 4;
     parameter INSTALL_CACHE = 5;
     parameter DONE = 6;
     parameter COMPWR = 7;
     parameter WRMISSDONE = 8;
     parameter PREWBMEM = 9;
     parameter WBMEM = 10;

     
         // DUT
         mem_system DUT (.DataOut(data_out),
                         .Done(done),
                         .Stall(stall),
                         .CacheHit(cache_hit),
                         .err(err),                                                                                                .Addr(addr),                                                                                              .DataIn(data_in),                                                                                         .Rd(rd),                          
			 .Wr(wr),
                         .createdump(createdump),                                                                                  .clk(clk),                                                                                                .rst(rst)                                                                                                  );
     
     
     initial clk = 0;
     always begin
	  #50 clk = ~clk;
     end

     initial begin
        `info("Tests starting...");


	//Initialize
	addr = 0;
	data_in = 0;
	rd = 0;
	wr = 0;
	createdump = 0;
	rst = 0;

        /*****************************
	 * Reset
	 * ***************************/

	rst = 1;
	`tic;
	rst = 0;
	`tic
        
	/*******************************
	 *  First Test- Write to Address
	 *  ****************************/

	addr = 16'h1010;
	force DUT.DataIn = 16'h1111;
	#1
	rd = 0;
	wr = 1;
	`tic;  
	`test(COMPWR, DUT.state, "Should be in COMPWR");
	`tic;  
	`test(MEMRD, DUT.state, "Should be in MEMRD");
	`tic;  
	`test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
	`tic;  
        `test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	`test(0, DUT.count, "Count on first word");
	$display("Index: %h, Tag: %h, Offset: %d", DUT.cache_index, DUT.cache_tag_in,
		 DUT.cache_offset);
	$display("Cache_valid_in: %b", DUT.cache_valid_in);
	$display("Cache_write: %b", DUT.cache_write);
	$display("Cache_comp: %b", DUT.cache_comp);
	$display("Cache_enable: %b", DUT.cache_enable);
	
	
	`test(1, DUT.cache_write, "Should be writing on first word in INSTALL_CACHE");
	`tic; 
	`test(MEMRD, DUT.state, "Should be in MEMRD");
	`tic; 
	`test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
        `tic; 
	`test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	$display("Index: %h, Tag: %h, Offset: %d", DUT.cache_index, DUT.cache_tag_in,
		 DUT.cache_offset);	
	`tic;  
        `test(MEMRD, DUT.state, "Should be in MEMRD");
	`tic;  
	`test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
	`tic;  
	`test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	$display("Index: %h, Tag: %h, Offset: %d", DUT.cache_index, DUT.cache_tag_in,
		 DUT.cache_offset);	
	`tic;  
        `test(MEMRD, DUT.state, "Should be in MEMRD");
	`tic;  
	`test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
	`tic;  
	`test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	$display("Index: %h, Tag: %h, Offset: %d", DUT.cache_index, DUT.cache_tag_in,
		 DUT.cache_offset);	
	`tic
	`test(WRMISSDONE, DUT.state, "Should be Done");
        `tic
	`test(IDLE, DUT.state, "Should be in IDLE");
	`test(16'h1111, DUT.cache_data_in, "Data into cache should be data into memory");
        `tic
	`test(COMPWR, DUT.state, "Should be in COMPWR");
	`test(1, DUT.cache_hit, "Should be a hit after filling cache with valid block");
	`tic
	`test(DONE, DUT.state, "Should be in DONE");
	`tic
	`test(IDLE, DUT.state, "Should be in IDLE");
	#1
      
        /****************************
	 *  Now Read Address
	 *  *************************/

	rd = 1;
	wr = 0;
	#1;
	
	$display("Index: %h, Tag: %h, Offset: %d", DUT.cache_index, DUT.cache_tag_in,
		 DUT.cache_offset);
	$display("cache_enable: %b, comp: %b", DUT.cache_enable, DUT.cache_comp);
 
	`tic; //Should be in COMPRD
	`test(COMPRD, DUT.state, "Should be in COMPR");
	`test(1, DUT.c0.hit, "Should be a hit");

	`tic; //Should be in DONE

	`test(DONE, DUT.state, "Should be Done");
        `test(16'h1111, DUT.DataOut, "Should be 16'h1111");
	`tic
	`test(IDLE, DUT.state, "Should be IDLE");
	 rd = 0;
	 wr = 0;
	`tic;
	`tic;
	`test(IDLE, DUT.state, "Should be remaining in IDLE");


        /***********************
	 * READ new address
	 **********************/
	 `test(IDLE, DUT.state, "Should be IDLE");

          addr = 16'h1110;
	
	  rd = 1;
	  wr = 0;
	  `tic;
	  `test(COMPRD, DUT.state, "Should be in COMPRD");
	  `tic;
	  `test(MEMRD, DUT.state, "Should be in MEMRD");
	  `tic;
          `test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
	  `tic;
          `test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	  `tic;
	  `test(MEMRD, DUT.state, "Should be in MEMRD");
	  `tic;
	  `test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
	  `tic;
	  `test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	  `tic;
	  `test(MEMRD, DUT.state, "Should be in MEMRD");
	  `tic;
	  `test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
	  `tic;
	  `test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	  `tic;
	  `test(MEMRD, DUT.state, "Should be in MEMRD");
	  `tic;
	  `test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
	  `tic;
	  `test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	  `tic;
	  `test(DONE, DUT.state, "Should be in DONE");
	  `tic;
	  `test(IDLE, DUT.state, "Should be in IDLE");


		  

	$stop;

     end

endmodule







