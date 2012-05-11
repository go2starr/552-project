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
   parameter READ_0 = 2;        // (Read, Ready) = (0,x)
   parameter READ_1 = 3;        // (1,x)
   parameter READ_2 = 4;        // (2,0)
   parameter READ_3 = 5;        // (3,1)
   parameter READ_4 = 6;        // (x,2)
   parameter READ_5 = 7;        // (x,3)
   parameter WRITE_MEM = 8;        // Writing to memory
   parameter RETRY = 9;            // Re-attempting a read/write operation after miss
   
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

   reg               victim;    // Actual victim cache on replacement
   reg               next_victim;
   
   reg               victimway; // Victim cache on replacement using pseudo-random
   reg               next_victimway;

   reg [15:0]        retry_addr; // Address gets wiped out in retry
   reg [15:0]        next_retry_addr;

   reg [15:0]        retry_din; // Din gets wiped on retry
   reg [15:0]        next_retry_din;
   
   reg               retry_wr;  // Wr gets wiped in retry
   reg               next_retry_wr;

   /****************************************
    *  Outputs
    * ****************************************/
   reg [15:0]        next_data_out;
   reg               next_done;
   reg               next_stall;
   reg               next_cache_hit;
   reg               next_err;
   
   always @(posedge clk) begin
      if (rst) begin
         // State
         state <= IDLE;
         count <= 0;
         victim <= 0;
         victimway <= 0;
         retry_addr <= 0;
         retry_wr <= 0;
         retry_din <= 0;
         
         // Outputs
         DataOut <= 0;
         Done <= 0;
         Stall <= 0;
         CacheHit <= 0;
         err <= 0;
         
      end else begin
         // State
         state <= next_state;
         count <= next_count;
         victim <= next_victim;
         victimway <= next_victimway;
         retry_addr <= next_retry_addr;
         retry_wr <= next_retry_wr;
         retry_din <= next_retry_din;

         // Outputs
         DataOut <= next_data_out;
         Done <= next_done;
         Stall <= next_stall;
         CacheHit <= next_cache_hit;
         err <= next_err;
      end
   end
   
   /****************************************
    *   Cache 0
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
   wire          cache_valid_hit;

   // Assigns
   assign cache_tag_in = (state == WRITE_MEM) ? cache_tag_out : 
                         (state == RETRY) ? retry_addr[7:3] :
                         Addr [7:3];
   
   assign cache_index  = (state == RETRY) ? retry_addr[15:8] :
                         Addr [15:8];
   assign cache_valid_hit = cache_hit && cache_valid;

   /****************************************
    *   Cache 1
    * ****************************************/
   // Inputs
   reg           cache_enable_1;
   
   // Outputs
   wire [4:0]    cache_tag_out_1;
   wire [15:0]   cache_data_out_1;   
   wire          cache_hit_1, cache_dirty_1, cache_valid_1, cache_err_1;
   wire          cache_valid_hit_1;

   assign cache_valid_hit_1 = cache_hit && cache_valid;

   /****************************************
    *   Both Caches
    *****************************************/
   assign either_cache_valid = cache_valid_hit | cache_valid_hit_1;
   assign both_cache_dirty = cache_dirty & cache_dirty_1;

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

   // Wires
   wire          write_mem_addr;
   wire          read_mem_addr;

   /********************************************************************************
    *  Modules
    * ********************************************************************************/
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

   cache #(0 + mem_type) c1(
	                    // Inputs
                            .enable(cache_enable_1),
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
	                    .tag_out(cache_tag_out_1), 
	                    .data_out(cache_data_out_1), 
	                    .hit(cache_hit_1), 
	                    .dirty(cache_dirty_1), 
	                    .valid(cache_valid_1), 
	                    .err(cache_err_1)
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

      // Outputs
      Stall = 1;
      Done = 0;
      err = 0;
      DataOut = DataOut;
      CacheHit = 0;
      

      // State
      next_victim = victim;
      next_count = 0;
      
      // Cache 0
      cache_enable = 0;

      // Cache 1
      cache_enable_1 = 0;
      
      // Caches
      cache_data_in = 0;
      cache_comp = 0;
      cache_write = 0;
      cache_valid_in = 0;

      // Memory
      mem_addr = 0;
      mem_data_in = 0;
      mem_wr = 0;
      mem_rd = 0;
      
      case(state)
        /*
         *  ERR - In the error state; stay here.
         */
        ERR: begin
           next_state = ERR;
           err = 1;
        end
        
        
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
        IDLE: begin
           // Cache control
           cache_enable = 1;
           cache_enable_1 = 1;
           cache_data_in = DataIn;
           cache_comp = 1;      
           cache_write = Wr;
           cache_valid_in = Wr;
           cache_offset = Addr[3:0];
           
           // Did the access hit?
           if (either_cache_valid) begin
              // Stay in idle, the operation completed
              next_state = IDLE;

              // Outputs
              Stall = 0;
              Done = 1;

              if (cache_valid_hit)
                DataOut = cache_data_out;
              else 
                DataOut = cache_data_out_1;
              CacheHit = 1;
              
           end else begin
              // Cache missed
              // is the row dirty?
              if (both_cache_dirty) begin
                 // Choose a vitcim cache
                 if (cache_valid && !cache_valid_1)
                   next_victim = 1;
                 else if (!cache_valid && cache_valid)
                   next_victim = 0;
                 else if (!cache_valid && !cache_valid_1)
                   next_victim = 0;
                 else
                   next_victim = victimway;

                 // Cache is dirty, need to write back to mem
                 next_state = WRITE_MEM;
              end else begin
                 // One cache is not dirty, safe to read block into cache
                 if (cache_dirty)
                   next_victim = 1;
                 else
                   next_victim = 0;
                 next_state = READ_0;
              end
           end
        end

        /*
         *  READ_0 - In the READ_0 we begin reading a block of data from memory.
         *  Reads take two cycles, but can be done in parallel.  We start reading
         *  from offset 0 here, and in 2 cycles install to cache.
         */
        READ_0: begin
           next_state = READ_1;
           
           // Mem control
           mem_addr = { Addr[15:3], 2'd0, 1'b0 };
           mem_rd = 1;
           
        end

        /*
         *  READ_1 - Reading from 0, no data available
         * 
         */
        READ_1: begin
          next_state = READ_2;

           // Mem control
           mem_addr = { Addr[15:3], 2'd1, 1'b0 };           
           mem_rd = 1;

        end
        
        /*
         *  READ_2 
         */
        READ_2: begin
           next_state = READ_3;
           
           // Mem control
           mem_addr = { Addr[15:3], 2'd2, 1'b0 };                      
           mem_rd = 1;

           // Cache control
           if (!victim)
             cache_enable = 1;
           else
             cache_enable_1 = 1;
           cache_write = 1;
           cache_offset = {2'd0, 1'b0};
           cache_comp = 0;
           cache_data_in = mem_data_out;
           cache_valid_in = 1;
           
        end
        
        /*
         *  READ_3
         */
        READ_3: begin
          next_state = READ_4;

           // Mem control
           mem_addr = { Addr[15:3], 2'd3, 1'b0 };                      
           mem_rd = 1;

           // Cache control
           if (!victim)
             cache_enable = 1;
           else
             cache_enable_1 = 1;
           
           cache_write = 1;
           cache_offset = {2'd1, 1'b0};
           cache_comp = 0;
           cache_data_in = mem_data_out;           
           cache_valid_in = 1;           
        end

        /*
         *  READ_4
         */
        READ_4: begin
          next_state = READ_5;

           // Cache control
           if (!victim)
             cache_enable = 1;
           else
             cache_enable_1 = 1;
           
           cache_write = 1;
           cache_offset = {2'd2, 1'b0};
           cache_comp = 0;
           cache_data_in = mem_data_out;           
           cache_valid_in = 1;           
        end

        /*
         *  READ_5 - Done reading from memory and installing to cache, retry
         *  the original memory access.
         */
        READ_5: begin
           next_state = RETRY;
           next_retry_addr = Addr;
           next_retry_wr = Wr;
           next_retry_din = DataIn;
           
           // Cache control
           if (!victim)
             cache_enable = 1;
           else
             cache_enable_1 = 1;
           
           cache_write = 1;
           cache_offset = {2'd3, 1'b0};
           cache_comp = 0;
           cache_data_in = mem_data_out;           
           cache_valid_in = 1;           
        end
        /*
         *  WRITE_MEM - In the write_mem stage, a block in the cache is being
         *  written to memory.
         */
        WRITE_MEM: begin
           // Mem control
           mem_wr = 1;
           mem_rd = 0;
           mem_addr = { cache_index, cache_tag_out, count, 1'b0};
           mem_data_in = cache_data_out;

           // Cache control
           if (!victim)
             cache_enable = 1;
           else
             cache_enable_1 = 1;
           
           cache_offset = {count, 1'b0};
           cache_comp = 0;
           cache_write = 0;
           cache_valid_in = 0;
           
           // Last word?
           if (count == 3) begin
              // The block has been written to memory from the cache - read in
              // the new block
              next_state = READ_0;
              next_count = 0;
           end else begin
              // There are more words to write
              next_state = WRITE_MEM;
              next_count = count + 1;
           end
        end
        
        /*
         *  RETRY - In the retry state, a cache miss had occurred before during
         *  this read/write cycle, but the correct block has been installed to
         *  the cache since then.  A cache hit will now occur, and we will return
         *  to IDLE.
         */
        RETRY: begin
           next_state = IDLE;
           
           // Cache Control
           cache_enable = 1;
           cache_enable_1 = 1;           

           cache_data_in = retry_din;
           cache_comp = 1;
           cache_write = retry_wr;
           cache_valid_in = retry_wr;
           cache_offset = retry_addr[3:0];

           // Outputs
           Stall = 0;
           Done = 1;
           if (cache_valid_hit)
             DataOut = cache_data_out;
           else 
             DataOut = cache_data_out_1;           
           CacheHit = 0;
        end
      endcase
   end
endmodule // mem_system




// DUMMY LINE FOR REV CONTROL :9:
