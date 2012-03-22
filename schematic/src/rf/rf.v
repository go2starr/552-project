module rf (
           // Outouts
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
           );
   parameter WIDTH = 16;
   
   input clk, rst;
   input [2:0] read1regsel;
   input [2:0] read2regsel;
   input [2:0] writeregsel;
   input [(WIDTH-1):0] writedata;
   input        write;

   output [(WIDTH-1):0] read1data;
   output [(WIDTH-1):0] read2data;
   output        err;
  
   wire [(WIDTH-1):0] readData0, readData1, readData2, readData3, readData4, readData5, readData6, readData7;
   wire [(WIDTH-1):0] writeData0, writeData1, writeData2, writeData3, writeData4, writeData5, writeData6, writeData7;
   
   reg [(WIDTH-1):0] outData1, outData2;
   assign read1data = outData1;
   assign read2data = outData2; 
   
   // module register (data, out, clk, rst);
   register my_regs0 (.d(writeData0), .q(readData0), .clk(clk), .rst(rst), .we(1'b1));
   register my_regs1 (.d(writeData1), .q(readData1), .clk(clk), .rst(rst), .we(1'b1));
   register my_regs2 (.d(writeData2), .q(readData2), .clk(clk), .rst(rst), .we(1'b1));
   register my_regs3 (.d(writeData3), .q(readData3), .clk(clk), .rst(rst), .we(1'b1));
   register my_regs4 (.d(writeData4), .q(readData4), .clk(clk), .rst(rst), .we(1'b1));
   register my_regs5 (.d(writeData5), .q(readData5), .clk(clk), .rst(rst), .we(1'b1));
   register my_regs6 (.d(writeData6), .q(readData6), .clk(clk), .rst(rst), .we(1'b1));
   register my_regs7 (.d(writeData7), .q(readData7), .clk(clk), .rst(rst), .we(1'b1));

   
   assign writeData0 = (write & (writeregsel == 3'b000)) ? writedata : readData0;
   assign writeData1 = (write & (writeregsel == 3'b001)) ? writedata : readData1;
   assign writeData2 = (write & (writeregsel == 3'b010)) ? writedata : readData2;
   assign writeData3 = (write & (writeregsel == 3'b011)) ? writedata : readData3;
   assign writeData4 = (write & (writeregsel == 3'b100)) ? writedata : readData4;
   assign writeData5 = (write & (writeregsel == 3'b101)) ? writedata : readData5;
   assign writeData6 = (write & (writeregsel == 3'b110)) ? writedata : readData6;
   assign writeData7 = (write & (writeregsel == 3'b111)) ? writedata : readData7; 


   always@(*) begin
     case (read1regsel)
       3'b000: outData1 = readData0;
       3'b001: outData1 = readData1; 
       3'b010: outData1 = readData2;  	   
       3'b011: outData1 = readData3; 
       3'b100: outData1 = readData4;  
       3'b101: outData1 = readData5;
       3'b110: outData1 = readData6;
       3'b111: outData1 = readData7;
     endcase // case (read1regsel)
   end

   
   always@(read2regsel, readData0, readData1, readData2, readData3, readData4, readData5, readData6, readData7) begin
     case (read2regsel)
       3'b000: outData2 = readData0;
       3'b001: outData2 = readData1; 
       3'b010: outData2 = readData2;  	   
       3'b011: outData2 = readData3; 
       3'b100: outData2 = readData4;  
       3'b101: outData2 = readData5;
       3'b110: outData2 = readData6;
       3'b111: outData2 = readData7;
     endcase // case (read2regsel)
   end
endmodule
