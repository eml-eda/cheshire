# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
# Description: Program Genesys II

set current_directory [file normalize [pwd]]
puts $current_directory


open_hw_manager

connect_hw_server -url $::env(HOST):$::env(PORT)

if {$::env(BOARD) eq "genesys2"} {
  open_hw_target $::env(HOST):$::env(PORT)/$::env(FPGA_PATH)

  current_hw_device [get_hw_devices xc7k325t_0]
  set_property PROGRAM.FILE $::env(BIT) [get_hw_devices xc7k325t_0]
  program_hw_devices [get_hw_devices xc7k325t_0]
  refresh_hw_device [lindex [get_hw_devices xc7k325t_0] 0]
  disconnect_hw_server
} elseif {$::env(BOARD) eq "vc707"} {
  open_hw_target {$::env(HOST):$::env(PORT)/$::env(FPGA_PATH)}
  puts $::env{FPGA_PATH}

  current_hw_device [get_hw_devices xc7vx485t_0]
  set_property PROGRAM.FILE $::env(BIT) [get_hw_devices xc7vx485t_0]
  program_hw_devices [get_hw_devices xc7vx485t_0]
  refresh_hw_device [lindex [get_hw_devices xc7vx485t_0] 0]
  disconnect_hw_server
} elseif {$::env(BOARD) eq "zcu102"} {
  current_hw_target [lindex [get_hw_targets] 0]
  open_hw_target
  set_property PROGRAM.FILE $::env(BIT) [lindex [get_hw_devices xczu9_0] 0]
  set_property PROBES.FILE ${current_directory}/out/cheshire_top_xilinx_wrapper.ltx [get_hw_devices xczu9_0]
  set_property FULL_PROBES.FILE ${current_directory}/out/cheshire_top_xilinx_wrapper.ltx [get_hw_devices xczu9_0]
  current_hw_device [lindex [get_hw_devices xczu9_0] 0]
  program_hw_devices [get_hw_devices xczu9_0]
  refresh_hw_device [lindex [get_hw_devices xczu9_0] 0]
  puts "The FPGA was properly programmed"
  disconnect_hw_server
  

} else {
      exit 1
      puts "The FPGA was not properly programmed"
}
