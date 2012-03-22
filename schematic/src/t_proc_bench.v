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


      /****************************************/
      `info("lbi r0, 0x10");
      /****************************************/      

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
      `info("lbi r1, 0x01");      
      /****************************************/
      `test(16'h10, dut.rf.my_regs0.q, "R0 does not contain 0x10 after a lbi 0x10");

      // dut
      `test(16'h c101, dut.instr, "Instruction does not match: lbi r1, 0x01");
      `test(16'h 2, dut.pc, "PC should be 2 after first instruction");

      // add (destination decode)
      
      // write to rf
      `test(16'h 01, dut.rf_ws, "RF write select should be one");      
      `test(16'h 01, dut.rf_wd, "RF write data should be 0x01");

      

      /****************************************/
      `tic;
      `info("add r2, r0, r1");      
      /****************************************/
      `test(16'h01, dut.rf.my_regs1.q, "R1 does not contain 0x01 after lbi r1, 0x01");



      // dut
      `test(16'h 4, dut.pc, "PC should be 4 after second instruction");
      `test(16'h d828, dut.instr, "Instruction does not match: add r2, r0, r1");

      // rf
      `test(3'h 0, dut.rf.read1regsel, "RF internal read1 select is not 0");
      `test(3'h 1, dut.rf.read2regsel, "RF internal read2 select is not 1");      
      `test(16'h 10, dut.rf.read1data, "RF read1 data is not 0x10");
      `test(16'h 01, dut.rf.read2data, "RF read2 data is not 0x01");      
      
      `test(16'h 10, dut.rf.my_regs0.q, "RF did not hold value(0x10) for r0");
      `test(16'h 01, dut.rf.my_regs1.q, "RF did not hold value(0x01) for r1");      
      
      
      `test(3'h 0, dut.rf_rs1, "RF select 1 is not r0");
      `test(3'h 1, dut.rf_rs2, "RF select 2 is not r1");
      `test(16'h 10, dut.rf_rd1, "RF data 1 is not 0x10");
      `test(16'h 1, dut.rf_rd2, "RF data 2 is not 0x1");      
      
      

      // alu
      `test(16'h 10, dut.alu.A, "ALU primary op is not 0x10");
      `test(16'h 01, dut.alu.B, "ALU primary op is not 0x01");
      `test(16'h 11, dut.alu.add_Sum, "ALU internal sum is not 0x11");
      `test(16'h 10, dut.alu.opA, "ALU internal op A is not 0x10");
      `test(16'h 01, dut.alu.opB, "ALU internal op B is not 0x01");
      `test(16'h 11, dut.alu.adder.Sum, "ALU internal adder output is not 0x11");
      `test(16'h 10, dut.alu.adder.A, "ALU internal adder input A is not 0x10");
      `test(16'h 01, dut.alu.adder.B, "ALU internal adder input B is not 0x01");
      `test(16'h 00, dut.alu.Cin, "ALU carrying should be zero");
      
      `test(5'd 0, dut.alu.Op, "ALU opcode is not ADD (0)");
      `test(16'h 11, dut.alu.Out, "ALU output is not 0x11");

      /****************************************/
      `tic;
      `info("lbi r0, 0x01");      
      /****************************************/      
      // result
      `test(16'h 11, dut.rf.my_regs2.q, "R0(0x10) + R1(0x01) not put into R2");



      /****************************************/
      `tic;
      `info("lbi r1, 0x02");      
      /****************************************/
      
      /****************************************/
      `tic;
      `info("sub r2, r0, r1");      
      /****************************************/
      // result
      `test(16'h 01, dut.rf.my_regs0.q, "lbi r0, 0x01 did not load");
      `test(16'h 02, dut.rf.my_regs1.q, "lbi r1, 0x02 did not load");

      // alu
      `test(5'd 1, dut.alu.Op, "ALU opcode is not SUB (1)");

      /****************************************/
      `tic;
      `info("ror r2, r1, r0");
      /****************************************/
      // result
      `test(16'h1, dut.rf.my_regs2.q, "sub r2, r0, r1");

      /****************************************/
      `tic;
      `info("or r2, r0, r1");
      /****************************************/
      // result
      `test(16'h1, dut.rf.my_regs2.q, "ror r2, r1, r0");

      /****************************************/
      `tic;
      `info("and r2, r0, r1");      
      /****************************************/
      // result
      `test(16'h3, dut.rf.my_regs2.q, "or r2, r1, r0");

      /****************************************/
      `tic;
      `info("rol r2, r0, r1");      
      /****************************************/
      // result
      `test(16'h0, dut.rf.my_regs2.q, "and r2, r1, r0");

      /****************************************/
      `tic;
      `info("sll r2, r0, r1");      
      /****************************************/
      // result
      `test(16'h4, dut.rf.my_regs2.q, "rol r2, r1, r0");

      /****************************************/
      `tic;
      `info("sra r2, r0, r1");      
      /****************************************/
      // result
      `test(16'h4, dut.rf.my_regs2.q, "sll r2, r1, r0");

      /****************************************/
      `tic;
      `info("seq r2, r0, r1");      
      /****************************************/
      // result
      `test(16'h0, dut.rf.my_regs2.q, "sra r2, r1, r0");

      /****************************************/
      `tic;
      `info("slt r2, r0, r1");      
      /****************************************/
      // result
      `test(16'h0, dut.rf.my_regs2.q, "seq r2, r1, r0");

      /****************************************/
      `tic;
      `info("sle r2, r0, r1");      
      /****************************************/
      // result
      `test(16'h1, dut.rf.my_regs2.q, "slt r2, r1, r0");

      $display("%h", dut.alu_op);
      
      `test(3'h00, dut.rf_rs1, "rf rdselect1 should be 00");      
      `test(3'h01, dut.rf_rs2, "rf rdselect2 should be 01");

      `test(3'h00, dut.rf.read1regsel, "rf internal select1 should be 0");
      `test(3'h01, dut.rf.read2regsel, "rf internal select2 should be 1");      
      
      `test(16'h01, dut.rf.my_regs0.q, "reg0 should hold 01");
      `test(16'h01, dut.rf_rd1, "regData1 should be 01");
      `test(16'h02, dut.rf.my_regs1.q, "reg1 should hold 02");
      `test(16'h02, dut.rf_rd2, "regData2 should be 02");      

      
      `test(16'h01, dut.alu.opA, "slt opA should be 0x01");
      `test(16'h02, dut.alu.opB, "slt opA should be 0x02");      
      
      
      /****************************************/
      `tic;
      // addi
      /****************************************/
      // result
      `test(16'h1, dut.rf.my_regs2.q, "sle r2, r0, r1");


      /************************************************************
       *  IMMEDIATE OPS
       ************************************************************/
      `tic;
      `info("addi r2, r0, 0x09");
      `test(16'h 0a, dut.rf.my_regs2.q, "addi r2, r0, 0x09");

      `tic;
      `info("subi r2, r0, 0x01");
      `test(16'h 00, dut.rf.my_regs2.q, "subi r2, r0, 0x01");

      `tic;
      `info("ori r2, r0, 0x10");
      `test(16'h 11, dut.rf.my_regs2.q, "ori r2, r0, 0x10");
      /************************************************************
      *   SLBI
      ************************************************************/
      `test(16'h910b, dut.instr, "Instruction should be slbi");
      `test(20, dut.alu.Op, "ALU op should be slbi(20)");
      `test(16'h02, dut.alu.opA, "ALU opA should be r1(0x02)");

      `test(3'h01, dut.rf_rs1, "rf_rs1 should be 0x01");
      `test(16'h02, dut.rf.rf_rd1, "rf readdata1 should be 0x01");
      
      `test(16'h02, dut.aopd.opA, "alu op decode opA should be r0(0x01)");
      `test(16'h0b, dut.aopd.opB, "alu op decode opB should be 0x0b");
      `test(16'h02, dut.aopd.rsVal, "alu op decode input rsVal should be 0x01");
      `test(16'h20b, dut.alu.Out, "alu output should be 0x10b");

      `test(16'h20b, dut.rf.writedata, "RF write data should be correct");
      `test(3'h01, dut.rf.writeregsel, "RF write select should be correct");
      `test(1'b1, dut.rf.write, "RF write should be enabled");
      
      `tic;

      `info("slbi r0, 0xb");
      `test(16'h020b, dut.rf.my_regs1.q, "slbi");

      /************************************************************
       *  STU
       * ************************************************************/
      `tic;                     // lbi
      
      `test(3'h01, dut.rf.writeregsel, "RF write reg sel should be 1 on stu");
      `test(16'h04, dut.rf.writedata, "RF write data should be 0x04 on stu");
      `test(16'h04, dut.alu.Out, "ALU output on alu");
      `test(16'h02, dut.alu.A, "ALU input A");
      `test(16'h02, dut.alu.B, "ALU input B");

      /************************************************************
       *   JAL
       * ************************************************************/
      `tic;                     // stu

      $display("Instr: %h", dut.add.instr);
      $display("Op: %h", dut.add.op);
      $display("WE: %b", dut.add.we_reg);
      $display("RD: %h", dut.add.rd);

      `test(16'h3002, dut.instr, "Instruction should be JAL");
      `test(16'h3002, dut.add.instr, "ADD internal instr");
      `test(5'd22, dut.alu.Op, "ALU op should be JAL");
      `test(3'd7, dut.add.rd, "ADD dest should be 7");

      `test(dut.pc+2+2, dut.next_pc, "Next pc should be +4");
      `test(dut.pc+2, dut.rf_wd, "Should write pc+2 to r7");
      
      $display("%h", dut.rf.writedata);
      $display("%h", dut.rf.writeregsel);      
      
      $display("%h", dut.pc);
      
      `tic;                     // jal

      `test(16'h2e, dut.pc, "PC should increment by 4");

      /************************************************************
       *   SLT
       * ************************************************************/
      `tic;                     // addi
      `tic;                     // lbi
      `tic;                     // lbi

      `test(16'he828, dut.instr, "instruction is slt");
      `test(1, dut.rf.my_regs0.q, "RF 0 should be 1");
      `test(10, dut.rf.my_regs1.q, "RF 1 should be 10");
      `test(1, dut.rf_wd, "1 < 10?");
      
      `tic;                     // slt

      `test(1, dut.rf.my_regs2.q, "RF 2 should be 1");
      
      
      
      
      
      `info("Tests complete");
      $finish;
   end   

endmodule // t_proc_bench

