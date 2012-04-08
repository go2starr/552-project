/* add1.v - 1-bit adder */
module add1(
            A,
            B,
            CI,
            Sum,
            P,
            G
            );
   // Inputs
   input A, B, CI;
   
   // Outputs
   output Sum, G, P;

   assign Sum = A ^ B ^ CI;
   assign G   = A & B;
   assign P   = A | B;
endmodule // fa

   
