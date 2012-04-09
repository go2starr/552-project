/* add16.v - 16-bit adder (CLA) */
module add16(
            A,                  // Input A
            B,                  // Input B
            CI,                 // Carryin
            Sum,                // Sum
            CO,                 // Carryout
            Ggroup,             // Generate bit
            Pgroup              // Propagate
            );
   // Inputs
   input [15:0] A, B;
   input       CI;

   // Outputs
   output [15:0] Sum;
   output       CO, Ggroup, Pgroup;

   // Wires
   wire [3:0]   G, P;
   wire [4:1]   C;
   wire [3:0]   COX;             // Don't care

   // Connections
   add4 a0 (A[3:0],   B[3:0],     CI, Sum[3:0],   COX[0], P[0], G[0]);
   add4 a1 (A[7:4],   B[7:4],   C[1], Sum[7:4],   COX[1], P[1], G[1]);
   add4 a2 (A[11:8],  B[11:8],  C[2], Sum[11:8],  COX[2], P[2], G[2]);
   add4 a3 (A[15:12], B[15:12], C[3], Sum[15:12], COX[3], P[3], G[3]);   
   
   cla_logic clo (CI, P, G, C, Ggroup, Pgroup);

   assign CO = C[4];

endmodule // add4
