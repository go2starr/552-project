module branch_logic (op, zero, ltz, bt);
	
	// inputs
	input [4:0] op;
	input zero;
	input ltz;
	
	// outputs
	output reg bt;

	// parameters
   parameter BEQZ = 5'b01100;
	parameter BNEZ = 5'b01101;
	parameter BLTZ = 5'b01111;
	
	always@(*) begin
		case (op)
			BEQZ : bt = (zero == 1'b1) ? 1'b1 : 1'b0;
			BNEZ : bt = (zero == 1'b1) ? 1'b0 : 1'b1;
			BLTZ : bt = (zero == 1'b0 && ltz == 1'b1) ? 1'b1 : 1'b0;		
		endcase
	end
endmodule
