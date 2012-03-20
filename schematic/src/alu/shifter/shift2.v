/* shift2.v - shift 2 */
module shift2(
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
           out[15:2] = in[13:0];
           out[1:0]  = in[15:14];
        end

        OP_SLL: begin
           out[15:2] = in[13:0];
           out[1:0]  = 0;
        end

        OP_ROR: begin
           out[13:0]  = in[15:2];
           out[15:14] = in[1:0];
        end

        OP_ASR: begin
           out[13:0] = in[15:2];
           out[15]   = in[15];
           out[14]   = in[15];
        end        
      endcase // case (op)
   end
endmodule // shiftx

     
   

              
