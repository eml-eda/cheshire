# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>

set current_directory [file normalize [pwd]]
set project $::env(PROJECT)

create_project $project $current_directory -force -part $::env(XILINX_PART)
set_property board_part $::env(XILINX_BOARD) [current_project]

# set number of threads to 16 (maximum, unfortunately)
set_param general.maxThreads 16

#set_msg_config -id {[Synth 8-5858]} -new_severity "info"

#set_msg_config -id {[Synth 8-4480]} -limit 1000