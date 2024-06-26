# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
set current_script [info script]
set current_directory [file dirname $current_script]


# Ips selection
switch $::env(BOARD) {
      "genesys2" - "kc705" - "vc707" {
            set ips { "xilinx/xlnx_mig_7_ddr3/xlnx_mig_7_ddr3.srcs/sources_1/ip/xlnx_mig_7_ddr3/xlnx_mig_7_ddr3.xci" \
                  "xilinx/xlnx_clk_wiz/xlnx_clk_wiz.srcs/sources_1/ip/xlnx_clk_wiz/xlnx_clk_wiz.xci" \
                        "xilinx/xlnx_vio/xlnx_vio.srcs/sources_1/ip/xlnx_vio/xlnx_vio.xci" }
            }
      "vcu128" {
            set ips { "xilinx/xlnx_clk_wiz/xlnx_clk_wiz.srcs/sources_1/ip/xlnx_clk_wiz/xlnx_clk_wiz.xci" \
                  "xilinx/xlnx_vio/xlnx_vio.srcs/sources_1/ip/xlnx_vio/xlnx_vio.xci" }
            }
      "zcu102" {
            set ips { "ips/ILA/ila_0.srcs/sources_1/ip/ila_0/ila_0.xci"
            }
      }
      "zcu104" - "pynq-z1" {
            set ips {
                  "xilinx/xlnx_mig_ddr4/xlnx_mig_ddr4.srcs/sources_1/ip/xlnx_mig_ddr4/xlnx_mig_ddr4.xci"
            }
      }
      default {
            set ips {}
      }
}

read_ip $ips

source $current_directory/add_sources.tcl

set_property top cheshire_top_xilinx_wrapper [current_fileset]

update_compile_order -fileset sources_1

add_files -fileset constrs_1 -norecurse $current_directory/../constraints/$project.xdc
add_files -fileset constrs_1 -norecurse $current_directory/../constraints/cheshire.xdc


set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]

set_property XPM_LIBRARIES XPM_MEMORY [current_project]

set_param general.maxThreads 16

synth_design -rtl -name rtl_1

set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]

launch_runs synth_1
wait_on_run synth_1

add_files -fileset constrs_1 -norecurse $current_directory/../constraints/imp_constraints.xdc
update_compile_order -fileset sources_1

open_run synth_1 -name synth_1

# Get all nets of the design
set all_nets [get_nets -hierarchical]
 

# Initialize an empty list to store nets marked for debugging
set nets_to_set {}

# Loop through each net and check if it's marked for debugging
foreach net $all_nets {
    if {[get_property MARK_DEBUG $net] == 1} {
        lappend nets_to_set $net
    }
}

puts $nets_to_set




#Know the number of the nets to add
set length [llength $nets_to_set]

# Print the list of nets marked for debug
if {$length > 0} {
      #The name of the core is "ila". We are using the ip "ila_0"
      create_debug_core ila_0 ila
      puts "The signals marked for debug are:"
      for {set index 0} {$index <= $length - 1} {incr index} {

            set new_net [ get_nets [ lindex $nets_to_set $index ] ]
            set probe "probe$index"
            
            puts $new_net

            if {$index != 0} {
                  create_debug_port [get_debug_cores ila_0] probe  
            }

            connect_debug_port [get_debug_cores ila_0]/$probe [ get_nets $new_net]
      }     
      #Connect the debug core to the clock
      connect_debug_port [get_debug_cores ila_0]/clk [ get_nets cheshire_top_xilinx_instance/soc_clk ]

} else {

    puts "No nets marked for debug."
}


exec mkdir -p reports/
exec rm -rf reports/*

check_timing -verbose                                                   -file reports/$project.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack -file reports/$project.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                  -file reports/$project.timing.rpt
report_utilization -hierarchical                                        -file reports/$project.utilization.rpt
report_cdc                                                              -file reports/$project.cdc.rpt
report_clock_interaction                                                -file reports/$project.clock_interaction.rpt




set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
launch_runs impl_1
wait_on_run impl_1

launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1

#Check timing constraints
open_run impl_1
set timingrep [report_timing_summary -no_header -no_detailed_paths -return_string]
if {[info exists ::env(CHECK_TIMING)] && $::env(CHECK_TIMING)==1} {
      if {! [string match -nocase {*timing constraints are met*} $timingrep]} {
            send_msg_id {USER 1-1} ERROR {Timing constraints were not met.}
            return -code error
      }
}

# # output Verilog netlist + SDC for timing simulation
# write_verilog -force -mode funcsim out/${project}_funcsim.v
# write_verilog -force -mode timesim out/${project}_timesim.v
# write_sdf     -force out/${project}_timesim.sdf

# reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing                                                              -file reports/${project}.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack   -file reports/${project}.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                    -file reports/${project}.timing.rpt
report_utilization -hierarchical                                          -file reports/${project}.utilization.rpt
