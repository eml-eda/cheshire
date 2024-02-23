# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

#############
# Sys Clock #
#############

# 100 MHz input clock
set SYS_TCK 10
create_clock -period $SYS_TCK -name sys_clk [get_ports sys_clk_p]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_pins i_bufds_sys_clk/O]

# SoC clock is generated by clock wizard and its constraints
set SOC_TCK 20.0
set soc_clk {clk_50_clkwiz}

#######
# MIG #
#######

# Dram axi clock : 333 MHz (defined by MIG constraints)
set MIG_TCK 3

# False-path incoming reset
set MIG_RST_I [get_pin i_dram_wrapper/i_dram/inst/c0_ddr4_aresetn]
set_false_path -hold -setup -through $MIG_RST_I

# Constrain outgoing reset
set MIG_RST_O [get_pins i_dram_wrapper/i_dram/c0_ddr4_ui_clk_sync_rst]
set_false_path -hold -through $MIG_RST_O
set_max_delay -through $MIG_RST_O $MIG_TCK

# Limit delay across DRAM CDC (hold already false-pathed)
set_max_delay -datapath_only \
 -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
  -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*i_sync/reg*/D] $MIG_TCK
set_max_delay -datapath_only \
 -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
  -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] $MIG_TCK

###############
# Assign Pins #
###############

set_property PACKAGE_PIN BP26     [get_ports "uart_rx_i"] ;# Bank  67 VCCO - VCC1V8   - IO_L2N_T0L_N3_67
set_property IOSTANDARD  LVCMOS18 [get_ports "uart_rx_i"] ;# Bank  67 VCCO - VCC1V8   - IO_L2N_T0L_N3_67
set_property PACKAGE_PIN BN26     [get_ports "uart_tx_o"] ;# Bank  67 VCCO - VCC1V8   - IO_L2P_T0L_N2_67
set_property IOSTANDARD  LVCMOS18 [get_ports "uart_tx_o"] ;# Bank  67 VCCO - VCC1V8   - IO_L2P_T0L_N2_67

# Jtag GPIOs goes to the FMC XM105 where the debug cable is connected (example Digilent HS2)
set_property PACKAGE_PIN A23     [get_ports jtag_gnd_o] ;# A23 - C15 (FMCP_HSPC_LA10_N) - J1.04 - GND
set_property IOSTANDARD LVCMOS18 [get_ports jtag_gnd_o] ;
set_property PACKAGE_PIN B23     [get_ports jtag_vdd_o] ;# B23 - C14 (FMCP_HSPC_LA10_P) - J1.02 - VDD
set_property IOSTANDARD LVCMOS18 [get_ports jtag_vdd_o] ;
set_property PACKAGE_PIN B25     [get_ports jtag_tdo_o] ;# B25 - H17 (FMCP_HSPC_LA11_N) - J1.08 - TDO
set_property IOSTANDARD LVCMOS18 [get_ports jtag_tdo_o]
set_property PACKAGE_PIN B26     [get_ports jtag_tck_i] ;# B26 - H16 (FMCP_HSPC_LA11_P) - J1.06 - TCK
set_property IOSTANDARD LVCMOS18 [get_ports jtag_tck_i] ;
set_property PACKAGE_PIN H22     [get_ports jtag_tms_i] ;# H22 - G16 (FMCP_HSPC_LA12_N) - J1.12 - TNS
set_property IOSTANDARD LVCMOS18 [get_ports jtag_tms_i] ;
set_property PACKAGE_PIN J22     [get_ports jtag_tdi_i] ;# J22 - G15 (FMCP_HSPC_LA12_P) - J1.10 - TDI
set_property IOSTANDARD LVCMOS18 [get_ports jtag_tdi_i]

# Clock diff @ 100MHz
set_property BOARD_PART_PIN default_100mhz_clk_n [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_n]
set_property BOARD_PART_PIN default_100mhz_clk_p [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_p]
set_property PACKAGE_PIN BH51 [get_ports sys_clk_p]
set_property PACKAGE_PIN BJ51 [get_ports sys_clk_n]

# Active high reset
set_property PACKAGE_PIN BM29 [get_ports sys_reset]
set_property IOSTANDARD LVCMOS12 [get_ports sys_reset]
