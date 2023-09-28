module uart_fifo #(
  parameter DATA_SIZE   = 8,
            SIZE_FIFO   = 8,
            ADDR_WIDTH  = $clog2(SIZE_FIFO)
  )  (
  input                             clk, s_tick,
  input                             reset_n, 
  input  [DATA_SIZE - 1 : 0]        w_data,
  input                             wr,
  input                             rd,
  output  [DATA_SIZE - 1 : 0]       r_data,
  output wire                       full,
  output wire                       empty     
);

// Signal Declaration
// * Datapath Registers
reg [DATA_SIZE - 1 : 0]   fifo [SIZE_FIFO - 1 : 0];
reg [ADDR_WIDTH -1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
reg [ADDR_WIDTH -1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
reg full_reg, full_next;
reg empty_reg, empty_next;

wire wr_en;

// Registers
always @(posedge clk or negedge reset_n) begin
  if (~reset_n) begin
    w_ptr_reg <= 0;
    r_ptr_reg <= 0;
    full_reg <= 0;
    empty_reg <= 1;
  end
  else if (s_tick) begin
    if (wr_en) fifo[w_ptr_reg] <= w_data;
    w_ptr_reg <= w_ptr_next;
    r_ptr_reg <= r_ptr_next;
    full_reg <= full_next;
    empty_reg <= empty_next;
  end  
end

// Output Logic
assign wr_en = wr & ~full_reg; // Control output logic

assign full = full_reg;
assign empty = empty_reg;
assign r_data = fifo[r_ptr_reg];

// Next-state logic for {wr, rd}
always @(*) begin
  //successive pointer values
  w_ptr_succ = w_ptr_reg + 1'b1;
  r_ptr_succ = r_ptr_reg + 1'b1;
  // default values
  w_ptr_next = w_ptr_reg;
  r_ptr_next = r_ptr_reg;
  full_next = full_reg;
  empty_next = empty_reg;
  case ({wr, rd}) 
    // Skip 2'b00 for no operation is done
    2'b01: begin //read
      if (~empty_reg) begin
        r_ptr_next = r_ptr_succ;
        full_next = 0;
        if (r_ptr_succ == w_ptr_reg) empty_next = 1;
      end
    end
    2'b10: begin //write
      if (~full_reg) begin
        w_ptr_next = w_ptr_succ;
        empty_next = 0;
        if (w_ptr_succ == r_ptr_reg) full_next = 1;
      end
    end
    2'b11: begin //read and write
      w_ptr_next = w_ptr_succ;
      r_ptr_next = r_ptr_succ;
    end
  endcase
end
endmodule 