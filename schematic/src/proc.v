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

   // Next pc logic
   pc_mux i_pc_mux (
		    // Inputs
		    .pc_inc(pc_inc),
		    .pc_branch(pc_branch),
		    // Outputs
		    .next_pc(next_pc)
		    );
   


endmodule // proc
