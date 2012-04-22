`include "testbench.v"

module t_proc_pipe_bench();
   // DUT inputs
   wire clk, rst;
   
   // DUT outputs
   wire err;

   // Clock gen
   clkrst cr(clk, rst, err);

   // CPU - DUT
   proc dut(
            .clk(clk),
            .rst(rst),
            .err(err)
            );

   // Counters
   integer i, j, k;
   integer no_errs;
   integer cycle;

   initial begin
      `info("Tests begin");
      cycle = 0;
      


      /********************************************************************************
       *  lbi r0, 0x0
       * ********************************************************************************/
      `tic;
      `tic;
      `tic;

      // IF
      `test(0, dut.IF_pc, "PC did not reset to 0");
      `test(16'hc000, dut.IF_instr, "Instruction not correct");
      `test(16'h02, dut.IF_next_pc, "Next_pc not correct");
      `test(16'h02, dut.IF_pc_inc, "PC not incremented");

      /********************************************************************************
       *  lbi r1, 0x1
       * ********************************************************************************/
      `tic;

      // IF
      `test(2, dut.IF_pc, "PC did not increment");
      `test(16'hc101, dut.IF_instr, "Instruction not correct");
      `test(16'h04, dut.IF_next_pc, "Next_pc not correct");
      `test(16'h04, dut.IF_pc_inc, "PC not incremented");

      // ID
      `test(16'hc000, dut.ID_instr, "ID instruction not correct");
      `test(16'h02, dut.ID_pc_inc, "ID pc_inc correct");

      /********************************************************************************
       *  lbi r2, 0x02
       * ********************************************************************************/
      `tic;

      // IF
      `test(4, dut.IF_pc, "PC did not increment");
      `test(16'hc202, dut.IF_instr, "Instruction not correct");
      `test(16'h06, dut.IF_next_pc, "Next_pc not correct");
      `test(16'h06, dut.IF_pc_inc, "PC not incremented");

      // ID
      `test(16'hc101, dut.ID_instr, "ID instruction not correct");
      `test(16'h04, dut.ID_pc_inc, "ID pc_inc correct");      

      // EX
      `test(16'hc000, dut.EX_instr, "EX instruction");
      `test(16'h02, dut.EX_pc_inc, "EX PC inc");
      `test(16'h00, dut.EX_alu_out, "EX ALU out");
      `test(16'h00, dut.EX_rf_ws, "EX WS");
      `test(1, dut.EX_rf_wr, "EX RF_WR");
      `test(0, dut.EX_bt, "EX bt");

      /********************************************************************************
       *  lbi r3, 0x03
       * ********************************************************************************/
      `tic;

      // IF
      `test(6, dut.IF_pc, "PC did not increment");
      `test(16'hc303, dut.IF_instr, "Instruction not correct");
      `test(16'h08, dut.IF_next_pc, "Next_pc not correct");
      `test(16'h08, dut.IF_pc_inc, "PC not incremented");

      // ID
      `test(16'hc202, dut.ID_instr, "ID instruction not correct");
      `test(16'h06, dut.ID_pc_inc, "ID pc_inc correct");      

      // EX
      `test(16'hc101, dut.EX_instr, "EX instruction");
      `test(16'h04, dut.EX_pc_inc, "EX PC inc");
      `test(16'h01, dut.EX_alu_out, "EX ALU out");
      `test(16'h01, dut.EX_rf_ws, "EX WS");
      `test(1, dut.EX_rf_wr, "EX RF_WR");
      `test(0, dut.EX_bt, "EX bt");

      // MEM
      `test(16'hc000, dut.MEM_instr, "MEM instr");
      `test(16'h02, dut.MEM_pc_inc, "MEM pc_inc");
      `test(16'h00, dut.MEM_alu_out, "MEM alu_out");
      `test(3'h0, dut.MEM_rf_ws, "MEM rf_ws");
      `test(1'b1, dut.MEM_rf_wr, "MEM rf_wr");

      /********************************************************************************
       *  lbi r4, 0x04
       * ********************************************************************************/
      `tic;

      // IF
      `test(8, dut.IF_pc, "PC did not increment");
      `test(16'hc404, dut.IF_instr, "Instruction not correct");
      `test(16'h0a, dut.IF_next_pc, "Next_pc not correct");
      `test(16'h0a, dut.IF_pc_inc, "PC not incremented");

      // ID
      `test(16'hc303, dut.ID_instr, "ID instruction not correct");
      `test(16'h08, dut.ID_pc_inc, "ID pc_inc correct");      

      // EX
      `test(16'hc202, dut.EX_instr, "EX instruction");
      `test(16'h06, dut.EX_pc_inc, "EX PC inc");
      `test(16'h02, dut.EX_alu_out, "EX ALU out");
      `test(16'h02, dut.EX_rf_ws, "EX WS");
      `test(1, dut.EX_rf_wr, "EX RF_WR");
      `test(0, dut.EX_bt, "EX bt");

      // MEM
      `test(16'hc101, dut.MEM_instr, "MEM instr");
      `test(16'h04, dut.MEM_pc_inc, "MEM pc_inc");
      `test(16'h01, dut.MEM_alu_out, "MEM alu_out");
      `test(3'h1, dut.MEM_rf_ws, "MEM rf_ws");
      `test(1'b1, dut.MEM_rf_wr, "MEM rf_wr");      

      // WB
      `test(16'hc000, dut.WB_instr, "WB instr");
      `test(16'h02, dut.WB_pc_inc, "WB pc inc");
      `test(16'h00, dut.WB_alu_out, "WB alu out");
      `test(3'h0, dut.WB_rf_ws, "WB rf_ws");
      `test(1'b1, dut.WB_rf_wr, "WB rf_wr");
      `test(16'h0, dut.WB_rf_wd, "WB rf_wd");

      `info("Tests end");
      $stop;
   end // initial begin

endmodule // t_proc_pipe_bench

   
   
   
