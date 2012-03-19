// Code for register

module register (q, d, clk, rst, we);

// This value can be changed later

parameter WIDTHreg = 16;

// define inputs and outputs of the module

input[WIDTHreg-1:0] q;

input clk, rst, we;

output [WIDTHreg-1:0] d;

// wires that are local to the module

wire [WIDTHreg-1:0] enabledIn;

// A combination of a 2:1 MUX and a DFF to hold and update values; for more information 

mux2_1 mux[WIDTHreg-1:0] (.InA (q), .InB(d), .S({WIDTHreg{we}}), .Out(enabledIn));

dff file[WIDTHreg-1:0] (.q(q), .d(enabledIn), .clk({WIDTHreg{clk}}), .rst({WIDTHreg{rst}}));

endmodule
