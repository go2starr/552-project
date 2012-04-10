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

      // COMPWR
      force DUT.state = IDLE;
      release DUT.state;
      #1;
      `test(IDLE, DUT.state, "Force should reset state to IDLE");
      rd = 0;
      wr = 1;
      #1;
      `test(COMPWR, DUT.next_state, "DUT next state should be COMPWR");
      
      `tic;
      `test(COMPWR, DUT.state, "FSM should transition to COMPWR on read in IDLE");
      
      
      
      `info("Tests complete");

      $stop;
      
   end
   
endmodule // t_mem_system_fsm_bench
