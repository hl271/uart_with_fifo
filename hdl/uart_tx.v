module uart_tx #(
  parameter DATA_SIZE       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1)
  )  (
  input                         clk, s_tick, // Clock and sampling tick
  input                         reset_n, 
  input                         tx_start, // Empty signal from FIFO
  input   [DATA_SIZE - 1 : 0]   data_in, // Data from FIFO
  output wire                   tx, 
  output wire                   tx_done_tick        
);

// Signal Declaration 
// * Data Registers
reg [DATA_SIZE-1:0]           TX_shift_reg, TX_shift_next; 
reg [BIT_COUNT_SIZE - 1:0]    bit_count; 
reg [3:0]                     sample_count;
reg                           tx_reg; // a buffer to avoid potential glitch
wire [BIT_COUNT_SIZE - 1:0]   bit_count_next;
wire [3:0]                    sample_count_next;
wire                          tx_next;

// * Control signals
reg                       load_TX_shift_reg;
reg                       inc_bit_count;
reg                       clr_bit_count;
reg                       inc_sample_count;
reg                       clr_sample_count;
reg                       add_start_bit_tx;
reg                       add_data_bit_tx;
reg                       add_stop_bit_tx;
reg                       shift;
reg                       tx_done;
// * State Registers
reg [1:0]                 state, next_state;

// State Encoding
localparam [1:0] 
  IDLE      = 2'b00,
  START     = 2'b01,
  DATA      = 2'b10,
  STOP      = 2'b11;

// FSMD Registers
// * State Registers
always @(posedge clk or negedge reset_n) begin 
  if(~reset_n) begin
    state <= IDLE;
  end
  else if (s_tick) begin
    state <= next_state;
  end
end
// * Data Registers
always @(posedge clk or negedge reset_n) begin
  if (~reset_n) begin
    bit_count <= 0;
    sample_count <= 0;
    TX_shift_reg <= {(DATA_SIZE){1'b1}};
    tx_reg <= 1'b1;
  end
  else if (s_tick) begin
    bit_count <= bit_count_next;
    sample_count <= sample_count_next;
    TX_shift_reg <= TX_shift_next;
    tx_reg <= tx_next;
  end
end

// FSMD next-state logic & output logic
// * Datapath Next State Logic & Output Logic
assign bit_count_next = (clr_bit_count) ? 0 : (inc_bit_count) ? bit_count + 1'b1 : bit_count;
assign sample_count_next = (clr_sample_count) ? 0 : (inc_sample_count) ? sample_count + 1'b1 : sample_count;
assign tx_next = (add_start_bit_tx) ? 1'b0 : (add_data_bit_tx) ? TX_shift_reg[0] : (add_stop_bit_tx) ? 1'b1 : tx_reg;
always @* begin
  if (load_TX_shift_reg) begin
    TX_shift_next = data_in;
  end
  else if (shift) begin
    TX_shift_next = {1'b1,TX_shift_reg[DATA_SIZE-1:1]};
  end
  else begin
    TX_shift_next = TX_shift_reg;
  end
end

assign tx = tx_reg; // Data output wired to interface output

// * Controller Next State Logic & Output Logic
always @* begin 
  inc_sample_count    = 0;
  clr_sample_count    = 0;
  inc_bit_count       = 0;
  clr_bit_count       = 0;
  load_TX_shift_reg   = 0;
  shift               = 0;
  add_start_bit_tx    = 0;
  add_data_bit_tx     = 0;
  add_stop_bit_tx     = 0;
  tx_done             = 0;

  case (state)
    IDLE: begin
      if (tx_start) begin
        load_TX_shift_reg = 1;
        next_state = START;
      end
      else begin
        next_state = IDLE;
      end
    end
    START: begin
      add_start_bit_tx = 1;
      if (sample_count == 4'd15) begin
        clr_sample_count = 1;
        inc_bit_count = 1;
        next_state = DATA;
      end
      else begin
        inc_sample_count = 1;
        next_state = START;
      end
    end
    DATA: begin
      add_data_bit_tx = 1;
      if (sample_count == 4'd15) begin
        clr_sample_count = 1;
        if (bit_count == 4'd8) begin
          clr_bit_count = 1;
          next_state = STOP;
        end
        else begin
          shift = 1;
          inc_bit_count = 1;
          next_state = DATA;
        end
      end
      else begin
        inc_sample_count = 1;
        next_state = DATA;
      end
    end
    STOP: begin
      add_stop_bit_tx = 1;
      if (sample_count == 4'd15) begin
        clr_sample_count = 1;
        tx_done = 1;
        next_state = IDLE;
      end
      else begin
        inc_sample_count = 1;
        next_state = STOP;
      end    
    end
    default : next_state = IDLE;
  endcase
end

assign tx_done_tick = tx_done; // Control output wired to interface output


endmodule 