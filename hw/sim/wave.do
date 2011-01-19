onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix unsigned /tb/u_system/u_amber/u_decode/u_decompile/clk_count
add wave -noupdate -expand -group Amber -format Logic /tb/u_system/u_amber/u_fetch/o_fetch_stall
add wave -noupdate -expand -group Amber -format Literal /tb/u_system/u_amber/u_fetch/i_write_data
add wave -noupdate -expand -group Amber -format Logic /tb/u_system/u_amber/u_fetch/i_write_enable
add wave -noupdate -expand -group Amber -format Literal /tb/u_system/u_amber/u_fetch/i_address
add wave -noupdate -expand -group Amber -format Literal /tb/u_system/u_amber/u_fetch/o_read_data
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/swi_request
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/i_fetch_stall
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal /tb/u_system/u_amber/u_decode/i_read_data
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal /tb/u_system/u_amber/u_decode/o_read_data
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal /tb/u_system/u_amber/u_decode/instruction
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/interrupt
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal /tb/u_system/u_amber/u_decode/interrupt_mode
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal /tb/u_system/u_amber/u_decode/next_interrupt
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal -radix ascii /tb/u_system/u_amber/u_decode/xMODE
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal -radix ascii /tb/u_system/u_amber/u_decode/xCONTROL_STATE
add wave -noupdate -expand -group Amber -expand -group Execute -format Logic /tb/u_system/u_amber/u_decode/instruction_execute
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_decode/pre_fetch_instruction
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal -radix ascii /tb/u_system/u_amber/u_decode/u_decompile/xINSTRUCTION_EXECUTE
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal -radix ascii /tb/u_system/u_amber/u_decode/xCONTROL_STATE
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal -radix ascii /tb/u_system/u_amber/u_decode/xMODE
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r0
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r1
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r2
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r3
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r12_out
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r13_out
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r14_out
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r15
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/i_pc_sel
add wave -noupdate -expand -group Amber -expand -group Execute -format Logic /tb/u_system/u_amber/u_decode/o_pc_wen
add wave -noupdate -expand -group Amber -expand -group Execute -format Logic /tb/u_system/u_amber/u_decode/u_decompile/execute_valid
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r14_irq
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/pc
add wave -noupdate -expand -group Amber -expand -group Execute -format Logic /tb/u_system/u_amber/u_execute/pc_wen
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/i_pc_sel
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/alu_out
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/o_address
add wave -noupdate -expand -group Amber -expand -group Execute -format Logic /tb/u_system/u_amber/u_execute/i_status_bits_flags_wen
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/status_bits_flags
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/i_status_bits_sel
add wave -noupdate -expand -group Amber -expand -group Execute -format Literal /tb/u_system/u_amber/u_execute/i_condition
add wave -noupdate -expand -group Amber -expand -group Execute -format Logic /tb/u_system/u_amber/u_execute/execute
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Logic /tb/u_system/u_amber/u_fetch/u_cache/o_stall
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Logic /tb/u_system/u_amber/u_fetch/u_cache/hit
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Literal -radix ascii /tb/u_system/u_amber/u_fetch/u_cache/xC_STATE
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Literal -radix ascii /tb/u_system/u_amber/u_fetch/u_cache/xSOURCE_SEL
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Literal /tb/u_system/u_amber/u_fetch/u_cache/o_read_data
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Logic /tb/u_system/u_amber/u_coprocessor/o_cache_enable
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Logic /tb/u_system/u_amber/u_fetch/u_cache/i_core_stall
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Logic /tb/u_system/u_amber/u_fetch/u_cache/i_select
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Logic /tb/u_system/u_amber/u_fetch/sel_cache
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Literal /tb/u_system/u_amber/u_fetch/u_cache/tag_address
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Literal /tb/u_system/u_amber/u_fetch/u_cache/tag_wdata
add wave -noupdate -expand -group Amber -group Fetch -expand -group Cache -format Logic /tb/u_system/u_amber/u_fetch/u_cache/tag_wenable
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/o_stall
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/servicing_cache
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/start_access
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/wait_write_ack
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/core_read_request
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/core_write_request
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/cache_read_request
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/servicing_cache
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/i_select
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/i_exclusive
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/exclusive_access
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -group int -format Logic /tb/u_system/u_amber/u_fetch/u_wishbone/i_write_enable
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -format Literal -radix ascii /tb/u_system/u_amber/u_fetch/u_wishbone/xAS_STATE
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -format Logic /tb/u_system/u_amber/o_wb_cyc
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -format Logic /tb/u_system/u_amber/o_wb_stb
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -format Logic /tb/u_system/u_amber/i_wb_ack
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -format Literal /tb/u_system/u_amber/u_fetch/u_wishbone/o_wb_adr
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -format Literal /tb/u_system/u_amber/o_wb_dat
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -format Literal /tb/u_system/u_amber/o_wb_sel
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -format Logic /tb/u_system/u_amber/o_wb_we
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -format Literal /tb/u_system/u_amber/i_wb_dat
add wave -noupdate -expand -group Amber -group Fetch -expand -group Wishbone -format Logic /tb/u_system/u_amber/i_wb_err
add wave -noupdate -expand -group Amber -group Co-Processor -format Literal /tb/u_system/u_amber/u_coprocessor/fault_address
add wave -noupdate -expand -group Amber -group Co-Processor -format Literal /tb/u_system/u_amber/u_coprocessor/fault_status
add wave -noupdate -group {Boot Mem} -format Logic /tb/u_system/u_boot_mem/i_wb_stb
add wave -noupdate -group {Boot Mem} -format Logic /tb/u_system/u_boot_mem/o_wb_ack
add wave -noupdate -group {Boot Mem} -format Logic /tb/u_system/u_boot_mem/i_wb_we
add wave -noupdate -group {Boot Mem} -format Literal /tb/u_system/u_boot_mem/i_wb_adr
add wave -noupdate -group {Boot Mem} -format Literal /tb/u_system/u_boot_mem/i_wb_dat
add wave -noupdate -group {Boot Mem} -format Literal /tb/u_system/u_boot_mem/o_wb_dat
add wave -noupdate -group ETHMAC -group {Wishbone Master} -format Logic /tb/u_system/u_eth_top/m_wb_cyc_o
add wave -noupdate -group ETHMAC -group {Wishbone Master} -format Logic /tb/u_system/u_eth_top/m_wb_stb_o
add wave -noupdate -group ETHMAC -group {Wishbone Master} -format Logic /tb/u_system/u_eth_top/m_wb_ack_i
add wave -noupdate -group ETHMAC -group {Wishbone Master} -format Literal /tb/u_system/u_eth_top/m_wb_adr_o
add wave -noupdate -group ETHMAC -group {Wishbone Master} -format Literal /tb/u_system/u_eth_top/m_wb_adr_tmp
add wave -noupdate -group ETHMAC -group {Wishbone Master} -format Literal /tb/u_system/u_eth_top/m_wb_dat_i
add wave -noupdate -group ETHMAC -group {Wishbone Master} -format Literal /tb/u_system/u_eth_top/m_wb_dat_o
add wave -noupdate -group ETHMAC -group {Wishbone Master} -format Logic /tb/u_system/u_eth_top/m_wb_err_i
add wave -noupdate -group ETHMAC -group {Wishbone Master} -format Literal /tb/u_system/u_eth_top/m_wb_sel_o
add wave -noupdate -group ETHMAC -group {Wishbone Master} -format Logic /tb/u_system/u_eth_top/m_wb_we_o
add wave -noupdate -group ETHMAC -group {Wishbone slave} -format Logic /tb/u_system/u_eth_top/wb_cyc_i
add wave -noupdate -group ETHMAC -group {Wishbone slave} -format Logic /tb/u_system/u_eth_top/wb_stb_i
add wave -noupdate -group ETHMAC -group {Wishbone slave} -format Logic /tb/u_system/u_eth_top/wb_ack_o
add wave -noupdate -group ETHMAC -group {Wishbone slave} -format Literal /tb/u_system/u_eth_top/wb_adr_i
add wave -noupdate -group ETHMAC -group {Wishbone slave} -format Literal /tb/u_system/u_eth_top/wb_dat_i
add wave -noupdate -group ETHMAC -group {Wishbone slave} -format Literal /tb/u_system/u_eth_top/wb_dat_o
add wave -noupdate -group ETHMAC -group {Wishbone slave} -format Logic /tb/u_system/u_eth_top/wb_err_o
add wave -noupdate -group ETHMAC -group {Wishbone slave} -format Literal /tb/u_system/u_eth_top/wb_sel_i
add wave -noupdate -group ETHMAC -group {Wishbone slave} -format Logic /tb/u_system/u_eth_top/wb_we_i
add wave -noupdate -group ETHMAC -format Literal /tb/u_system/mtxd_pad_o
add wave -noupdate -group ETHMAC -format Logic /tb/u_system/mtxen_pad_o
add wave -noupdate -group ETHMAC -group MDIO -format Logic /tb/u_system/md_pad_io
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/rx_interrupt
add wave -noupdate -group UART0 -format Literal /tb/u_system/u_uart0/rx_fifo_count
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/rx_fifo_empty
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/rx_fifo_push
add wave -noupdate -group UART0 -format Literal /tb/u_system/u_uart0/rx_bit_pulse_count
add wave -noupdate -group UART0 -format Literal /tb/u_system/u_uart0/rx_byte
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/rx_fifo_pop
add wave -noupdate -group UART0 -format Literal {/tb/u_system/u_uart0/rx_fifo[1]}
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/rx_fifo_pop_not_empty
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/tx_fifo_full
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/tx_fifo_push
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/tx_fifo_push_not_full
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/o_uart_txd
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/o_uart_int
add wave -noupdate -group UART0 -format Logic /tb/u_system/u_uart0/i_uart_cts_n
add wave -noupdate -group UART0 -expand -group {Wishbone IF} -format Logic /tb/u_system/u_uart0/i_wb_stb
add wave -noupdate -group UART0 -expand -group {Wishbone IF} -format Logic /tb/u_system/u_uart0/i_wb_cyc
add wave -noupdate -group UART0 -expand -group {Wishbone IF} -format Literal /tb/u_system/u_uart0/i_wb_adr
add wave -noupdate -group UART0 -expand -group {Wishbone IF} -format Logic /tb/u_system/u_uart0/o_wb_ack
add wave -noupdate -group UART0 -expand -group {Wishbone IF} -format Literal /tb/u_system/u_uart0/o_wb_dat
add wave -noupdate -group UART0 -expand -group {Wishbone IF} -format Literal /tb/u_system/u_uart0/i_wb_dat
add wave -noupdate -group UART0 -expand -group {Wishbone IF} -format Literal /tb/u_system/u_uart0/i_wb_sel
add wave -noupdate -group UART0 -expand -group {Wishbone IF} -format Logic /tb/u_system/u_uart0/i_wb_we
add wave -noupdate -group UART0 -expand -group {Wishbone IF} -format Logic /tb/u_system/u_uart0/wb_start_write
add wave -noupdate -group {Wishbone Arbiter} -format Literal /tb/u_system/u_wishbone_arbiter/master_adr
add wave -noupdate -group {Wishbone Arbiter} -format Logic /tb/u_system/u_wishbone_arbiter/select_master
add wave -noupdate -group {Wishbone Arbiter} -format Logic /tb/u_system/u_wishbone_arbiter/current_master
add wave -noupdate -group {Wishbone Arbiter} -format Literal /tb/u_system/u_wishbone_arbiter/master_adr
add wave -noupdate -group {Wishbone Arbiter} -format Literal /tb/u_system/u_wishbone_arbiter/master_wdat
add wave -noupdate -group {Wishbone Arbiter} -group M0 -format Logic /tb/u_system/u_wishbone_arbiter/i_m0_wb_cyc
add wave -noupdate -group {Wishbone Arbiter} -group M0 -format Logic /tb/u_system/u_wishbone_arbiter/i_m0_wb_stb
add wave -noupdate -group {Wishbone Arbiter} -group M0 -format Logic /tb/u_system/u_wishbone_arbiter/o_m0_wb_ack
add wave -noupdate -group {Wishbone Arbiter} -group M0 -format Literal /tb/u_system/u_wishbone_arbiter/i_m0_wb_adr
add wave -noupdate -group {Wishbone Arbiter} -group M0 -format Literal /tb/u_system/u_wishbone_arbiter/i_m0_wb_dat
add wave -noupdate -group {Wishbone Arbiter} -group M0 -format Literal /tb/u_system/u_wishbone_arbiter/i_m0_wb_sel
add wave -noupdate -group {Wishbone Arbiter} -group M0 -format Logic /tb/u_system/u_wishbone_arbiter/i_m0_wb_we
add wave -noupdate -group {Wishbone Arbiter} -group M0 -format Literal /tb/u_system/u_wishbone_arbiter/o_m0_wb_dat
add wave -noupdate -group {Wishbone Arbiter} -group M0 -format Logic /tb/u_system/u_wishbone_arbiter/o_m0_wb_err
add wave -noupdate -group {Wishbone Arbiter} -group M1 -format Logic /tb/u_system/u_wishbone_arbiter/i_m1_wb_cyc
add wave -noupdate -group {Wishbone Arbiter} -group M1 -format Logic /tb/u_system/u_wishbone_arbiter/i_m1_wb_stb
add wave -noupdate -group {Wishbone Arbiter} -group M1 -format Logic /tb/u_system/u_wishbone_arbiter/o_m1_wb_ack
add wave -noupdate -group {Wishbone Arbiter} -group M1 -format Literal /tb/u_system/u_wishbone_arbiter/i_m1_wb_adr
add wave -noupdate -group {Wishbone Arbiter} -group M1 -format Literal /tb/u_system/u_wishbone_arbiter/i_m1_wb_dat
add wave -noupdate -group {Wishbone Arbiter} -group M1 -format Literal /tb/u_system/u_wishbone_arbiter/i_m1_wb_sel
add wave -noupdate -group {Wishbone Arbiter} -group M1 -format Logic /tb/u_system/u_wishbone_arbiter/i_m1_wb_we
add wave -noupdate -group {Wishbone Arbiter} -group M1 -format Literal /tb/u_system/u_wishbone_arbiter/o_m1_wb_dat
add wave -noupdate -group {Wishbone Arbiter} -group M1 -format Logic /tb/u_system/u_wishbone_arbiter/o_m1_wb_err
add wave -noupdate -group tb_uart -format Logic /tb/u_tb_uart/o_uart_txd
add wave -noupdate -group tb_uart -format Logic /tb/u_tb_uart/i_uart_cts_n
add wave -noupdate -group tb_uart -format Logic /tb/u_tb_uart/txfifo_empty
add wave -noupdate -group tb_uart -format Logic /tb/u_tb_uart/txfifo_full
add wave -noupdate -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_addr
add wave -noupdate -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_ba
add wave -noupdate -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_cas_n
add wave -noupdate -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_ck_n
add wave -noupdate -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_ck_p
add wave -noupdate -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_cke
add wave -noupdate -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_dm
add wave -noupdate -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_dq
add wave -noupdate -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_dqs_n
add wave -noupdate -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_dqs_p
add wave -noupdate -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_odt
add wave -noupdate -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_ras_n
add wave -noupdate -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_reset_n
add wave -noupdate -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_we_n
add wave -noupdate -format Logic /tb/u_system/u_amber/u_fetch/address_cachable
add wave -noupdate -format Logic /tb/u_system/u_amber/u_fetch/i_cache_enable
add wave -noupdate -format Literal /tb/u_system/u_amber/u_fetch/i_cacheable_area
add wave -noupdate -format Logic /tb/u_system/u_amber/u_fetch/i_cache_flush
add wave -noupdate -format Logic /tb/u_system/u_amber/u_execute/o_adex
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10415856 ps} 0} {{Cursor 3} {8693623333 ps} 0}
configure wave -namecolwidth 279
configure wave -valuecolwidth 201
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 4000
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {8693523542 ps} {8693947010 ps}
