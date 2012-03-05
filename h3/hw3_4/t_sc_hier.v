module t_sc_hier();

//Inputs
reg rst;
reg testvar = 0;

//Outputs
wire[2:0] out;

// Pull out clk and rst from clkgenerator module


//Instantiate
sc_hier sctest(.out(out), .ctr_rst(rst));

 // Debug
   task compare;
      input [2:0] ex, got;
      begin
         #2;
         if (ex !== got)
           $display ("ERR: Expected: 0x%d Got: 0x%d", ex, got);
      end
   endtask // comp
   
   initial begin
   $display("Starting tests...");
   #250
   rst = 1'b1;
   #100
    rst = 1'b0;
      
   end
   
   endmodule
   
   
   
      
   
   