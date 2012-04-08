module rf_bypass (
	// Outputs
	read1data, read2data, err,
	// Inputs
	clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
	);

	// use of parameter to make RF modifiable later
	parameter WIDTH = 16;

	// define module inputs and outputs
	input clk, rst;
	input [2:0] read1regsel;
	input [2:0] read2regsel;
	input [2:0] writeregsel;
	input [WIDTH-1:0] writedata;
	input write;

	output [WIDTH-1:0] read1data;
	output [WIDTH-1:0] read2data;
	output err;

	// internal wires
	wire xorw0r00, xorw1r01, xorw2r02, xorw0r10, xorw1r11, xorw2r12;
	wire norr0, norr1;
	wire andnorr0write, andnorr1write;

	wire [WIDTH-1:0] dataOut1, dataOut2;

	// instantiate a register file
	rf #(WIDTH) rf0 (.read1data (dataOut1), 
		.read2data(dataOut2), 
		.err(err), 
		.clk(clk), 
		.rst(rst), 
		.read1regsel(read1regsel), 
		.read2regsel(read2regsel), 
		.writeregsel(writeregsel), 
		.writedata(writedata), 
		.write(write));

	xor2 x0 (.in1(read1regsel[0]), .in2(writeregsel[0]), .out(xorw0r00));
	xor2 x1 (.in1(read1regsel[1]), .in2(writeregsel[1]), .out(xorw1r01));
	xor2 x2 (.in1(read1regsel[2]), .in2(writeregsel[2]), .out(xorw2r02));

	xor2 x3 (.in1(read2regsel[0]), .in2(writeregsel[0]), .out(xorw0r10));
	xor2 x4 (.in1(read2regsel[1]), .in2(writeregsel[1]), .out(xorw1r11));
	xor2 x5 (.in1(read2regsel[2]), .in2(writeregsel[2]), .out(xorw2r12));

	nor3 n0 (.in1(xorw0r00), .in2(xorw1r01), .in3(xorw2r02), .out(norr0));
	nor3 n1 (.in1(xorw0r10), .in2(xorw1r11), .in3(xorw2r12), .out(norr1));

	and2 a0 (.in1(norr0), .in2(write), .out(andnorr0write));
	and2 a1 (.in1(norr1), .in2(write), .out(andnorr1write));

	mux2_1 m0 [15:0] (.InA(dataOut1), .InB(writeData), .S(andnorr0write), .Out(read1data));
	mux2_1 m1 [15:0] (.InA(dataOut2), .InB(writeData), .S(andnorr1write), .Out(read2data));

endmodule
