/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
                  // Outputs
                  DataOut, Done, Stall, CacheHit, err, 
                  // Inputs
                  Addr, DataIn, Rd, Wr, createdump, clk, rst
                  );

   /********************************************************************************
    *  Module Definition
    * ********************************************************************************/
   // Inputs
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;

   // Outputs
   output reg [15:0] DataOut;
   output reg        Done;
   output reg        Stall;
   output reg        CacheHit;
   output reg        err;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter mem_type = 0;
   
   /* Mem FSM states */
   parameter ERR = 0;           // Error
   parameter IDLE = 1;          // Ready to be used
   parameter READ_MEM = 2;      // Initiating read request
   parameter READ_MEM_WAIT = 3; // Waiting for read request to finish
   parameter READ_MEM_INSTALL = 4; // Installing read request to cache
   parameter WRITE_MEM = 5;        // Writing to memory
   parameter RETRY = 6;            // Re-attempting a read/write operation after miss
   
   /********************************************************************************
    *   Wires
    * ********************************************************************************/

   /****************************************
    *  Internal
    * ****************************************/
   reg [3:0]         state;
   reg [3:0]         next_state;
   
   reg [1:0]         count;     // Number of words written/read in this block
   reg [1:0]         next_count;

   reg               cache_accessed; // Was the cache accessed on the previous cycle?
   reg               next_cache_accessed;
   
   always @(posedge clk) begin
      if (rst) begin
         state <= IDLE;
         count <= 0;
         cache_accessed = 0;
      end else begin
         state <= next_state;
         count <= next_count;
         cache_accessed <= next_cache_accessed;
      end
   end
   
   /****************************************
    *   Cache
    * ****************************************/
   // Inputs
   reg           cache_enable;
   wire [4:0]    cache_tag_in;
   wire [7:0]    cache_index;
   reg [2:0]     cache_offset;
   reg [15:0]    cache_data_in;
   reg           cache_comp, cache_write, cache_valid_in;   

   // Outputs
   wire [4:0]    cache_tag_out;
   wire [15:0]   cache_data_out;   
   wire          cache_hit, cache_dirty, cache_valid, cache_err;

   // Assigns
   assign cache_index  = Addr [15:8];
   assign cache_tag_in = Addr [7:3];

   /****************************************
    *  Memory
    *****************************************/
   // Inputs
   reg [15:0]    mem_addr;
   reg [15:0]    mem_data_in;
   reg           mem_wr, mem_rd;

   // Outputs
   wire [15:0]   mem_data_out;
   wire          mem_stall;
   wire [3:0]    mem_busy;
   wire          mem_err;
   
   /********************************************************************************
    *  Modules
    * ********************************************************************************/
   // You must pass the mem_type parameter 
   // and createdump inputs to the 
   // cache modules
   cache #(0 + mem_type) c0(
	                    // Inputs
                            .enable(cache_enable),
	                    .clk(clk), 
	                    .rst(rst), 
	                    .createdump(createdump),
	                    .tag_in(cache_tag_in), 
	                    .index(cache_index), 
	                    .offset(cache_offset), 
	                    .data_in(cache_data_in), 
	                    .comp(cache_comp), 
	                    .write(cache_write), 
	                    .valid_in(cache_valid_in), 
	                    // Outputs
	                    .tag_out(cache_tag_out), 
	                    .data_out(cache_data_out), 
	                    .hit(cache_hit), 
	                    .dirty(cache_dirty), 
	                    .valid(cache_valid), 
	                    .err(cache_err)
	                    );

   four_bank_mem mem (
                      // Inputs
                      .clk(clk),
                      .rst(rst),
                      .createdump(createdump),
                      .addr(mem_addr),
                      .data_in(mem_data_in),
                      .wr(mem_wr),
                      .rd(mem_rd),
                      // Outputs
                      .data_out(mem_data_out),
                      .stall(mem_stall),
                      .busy(mem_busy),
                      .err(mem_err)
                      );

