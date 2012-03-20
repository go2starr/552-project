// Code for 8:1 MUX

module mux8_1(InA, InB, InC, InD, InE, InF, InG, InH, S, Out);

// define module inputs and outputs

input InA;

input InB;

input InC;

input InD;

input InE;

input InF;

input InG;

input InH;

input [2:0] S;

output Out;

// wires that are local to the module

wire result1;

wire result2;// Build a 8:1 MUX using two 4:1 MUXes and one 2:1 MUX designed in HW1

mux4_1 mux1(.InA(InA), .InB(InB), .InC(InC), .InD(InD), .S(S[1:0]), .Out(result1

));

mux4_1 mux2(.InA(InE), .InB(InF), .InC(InG), .InD(InH), .S(S[1:0]), .Out(

result2));

mux2_1 mux3(.InA(result1), .InB(result2), .S(S[2]), .Out(Out));

endmodule

// end of module
