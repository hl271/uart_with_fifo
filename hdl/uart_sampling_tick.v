/*
    A mod-m counter counts from 0 to M-1, then resets to 0.
*/

module uart_sampling_tick #(
    parameter SYS_FREQ  = 50000000,
    parameter BAUD_RATE = 921600,
    parameter CLOCK     = SYS_FREQ/BAUD_RATE,
    parameter SAMPLE    = 16,
    parameter BAUD_DVSR = SYS_FREQ/(SAMPLE*BAUD_RATE) // baud rate divisor
) (
    input wire      clk, reset_n,
    output wire     s_tick
);
    parameter N = $clog2(BAUD_DVSR);
    /* Since this state machine has only 1 state (inc) hence it can skip the state declaration */
    //signcal declaration
    reg [N-1:0] cnt_reg;
    wire [N-1:0] cnt_next;
    //register
    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            cnt_reg<=0;
        end
        else cnt_reg <= cnt_next;
    end
    //next-state logic
    assign cnt_next = (cnt_reg == (BAUD_DVSR-1)) ? 0 : (cnt_reg + 1);
    //output logic
    assign s_tick = (cnt_reg == (BAUD_DVSR-1)) ? 1'b1 : 1'b0;
endmodule