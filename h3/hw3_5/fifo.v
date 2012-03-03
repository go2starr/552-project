// fifo.v - 64-bit FIFO
module fifo(
            // Outputs
            data_out, fifo_empty, fifo_full, data_out_valid, err, 
            // Inputs
            data_in, data_in_valid, pop_fifo, clk, rst
            );
   // Parameters
   parameter MAX = 4;          // Max size of FIFO
   
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

   // Internal wires
   wire [63:0]   q [MAX-1:0];           // FIFO register output
   wire [63:0]   q_next      [MAX-1:0]; // Next FIFO data
   wire [63:0]   q_pop_next  [MAX-1:0]; // Next if pop
   wire [63:0]   q_hold_next [MAX-1:0]; // Next if hold
   wire [63:0]   q_push_next [MAX-1:0]; // Next if push

   reg [4:0]    size;          // Size register output

   // Internal regs
   reg64 qrf0 (.in(q_next[0]), .rst(rst), .clk(clk), .out(q[0]));
   reg64 qrf1 (.in(q_next[1]), .rst(rst), .clk(clk), .out(q[1]));
   reg64 qrf2 (.in(q_next[2]), .rst(rst), .clk(clk), .out(q[2]));   
   reg64 qrf3 (.in(q_next[3]), .rst(rst), .clk(clk), .out(q[3]));

   dff rs1 (.q(size[1]), .d(size_next[1]), .clk(clk), .rst(rst));
   dff rs2 (.q(size[2]), .d(size_next[2]), .clk(clk), .rst(rst));
   dff rs3 (.q(size[3]), .d(size_next[3]), .clk(clk), .rst(rst));
   dff rs4 (.q(size[4]), .d(size_next[4]), .clk(clk), .rst(rst));
   
   // Fifo Empty / Full
   assign fifo_empty = size[0];
   assign fifo_full  = size[MAX];

   // Next size
   assign size_next[MAX-1:0] = data_in_valid ? // Push
                               size_next[MAX-1:0] << 1 : 
                               (pop_fifo ? // Pop
                                size_next[MAX:1] :
                                // Hold
                                size_next[MAX-1:0]
                                );
   assign size_next[MAX] = data_in_valid ? // Push
                           

   // Pop
   assign q_pop_next[0] = q[1];
   assign q_pop_next[1] = q[2];
   assign q_pop_next[2] = q[3];

   // Hold
   assign q_hold_next[0] = q[0];
   assign q_hold_next[1] = q[1];
   assign q_hold_next[2] = q[2];
   assign q_hold_next[3] = q[3];   

   // Push
   assign q_push_next[0] = data_in;
   assign q_push_next[1] = q[0];
   assign q_push_next[2] = q[1];
   assign q_push_next[3] = q[2];
   
endmodule
