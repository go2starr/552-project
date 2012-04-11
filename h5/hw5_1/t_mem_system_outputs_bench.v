`include "testbench.v"

/* t_mem_system_fsm_bench.v - Testbench for memory system FSM state transitions */
module t_mem_system_outputs_bench();
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

      /********************************************************************************
       *  ERR Outputs
       ********************************************************************************/
      force DUT.state = ERR;
      #1;

      `test(1, err, "DUT.err should be 1 in the ERR state");


      /********************************************************************************
       *  IDLE Outputs
       * ********************************************************************************/
      force DUT.state = IDLE;
      #1;

      `test(0, done, "DUT.done should be 0 in IDLE state");
      `test(0, stall, "DUT.stall should be 0 in the IDLE state");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in the IDLE state");
      `test(0, err, "DUT.err should be 0 in the IDLE state");

      `tic;
      `tic;
      `tic;

      // No change
      `test(0, done, "DUT.done should be 0 in IDLE state");
      `test(0, stall, "DUT.stall should be 0 in the IDLE state");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in the IDLE state");
      `test(0, err, "DUT.err should be 0 in the IDLE state");      

      /********************************************************************************
       *  COMPRD
       * ********************************************************************************/
      force DUT.state = COMPRD;

      /****************************************
       * Cache hit 
       * ****************************************/
      force DUT.c0.hit   = 1;
      
      // Cache hit when valid
      force DUT.c0.valid = 1;
      #1;
      
      `test(1, done, "DUT.done should be 1 in COMPRD state on a valid hit");
      `test(0, stall, "DUT.stall should be 0 in COMPRD state on valid hit");
      `test(1, cache_hit, "DUT.cache_hit should be 1 in COMPRD state on valid hit");
      `test(0, err, "DUT.err should be 0 in COMPRD state on valid hit");

      // Cache hit when not valid
      force DUT.c0.valid = 0;
      #1;

      `test(0, done, "DUT.done should be 0 in COMPRD state on invalid hit");
      `test(1, stall, "DUT.stall should be 1 in COMPRD state on invalid hit");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in COMPRD state on invalid hit");
      `test(0, err, "DUT.err should be 0 in COMPRD state on invalid hit");

      /****************************************
       *  Cache miss
       * ****************************************/
      force DUT.c0.hit = 0;

      // Cache miss, not dirty
      force DUT.c0.dirty = 0;
      #1;

      `test(0, done, "DUT.done should be 0 in COMPRD state on miss but not dirty");
      `test(1, stall, "DUT.stall should be 1 in COMPRD state on miss but not dirty");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in COMPRD state on miss but not dirty");
      `test(0, err, "DUT.err should be 0 in COMPRD state on miss but not dirty");

      // Cache miss, dirty, and valid
      force DUT.c0.dirty = 1;
      force DUT.c0.valid = 1;
      #1;

      `test(0, done, "DUT.done should be 0 in COMPRD state on miss, dirty, and valid");
      `test(1, stall, "DUT.stall should be 1 in COMPRD state on miss, dirty, and valid");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in COMPRD state on miss, dirty, and valid");
      `test(0, err, "DUT.err should be 0 in COMPRD state on miss, dirty, and valid");

      // Cache miss, dirty, and not valid
      force DUT.c0.valid = 0;
      #1;

      `test(0, done, "DUT.done should be 0 in COMPRD state on miss, dirty, and not valid");
      `test(1, stall, "DUT.stall should be 1 in COMPRD state on miss, dirty, and not valid");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in COMPRD state on miss, dirty, and not valid");
      `test(0, err, "DUT.err should be 0 in COMPRD state on miss, dirty, and not valid");

      /********************************************************************************
       *  MEMRD
       * ********************************************************************************/
      force DUT.state = MEMRD;

      // Mem stalling
      force DUT.mem.stall = 1;
      #1;

      `test(0, done, "DUT.done should be 0 in MEMRD on mem stall");
      `test(1, stall, "DUT.stall should be 1 in MEMRD on mem stall");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in MEMRD on mem stall");
      `test(0, err, "DUT.err should be 0 in MEMRD on mem stall");
      
      // Mem not stalling
      force DUT.mem.stall = 0;
      #1;
      
      `test(0, done, "DUT.done should be 0 in MEMRD on mem not stalling");
      `test(1, stall, "DUT.stall should be 1 in MEMRD on mem not stalling");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in MEMRD on mem not stalling");
      `test(0, err, "DUT.err should be 0 in MEMRD on mem not stalling");      
      
      /********************************************************************************
       *  WAITSTATE
       * ********************************************************************************/
      force DUT.state = WAITSTATE;
      #1;

      `test(0, done, "DUT.done should be 0 in WAITSTATE");
      `test(1, stall, "DUT.stall should be 1 in WAITSTATE");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in WAITSTATE");
      `test(0, err, "DUT.err should be 0 in WAITSTATE");

      /********************************************************************************
       *  INSTALL_CACHE
       * ********************************************************************************/
      force DUT.state = INSTALL_CACHE;
      #1;

      `test(0, done, "DUT.done should be 0 in INSTALL_CACHE");
      `test(1, stall, "DUT.stall should be 1 in INSTALL_CACHE");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in INSTALL_CACHE");
      `test(0, err, "DUT.err should be 0 in INSTALL_CACHE");     

      /********************************************************************************
       *  DONE
       * ********************************************************************************/
      force DUT.state = DONE;
      #1;

      // On cache hit
      force DUT.c0.hit = 1;
      #1;

      // Already raised done, stall, and hit
      `test(0, done, "DUT.done should be 0 in DONE on hit");
      `test(1, stall, "DUT.stall should be 1 in DONE on hit");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in DONE on hit");
      `test(0, err, "DUT.err should be 0 in DONE on hit");

      // On cache miss
      force DUT.c0.hit = 0;
      #1;

      `test(1, done, "DUT.done should be 0 in DONE on miss");
      `test(0, stall, "DUT.stall should be 1 in DONE on miss");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in DONE on miss");
      `test(0, err, "DUT.err should be 0 in DONE on miss");

      /********************************************************************************
       *  COMPWR
       * ********************************************************************************/
      force DUT.state = COMPWR;

      // On hit and valid
      force DUT.c0.valid = 1;
      force DUT.c0.hit = 1;
      #1;
      
      `test(1, done, "DUT.done should be 1 in COMPWR");
      `test(0, stall, "DUT.stall should be 0 in COMPWR");
      `test(1, cache_hit, "DUT.cache_hit should be 1 in COMPWR");
      `test(0, err, "DUT.err should be 0 in COMPWR");
     
      // On hit and not valid
      force DUT.c0.valid = 0;
      #1;

      `test(0, done, "DUT.done should be 0 in COMPWR");
      `test(1, stall, "DUT.stall should be 1 in COMPWR");
      `test(0, cache_hit, "DUT.cache_hit should be 0 in COMPWR");
      `test(0, err, "DUT.err should be 0 in COMPWR");

      // On miss and dirty
      force DUT.c0.hit = 0;
      force DUT.c0.dirty = 1;
      #1;

      `test(0, done, "DUT.done should be 0 in COMPWR");
      `test(1, stall, "DUT.stall should be 0 in COMPWR");
      `test(0, cache_hit, "DUT.cache_hit should be 1 in COMPWR");
      `test(0, err, "DUT.err should be 0 in COMPWR");

      // On miss and not dirty
      force DUT.c0.dirty = 0;
      #1;

      `test(0, done, "DUT.done should be 0 in COMPWR");
      `test(1, stall, "DUT.stall should be 0 in COMPWR");
      `test(0, cache_hit, "DUT.cache_hit should be 1 in COMPWR");
      `test(0, err, "DUT.err should be 0 in COMPWR");      

      /********************************************************************************
       *  WRMISSDONE
       * ********************************************************************************/
      force DUT.state = WRMISSDONE;
      #1;
      
      `test(0, done, "DUT.done should be 0 in WRMISSDONE");
      `test(1, stall, "DUT.stall should be 1 in WRMISSDONE");
      `test(0, cache_hit, "DUT.cache_hit should be 1 in WRMISSDONE");
      `test(0, err, "DUT.err should be 0 in WRMISSDONE");

      /********************************************************************************
       *  PREWBMEM
       * ********************************************************************************/
      force DUT.state = PREWBMEM;
      #1;
      
      `test(0, done, "DUT.done should be 0 in PREWBMEM");
      `test(1, stall, "DUT.stall should be 1 in PREWBMEM");
      `test(0, cache_hit, "DUT.cache_hit should be 1 in PREWBMEM");
      `test(0, err, "DUT.err should be 0 in PREWBMEM");

      /********************************************************************************
       *  WBMEM
       * ********************************************************************************/
      force DUT.state = WBMEM;
      #1;

      // Mem stall
      force DUT.mem.stall = 1;
      
      `test(0, done, "DUT.done should be 0 in WBMEM on mem stall");
      `test(1, stall, "DUT.stall should be 1 in WBMEM on mem stall");
      `test(0, cache_hit, "DUT.cache_hit should be 1 in WBMEM on mem stall");
      `test(0, err, "DUT.err should be 0 in WBMEM on mem stall");                        

      // Count != 11
      force DUT.mem.stall = 0;
      force DUT.count = 2'b10;

      `test(0, done, "DUT.done should be 0 in WBMEM on count != 2'b11");
      `test(1, stall, "DUT.stall should be 1 in WBMEM on count != 2'b11");
      `test(0, cache_hit, "DUT.cache_hit should be 1 in WBMEM on count != 2'b11");
      `test(0, err, "DUT.err should be 0 in WBMEM on count != 2'b11");
      
      // Count == 11
      force DUT.count = 2'b11;

      `test(0, done, "DUT.done should be 0 in WBMEM on count == 2'b11");
      `test(1, stall, "DUT.stall should be 1 in WBMEM on count == 2'b11");
      `test(0, cache_hit, "DUT.cache_hit should be 1 in WBMEM on count == 2'b11");
      `test(0, err, "DUT.err should be 0 in WBMEM on count == 2'b11");
      
      `info("Tests complete");
      $stop;
      
   end // initial begin
endmodule // t_mem_system_outputs_bench
