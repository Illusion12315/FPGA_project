#set_property -dict {PACKAGE_PIN AU26 IOSTANDARD LVCMOS18} [get_ports clk_40m]
#create_clock -period 25.000 -name clk_40m -waveform {0.000 12.500} [get_ports clk_40m]

create_clock -period 10.000 -name clk_in_p -waveform {0.000 5.000} [get_ports clk_in_p]
create_clock -period 10.000 -name adc_dco_a -waveform {0.000 5.000} [get_ports adc_dco_a]
create_clock -period 10.000 -name adc_dco_b -waveform {0.000 5.000} [get_ports adc_dco_b]
create_clock -period 10.000 -name VIRTUAL_clk_out1_CLK_144MTO100M -waveform {0.000 5.000}

# adc_interface
set_property -dict {PACKAGE_PIN G32 IOSTANDARD LVCMOS18} [get_ports adc_or_a]
set_property -dict {PACKAGE_PIN C39 IOSTANDARD LVCMOS18} [get_ports adc_or_b]


# DAC5662
set_property -dict {PACKAGE_PIN Y30 IOSTANDARD LVCMOS18} [get_ports dac_clk_a]
set_property -dict {PACKAGE_PIN M33 IOSTANDARD LVCMOS18} [get_ports dac_clk_b]
set_property -dict {PACKAGE_PIN V30 IOSTANDARD LVCMOS18} [get_ports dac_wrta]
set_property -dict {PACKAGE_PIN L35 IOSTANDARD LVCMOS18} [get_ports dac_wrtb]

set_property -dict {PACKAGE_PIN T29 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[0]}]
set_property -dict {PACKAGE_PIN R29 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[1]}]
set_property -dict {PACKAGE_PIN T30 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[2]}]
set_property -dict {PACKAGE_PIN P30 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[3]}]
set_property -dict {PACKAGE_PIN L30 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[4]}]
set_property -dict {PACKAGE_PIN N30 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[5]}]
set_property -dict {PACKAGE_PIN N31 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[6]}]
set_property -dict {PACKAGE_PIN M31 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[7]}]
set_property -dict {PACKAGE_PIN L31 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[8]}]
set_property -dict {PACKAGE_PIN L32 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[9]}]
set_property -dict {PACKAGE_PIN M32 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[10]}]
set_property -dict {PACKAGE_PIN M34 IOSTANDARD LVCMOS18} [get_ports {dac_dat_i[11]}]

set_property -dict {PACKAGE_PIN L34 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[0]}]
set_property -dict {PACKAGE_PIN K35 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[1]}]
set_property -dict {PACKAGE_PIN J35 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[2]}]
set_property -dict {PACKAGE_PIN K33 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[3]}]
set_property -dict {PACKAGE_PIN H35 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[4]}]
set_property -dict {PACKAGE_PIN K34 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[5]}]
set_property -dict {PACKAGE_PIN H34 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[6]}]
set_property -dict {PACKAGE_PIN K32 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[7]}]
set_property -dict {PACKAGE_PIN J32 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[8]}]
set_property -dict {PACKAGE_PIN J33 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[9]}]
set_property -dict {PACKAGE_PIN H31 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[10]}]
set_property -dict {PACKAGE_PIN J31 IOSTANDARD LVCMOS18} [get_ports {dac_dat_q[11]}]

set_property -dict {PACKAGE_PIN F32 IOSTANDARD LVCMOS18} [get_ports adc_dco_a]
set_property -dict {PACKAGE_PIN C33 IOSTANDARD LVCMOS18} [get_ports adc_dco_b]
set_property -dict {PACKAGE_PIN C38 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[13]}]
set_property -dict {PACKAGE_PIN C36 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[12]}]
set_property -dict {PACKAGE_PIN D38 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[11]}]
set_property -dict {PACKAGE_PIN D36 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[10]}]
set_property -dict {PACKAGE_PIN D37 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[9]}]
set_property -dict {PACKAGE_PIN C35 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[8]}]
set_property -dict {PACKAGE_PIN F37 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[7]}]
set_property -dict {PACKAGE_PIN D35 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[6]}]
set_property -dict {PACKAGE_PIN F36 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[5]}]
set_property -dict {PACKAGE_PIN E35 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[4]}]
set_property -dict {PACKAGE_PIN E34 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[3]}]
set_property -dict {PACKAGE_PIN C34 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[2]}]
set_property -dict {PACKAGE_PIN D33 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[1]}]
set_property -dict {PACKAGE_PIN E33 IOSTANDARD LVCMOS18} [get_ports {adc_d_a[0]}]

set_property -dict {PACKAGE_PIN D32 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[13]}]
set_property -dict {PACKAGE_PIN B32 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[12]}]
set_property -dict {PACKAGE_PIN B33 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[11]}]
set_property -dict {PACKAGE_PIN A34 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[10]}]
set_property -dict {PACKAGE_PIN E32 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[9]}]
set_property -dict {PACKAGE_PIN A35 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[8]}]
set_property -dict {PACKAGE_PIN B34 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[7]}]
set_property -dict {PACKAGE_PIN A36 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[6]}]
set_property -dict {PACKAGE_PIN B36 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[5]}]
set_property -dict {PACKAGE_PIN A37 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[4]}]
set_property -dict {PACKAGE_PIN B37 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[3]}]
set_property -dict {PACKAGE_PIN B38 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[2]}]
set_property -dict {PACKAGE_PIN A39 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[1]}]
set_property -dict {PACKAGE_PIN B39 IOSTANDARD LVCMOS18} [get_ports {adc_d_b[0]}]
set_property -dict {PACKAGE_PIN G32 IOSTANDARD LVCMOS18} [get_ports adc_or_a]
set_property -dict {PACKAGE_PIN C39 IOSTANDARD LVCMOS18} [get_ports adc_or_b]


set_property IOSTANDARD LVDS [get_ports clk_in_p]
set_property IOSTANDARD LVDS [get_ports {dat_in_p[3]}]
set_property IOSTANDARD LVDS [get_ports {dat_in_p[2]}]
set_property IOSTANDARD LVDS [get_ports {dat_in_p[1]}]
set_property IOSTANDARD LVDS [get_ports {dat_in_p[0]}]

set_property IOSTANDARD LVDS [get_ports clk_to_pins_p]
set_property IOSTANDARD LVDS [get_ports {dat_out_p[0]}]
set_property IOSTANDARD LVDS [get_ports {dat_out_p[1]}]
set_property IOSTANDARD LVDS [get_ports {dat_out_p[2]}]
set_property IOSTANDARD LVDS [get_ports {dat_out_p[3]}]

set_property PACKAGE_PIN AD36 [get_ports {dat_in_p[0]}]
set_property PACKAGE_PIN Y35 [get_ports {dat_in_p[1]}]
set_property PACKAGE_PIN Y37 [get_ports {dat_in_p[2]}]
set_property PACKAGE_PIN AC35 [get_ports {dat_in_p[3]}]
set_property PACKAGE_PIN AE37 [get_ports clk_in_p]



set_property PACKAGE_PIN AG36 [get_ports {dat_out_p[0]}]
set_property PACKAGE_PIN AF31 [get_ports {dat_out_p[1]}]
set_property PACKAGE_PIN AE34 [get_ports {dat_out_p[2]}]
set_property PACKAGE_PIN AF35 [get_ports {dat_out_p[3]}]
set_property PACKAGE_PIN AF34 [get_ports clk_to_pins_p]

set_property  -dict {PACKAGE_PIN AK42	 IOSTANDARD LVCMOS18}  [get_ports BCTRL_RX_CLK]
set_property  -dict {PACKAGE_PIN AH39	 IOSTANDARD LVCMOS18}  [get_ports BCTRL_RX_DATA]
set_property  -dict {PACKAGE_PIN AJ38	 IOSTANDARD LVCMOS18}  [get_ports BCTRL_RX_EN]

set_property  -dict {PACKAGE_PIN AJ42	 IOSTANDARD LVCMOS18}  [get_ports BCTRL_TX_CLK]
set_property  -dict {PACKAGE_PIN AG41	 IOSTANDARD LVCMOS18}  [get_ports BCTRL_TX_DATA]
set_property  -dict {PACKAGE_PIN AF41	 IOSTANDARD LVCMOS18}  [get_ports BCTRL_TX_EN]

# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets BCTRL_RX_CLK_IBUF]


set_output_delay -clock [get_clocks VIRTUAL_clk_out1_CLK_144MTO100M] -min -add_delay -2.000 [get_ports {dat_out_p[*]}]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_CLK_144MTO100M] -max -add_delay 2.000 [get_ports {dat_out_p[*]}]


set_output_delay -clock [get_clocks VIRTUAL_clk_out1_CLK_144MTO100M] -max -add_delay 2.000 [get_ports dat_vld_o]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_CLK_144MTO100M] -min -add_delay -2.000 [get_ports dat_vld_o]

set_input_delay -clock [get_clocks clk_in_p] -min -add_delay 3.000 [get_ports {dat_in_p[*]}]
set_input_delay -clock [get_clocks clk_in_p] -max -add_delay 4.000 [get_ports {dat_in_p[*]}]

set_input_delay -clock [get_clocks clk_in_p] -min -add_delay 3.000 [get_ports dat_vld_in]
set_input_delay -clock [get_clocks clk_in_p] -max -add_delay 4.000 [get_ports dat_vld_in]

set_property PACKAGE_PIN BB38 [get_ports dat_vld_in]
set_property PACKAGE_PIN AU41 [get_ports dat_vld_o]
set_property IOSTANDARD LVCMOS18 [get_ports dat_vld_in]
set_property IOSTANDARD LVCMOS18 [get_ports dat_vld_o]



#######################################################
#mod_clk
set_property IOSTANDARD LVDS [get_ports clk_100_p]
set_property IOSTANDARD LVDS [get_ports clk_100_n]

set_property PACKAGE_PIN AU38 [get_ports clk_100_p]
#set_property PACKAGE_PIN AV38 [get_ports clk_100_n]

#set_property PACKAGE_PIN H33 [get_ports clk_100_p]

###-------------hp spi
set_property PACKAGE_PIN AJ41 [get_ports sclk_spi_hp]
set_property PACKAGE_PIN AG42 [get_ports cs_spi_hp]
set_property PACKAGE_PIN AH38 [get_ports sdo_spi_hp]

set_property IOSTANDARD LVCMOS18 [get_ports sclk_spi_hp]
set_property IOSTANDARD LVCMOS18 [get_ports cs_spi_hp]
set_property IOSTANDARD LVCMOS18 [get_ports sdo_spi_hp]

#connect_debug_port dbg_hub/clk [get_nets adc_clk100m]

#connect_debug_port dbg_hub/clk [get_nets adc_clk100m]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets u_kq_mod_demod_top/CoRefClk_inst/adc_clk_a]

#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_rst_wrapper_inst/U_clk_100Mto144M/inst/clk_in1_clk_100Mto144M]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets u_kq_mod_demod_top/CoRefClk_inst/adc_clk_Q] 


set_false_path -from [get_pins u_kq_mod_demod_top/rst_n_rr_reg/C] -to [get_pins u_kq_mod_demod_top/kq_hp_module_inst/hp_rstn_r_reg/D]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
