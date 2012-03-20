`include "testbench.v"
module t_ALU_bench();

   // Inputs
   reg [15:0] a, b, expected;
   reg        cin;
   reg [2:0]  op;
   reg        invA, invB, sign;
   
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
   ALU alu (a, b, cin, op, invA, invB, sign, out, ofl, zero);

   initial begin
      `info("Starting ALU testbench");

      `test(1,1,"DUMMY TEST");
      
      // Initialize variables
      a = 0;
      b = 0;
      cin = 0;
      op = 0;
      invA = 0;
      invB = 0;
      sign = 0;

      ////////////////////////////////////////
      $display("Testing shifter...");
      ////////////////////////////////////////
      // Initialize some testing values
      vals[0] = 24;
      vals[1] = 234;
      vals[2] = 15893;
      vals[3] = 64123;      
      $display("Testing rotate left...");
      op = OP_ROL;
      for (i = 0; i < 2; i = i + 1) begin
         for (j = 0; j < 16; j = j + 4) begin
            a = vals[i];
            b = j;
            #1;
            `test((a << j) | (a >> (16-j)), out, "Rotate left");
         end
      end      

      $display("Testing shift left...");
      op = OP_SLL;
      for (i = 0; i < 2; i = i + 1) begin
         for (j = 0; j < 16; j = j + 4) begin
            a = vals[i];
            b = j;
            #1;
            `test(a << j, out, "Shift left");
         end
      end

      $display("Testing rotate right...");
      op = OP_ROR;
      for (i = 0; i < 2; i = i + 1) begin
         for (j = 0; j < 16; j = j + 4) begin
            a = vals[i];
            b = j;
            #1;
            `test((a >> j) | (a << (16-j)), out, "Rotate right");
         end
      end

      $display("Testing rotate right...");
      op = OP_SRA;
      for (i = 0; i < 2; i = i + 1) begin
         for (j = 0; j < 16; j = j + 4) begin
            a = vals[i];
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
      $display("Testing adder...");
      ////////////////////////////////////////
      op = OP_ADD;
      #100;
      for (k = 0; k < 2; k = k + 1) begin
         if (k)
           $display ("Testing with carryin...");
         else
           $display ("Testing without carryin...");
         for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 4) begin
               a = (256 << i) | 99;
               b = (123 << j) | 72;
               cin = k;
               expected = a+b+cin;
               #1;
               `test(expected, out, "Adder");
            end
         end
      end

      ////////////////////////////////////////
      $display("Testing logical operations...");
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
      $display("Testing operand inversion...");
      ////////////////////////////////////////
      op = OP_ADD;
      cin = 0;

      a = 0x123;
      b = 0x234;

      invA = 1;
      invB = 0;
      expected = ~a + b;
      #1;
      `test(expected, out, "INV ADD");
      #1;
      invA = 1;
      invB = 1;
      expected = ~a + ~b;
      #1;
      `test(expected, out, "INV ADD");
      #1;
      invA = 0;
      invB = 1;
      `test(a + (~b), out, "INV ADD");
      #1;
      invA = 0;
      invB = 0;
      #1;

      ////////////////////////////////////////
      $display("Testing overflow...");
      ////////////////////////////////////////
      op = OP_ADD;
      invA = 0;
      invB = 0;

      $display ("Testing signed overflow");
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

      $display ("Testing unsigned overflow");
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
      $display("Testing zero bit...");
      ////////////////////////////////////////
      sign = 0;
      a = 0;
      b = 0;
      #1;
      `test(1, zero, "");
      #2;
      a = 10;
      #1;
      `test(0, zero, "");
      
      `info("ALU tests complete");
   end
endmodule // ALU_t
