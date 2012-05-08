module mem_system ( // Outputs
                    DataOut, Done, Stall, CacheHit, err,
                    // Inputs
                    Addr, DataIn, Rd, Wr, createdump, clk, rst
                   );

   input [15:0] Addr, DataIn;
   input Rd, Wr, createdump, clk, rst;
   output [15:0] DataOut;
   output Done, Stall, CacheHit, err;

   /* data_mem == 1, inst_mem == 0*/
   parameter MEMTYPE = 0;

   // wires
   wire [15:0] mem_dout, cache_dout, addr_to_mem, data_to_cache;
   wire [4:0] tag_out;
   wire [3:0] busy;
   wire [2:0] coffset;
   wire cache_err, mem_stall, mem_err, hit, validsig, dirty;
   reg tag_from_cache, data_from_mem, en, comp, write, V_in, mem_wr, mem_rd, cont_err, done, stall, incr_count, clear_count, cword_from_count;
   
   wire qidle, qcomprd, qmemrd, qwbmem, qinstall_cache, qdone;
   wire qcompwr, qerr, qwaitstate, qwrmissdone, qprewbmem;
   wire didle, dcomprd, dmemrd, dqbmem, dinstall_cache, ddone;
   wire dcompwr, derr, dwaitstate, dwrmissdone, dprewbmem;
   wire [10:0] state;
   assign state = {qprewbmem, qwrmissdone, qwaitstate, qerr, qcompwr, qdone, qinstall_cache, qwbmem, qmemrd, qcomprd, qidle};
   
   // Initialize state machine to idle state
   wire idle_ns;
   assign idle_ns = rst ? 1'b1 : didle;

   // Counter status for reacing and writing an entire block
   wire count11;
   wire [1:0] count;
   assign count11 = count[1] & count[0];
   // Instantiate counter 
   counter cntr (.count(count), .incr(incr_count), .clear(clear_count), .clk(clk), .rst(rst));

   // Mux to cache data_in and mem addr
   wire [1:0] wib;
   
   // word to writeback or read from mem depending on count
   assign wib = (count[1]) ? (count[0] ? 2'b11 : 2'b10) : (count[0] ? 2'b01 : 2'b00);
   
   // Logic to determine address supplied to mem
   assign addr_to_mem = tag_from_cache ? {tag_out[4:0], Addr[10:3], wib, Addr[0]} : {Addr[15:3], wib, Addr[0]};
   assign data_to_cache[15:0] = data_from_mem ? mem_dout[15:0] : DataIn[15:0];

   // What to use as word input to cache
   assign coffset = cword_from_count ? {wib, 1'b0} : Addr[2:0];

   // Keep track of cache hit signal
   wire dch, qch;
   dff ch (.q(qch), .d(dch), .clk(clk), .rst(rst));
   assign dch = (state[1] | state[6]) ? (hit & validsig) : qch;

   // Assign mem system outputs
   assign DataOut = cache_dout;
   assign Done = done;
   assign Stall = stall | mem_stall;  // stalls entire mem system if not done
   assign CacheHit = qch;
   assign err = mem_err | cache_err | cont_err;


   //////////////////////////////////////////////////////////
   // Next state logic -- TODO partially complete
   //
   // State[0] IDLE
   // State[1] COMPRD
   // State[2] MEMRD
   // State[3] WBMEM
   // State[4] INSTALL_CACHE
   // State[5] DONE
   // State[6] COMPWR
   // State[7] ERR
   // State[8] WAITSTATE
   // State[9] WRMISSDONE
   // State[10] PREWBMEM
   //////////////////////////////////////////////////////////
   assign didle = state[5] | (~Rd & ~Wr & state[0]) | state[9];
   assign dcomprd = Rd & ~Wr & state[0]; 
   assign dcompwr = ~Rd & Wr & state[0];
   assign dmemrd = ((~validsig | (~hit &validsig & ~dirty)) & (state[1]|state[6])) | (state[2] & mem_stall) | (state[4] & ~count11) | (state[3] & ~mem_stall & count11);
   assign dwaitstate = ~mem_stall && state[2];
   assign dwbmem = state[10] | state[3] & (mem_stall | ~count11);
   assign dinstall_cache = state[8];
   assign ddone = (hit & validsig & state[1]) | (hit & validsig & state[6]) | (Rd & ~Wr & (state[4] & count11));
   assign derr = Rd & Wr;
   assign dwrmissdone = state[4] & Wr & ~Rd & count11;
   assign dprewbmem = (~hit & validsig & dirty & (state[1] | state[6]));          
  
   ///////////////////////////////////////////////////////////////
   //   MemSystem Control
   //////////////////////////////////////////////////////////////
   always@(*) begin
      en = 1'b0;
      comp = 1'b0;
      write = 1'b0;
      V_in = 1'b0;
      mem_wr = 1'b0;
      mem_rd = 1'b0;
      cont_err = 1'b0;
      done = 1'b0;
      tag_from_cache = 1'b0;
      data_from_mem = 1'b0;
      stall = 1'b0;
      incr_count = 1'b0;
      clear_count = 1'b0;
      cword_from_count = 1'b0;
      case (state)
         11'b000_0000_0001: begin 
            en = 1'b1;
            end
         11'b000_0000_0010: begin
            en = 1'b1;
            comp = 1'b1;
            stall = 1'b1;
            end
         11'b000_0000_0100: begin
            en = 1'b1;
            stall = 1'b1;
            end
         11'b000_0000_1000: begin
            en = 1'b1;
            mem_wr = 1'b1;
            tag_from_cache = 1'b1;
            stall = 1'b1;
            incr_count = 1'b1;
            cword_from_count = 1'b1;
            end
          11'b000_0001_0000: begin
            en = 1'b1;
            write = 1'b1;
            V_in = 1'b1;
            data_from_mem = 1'b1;
            stall = 1'b1;
            incr_count = 1'b1;
            cword_from_count = 1'b1;
            end
          11'b000_0010_0000 : begin
            en = 1'b1;
            done = 1'b1;
            stall = 1'b1;
            end
          11'b000_0100_0000 : begin
            en = 1'b1;
            comp = 1'b1; write = 1'b1;
            stall = 1'b1;
            end
          11'b000_1000_000: begin
            en = 1'b1;
            comp = 1'b1;
            cont_err = 1'b1;
            data_from_mem = 1'b1;
            stall = 1'b1;
            end
          11'b001_0000_0000: begin
            en=1'b1;
            stall = 1'b1;
            end
          11'b010_0000_0000: begin
            en = 1'b1;
            comp = 1'b1;
            write = 1'b1;
            V_in = 1'b1;
            done = 1'b1;
            stall = 1'b1;
            end
          11'b100_0000_0000: begin
            en = 1'b1;
            mem_wr = 1'b1;
            tag_from_cache = 1'b1;
            stall = 1'b1;
            cword_from_count = 1'b1;
            end
          default: begin
            en = 1'b1;
            comp = 1'b1;
            cont_err = 1'b1;
            end
        endcase
    end

////////////////////////////////////////////////////////
//  Instatntiate memory and cache modules
////////////////////////////////////////////////////////   
   cache #(MEMTYPE) c0 (
                  .enable(en), .clk(clk), .rst(rst), .createdump(createdump), .tag_in(Addr[15:11]), .index(Addr[10:3]), .offset(coffset),
                  .data_in(data_to_cache), .comp(comp), .write(write), .valid_in(V_in), .tag_out(tag_out), .data_out(cache_dout), .hit(hit),
                  .dirty(dirty), .valid(validsig), .err(cache_err)
                  );

   // TODO Instantiate four bank mem here with params


// TODO instantiate DFFs for states   
dff idle(.q(qidle), .d(idle_ns), .clk(clk), .rst(1'b0));
dff comprd(.q(qcomprd), .d(comprd), .clk(clk), .rst(rst));
/////..........................
endmodule

module counter (count incr, clear, clk, rst);

input clk, rst, incr, clear;
output [1:0] count;

wire c1, c2;
wire qb0, qb1, db0, db1;

dff b1(.q(qb1), .d(db1), .clk(clk), .rst(rst));
dff b0(.g(qb0), .d(db0), .clk(clk), .rst(rst));

wire b0_ns, b1_ns;
assign b0_ns = incr & ~clear ? ~qb0 : qb0;
assign b1_ns = incr & ~clear ? (~qb1 & qb0) | (qb1 & ~qb0) : qb1;

assign db0 = clear ? 1'b0 : b0_ns;
assign db1 = clear ? 1'b0 : b1_ns;
assign count = {qb1, qb0};

endmodule  

   












      
