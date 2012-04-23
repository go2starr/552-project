module next_pc_addr (instr, pc_inc, alu_out, brj_dest, bt, stall, next_pc);

   // inputs
   input [15:0] instr;
   input [15:0] pc_inc;
   input [15:0] alu_out;
   input [15:0] brj_dest;
   input        bt;
   input        stall;

   // outputs
   output [15:0] next_pc;

   // wires
   wire [4:0]        op;
   reg [15:0] br_pc;

   // assigns
   assign op = instr[15:11];
   
   next_pc = (stall & ~bt) ? (pc_inc - 2 ): br_pc; 

   always @ (*) begin
         case (op)
	   5'b01100 : begin	// BEQZ
	      br_pc = (bt == 1'b1) ? brj_dest : pc_inc;
	   end
	   5'b01101 : begin  // BNEZ
	      br_pc = (bt == 1'b1) ? brj_dest : pc_inc;
	   end
	   5'b01111 : begin  // BLTZ
	      br_pc = (bt == 1'b1) ? brj_dest : pc_inc;
	   end
	   5'b00100 : begin  // J
	      br_pc = brj_dest;	
	   end
	   5'b00101 : begin  // JR
	      br__pc = alu_out;
	   end
	   5'b00110 : begin  // JAL
	      br_pc = brj_dest;
	   end
	   5'b00111 : begin  // JALR
	      br_pc = alu_out;
	   end
	   5'b01110 : begin  // RET
	      br_pc = alu_out;
	   end
	   5'b00011 : begin  // RTI
	      br_pc = alu_out;
	   end
	   default : begin
	      br_pc = pc_inc;
	   end
         endcase // case (op)
   end*/
endmodule
