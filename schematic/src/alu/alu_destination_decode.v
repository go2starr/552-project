module alu_destination_decode (instr, rd);
   // Inputs
   input [15:0] instr;

   // Outputsn
   output reg [2:0] rd;

   // Wires
   wire [2:0]       rd_imm, rd_reg, rd_ld_imm;
   assign rd_imm = instr[7:5];
   assign rd_reg = instr[4:2];
   assign rd_ld_imm = instr[10:8];

   // assigns
   wire [6:0]       op;
   assign op = {instr[15:11], instr[1:0]};
   
   always @ (*) begin
      casex (op)
        /* Reg op */
	7'b1101100 : // ADD
	  rd = rd_reg;
	7'b1101101 : // SUB
	  rd = rd_reg;
	7'b1101110 : // OR
	  rd = rd_reg;
	7'b1101111 : // AND
	  rd = rd_reg;
	7'b1101000 : // ROL
	  rd = rd_reg;
	7'b1101001 : // SLL
	  rd = rd_reg;
	7'b1101010 : // ROR
	  rd = rd_reg;
	7'b1101011 : // SRA
	  rd = rd_reg;
	7'b11100xx : // SEQ
	  rd = rd_reg;
	7'b11101xx : // SLT
	  rd = rd_reg;
	7'b11110xx : // SLE
	  rd = rd_reg;
	7'b11111xx : // SCO
	  rd = rd_reg;
	7'b11001xx : // BTR
	  rd = rd_reg;

        /* Imm */
	7'b01000xx : // ADDI
	  rd = rd_imm;
	7'b01001xx : // SUBI
	  rd = rd_imm;
	7'b01010xx : // ORI
	  rd = rd_imm;
	7'b01011xx : // ANDI
	  rd = rd_imm;
	7'b10100xx : // ROLI
	  rd = rd_imm;
	7'b10101xx : // SLLI
	  rd = rd_imm;
	7'b10110xx : // RORI
	  rd = rd_imm;
	7'b10111xx : // SRAI
	  rd = rd_imm;
	7'b10000xx : // ST
	  rd = rd_imm;
	7'b10001xx : // LD
	  rd = rd_imm;
	7'b10011xx : // STU
	  rd = rd_imm;

        /* Load immediates (Rd is Rs here) */
	7'b11000xx : // LBI
	  rd = rd_ld_imm;
	7'b10010xx : // SLBI
	  rd = rd_ld_imm;

        /* No write */
        /*
	7'b01100xx : // BEQZ
	  rd = 
	7'b01101xx : // BNEZ
	  rd = 
	7'b01111xx : // BLTZ
	  rd = 
	7'b00100xx : // JINST
	  rd = 
	7'b00101xx : // JR
	  rd = 
	7'b00110xx : // JAL
	  rd = 
	7'b00111xx : // JALR
	  rd = 
	7'b01110xx : // RET
	  rd = 
	7'b00010xx : // SIIC
	  rd = 
	7'b00011xx : // RTI
	  rd =

	7'b00000xx : // HALT
	  rd = rd_reg;
	7'b00001xx : // NOP;
	  rd = 
         
               
	default	  : rd = 
         */
        default :
          rd = 3'b010;
      endcase
   end
endmodule

