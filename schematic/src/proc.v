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

   
   /********************************************************************************
    *  Fetch Stage
    *********************************************************************************/
   // Wires
   wire [15:0] pc, pc_inc, pc_branch, next_pc; // Next pc logic
   wire [15:0] instr; // Instruction read from instruction memory

   // PC
   register pc_reg(.q(pc), 
                   .d(next_pc), 
                   .clk(clk),
                   .rst(rst),
                   .we(1'b1));

   // Next-pc logic
   assign next_pc = pc + 2;

   // Instruction memory
   memory2c instr_mem (
   		       // Inputs
		       .data_in (16'b0),
		       .addr (pc),
		       .enable (1'b1),
		       .wr(1'b0),
		       .createdump(1'b0),	// TODO change to correct value
		       .clk (clk),
		       .rst(rst),
		       // Outputs
		       .data_out (instr)
		       );

   /********************************************************************************
    *  Decode Stage
    *********************************************************************************/
   wire [4:0]  alu_op;
   alu_op_decode aod (.instr(instr),
                      .alu_op(alu_op));
   
   /********************************************************************************
    *  Fetch Stage
    *********************************************************************************/
   wire [2:0]  rf_rs1, rf_rs2, rf_ws; // Read/Write select
   wire [15:0] rf_rd1, rf_rd2, rf_wd; // Read/Write data
   wire        rf_wr;
   rf_bypass rf(.read1data(rf_rd1),
                .read2data(rf_rd2),
                .err(err),
                .clk(clk),
                .rst(rst),
                .read1regsel(rf_rs1),
                .read2regsel(rf_rs2),
                .writeregsel(rf_ws),
                .writedata(rf_wd),
                .write(rf_wr)
                );
   
   /********************************************************************************
    *  Execute Stage
    *********************************************************************************/
   wire [15:0] alu_op1, alu_op2, alu_out;
   wire        cin, alu_ofl, alu_zero, alu_signed;
   
   ALU alu(.A(alu_op1),
           .B(alu_op2),
           .Cin(cin),
           .Op(alu_op),
           .sign(alu_signed),
           .Out(alu_out),
           .OFL(alu_ofl),
           .Zero(alu_zero)
           );
   

   /********************************************************************************
    *  Memory Stage
    *********************************************************************************/

   /********************************************************************************
    *  Write Stage
    *********************************************************************************/         



   /********************************************************************************
    *
    *********************************************************************************/
   assign err = 0;
endmodule // proc
