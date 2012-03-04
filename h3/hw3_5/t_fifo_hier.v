
// Assertion with debug messages
`define test(ex, got, msg) \
   if (ex !== got) begin    \
      $write("ERR: ");     \
      $display(msg);       \
      $display("--> Expected: %d  Got: %d", ex, got); \
      no_errs = no_errs + 1; \
      end

// Clock advancing
`define tic @(posedge clk); #3;

module t_fifo_hier();
   reg [63:0] data_in;
   reg        data_in_valid;
   reg        pop_fifo;

   wire [63:0] data_out;
   wire        fifo_empty;
   wire        fifo_full;
   wire        data_out_valid;
   wire        clk, rst;

   integer     no_errs, i, j, k;
   
   fifo_hier DUT(data_out, fifo_empty, fifo_full, data_out_valid,
                 data_in, data_in_valid, pop_fifo);

   assign clk = DUT.clk;
   assign rst = DUT.rst;

   // Debug
   initial begin
      $display("Tests starting...");
      no_errs = 0;
      data_in = 0;
      data_in_valid = 0;
      pop_fifo = 0;

      // Reset
      `tic;
      `tic;
      `tic;
      `tic;      
      
      ////////////////////////////////////////////////////////////
      // Should reset to size == 0          
      ////////////////////////////////////////////////////////////
      `test(4'd1, DUT.fifo0.size, "Fifo size did not reset to 0");
      `test(1, fifo_empty, "fifo_empty did not reset to 0");
      `test(0, data_out_valid, "data_out_valid should reset to 0");

      ////////////////////////////////////////////////////////////
      // Popping while empty has no effect
      ////////////////////////////////////////////////////////////
      pop_fifo = 1;
      `tic;
      `test(0, data_out_valid, "data_out_valid should be zero with empty fifo");
      pop_fifo = 0;
      
      ////////////////////////////////////////////////////////////
      // Pushing a value should increase the size
      ////////////////////////////////////////////////////////////
      `tic;
      data_in = 64'h1122334455667788;
      data_in_valid = 1;

      `tic;
      data_in_valid = 0;
      
      `test(1 << 1, DUT.fifo0.size, "Fifo size is not 1 after pushing");
      `test(0, fifo_empty, "fifo_empty asserted after push");
      `test(0, data_out_valid, "data_out_valid should remain zero after push");

      ////////////////////////////////////////////////////////////
      // Popping should return the original value
      ////////////////////////////////////////////////////////////
      `tic;
      pop_fifo = 1;
      `tic;
      pop_fifo = 0;
      `test(64'h1122334455667788, data_out, "Did not pop off the same value as pushed");
      `test(1, fifo_empty, "Fifo empty did not return to asserted after popping last element");
      `test(1 << 0, DUT.fifo0.size, "Fifo size not zero on empty");
      `test(1, data_out_valid, "data_out_valid should be 1 on pop with full fifo");

      ////////////////////////////////////////////////////////////
      // Pushing until full should raise the FIFO size
      ////////////////////////////////////////////////////////////
      `tic;
      for (i = 0; i < 4; i = i + 1) begin
         data_in_valid = 1;
         data_in = i;
         `tic;
      end
      
      // Four values loaded...
      `test(1 << 4, DUT.fifo0.size, "Fifo size is not 4 when full");
      `test(1, fifo_full, "Fifo is not full when size is 4");

      ////////////////////////////////////////////////////////////
      // Pushing when full should have no effect, and values
      // should be popped off in order
      ////////////////////////////////////////////////////////////
      data_in_valid = 1;      
      data_in = 64'h12345678;
      `tic;

      // Make sure state is preserved...
      data_in_valid = 0;
      `tic;
      `tic;
      `tic;
      `tic;

      // Pop off values
      for (i = 0; i < 4; i = i + 1) begin
         pop_fifo = 1;
         `tic;
         `test(i, data_out, "Popped values do not match pushed");
         `test(1, data_out_valid, "Data out valid should be 1 with data in fifo");
      end

      // Fifo now empty
      `tic;
      `test(0, data_out_valid, "data_out_valid should be 0 after emptying fifo");
      
      $display("Tests complete.");
      
      $finish;
   end
   
endmodule // t_fifo_hier
