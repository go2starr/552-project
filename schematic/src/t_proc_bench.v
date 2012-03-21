`include "testbench.v"

`define DEBUG 1

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
       *  Test first instruction
       ****************************************/
      `info("lbi r0, 0x10");

      $display("PC: %h \t Instr: %h", dut.pc, dut.instr);
      // dut
      `test(16'h c010, dut.instr, "Instruction does not match: lbi r0, 0x10");
      `test(16'h 0, dut.pc, "PC should be 0 on start");
      `test(16'h 10, dut.alu.Out, "ALU output should be zero");

      // aopd
      `test(16'h 10, dut.aopd.opB, "ALU op decode output should be 0x10");
      `test(16'h c010, dut.aopd.instr, "Input to alu_op_decode should be instruction");
      `test(7'b 1100000, dut.aopd.op, "Op should be correct");

      // alu
      `test(16'h 10, dut.alu.opB, "ALU opB should be 0x10");
      `test(16'h 10, dut.alu.B, "ALU input should be 0x10 (immediate value)");
      `test(5'd  19, dut.alu.Op, "ALU op should be LBI");
      `test(16'h 10, dut.alu.Out, "ALU output should be 0x10");

      // add (destination decode)
      `test(16'h c010, dut.add.instr, "add instruction should be correct");
      `test(3'h  0,    dut.add.rd, "add register select should be zero");
      
      // write to rf
      `test(16'h 0, dut.rf_ws, "RF write select should be zero");
      `test(16'h 10, dut.rf_wd, "RF write data should be 0x10");
      
      /****************************************/
      `tic;
      /****************************************/
      `test(16'h10, dut.rf.rf0.my_regs0.q, "R0 does not contain 0x10 after a lbi 0x10");

      // dut
      `test(16'h c101, dut.instr, "Instruction does not match: lbi r1, 0x01");
      `test(16'h 2, dut.pc, "PC should be 2 after first instruction");

      // add (destination decode)
      
      // write to rf
      `test(16'h 01, dut.rf_ws, "RF write select should be one");      
      `test(16'h 01, dut.rf_wd, "RF write data should be 0x01");

      

      /****************************************/
      `tic;
      /****************************************/
      `test(16'h01, dut.rf.rf0.my_regs1.q, "R1 does not contain 0x01 after lbi r1, 0x01");

      `info("Tests complete");
      $finish;
   end   

endmodule // t_proc_bench

