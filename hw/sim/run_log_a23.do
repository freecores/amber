log -r /tb/u_system/u_amber/u_fetch/*
log -r /tb/u_system/u_amber/u_execute/*
log /tb/u_system/u_amber/u_execute/u_register_bank/*
log /tb/u_system/u_amber/u_decode/*

log /tb/clk_count
log /tb/u_system/u_uart0/i_uart_rxd
log /tb/u_system/u_uart0/rx_fifo
log /tb/u_system/u_uart0/fifo_enable
log /tb/u_system/u_uart0/rx_fifo_push
log /tb/u_system/u_uart0/rx_fifo_push_not_full
log /tb/u_system/u_uart0/rx_byte
log /tb/u_system/u_uart0/xRXD_STATE
log /tb/u_system/u_uart0/TX_BITADJUST_COUNT
log /tb/u_system/u_uart0/TX_BITPULSE_COUNT
log /tb/u_system/u_uart0/xTXD_STATE
log /tb/u_tb_uart/i_uart_rxd
log /tb/u_tb_uart/o_uart_txd
log /tb/u_tb_uart/rx_bit_count
log /tb/u_tb_uart/rx_bit_start
log /tb/u_tb_uart/rx_byte
log /tb/u_system/u_amber/fetch_stall
log /tb/u_system/u_amber/o_wb_cyc
log /tb/u_system/u_amber/o_wb_stb
log /tb/u_system/u_amber/i_wb_ack
log /tb/u_system/u_amber/o_wb_dat
log /tb/u_system/u_amber/o_wb_sel
log /tb/u_system/u_amber/o_wb_we
log /tb/u_system/u_amber/i_wb_dat
log /tb/u_system/u_amber/i_wb_err
log /tb/u_system/u_amber/u_coprocessor/fault_address
log /tb/u_system/u_amber/u_coprocessor/fault_status

run -all