/********************************************************************************
 *  Next-state logic
 * ********************************************************************************/
   always@(*)begin
      case(state)
        /*
         *  ERR - In the error state; stay here.
         */
        ERR:
          next_state = ERR;
        
        /*
         *  IDLE -  In the idle state, the memory system is ready to be used.
         *  Reads and writes can be made, and two cases can occur:
         * 
         *  1. A memory access can hit, in which case the operation happens
         *     immediately, and we return to IDLE.
         * 
         *  2. A memory access misses, in which case we need to:
         *       - Write to memory if the cache row is dirty
         *       - Read in a new row; install to cache
         *       - Retry the operation
         */
        IDLE:
          // Did we access the cache last clock cycle?
          if (cache_accessed) begin
             // Did the access hit?
             if (cache_hit && cache_valid) begin
                // Stay in idle, the operation completed
                next_state = IDLE;
                
             end else begin
                // Cache missed, is the row dirty?
                if (cache_dirty) begin
                   // Cache is dirty, need to write back to mem
                   next_state = WRITE_MEM;
                end else begin
                   // Cache is not dirty, safe to read block into cache
                   next_state = READ_MEM;
                end                
             end
          end else begin // if (cache_accessed)
             // No accesses made; stay here
             next_state = IDLE;
          end // else: !if(cache_accessed)

        /*
         *  READ_MEM - In the read_mem state, the address and control lines
         *  are driven to memory to make a read.  The read takes two cycles,
         *  so a wait state is entered.
         */
        READ_MEM:
          next_state = READ_MEM_WAIT;

        /*
         *  READ_MEM_WAIT - In the read_mem_wait state, we are waiting the
         *  one stall cycle to access memory.
         */
        READ_MEM_WAIT:
          next_state = READ_MEM_INSTALL;

        /*
         *  READ_MEM_INSTALL - In the read_mem_install state, the memory data
         *  out is valid, and should be written to the correct word offset 
         *  within the cache.
         */
        READ_MEM_INSTALL:
          // Last word?
          if (count == 3) begin
             // The block has been read from memory into the cache - retry op
             next_state = RETRY;
          end else begin
             // There are more words to read
             next_state = READ_MEM;
          end

        /*
         *  WRITE_MEM - In the write_mem stage, a block in the cache is being
         *  written to memory.
         */
        WRITE_MEM:
          // Last word?
          if (count == 3) begin
             // The block has been written to memory from the cache - read in
             // the new block
             next_state = READ_MEM;
          end else begin
             // There are more words to write
             next_state = WRITE_MEM;
          end

        /*
         *  RETRY - In the retry state, a cache miss had occurred before during
         *  this read/write cycle, but the correct block has been installed to
         *  the cache since then.  A cache hit will now occur, and we will return
         *  to IDLE.
         */
        RETRY:
          next_state = IDLE_STATE;
        
      endcase
   end

/********************************************************************************
 *  Next-output logic
 * ********************************************************************************/
   //   Mem:
   //     - addr
   //     - data_in
   //     - wr
   //     - rd
   //   Mem_System:
   //     - next_count
   //     - err
   
   always @(*) begin
      // Outputs
      Stall = 1;
      Done = 0;
      err = 0;

      // State
      next_count = count;
      next_cache_accessed = 0;
      
      // Cache
      cache_enable = 0;
      cache_data_in = 0;
      cache_comp = 0;
      cache_write = 0;
      cache_valid_in = 0;

      // Memory
      mem_addr = 0;
      mem_data_in = 0;
      mem_wr = 0;
      mem_rd = 0;

      case (state)
        /*
         *  ERR - Error state, unrecoverable.
         */
        ERR:
           err = 1;

        /*
         *  IDLE - 
         */
        IDLE:
          // Did we access the cache last cycle?
          if (cache_accessed) begin
             // Cache was accessed, we are done if there was a hit
             if (cache_hit && cache_valid) begin
                Done = 1;
             end else begin
                // Cache missed, row dirty?
                if (cache_dirty) begin
          end else begin
          end
      endcase
   end   
endmodule // mem_system




// DUMMY LINE FOR REV CONTROL :9:
