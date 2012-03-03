/* add4.v - 4-bit adder (CLA) */
module add4(
            A,                  // Input A
            B,                  // Input B
            CI,                 // Carryin
            Sum,                // Sum
            CO,                 // Carryout
            Pgroup,             // Propagate
            Ggroup              // Generate bit
            );
   // Inputs
   input [3:0] A, B;
   input       CI;

   // Outputs
   output [3:0] Sum;
   output       CO, Ggroup, Pgroup;

   // Wires
   wire [3:0]   G, P;
   wire [4:1]   C;

   // Connections
   add1 a0(A[0], B[0],   CI, Sum[0], P[0], G[0]);
   add1 a1(A[1], B[1], C[1], Sum[1], P[1], G[1]);
   add1 a2(A[2], B[2], C[2], Sum[2], P[2], G[2]);
   add1 a3(A[3], B[3], C[3], Sum[3], P[3], G[3]);   
   
   cla_logic clo (CI, P, G, C, Ggroup, Pgroup);

   assign CO = C[4];

endmodule // add4
