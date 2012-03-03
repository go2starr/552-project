// fifo.v - 64-bit FIFO
module fifo(
            // Outputs
            data_out, fifo_empty, fifo_full, data_out_valid, err, 
            // Inputs
            data_in, data_in_valid, pop_fifo, clk, rst
            );
   // Inputs
   input [63:0] data_in;
   input        data_in_valid;
   input        pop_fifo;

   // Outputs
   input        clk;
   input        rst;
   output [63:0] data_out;
   output        fifo_empty;
   output        fifo_full;
   output        data_out_valid;
   output        err;
   
   // Internal reg
   

   
endmodule

