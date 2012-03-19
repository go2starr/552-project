// Code for 3 to 8 decoder

module decode3_8 (sel, Out);

// define module inputs and outputs

input [2:0] sel;

output [7:0] Out;

// wires that are local to the module
wire [2:0] nsel;

// structural design of a 3 to 8 decoder

not1 nottedsel[2:0] (.in1(sel), .out(nsel[2:0]));

nor3 ng0 (.in1(sel[0]), .in2(sel[1]), .in3(sel[2]), .out(Out[0]));

nor3 ng1 (.in1(nsel[0]), .in2(sel[1]), .in3(sel[2]), .out(Out[1]));

nor3 ng2 (.in1(sel[0]), .in2(nsel[1]), .in3(sel[2]), .out(Out[2]));

nor3 ng3 (.in1(nsel[0]), .in2(nsel[1]), .in3(sel[2]), .out(Out[3]));

nor3 ng4 (.in1(sel[0]), .in2(sel[1]), .in3(nsel[2]), .out(Out[4]));

nor3 ng5 (.in1(nsel[0]), .in2(sel[1]), .in3(nsel[2]), .out(Out[5]));

nor3 ng6 (.in1(sel[0]), .in2(nsel[1]), .in3(nsel[2]), .out(Out[6]));

nor3 ng7 (.in1(nsel[0]), .in2(nsel[1]), .in3(nsel[2]), .out(Out[7]));

endmodule

// end of module
