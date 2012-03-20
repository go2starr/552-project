// 2:1 MUX
module mux2_1(InA,InB,S,Out);
   // define inputs and outputs
   input InA,InB,S;
   output Out;
   // wires local to the module
   wire   a1,a2,n1;
   // logic starts
   not1 n5(S,n1);
   nand2 n4(InA,n1,a1);
   nand2 n2(InB,S,a2);
   nand2 n3(a1,a2,out);
endmodule
// end of module
