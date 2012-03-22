module brj_addr_calc (instr, pc_inc, dest_addr);

	// TODO : ARE SHIFTS NEEDED?? (ie SL by 1)
		
	// inputs
	input [15:0] instr;
	input [15:0] pc_inc;

	// outputs
	output [15:0] dest_addr;

	// wires
	wire [4:0] op;
	wire co, G, P;
	reg [15:0] sextVal;

	// assigns
	assign op = instr[15:11];
	
	// Instantiations
	add16 add (.A(sextVal), .B(pc_inc), .CI(1'b0), .Sum(dest_addr), .CO(co), .Ggroup(G), .Pgroup (P));


	always @ (*) begin
		case (op)
			5'b01100 : begin  // BEQZ
							sextVal = {{8{instr[7]}}, instr[7:0]};		
					     end
			5'b01101 : begin  // BNEZ
							sextVal = {{8{instr[7]}}, instr[7:0]}; 
			  			  end
			5'b01111 : begin	// BLTZ
							sextVal = {{8{instr[7]}}, instr[7:0]};
						  end
			5'b00100 : begin	// J
							sextVal = {{5{instr[10]}}, instr[10:0]};
						  end
			5'b00110 : begin  // JAL
							sextVal = {{5{instr[10]}}, instr[10:0]};
						  end
			default :  begin
							sextVal = 16'b0;
						  end			
		endcase
	end



endmodule
