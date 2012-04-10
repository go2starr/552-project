module t_mem_system();


wire [15:0] Addr;
wire [15:0] DataIn;
wire Rd, Wr, createdump, clk, rst;

wire [15:0] DataOut;
wire  Done, Stall, CacheHit,err;
		     
mem_system mtest(DataOut, Done, Stall, CacheHit, err, Addr, DataIn, Wr,createdump, clk,rst);

intial begin





end
endmodule
