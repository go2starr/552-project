`include "testbench.v"

/* t_mem_system_fsm_bench.v - Testbench for memory system FSM state transitions */
module t_mem_system_fsm_bench();
   // Inputs
   reg [15:0] addr, data_in;
   reg        rd, wr, createdump, clk, rst;

   // Outputs
   wire [15:0] data_out;
   wire        done, stall, cache_hit, err;

   // Counters
   integer     i, j, k, no_errs;

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
                   .err(err),
                   .Addr(addr),
                   .DataIn(data_in),
                   .Rd(rd),
                   .Wr(wr),
                   .createdump(createdump),
                   .clk(clk),
                   .rst(rst)
                   );

/* output reg [15:0] DataOut;
   output            Done;
   output reg        Stall;
   output            CacheHit;
   output reg        err;*/

   
   initial clk = 0;
   always begin
      #50 clk = ~clk;
   end
   
   initial begin
      `info("Tests starting...");

      // Initialize
      addr = 0;
      data_in = 0;
      rd = 0;
      wr = 0;
      createdump = 0;
      rst = 0;

      /****************************************
       *  Reset conditions
       * ****************************************/
      rst = 1;
      `tic;
      `test(IDLE, DUT.state, "FSM should reset to IDLE state");
      `test(0, DUT.count, "FSM should reset counter to 0");
      rst = 0;

      /****************************************
       *  IDLE transitions
       * ****************************************/
      `tic;
      `tic;
      `tic;
      `test(IDLE, DUT.state, "FSM should stay in idle state while read/write low");

      // COMPRD
      rd = 1;
      #1;
      `test(1, DUT.Rd, "DUT read input should be 1");
      `test(COMPRD, DUT.next_state, "DUT next state should be COMPRD");
      
      `tic;
      `test(COMPRD, DUT.state, "FSM should transition to COMPRD on read");
      // transition to COMPRD Outputs
      `test(0, err, "No error occured");
      `test(1, stall, "stall should occur");


      // COMPWR
      force DUT.state = IDLE;
      release DUT.state;
      #1;
      `test(IDLE, DUT.state, "Force should reset state to IDLE");
      rd = 0;
      wr = 1;
      #1;
      `test(COMPWR, DUT.next_state, "DUT next state should be COMPWR");
      // transition to COMPWR Outputs
      `test(0, err, "No error occured");
      `test(0, stall, "stall should not occur");

      
      `tic;
      `test(COMPWR, DUT.state, "FSM should transition to COMPWR on read in IDLE");
      
      // ERR
      force DUT.state = IDLE;
      release DUT.state;
      rd = 1;
      wr = 1;
      `tic;
      `test(ERR, DUT.state, "FSM should transition to ERR");
      // transition to ERR Outputs
      `test(1, err, "Error occured so err output should be high.");
      `test(0, done, "Is not done");
      `test(0, stall, "stall should not occur");



      /****************************************
       * COMPRD transitions
       ******************************************/
      force DUT.state = COMPRD;
      release DUT.state;
      rd = 1;
      wr = 0; 
      `tic;
      `test(COMPRD, DUT.state, "FSM should remain in COMPRD");
      
      // MEMRD
      force DUT.cache_hit = 0;
      force DUT.cache_dirty = 0;
      rd = 0; 
      `tic;
      `test(MEMRD, DUT.state, "FSM should transition to MEMRD");
      // transition to MEMRD Outputs
      `test(0, cache_hit, "Should have missed in the cache");
      `test(0, done, "Is not done");
      `test(0, err, "No error occured");
      `test(1, stall, "stall should occur");

      // PREWBMEM
      force DUT.state = COMPRD;
      release DUT.state;
      force DUT.cache_hit = 0;
      force DUT.cache_dirty = 1;
      force DUT.cache_valid = 1;
      `tic;
      `test(PREWBMEM, DUT.state, "FSM should transition to PREWBMEM");
      // transition to PREWBMEM Outputs
      `test(0, cache_hit, "Should have missed in the cache");
      `test(0, done, "Is not done");
      `test(0, err, "No error occured");
      `test(0, stall, "stall should not occur");


      // DONE
      force DUT.state = COMPRD;
      release DUT.state;
      force DUT.cache_hit = 1;
      force DUT.cache_valid = 1;
      `tic;
      `test(DONE, DUT.state, "FSM should transition to DONE"); 
      // transition to DONE Outputs
      `test(0, err, "No error occured");
      `test(0, stall, "stall should not occur");
     
      
      /*************************************************
       * MEMRD transitions
       *************************************************/
      force DUT.state = MEMRD;
      release DUT.state;
      force DUT.mem_stall = 1;
      `tic;
      `tic;
      `tic;
      `test(MEMRD, DUT.state, "FSM should remain in MEMRD"); 
       
      // WAITSTATE
      force DUT.state = MEMRD;
      release DUT.state;
      force DUT.mem_stall = 0;
      `tic;
      `test(WAITSTATE, DUT.state, "FSM should transition to WAITSTATE");
      // transition to WAITSTATE Outputs
      `test(0, done, "Is not done");
      `test(0, err, "No error occured");
      `test(1, stall, "stall should occur");


      /************************************************
       * WAITSTATE transitions
       ************************************************/
      force DUT.state = WAITSTATE;
      release DUT.state;
      `tic;
      `test(INSTALL_CACHE, DUT.state, "FSM should transition to INSTALL_CACHE");
  
      /****************************************************
       * INSTALL_CACHE transitions
       ********************************************************/       
      // MEMRD
      force DUT.state = INSTALL_CACHE;
      release DUT.state;
      force DUT.count = 0;
      `tic;
      `test(MEMRD, DUT.state, "FSM should transition to MEMRD");
      `tic;
      `tic;
      `test(INSTALL_CACHE, DUT.state, "FSM should now be in INSTALL_CACHE again");
      force DUT.count = 1;
      `tic;
      `test(MEMRD, DUT.state, "FSM should transition to MEMRD");

      // DONE
      force DUT.count = 2'b11;
      force DUT.state = INSTALL_CACHE;
      release DUT.state;
      rd = 1;
      wr = 0;
      `tic;
      `test(DONE, DUT.state, "FSM should transition to DONE");
      // transition to DONE Outputs
      `test(0, err, "No error occured");
      `test(0, stall, "stall should not occur");


      // WRMISSDONE
      force DUT.count = 2'b11;
      force DUT.state = INSTALL_CACHE;
      release DUT.state;
      rd = 0;
      wr = 1;
      `tic;
      `test(WRMISSDONE, DUT.state, "FSM should transition to WRMISSDONE");
      // transition to MEMRD Outputs
      `test(0, cache_hit, "Cache missed, so cache_hit should be 0");
      `test(0, err, "No error occured");
      `test(0, stall, "stall should not occur");

    
      /*************************************
       * DONE transitions
       ***************************************/
      // IDLE
      force DUT.state = DONE;
      release DUT.state;
      `tic;
      `test(IDLE, DUT.state, "FSM should transition to IDLE");
      // transition to IDLE Outputs
      `test(0, err, "No error occured");
      `test(0, stall, "stall should not occur");
 

      /******************************************
       * COMPWR transitions
       *********************************************/
      // DONE
      force DUT.state = COMPWR;
      release DUT.state;
      force DUT.cache_hit = 1;
      `tic;
      `test(DONE, DUT.state, "FSM should transition to DONE");

      // MEMRD
      force DUT.state = COMPWR;
      release DUT.state;
      force DUT.cache_hit = 0;
      force DUT.cache_dirty = 0;
      `tic;
      `test(MEMRD, DUT.state, "FSM should transition to MEMRD");

      // WBMEM 
      force DUT.state = COMPWR;
      release DUT.state;
      force DUT.cache_hit = 0;
      force DUT.cache_dirty = 1;
      `tic;
      `test(WBMEM, DUT.state, "FSM should transition to WBMEM");      

      /***************************************
       * WRMISSDONE transitions
       *******************************************/
      // IDLE
      force DUT.state = WRMISSDONE;
      release DUT.state;
      `tic;
      `test(IDLE, DUT.state, "FSM should transition to IDLE");  

      /*****************************************
       * PREWBMEM transitions
       *********************************************/
      // WBMEM
      force DUT.state = PREWBMEM;
      release DUT.state;
      force DUT.count = 2'b00;
      `tic;
      `test(WBMEM, DUT.state, "FSM should transition to WBMEM"); 

      /*******************************************
       * WBMEM transitions
       **********************************************/  
      force DUT.state = WBMEM;
      release DUT.state;
      force DUT.count = 2'b00;
      `tic;
      `test(WBMEM, DUT.state, "FSM should remain in WBMEM");
      force DUT.mem_stall = 1;
      force DUT.count = 2'b11;
      `tic;
      `test(WBMEM, DUT.state, "FSM should remain in WBMEM");

      // MEMRD
      force DUT.mem_stall = 0;
      `tic;
      `test(MEMRD, DUT.state, "FSM should transition to MEMRD");

      `info("Tests complete");

      $stop;
      
   end
   
endmodule // t_mem_system_fsm_bench
