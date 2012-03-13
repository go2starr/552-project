/* mux16_2_1.v - 16-bit 2:1 multiplexer */
module mux16_2_1(
                 in1,           // input 1
                 in2,           // input 2
                 s,             // select
                 out            // output
                 );

   // Inputs
   input [15:0] in1, in2;
   input        s;

   // Outputs
   output [15:0] out;

   // Logic
   assign out = s ? in2 : in1;
   
endmodule // mux16_2_1

   
