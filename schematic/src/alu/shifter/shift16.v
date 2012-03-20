/* shift16.v - 16-bit shifter with 4 operands */
module shift16(
               In,              // input value to shift
               Cnt,             // number of bits to shift
               Op,              // shifter operand
               Out              // output
               );
   // Inputs
   input [15:0] In;
   input [3:0]  Cnt;
   input [1:0]  Op;

   // Outputs
   output [15:0] Out;

   // Wires
   wire [15:0] l3, sl3,         // 8-shift
               l2, sl2,         // 4-shift
               l1, sl1,         // 2-shift
               l0, sl0;         // 1-shift

   // Shifter outputs
   shift8 s8 (l3, Op, sl3);
   shift4 s4 (l2, Op, sl2);
   shift2 s2 (l1, Op, sl1);
   shift1 s1 (l0, Op, sl0);

   // Connections
   assign l3 = In;

   mux16_2_1 m3 (l3, sl3, Cnt[3], l2);
   mux16_2_1 m2 (l2, sl2, Cnt[2], l1);
   mux16_2_1 m1 (l1, sl1, Cnt[1], l0);
   mux16_2_1 m0 (l0, sl0, Cnt[0], Out);   
   
endmodule // shift16

   
