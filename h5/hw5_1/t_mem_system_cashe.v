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
        force DUT.mem_data_out = 16'h dead;
	#1
	rd = 0;
	wr = 1;
	`tic;  
	`test(COMPWR, DUT.state, "Should be in COMPWR");
	`tic;  
	`test(MEMRD, DUT.state, "Should be in MEMRD");
        `test(16'h1010, DUT.mem_addr, "Should be the right address on first mem access");
	`tic;  
	`test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
	`tic;  
        `test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	`test(0, DUT.count, "Count on first word");
	`test(1, DUT.cache_write, "Should be writing on first word in INSTALL_CACHE");
	`tic; 
	`test(MEMRD, DUT.state, "Should be in MEMRD");
        `test(16'h1012, DUT.mem_addr, "Should be the right address on second mem access");        
	`tic; 
	`test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
        `tic; 
	`test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	`tic;  
        `test(MEMRD, DUT.state, "Should be in MEMRD");
        `test(16'h1014, DUT.mem_addr, "Should be the right address on third mem access");                
	`tic;  
	`test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
	`tic;  
	`test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	`tic;  
        `test(MEMRD, DUT.state, "Should be in MEMRD");
        `test(16'h1016, DUT.mem_addr, "Should be the right address on fourth mem access");                        
	`tic;  
	`test(WAITSTATE, DUT.state, "Should be in WAITSTATE");
	`tic;  
	`test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
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

          /******************************************
	   * Write to address that is already in CACHE
	   * *****************************************/
          rd = 0;
	  wr = 1;
	  force DUT.DataIn = 16'h1100;
           #1

          `tic;
	  `test(COMPWR, DUT.state, "Should be in COMPWR");
	  `tic;
	  `test(DONE, DUT.state, "Should be in DONE");
	  `tic

           /****************************************
	    * Make it dirty
	    * **************************************/

	  addr = 16'h1100;
          force DUT.DataIn = 16'h0011;
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `test(INSTALL_CACHE, DUT.state, "Should be in INSTALL_CACHE");
	  `tic;
	  `test(WRMISSDONE, DUT.state, "Should be in WRMISSDONE");
	  `tic;
	  `test(IDLE, DUT.state, "Should be in IDLE");
	  `tic;
	  `test(COMPWR, DUT.state, "should be in compwr");
	  `tic;
	  `test(DONE, DUT.state, "should be in done");
	  `tic;

           /********************************************
	    *  Now Read it
	    * ******************************************/

	   rd = 1;
	   wr = 0;
	   #1

	   `tic
	   `test(COMPRD, DUT.state, "Should be in INSTALL_CACHE");
	   `tic;
	   `test(DONE, DUT.state, "Should be in DONE");
	   `tic;
           `test(16'h0011, DUT.DataOut, "Should be 16'h0011");

           /*************************************
	    * Seeing if shit works
	    * *********************************/
           
	   rd = 0;
	   wr = 1;
	   #1
           addr = 16'h0010;
	   force DUT.DataIn = 16'h0010;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   
	   addr = 16'h0100;
	   #1
	   force DUT.DataIn = 16'h0100;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;
	   `tic;

	   //Now Read Values

	   rd = 1;
	   wr = 0;

	   `tic;
	   `tic;
	   `tic;
	   `test(16'h0100, DUT.DataOut, "Should be 16'h0100");

	   addr = 16'h0010;
	   `tic;
	   `tic;
	   `tic;
	   `test(16'h0010, DUT.DataOut, "Should be 16'h0010");

           $display("Tests Complete");

	$stop;

     end

endmodule







