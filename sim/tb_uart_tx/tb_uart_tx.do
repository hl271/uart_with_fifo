cd C:/MEGA_SYNC/UNIVERSITY/EDABK_Lab/Final_Prj_UART/sim

vlog ../../hdl/uart_sampling_tick.v ../../hdl/uart_tx.v
vlog tb_uart_tx.v

vsim -voptargs=+acc work.tb_uart_tx

add wave -position insertpoint sim:/tb_uart_tx/*
add wave -position insertpoint sim:/tb_uart_tx/uart_tx/*

run -all