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
   input [15:0] writedata;
   input        write;

   output [15:0] read1data;
   output [15:0] read2data;
   output        err;
   
   wire [15:0] readData [7:0];
   wire [15:0] writeRegData [7:0];
   
   reg rf8 [7:0] (.data(writeRegData), .out(readData), .clk(clk), .rst(rst)); 
   
   writeRegData[0] = (write && (writeregsel == 3'b000)) ? writedata : writeRegData[0];
   writeRegData[1] = (write && (writeregsel == 3'b001)) ? writedata : writeRegData[1];
   writeRegData[2] = (write && (writeregsel == 3'b010)) ? writedata : writeRegData[2];
   writeRegData[3] = (write && (writeregsel == 3'b011)) ? writedata : writeRegData[3];
   writeRegData[4] = (write && (writeregsel == 3'b100)) ? writedata : writeRegData[4];
   writeRegData[5] = (write && (writeregsel == 3'b101)) ? writedata : writeRegData[5];
   writeRegData[6] = (write && (writeregsel == 3'b110)) ? writedata : writeRegData[6];
   writeRegData[7] = (write && (writeregsel == 3'b111)) ? writedata : writeRegData[7]; 


always@(*)
case (read1regsel)
  3'b000: begin
  	  read1data <= readData[0];
  	  end
  3'b001: begin
          read1data <= readData[1]; 
  	  end
  3'b010: begin
   	  read1data <= readData[2];  	   
  	  end
  3'b011: begin
   	  read1data <= readData[3]; 
  	  end 
  3'b100: begin
          read1data <= readData[4];  
  	  end
  3'b101: begin
  	  read1data <= readData[5];
  	  end
  3'b110: begin
          read1data <= readData[6];
  	  end
  3'b111: begin
  	  read1data <= readData[7];
  	  end
 endcase
 
 always@(*)
 case (read2regsel)
  3'b000: begin
  	  read2data <= readData[0];
  	  end
  3'b001: begin
          read2data <= readData[1]; 
  	  end
  3'b010: begin
   	  read2data <= readData[2];  	   
  	  end
  3'b011: begin
   	  read2data <= readData[3]; 
  	  end 
  3'b100: begin
          read2data <= readData[4];  
  	  end
  3'b101: begin
  	  read2data <= readData[5];
  	  end
  3'b110: begin
          read2data <= readData[6];
  	  end
  3'b111: begin
  	  read2data <= readData[7];
  	  end
 endcase
endmodule
