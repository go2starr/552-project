// This module is an array of 16 2:1 MUXes used in shift logic
module stage (a,b,sel,out);
   // define inputs and outputs
   input [15:0]a,b;
   input       sel;
   output [15:0] out;
   // logic starts
   mux2_1 k1 [15:0] (.InA(a), .InB(b), .S(sel), .out(out));
endmodule // stage
// end of module
