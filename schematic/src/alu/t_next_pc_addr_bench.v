module t_next_pc_addr_bench ();
	
	wire [15:0] npc;

	reg [15:0] instr, pc, alu_out, brj_dest, numErrors;
	reg bt;

	// Instantiation
	next_pc_addr npa (.instr(instr), .pc_inc(pc), .alu_out(alu_out), .brj_dest(brj_dest), .bt(bt), .next_pc(npc));

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
		alu_out = 16'h5555;
		brj_dest = 16'h3232;
		#2;
		
		////////////////////////////////////////
      $display("Testing BEQZ...");
      ////////////////////////////////////////
		instr = 16'b0110000000001111;
		bt = 1'b1;
		#2;
		compare (brj_dest, npc);

		#2;
		bt = 1'b0;
		#2;
		compare (pc, npc);

		////////////////////////////////////////
      $display("Testing BNEZ...");
      ////////////////////////////////////////
		instr = 16'b0110100000000010;
		bt = 1'b1;
		#2;
		compare (brj_dest, npc);

		#2;
		bt = 1'b0;
		#2;
		compare (pc, npc);

		////////////////////////////////////////
      $display("Testing BLTZ...");
      ////////////////////////////////////////
		instr = 16'b0111100000000001;
		bt = 1'b1;
		#2;
		compare (brj_dest, npc);

		#2;
		bt = 1'b0;
		#2;
		compare (pc, npc);

		////////////////////////////////////////
      $display("Testing J...");
      ////////////////////////////////////////
		instr = 16'b0010000000000111;
		#2;
		compare (brj_dest, npc);

		////////////////////////////////////////
      $display("Testing JR...");
      ////////////////////////////////////////
		instr = 16'b0010100000000001;
		brj_dest = 16'h0a0a;
		#2;
		compare (brj_dest, npc);

		////////////////////////////////////////
      $display("Testing JAL...");
      ////////////////////////////////////////
		instr = 16'b0011000000000011;
		bt = 1'b1;
		brj_dest = 16'h7171;
		#2;
		compare (brj_dest, npc);

		////////////////////////////////////////
      $display("Testing JALR...");
      ////////////////////////////////////////
		instr = 16'b0011100000000001;
		brj_dest = 16'h8989;
		#2;
		compare (brj_dest, npc);

		///////////////////////////////////////
		$display("Testing RET");
	   ///////////////////////////////////////
	  	instr = 16'b0111000000000000;
		#2;
		compare (alu_out, npc);

		//////////////////////////////////////
		$display("Testing RTI");
		//////////////////////////////////////
		instr = 16'b0001100000000000;
		alu_out = 16'hf4f4;
		#2;
		compare (alu_out, npc);

		/////////////////////////////////////
		$display("Testing Add (ie Default)");
		/////////////////////////////////////
		instr = 16'b1101100000000000;
		#2;
		compare (pc, npc);
      
      $display("Testing finished:   Num Errors = %d", numErrors);
   	$finish;
	end




endmodule
