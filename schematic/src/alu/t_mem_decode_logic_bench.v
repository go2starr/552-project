module t_mem_decode_logic_bench ();

reg [15:0] instr;
wire en, wr, cd;

reg [15:0] numErrors;

// Instantiate
mem_decode_logic mdl (.instr(instr), .e_mem(en), .wr_mem(wr), .cd(cd));

 task compare;
      input ex, got;
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
		#2;
		
	   ////////////////////////////////////////
      $display("Testing HALT...");
      ////////////////////////////////////////
		instr = 16'b0000000000000000;
   	#2;   
		compare (1'b1, en);
	   compare (1'b0, wr);
		compare (1'b1, cd);

		////////////////////////////////////////
      $display("Testing LD...");
      ////////////////////////////////////////
		instr = 16'b1000100000000000;
   	#2;   
		compare (1'b1, en);
	   compare (1'b0, wr);
		compare (1'b0, cd);


		////////////////////////////////////////
      $display("Testing ST...");
      ////////////////////////////////////////
		instr = 16'b1000000000000000;
   	#2;   
		compare (1'b1, en);
	   compare (1'b1, wr);
		compare (1'b0, cd);


		////////////////////////////////////////
      $display("Testing STU...");
      ////////////////////////////////////////
		instr = 16'b1001100000000000;
   	#2;   
		compare (1'b1, en);
	   compare (1'b1, wr);
		compare (1'b0, cd);


		$display("Testing Finished - Num Errors: %d", numErrors);	

	   $finish;
 end
endmodule
