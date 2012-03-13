/* mux2_16.v - 2 to 1, 16-bit mux */
module mux2_16(
	       // Inputs
	       in_a,
	       in_b,
	       // Outputs
	       out
	       );
   // Inputs
   input in_a, in_b;

   // Outputs
   output [15:0] out;

endmodule // mux2_16
