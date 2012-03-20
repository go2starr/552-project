module ALU (
            A,                  // Data-in A
            B,                  // Data-in B
            Cin,                // Carry-in for LSB of adder
            Op,                 // Op code
            sign,               // Signed or unsigned input
            Out,                // Result
            OFL,                // High if overflow
            Zero                // Result is exactly zero
            );

   // Inputs
   input [15:0] A, B;
   input        Cin;
   input [4:0]  Op;
   input        sign;

   // Outputs
   output reg [15:0] Out;
   output            OFL, Zero;

   // Parameters
   parameter OP_ROL = 0;
   parameter OP_SLL = 1;
   parameter OP_ROR = 2;
   parameter OP_SRA = 3;
   parameter OP_ADD = 4;
   parameter OP_OR  = 5;
   parameter OP_XOR = 6;
   parameter OP_AND = 7;

   // Wires
   wire [15:0]   opA, opB;

   // Wires - shifter
   wire [15:0]   shifter_Out;
   
   // Wires - adder
   wire [15:0]   add_Sum;
   wire          add_CO, add_P, add_G;

   // Wires - sign detection
   wire          OFL_signed, OFL_unsigned;
   
   // Module instantiation
   shift16 shifter (opA, opB[3:0], Op[1:0], shifter_Out);
   add16   adder   (opA, opB, Cin, add_Sum, add_CO, add_G, add_P);

   // Operands
   assign opA = A;
   assign opB = B;

   // Overflow detection
   assign OFL_signed = ( opA[15] &  opB[15] & ~add_Sum[15]) |  // two negatives add to positive
                       (~opA[15] & ~opB[15] &  add_Sum[15]);   // two positives add to negative
   assign OFL_unsigned = add_CO;
   assign OFL = sign ? OFL_signed : OFL_unsigned;

   // Zero detection
   assign Zero = (Out == 0) &&
                 (Op == OP_ADD); // Not logical operations

   // Opcode decode
   always @(*) begin
      case (Op)
        // Shifter
        OP_ROL: Out = shifter_Out;
        OP_SLL: Out = shifter_Out;
        OP_ROR: Out = shifter_Out;
        OP_SRA: Out = shifter_Out;
        // Adder
        OP_ADD: Out = add_Sum;
        // Logical
        OP_OR:  Out = opA | opB;
        OP_XOR: Out = opA ^ opB;
        OP_AND: Out = opA & opB;

        default:
          Out = 16'hbadadd;
      endcase
   end
   
endmodule // ALU

