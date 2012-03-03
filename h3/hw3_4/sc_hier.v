    module sc_hier (ctr_rst, out);

    input ctr_rst;
    output [2:0] out;

    wire err;
    wire clk;
    wire rst;

    clkrst clk_generator(.clk(clk), .rst(rst), .err(err) );
    
    sc sc0( .clk(clk),
            .rst(rst),
            .ctr_rst( ctr_rst ),
            .err(err) );
            
    endmodule
