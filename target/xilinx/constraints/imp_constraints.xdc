########
# UART #
########
set_false_path -hold -from [get_ports uart_rx_i]
set_false_path -hold -to [get_ports uart_tx_o]

#######
# I2C #
#######
set_false_path -hold -from [get_ports {i2c_scl_io i2c_sda_io}]
set_false_path -hold -to [get_ports {i2c_scl_io i2c_sda_io}]



############
# Switches #
############
set_false_path -hold -from [get_ports {boot_mode*  test_mode_i}]


############
# RESET #
############

set_false_path -from [get_ports cpu_reset]