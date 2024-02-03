##############################
# BOARD SPECIFIC CONSTRAINTS #
##############################

#############
# Sys clock #
#############

# 100 MHz ref clock single ended out of the diff buffer (cheshire_top_xilinx.sv)
set SYS_TCK 10
create_clock -period $SYS_TCK -name sys_clk [get_pins u_ibufg_sys_clk/O]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_pins u_ibufg_sys_clk/O]

#############
# Mig clock #
#############

# Dram axi clock : 750ps * 4
set MIG_TCK 3
create_generated_clock -source [get_pins i_dram_wrapper/i_dram/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0] \
 -divide_by 1 -add -master_clock mmcm_clkout0 -name dram_axi_clk [get_pins i_dram_wrapper/i_dram/c0_ddr4_ui_clk]
# Aynch reset in
set MIG_RST_I [get_pin i_dram_wrapper/i_dram/inst/c0_ddr4_aresetn]
set_false_path -hold -setup -through $MIG_RST_I
# Synch reset out
set MIG_RST_O [get_pins i_dram_wrapper/i_dram/c0_ddr4_ui_clk_sync_rst]
set_false_path -hold -through $MIG_RST_O
set_max_delay -through $MIG_RST_O $MIG_TCK

########
# CDCs #
########

# The only CDC of the design is before in the dram wrapper (xilinx_dram_wrapper.sv)
set_max_delay -datapath \
 -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
  -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*i_sync/reg*/D] $MIG_TCK

set_max_delay -datapath \
 -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
  -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] $MIG_TCK

#################################################################################

###############
# ASSIGN PINS #
###############

#  VCU128 Rev1.0 XDC
#  Date: 01/24/2018

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
set_property PACKAGE_PIN BM29 [get_ports cpu_reset]
set_property IOSTANDARD LVCMOS12 [get_ports cpu_reset]