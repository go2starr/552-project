/* shift16_t.v - testbench for shift16.v */

module shift16_t();
   reg [15:0] in, expected;
   reg [3:0]  cnt;
   reg [1:0]  op;

   wire [15:0] out;
   

   reg [15:0]  vals [3:0];
   
   shift16 s16 (in, cnt, op, out);

   integer     i,j,k;

   // Shifter operands
   parameter OP_ROL = 0;            // Rotate left
   parameter OP_SLL = 1;            // Shift left logical
   parameter OP_ROR = 2;            // Rotate right
   parameter OP_ASR = 3;            // Shift right arithmetic

   // Debug
   task check;
      input [15:0] expected;
      input [15:0] got;
      begin
            if (got !== expected)
              $display ("ERR:  In: 0x%x Expected: 0x%h Got: 0x%h", in, expected, got);
      end
   endtask // check

   initial begin
      $display("Tests beginning...");

      // Initialize some testing values
      vals[0] = 24;
      vals[1] = 234;
      vals[2] = 15893;
      vals[3] = 64123;

      $display("Testing rotate left...");
      op = OP_ROL;
      for (i = 0; i < 4; i = i + 1) begin
         in = vals[i];
         for (j = 0; j < 16; j = j + 4) begin
            cnt = j;
            #1;
            check((in << j) | (in >> (16-j)), out);
         end
      end      

      $display("Testing shift left...");
      op = OP_SLL;
      for (i = 0; i < 4; i = i + 1) begin
         in = vals[i];
         for (j = 0; j < 16; j = j + 4) begin
            cnt = j;
            #1;
            check(in << j, out);
         end
      end

      $display("Testing rotate right...");
      op = OP_ROR;
      for (i = 0; i < 4; i = i + 1) begin
         in = vals[i];
         for (j = 0; j < 16; j = j + 4) begin
            cnt = j;
            #1;
            check((in >> j) | (in << (16-j)), out);
         end
      end

      $display("Testing rotate right...");
      op = OP_ASR;
      for (i = 0; i < 4; i = i + 1) begin
         in = vals[i];
         for (j = 0; j < 16; j = j + 4) begin
            cnt = j;
            #1;
            expected = in >> j;
            for (k = 0; k < j; k = k + 1) begin
               expected[15-k] = in[15];
            end
            check(expected, out);
         end
      end            

      $display("Tests complete.");
   end
endmodule // shift16_t

