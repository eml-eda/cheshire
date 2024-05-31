//Wrapper of the system --All these signals appear in the constraints file
`include "phy_definitions.svh"
module cheshire_top_xilinx_wrapper (
    //System signals
    input logic         sysclk_p,
    input logic         sysclk_n,
    input logic         cpu_reset,
    input logic [1:0]   boot_mode_i,
    input logic         test_mode_i,
    //JTAG
    input logic         jtag_tck_i,
    input logic         jtag_trst_i,
    input logic         jtag_tms_i,
    input logic         jtag_tdi_i,
    output logic        jtag_tdo_o,
    //UART
    output logic        uart_tx_o,
    input logic         uart_rx_i,
    //I2C
    inout wire          i2c_scl_io,
    inout wire          i2c_sda_io,
    //GPIO 
    inout wire  [28:0]  gpio_io
    //SD
    //input logic         sd_cd_i,
    //output logic        sd_cmd_o,
    //inout wire  [3:0]   sd_d_io,
    //output logic        sd_reset_o,
    //output logic        sd_sclk_o
  );

  cheshire_top_xilinx cheshire_top_xilinx_instance (
    `ifdef USE_SWITCHES
    .test_mode_i(test_mode_i),
    .boot_mode_i(boot_mode_i),
    `endif

    .uart_tx_o(uart_tx_o),
    .uart_rx_i(uart_rx_i),

    `ifdef USE_JTAG
    .jtag_tck_i(jtag_tck_i),
    .jtag_trst_i(jtag_trst_i),
    .jtag_tms_i(jtag_tms_i),
    .jtag_tdi_i(jtag_tdi_i),
    .jtag_tdo_o(jtag_tdo_o),
    `endif

    `ifdef USE_I2C
    .i2c_scl_io(i2c_scl_io),
    .i2c_sda_io(i2c_sda_io),
    `endif

    `ifdef USE_GPIO
    .gpio_io(gpio_io),
    `endif

    `ifdef USE_SD
    .sd_cd_i(),
    .sd_cmd_o(),
    .sd_d_io(),
    .sd_reset_o(),
    .sd_sclk_o(),
    `endif

    `ifdef USE_FAN
    //We leave this part in tri-state
    .fan_sw(),
    .fan_pwm(),
    `endif

    `ifdef USE_VGA
    //We leave the VGA part in tri-state too
    .vga_b(),
    .vga_g(),
    .vga_r(),
    .vga_hs(),
    .vga_vs(),
    `endif

    .sysclk_p(sysclk_p),
    .sysclk_n(sysclk_n),
    .cpu_reset(cpu_reset)
  );

endmodule
