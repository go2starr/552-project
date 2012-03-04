// Fancy printing
`define C_OKGREEN "\033[92m"
`define C_FAIL    "\033[91m"
`define C_WARN    "\033[93m"
`define C_ENDC    "\033[0m"

`define PRINT_C(msg, c) $write(c); $write(msg); $write(`C_ENDC);
`define WARN(msg) `PRINT_C(msg, `C_WARN);
`define FAIL(msg) `PRINT_C(msg, `C_FAIL);
`define OK(msg)   `PRINT_C(msg, `C_OKGREEN);

// Assertion with debug messages
`define test(ex, got, msg) \
if (ex !== got) begin    \
      $display(`C_FAIL);   \
      $write("ERR:  ");  \
      $display(msg);       \
      $display("  --> Expected: %d  Got: %d", ex, got); \
      $write(`C_ENDC);  \
      no_errs = no_errs + 1; \
end else begin \
     `OK("."); \
end
               

// Clock advancing
`define tic @(posedge clk); #3;

