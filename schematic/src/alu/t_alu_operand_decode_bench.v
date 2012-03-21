module t_alu_operand_decode_bench();

   // Inputs
   reg [15:0] instr, rtVal, rsVal;
  
   // Outputs
   wire [15:0] outA, outB;

   alu_operand_decode aod (.instr(instr), .rsVal(rsVal), .rtVal(rtVal), .opA(outA), .opB(outB));

	// clock reset module
	wire clk;
	wire rst;
	reg err;
	clkrst cr1 (.clk(clk), .rst(rst), .err(err));

	reg [15:0] numErrors;

   // Instantiate

   // Debug
   task compare;
      input [15:0] ex, got;
      begin
         #2;
         if (ex !== got) begin
           $display ("ERR: Expected: 0x%d Got: 0x%d", ex, got);
			  numErrors = numErrors + 1;
		   end
      end
   endtask // compare

   initial begin
      $display("Starting tests...");
		instr = 16'b0000000000000000;
		rsVal = 16'hAAAA;
		rtVal = 16'h1010;
		numErrors = 0;
		#2;
		
		////////////////////////////////////////
      $display("Testing ADDI...");
      ////////////////////////////////////////
		instr = 16'b0100000000000101;
		#2;
		compare (rsVal, outA);
		compare (16'h0005, outB);

		////////////////////////////////////////
      $display("Testing SUBI...");
      ////////////////////////////////////////
		instr = 16'b0100100000000110;
		#2;
		compare (rsVal, outA);
		compare (16'h0006, outB);

		////////////////////////////////////////
      $display("Testing ORI...");
      ////////////////////////////////////////
		instr = 16'b0101000000000001;
		#2;
		compare (rsVal, outA);
		compare (16'h0001, outB);

		////////////////////////////////////////
      $display("Testing ANDI...");
      ////////////////////////////////////////
		instr = 16'b0101100000000010;
		#2;
		compare (rsVal, outA);
		compare (16'h0002, outB);

		////////////////////////////////////////
      $display("Testing ROLI...");
      ////////////////////////////////////////
		instr = 16'b1010000000000011;
		#2;
		compare (rsVal, outA);
		compare (16'h0003, outB);

		////////////////////////////////////////
      $display("Testing SLLI...");
      ////////////////////////////////////////
		instr = 16'b1010100000000100;
		#2;
		compare (rsVal, outA);
		compare (16'h0004, outB);

		////////////////////////////////////////
      $display("Testing RORI...");
      ////////////////////////////////////////
		instr = 16'b1011000000000110;
		#2;
		compare (rsVal, outA);
		compare (16'h0006, outB);

		////////////////////////////////////////
      $display("Testing SRAI...");
      ////////////////////////////////////////
		instr = 16'b1011100000000111;
		#2;
		compare (rsVal, outA);
		compare (16'h0007, outB);

		////////////////////////////////////////
      $display("Testing ST...");
      ////////////////////////////////////////
		instr = 16'b1000000000000100;
		#2;
		compare (rsVal, outA);
		compare (16'h0004, outB);

		////////////////////////////////////////
      $display("Testing LD...");
      ////////////////////////////////////////
		instr = 16'b1000100000000001;
		rtVal = 16'hcccc;
		#2;
		compare (rsVal, outA);
		compare (16'h0001, outB);

		////////////////////////////////////////
      $display("Testing STU...");
      ////////////////////////////////////////
		instr = 16'b1001100000001000;
		rsVal = 16'h5454;
		#2;
		compare (rsVal, outA);
		compare (16'h0008, outB);

		////////////////////////////////////////
      $display("Testing ADD...");
      ////////////////////////////////////////
		instr = 16'b1101100000000000;
		rtVal = 16'h7777;
		#2;
		compare (rsVal, outA);
		compare (rtVal, outB);

		////////////////////////////////////////
      $display("Testing SUB...");
      ////////////////////////////////////////
		instr = 16'b1101100000000001;
		rtVal = 16'h3333;
		#2;
		compare (rsVal, outA);
		compare (rtVal, outB);

		////////////////////////////////////////
      $display("Testing OR...");
      ////////////////////////////////////////
		instr = 16'b1101100000000010;
		rtVal = 16'h2222;
		#2;
		compare (rsVal, outA);
		compare (rtVal, outB);

		////////////////////////////////////////
      $display("Testing AND...");
      ////////////////////////////////////////
		instr = 16'b1101100000000011;
		rtVal = 16'h7272;
		#2;
		compare (rsVal, outA);
		compare (rtVal, outB);

		////////////////////////////////////////
      $display("Testing ROL...");
      ////////////////////////////////////////
		instr = 16'b1101000000000000;
		rtVal = 16'habba;
		#2;
		compare (rsVal, outA);
		compare (rtVal, outB);

		////////////////////////////////////////
      $display("Testing SLL...");
      ////////////////////////////////////////
		instr = 16'b1101000000000001;
		rtVal = 16'hdddd;
		#2;
		compare (rsVal, outA);
		compare (rtVal, outB);

		////////////////////////////////////////
      $display("Testing ROR...");
      ////////////////////////////////////////
		instr = 16'b1101000000000010;
		rtVal = 16'hf0f0;
		#2;
		compare (rsVal, outA);
		compare (rtVal, outB);

		////////////////////////////////////////
      $display("Testing SRA...");
      ////////////////////////////////////////
		instr = 16'b1101000000000011;
		rtVal = 16'h1616;
		#2;
		compare (rsVal, outA);
		compare (rtVal, outB);

		////////////////////////////////////////
      $display("Testing BEQZ...");
      ////////////////////////////////////////
		instr = 16'b0110000000001111;
		#2;
		compare (rsVal, outA);
		compare (16'h000f, outB);

		////////////////////////////////////////
      $display("Testing BNEZ...");
      ////////////////////////////////////////
		instr = 16'b0110100000000010;
		#2;
		compare (rsVal, outA);
		compare (16'h0002, outB);

		////////////////////////////////////////
      $display("Testing BLTZ...");
      ////////////////////////////////////////
		instr = 16'b0111100000000001;
		#2;
		compare (rsVal, outA);
		compare (16'h0001, outB);

		////////////////////////////////////////
      $display("Testing LBI...");
      ////////////////////////////////////////
		instr = 16'b1100000000001001;
		#2;
		compare (rsVal, outA);
		compare (16'h0009, outB);

		////////////////////////////////////////
      $display("Testing SLBI...");
      ////////////////////////////////////////
		instr = 16'b1001000000000001;
		#2;
		compare (rsVal, outA);
		compare (16'h0001, outB);

		////////////////////////////////////////
      $display("Testing J...");
      ////////////////////////////////////////
		instr = 16'b0010000000000111;
		#2;
		compare (rsVal, outA);
		compare (16'h0007, outB);

		////////////////////////////////////////
      $display("Testing JR...");
      ////////////////////////////////////////
		instr = 16'b0010100000000001;
		#2;
		compare (rsVal, outA);
		compare (16'h0001, outB); 

		////////////////////////////////////////
      $display("Testing JAL...");
      ////////////////////////////////////////
		instr = 16'b0011000000000011;
		#2;
		compare (rsVal, outA);
		compare (16'h0003, outB); 

		////////////////////////////////////////
      $display("Testing JALR...");
      ////////////////////////////////////////
		instr = 16'b0011100000000001;
		#2;
		compare (rsVal, outA);
		compare (16'h0001, outB); 
      
      $display("Testing finished:   Num Errors = %d", numErrors);
   	$finish;
	end
endmodule // ALU_t
