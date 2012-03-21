module mem_decode_logic (instr, e_mem, wr_mem, cd);
   // Inputs
   input [15:0] instr;

   // Outputsn
   output reg cd;		// create dump
	output reg e_mem;
	output reg wr_mem;

   // Wires
   wire [6:0] op;

   // assigns
   assign op = {instr[15:11], instr[1:0]};
   
   always @ (*) begin
      casex (op)
	/* Read from mem */
	7'b10001xx : begin // LD
	  wr_mem = 1'b0;
	  e_mem = 1'b1;
	  cd = 1'b0;
     end

   /* write to mem */ 
	7'b10011xx : begin// STU
	  wr_mem = 1'b1;
	  e_mem = 1'b1;
	  cd = 1'b0;
	end
	7'b10000xx : begin // ST
	  wr_mem = 1'b1;
     e_mem = 1'b1;
	  cd = 1'b0;
	  end 

	/* create dump */  
	7'b00000xx : begin // HALT
	  wr_mem = 1'b0;
	  e_mem = 1'b1;
	  cd = 1'b1;
     end      
               
	default	  : begin
	  e_mem = 1'b0;
	  wr_mem = 1'b0;
	  cd = 1'b0;
     end
 
      endcase
   end
endmodule

