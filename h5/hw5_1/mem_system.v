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
   output            Done;
   output            Stall;
   output            CacheHit;
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
   wire [3:0]    state;
   reg [3:0]     next_state;

   wire [1:0]    count;
   reg [1:0]     next_count;

   
   /****************************************
    *   Cache
    * ****************************************/
   // Inputs
   reg           cache_enable;
   wire [4:0]    cache_tag_in;
   wire [7:0]    cache_index;
   wire [2:0]    cache_offset;
   reg [15:0]    cache_data_in;
   reg           cache_comp, cache_write, cache_valid_in;   

   // Outputs
   wire [4:0]    cache_tag_out;
   wire [15:0]   cache_data_out;   
   wire          cache_hit, cache_dirty, cache_valid, cache_err;

   // Assigns
   assign cache_index  = Addr [15:11];
   assign cache_tag_in = Addr [10:3];
   assign cache_offset = (state != INSTALL_CACHE) ? Addr [2:0] : count;

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
           next_state = (Rd == 1 && Wr == 1) ? ERR : (Rd == 1 && Wr ==0) ? COMPRD : (Rd == 0 && Wr == 0) ? IDLE : ERR;
	end
        COMPRD : begin
           next_state = (Rd == 1 && Wr == 0) ? COMPRD : (cache_hit == 0 && cache_dirty == 0) ? MEMRD : (cache_hit == 1 && cache_valid == 1) ? DONE : 
	                (cache_hit == 0 && cache_dirty == 1 && cache_valid == 1) ? PREWBMEM : ERR;
	end
        MEMRD  : begin
           next_state = (mem_stall == 0) ? WAITSTATE : MEMRD;
        end
        WAITSTATE : 
          begin
             next_state = INSTALL_CACHE;
	  end
        INSTALL_CACHE : 
          begin
             next_state = (Rd == 1 && count == 2'b11) ? DONE : (Wr == 1 && count == 2'b11) ? WRMISSDONE : ERR;
	  end
        DONE   : begin
           next_state = IDLE;
	end
        COMPWR : begin
           next_state = (cache_hit == 1) ? DONE : (cache_hit == 0 && cache_dirty == 1) ? WBMEM : (cache_hit == 0 && cache_dirty == 0) ? MEMRD : ERR;
	end
        WBMEM  : begin
           next_state = (count == 2'b11) ? MEMRD : (mem_stall == 1 | count != 2'b11) ? WBMEM : ERR;
	end
        PREWBMEM :
          begin
	     next_state = (count == 2'b00) ? WBMEM : ERR;
	  end
        WRMISSDONE :
          begin
	     next_state = IDLE;
	  end
        ERR :    begin
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
   //     - err
   
   always @(*) begin
      // Defaults
      cache_enable = 0;
      cache_data_in = 16'bx;
      cache_comp = 1'bx;
      cache_write = 0;
      cache_valid_in = 0;

      mem_addr = 16'bx;
      mem_data_in = 16'bx;
      mem_wr = 0;
      mem_rd = 0;

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
           // Defaults
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
           cache_enable = 1;    // Enable
           cache_comp = 1;      // Compare tags
           cache_write = 0;     // Read
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
           mem_addr = { cache_index, cache_tag_in } + (count * 2); // Block base + word offset
           mem_rd = 1;
        end

        /*
         *  WAITSTATE - State entered while reading from mem
         */
        WAITSTATE: begin
           // Defaults
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
           
           next_count = count + 1; // finished a read
           
        end

        /*
         *  DONE - At this point, any data being read will be valid from the cache;
         *  send it out.
         */
        DONE: begin
           DataOut = cache_data_out;
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
           cache_enable = 1;    // Enable
           cache_comp = 1;      // Compare tags
           cache_write = 1;     // Write
        end

        /*
         *  WBMEM - "Write back to memory."  In this state we are writing a block of
         *  data back to memory. These writes are back-to-back, and so count is 
         *  incremented at each cycle
         */
        WBMEM: begin
           mem_addr = { cache_index, cache_tag_out } + (count * 2); // Block base + word offset
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
           // Defaults
        end
      endcase
   end   
endmodule // mem_system




// DUMMY LINE FOR REV CONTROL :9:
