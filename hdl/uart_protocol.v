module uart_protocol #(
  parameter DATA_SIZE       = 8,
            SIZE_FIFO       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1),
            SYS_FREQ        = 50000000,
            BAUD_RATE       = 9600,
            CLOCK           = SYS_FREQ/BAUD_RATE,
            SAMPLE          = 16,
            BAUD_DVSR       = SYS_FREQ/(SAMPLE*BAUD_RATE)
  )  (
  input                       clk               ,  // Clock
  input                       reset_n           ,  // Asynchronous reset active low
  input                       rx    ,  // rx
  output                      tx   ,  // tx
  output  [            2 : 0] TX_status_register,
  output  [            2 : 0] RX_status_register
);

// Signal Declaration
// * Module output (must be wire)
wire                     s_tick    ;
wire [DATA_SIZE - 1 : 0] tx_data_in;
wire [DATA_SIZE - 1 : 0] rx_data_out;
wire [DATA_SIZE - 1 : 0] bus_data_in;
wire [DATA_SIZE - 1 : 0] bus_data_out;

wire                     tx_start;
wire                     tx_done;
wire                     tx_full;
wire                     tx_empty;

wire                     rx_start;
wire                     rx_done;
wire                     rx_full;
wire                     rx_empty;

// * State registers
reg                       state, next_state;

// * Control signals
reg                     fifo_tx_wr;
reg                     fifo_rx_rd;

// * datapath registers
// reg [DATA_SIZE - 1 : 0] temp_reg, temp_next; //store temporary bus data

localparam  
  IDLE      = 1'b0,
  ON        = 1'b1;

assign tx_start = ~tx_empty; // tx starts when fifo is not empty
assign rx_start = ~rx_full; // rx starts when fifo is not full
assign bus_data_in = bus_data_out;

// ============================================---------------------
//   | tx_done | tx_empty | tx_full | <== Status Register
//   ==========================================---------------------
// assign TX_status_register = {5'b0,tx_done,tx_empty,tx_full};
assign TX_status_register = {tx_done,tx_empty,tx_full};

// =====================================================================================================================--------------------
//   | rx_done | empty | full  | <== Status Register
//   =====================================================================================================================---------------------
assign RX_status_register = {rx_done,rx_empty,rx_full};

always @(posedge clk or negedge reset_n) begin 
  if (~reset_n) begin
    state <= IDLE;
  end
  else if (s_tick) state <= next_state;
end

// always @(posedge clk or negedge reset_n) begin
//   if (~reset_n) begin
//     temp_reg <= 0;
//   end
//   else if (s_tick) begin
//     temp_reg <= temp_next;
//   end
// end

always @* begin 
  // next-state logic for 
  fifo_rx_rd = 0;
  fifo_tx_wr = 0;
  // temp_next = 0;
  case(state)
    IDLE: begin           
      if (~rx_empty & ~tx_full) begin      
        // temp_next = bus_data_out;
        // fifo_rx_rd = 1; // output set in this state would be RESET in the next state
        fifo_tx_wr = 1;
        next_state = ON;
      end
      else begin
        next_state = IDLE;
      end
    end
    ON: begin      
      // fifo_tx_wr = 1;
      // temp_next = bus_data_out;   
      if (rx_empty | tx_full) begin
        next_state = IDLE;
      end 
      else begin          
        fifo_rx_rd = 1;   
        next_state = ON;
      end
      
    end
  endcase
end

// Sampling Clock
uart_sampling_tick #(SYS_FREQ,BAUD_RATE,CLOCK,SAMPLE,BAUD_DVSR)
uart_sampling_tick (
  .clk       (clk       ),
  .reset_n   (reset_n   ),
  .s_tick     (s_tick     )
  );

// Transmitter
uart_tx #(
  .DATA_SIZE (DATA_SIZE))
uart_tx(
  .clk              (clk          ),
  .s_tick           (s_tick       ),
  .reset_n          (reset_n        ),
  .tx_start         (tx_start     ),
  .data_in          (tx_data_in     ),
  .tx               (tx),
  .tx_done_tick     (tx_done        )
  );

uart_fifo #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_fifo_tx (
  .clk      (clk         ),
  .s_tick   (s_tick      ),
  .reset_n  (reset_n     ),
  .w_data   (bus_data_in ),
  // .w_data   (temp_reg),
  .r_data   (tx_data_in  ),
  .wr       (fifo_tx_wr  ),
  .rd       (tx_done     ),
  .full     (tx_full     ),
  .empty    (tx_empty    )
  );

// Receiver
uart_rx #(
  .DATA_SIZE (DATA_SIZE))
uart_rx (
  .clk              (clk),
  .s_tick           (s_tick),
  .reset_n          (reset_n),
  .rx_start         (rx_start),
  .rx               (rx),
  .data_out         (rx_data_out),
  .rx_done_tick     (rx_done)
  );

uart_fifo #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_fifo_rx (
  .clk      (clk         ),
  .s_tick   (s_tick      ),
  .reset_n  (reset_n     ),
  .w_data   (rx_data_out ),
  .r_data   (bus_data_out  ),
  .wr       (rx_done  ),
  .rd       (fifo_rx_rd),
  .full     (rx_full     ),
  .empty    (rx_empty    )
  );

endmodule 