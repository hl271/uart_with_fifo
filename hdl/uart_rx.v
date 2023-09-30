module uart_rx #(
  parameter DATA_SIZE       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE)
  )  (
  input                         clk, s_tick, // Clock and sampling tick
  input                         reset_n, 
  input                         rx,
  input                         rx_start,
  output [DATA_SIZE- 1:0]       data_out,
  output wire                   rx_done_tick       
);

// Signal Declaration
// * Datapath Registers
reg [DATA_SIZE-1:0]         RX_shift_reg, RX_shift_next;
reg [BIT_COUNT_SIZE:0]      bit_count;
reg [3:0]                   sample_count;
wire [BIT_COUNT_SIZE:0]     bit_count_next;
wire [3:0]                  sample_count_next;
// * Control signals
reg                       load_RX_shift_reg;
reg                       inc_bit_count;
reg                       clr_bit_count;
reg                       inc_sample_count;
reg                       clr_sample_count;
reg                       shift;
reg                       rx_done;
// * State Registers
reg [1:0]                 state, next_state;
// * Assignments
assign rx_done_tick = rx_done;

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
// * Datapath Registers
always @(posedge clk or negedge reset_n) begin
  if (~reset_n) begin
    bit_count <= 0;
    sample_count <= 0;
    RX_shift_reg <= 0;
  end
  else if (s_tick) begin
    bit_count <= bit_count_next;
    sample_count <= sample_count_next;
    RX_shift_reg <= RX_shift_next;
  end
end

// FSMD Next State Logic & Output Logic
// * Datapath Next State Logic & Output Logic
assign bit_count_next = (clr_bit_count) ? 0 : (inc_bit_count) ? bit_count + 1'b1 : bit_count;
assign sample_count_next = (clr_sample_count) ? 0 : (inc_sample_count) ? sample_count + 1'b1 : sample_count;
always @* begin
  if (load_RX_shift_reg) begin
    RX_shift_next = RX_shift_reg; 
  end
  else if (shift) begin
    RX_shift_next = {rx,RX_shift_reg[DATA_SIZE-1: 1]};
  end
  else begin
    RX_shift_next = RX_shift_reg;
  end
end
assign data_out = RX_shift_reg; // Datapath output wired to interface output
// * Controller Next State Logic & Output Logic
always @* begin 
  inc_sample_count    = 0;
  clr_sample_count    = 0;
  inc_bit_count       = 0;
  clr_bit_count       = 0;
  load_RX_shift_reg   = 0;
  shift               = 0;
  rx_done             = 0;

  case (state)
    IDLE: begin
      if (~rx_start) begin
        next_state        = IDLE;
      end
      else begin
        if (rx == 1'b0) begin
          next_state      = START;
        end
        else begin
          next_state      = IDLE;
        end
      end
    end

    START: begin
      if (rx == 1'b1) begin // Check for bouncing rx signal
        clr_sample_count  = 1'b1;
        next_state        = IDLE;
      end
      else begin
        if (sample_count == 4'd7) begin
          clr_sample_count= 1'b1;
          next_state      = DATA;
        end
        else begin
          inc_sample_count = 1;
          next_state      = START;
        end
      end
    end

    DATA: begin
      // inc_sample_count    = 1;
      if (sample_count == 4'd15) begin
        if (bit_count == 4'd8) begin 
            clr_sample_count  = 1'b1;
            clr_bit_count     = 1'b1;
            next_state  = STOP;
        end
        else begin
            shift           = 1;
            inc_bit_count   = 1;
            clr_sample_count= 1;
            next_state      = DATA;
        end
      end
      else begin
        inc_sample_count    = 1;
        next_state        = DATA;
      end
    end

    STOP: begin
      if (sample_count == 4'd15) begin
        clr_sample_count = 1;
        rx_done = 1;
        // load_RX_shift_reg = 1;
        next_state = IDLE;
      end
      else begin
        inc_sample_count = 1;
        next_state = STOP;
      end
    end
    default : next_state  = IDLE;
  endcase
end

assign rx_done_tick = rx_done; // Control output wired to interface output

endmodule 