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
	parameter ADD   = 0;
	parameter SUB   = 1;
	parameter OR    = 2;
	parameter AND   = 3;
	parameter ROL   = 4;
	parameter SLL   = 5;
	parameter ROR   = 6;
	parameter SRA   = 7;
	parameter ST    = 8;
	parameter LD    = 9;
	parameter STU   = 10;
	parameter BTR   = 11;
	parameter SEQ   = 12;
	parameter SLT   = 13;
	parameter SLE   = 14;
	parameter SCO   = 15;
	parameter BEQZ  = 16;
	parameter BNEZ  = 17;
	parameter BLTZ  = 18;
	parameter LBI   = 19;
	parameter SLBI  = 20;
	parameter JINST = 21;
	parameter JAL   = 22;
	parameter JR    = 23;
	parameter JALR  = 24;
	parameter RET   = 25;
	parameter SIIC  = 26;
	parameter RTI   = 27;
	parameter NOP   = 28;
	parameter HALT  = 29;
	
   // Wires
   wire [15:0]   opA;
	reg  [15:0]   opB;

   // Wires - shifter
   wire [15:0]   shifter_Out;
   reg [1:0] shifter_op;
   // Wires - adder
   wire [15:0]   add_Sum;
   wire          add_CO, add_P, add_G;

   // Wires - sign detection
   wire          OFL_signed, OFL_unsigned;
   
   // Module instantiation
   shift16 shifter (opA, opB[3:0], shifter_op, shifter_Out); 
   add16   adder   (opA, opB, Cin, add_Sum, add_CO, add_G, add_P);

   // Operands
   assign opA = A;
   assign opB = ((Op == SUB) ? ~B : B);

   // Overflow detection
   assign OFL_signed = ( opA[15] &  opB[15] & ~add_Sum[15]) |  // two negatives add to positive
                       (~opA[15] & ~opB[15] &  add_Sum[15]);   // two positives add to negative
   assign OFL_unsigned = add_CO;
   assign OFL = sign ? OFL_signed : OFL_unsigned;

   // Zero detection
   assign Zero = (Out == 0) &&
                 (Op == OP_ADD); // Not logical operations

	
   // Opcode decode   // TODO finish filling in operations
   always @(Op) begin
      case (Op)
      ADD   : Out = add_Sum;
      SUB   : Out = add_Sum;
      ROR   : begin
					shifter_op = 2'b10;
					Out = shifter_Out;
				  end	
      SRA   : begin
					shifter_op = 2'b11;
					Out = shifter_Out;
				  end
		ROL   : begin
					shifter_op = 2'b00;
					Out = shifter_Out;
				  end
	 	SLL   : begin
					shifter_op = 2'b01;
					Out = shifter_Out;
				  end
		OR    : Out = opA | opB;
      AND   : Out = opA & opB;
		LD	   : Out = add_Sum;
		ST    : Out = add_Sum; 
		STU   : Out = add_Sum;
		BTR   : Out = 16'b0;			// TODO
		SEQ   : Out = (opA == opB) ? 16'h0001 : 16'h000i0;
		SLT   : Out = (opA < opB)  ? 16'h0001 : 16'h0000;
		SLE   : Out = (opA <= opB) ? 16'h0001 : 16'h0000; 
		SCO   : Out = 16'b0;			// TODO
		BEQZ  : Out = OpB;	// Outputs immediate value to be added to 2 + PC if OpA == 0
		BNEZ  : Out = OpB;	// Outputs immediate value to be added to 2 + PC if OpA != 0
		BLTZ  : Out = OpB;	// Outputs immediate value to be added to 2 + PC if OpA < 0
		LBI   : Out = OpB;
		SLBI  : Out = 16'b0;		// TODO
		JINST : Out = OpB;   // Outputs displacement value to be added to 2 + PC
		JR		: Out = add_Sum;
		JAL   : Out = 16'b0;		// Don't care
		JALR  : Out = add_Sum;
		RET   : Out = 16'b0;		// Don't care
		SIIC  : Out = 16'b0; 	// Don't care
      RTI   : Out = 16'b0;		// Don't care
		NOP   : Out = 16'b0;		// Don't care
		HALT  : Out = 16'b0;		// Don't care
      default:
          Out = 16'hbadadd;
      endcase
   end
   
endmodule // ALU

