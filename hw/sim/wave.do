onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix decimal /tb/clk_count
add wave -noupdate -group System -group {uart 0} -format Logic /tb/u_system/u_uart0/i_uart_rxd
add wave -noupdate -group System -group {uart 0} -format Literal {/tb/u_system/u_uart0/rx_fifo[0]}
add wave -noupdate -group System -group {uart 0} -format Logic /tb/u_system/u_uart0/fifo_enable
add wave -noupdate -group System -group {uart 0} -format Logic /tb/u_system/u_uart0/rx_fifo_push
add wave -noupdate -group System -group {uart 0} -format Logic /tb/u_system/u_uart0/rx_fifo_push_not_full
add wave -noupdate -group System -group {uart 0} -format Literal /tb/u_system/u_uart0/rx_byte
add wave -noupdate -group System -group {uart 0} -format Literal -radix ascii /tb/u_system/u_uart0/xRXD_STATE
add wave -noupdate -group System -group {uart 0} -format Literal -radix decimal /tb/u_system/u_uart0/TX_BITADJUST_COUNT
add wave -noupdate -group System -group {uart 0} -format Literal -radix decimal /tb/u_system/u_uart0/TX_BITPULSE_COUNT
add wave -noupdate -group System -group {uart 0} -format Literal -radix ascii /tb/u_system/u_uart0/xTXD_STATE
add wave -noupdate -group System -group tb_uart -format Logic /tb/u_tb_uart/i_uart_rxd
add wave -noupdate -group System -group tb_uart -format Logic /tb/u_tb_uart/o_uart_txd
add wave -noupdate -group System -group tb_uart -format Literal /tb/u_tb_uart/rx_bit_count
add wave -noupdate -group System -group tb_uart -format Logic /tb/u_tb_uart/rx_bit_start
add wave -noupdate -group System -group tb_uart -format Literal /tb/u_tb_uart/rx_byte
add wave -noupdate -group System -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_addr
add wave -noupdate -group System -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_ba
add wave -noupdate -group System -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_cas_n
add wave -noupdate -group System -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_ck_n
add wave -noupdate -group System -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_ck_p
add wave -noupdate -group System -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_cke
add wave -noupdate -group System -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_dm
add wave -noupdate -group System -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_dq
add wave -noupdate -group System -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_dqs_n
add wave -noupdate -group System -group {DDR3 Bus} -format Literal /tb/u_system/ddr3_dqs_p
add wave -noupdate -group System -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_odt
add wave -noupdate -group System -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_ras_n
add wave -noupdate -group System -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_reset_n
add wave -noupdate -group System -group {DDR3 Bus} -format Logic /tb/u_system/ddr3_we_n
add wave -noupdate -expand -group Amber -format Logic /tb/u_system/u_amber/fetch_stall
add wave -noupdate -expand -group Amber -format Logic /tb/u_system/u_amber/mem_stall
add wave -noupdate -expand -group Amber -expand -group Fetch -format Literal /tb/u_system/u_amber/u_fetch/i_iaddress
add wave -noupdate -expand -group Amber -expand -group Fetch -format Logic /tb/u_system/u_amber/u_fetch/i_iaddress_valid
add wave -noupdate -expand -group Amber -expand -group Fetch -format Literal /tb/u_system/u_amber/u_fetch/o_fetch_instruction
add wave -noupdate -expand -group Amber -expand -group Fetch -format Logic /tb/u_system/u_amber/u_fetch/o_wb_req
add wave -noupdate -expand -group Amber -expand -group Fetch -format Logic /tb/u_system/u_amber/u_fetch/o_fetch_stall
add wave -noupdate -expand -group Amber -expand -group Fetch -format Logic /tb/u_system/u_amber/u_fetch/sel_cache
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Logic /tb/u_system/u_amber/u_fetch/u_cache/o_stall
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Logic /tb/u_system/u_amber/u_fetch/u_cache/read_stall
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Logic /tb/u_system/u_amber/u_fetch/u_cache/o_wb_req
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Literal -radix ascii /tb/u_system/u_amber/u_fetch/u_cache/xC_STATE
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Literal /tb/u_system/u_amber/u_fetch/u_cache/miss_address
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Logic /tb/u_system/u_amber/u_fetch/u_cache/read_miss
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Literal /tb/u_system/u_amber/u_fetch/u_cache/o_read_data
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Logic /tb/u_system/u_amber/u_coprocessor/o_cache_enable
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Logic /tb/u_system/u_amber/u_fetch/u_cache/i_core_stall
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Logic /tb/u_system/u_amber/u_fetch/u_cache/i_select
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Logic /tb/u_system/u_amber/u_fetch/sel_cache
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Literal /tb/u_system/u_amber/u_fetch/u_cache/tag_wdata
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Literal /tb/u_system/u_amber/u_fetch/u_cache/tag_address
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Logic /tb/u_system/u_amber/u_fetch/u_cache/tag_wenable
add wave -noupdate -expand -group Amber -expand -group Fetch -group {Instruction Cache} -format Literal /tb/u_system/u_amber/u_fetch/u_cache/data_wdata
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal -radix ascii /tb/u_system/u_amber/u_decode/xTYPE
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal -radix ascii /tb/u_system/u_amber/u_decode/xMODE
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal -radix ascii /tb/u_system/u_amber/u_decode/xCONTROL_STATE
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/instruction_execute
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/decode_iaccess_nxt
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/interrupt
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal /tb/u_system/u_amber/u_decode/mtrans_num_registers
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/pre_fetch_instruction_wen
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal /tb/u_system/u_amber/u_decode/fetch_instruction_r
add wave -noupdate -expand -group Amber -expand -group Decode -format Literal /tb/u_system/u_amber/u_decode/instruction
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/instruction_valid
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/saved_current_instruction_wen
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/use_saved_current_instruction
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/pc_wen_nxt
add wave -noupdate -expand -group Amber -expand -group Decode -format Logic /tb/u_system/u_amber/u_decode/write_pc
add wave -noupdate -expand -group Amber -expand -group Decode -expand -group Conflict -format Logic /tb/u_system/u_amber/u_decode/rn_conflict1
add wave -noupdate -expand -group Amber -expand -group Decode -expand -group Conflict -format Logic /tb/u_system/u_amber/u_decode/rn_conflict2
add wave -noupdate -expand -group Amber -expand -group Decode -expand -group Conflict -format Logic /tb/u_system/u_amber/u_decode/conflict1
add wave -noupdate -expand -group Amber -expand -group Decode -expand -group Conflict -format Logic /tb/u_system/u_amber/u_decode/conflict2
add wave -noupdate -expand -group Amber -group Execute -format Logic /tb/u_system/u_amber/u_execute/execute
add wave -noupdate -expand -group Amber -group Execute -format Literal -radix ascii /tb/u_system/u_amber/u_decode/u_decompile/xINSTRUCTION_EXECUTE
add wave -noupdate -expand -group Amber -group Execute -format Literal /tb/u_system/u_amber/u_execute/i_pc_sel
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r0
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r1
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r2
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r3
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r12_out
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r13_out
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r14_out
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Logic /tb/u_system/u_amber/u_execute/pc_wen
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Literal /tb/u_system/u_amber/u_execute/pc_nxt
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Literal /tb/u_system/u_amber/u_execute/rn
add wave -noupdate -expand -group Amber -group Execute -expand -group Registers -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r15
add wave -noupdate -expand -group Amber -group Execute -group internals -format Logic /tb/u_system/u_amber/u_decode/instruction_execute
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal /tb/u_system/u_amber/u_decode/pre_fetch_instruction
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal -radix ascii /tb/u_system/u_amber/u_decode/u_decompile/xINSTRUCTION_EXECUTE
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal -radix ascii /tb/u_system/u_amber/u_decode/xCONTROL_STATE
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal -radix ascii /tb/u_system/u_amber/u_decode/xMODE
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal /tb/u_system/u_amber/u_execute/i_pc_sel
add wave -noupdate -expand -group Amber -group Execute -group internals -format Logic /tb/u_system/u_amber/u_decode/o_pc_wen
add wave -noupdate -expand -group Amber -group Execute -group internals -format Logic /tb/u_system/u_amber/u_decode/u_decompile/execute_valid
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal /tb/u_system/u_amber/u_execute/u_register_bank/r14_irq
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal /tb/u_system/u_amber/u_execute/pc
add wave -noupdate -expand -group Amber -group Execute -group internals -format Logic /tb/u_system/u_amber/u_execute/pc_wen
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal /tb/u_system/u_amber/u_execute/i_pc_sel
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal /tb/u_system/u_amber/u_execute/alu_out
add wave -noupdate -expand -group Amber -group Execute -group internals -format Logic /tb/u_system/u_amber/u_execute/i_status_bits_flags_wen
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal /tb/u_system/u_amber/u_execute/status_bits_flags
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal /tb/u_system/u_amber/u_execute/i_status_bits_sel
add wave -noupdate -expand -group Amber -group Execute -group internals -format Literal /tb/u_system/u_amber/u_execute/i_condition
add wave -noupdate -expand -group Amber -group Execute -group internals -format Logic /tb/u_system/u_amber/u_execute/execute
add wave -noupdate -expand -group Amber -group Wishbone -expand -group {WB Bus} -format Logic /tb/u_system/u_amber/o_wb_cyc
add wave -noupdate -expand -group Amber -group Wishbone -expand -group {WB Bus} -format Logic /tb/u_system/u_amber/o_wb_stb
add wave -noupdate -expand -group Amber -group Wishbone -expand -group {WB Bus} -format Logic /tb/u_system/u_amber/i_wb_ack
add wave -noupdate -expand -group Amber -group Wishbone -expand -group {WB Bus} -format Literal /tb/u_system/u_amber/u_wishbone/o_wb_adr
add wave -noupdate -expand -group Amber -group Wishbone -expand -group {WB Bus} -format Literal /tb/u_system/u_amber/o_wb_dat
add wave -noupdate -expand -group Amber -group Wishbone -expand -group {WB Bus} -format Literal /tb/u_system/u_amber/o_wb_sel
add wave -noupdate -expand -group Amber -group Wishbone -expand -group {WB Bus} -format Logic /tb/u_system/u_amber/o_wb_we
add wave -noupdate -expand -group Amber -group Wishbone -expand -group {WB Bus} -format Literal /tb/u_system/u_amber/i_wb_dat
add wave -noupdate -expand -group Amber -group Wishbone -expand -group {WB Bus} -format Logic /tb/u_system/u_amber/i_wb_err
add wave -noupdate -expand -group Amber -group Co-Processor -format Literal /tb/u_system/u_amber/u_coprocessor/fault_address
add wave -noupdate -expand -group Amber -group Co-Processor -format Literal /tb/u_system/u_amber/u_coprocessor/fault_status
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1138913 ps} 0} {{Cursor 3} {10386717250 ps} 0}
configure wave -namecolwidth 279
configure wave -valuecolwidth 174
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
WaveRestoreZoom {913193 ps} {1614177 ps}
