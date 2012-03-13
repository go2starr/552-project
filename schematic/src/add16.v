/* add16.v -  Two-input, 16-bit adder */
module add16 (
	      // Inputs
	      in_a,
	      in_b,
	      // Outputs
	      out
	      );
   // Inputs
   input [15:0] in_a, in_b;

   // Outputs
   output [15:0] out;
   
endmodule // add16
