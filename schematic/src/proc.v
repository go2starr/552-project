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
   wire [15:0] pc, pc_inc, pc_branch, next_pc; // Next pc logic
   wire [15:0] instr; // Instruction read from instruction memory

   // PC
   register pc_reg(.q(pc), 
                   .d(next_pc), 
                   .clk(clk),
                   .rst(rst),
                   .we(1'b1));

   // Next-pc logic
   assign next_pc = pc + 2;

   // Instruction memory
   memory2c instr_mem (
   		       // Inputs
		       .data_in (16'b0),
		       .addr (pc),
		       .enable (1'b1),
		       .wr(1'b0),
		       .createdump(1'b0),	// TODO change to correct value
		       .clk (clk),
		       .rst(rst),
		       // Outputs
		       .data_out (instr)
		       );






   /********************************************************************************
    *
    *********************************************************************************/
   assign err = 0;
endmodule // proc
