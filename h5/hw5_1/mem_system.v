/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
                  // Outputs
                  DataOut, Done, Stall, CacheHit, err, 
                  // Inputs
                  Addr, DataIn, Rd, Wr, createdump, clk, rst
                  );
   
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   
   output [15:0] DataOut;
   output        Done;
   output        Stall;
   output        CacheHit;
   output        err;

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
   
   // wires
   wire          dirty, valid, comp, write, valid_in, enable;
   wire [4:0]    tag_out, tag_in;
   wire [7:0]    index;
   wire [2:0]    offset;

   wire [3:0]    state;
   reg [3:0]     next_state;   

   // assigns
   assign index = Addr [15:11];
   assign tag_in = Addr [10:3];
   assign offset = Addr [2:0];

   // You must pass the mem_type parameter 
   // and createdump inputs to the 
   // cache modules
   cache #(0 + memtype) c0(
	                   // Inputs
                           .enable(enable),
	                   .clk(clk), 
	                   .rst(rst), 
	                   .createdump(createdump),
	                   .tag_in(tag_in), 
	                   .index(index), 
	                   .offset(offset), 
	                   .data_in(DataIn), 
	                   .comp(comp), 
	                   .write(write), 
	                   .valid_in(valid_in), 
	                   // Outputs
	                   .tag_out(tag_out), 
	                   .data_out(DataOut), 
	                   .hit(CacheHit), 
	                   .dirty(dirty), 
	                   .valid(valid), 
	                   .err(err)
	                   );

   four_bank_mem mem (
                      // Inputs
                      .clk(clk),
                      .rst(rst),
                      .createdump(createdump),
                      .addr(Addr),
                      .data_in(DataIn),
                      .wr(Wr),
                      .rd(Rd),
                      // Outputs
                      .data_out(DataOut),
                      .stall(Stall),
                      .busy(1'b1),
                      .err(1'b0)
                      );
//next state logic
//
always@(*)begin
   case(state)
   IDLE   : begin
            next_state = (Rd == 1 && Wr == 1) ? ERR : (Rd == 1 && Wr ==0) ? COMPRD : IDLE;
	    end
   COMPRD : begin
            next_state = (Rd == 1 && Wr == 0) ? COMPRD : (cache_hit == 0 && dirty == 0) ? MEMRD : (cache_hit == 1 && valid == 1) ? DONE : 
	                 (cache_hit == 0 && dirty == 1 && valid == 1) ? PREWBMEM : ERR;
	    end
   MEMRD  : begin
            next_state = (mem_stall == 0) ? WAITSTATE : MEMRD;
            end
   WAITSTATE : begin
            next_state = WAITSTATE;





















end
endcase
   case (
   
   
endmodule // mem_system




// DUMMY LINE FOR REV CONTROL :9:
