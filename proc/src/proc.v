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

   /********************************************************************************
    *   Wires
    *********************************************************************************/
   /****************************************
    *   Fetch
    ****************************************/   
   // Wires
   wire [15:0] pc, pc_inc, pc_branch, next_pc; // Next pc logic
   wire [15:0] instr; // Instruction read from instruction memory   
          
   /****************************************
    *   Execute
    ****************************************/
   wire [15:0] alu_op1, alu_op2, alu_out, brj_dest_addr;
   wire        cin, alu_ofl, alu_zero, alu_signed, bt;

   /****************************************
    *   Decode
    ****************************************/   
   wire [4:0]  alu_op;
   wire [2:0]  rf_rs1, rf_rs2, rf_ws; // Read/Write select
   wire [15:0] rf_rd1, rf_rd2, rf_wd; // Read/Write data
   wire        rf_wr;

   /****************************************
    *   Memory
    ****************************************/      
   wire        we_mem, wr_mem, halt, cd;   

   /****************************************
    *   Write
    ****************************************/         
   wire [15:0] mem_out;
   

   /********************************************************************************
    *  Fetch Stage
    *********************************************************************************/

   // PC + 2
   add16 incpc (.A(16'h0002), 
		.B(pc),
		.CI (1'b0), 
		.Sum(pc_inc), 
		.CO(), 
		.Ggroup(), 
		.Pgroup()
		);

   // Next-pc logic
   next_pc_addr npca (
                      // Inputs
                      .instr(instr), // Instr @ EX
		      .pc_inc(pc_inc), // PC + 2 @ IF
		      .alu_out(alu_out), // alu_out @ EX
		      .brj_dest(brj_dest_addr), // brj_dest @ EX
		      .bt(bt),                  // bt @ EX
                      // Outputs
		      .next_pc(next_pc)
		      );

   // Instruction memory
   memory2c instr_mem (
   		       // Inputs
		       .data_in (16'b0),
		       .addr (pc),
		       .enable (1'b1),
		       .wr(1'b0),
		       .createdump(1'b0),
		       .clk (clk),
		       .rst(rst),
		       // Outputs
		       .data_out (instr)
		       );
   // PC
   register pc_reg(.q(pc), 
                   .d(next_pc), 
                   .clk(clk),
                   .rst(rst),
                   .we(1'b1));

   /********************************************************************************
    *  Decode Stage
    *********************************************************************************/
   // Assign Rs, Rt
   assign rf_rs1 = instr[10:8]; // Rs
   assign rf_rs2 = (instr[15:11] != 5'b01110) ? instr[7:5] : 3'b111;  // Rt, R7 upon RET instr

   /********************************************************************************
    *  Execute Stage
    *********************************************************************************/
   // Decode instruction operands (post-fetch)	
   alu_operand_decode aopd(
                           // Inputs
                           .instr(instr),
                           .rsVal(rf_rd1),
                           .rtVal(rf_rd2),
                           // Outputs
                           .opA(alu_op1),
                           .opB(alu_op2)
                           );   

   // Decode instruction opcode
   alu_op_decode aod (
                      // Inputs
                      .instr(instr),
                      // Outputs
                      .alu_op(alu_op));

   // Decode instruction destination
   alu_destination_decode add(
                              // Inputs
                              .instr(instr),
                              // Outputs
                              .rd(rf_ws),
			      .we_reg (rf_wr)
                              );

   // ALU
   ALU alu(.A(alu_op1),
           .B(alu_op2),
           .Op(alu_op),
           .sign(alu_signed),
           .Out(alu_out),
           .OFL(alu_ofl),
           .Zero(alu_zero)
           );

   branch_logic bl (.op(instr[15:11]), 
		    .zero(alu_zero), 
		    .top_alu(alu_out[15]), 
		    .bt(bt));


   // Calculate branch/jump destination address
   brj_addr_calc bac (.instr(instr), 
		      .next_pc(pc_inc), 
		      .dest_addr(brj_dest_addr)); 
   

   /********************************************************************************
    *  Memory Stage
    *********************************************************************************/
   mem_decode_logic mdl (
                         // Inputs
                         .instr(instr),
                         // Outputs
			 .e_mem(we_mem),
			 .wr_mem(wr_mem),
			 .halt(halt)
			 );
   
   memory2c data_mem (
   		      // Inputs
		      .data_in (rf_rd2),
		      .addr (alu_out),
		      .enable (we_mem),
		      .wr(wr_mem),
		      .createdump(cd),	
		      .clk (clk),
		      .rst(rst),
		      // Outputs
		      .data_out (mem_out)
		      );
   
   
   /********************************************************************************
    *  Write Stage
    *********************************************************************************/
   
   
   // determine which data to write back into the register file
   dest_data_decode ddd (
                         // Inputs
                         .instr(instr), 
			 .next_pc(pc_inc), 
			 .alu_out(alu_out), 
			 .mem_out(mem_out),
                         // Outputs
			 .rdata (rf_wd)
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
                .read1regsel(rf_rs1),
                .read2regsel(rf_rs2),
                .writeregsel(rf_ws),
                .writedata(rf_wd),
                .write(rf_wr),
                // Outputs
                .read1data(rf_rd1),
                .read2data(rf_rd2)
                );
   

endmodule // proc
