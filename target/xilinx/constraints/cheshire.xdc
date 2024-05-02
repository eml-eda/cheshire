# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

###################
# Global Settings #
###################

# Testmode is set to 0 during normal use
set_case_analysis 0 [get_ports test_mode_i]

#####################
# Timing Parameters #
#####################

# 200 MHz FPGA diff clock
set FPGA_TCK 20.0

# 50 MHz SoC clock
set SOC_TCK 20.0

# 10 MHz JTAG clock
set JTAG_TCK 100.0

# I2C High-speed mode is 3.2 Mb/s
set I2C_IO_SPEED 312.5

# UART speed is at most 5 Mb/s
set UART_IO_SPEED 200.0

#################
# Clocks #
#################


# System Clock
create_clock -period $FPGA_TCK -name soc_clk [get_ports sysclk_p]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets soc_clk]

# JTAG Clock
create_clock -period $JTAG_TCK -name clk_jtag [get_ports jtag_tck_i]
set_input_jitter clk_jtag 1.000

################
# Clock Groups #
################

# JTAG Clock is asynchronous to all other clocks
set_clock_groups -name jtag_async -asynchronous -group [get_clocks clk_jtag]



# JTAG is on non-clock-capable GPIOs (if not using BSCANE)
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports jtag_tck_i]]
#set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports jtag_tck_i]]

#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports   cpu_reset]]
#set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports cpu_reset]]

# Remove avoid tc_clk_mux2 to use global clock routing
#set all_in_mux [get_nets -of [ get_pins -filter { DIRECTION == IN } -of [get_cells -hier -filter { ORIG_REF_NAME == tc_clk_mux2 || REF_NAME == tc_clk_mux2 }]]]
#set_property CLOCK_DEDICATED_ROUTE FALSE $all_in_mux
#set_property CLOCK_BUFFER_TYPE NONE $all_in_mux

########
# JTAG #
########

# JTAG Clock

set_input_delay  -min -clock clk_jtag [expr 0.10 * $JTAG_TCK] [get_ports {jtag_tdi_i jtag_tms_i}]
set_input_delay  -max -clock clk_jtag [expr 0.20 * $JTAG_TCK] [get_ports {jtag_tdi_i jtag_tms_i}]

set_output_delay -min -clock clk_jtag [expr 0.10 * $JTAG_TCK] [get_ports jtag_tdo_o]
set_output_delay -max -clock clk_jtag [expr 0.20 * $JTAG_TCK] [get_ports jtag_tdo_o]

#set_max_delay  -from [get_ports jtag_trst_ni] $JTAG_TCK
#set_false_path -hold -from [get_ports jtag_trst_ni]

########
# UART #
########

set_max_delay [expr $UART_IO_SPEED * 0.35] -from [get_ports uart_rx_i]
set_false_path -hold -from [get_ports uart_rx_i]

set_max_delay [expr $UART_IO_SPEED * 0.35] -to [get_ports uart_tx_o]
set_false_path -hold -to [get_ports uart_tx_o]

#######
# I2C #
#######

set_max_delay [expr $I2C_IO_SPEED * 0.35] -from [get_ports {i2c_scl_io i2c_sda_io}]
set_false_path -hold -from [get_ports {i2c_scl_io i2c_sda_io}]

set_max_delay [expr $I2C_IO_SPEED * 0.35] -to [get_ports {i2c_scl_io i2c_sda_io}]
set_false_path -hold -to [get_ports {i2c_scl_io i2c_sda_io}]

############
# Switches #
############

set_input_delay -min -clock soc_clk [expr $SOC_TCK * 0.10] [get_ports {boot_mode* test_mode_i}]
set_input_delay -max -clock soc_clk [expr $SOC_TCK * 0.35] [get_ports {boot_mode* test_mode_i}]
set_max_delay [expr 2 * $SOC_TCK] -from [get_ports {boot_mode* test_mode_i}]
set_false_path -hold -from [get_ports {boot_mode*  test_mode_i}]

########
# CDCs #
########

# Disable hold checks on CDCs
#set_property KEEP_HIERARCHY SOFT [get_cells -hier -filter {ORIG_REF_NAME=="sync" || REF_NAME=="sync"}]
#set_false_path -hold -through [get_pins -of_objects [get_cells -hier -filter {ORIG_REF_NAME=="sync" || REF_NAME=="sync"}] -filter {NAME=~*serial_i}]

#set_false_path -hold -through [get_pins -of_objects [get_cells -hier -filter {ORIG_REF_NAME == axi_cdc_src || REF_NAME == axi_cdc_src}] -filter {NAME =~ *async*}]
#set_false_path -hold -through [get_pins -of_objects [get_cells -hier -filter {ORIG_REF_NAME == axi_cdc_dst || REF_NAME == axi_cdc_dst}] -filter {NAME =~ *async*}]
