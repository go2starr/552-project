// Clock advancing
`define tic @(posedge clk); #3;

// t_rf.v - Testbench for reg file
module t_rf;

   task compare;
      input [15:0] ex, got;
      begin 
         if (ex != got)
           $display("ERR: Expected: 0x%x Got 0x%x", ex, got);
      end
   endtask

   reg [15:0] wd;
   reg [2:0]  r1rs, r2rs, wrs;
   reg        w;
   reg [15:0] data_out;
   wire [15:0] r1d, r2d;  

   rf_hier rfh(.read1data(r1d), .read2data(r2d), .read1regsel(r1rs), .read2regsel(r2rs), .writeregsel(wrs), .writedata(wd), .write(w));
   
   initial begin
      #250;
      $display("Starting Tests...");
      // initialize everything to 0
      r1rs = 3'b0;
      r2rs = 3'b0;
      wrs = 3'b0;
      wd = 15'b0;
      w = 1'b0;
      
      /////////////////////////////////////////////////
      $display("Testing Register Reads and Writes... ");
      /////////////////////////////////////////////////
      // write register 0, read register 0
      $display("  Testing register 0...");
      wd = 16'h5555;
      w = 1'b1;
      wrs = 3'b000;
      // wait clock cycle to read
      `tic;
      
      w = 1'b0;
      r1rs = 3'b000;
      r2rs = 3'b000;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      wd = 16'hAAAA;
      w = 1'b1;
      wrs = 3'b000;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b000;
      r1rs = 3'b000;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);

      
      
      $display("  Testing register 1...");
      wd = 16'h5555;
      w = 1'b1;
      wrs = 3'b001;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b001;
      r2rs = 3'b001;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      wd = 16'hAAAA;
      w = 1'b1;
      wrs = 3'b001;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b001;
      r2rs = 3'b001;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      
      $display("  Testing register 2...");
      wd = 16'h5555;
      w = 1'b1;
      wrs = 3'b010;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b010;
      r2rs = 3'b010;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      wd = 16'hAAAA;
      w = 1'b1;
      wrs = 3'b010;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b010;
      r2rs = 3'b010;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      
      $display("  Testing register 3...");
      wd = 16'h5555;
      w = 1'b1;
      wrs = 3'b011;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b011;
      r2rs = 3'b011;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      wd = 16'hAAAA;
      w = 1'b1;
      wrs = 3'b011;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b011;
      r2rs = 3'b011;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      $display("  Testing register 4...");
      wd = 16'h5555;
      w = 1'b1;
      wrs = 3'b100;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b100;
      r2rs = 3'b100;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      wd = 16'hAAAA;
      w = 1'b1;
      wrs = 3'b100;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b100;
      r2rs = 3'b100;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      
      $display("  Testing register 5...");
      wd = 16'h5555;
      w = 1'b1;
      wrs = 3'b101;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b101;
      r2rs = 3'b101;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      wd = 16'hAAAA;
      w = 1'b1;
      wrs = 3'b101;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b101;
      r2rs = 3'b101;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      
      $display("  Testing register 6...");
      wd = 16'h5555;
      w = 1'b1;
      wrs = 3'b110;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b110;
      r2rs = 3'b110;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      wd = 16'hAAAA;
      w = 1'b1;
      wrs = 3'b110;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b110;
      r2rs = 3'b110;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      
      $display("  Testing register 7...");
      wd = 16'h5555;
      w = 1'b1;
      wrs = 3'b111;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b111;
      r2rs = 3'b111;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      
      wd = 16'hAAAA;
      w = 1'b1;
      wrs = 3'b111;
      // wait clock cycle to read
      #100;
      w = 1'b0;
      r1rs = 3'b111;
      r2rs = 3'b111;
      #100;
      compare (wd, r1d);
      compare (wd, r2d);
      
      
      ////////////////////////////////////////////////////
      $display("Testing Simultaneous Read and Write ... ");
      ////////////////////////////////////////////////////
      wd = 16'hBEEF;  // write 0xbeef while reading current value 0xaaaa
      wrs = 3'b111;
      r1rs = 3'b111;
      w = 1'b1;
      data_out = r1d;
      compare (16'haaaa, data_out);
      // wait clock cycle to read again
      #100;
      w = 1'b0;
      r1rs = 3'b111;
      #100;
      data_out = r1d;
      compare (wd, data_out);  // read new value 0xbeef

      
      //////////////////////////////////////////////////////////////////////////////
      $display("Testing Read and Write on Same Cycle but Different Registers ... ");
      //////////////////////////////////////////////////////////////////////////////
      wd = 16'hDEAD;
      w = 1'b1;
      wrs = 3'b100;   // write register 4 while reading register 5
      r1rs = 3'b111;
      data_out = r1d;
      compare (16'hbeef, data_out);
      // wait clock cycle to read register 1
      #100;
      w = 1'b0;
      r1rs = 3'b100;
      #100;
      data_out = r1d;
      compare (wd, data_out);
      
      
      ///////////////////////////////////////////////////////////////
      $display("Testing both read ports set to the same value ... ");
      ///////////////////////////////////////////////////////////////
      r1rs = 3'b000;
      r2rs = 3'b000;
      #100;
      compare (r1d, r2d);  
      #100;
      
      ///////////////////////////////
      $display("Testing Finished. ");
      /////////////////////////////// 
      
      $stop;
      
   end

endmodule
