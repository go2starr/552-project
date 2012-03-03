/* add16_t.v - 16-bit adder testbench */
module add16_t();
   reg [15:0] A, B;
   reg        CI;
   wire [15:0] Sum;
   wire        CO, G, P;

   add16 a16 (A, B, CI, Sum, CO, G, P);

   integer     i, j, k;
   parameter TWO_POW_16 = 65536;


   task doTest;
      input [15:0] a, b;
      input ci;
      begin
         A = a;
         B = b;
         CI = ci;

         #10;
         $display ("%d + %d + %d = %d", A, B, CI, Sum);
         if (A+B+CI !== Sum)
           $display ("%d + %d + %d = %d.  Got %d.",
                     A, B, CI, A+B+CI, Sum);

         if (A+B+CI >= TWO_POW_16 && !CO)
           $display ("Carry failed for %d, %d, %d",
                     A, B, CI);
            
      end
   endtask // begin
   
   
   initial begin
      $display("Running tests...");
      
      doTest(1,0,0);
      doTest(1,1,0);
      doTest(10,10,0);
      doTest(1,2,1);

      for (i = 0; i < 16; i = i + 1) begin
         for (j = 0; j < 2; j = j + 1) begin
            A = (12701 << 2*i) % TWO_POW_16;
            B = (1027  << 1*i) % TWO_POW_16 + 5000;
            CI = j;
            
            doTest(A, B, CI);
         end
      end

      $display("All tests complete");
   end
   
endmodule // add16_t

   
   
