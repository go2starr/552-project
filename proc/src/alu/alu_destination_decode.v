module alu_destination_decode (instr, rd, we_reg);
   // Inputs
   input [15:0] instr;

   // Outputsn
   output reg [2:0] rd;
   output reg       we_reg;

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
	7'b1101100 : begin // ADD
	   rd = rd_reg;
	   we_reg = 1'b1;
	end
	7'b1101101 : begin // SUB
	   rd = rd_reg;
	   we_reg = 1'b1;
	end
	7'b1101110 : begin // OR
	   rd = rd_reg;
	   we_reg = 1'b1;
	end
	7'b1101111 : begin// AND
	   rd = rd_reg;
	   we_reg = 1'b1;
	end
	7'b1101000 : begin // ROL
	   rd = rd_reg;
	   we_reg = 1'b1;
	end
	7'b1101001 : begin // SLL
	   rd = rd_reg;
	   we_reg = 1'b1;
        end
	7'b1101010 : begin // ROR
	   rd = rd_reg;
	   we_reg = 1'b1;
	end
	7'b1101011 : begin// SRA
	   rd = rd_reg;
	   we_reg = 1'b1;
        end
	7'b11100xx : begin // SEQ
	   rd = rd_reg;
	   we_reg = 1'b1;
        end
	7'b11101xx : begin// SLT
	   rd = rd_reg;
	   we_reg = 1'b1;
        end
	7'b11110xx : begin// SLE
	   rd = rd_reg;
           we_reg = 1'b1;
	end
	7'b11111xx : begin // SCO
	   rd = rd_reg;
	   we_reg = 1'b1;
        end
	7'b11001xx : begin // BTR
	   rd = rd_reg;
           we_reg = 1'b1;
	end

        /* Imm */
	7'b01000xx : begin // ADDI
	   rd = rd_imm;
	   we_reg = 1'b1;
        end
	7'b01001xx : begin// SUBI
	   rd = rd_imm;
           we_reg = 1'b1;
        end
	7'b01010xx : begin// ORI
	   rd = rd_imm;
	   we_reg = 1'b1;
        end
	7'b01011xx : begin // ANDI
	   rd = rd_imm;
           we_reg = 1'b1;
        end
	7'b10100xx : begin // ROLI
	   rd = rd_imm;
           we_reg = 1'b1;
        end
	7'b10101xx : begin // SLLI
	   rd = rd_imm;
           we_reg = 1'b1;
        end
	7'b10110xx : begin // RORI
	   rd = rd_imm;
           we_reg = 1'b1;
	end
	7'b10111xx : begin // SRAI
	   rd = rd_imm;
 	   we_reg = 1'b1;
        end
	7'b10001xx : begin // LD
	   rd = rd_imm;
	   we_reg = 1'b1;
        end

        /* Load immediates (Rd is Rs here) */
	7'b11000xx : begin // LBI
	   rd = rd_ld_imm;
	   we_reg = 1'b1;
	end
	7'b10010xx : begin// SLBI
	   rd = rd_ld_imm;
	   we_reg = 1'b1;
	end

	/* Write PC to R7 */
	7'b00110xx : begin // JAL
	   rd = 3'd7;
	   we_reg = 1'b1;
	end
	7'b00111xx : begin // JALR
	   rd = 3'd7;
	   we_reg = 1'b1;
	end

  	7'b10011xx : begin // STU
	   rd = rd_ld_imm;
	   we_reg = 1'b1;
	end

        /* No write */ 
	7'b10000xx : begin // ST
           rd = 3'd0;
           we_reg = 1'b0;
        end
	7'b01100xx : begin // BEQZ
           rd = 3'd0;
	   we_reg = 1'b0;
        end
	7'b01101xx : begin // BNEZ
           rd = 3'd0;
	   we_reg = 1'b0;
        end
	7'b01111xx : begin // BLTZ
           rd = 3'd0;
	   we_reg = 1'b0;
        end
	7'b00100xx : begin // JINST
           rd = 3'd0;
	   we_reg = 1'b0;
        end
	7'b00101xx : begin // JR
           rd = 3'd0;
	   we_reg = 1'b0;
        end
	7'b01110xx : begin // RET
           rd = 3'd0;
	   we_reg = 1'b0;
        end
	7'b00010xx : begin // SIIC
           rd = 3'd0;
	   we_reg = 1'b0;
        end
	7'b00011xx : begin // RTI
           rd = 3'd0;
	   we_reg = 1'b0;
        end
	7'b00000xx : begin // HALT
           rd = 3'd0;
	   we_reg = 1'b0;
        end
	7'b00001xx : begin // NOP;
           rd = 3'd0;
	   we_reg = 1'b0;
        end
        
	default	  : begin
           rd = 3'd0;
           we_reg = 1'b0;
        end
      endcase
   end
endmodule

