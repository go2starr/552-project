
// ALU module
module ALU (A, B, Cin, Op, invA, invB, sign, Out, OFL, Zero);
// define inputs and outputs
input [15:0] A;
input [15:0] B;
input Cin;
input [2:0] Op;
input invA;
input invB;
input sign;
output [15:0] Out;
output OFL;
output Zero;
// wires local to the module
wire cout;
wire [15:0] c1;
reg OFL, Zero;
reg C;
reg [1:0]Opcode;
wire [15:0]a1,b1;
wire [15:0]out;
reg [15:0]Out;
wire [15:0]O;
assign a1 = invA ? (~A) : A;
assign b1 = invB ? (~B) : B;
// Instantiate CLA here
cla16 C1 (.A(a1),.B(b1),.Cin(C),.Out(out),.Cout(cout));
// Instantiate shifter from problem 1 here
shift_16 S1(.In(a1),.Cnt(b1[3:0]),.Op(Opcode), .Out(O));
always@(*)beginC= Cin|invA|invB;
case(Op)
// Rotate Left
3'd0: begin Opcode = 2'b00; Out=O; OFL = 1'b0; end
// Shift left logical
3'd1: begin Opcode = 2'b01; Out=O; OFL = 1'b0; end
// Rotate Right
3'd2: begin Opcode = 2'b10; Out=O; OFL = 1'b0; end
// Shift Right Arithmetic
3'd3: begin Opcode = 2'b11; Out=O; OFL = 1'b0; end
// Addition
3'd4: begin
Out = out;
// Logic for OFL
OFL = ((cout==1'b1)&(sign==1'b0))|((sign==1'b1)&(cout^(C1.k1.C[3])));
end
// OR
3'd5: begin Out = a1 | b1; OFL = 1'b0; end
// XOR
3'd6: begin Out = a1 ^ b1; OFL = 1'b0; end
// AND
3'd7: begin Out = a1 & b1; OFL = 1'b0; end
endcase
// Logic for Zero detection
Zero = !(|Out);
end
endmodule
// end of modul