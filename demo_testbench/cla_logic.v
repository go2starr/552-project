/* cla_logic.v - Routing logic for CLA */
module cla_logic(
                 CI,
                 P,
                 G,
                 C,
                 Ggroup,
                 Pgroup);
   // Inputs
   input CI;
   input [3:0] P, G;
   
   // Outputs
   output [4:1] C;
   output       Ggroup, Pgroup;

   // Connections
   assign C[1] = G[0] | P[0] & CI;
   assign C[2] = G[1] | P[1] & C[1];
   assign C[3] = G[2] | P[2] & C[2];
   assign C[4] = G[3] | P[3] & C[3];

   assign Ggroup = G[3] | P[3]&G[2] | P[3]&P[2]&G[1] | P[3]&P[2]&P[1]&G[0];
   assign Pgroup = P[3]&P[2]&P[1]&P[0];
   
   
endmodule // cla_logic
