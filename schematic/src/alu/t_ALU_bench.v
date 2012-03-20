`include "testbench.v"
`define DEBUG 1
module t_ALU_bench();
   // Inputs
   reg [15:0] a, b, expected;
   reg        cin;
   reg [2:0]  op;
   reg        sign;
   
   // Outputs
   wire [15:0] out;
   wire        ofl, zero;

   // Other
   integer     i,j,k, no_errs;
   
   reg [15:0]  vals [3:0];      // Shifter test

   // Shifter operands
   parameter OP_ROL = 0;
   parameter OP_SLL = 1;
   parameter OP_ROR = 2;
   parameter OP_SRA = 3;
   parameter OP_ADD = 4;
   parameter OP_OR  = 5;
   parameter OP_XOR = 6;
   parameter OP_AND = 7;   

   // Instantiate
   ALU alu (a, b, cin, op, sign, out, ofl, zero);

   initial begin
      `info("Starting ALU testbench");
      // Initialize variables
      a = 0;
      b = 0;
      cin = 0;
      op = 0;
      sign = 0;

      ////////////////////////////////////////
      `info("Testing shifter...");
      ////////////////////////////////////////
      // Initialize some testing values
      `info("Testing rotate left...");
      op = OP_ROL;
      for (i = 0; i < 50; i = i + 1) begin
         for (j = 0; j < 16; j = j + 1) begin
            a = $random;
            b = j;
            #100;
            `test(16'((a << j) | (a >> (16-j))), out, "Rotate left");
            #100;
         end
      end      

      `info("Testing shift left...");
      op = OP_SLL;
      for (i = 0; i < 50; i = i + 1) begin
         for (j = 0; j < 16; j = j + 1) begin
            a = $random;
            b = j;
            #100;
            `test(a << j, out, "Shift left");
         end
      end

      `info("Testing rotate right...");
      op = OP_ROR;
      for (i = 0; i < 50; i = i + 1) begin
         for (j = 0; j < 16; j = j + 1) begin
            a = $random;
            b = j;
            #100;
            `test(16'((a >> j) | (a << (16-j))), out, "Rotate right");
         end
      end

      `info("Testing rotate right...");
      op = OP_SRA;
      for (i = 0; i < 50; i = i + 1) begin
         for (j = 0; j < 16; j = j + 1) begin
            a = $random;
            b = j;
            #1;
            expected = a >> j;
            for (k = 0; k < j; k = k + 1) begin
               expected[15-k] = a[15];
            end
            `test(expected, out, "Shift right");
         end
      end            

      ////////////////////////////////////////
      `info("Testing adder...");
      ////////////////////////////////////////
      op = OP_ADD;
      #100;
      for (k = 0; k < 2; k = k + 1) begin
         if (k) begin
           `info("Testing with carryin...");
         end else begin
           `info("Testing without carryin...");
         end
         for (i = 0; i < 1000; i = i + 1) begin
            a = $random % 16;
            b = $random % 16;
            cin = k;
            expected = a+b+cin;
            #1;
            `test(expected, out, "Adder");
         end
      end

      ////////////////////////////////////////
      `info("Testing logical operations...");
      ////////////////////////////////////////
      a = 0x123;
      b = 0x234;

      op = OP_OR; #1;
      `test(a|b, out, "OR");

      op = OP_XOR; #1;
      `test(a^b, out, "XOR");

      op = OP_AND; #1;
      `test(a&b, out, "AND");

      ////////////////////////////////////////
      `info("Testing overflow...");
      ////////////////////////////////////////
      op = OP_ADD;

      `info("Testing signed overflow");
      sign = 1;
      a = 16'd20000;
      b = 16'd20000;
      #1;
      `test(1, ofl, "ofl");         // overflow
      #1;
      a = -16'd20000;
      b = -16'd20000;
      #1;
      `test(1, ofl, "ofl");         // overflow
      #1;
      a = 10;
      b = 20;
      #1;
      `test(0, ofl, "ofl");         // no overflow
      #1;
      a = -10;
      b = -20000;
      #1;
      `test(0, ofl, "ofl");         // no overflow

      `info("Testing unsigned overflow");
      sign = 0;
      a = 60000;
      b = 60000;
      #1;
      `test(1, ofl, "");
      #1;
      a = 30000;
      b = 30000;
      #1;
      `test(0, ofl, "");

      ////////////////////////////////////////
      `info("Testing zero bit...");
      ////////////////////////////////////////
      op = OP_ADD;
      sign = 0;
      a = 0;
      b = 0;
      cin = 0;
      #1;
      `test(1, zero, "Zero bit not set when adding two zero operands");
      `test(0, out, "Output of a zero operation is not zero");
      a = 10;
      #1;
      `test(0, zero, "Zero bit set when adding two non-zero operands");
      
      `info("ALU tests complete");
   end
endmodule // ALU_t
