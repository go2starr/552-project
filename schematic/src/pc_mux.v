/* pc_mux.v - Mux to choose the next pc */
module pc_mux(
	      // Inputs
	      pc_inc,
	      pc_branch,
	      // Outputs
	      next_pc
	      );
   // Inputs
   input [15:0] pc_inc, pc_branch;

   // Outputs
   output [15:0] next_pc;
   
endmodule // pc_mux
