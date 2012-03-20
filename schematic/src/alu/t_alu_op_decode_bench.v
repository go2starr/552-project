module t_alu_op_decode_bench();

   // Inputs
   reg [15:0] instr; 
  
   // Outputs
   wire [4:0] out;

   // parameters
	parameter ADD   = 0;
	parameter SUB   = 1;
	parameter OR    = 2;
	parameter AND   = 3;
	parameter ROL   = 4;
	parameter SLL   = 5;
	parameter ROR   = 6;
	parameter SRA   = 7;
	parameter ST    = 8;
	parameter LD    = 9;
	parameter STU   = 10;
	parameter BTR   = 11;
	parameter SEQ   = 12;
	parameter SLT   = 13;
	parameter SLE   = 14;
	parameter SCO   = 15;
	parameter BEQZ  = 16;
	parameter BNEZ  = 17;
	parameter BLTZ  = 18;
	parameter LBI   = 19;
	parameter SLBI  = 20;
	parameter JINST = 21;
	parameter JAL   = 22;
	parameter JR    = 23;
	parameter JALR  = 24;
	parameter RET   = 25;
	parameter SIIC  = 26;
	parameter RTI   = 27;
	parameter NOP   = 28;
	parameter HALT  = 29;

	// clock reset module
	wire clk;
	wire rst;
	reg err;
	clkrst cr1 (.clk(clk), .rst(rst), .err(err));

   // Instantiate
   alu_op_decode aluop (.instr(instr), .alu_op (out));

   // Debug
   task compare;
      input [4:0] ex, got;
      begin
         #2;
         if (ex !== got)
           $display ("ERR: Expected: 0x%d Got: 0x%d", ex, got);
      end
   endtask // compare

   initial begin
      $display("Starting tests...");
		instr = 16'b0000000000000000;
		#2;
		
	   ////////////////////////////////////////
      $display("Testing HALT...");
      ////////////////////////////////////////
		instr = 16'b0000000000000000;
   	#2;   
		compare(HALT, out);

	   ////////////////////////////////////////
      $display("Testing NOP...");
      ////////////////////////////////////////
		instr = 16'b0000100000000000;
		#2;
		compare (NOP, out);

		////////////////////////////////////////
      $display("Testing ADDI...");
      ////////////////////////////////////////
		instr = 16'b0100000000000000;
		#2;
		compare (ADD, out);

		////////////////////////////////////////
      $display("Testing SUBI...");
      ////////////////////////////////////////
		instr = 16'b0100100000000000;
		#2;
		compare (SUB, out);

		////////////////////////////////////////
      $display("Testing ORI...");
      ////////////////////////////////////////
		instr = 16'b0101000000000000;
		#2;
		compare (OR, out);

		////////////////////////////////////////
      $display("Testing ANDI...");
      ////////////////////////////////////////
		instr = 16'b0101100000000000;
		#2;
		compare (AND, out);

		////////////////////////////////////////
      $display("Testing ROLI...");
      ////////////////////////////////////////
		instr = 16'b1010000000000000;
		#2;
		compare (ROL, out);

		////////////////////////////////////////
      $display("Testing SLLI...");
      ////////////////////////////////////////
		instr = 16'b1010100000000000;
		#2;
		compare (SLL, out);

		////////////////////////////////////////
      $display("Testing RORI...");
      ////////////////////////////////////////
		instr = 16'b1011000000000000;
		#2;
		compare (ROR, out);

		////////////////////////////////////////
      $display("Testing SRAI...");
      ////////////////////////////////////////
		instr = 16'b1011100000000000;
		#2;
		compare (SRA, out);

		////////////////////////////////////////
      $display("Testing ST...");
      ////////////////////////////////////////
		instr = 16'b1000000000000000;
		#2;
		compare (ST, out);

		////////////////////////////////////////
      $display("Testing LD...");
      ////////////////////////////////////////
		instr = 16'b1000100000000000;
		#2;
		compare (LD, out);

		////////////////////////////////////////
      $display("Testing STU...");
      ////////////////////////////////////////
		instr = 16'b1001100000000000;
		#2;
		compare (STU, out);

		////////////////////////////////////////
      $display("Testing BTR...");
      ////////////////////////////////////////
		instr = 16'b1100100000000000;
		#2;
		compare (BTR, out);

		////////////////////////////////////////
      $display("Testing ADD...");
      ////////////////////////////////////////
		instr = 16'b1101100000000000;
		#2;
		compare (ADD, out);

		////////////////////////////////////////
      $display("Testing SUB...");
      ////////////////////////////////////////
		instr = 16'b1101100000000001;
		#2;
		compare (SUB, out);

		////////////////////////////////////////
      $display("Testing OR...");
      ////////////////////////////////////////
		instr = 16'b1101100000000010;
		#2;
		compare (OR, out);

		////////////////////////////////////////
      $display("Testing AND...");
      ////////////////////////////////////////
		instr = 16'b1101100000000011;
		#2;
		compare (AND, out);

		////////////////////////////////////////
      $display("Testing ROL...");
      ////////////////////////////////////////
		instr = 16'b1101000000000000;
		#2;
		compare (ROL, out);

		////////////////////////////////////////
      $display("Testing SLL...");
      ////////////////////////////////////////
		instr = 16'b1101000000000001;
		#2;
		compare (SLL, out);

		////////////////////////////////////////
      $display("Testing ROR...");
      ////////////////////////////////////////
		instr = 16'b1101000000000010;
		#2;
		compare (ROR, out);

		////////////////////////////////////////
      $display("Testing SRA...");
      ////////////////////////////////////////
		instr = 16'b1101000000000011;
		#2;
		compare (SRA, out);

		////////////////////////////////////////
      $display("Testing BEQZ...");
      ////////////////////////////////////////
		instr = 16'b0110000000000001;
		#2;
		compare (BEQZ, out);

		////////////////////////////////////////
      $display("Testing BNEZ...");
      ////////////////////////////////////////
		instr = 16'b01101000000000001;
		#2;
		compare (BNEZ, out);

		////////////////////////////////////////
      $display("Testing BLTZ...");
      ////////////////////////////////////////
		instr = 16'b0111100000000001;
		#2;
		compare (BLTZ, out);

		////////////////////////////////////////
      $display("Testing LBI...");
      ////////////////////////////////////////
		instr = 16'b1100000000000001;
		#2;
		compare (LBI, out);

		////////////////////////////////////////
      $display("Testing SLBI...");
      ////////////////////////////////////////
		instr = 16'b1001000000000001;
		#2;
		compare (SLBI, out);

		////////////////////////////////////////
      $display("Testing J...");
      ////////////////////////////////////////
		instr = 16'b0010000000000001;
		#2;
		compare (JINST, out);

		////////////////////////////////////////
      $display("Testing JR...");
      ////////////////////////////////////////
		instr = 16'b0010100000000001;
		#2;
		compare (JR, out); 

		////////////////////////////////////////
      $display("Testing JAL...");
      ////////////////////////////////////////
		instr = 16'b0011000000000001;
		#2;
		compare (JAL, out); 

		////////////////////////////////////////
      $display("Testing JALR...");
      ////////////////////////////////////////
		instr = 16'b0011100000000001;
		#2;
		compare (JALR, out); 

		////////////////////////////////////////
      $display("Testing RET...");
      ////////////////////////////////////////
		instr = 16'b0111000000000001;
		#2;
		compare (RET, out); 

		////////////////////////////////////////
      $display("Testing SIIC...");
      ////////////////////////////////////////
		instr = 16'b0001000000000001;
		#2;
		compare (SIIC, out); 

		////////////////////////////////////////
      $display("Testing RTI...");
      ////////////////////////////////////////
		instr = 16'b0001100000000001;
		#2;
		compare (RTI, out);   
      
      $display("Testing finished");
   	$finish;
	end
endmodule // ALU_t
