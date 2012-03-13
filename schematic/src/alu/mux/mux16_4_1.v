/* mux16_4_1.v - 16-bit 4:1 mux */
module mux16_4_1(
		 // Inputs
		 in_1, in_2, in_3, in_4,
		 s,
		 // Outputs
		 out
		 );
   // Inputs
   input [15:0] in_1, in_2, in_3, in_4,
   input [1:0]  s

   // Outputs
   output [15:0] out;
   
   
endmodule // mux16_4_1

