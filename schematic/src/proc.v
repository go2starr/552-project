module proc(
	    // Inputs
	    clk,
	    rst,
	    // Outputs
	    err
	    );
   // Inputs
   input clk;
   input rst;

   // Outputs
   output err;

   
   /********************************************************************************
    *  Datapath
    *********************************************************************************/
   // Wires
   wire [15:0] pc_inc, pc_branch, next_pc; // Next pc logic
   wire [15:0] instr; // Instruction read from instruction memory
	
   // Next pc logic
   pc_mux i_pc_mux (
		    // Inputs
		    .pc_inc(pc_inc),
		    .pc_branch(pc_branch),
		    // Outputs
		    .next_pc(next_pc)
		    );
   
   memory2c instr_mem (
   		       // Inputs
		       .data_in (16'b0),
		       .addr (next_pc),
		       .enable (1'b1),
		       .wr(1'b0),
		       .createdump(1'b0),	// TODO change to correct value
		       .clk (clk),
		       .rst(rst),
		       // Outputs
		       .data_out (instr)
		       );


endmodule // proc
