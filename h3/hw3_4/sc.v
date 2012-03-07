
module sc( clk, rst, ctr_rst, out, err);
   input clk;
   input rst;
   input ctr_rst;
   output [2:0] out;
   output err;
   wire [2:0] currentState;
   reg [2:0] newState;
   reg [2:0] Out;
   reg Err;
   
   
   dff inst[2:0](currentState, newState, clk, rst);
   
   //do this with dff by above way?
   
   //assign currentState = rst ? 3'b000 : ;
   assign out = Out;
   //assign err = Err;
   
   //Deal with global reset?
   
   always@(out, ctr_rst, currentState)
   case({ctr_rst, currentState})
   5'b1000 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b1001 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b1010 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b1011 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b1100 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b1101 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b0000 : begin Out = 3'b000; newState = 3'b001; Err = 0; end
   5'b0001 : begin Out = 3'b001; newState = 3'b010; Err = 0; end
   5'b0010 : begin Out = 3'b010; newState = 3'b011; Err = 0; end
   5'b0011 : begin Out = 3'b011; newState = 3'b100; Err = 0; end
   5'b0100 : begin Out = 3'b100; newState = 3'b101; Err = 0; end
   5'b0101 : begin Out = 3'b101; newState = 3'b101; Err = 0; end
   default : begin Out = 3'b000; newState = 3'b000; Err = 1; end
   endcase

endmodule