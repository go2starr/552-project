`include "testbench.v"

module t_proc_forward_bench();
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
       *   lbi r0, 0x0
       * ********************************************************************************/
      `tic;
      `tic;
      `tic;

      // IF
      `test(0, dut.IF_pc, "(1) PC did not reset to 0");
      `test(16'hc000, dut.IF_instr, "(1) Instruction not correct");
      `test(16'h02, dut.IF_next_pc, "(1) Next_pc not correct");
      `test(16'h02, dut.IF_pc_inc, "(1) PC not incremented");

      /********************************************************************************
       *  addi r1, r0, 0x1
       * ********************************************************************************/
      `tic;

      // IF
      `test(2, dut.IF_pc, "(2) PC did not increment");
      `test(16'h4021, dut.IF_instr, "(2) Instruction not correct");
      `test(16'h04, dut.IF_next_pc, "(2) Next_pc not correct");
      `test(16'h04, dut.IF_pc_inc, "(2) PC not incremented");

      // ID
      `test(16'hc000, dut.ID_instr, "(2) ID instruction not correct");
      `test(16'h02, dut.ID_pc_inc, "(2) ID pc_inc correct");

      /********************************************************************************
       *  lbi r2, 0x02
       * ********************************************************************************/
      `tic;

      // IF
      `test(4, dut.IF_pc, "(3) PC did not increment");
      `test(16'hc202, dut.IF_instr, "(3) Instruction not correct");
      `test(16'h06, dut.IF_next_pc, "(3) Next_pc not correct");
      `test(16'h06, dut.IF_pc_inc, "(3) PC not incremented");

      // ID
      `test(16'h4021, dut.ID_instr, "(3) ID instruction not correct");
      `test(16'h04, dut.ID_pc_inc, "(3) ID pc_inc correct");  
      `test(1'b1, dut.forwardMemExRs1, "(3) forwardMemExRs1");    
      `test(1'b0, dut.forwardWbExRs1, "(3) forwardWbExRS1");
      `test(1'b0, dut.forwardMemExRs2, "(3) forwardMemExRs2");
      `test(1'b0, dut.forwardWbExRs2, "(3) forwardWbExRs2");


      // EX
      `test(16'hc000, dut.EX_instr, "(3) EX instruction");
      `test(16'h02, dut.EX_pc_inc, "(3) EX PC inc");
      `test(16'h00, dut.EX_alu_out, "(3) EX ALU out");
      `test(16'h00, dut.EX_rf_ws, "(3) EX WS");
      `test(1, dut.EX_rf_wr, "(3) EX RF_WR");
      `test(0, dut.EX_bt, "(3) EX bt");

      /********************************************************************************
       *  lbi r3, 0x03
       * ********************************************************************************/
      `tic;

      // IF
      `test(6, dut.IF_pc, "(4) PC did not increment");
      `test(16'hc303, dut.IF_instr, "(4) Instruction not correct");
      `test(16'h08, dut.IF_next_pc, "(4) Next_pc not correct");
      `test(16'h08, dut.IF_pc_inc, "(4) PC not incremented");

      // ID
      `test(16'hc202, dut.ID_instr, "(4) ID instruction not correct");
      `test(16'h06, dut.ID_pc_inc, "(4) ID pc_inc correct");      

      // EX
      `test(16'h00, dut.EX_rf_rd1, "(4) EX rf_rd1");
      `test(16'h4021, dut.EX_instr, "(4) EX instruction");
      `test(16'h04, dut.EX_pc_inc, "(4) EX PC inc");
      `test(16'h01, dut.EX_alu_out, "(4) EX ALU out");
      `test(16'h01, dut.EX_rf_ws, "(4) EX WS");
      `test(1, dut.EX_rf_wr, "(4) EX RF_WR");
      `test(0, dut.EX_bt, "(4) EX bt");

      // MEM
      `test(16'hc000, dut.MEM_instr, "(4) MEM instr");
      `test(16'h02, dut.MEM_pc_inc, "(4) MEM pc_inc");
      `test(16'h00, dut.MEM_alu_out, "(4) MEM alu_out");
      `test(3'h0, dut.MEM_rf_ws, "(4) MEM rf_ws");
      `test(1'b1, dut.MEM_rf_wr, "(4) MEM rf_wr");

      /********************************************************************************
       *  st r1, r0, 0x00
       * ********************************************************************************/
      `tic;

      // IF
      `test(8, dut.IF_pc, "(5) PC did not increment");
      `test(16'h8020, dut.IF_instr, "(5) Instruction not correct");
      `test(16'h0a, dut.IF_next_pc, "(5) Next_pc not correct");
      `test(16'h0a, dut.IF_pc_inc, "(5) PC not incremented");

      // ID
      `test(16'hc303, dut.ID_instr, "(5) ID instruction not correct");
      `test(16'h08, dut.ID_pc_inc, "(5) ID pc_inc correct");      

      // EX
      `test(16'hc202, dut.EX_instr, "(5) EX instruction");
      `test(16'h06, dut.EX_pc_inc, "(5) EX PC inc");
      `test(16'h02, dut.EX_alu_out, "(5) EX ALU out");
      `test(16'h02, dut.EX_rf_ws, "(5) EX WS");
      `test(1, dut.EX_rf_wr, "(5) EX RF_WR");
      `test(0, dut.EX_bt, "(5) EX bt");

      // MEM
      `test(16'h4021, dut.MEM_instr, "(5) MEM instr");
      `test(16'h04, dut.MEM_pc_inc, "(5) MEM pc_inc");
      `test(16'h01, dut.MEM_alu_out, "(5) MEM alu_out");
      `test(3'h1, dut.MEM_rf_ws, "(5) MEM rf_ws");
      `test(1'b1, dut.MEM_rf_wr, "(5) MEM rf_wr");      

      // WB
      `test(16'hc000, dut.WB_instr, "(5) WB instr");
      `test(16'h02, dut.WB_pc_inc, "(5) WB pc inc");
      `test(16'h00, dut.WB_alu_out, "(5) WB alu out");
      `test(3'h0, dut.WB_rf_ws, "(5) WB rf_ws");
      `test(1'b1, dut.WB_rf_wr, "(5) WB rf_wr");
      `test(16'h0, dut.WB_rf_wd, "(5) WB rf_wd");
         
      /********************************************************************************
      *  ld r2, r0, 0x0
      ********************************************************************************/
      `tic;
 
      // IF
      `test(16'h0a, dut.IF_pc, "(6) PC did not increment");
      `test(16'h8840, dut.IF_instr, "(6) Instruction not correct");
      `test(16'h0c, dut.IF_next_pc, "(6) Next_pc not correct");   
      `test(16'h0c, dut.IF_pc_inc, "(6) PC not incremented");

      // ID
      `test(16'h8020, dut.ID_instr, "(6) ID instruction not correct");
      `test(16'h0a, dut.ID_pc_inc, "(6) ID pc_inc incorrect");
      
      // EX
      `test(16'hc303, dut.EX_instr, "(6) EX instruction not correct");
      `test(16'h8, dut.EX_pc_inc, "(6) EX pc_inc incorrect");     
      `test(16'h3, dut.EX_alu_out, "(6) EX ALU out");
      `test(3'h3, dut.EX_rf_ws, "(6) EX WS");
      `test(1, dut.EX_rf_wr, "(6) EX RF_WR");
      `test(0, dut.EX_bt, "(6) EX bt"); 

      // MEM
      `test(16'hc202, dut.MEM_instr, "(6) MEM instruction not correct");
      `test(16'h06, dut.MEM_pc_inc, "(6) MEM pc_inc");
      `test(16'h02, dut.MEM_alu_out, "(6) MEM alu_out");
      `test(3'h2, dut.MEM_rf_ws, "(6) MEM rf_ws");
      `test(1'b1, dut.MEM_rf_wr, "(6) MEM rf_wr");

      // WB
      `test(16'h4021, dut.WB_instr, "(6) WB instr");
      `test(16'h04, dut.WB_pc_inc, "(6) WB pc inc");
      `test(16'h01, dut.WB_alu_out, "(6) WB alu out");
      `test(3'h1, dut.WB_rf_ws, "(6) WB rf_ws");
      `test(1, dut.WB_rf_wr, "(6) WB rf_wr");
      `test(16'h1, dut.WB_rf_wd, "(6) WB rf_wd");  
             
      /********************************************************************************
      *   add r0, r2, r1
      **********************************************************************************/
      `tic;
      // IF
      `test(16'h0c, dut.IF_pc, "(7) PC did not increment");
      `test(16'hda20, dut.IF_instr, "(7) Instruction not correct");
      `test(16'h0e, dut.IF_next_pc, "(7) Next_pc not correct");
      `test(16'h0e, dut.IF_pc_inc, "(7) ID pc_inc incorrect");  

      // ID
      `test(16'h0c, dut.ID_pc_inc, "(7) ID pc_inc incorrect");
      `test(16'h8840, dut.ID_instr, "(7) ID Instruction not correct");
 
      // EX
      `test(16'h8020, dut.EX_instr, "(7) EX instruction not correct");
      `test(16'h0a, dut.EX_pc_inc, "(7)  EX pc_inc incorrect");
      `test(16'h0, dut.EX_alu_out, "(7) EX ALU out");
      `test(0, dut.EX_rf_wr, "(7) EX RF_WR");
      `test(0, dut.EX_bt, "(7) EX bt"); 
      
      // MEM
      `test(16'hc303, dut.MEM_instr, "(7) MEM instruction not correct");
      `test(16'h8, dut.MEM_pc_inc, "(7) MEM pc_inc incorrect");     
      `test(16'h3, dut.MEM_alu_out, "(7) MEM ALU out");
      `test(1, dut.MEM_rf_wr, "(7) MEM rf_wr"); 
      `test(3'h3, dut.MEM_rf_ws, "(7) MEM rf_ws incorrect");

      // WB
      `test(16'hc202, dut.WB_instr, "(7) WB instruction not correct");
      `test(16'h06, dut.WB_pc_inc, "(7) WB pc_inc");
      `test(16'h02, dut.WB_rf_wd, "(7) WB rf_wd");
      `test(3'h2, dut.WB_rf_ws, "(7) WB rf_ws");
      `test(1'b1, dut.WB_rf_wr, "(7) WB rf_wr");

      /*********************************************************************************
      *   lbi r4, 4
      *********************************************************************************/
      `tic;
      
      // IF
      `test(16'h0e, dut.IF_pc, "(8) PC did not increment");
      `test(16'hc404, dut.IF_instr, "(8) Instruction not correct");
      `test(16'h0e, dut.IF_next_pc, "(8) Next_pc not correct");
      `test(16'h10, dut.IF_pc_inc, "(8) ID pc_inc incorrect");  
       
      // ID
      `test(16'h0e, dut.ID_pc_inc, "(8) ID pc_inc incorrect");
      `test(16'hda20, dut.ID_instr, "(8) ID Instruction not correct");
      `test(1, dut.stall, "(8) stall incorrect");
      `test(1, dut.EX_instr, "Ex Instr");
 
      `tic;
      `test(1, dut.IF_instr, "IF");
      `test(1, dut.ID_instr, "ID");
      `test(1, dut.EX_instr, "EX");
      `test(1, dut.MEM_instr, "MEM");
      `test(1, dut.WB_instr, "WB");

      `tic; 
       `test(1, dut.IF_instr, "IF");
      `test(1, dut.ID_instr, "ID");
      `test(1, dut.EX_instr, "EX");
      `test(1, dut.MEM_instr, "MEM");
      `test(1, dut.WB_instr, "WB");
 

      `tic;
      `test(1, dut.IF_instr, "IF");
      `test(1, dut.ID_instr, "ID");
      `test(1, dut.EX_instr, "EX");
      `test(1, dut.MEM_instr, "MEM");
      `test(1, dut.WB_instr, "WB");

      `tic;
      `test(1, dut.IF_instr, "IF");
      `test(1, dut.ID_instr, "ID");
      `test(1, dut.EX_instr, "EX");
      `test(1, dut.MEM_instr, "MEM");
      `test(1, dut.WB_instr, "WB");

      `info("Tests end");
      $stop;
   end // initial begin

endmodule // t_proc_pipe_bench

   
   
   
