module next_pc_addr (instr, pc_inc, alu_out, brj_dest, bt, next_pc);

	// inputs
	input [15:0] instr;
	input [15:0] pc_inc;
	input [15:0] alu_out;
	input [15:0] brj_dest;
	input bt;

	// outputs
	output reg [15:0] next_pc;

	// wires
	wire [4:0] op;

	// assigns
	assign op = instr[15:11];
	

	always @ (*) begin
		case (op)
			5'b01100 : begin	// BEQZ
							next_pc = (bt == 1'b1) ? brj_dest : pc_inc;
						  end
			5'b01101 : begin  // BNEZ
							next_pc = (bt == 1'b1) ? brj_dest : pc_inc;
						  end
			5'b01111 : begin  // BLTZ
							next_pc = (bt == 1'b1) ? brj_dest : pc_inc;
						  end
			5'b00100 : begin  // J
							next_pc = brj_dest;	
						  end
			5'b00101 : begin  // JR
							next_pc = alu_out;
						  end
			5'b00110 : begin  // JAL
							next_pc = brj_dest;
						  end
			5'b00111 : begin  // JALR
							next_pc = alu_out;
						  end
			5'b01110 : begin  // RET
							next_pc = alu_out;
						  end
			5'b00011 : begin  // RTI
							next_pc = alu_out;
						  end
			default : begin
							next_pc = pc_inc;
						 end
		
		endcase
	end
endmodule
