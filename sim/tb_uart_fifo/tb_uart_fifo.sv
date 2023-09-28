//-----------------------------------------------------------------------------------------------------------
`timescale 1ns/1ns
module tb_uart_fifo #(
  parameter DATA_SIZE   = 8,
            SIZE_FIFO   = 8,
            ADDR_WIDTH  = $clog2(SIZE_FIFO)
  )();

reg                         clk     ;
reg                         reset_n ;
reg  [DATA_SIZE - 1 : 0]    w_data ;
reg                         wr   ;
reg                         rd    ;
wire  [DATA_SIZE - 1 : 0]   r_data;
wire                        full    ;
wire                        empty   ;

uart_fifo #(
  .DATA_SIZE (DATA_SIZE),
  .SIZE_FIFO (SIZE_FIFO))
uart_fifo(
  .clk      (clk     ),
  .reset_n  (reset_n ),
  .w_data   (w_data ),
  .rd       (rd    ),
  .wr       (wr   ),
  .r_data   (r_data),
  .empty    (empty   ),
  .full     (full    )
  );

always #10 clk = ~clk;

initial begin
  clk = 0;
  reset_n = 1;
  wr = 0;
  rd = 0;
  w_data = 0;
  @(negedge clk);
  reset_n = 0;
  @(negedge clk);
  reset_n = 1;
  @(negedge clk);
  w_data = 8'h6C;
  wr = 1;
  @(negedge clk);
  w_data = 8'hAF;
  @(negedge clk);
  w_data = 8'h64;
  rd = 1;
  @(negedge clk);
  w_data =$random();
  rd = 0;
  repeat(7) begin
    @(negedge clk);
    w_data = $random();
  end
  @(negedge clk);
  rd = 1;
  wr = 0;
  repeat(8) begin
    @(negedge clk);
  end
  rd = 0;
  @(negedge clk);
  $finish;

end

endmodule : tb_uart_fifo