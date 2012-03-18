// 2 to 1 MUX using NAND, NOR, and NOT gates
module mux2_1 (InA, InB, S, Out);
input InA;
input InB;
input S;
output Out;

wire AInt;
wire AIntInv;
wire BInt;
wire BIntInv;
wire norInt;

nand2 n1 (.in1(InA), .in2(~S), .out(AInt));
not1 i1 (.in1(AInt), .out(AIntInv));

nand2 n2 (.in1(InB), .in2(S), .out(BInt));
not1 i2 (.in1(BInt), .out(BIntInv));

nor2 x1 (.in1(AIntInv), .in2(BIntInv), .out(norInt));

not1 i3 (.in1(norInt), .out(Out)); 

endmodule
