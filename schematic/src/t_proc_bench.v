`include "testbench.v"

// t_proc_bench.v
module t_proc_bench();
   // DUT Outputs
   wire err;

   // Clkrst
   wire clk, rst;
   clkrst cr(clk, rst, err);
   
   // CPU - DUT
   proc dut (.clk(clk),
             .rst(rst),
             .err(err)
             );


   // Counters
   integer i,j,k, no_errs;


   initial begin
      `info("Starting tests");

      /****************************************
       *  Check reset conditions
       *****************************************/
      `tic;
      `test(0, dut.pc, "PC did not reset to 0");


      `tic;
      `tic;


      /****************************************
       ****************************************/
      for (i = 0; i < 100; i = i + 1) begin
         $display("PC: %h", dut.pc);
         `tic;
      end

      `info("Tests complete");
      $finish;
   end   

endmodule // t_proc_bench

