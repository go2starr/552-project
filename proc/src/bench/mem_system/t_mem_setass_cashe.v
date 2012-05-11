`include "testbench.v"

module t_mem_setass_cashe();
     //Inputs
     reg [15:0] addr, data_in;
     reg        rd, wr, createdump;
     integer cycle;

     // Outputs
     wire [15:0] data_out;
     wire        done, stall, cache_hit, err;
     wire clk, rst;
     
     //Band aid fix
     integer no_errs;

     /* Mem FSM states */
     parameter ERR = 0;
     parameter IDLE = 1;
     parameter READ_0 = 2;
     parameter READ_1 = 3;
     parameter READ_2 = 4;
     parameter READ_3 = 5;
     parameter READ_4 = 6;
     parameter READ_5 = 7;
     parameter WRITE_MEM = 8;
     parameter RETRY = 9;

     
         // DUT
         mem_system DUT (.DataOut(data_out),
                         .Done(done),
                         .Stall(stall),
                         .CacheHit(cache_hit),
                         .err(err),                                                                       
			 .Addr(addr),
			 .DataIn(data_in),
			 .Rd(rd),            			
			 .Wr(wr),
			 .createdump(createdump),
			 .clk(clk),
			 .rst(rst)
			 );
     
     
     clkrst cr(clk, rst, err);

     initial begin
        `info("Tests starting...");


	//Initialize
	addr = 0;
	data_in = 0;
	rd = 0;
	wr = 0;
	createdump = 0;


	/*******************************
	 *  First Test- Write to Address
	 *  ****************************/

	addr = 16'h1010;
	force DUT.DataIn = 16'h1111;
	#1
	rd = 0;
	wr = 1;
	`tic;
	`tic;

        `test(0, DUT.victimway, "victimway should be intialized to 0");
	`test(IDLE, DUT.state, "Should be in IDLE");
	`tic;
	`test(16'h1010, DUT.mem_addr, "Right addr on first mem access");
	`test(READ_0, DUT.state, "Should be in READ_0");
	`tic;
	`test(READ_1, DUT.state, "Should be in READ_1");
        `tic; 
	`test(READ_2, DUT.state, "Should be in READ_2");
	`tic;  
        `test(READ_3, DUT.state, "Should be in READ_3");
	`tic
	`test(READ_4, DUT.state, "Should be in READ_4");
	`tic;  
	`test(READ_5, DUT.state, "Should be in READ_5");
	`tic;  
        `test(RETRY, DUT.state, "Should be in RETRY");
	`tic; 
	`test(1, DUT.cache_write, "writing on first word in INSTALL_CACHE");
	`test(IDLE, DUT.state, "Should be in IDLE");
	`tic;  
	`test(16'h1111, DUT.cache_data_in, "Data into cache should be data into memory");
        `tic;
	`test(1, DUT.cache_hit, "Should be a hit after filling cache with valid block");
	`tic;
	`test(IDLE, DUT.state, "Should be in IDLE");
	#1
      


 	/**********************************************
	 *  Second Test- Write to another address
	 *  *******************************************/

	addr = 16'h1011;
	force DUT.DataIn = 16'h1111;
	#1
	rd = 0;
	wr = 1;
	`tic;
	`tic;

        `test(1, DUT.victimway, "state of victimway should be inverted");
	`test(IDLE, DUT.state, "Should be in IDLE");
	`tic;
	`test(16'h1011, DUT.mem_addr, "Right addr on first mem access");
	`test(READ_0, DUT.state, "Should be in READ_0");
	`tic;
	`test(READ_1, DUT.state, "Should be in READ_1");
        `tic; 
	`test(READ_2, DUT.state, "Should be in READ_2");
	`tic;  
        `test(READ_3, DUT.state, "Should be in READ_3");
	`tic
	`test(READ_4, DUT.state, "Should be in READ_4");
	`tic;  
	`test(READ_5, DUT.state, "Should be in READ_5");
	`tic;  
        `test(RETRY, DUT.state, "Should be in RETRY");
	`tic; 
	`test(1, DUT.cache_write, "writing on first word in INSTALL_CACHE");
	`test(IDLE, DUT.state, "Should be in IDLE");
	`tic;  
	`test(16'h1111, DUT.cache_data_in, "Data into cache should be data into memory");
        `tic;
	`test(1, DUT.cache_hit, "Should be a hit after filling cache with valid block");
	`tic;
	`test(IDLE, DUT.state, "Should be in IDLE");
	#1
      
       	/**************************************
	 *  Third Test- Write to another Address
	 *  ************************************/

	addr = 16'h1111;
	force DUT.DataIn = 16'h1111;
	#1
	rd = 0;
	wr = 1;
	`tic;
	`tic;

        `test(0, DUT.victimway, "victimway should be inverted back to 0");
	`test(IDLE, DUT.state, "Should be in IDLE");
	`tic;
	`test(16'h1010, DUT.mem_addr, "Right addr on first mem access");
	`test(READ_0, DUT.state, "Should be in READ_0");
	`tic;
	`test(READ_1, DUT.state, "Should be in READ_1");
        `tic; 
	`test(READ_2, DUT.state, "Should be in READ_2");
	`tic;  
        `test(READ_3, DUT.state, "Should be in READ_3");
	`tic
	`test(READ_4, DUT.state, "Should be in READ_4");
	`tic;  
	`test(READ_5, DUT.state, "Should be in READ_5");
	`tic;  
        `test(RETRY, DUT.state, "Should be in RETRY");
	`tic; 
	`test(1, DUT.cache_write, "writing on first word in INSTALL_CACHE");
	`test(IDLE, DUT.state, "Should be in IDLE");
	`tic;  
	`test(16'h1111, DUT.cache_data_in, "Data into cache should be data into memory");
        `tic;
	`test(1, DUT.cache_hit, "Should be a hit after filling cache with valid block");
	`tic;
	`test(IDLE, DUT.state, "Should be in IDLE");
	#1
      

        /****************************
	 *  Now Read Address
	 *  *************************/

	rd = 1;
	wr = 0;
	#1;
	`test(1, DUT.victimway, "victimway should be inverted back to 1");
	`test(1, DUT.c0.hit, "Should be a hit");
	`tic; //Should be in DONE
	`test(IDLE, DUT.state, "Should be Done");
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
	  `test(0, DUT.victimway, "victimway should be inverted back to 0");
	  `tic;
	  `test(READ_0, DUT.state, "Should be in READ_0");
	  `tic;
	  `test(READ_1, DUT.state, "Should be in READ_1");
	  `tic;
          `test(READ_2, DUT.state, "Should be in READ_2");
	  `tic;
          `test(READ_3, DUT.state, "Should be in READ_3");
	  `tic;
	  `test(READ_4, DUT.state, "Should be in READ_4");
	  `tic;
	  `test(READ_5, DUT.state, "Should be in READ_5");
	  `tic;
	  `test(RETRY, DUT.state, "Should be in INSTALL_CACHE");
	  `tic;
	  `test(IDLE, DUT.state, "Should be in IDLE");
	  `tic;
	  `test(IDLE, DUT.state, "Should be in IDLE");

          /******************************************
	   * Write to address that is already in CACHE
	   * *****************************************/
          rd = 0;
	  wr = 1;
	  force DUT.DataIn = 16'h1100;
           #1
          
          `test(1, DUT.victimway, "victimway should be inverted back to 1");
	   tic;
	  `test(IDLE, DUT.state, "Should be in IDLE");

           /****************************************
	    * Make it dirty
	    * **************************************/

	  addr = 16'h1100;
          force DUT.DataIn = 16'h0011;


	  `test(0, DUT.victimway, "victimway should be inverted back to 0");
	  `test(IDLE, DUT.state, "Should be IDLE");
	  `tic;
	  `test(WRITE_MEM, DUT.state, "Should be write because its dirty");
	  `tic;
	  `tic;
	  `tic;
	  `tic;
	  `test(READ_0, DUT.state, "Should be READ_0");
	  `tic;
	  `test(READ_1, DUT.state, "Should be READ_1");
	  `tic;
	  `test(READ_2, DUT.state, "Should be READ_2");
	  `tic;
	  `test(READ_3, DUT.state, "Should be READ_3");
	  `tic;
	  `tic;
	  `tic;
	  `test(RETRY, DUT.state, "Should be in RETRY");
	  `tic;
	  `test(IDLE, DUT.state, "Should be IDLE");

           $display("Tests Complete");

	$stop;

     end

endmodule







