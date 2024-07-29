###########################################################################
## FLASH SPIx4
###########################################################################
set_property CONFIG_MODE SPIx8 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]


create_pblock SLR1
add_cells_to_pblock [get_pblocks SLR1] [get_cells -quiet [list clk_rst_wrapper_inst/hw_arst_n_slr1_reg sw_srst_n_slr1_reg sw_srst_n_slr1_reg_replica sw_srst_n_slr1_reg_replica_1 sw_srst_n_slr1_reg_replica_10 sw_srst_n_slr1_reg_replica_11 sw_srst_n_slr1_reg_replica_12 sw_srst_n_slr1_reg_replica_13 sw_srst_n_slr1_reg_replica_14 sw_srst_n_slr1_reg_replica_15 sw_srst_n_slr1_reg_replica_16 sw_srst_n_slr1_reg_replica_17 sw_srst_n_slr1_reg_replica_18 sw_srst_n_slr1_reg_replica_19 sw_srst_n_slr1_reg_replica_2 sw_srst_n_slr1_reg_replica_20 sw_srst_n_slr1_reg_replica_21 sw_srst_n_slr1_reg_replica_22 sw_srst_n_slr1_reg_replica_23 sw_srst_n_slr1_reg_replica_24 sw_srst_n_slr1_reg_replica_25 sw_srst_n_slr1_reg_replica_26 sw_srst_n_slr1_reg_replica_27 sw_srst_n_slr1_reg_replica_28 sw_srst_n_slr1_reg_replica_29 sw_srst_n_slr1_reg_replica_3 sw_srst_n_slr1_reg_replica_30 sw_srst_n_slr1_reg_replica_31 sw_srst_n_slr1_reg_replica_32 sw_srst_n_slr1_reg_replica_33 sw_srst_n_slr1_reg_replica_34 sw_srst_n_slr1_reg_replica_35 sw_srst_n_slr1_reg_replica_36 sw_srst_n_slr1_reg_replica_37 sw_srst_n_slr1_reg_replica_38 sw_srst_n_slr1_reg_replica_39 sw_srst_n_slr1_reg_replica_4 sw_srst_n_slr1_reg_replica_40 sw_srst_n_slr1_reg_replica_41 sw_srst_n_slr1_reg_replica_42 sw_srst_n_slr1_reg_replica_43 sw_srst_n_slr1_reg_replica_44 sw_srst_n_slr1_reg_replica_45 sw_srst_n_slr1_reg_replica_46 sw_srst_n_slr1_reg_replica_47 sw_srst_n_slr1_reg_replica_48 sw_srst_n_slr1_reg_replica_49 sw_srst_n_slr1_reg_replica_5 sw_srst_n_slr1_reg_replica_50 sw_srst_n_slr1_reg_replica_51 sw_srst_n_slr1_reg_replica_52 sw_srst_n_slr1_reg_replica_53 sw_srst_n_slr1_reg_replica_54 sw_srst_n_slr1_reg_replica_55 sw_srst_n_slr1_reg_replica_56 sw_srst_n_slr1_reg_replica_57 sw_srst_n_slr1_reg_replica_58 sw_srst_n_slr1_reg_replica_59 sw_srst_n_slr1_reg_replica_6 sw_srst_n_slr1_reg_replica_60 sw_srst_n_slr1_reg_replica_61 sw_srst_n_slr1_reg_replica_62 sw_srst_n_slr1_reg_replica_63 sw_srst_n_slr1_reg_replica_64 sw_srst_n_slr1_reg_replica_65 sw_srst_n_slr1_reg_replica_66 sw_srst_n_slr1_reg_replica_67 sw_srst_n_slr1_reg_replica_68 sw_srst_n_slr1_reg_replica_69 sw_srst_n_slr1_reg_replica_7 sw_srst_n_slr1_reg_replica_70 sw_srst_n_slr1_reg_replica_71 sw_srst_n_slr1_reg_replica_72 sw_srst_n_slr1_reg_replica_73 sw_srst_n_slr1_reg_replica_74 sw_srst_n_slr1_reg_replica_75 sw_srst_n_slr1_reg_replica_76 sw_srst_n_slr1_reg_replica_77 sw_srst_n_slr1_reg_replica_78 sw_srst_n_slr1_reg_replica_79 sw_srst_n_slr1_reg_replica_8 sw_srst_n_slr1_reg_replica_80 sw_srst_n_slr1_reg_replica_81 sw_srst_n_slr1_reg_replica_9 {u_srio_app_1x/genblk2.gen_srio_1x[10].u_srio_1x/u_srio_ip} {u_srio_app_1x/genblk2.gen_srio_1x[11].u_srio_1x/u_srio_ip} {u_srio_app_1x/genblk2.gen_srio_1x[9].u_srio_1x/u_srio_ip} {u_srio_app_4x/genblk1.gen_srio_4x[5].u_srio_4x/u_srio_ip} {u_srio_app_4x/genblk1.gen_srio_4x[6].u_srio_4x/u_srio_ip}]]
resize_pblock [get_pblocks SLR1] -add {CLOCKREGION_X0Y5:CLOCKREGION_X5Y9}
create_pblock SLR0
add_cells_to_pblock [get_pblocks SLR0] [get_cells -quiet [list clk_rst_wrapper_inst/hw_arst_n_slr0_reg sw_srst_n_slr0_reg]]
resize_pblock [get_pblocks SLR0] -add {CLOCKREGION_X0Y0:CLOCKREGION_X5Y4}



set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets global_clk100m]
