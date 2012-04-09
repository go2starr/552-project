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
   output Done;
   output Stall;
   output CacheHit;
   output err;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter mem_type = 0;
   
   // your code here
	wire dirty, valid, comp, write, valid_in, enable;
	wire [4:0] tag_out, tag_in;
	wire [7:0] index;
	wire [2:0] offset;

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
   
endmodule // mem_system

   


// DUMMY LINE FOR REV CONTROL :9:
