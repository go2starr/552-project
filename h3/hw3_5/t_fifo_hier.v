module t_fifo_hier();
   reg [63:0] data_in;
   reg        data_in_valid;
   reg        pop_fifo;

   wire [63:0] data_out;
   wire        fifo_empty;
   wire        fifo_full;
   wire        data_out_valid;
   
   fifo_hier DUT(data_out, fifo_empty, fifo_full, data_out_valid,
                 data_in, data_in_valid, pop_fifo);

   initial begin
      $display("Hello, world!");
      
      $finish;
   end
   
endmodule // t_fifo_hier
