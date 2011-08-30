*** Steps to create the Spartan-6 DDR3 memory interface for the SP605 development board.
These instructions are based on using Xilinx ISE 11.5

Use Coregen/MIG 3.3 to create the controller. 
- Component Name: ddr3
- Bank 3 Memory Type DDR3 SDRAM
- Frequency: 400MHz
- Memory Part: MT41J64M16XX-187E
- Configuration Selection: One 128-bit bi-directional port
- Memory Address Mapping Selection: Row, Bank, Column


Once the controller is generated copy all the Verilog files from the user_design/rtl directory to $AMBER_BASE/hw/vlog/xs6_ddr3.

Then make the following modifications

1. ddr3.v
Rename this module to mcb_ddr3.v.
Replace the inputs c3_sys_clk_p, c3_sys_clk_n with sys_clk_ibufg.
Delete the outputs c3_clk0 and c3_rst0.

2. memc3_infrastructure.v
Replace the inputs sys_clk_p, sys_clk_n with sys_clk_ibufg.
Delete the outputs clk0 and rst0.
Delete the line with (* KEEP = "TRUE" *) wire sys_clk_ibufg;

Change the localparam from
localparam CLK_PERIOD_NS = C_MEMCLK_PERIOD / 1000.0;
to
localparam CLK_PERIOD_NS = C_MEMCLK_PERIOD / 500.0;

Delete the generate statement from lines 124 to 154

On the PLL_ADV instantiation, 
    Change the parameter CLKFBOUT_MULT from 2 to 4.
    Disconnect the CLKOUT2 output

Delete the U_BUFG_CLK0 instantiation.
Delete the rst0_sync_r logic.
