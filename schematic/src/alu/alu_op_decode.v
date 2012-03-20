module alu_op_decode (instr, alu_op);

input [15:0] instr;
output [4:0] alu_op;

parameter ADD   = 0;
parameter SUB   = 1;
parameter OR    = 2;
parameter AND   = 3;
parameter ROL   = 4;
parameter SLL   = 5;
parameter ROR   = 6;
iparameter SRA   = 7;
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

// wires and reg vars
reg [4:0] op;
wire [6:0] instr_op;

// assigns
assign instr_op = {instr[15:11], instr[1:0]};
assign alu_op = op;

// case statement/decode logic
always @ (instr_op) begin
	casex (instr_op)
	7'b1101100 : op = ADD;
	7'b1101101 : op = SUB;
	7'b1101110 : op = OR;
	7'b1101111 : op = AND;
	7'b1101000 : op = ROL;
	7'b1101001 : op = SLL;
	7'b1101010 : op = ROR;
	7'b1101011 : op = SRA;
	7'b00000xx : op = HALT;
	7'b00001xx : op = NOP;
	7'b01000xx : op = ADD;
	7'b01001xx : op = SUB;
	7'b01010xx : op = OR;
	7'b01011xx : op = AND;
	7'b10100xx : op = ROL;
	7'b10101xx : op = SLL;
	7'b10110xx : op = ROR;
	7'b10111xx : op = SRA;
	7'b10000xx : op = ST;
	7'b10001xx : op = LD;
	7'b10011xx : op = STU;
	7'b11001xx : op = BTR;
	7'b11100xx : op = SEQ;
	7'b11101xx : op = SLT;
	7'b11110xx : op = SLE;
	7'b11111xx : op = SCO;
	7'b01100xx : op = BEQZ;
	7'b01101xx : op = BNEZ;
	7'b01111xx : op = BLTZ;
	7'b11000xx : op = LBI;
	7'b10010xx : op = SLBI;
	7'b00100xx : op = JINST;
	7'b00101xx : op = JR;
	7'b00110xx : op = JAL;
	7'b00111xx : op = JALR;
	7'b01110xx : op = RET;
	7'b00010xx : op = SIIC;
	7'b00011xx : op = RTI;
	default	  : op = 5'b11111;
	endcase
end
endmodule
