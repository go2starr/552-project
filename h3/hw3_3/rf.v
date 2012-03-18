// Your code for register file goes in here
/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module rf (
           // Outputs
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
           );
    // Use of parameter to make RF modifiable later
    parameter WIDTH = 16;
    // define module injputs and outputs
    input clk, rst;
    input [2:0] read1regsel;
    input [2:0] read2regsel;
    input [2:0] writeregsel;
    input [WIDTH-1:0] writedata;
    input        write;
    output [WIDTH-1:0] read1data;
    output [WIDTH-1:0] read2data;
    output        err;
    // Assigning err to 0; can be used for debugging purposes
    assign err = 0; // Should it be there?
    // wires that are local to the module
    wire [WIDTH-1:0] q7,q6,q5,q4,q3,q2,q1,q0;
    wire [7:0] we, awe;
    // instantiating a 3-8 decoder
    decode3_8 deocder (.sel(writeregsel), .Out(we));
    // generating write enable signals
    and2 andgates[7:0] (.in1(we), .in2({8{write}}), .out(awe));
    // individual registers - note that there are 8 such copies
    register #(WIDTH) my_regs7 (.q(q7), .d(writedata), .clk(clk), .rst(rst), .we(awe[7]));
    register #(WIDTH) my_regs6 (.q(q6), .d(writedata), .clk(clk), .rst(rst), .we(awe[6]));
    register #(WIDTH) my_regs5 (.q(q5), .d(writedata), .clk(clk), .rst(rst), .we(awe[5]));
    register #(WIDTH) my_regs4 (.q(q4), .d(writedata), .clk(clk), .rst(rst), .we(awe[4]));
    register #(WIDTH) my_regs3 (.q(q3), .d(writedata), .clk(clk), .rst(rst), .we(awe[3]));
    register #(WIDTH) my_regs2 (.q(q2), .d(writedata), .clk(clk), .rst(rst), .we(awe[2]));
    register #(WIDTH) my_regs1 (.q(q1), .d(writedata), .clk(clk), .rst(rst), .we(awe[1]));
    register #(WIDTH) my_regs0 (.q(q0), .d(writedata), .clk(clk), .rst(rst), .we(awe[0]));
    // instantiate 8:1 MUX for choosing what needs to come at the output read port
    mux8_1 choosefrom8[WIDTH-1:0] (.InA(q0), .InB(q1), .InC(q2), .InD(q3), .InE(q4), .InF(q5), .
    InG(q6), .InH(q7), .S({WIDTH{read1regsel}}), .Out(read1data));
    mux8_1 choosefrom8again[WIDTH-1:0] (.InA(q0), .InB(q1), .InC(q2), .InD(q3), .InE(q4), .InF(
    q5), .InG(q6), .InH(q7), .S({WIDTH{read2regsel}}), .Out(read2data));
endmodule

