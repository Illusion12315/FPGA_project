###########################################################################
## system clock
###########################################################################
set_property PACKAGE_PIN U26 [get_ports SYSCLK]
set_property IOSTANDARD LVCMOS33 [get_ports SYSCLK]
create_clock -period 10.000 -name SYSCLK -waveform {0.000 5.000} [get_ports SYSCLK]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks SYSCLK]

set_property PACKAGE_PIN R25 [get_ports SYSCLK_Z7_PL]
set_property IOSTANDARD LVCMOS33 [get_ports SYSCLK_Z7_PL]
create_clock -period 10.000 -name SYSCLK_Z7_PL -waveform {0.000 5.000} [get_ports SYSCLK_Z7_PL]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks SYSCLK_Z7_PL]
###########################################################################
## DDR3
###########################################################################
set_property PACKAGE_PIN D9 [get_ports Z7_PL_DDR3_CLK_P]
set_property PACKAGE_PIN D8 [get_ports Z7_PL_DDR3_CLK_N]
set_property IOSTANDARD DIFF_SSTL15 [get_ports Z7_PL_DDR3_CLK_P]
create_clock -period 5.000 -name Z7_PL_DDR3_CLK_P -waveform {0.000 2.500} [get_ports Z7_PL_DDR3_CLK_P]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks Z7_PL_DDR3_CLK_P]
###########################################################################
## SRIO
###########################################################################
set_property PACKAGE_PIN U8 [get_ports SRIO_REFCLK13_P]
set_property PACKAGE_PIN U7 [get_ports SRIO_REFCLK13_N]
###########################################################################
## pcie
###########################################################################
set_property PACKAGE_PIN T27 [get_ports RESET_N_3V3]
set_property IOSTANDARD LVCMOS33 [get_ports RESET_N_3V3]
###########################################################################
## ad9516
###########################################################################
# ad9516 1
set_property PACKAGE_PIN P30 [get_ports AD9516_1_RESET_B]
set_property PACKAGE_PIN R30 [get_ports AD9516_1_PD_B]
set_property PACKAGE_PIN U30 [get_ports AD9516_1_SCLK]
set_property PACKAGE_PIN N28 [get_ports AD9516_1_SDIO]
set_property PACKAGE_PIN P28 [get_ports AD9516_1_SDO]
set_property PACKAGE_PIN N29 [get_ports AD9516_1_CS]
set_property PACKAGE_PIN P29 [get_ports AD9516_1_STATUS]
set_property PACKAGE_PIN T29 [get_ports AD9516_1_REFSEL]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_1_RESET_B]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_1_PD_B]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_1_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_1_SDIO]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_1_SDO]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_1_CS]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_1_STATUS]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_1_REFSEL]
# ad9516 2
set_property PACKAGE_PIN V29 [get_ports AD9516_2_RESET_B]
set_property PACKAGE_PIN W29 [get_ports AD9516_2_PD_B]
set_property PACKAGE_PIN W30 [get_ports AD9516_2_SCLK]
set_property PACKAGE_PIN V27 [get_ports AD9516_2_SDIO]
set_property PACKAGE_PIN W28 [get_ports AD9516_2_SDO]
set_property PACKAGE_PIN W25 [get_ports AD9516_2_CS]
set_property PACKAGE_PIN W26 [get_ports AD9516_2_STATUS]
set_property PACKAGE_PIN U25 [get_ports AD9516_2_REFSEL]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_2_RESET_B]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_2_PD_B]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_2_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_2_SDIO]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_2_SDO]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_2_CS]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_2_STATUS]
set_property IOSTANDARD LVCMOS33 [get_ports AD9516_2_REFSEL]
###########################################################################
## GPIO
###########################################################################
# z7 to d-card
set_property PACKAGE_PIN AH18 [get_ports Z7_PL_GPIO0]
set_property PACKAGE_PIN AJ18 [get_ports Z7_PL_GPIO1]
set_property PACKAGE_PIN AJ14 [get_ports Z7_PL_GPIO2]
set_property PACKAGE_PIN AJ13 [get_ports Z7_PL_GPIO3]
set_property PACKAGE_PIN AJ16 [get_ports Z7_PL_GPIO4]
set_property PACKAGE_PIN AK16 [get_ports Z7_PL_GPIO5]
set_property PACKAGE_PIN AJ15 [get_ports Z7_PL_GPIO6]
set_property PACKAGE_PIN AK15 [get_ports Z7_PL_GPIO7]
set_property PACKAGE_PIN AH17 [get_ports Z7_PL_GPIO8]
set_property PACKAGE_PIN AH16 [get_ports Z7_PL_GPIO9]
set_property PACKAGE_PIN AE12 [get_ports Z7_PL_GPIO10]
set_property PACKAGE_PIN AF12 [get_ports Z7_PL_GPIO11]
set_property PACKAGE_PIN AH14 [get_ports Z7_PL_GPIO12]
set_property PACKAGE_PIN AH13 [get_ports Z7_PL_GPIO13]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO0]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO1]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO2]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO3]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO4]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO5]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO6]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO7]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO8]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO9]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO10]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO11]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO12]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_PL_GPIO13]
# z7 to ku115
set_property PACKAGE_PIN T25 [get_ports Z7_KU115_GPIO1]
set_property PACKAGE_PIN P23 [get_ports Z7_KU115_GPIO2]
set_property PACKAGE_PIN P24 [get_ports Z7_KU115_GPIO3]
set_property PACKAGE_PIN P21 [get_ports Z7_KU115_GPIO4]
set_property PACKAGE_PIN R21 [get_ports Z7_KU115_GPIO5]
set_property PACKAGE_PIN T22 [get_ports Z7_KU115_GPIO6]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_KU115_GPIO1]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_KU115_GPIO2]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_KU115_GPIO3]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_KU115_GPIO4]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_KU115_GPIO5]
set_property IOSTANDARD LVCMOS33 [get_ports Z7_KU115_GPIO6]
