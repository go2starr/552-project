`include "testbench.v"

// t_mem_system_clone_bench
module t_mem_system_clone_bench();

   // Inputs
   reg [15:0] addr, data_in;
   reg        rd, wr, createdump;
   wire       clk, rst;
   

   // Outputs
   wire [15:0] data_out;
   wire        done, stall, cache_hit, err;

   // FSM states
   parameter ERR = 0;           // Error
   parameter IDLE = 1;          // Ready to be used
   parameter READ_0 = 2;        // (Read, Ready) = (0,x)
   parameter READ_1 = 3;        // (1,x)
   parameter READ_2 = 4;        // (2,0)
   parameter READ_3 = 5;        // (3,1)
   parameter READ_4 = 6;        // (x,2)
   parameter READ_5 = 7;        // (x,3)
   parameter WRITE_MEM = 8;        // Writing to memory
   parameter RETRY = 9;            // Re-attempting a read/write operation after miss
   
   // Counters, etc.
   integer     i,j,k;
   integer     no_errs, cycle;
   

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
      `info("Tests begin");

      // Init
      addr = 0;
      data_in = 0;
      rd = 0;
      wr = 0;
      createdump = 0;


      /********************************************************************************
       *  Test state transitions
       * ********************************************************************************/
      /****************************************
       *  ERR state
       * ****************************************/
      force DUT.state = ERR;
      #1;

      `test(ERR, DUT.next_state, "Next state is not ERR in ERR state");

      /****************************************
       *  IDLE state
       * ****************************************/
      force DUT.state = IDLE;

      // -> cache_valid_hit
      force DUT.cache_valid_hit = 1;
      #1;
      `test(IDLE, DUT.next_state, "Next state is not IDLE in IDLE on cache hit");

      // -> cache miss
      force DUT.cache_valid_hit = 0;
      
      // --> cache_dirty
      force DUT.cache_dirty = 1;
      #1;
      `test(WRITE_MEM, DUT.next_state, "Next state is not WRITE_MEM in IDLE on cache miss, dirty");

      // --> cache not dirty
      force DUT.cache_dirty = 0;
      #1;

      `test(READ_0, DUT.next_state, "Next state is not READ_0 in IDLE on cache miss, not dirty");

      /****************************************
       *  READ_0 thru READ_5
       *****************************************/
      force DUT.state = READ_0;
      #1;
      `test(READ_1, DUT.next_state, "Next state is not READ_1 in READ_0");

      force DUT.state = READ_1;
      #1;
      `test(READ_2, DUT.next_state, "Next state is not READ_2 in READ_1");

      force DUT.state = READ_2;
      #1;
      `test(READ_3, DUT.next_state, "Next state is not READ_3 in READ_2");

      force DUT.state = READ_3;
      #1;
      `test(READ_4, DUT.next_state, "Next state is not READ_4 in READ_3");

      force DUT.state = READ_4;
      #1;
      `test(READ_5, DUT.next_state, "Next state is not READ_5 in READ_4");      
      
      force DUT.state = READ_5;
      #1;
      `test(RETRY, DUT.next_state, "Next state is not RETRY in READ_5");

      /****************************************
       *  RETRY
       * ****************************************/
      force DUT.state = RETRY;
      #1;
      `test(IDLE, DUT.next_state, "Next state is not IDLE in RETRY");
      
      /****************************************
       *  WRITE_MEM
       *****************************************/
      force DUT.state = WRITE_MEM;

      // Count != 3
      force DUT.count = 0;
      #1;
      `test(WRITE_MEM, DUT.next_state, "Next state is not WRITE_MEM in WRITE_MEM on count != 3");

      // Count == 3
      force DUT.count = 3;
      #1;
      `test(READ_0, DUT.next_state, "Next state is not READ_0 in WRITE_MEM on count == 3");






      /****************************************
       *  Integration - cache hit
       *****************************************/
      force DUT.state = IDLE;
      force DUT.cache_valid_hit = 1;
      `tic;
      `test(IDLE, DUT.state, "State did not stay in IDLE on cache hit");

      /****************************************
       *  Int - Hit, not dirty
       *****************************************/
      force DUT.state = IDLE;
      force DUT.cache_valid_hit = 0;
      force DUT.cache_dirty = 0;
      #100;
      
      release DUT.state;
      release DUT.count;
      
      `tic;
      `test(READ_0, DUT.state, "State not READ_0 after IDLE miss, not dirty");
      `tic;
      `test(READ_1, DUT.state, "State not READ_1 after READ_0");
      `tic;
      `test(READ_2, DUT.state, "State not READ_2 after READ_1");
      `tic;
      `test(READ_3, DUT.state, "State not READ_3 after READ_2");
      `tic;
      `test(READ_4, DUT.state, "State not READ_4 after READ_3");
      `tic;
      `test(READ_5, DUT.state, "State not READ_5 after READ_4");      
      `tic;
      `test(RETRY, DUT.state, "State not RETRY after READ_5");
      `tic;
      `test(IDLE, DUT.state, "State not IDLE after RETRY");      

      /****************************************
       *  Int - Hit, dirty
       *****************************************/
      force DUT.state = IDLE;
      force DUT.cache_valid_hit = 0;
      force DUT.cache_dirty = 1;
      force DUT.count = 0;
      
      #100;
      release DUT.state;
      release DUT.count;
      
      `tic;
      `test(WRITE_MEM, DUT.state, "State not in WRITE_MEM after miss, dirty")
      `tic;
      `test(WRITE_MEM, DUT.state, "State not in WRITE_MEM after 1 write");
      `tic;
      `test(WRITE_MEM, DUT.state, "State not in WRITE_MEM after 2 writes");
      `tic;
      `test(WRITE_MEM, DUT.state, "State not in WRITE_MEM after 3 writes");
      `tic;
      `test(READ_0, DUT.state, "State not in READ_0 after 4 writes");      
      

      /********************************************************************************
       *  Output tests
       *********************************************************************************/

      /****************************************
       *  IDLE
       *****************************************/
      force DUT.state = IDLE;

      /********************
       *  Cache valid hit
       *********************/
      force DUT.cache_valid_hit = 1;
      #1;
      
      // Outputs
      `test(DUT.cache_data_out, DUT.DataOut, "DataOut is not the cache output on valid hit");
      `test(1, DUT.Done, "Done not set on cache hit");
      `test(0, DUT.Stall, "Stall not set on cache hit");
      `test(1, DUT.CacheHit, "CacheHit not set on cache hit");

      // Cache Control
      `test(1, DUT.cache_enable, "Cache should be enabled in IDLE");
      `test(1, DUT.cache_comp, "Comparison should be made in IDLE");
      `test(DUT.DataIn, DUT.cache_data_in, "Data into cache should be data into DUT");

      // On a read
      force DUT.Rd = 1;
      #1;
      `test(0, DUT.cache_write, "Cache write should be low on a read");

      force DUT.Rd = 0;
      force DUT.Wr = 1;
      #1;
      `test(1, DUT.cache_write, "Cache write should be high on write");

      /********************
       *  Cache miss
       *********************/
      force DUT.cache_valid_hit = 0;
      force DUT.cache_dirty = 0;
      #1;

      // Outputs
      `test(0, DUT.Done, "Done is set on a cache miss in IDLE");
      `test(1, DUT.Stall, "Stall not set on cache miss in IDLE");
      `test(0, DUT.CacheHit, "CacheHit set on cache miss in IDLE");

      /****************************************
       *  WRITEMEM
       *****************************************/
      force DUT.state = WRITE_MEM;
      force DUT.count = 0;
      #1;
      
      // Outputs
      `test(0, DUT.Done, "Done is set in WRITEMEM");
      `test(1, DUT.Stall, "Stall not set in WRITEMEM");
      `test(0, DUT.CacheHit, "CacheHit not set in WRITEMEM");

      // State control
      `test(DUT.count + 1, DUT.next_count, "Next count not incremented in WRITEMEM");
      
      // Mem control
      `test({DUT.cache_index, DUT.cache_tag_out, DUT.count, 1'b0}, DUT.mem_addr, "Mem address not correct in WRITEMEM");
      `test(DUT.cache_data_out, DUT.mem_data_in, "Mem data is not cache data out in WRITEMEM");
      `test(1, DUT.mem_wr, "Mem Wr not set in WRITEMEM");
      `test(0, DUT.mem_rd, "Mem Rd not set in WRITEMEM");

      // Cache control
      `test(1, DUT.cache_enable, "Cache not enabled in WRITEMEM");
      `test({DUT.count, 1'b0}, DUT.cache_offset, "Cache offset is not count in WRITEMEM");
      `test(0, DUT.cache_comp, "Cache comp set in WRITEMEM");
      `test(0, DUT.cache_write, "Cache write set in WRITEMEM");

      /****************************************
       *  READ_0
       * ****************************************/
      force DUT.state = READ_0;
      #1;

      // Mem control
      `test({DUT.Addr[15:3], 2'd0, 1'b0}, DUT.mem_addr, "Mem address not correct in READ_0");
      `test(0, DUT.mem_wr, "Mem wr set in READ_0");
      `test(1, DUT.mem_rd, "Meme rd not set in READ_0");

      /****************************************
       *  READ_1
       * ****************************************/
      force DUT.state = READ_1;
      #1;

      // Mem control
      `test({DUT.Addr[15:3], 2'd1, 1'b0}, DUT.mem_addr, "Mem address not correct in READ_1");
      `test(0, DUT.mem_wr, "Mem wr set in READ_1");
      `test(1, DUT.mem_rd, "Meme rd not set in READ_1");

      /****************************************
       *  READ_2
       * ****************************************/
      force DUT.state = READ_2;
      #1;

      // Mem control
      `test({DUT.Addr[15:3], 2'd2, 1'b0}, DUT.mem_addr, "Mem address not correct in READ_2");
      `test(0, DUT.mem_wr, "Mem wr set in READ_2");
      `test(1, DUT.mem_rd, "Meme rd not set in READ_2");

      // Cache control (install)
      `test(1, DUT.cache_enable, "Cache not enabled in READ_2");
      `test({2'b0, 1'b0}, DUT.cache_offset, "Cache offset in READ_2");
      `test(0, DUT.cache_comp, "Cache comp set in READ_2");
      `test(1, DUT.cache_write, "Cache write in READ_2");
      `test(1, DUT.cache_valid_in, "cache_valid_in in READ_2");
      `test(DUT.mem_data_out, DUT.cache_data_in, "Cache data in is not mem out in READ_2");
      
      
      /****************************************
       *  READ_3
       * ****************************************/
      force DUT.state = READ_3;
      #1;

      // Mem control
      `test({DUT.Addr[15:3], 2'd3, 1'b0}, DUT.mem_addr, "Mem address not correct in READ_3");
      `test(0, DUT.mem_wr, "Mem wr set in READ_3");
      `test(1, DUT.mem_rd, "Meme rd not set in READ_3");

      // Cache control (install)
      `test(1, DUT.cache_enable, "Cache not enabled in READ_2");
      `test({2'd1, 1'b0}, DUT.cache_offset, "Cache offset in READ_2");
      `test(0, DUT.cache_comp, "Cache comp set in READ_2");
      `test(1, DUT.cache_write, "Cache write in READ_2");
      `test(1, DUT.cache_valid_in, "cache_valid_in in READ_2");      

      /****************************************
       *  READ_4
       * ****************************************/
      force DUT.state = READ_4;
      #1;

      // Mem control (done reading)
      `test(0, DUT.mem_wr, "Mem wr set in read_4");
      `test(0, DUT.mem_rd, "Mem rd set in READ_4");

      // Cache control (install)
      `test(1, DUT.cache_enable, "Cache not enabled in READ_2");
      `test({2'd2, 1'b0}, DUT.cache_offset, "Cache offset in READ_2");
      `test(0, DUT.cache_comp, "Cache comp set in READ_2");
      `test(1, DUT.cache_write, "Cache write in READ_2");
      `test(1, DUT.cache_valid_in, "cache_valid_in in READ_2");      
      
      /****************************************
       *  READ_5
       * ****************************************/
      force DUT.state = READ_5;
      #1;

      // Cache control (install)
      `test(1, DUT.cache_enable, "Cache not enabled in READ_2");
      `test({2'd3, 1'b0}, DUT.cache_offset, "Cache offset in READ_2");
      `test(0, DUT.cache_comp, "Cache comp set in READ_2");
      `test(1, DUT.cache_write, "Cache write in READ_2");
      `test(1, DUT.cache_valid_in, "cache_valid_in in READ_2");

      /****************************************
       *  RETRY
       * ****************************************/
      force DUT.state = RETRY;
      #1;

      // Outputs
      `test(DUT.cache_data_out, DUT.DataOut, "DataOut not cache output in RETRY");
      `test(1, DUT.Done, "Done not set in RETRY");
      `test(0, DUT.Stall, "Stall set in RETRY");
      `test(0, DUT.CacheHit, "CacheHit not set in RETRY");

      // Cache Control
      `test(1, DUT.cache_enable, "Cache not enabled in RETRY");
      `test(1, DUT.cache_comp, "Comp should be set in RETRY");
      `test(DUT.DataIn, DUT.cache_data_in, "Data into cache should be data in to DUT");

      // On read
      force DUT.Rd = 1;
      force DUT.Wr = 0;
      #1;
      `test(0, DUT.cache_write, "Cache write should be low on read");

      force DUT.Rd = 0;
      force DUT.Wr = 1;
      #1;
      `test(1, DUT.cache_write, "Cache write should be high on write");
      
      

      `info("Tests end");
      $stop;
   end
endmodule // t_mem_system_clone_bench
