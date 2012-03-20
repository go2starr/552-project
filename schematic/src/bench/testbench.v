// Fancy printing
`define C_OKGREEN "\033[92m"
`define C_FAIL    "\033[91m"
`define C_WARN    "\033[93m"
`define C_ENDC    "\033[0m"
`define C_BLUE    "\033[94m"

`define PRINT_C(msg, c) $write(c); $write(msg); $write(`C_ENDC);
`define WARN(msg) `PRINT_C(msg, `C_WARN);
`define FAIL(msg) `PRINT_C(msg, `C_FAIL);
`define OK(msg)   `PRINT_C(msg, `C_OKGREEN);

`define DEBUG 0

//integer no_errs = 0;

// Assertion with debug messages
`define test(ex, got, msg) \
if (ex !== got) begin      \
      $display(`C_FAIL);   \
      $write("ERR:  ");    \
      $display(msg);       \
      $display("  --> Expected: %h  Got: %h", ex, got); \
      $write(`C_ENDC);     \
      no_errs = no_errs + 1; \
end else begin \
     `OK("."); \
end
               
// Info printing
`define info(msg) if (`DEBUG) begin `PRINT_C(msg, `C_BLUE); $display(""); end

// Clock advancing
`define tic @(posedge clk); #3;

