// reg64.v - 64-bit register
module reg64(
             // Inputs
             in, rst, clk,
             // Outputs
             out
             );
   // Inputs
   input [63:0] in;
   input        rst;
   input        clk;

   // Outputs
   output [63:0] out;

   // The register
   dff ff[63:0] (.q(out), .d(in), .clk(clk), .rst(rst));
   
endmodule // reg64

         
   
