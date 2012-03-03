module rf (
           // Outouts
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
           );
   input clk, rst;
   input [2:0] read1regsel;
   input [2:0] read2regsel;
   input [2:0] writeregsel;
   input [16:0] writedata;
   input        write;

   output [16:0] read1data;
   output [16:0] read2data;
   output        err;
   
   // TODO parameter WIDTH = 16;
  
   wire [16:0] readData0, readData1, readData2, readData3, readData4, readData5, readData6, readData7;
   wire [16:0] writeData0, writeData1, writeData2, writeData3, writeData4, writeData5, writeData6, writeData7;
   
   reg [16:0] outData1, outData2;
   assign read1data = outData1;
   assign read2data = outData2; 
   
   // module register (data, out, clk, rst);
   register r0 (.data(writeData0), .out(readData0), .clk(clk), .rst(rst));
   register r1 (.data(writeData1), .out(readData1), .clk(clk), .rst(rst));
   register r2 (.data(writeData2), .out(readData2), .clk(clk), .rst(rst));
   register r3 (.data(writeData3), .out(readData3), .clk(clk), .rst(rst));
   register r4 (.data(writeData4), .out(readData4), .clk(clk), .rst(rst));
   register r5 (.data(writeData5), .out(readData5), .clk(clk), .rst(rst));
   register r6 (.data(writeData6), .out(readData6), .clk(clk), .rst(rst));
   register r7 (.data(writeData7), .out(readData7), .clk(clk), .rst(rst));

   
   assign writeData0 = (write & (writeregsel == 3'b000)) ? writedata : writeData0;
   assign writeData1 = (write & (writeregsel == 3'b001)) ? writedata : writeData1;
   assign writeData2 = (write & (writeregsel == 3'b010)) ? writedata : writeData2;
   assign writeData3 = (write & (writeregsel == 3'b011)) ? writedata : writeData3;
   assign writeData4 = (write & (writeregsel == 3'b100)) ? writedata : writeData4;
   assign writeData5 = (write & (writeregsel == 3'b101)) ? writedata : writeData5;
   assign writeData6 = (write & (writeregsel == 3'b110)) ? writedata : writeData6;
   assign writeData7 = (write & (writeregsel == 3'b111)) ? writedata : writeData7; 


always@(read1regsel, readData0, readData1, readData2, readData3, readData4, readData5, readData6, readData7)
case (read1regsel)
  3'b000: begin
  	  outData1 = readData0;
  	  end
  3'b001: begin
          outData1 = readData1; 
  	  end
  3'b010: begin
   	  outData1 = readData2;  	   
  	  end
  3'b011: begin
   	  outData1 = readData3; 
  	  end 
  3'b100: begin
          outData1 = readData4;  
  	  end
  3'b101: begin
  	  outData1 = readData5;
  	  end
  3'b110: begin
          outData1 = readData6;
  	  end
  3'b111: begin
  	  outData1 = readData7;
  	  end
 endcase
 
 always@(read2regsel, readData0, readData1, readData2, readData3, readData4, readData5, readData6, readData7)
 case (read2regsel)
  3'b000: begin
  	  outData2 = readData0;
  	  end
  3'b001: begin
          outData2 = readData1; 
  	  end
  3'b010: begin
   	  outData2 = readData2;  	   
  	  end
  3'b011: begin
   	  outData2 = readData3; 
  	  end 
  3'b100: begin
          outData2 = readData4;  
  	  end
  3'b101: begin
  	  outData2 = readData5;
  	  end
  3'b110: begin
          outData2 = readData6;
  	  end
  3'b111: begin
  	  outData2 = readData7;
  	  end
 endcase
endmodule
