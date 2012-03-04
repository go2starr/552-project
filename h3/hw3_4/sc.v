
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
   
   dff inst[2:0](currentState, nextState, clk, rst);
   
   //do this with dff by above way?
   //assign currentState = rst ? 3'b000 : newState;
   //assign out = Out;
   assign err = Err;
   
   //Deal with global reset?
   
   always@(out, ctr_rst)
   case({clk, ctr_rst, currentState})
   5'b11000 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b11001 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b11010 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b11011 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b11100 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b11101 : begin Out = 3'b000; newState = 3'b000; Err = 0; end
   5'b10000 : begin Out = 3'b000; newState = 3'b001; Err = 0; end
   5'b10001 : begin Out = 3'b001; newState = 3'b010; Err = 0; end
   5'b10010 : begin Out = 3'b010; newState = 3'b011; Err = 0; end
   5'b10011 : begin Out = 3'b011; newState = 3'b100; Err = 0; end
   5'b10100 : begin Out = 3'b100; newState = 3'b101; Err = 0; end
   5'b10101 : begin Out = 3'b101; newState = 3'b101; Err = 0; end
   default  : begin Out = 3'b000; newState = 3'b000; Err = 1; end
   endcase

endmodule