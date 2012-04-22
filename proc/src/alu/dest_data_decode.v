module dest_data_decode (instr, next_pc, alu_out, mem_out, rdata);
   // Inputs
   input [15:0] instr;
   input [15:0] next_pc;
   input [15:0] alu_out;
   input [15:0] mem_out;

   // Outputs
   output reg [15:0] rdata;

   // Wires
   wire [6:0]        op; 
   

   // assigns
   assign op = {instr[15:11], instr[1:0]};
   
   always @ (*) begin
      casex (op)
        /* Reg op */
	7'b1101100 : // ADD
	  rdata = alu_out;
	7'b1101101 : // SUB
	  rdata = alu_out;
	7'b1101110 : // OR
	  rdata = alu_out;
	7'b1101111 : // AND
	  rdata = alu_out;
	7'b1101000 : // ROL
	  rdata = alu_out;
	7'b1101001 : // SLL
	  rdata = alu_out;
	7'b1101010 : // ROR
	  rdata = alu_out;
	7'b1101011 : // SRA
	  rdata = alu_out;
	7'b11100xx : // SEQ
	  rdata = alu_out;
	7'b11101xx : // SLT
	  rdata = alu_out;
	7'b11110xx : // SLE
	  rdata = alu_out;
	7'b11111xx : // SCO
	  rdata = alu_out;
	7'b11001xx : // BTR
	  rdata = alu_out;

        /* Imm */
	7'b01000xx : // ADDI
	  rdata = alu_out;
	7'b01001xx : // SUBI
	  rdata = alu_out;
	7'b01010xx : // ORI
	  rdata = alu_out;
	7'b01011xx : // ANDI
	  rdata = alu_out;
	7'b10100xx : // ROLI
	  rdata = alu_out;
	7'b10101xx : // SLLI
	  rdata = alu_out;
	7'b10110xx : // RORI
	  rdata = alu_out;
	7'b10111xx : // SRAI
	  rdata = alu_out;
	7'b10001xx : // LD
	  rdata = mem_out;

        /* Load immediates (Rd is Rs here) */
	7'b11000xx : // LBI
	  rdata = alu_out;
	7'b10010xx : // SLBI
	  rdata = alu_out;

	/* Write PC to R7 */
	7'b00110xx : // JAL
	  rdata = next_pc;
	7'b00111xx : // JALR
	  rdata = next_pc;

	/* Write back to Rs */
	7'b10011xx : // STU
	  rdata = alu_out;   

	default	  : rdata = 16'b0;
      endcase
   end
endmodule

