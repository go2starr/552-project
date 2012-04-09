/* shift1.v - shift 1 */
module shift1(
              in,               // value to shift
              op,               // operand
              out
              );
   // Inputs
   input [15:0] in;
   input [1:0]  op;

   // Outputs
   output reg [15:0] out;

   // Shifter operands
   parameter OP_ROL = 0;            // Rotate left
   parameter OP_SLL = 1;            // Shift left logical
   parameter OP_ROR = 2;            // Rotate right
   parameter OP_ASR = 3;            // Shift right arithmetic

   // Connections
   always @(*) begin
      case (op)
        OP_ROL: begin
           out[15:1] = in[14:0];
           out[0]    = in[15];
        end

        OP_SLL: begin
           out[15:1] = in[14:0];
           out[0]    = 0;
        end

        OP_ROR: begin
           out[14:0] = in[15:1];
           out[15]   = in[0];
        end

        OP_ASR: begin
           out[14:0] = in[15:1];
           out[15]   = in[15];
        end        
      endcase // case (op)
   end
   

   
   

endmodule // shiftx

     
   

              
