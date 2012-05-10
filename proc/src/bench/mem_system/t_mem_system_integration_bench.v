`include "testbench.v"

// t_mem_system_integration_bench
module t_mem_system_integration_bench();

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

      // $monitor("%d :: en,tag,index,offset,data_in,comp,write,valid_in : %b, %h, %h, %h, %h, %b, %b, %b",
      // DUT.state, DUT.cache_enable, DUT.cache_tag_in, DUT.cache_index, DUT.cache_offset, DUT.cache_data_in, DUT.cache_comp, DUT.cache_write, DUT.cache_valid_in);
      

      // Init
      addr = 0;
      data_in = 0;
      rd = 0;
      wr = 0;
      createdump = 0;

      /********************************************************************************
       *  Test 1 - Write and read back
       *********************************************************************************/
      `tic;
      `tic;
      `tic;
      
      // IDLE
      addr = 16'h1234;
      data_in = 16'hdead;
      rd = 0;
      wr = 1;
      
      `test(IDLE, DUT.state, "Should reset to IDLE state");
      
      // READ_0
      `tic;
      `test(READ_0, DUT.state, "Should go to READ_0 on cache miss, not dirty");

      // READ_1
      `tic;
      `test(READ_1, DUT.state, "Should go to READ_1 after READ_0");

      // READ_2
      `tic;
      `test(READ_2, DUT.state, "Should go to READ_2 after READ_1");

      // READ_3
      `tic;
      `test(READ_3, DUT.state, "Should go to READ_3 after READ_2");

      // READ_4
      `tic;
      `test(READ_4, DUT.state, "Should go to READ_4 after READ_3");

      // READ_5
      `tic;
      `test(READ_5, DUT.state, "Should go to READ_5 after READ_4");

      // RETRY
      `tic;
      `test(RETRY, DUT.state, "Should go to RETRY");

      `test(1, DUT.cache_enable, "Cache should be enabled on RETRY");
      `test(1, DUT.cache_hit, "Should hit in RETRY");
      `test(16'hdead, DUT.cache_data_in, "Data into cache should be data into mem_system");
      `test(1, DUT.cache_valid_in, "Cache_data_valid should be set on a write");

      // IDLE
      `tic;
      `test(IDLE, DUT.state, "Should go to IDLE after RETRY");
      
      rd = 1;
      wr = 0;

      #1;
      `test(1, DUT.CacheHit, "Should hit when reading from same address as just written to");
      `test(16'hdead, DUT.DataOut, "Should read back same data as written to cache");
      `test(1, DUT.Done, "Should be done on cache hit");
      
      
      
      
      
      

      `info("Tests end");
      $stop;
   end // initial begin
endmodule // t_mem_system_integration_bench
