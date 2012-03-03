module register (data, out, clk, rst);
    input [15:0] data;
    output [15:0] out;
    input clk;
    input rst;
    
    dff ff [15:0] (.q(out), .d(data), .clk(clk), .rst(rst)); 

endmodule