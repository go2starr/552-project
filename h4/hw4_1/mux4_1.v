// 4:1 MUX using 2:1 MUX

module mux4_1 (InA,InB,InC,InD,S,Out);

// define inputs and outputs

input InA,InB,InC,InD;

input [1:0] S;

output Out;

// wires local to module

wire s1,s2;

// logic starts

mux2_1 m1 (.InA(InA),.InB(InB),.S(S[0]),.Out(s1));

mux2_1 m2 (.InA(InC),.InB(InD),.S(S[0]),.Out(s2));

mux2_1 m3 (.InA(s1),.InB(s2),.S(S[1]),.Out(out));

endmodule

// end of module
