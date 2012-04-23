module proc(
	    // Inputs
	    clk,
	    rst,
	    // Outputs
	    err
	    );
   // Inputs
   input clk;
   input rst;

   // Outputs
   output err;
   assign err = 0;

   // Internal
   wire   halt, stall;

   /********************************************************************************
    *   Wires
    *********************************************************************************/
   /****************************************
    *   Fetch
    ****************************************/   
   // Passed out
   wire [15:0] IF_instr, IF_pc_inc;

   // Internal
   wire [15:0] IF_pc, IF_next_pc; // Next pc logic

   /****************************************
    *   Decode
    ****************************************/   
   // Passed in
   wire [15:0] ID_instr, ID_pc_inc;

   // Passed out
   wire [15:0] ID_rf_rd1, ID_rf_rd2;
   wire [2:0]  ID_rf_ws;
   wire        ID_rf_wr;

   // Internal
   wire [2:0]  ID_rf_rs1, ID_rf_rs2; // Read/Write select

   /****************************************
    *   Execute
    ****************************************/
   // Passed in
   wire [15:0] EX_instr, EX_pc_inc, EX_rf_rd2, EX_rf_rd1;
   wire [2:0]  EX_rf_ws;
   wire        EX_rf_wr;

   // Passed out
   wire [15:0] EX_alu_out, EX_brj_dest_addr;
   wire        EX_bt;

   // Internal
   wire        EX_alu_ofl, EX_alu_zero;
   wire [15:0] EX_alu_op1, EX_alu_op2;
   wire [4:0]  EX_alu_op;

   /****************************************
    *   Memory
    ****************************************/      
   // Passed in
   wire [15:0] MEM_instr, MEM_pc_inc, MEM_alu_out, MEM_rf_rd2;
   wire [2:0]  MEM_rf_ws;
   wire        MEM_rf_wr;

   // Passed out
   wire [15:0] MEM_mem_out;

   // Internal   
   wire        MEM_we_mem, MEM_wr_mem, MEM_halt;

   /****************************************
    *   Write
    ****************************************/
   // Passed in
   wire [15:0] WB_instr, WB_pc_inc, WB_mem_out, WB_alu_out;
   wire [2:0]  WB_rf_ws;
   wire        WB_rf_wr;
   
   // Passed out
   wire [15:0] WB_rf_wd;

   /********************************************************************************
    *  Fetch Stage
    *********************************************************************************/

   // PC + 2
   add16 incpc (.A(16'd2), 
		.B(IF_pc),
		.CI (1'b0), 
		.Sum(IF_pc_inc), 
		.CO(), 
		.Ggroup(), 
		.Pgroup()
		);

   // Next-pc logic
   next_pc_addr npca (
                      // Inputs
                      .instr(EX_instr), // Instr @ EX
		      .pc_inc(IF_pc_inc), // PC + 2 @ IF
		      .alu_out(EX_alu_out), // alu_out @ EX
		      .brj_dest(EX_brj_dest_addr), // brj_dest @ EX
		      .bt(EX_bt),                  // bt @ EX
                      .stall(stall),
                      .pc(IF_pc),
                      // Outputs
                      .next_pc(IF_next_pc)
		      );

   // Instruction memory
   memory2c instr_mem (
   		       // Inputs
		       .data_in (16'b0),
		       .addr (IF_pc),
		       .enable (1'b1),
		       .wr(1'b0),
		       .createdump(1'b0),
		       .clk (clk),
		       .rst(rst),
		       // Outputs
		       .data_out (IF_instr)
		       );
   // PC
   register pc_reg(.q(IF_pc), 
                   .d(IF_next_pc), 
                   .clk(clk),
                   .rst(rst),
                   .we(1'b1));

   /********************************************************************************
    *  Decode Stage
    *********************************************************************************/
   wire [15:0] IF_instr_in;
   wire [15:0] ID_instr_out;
   wire [15:0] IF_pc_inc_in;

   // Stalling?
   assign stall = (ID_rf_rs1 == EX_rf_ws  && EX_rf_wr)  ||
                  (ID_rf_rs1 == MEM_rf_ws && MEM_rf_wr) ||
                  (ID_rf_rs1 == WB_rf_ws  && WB_rf_wr)  ||
                  (ID_rf_rs2 == EX_rf_ws  && EX_rf_wr)  ||
                  (ID_rf_rs2 == MEM_rf_ws && MEM_rf_wr) ||
                  (ID_rf_rs2 == WB_rf_ws  && WB_rf_wr);

   assign IF_instr_in = (rst | EX_bt) ? 16'h0800 :          // On reset or branch_taken, insert NOP
                        stall ? ID_instr_out : IF_instr;  // On stall, hold.  Else, take in piped value
   assign ID_instr = (stall | EX_bt) ? 16'h0800 : ID_instr_out;     // Send out NOP on stall
   assign IF_pc_inc_in = stall ? ID_pc_inc : IF_pc_inc;

   // Pipelined regs
   register IF_ID_instr  (.d(IF_instr_in),   .q(ID_instr_out), .clk(clk), .rst(1'b0), .we(1'b1)); // Init'd
   register IF_ID_pc_inc (.d(IF_pc_inc_in),  .q(ID_pc_inc), .clk(clk), .rst(rst), .we(1'b1));   
   
   // Assign Rs, Rt
   assign ID_rf_rs1 = ID_instr_out[10:8]; // Rs
   assign ID_rf_rs2 = (ID_instr_out[15:11] != 5'b01110) ? ID_instr_out[7:5] : 3'd7;  // Rt, R7 upon RET instr

   // Decode instruction destination
   alu_destination_decode add(
                              // Inputs
                              .instr(ID_instr),
                              // Outputs
                              .rd(ID_rf_ws),
			      .we_reg (ID_rf_wr)
                              );
                         

   /********************************************************************************
    *  Execute Stage
    *********************************************************************************/
   wire [15:0] ID_instr_in;
   assign ID_instr_in = rst ? 16'h0800 : ID_instr;

   // Pipelined regs
   register #(.WIDTHreg(3)) ID_EX_rf_ws  (.d(ID_rf_ws),      .q(EX_rf_ws), .clk(clk), .rst(rst), .we(1'b1));
   register #(.WIDTHreg(1)) ID_EX_rf_wr  (.d(ID_rf_wr),      .q(EX_rf_wr), .clk(clk), .rst(rst), .we(1'b1));
   register ID_EX_instr  (.d(ID_instr_in),   .q(EX_instr), .clk(clk), .rst(1'b0), .we(1'b1)); // Init'd
   register ID_EX_pc_inc (.d(ID_pc_inc),  .q(EX_pc_inc), .clk(clk), .rst(rst), .we(1'b1));

   register ID_EX_rf_rd1 (.d(ID_rf_rd1), .q(EX_rf_rd1), .clk(clk), .rst(rst), .we(1'b1));      
   register ID_EX_rf_rd2 (.d(ID_rf_rd2), .q(EX_rf_rd2), .clk(clk), .rst(rst), .we(1'b1));   
   
   // Decode instruction operands (post-fetch)	
   alu_operand_decode aopd(
                           // Inputs
                           .instr(EX_instr),
                           .rsVal(EX_rf_rd1),
                           .rtVal(EX_rf_rd2),
                           // Outputs
                           .opA(EX_alu_op1),
                           .opB(EX_alu_op2)
                           );   

   // Decode instruction opcode
   alu_op_decode aod (
                      // Inputs
                      .instr(EX_instr),
                      // Outputs
                      .alu_op(EX_alu_op));


   // ALU
   ALU alu(
           // Inputs
           .A(EX_alu_op1),
           .B(EX_alu_op2),
           .Op(EX_alu_op),
           .sign(1'b1),
           // Outputs
           .Out(EX_alu_out),
           .OFL(EX_alu_ofl),
           .Zero(EX_alu_zero)
           );

   branch_logic bl (
                    // Inputs
                    .op(EX_instr[15:11]), 
		    .zero(EX_alu_zero), 
		    .top_alu(EX_alu_out[15]),
                    // Outputs
		    .bt(EX_bt));


   // Calculate branch/jump destination address
   brj_addr_calc bac (
                      // Inputs
                      .instr(EX_instr), 
		      .next_pc(EX_pc_inc),
                      // Outputs
		      .dest_addr(EX_brj_dest_addr)); 
   

   /********************************************************************************
    *  Memory Stage
    *********************************************************************************/
   wire        EX_rf_wr_in;
   wire [15:0] EX_instr_in;
   
   assign EX_rf_wr_in = rst ? 0 : EX_rf_wr;
   assign EX_instr_in = rst ? 16'h0800 : EX_instr;
   
   // Pipelined regs
   register EX_MEM_instr   (.d(EX_instr_in),   .q(MEM_instr), .clk(clk), .rst(1'b0), .we(1'b1)); // Init'd
   register EX_MEM_pc_inc  (.d(EX_pc_inc),  .q(MEM_pc_inc), .clk(clk), .rst(rst), .we(1'b1));
   register EX_MEM_alu_out (.d(EX_alu_out), .q(MEM_alu_out), .clk(clk), .rst(rst), .we(1'b1));
   register #(.WIDTHreg(3)) EX_MEM_rf_ws  (.d(EX_rf_ws),   .q(MEM_rf_ws), .clk(clk), .rst(rst), .we(1'b1));
   register #(.WIDTHreg(1)) EX_MEM_rf_wr  (.d(EX_rf_wr_in),   .q(MEM_rf_wr), .clk(clk), .rst(1'b0), .we(1'b1)); // Init'd

   register EX_MEM_rf_rd2  (.d(EX_rf_rd2), .q(MEM_rf_rd2), .clk(clk), .rst(rst), .we(1'b1));
   
   mem_decode_logic mdl (
                         // Inputs
                         .instr(MEM_instr),
                         // Outputs
			 .e_mem(MEM_we_mem),
			 .wr_mem(MEM_wr_mem),
			 .halt(MEM_halt)
			 );
   
   memory2c data_mem (
   		      // Inputs
		      .data_in (MEM_rf_rd2),
		      .addr (MEM_alu_out),
		      .enable (MEM_we_mem),
		      .wr(MEM_wr_mem),
		      .createdump(1'b0),	
		      .clk (clk),
		      .rst(rst),
		      // Outputs
		      .data_out (MEM_mem_out)
		      );
   
   
   /********************************************************************************
    *  Write Stage
    *********************************************************************************/
   wire        MEM_rf_wr_in;
   assign MEM_rf_wr_in = rst ? 0 : MEM_rf_wr;

   // Halt detection
   assign halt = MEM_instr[15:11] == 5'b00000;

   // Pipelined regs
   register MEM_WB_instr  (.d(MEM_instr),   .q(WB_instr), .clk(clk), .rst(rst), .we(1'b1));
   register MEM_WB_pc_inc (.d(MEM_pc_inc),  .q(WB_pc_inc), .clk(clk), .rst(rst), .we(1'b1));
   register MEM_WB_alu_out(.d(MEM_alu_out), .q(WB_alu_out), .clk(clk), .rst(rst), .we(1'b1));
   register MEM_WB_mem_out(.d(MEM_mem_out), .q(WB_mem_out), .clk(clk), .rst(rst), .we(1'b1));
   register #(.WIDTHreg(3)) MEM_WB_rf_ws  (.d(MEM_rf_ws),   .q(WB_rf_ws), .clk(clk), .rst(rst), .we(1'b1));
   register #(.WIDTHreg(1)) MEM_WB_rf_wr  (.d(MEM_rf_wr_in),   .q(WB_rf_wr), .clk(clk), .rst(1'b0), .we(1'b1)); // Initialized
   
   // determine which data to write back into the register file
   dest_data_decode ddd (
                         // Inputs
                         .instr(WB_instr), 
			 .next_pc(WB_pc_inc), 
			 .alu_out(WB_alu_out), 
			 .mem_out(WB_mem_out),
                         // Outputs
			 .rdata (WB_rf_wd)
                         );       
   
   /********************************************************************************
    *
    *********************************************************************************/
   // RF fetching
   rf rf(
         // Inputs
         .err(err),
         .clk(clk),
         .rst(rst),
         .read1regsel(ID_rf_rs1),  // ID
         .read2regsel(ID_rf_rs2),  // ID
         .writeregsel(WB_rf_ws), // WB
         .writedata(WB_rf_wd),   // WB
         .write(WB_rf_wr),       // WB
         // Outputs
         .read1data(ID_rf_rd1), // ID
         .read2data(ID_rf_rd2)  // ID
         );
   

endmodule // proc
