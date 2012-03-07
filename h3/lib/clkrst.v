// clock and reset generator
// CS/ECE 552
// Andy Phelps (TA)
// 3/22/06

// Clock period is 100 time units, and reset length
// to 201 time units (two rising edges of clock).

module clkrst (clk, rst, err);

    output clk;
    output rst;
    input  err;

    reg clk;
    reg rst;

    initial begin
      rst = 1;
      clk = 1;
      #201 rst = 0; // delay until slightly after two clock periods
    end

    always #50 begin   // delay 1/2 clock period each time thru loop
      clk = ~clk;
      if (clk & err) begin
        $display("Error signal asserted");
        $stop;
      end
    end

endmodule