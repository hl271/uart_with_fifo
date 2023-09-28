cd C:/MEGA_SYNC/UNIVERSITY/EDABK_Lab/Final_Prj_UART/sim/uart_rx/

vlog ../../hdl/uart_sampling_tick.v ../../hdl/uart_rx.v
vlog tb_uart_rx.v

vsim -voptargs=+acc work.tb_uart_tx

add wave -position insertpoint sim:/tb_uart_tx/*
add wave -position insertpoint sim:/tb_uart_tx/uart_tx/*

run -all