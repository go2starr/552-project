// Code for 16-bit barrel shifter
module shift_16 (In, Cnt, Op, Out);
// define inputs and outputs
input [15:0] In;
input [3:0] Cnt;
input [1:0] Op;
output [15:0] Out;// wires local to the module
wire [15:0] S0,S1,S2;
wire [15:0] L0,L1,L2,L3;
// level 1 shift
mux2_1 M1 [13:0](.InA(In[13:0]), .InB(In[15:2]), .out(L0[14:1]), .S(Op[1]));
mux4_1 n5 (.out(L0[0]), .InA(In[15]), .InB(1'b0), .InC(In[1]), .InD(In[1]), .S(Op));
mux4_1 n6 (.out(L0[15]), .InA(In[14]), .InB(In[14]), .InC(In[0]), .InD(In[15]), .S(Op));
stage s1 (.a(In), .b(L0), .sel(Cnt[0]), .out(S0));
//level 2 shift
mux2_1 M2 [11:0](.InA(S0[11:0]), .InB(S0[15:4]), .out(L1[13:2]), .S(Op[1]));
mux4_1 N2 [3:0] (.out({L1[15],L1[14],L1[1],L1[0]}), .InA({S0[13:12],S0[15:14]}), .InB({S0[13:
12],2'b00}), .InC({S0[1:0],S0[3:2]}), .InD({S0[15],S0[15],S0[3:2]}), .S(Op));
stage s2 (.a(S0), .b(L1), .sel(Cnt[1]), .out(S1));
//level 4 shift
mux2_1 M3 [7:0] (.InA(S1[7:0]), .InB(S1[15:8]), .out(L2[11:4]), .S(Op[1]));
mux4_1 N3 [7:0] (.out({L2[15:12],L2[3:0]}), .InA({S1[11:8],S1[15:12]}), .InB({S1[11:8],
4'b0000}), .InC({S1[3:0],S1[7:4]}), .InD({{4{S1[15]}},S1[7:4]}), .S(Op));
stage s3 (.a(S1), .b(L2), .sel(Cnt[2]), .out(S2));
//level 8 shift
mux4_1 N4 [15:0](.out(L3), .InA({S2[7:0],S2[15:8]}), .InB({S2[7:0],8'd0}), .InC({S2[7:0],S2[
15:8]}), .InD({{8{S2[15]}},S2[15:8]}), .S(Op));
stage s4 (.a(S2), .b(L3), .sel(Cnt[3]), .out(Out));
endmodule
// end of module