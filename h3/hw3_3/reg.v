module register (data, out, clk, rst);

    parameter WIDTH = 16;
    
    input [(WIDTH - 1):0] data;
    output [(WIDTH - 1):0] out;
    input clk;
    input rst;
    
    dff ff [(WIDTH-1):0] (.q(out), .d(data), .clk(clk), .rst(rst)); // 16 bit register

endmodule