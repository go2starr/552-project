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


   /********************************************************************************
    *   Wires
    * ********************************************************************************/

   /****************************************
    *  Internal
    * ****************************************/
   reg [3:0]         state;
   reg [3:0]         next_state;
   
   reg [1:0]         count;
   reg [1:0]         next_count;

   reg               wrmiss;

   always @(posedge clk) begin
      if (rst) begin
         state <= IDLE;
         count <= 0;
         wrmiss <= 0;
      end else begin
         state <= next_state;
         count <= next_count;
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
//   assign cache_offset = (state == INSTALL_CACHE) ? count : {1'b0, Addr[2:1]};
//   assign CacheHit     = cache_hit && cache_valid // Cache ok
//                         && (state == DONE); // Valid state

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
   //next state logic
   //
   always@(*)begin
      case(state)
        IDLE   : begin
           next_state = (Rd == 1 && Wr == 1) ? ERR : 
                        (Rd == 1 && Wr == 0) ? COMPRD :
                        (Rd == 0 && Wr == 1) ? COMPWR :
                        (Rd == 0 && Wr == 0) ? IDLE : ERR;
	end

        COMPRD : begin
           next_state = (cache_hit == 0 && cache_dirty == 0) ? MEMRD : 
                        (cache_hit == 1 && cache_valid == 0) ? MEMRD :
                        (cache_hit == 1 && cache_valid == 1) ? DONE :
                        (cache_hit == 0 && cache_dirty == 1 && cache_valid == 0) ? MEMRD :
	                (cache_hit == 0 && cache_dirty == 1 && cache_valid == 1) ? PREWBMEM :
                        ERR;
	end

        MEMRD  : begin
           next_state = (mem_stall == 0) ? WAITSTATE : MEMRD;
        end

        WAITSTATE : begin
           next_state = INSTALL_CACHE;
	end

        INSTALL_CACHE : begin
           next_state = (Rd == 1 && count == 2'b11) ? DONE :
                        (Wr == 1 && count == 2'b11) ? WRMISSDONE :
                        (count != 2'b11) ? MEMRD :
                        ERR;
	end

        DONE   : begin
           next_state = IDLE;
	end

        COMPWR : begin
           next_state = (cache_hit == 1 && cache_valid == 1) ? DONE :
                        (cache_hit == 1 && cache_valid == 0) ? MEMRD :                                          (cache_hit == 0 && cache_dirty == 1) ? WBMEM : 
                        (cache_hit == 0 && cache_dirty == 0) ? MEMRD : 
                        ERR;
        end

        WBMEM  : begin
           next_state = (count != 2'b11 | mem_stall == 1) ? WBMEM :
                        (count == 2'b11) ? MEMRD :
                        ERR;
	end

        PREWBMEM : begin
	   next_state = (count == 2'b00) ? WBMEM : ERR;
	end

        WRMISSDONE : begin
	   next_state = COMPWR;
	end

        ERR : begin
           next_state = ERR;
	end
	
        default: next_state = ERR;

      endcase
   end

   // Output control
   //
   // Outputs:
   //   Cache:
   //     - enable
   //     - data_in
   //     - comp
   //     - write
   //     - valid_in
   //   Mem:
   //     - addr
   //     - data_in
   //     - wr
   //     - rd
   //   Mem_System:
   //     - next_count
   //     - err
   
   always @(*) begin
      // Defaults
      cache_enable = 0;
      cache_data_in = 16'b0;
      cache_comp = 1'b0;
      cache_write = 0;
      cache_valid_in = 0;

      mem_addr = 16'b0;
      mem_data_in = 16'b0;
      mem_wr = 0;
      mem_rd = 0;
      Stall = 1;
      Done = 0;
      next_count = count;
      err = 0;
      
      case (state)
        /*
         *  ERR - Error state, unrecoverable.  err = 1
         */
        ERR: begin
           err = 1;
        end

        /*
         *  IDLE - No actions yet
         */
        IDLE: begin
           wrmiss = 0;

           Stall = 0;
           
           if (Rd) begin
              cache_enable = 1;    // Enable
              cache_comp = 1;      // Compare tags
              cache_write = 0;     // Read
           end

           if (Wr) begin
              cache_enable = 1;    // Enable
              cache_comp = 1;      // Compare tags
              cache_write = 1;     // Read
              cache_valid_in = 1;  // Valid data
              cache_data_in = DataIn;
           end

           cache_offset = Addr[2:0];
           CacheHit = 0;
        end

        /*
         *  COMPRD - This state occurs when proc. executes a load instruction.
         *  The cache checks the tag_in at the specified index, and compares 
         *  with the stored value (because comp = 1).
         * 
         *  If a hit occurs, 'data_out' contains the data, and 'valid' incidates
         *  if the data is valid.
         * 
         *  If a miss occurs, 'valid' output will indicate whether the block
         *  of that line is valid.  The 'dirty' bit indicates if the cache
         *  has been modified.
         */
        COMPRD: begin
           cache_enable = cache_hit && cache_valid;

           if (cache_hit && cache_valid) begin
              DataOut = cache_data_out;
              CacheHit = 1;
           end
        end

        /*
         *  MEMRD - This state occurs on a miss while reading and after the
         *  data line we are reading from is safe to write to (i.e. any dirty
         *  data words have been written to memory).
         * 
         *  While in this state, a counter is used to count the number of words
         *  read from memory into the cache.  This counter is incremented in 
         *  INSTALL_CACHE on reads, and WBMEM on writes.
         */
        MEMRD: begin
           mem_addr = { cache_index, cache_tag_in, 3'b0 } + (count * 2); // Block base + word offset
           mem_rd = ~mem_stall;
        end

        /*
         *  WAITSTATE - State entered while reading from mem
         */
        WAITSTATE: begin
        end

        /*
         *  INSTALL_CACHE - The 'data_out' from memory is valid from the last read
         *  request and needs to be written into the cache @count.
         */
        INSTALL_CACHE: begin
           // Data from memory 
           cache_enable = 1;
           cache_data_in = mem_data_out;
           cache_comp = 0;
           cache_write = 1;
           cache_valid_in = 1;
           cache_offset = { count, 1'b0 };
           
           next_count = count + 1; // finished a read

           if (count == Addr[2:1])
             DataOut = mem_data_out;
        end

        /*
         *  DONE - At this point, any data being read will be valid from the cache;
         *  send it out.
         */
        DONE: begin
	   Done = 1;  //~cache_hit;
           cache_enable = 1;
        end

        /*
         *  COMPWR - This state occurs on first write attempt to the cache.  If there
         *  is a hit, the data is written.
         * 
         *  If there is a miss, and the cache is not dirty, the block will be read.
         *  If there is a miss, and the cache is dirty, the block will first be written
         *  back to memory.
         */
        COMPWR: begin
           cache_enable = cache_hit && cache_valid;    // Enable

           if (cache_hit && cache_valid && !wrmiss)
             CacheHit = 1;
        end

        /*
         *  WBMEM - "Write back to memory."  In this state we are writing a block of
         *  data back to memory. These writes are back-to-back, and so count is 
         *  incremented at each cycle
         */
        WBMEM: begin
           mem_addr = { cache_index, cache_tag_out, 3'b0 } + (count * 2); // Block base + word offset
           mem_wr = 1;                                             // Write
           next_count = count + 1;                                 // Increment
        end

        /*
         *  PREWBMEM - "Pre- write back to memory."  In this state, we are preparing to
         *  write data that is currently in the cache back to memory.
         */
        PREWBMEM: begin
           // Defaults
        end

        /*
         *  WRMISSDONE - "Write miss done."  
         */
        WRMISSDONE: begin
           cache_enable = 1;    // Enable
           cache_comp = 1;      // Compare tags
           cache_write = 1;     // Read
           cache_valid_in = 1;  // Valid data
           cache_data_in = DataIn;

           wrmiss = 1;
        end
      endcase
   end   
endmodule // mem_system




// DUMMY LINE FOR REV CONTROL :9:
