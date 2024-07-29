###########################################################################
## FLASH SPIx4
###########################################################################
set_property CONFIG_MODE SPIx8 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

###########################################################################
## pblock
###########################################################################
create_pblock SLR1
add_cells_to_pblock [get_pblocks SLR1] \
[get_cells -quiet [list clk_rst_wrapper_inst/hw_arst_n_slr1_reg \
                        sw_srst_n_slr1_reg \
                        {u_srio_app_1x/genblk2.gen_srio_1x[0].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[1].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[2].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[3].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[4].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[5].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[6].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[7].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[8].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[9].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[10].u_srio_1x/u_srio_ip} \
                        {u_srio_app_1x/genblk2.gen_srio_1x[11].u_srio_1x/u_srio_ip} \
                        {u_srio_app_4x/genblk1.gen_srio_4x[5].u_srio_4x/u_srio_ip} \
                        {u_srio_app_4x/genblk1.gen_srio_4x[6].u_srio_4x/u_srio_ip}]]
resize_pblock [get_pblocks SLR1] -add {CLOCKREGION_X0Y5:CLOCKREGION_X5Y9}

create_pblock SLR0
add_cells_to_pblock [get_pblocks SLR0] \
[get_cells -quiet [list clk_rst_wrapper_inst/hw_arst_n_slr0_reg \
                        sw_srst_n_slr0_reg \
                        {u_srio_app_4x/genblk1.gen_srio_4x[0].u_srio_4x/u_srio_ip} \
                        {u_srio_app_4x/genblk1.gen_srio_4x[1].u_srio_4x/u_srio_ip} \
                        {u_srio_app_4x/genblk1.gen_srio_4x[2].u_srio_4x/u_srio_ip} \
                        {u_srio_app_4x/genblk1.gen_srio_4x[3].u_srio_4x/u_srio_ip} \
                        {u_srio_app_4x/genblk1.gen_srio_4x[4].u_srio_4x/u_srio_ip} \
                        {u_srio_app_4x/genblk1.gen_srio_4x[7].u_srio_4x/u_srio_ip}]]
resize_pblock [get_pblocks SLR0] -add {CLOCKREGION_X0Y0:CLOCKREGION_X5Y4}




###########################################################################
## jtag
###########################################################################
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets global_clk100m]
