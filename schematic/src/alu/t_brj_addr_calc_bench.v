module t_brj_addr_calc_bench ();

   // Inputs
   reg [15:0] instr, pc;
  
   // Outputs
   wire [15:0] dest_addr;

	// clock reset module
	wire clk;
	wire rst;
	reg err;
	clkrst cr1 (.clk(clk), .rst(rst), .err(err));

	reg [15:0] numErrors;

   // Instantiate
   brj_addr_calc bac (.instr(instr), .pc_inc (pc), .dest_addr (dest_addr));

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
		numErrors = 0;
		pc = 16'hf0f0;
		#2;
		
		////////////////////////////////////////
      $display("Testing BEQZ...");
      ////////////////////////////////////////
		instr = 16'b0110000000001111;
		#2;
		compare (16'b01111 + pc, dest_addr);

		////////////////////////////////////////
      $display("Testing BNEZ...");
      ////////////////////////////////////////
		instr = 16'b0110100000000010;
		#2;
		compare (16'b00010 + pc, dest_addr);

		////////////////////////////////////////
      $display("Testing BLTZ...");
      ////////////////////////////////////////
		instr = 16'b0111100000000001;
		#2;
		compare (16'b0001 + pc, dest_addr);

		////////////////////////////////////////
      $display("Testing J...");
      ////////////////////////////////////////
		instr = 16'b0010000000000111;
		#2;
		compare (16'b0000111 + pc, dest_addr);

		////////////////////////////////////////
      $display("Testing JR...");
      ////////////////////////////////////////
		instr = 16'b0010100000000001;
		#2;
		compare (16'b0001 + pc, dest_addr);

		////////////////////////////////////////
      $display("Testing JAL...");
      ////////////////////////////////////////
		instr = 16'b0011000000000011;
		#2;
		compare (16'b00011 + pc, dest_addr);

		////////////////////////////////////////
      $display("Testing JALR...");
      ////////////////////////////////////////
		instr = 16'b0011100000000001;
		#2;
		compare (16'b0001 + pc, dest_addr);
      
      $display("Testing finished:   Num Errors = %d", numErrors);
   	$finish;
	end


endmodule
