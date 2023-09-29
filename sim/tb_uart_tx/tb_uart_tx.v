`timescale 1ns/1ns //50MHz => 1 duty cycle = 10ns

module tb_uart_tx #(
  parameter DATA_SIZE       = 8,
  parameter BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1),
  parameter SYS_FREQ  = 50000000,
  parameter BAUD_RATE = 115200,
  parameter CLOCK     = SYS_FREQ/BAUD_RATE,
  parameter SAMPLE    = 16,
  parameter BAUD_DVSR = SYS_FREQ/(SAMPLE*BAUD_RATE) // baud rate divisor
  )();
//Input
reg                     clk            ;
reg                     reset_n        ;
reg                     tx_start     ;
reg [DATA_SIZE - 1 : 0] data_in        ;
//Output
wire                     tx;
wire                     tx_done_tick        ;

wire s_tick;

uart_sampling_tick #() uart_sampling_tick(
  .clk       (clk       ),
  .reset_n   (reset_n   ),
  .s_tick     (s_tick     )
  );
//Instantiate the Unit Under Test (UUT)
uart_tx #(
  .DATA_SIZE (DATA_SIZE))
uart_tx(
  .clk            (clk            ),
  .s_tick         (s_tick         ),
  .reset_n        (reset_n        ),
  .data_in        (data_in        ),
  .tx_start       (tx_start     ),
  .tx             (tx),
  .tx_done_tick   (tx_done_tick        )
  );

always #10 clk = ~clk;

initial begin
  $display("SYS_FREQ = %d", SYS_FREQ);
  $display("BAUD_RATE = %d", BAUD_RATE);
  $display("CLOCK = %f", CLOCK);
  $display("BAUD_DVSR = %f", BAUD_DVSR);
  clk = 0;
  reset_n = 1;
  tx_start = 0;
  repeat (BAUD_DVSR) @(negedge clk);
  reset_n = 0;
  repeat (BAUD_DVSR) @(negedge clk);
  reset_n = 1;
  repeat (BAUD_DVSR) @(posedge clk);
  data_in = 11001011;
  repeat (16*2*BAUD_DVSR) @(negedge clk);
  tx_start = 1;
  repeat (16*12*BAUD_DVSR) @(negedge clk);
  // data_in = 00101001;
  // tx_start = 0;
  // repeat (16*3*BAUD_DVSR) @(negedge clk);
  // tx_start = 1;
  // repeat (16*11*BAUD_DVSR) @(negedge clk);
  $finish;

end

endmodule 