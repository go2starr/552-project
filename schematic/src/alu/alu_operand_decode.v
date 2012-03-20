module alu_operand_decode (instr, rsVal, rtVal, opA, opB) begin
	input [15:0] instr;
	input [15:0] rsVal;
	input [15:0] rtVal;

	output [15:0] opA;
	output [15:0] opB;

	// wires and regs
	reg [15:0] opBVal;
	wire [6:0] op;

	// assigns
	assign opA = rsVal;
	assign opB = opBVal;
	assign op = {instr[15:11], instr[1:0]};
	
	always @ (*) begin
		casex (op)
			7'b1101100 : // ADD
							 opBVal = rtVal;
			7'b1101101 : // SUB
							 opBVal = rtVal;
			7'b1101110 : // OR
							 opBVal = rtVal;
			7'b1101111 : // AND
							 opBVal = rtVal;
			7'b1101000 : // ROL
							 opBVal = rtVal;
			7'b1101001 : // SLL
							 opBVal = rtVal;
			7'b1101010 : // ROR
							 opBVal = rtVal;
			7'b1101011 : // SRA
							 opBVal = rtVal;
			7'b00000xx : // HALT
							 opBVal = 16'b0;	// TODO what val?
			7'b00001xx : // NOP;
							 opBVal = 16'b0;	// TODO what val?
			7'b01000xx : // ADDI
							 opBVal = {{11{instr[4]}}, instr[4:0]}; // sign extended immediate
			7'b01001xx : // SUBI
							 opBVal = {{11{instr[4]}}, instr[4:0]}; // sign extended immediate
			7'b01010xx : // ORI
							 opBVal = {11'b0, instr[4:0]};		// zero-extended immediate
			7'b01011xx : // ANDI
							 opBVal = {11'b0, instr[4:0]};		// zero-extended immediate
			7'b10100xx : // ROLI
							 opBVal = {11'b0, instr[4:0]};		// zero-extended immediate
			7'b10101xx : // SLLI
							 opBVal = {11'b0, instr[4:0]};		// zero-extended immediate
			7'b10110xx : // RORI
							 opBVal = {11'b0, instr[4:0]};		// zero-extended immediate
			7'b10111xx : // SRAI
						    opBVal = {11'b0, instr[4:0]};		// zero-extended immediate
			7'b10000xx : // ST
							 opBVal = {{11{instr[4]}}, instr[4:0]}; // sign extended immediate 	
			7'b10001xx : // LD
						    opBVal = {{11{instr[4]}}, instr[4:0]}; // sign extended immediate
			7'b10011xx : // STU
							 opBVal = {{11{instr[4]}}, instr[4:0]}; // sign extended immediate
			7'b11001xx : // BTR
							 opBVal = 16'b1;	// don't care what opB is
			7'b11100xx : // SEQ
							 opBVal = rtVal;
			7'b11101xx : // SLT
							 opBVal = rtVal;
			7'b11110xx : // SLE
						 	 opBVal = rtVal;
			7'b11111xx : // SCO
							 opBVal = rtVal;
			7'b01100xx : // BEQZ
							 opBVal = {{8{instr[7]}}, instr[7:0]};		// sign extended immediate
			7'b01101xx : // BNEZ
							 opBVal = {{8{instr[7]}}, instr[7:0]};		// sign extended immediate
			7'b01111xx : // BLTZ
							 opBVal = {{8{instr[7]}}, instr[7:0]};		// sign extended immediate
			7'b11000xx : // LBI
							 opBVal = {{8{instr[7]}}, instr[7:0]};		// sign extended immediate
			7'b10010xx : // SLBI
							 opBVal = {8'b0, instr[7:0]};					// zero extended immediate
			7'b00100xx : // JINST
							 opBVal = {{5{instr[10]}}, instr[10:0]}	// sign extended displacement
			7'b00101xx : // JR
							 opBVal = {{8{instr[7]}}, instr[7:0]};		// sign extended immediate
			7'b00110xx : // JAL
							 opBVal = {{5{instr[10]}}, instr [10:0]}; // sign extended displacement
			7'b00111xx : // JALR
							 opBVal = {{8{instr[7]}}, instr[7:0]};		// sign extended immediate
			7'b01110xx : // RET
							 opBVal = 16'b0;	// Don't care
			7'b00010xx : // SIIC
							 opBVal = 16'b0;  // Don't care
			7'b00011xx : // RTI
							 opBVal = 16'b0;  // Don't care
			default	  : opBVal = 16'b1;	
		endcase
	end
endmodule
