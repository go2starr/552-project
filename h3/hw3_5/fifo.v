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

   wire [MAX:0]    size;          // Size register output
   wire [MAX:0]    size_next;     // Next size

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
   assign size_next[MAX-1:0] = (size == 0) ? 
                               1 : // Reset condition
                               (data_in_valid ?
                                size_next[MAX-1:0] << 1 : // Push
                                (
                                 pop_fifo ?
                                 size_next[MAX:1] : // Pop
                                 size_next[MAX-1:0] // Hold
                                 )
                                );
   assign size_next[MAX] = data_in_valid ?
                           (size_next[MAX] ? // Push
                            size_next[MAX] : // Push @max
                            size_next[MAX-1]) :
                           (pop_fifo ?
                            0 : // Pop
                            size_next[MAX] // Hold
                            );
   
   // Next FIFO
   assign q_next[0] = data_in_valid ? q_push_next[0] : // Push
                      (pop_fifo ? q_pop_next[0] :      // Pop
                       q_hold_next[0]);                // Hold

   assign q_next[1] = data_in_valid ? q_push_next[1] : // Push
                      (pop_fifo ? q_pop_next[1] :      // Pop
                       q_hold_next[1]);                // Hold

   assign q_next[2] = data_in_valid ? q_push_next[2] : // Push
                      (pop_fifo ? q_pop_next[2] :      // Pop
                       q_hold_next[2]);                // Hold

   assign q_next[3] = data_in_valid ? q_push_next[3] : // Push
                      (pop_fifo ? q_pop_next[3] :      // Pop
                       q_hold_next[3]);                // Hold
   
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
