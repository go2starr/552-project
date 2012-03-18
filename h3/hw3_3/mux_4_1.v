module mux_4_1 (InA, InB, InC, InD, S, Out);
input InA;
input InB;
input InC;
input InD;
input [1:0] S;
output Out;

wire m1Out;
wire m2Out;

mux_2_1 m1 (.InA(InA), .InB(InC), .S(S[1]), .Out(m1Out));
mux_2_1 m2 (.InA(InB), .InB(InD), .S(S[1]), .Out(m2Out));
mux_2_1 m3 (.InA(m1Out), .InB(m2Out), .S(S[0]), .Out(Out));

endmodule