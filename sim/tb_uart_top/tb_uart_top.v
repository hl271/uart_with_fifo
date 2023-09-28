//-----------------------------------------------------------------------------------------------------------
`timescale 1ns/1ns
module tb_uart_protocol #(
  parameter DATA_SIZE       = 8,
            SIZE_FIFO       = 8,
            BIT_COUNT_SIZE  = $clog2(DATA_SIZE+1),
            SYS_FREQ        = 50000000,
            BAUD_RATE       = 115200,
            CLOCK           = SYS_FREQ/BAUD_RATE,
            SAMPLE          = 16,
            BAUD_DVSR       = SYS_FREQ/(SAMPLE*BAUD_RATE)
  )();
reg                     clk                 ;
reg                     reset_n             ;

reg                       rx    ;
wire                      tx   ;
wire [            2 : 0]  TX_status_register;
wire [            2 : 0]  RX_status_register;


uart_protocol #(
  .DATA_SIZE     (DATA_SIZE ),
  .SIZE_FIFO     (SIZE_FIFO ),
  .SYS_FREQ      (SYS_FREQ  ),
  .BAUD_RATE     (BAUD_RATE ),
  .SAMPLE        (SAMPLE    ))
uart_protocol(
  .clk                  (clk                 ),
  .reset_n              (reset_n             ),
  .rx                   (rx    ),
  .tx                   (tx   ),
  .RX_status_register   (RX_status_register),
  .TX_status_register   (TX_status_register)
  );


always #10 clk = ~clk;

initial begin
  $display("SYS_FREQ = %d", SYS_FREQ);
  $display("BAUD_RATE = %d", BAUD_RATE);
  $display("CLOCK = %f", CLOCK);
  $display("BAUD_DVSR = %f", BAUD_DVSR);
  clk = 0;
  reset_n = 1;
  repeat (BAUD_DVSR) @(negedge clk);
  reset_n = 0;
  repeat (BAUD_DVSR) @(negedge clk);
  reset_n = 1;
  repeat (BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (BAUD_DVSR) @(posedge clk);
  // start bit
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  // receive data bit 11001101
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  //stop bit
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);

  repeat (16*5*BAUD_DVSR) @(negedge clk);
  // start bit
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  // receive data bit 11001101
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 0;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);
  //stop bit
  rx = 1;
  repeat (16*BAUD_DVSR) @(posedge clk);

  repeat (16*20*BAUD_DVSR) @(negedge clk);
  $finish;
end


endmodule : tb_uart_protocol