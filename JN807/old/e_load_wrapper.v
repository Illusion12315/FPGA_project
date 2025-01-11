//////////////////////////////////////////////////////////////////////////////////
// Company              : Wuhan Jingneng Electronics Co., LTD
// Engineer             : Wangyanqing
//                        Senior Engineer
// Create Date          : 8:23 2024/9/9
// Module Name          : e_load_ctrl
// Description          : 电子负载
// ---- CV/CC/CP/CR
// ---- Static/Dynamic/Short/
// Additional Comments  : 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module e_load_ctrl #
(
    parameter                       SIMULATION         = 1     ,
    parameter                       S_SR_LIMIT         = 10    ,// A/us max 16.7 A/us
    parameter                       BUILD_REV_0        = 8'd51 ,
    parameter                       BUILD_REV_1        = 8'd01 ,
    parameter                       BUILD_REV_2        = 8'd01 ,
    parameter                       BUILD_REV_3        = "A"   ,
    parameter                       MASK_DATA          = 'H5A3C
)
(
//system
    input                           i_clk               ,//100M
    input                           i_rst               ,//复位
//AD7606 电流电压采集                            
    output                          o_ad7606_reset      ,
    output                          o_ad7606_cs         ,
    output                          o_ad7606_sclk       ,
    output                          o_ad7606_conv       ,
    input                           i_ad7606_busy       ,
    input              [  15: 0]    i_ad7606_miso       ,
//AD5689 DAC                                              
    output                          o_ad5689_resetn     ,
    output                          o_ad5689_ldac       ,
    output                          o_ad5689_pdl        ,
    output                          o_ad5689_sclk       ,
    output                          o_ad5689_cs         ,
    output                          o_ad5689_mosi       ,
    input                           i_ad5689_miso       ,
    output                          o_ad5689_dir        ,
//温度采集值
    input              [  31: 0]    i_ch0_temp          ,
    input              [  31: 0]    i_ch1_temp          ,
    input              [  31: 0]    i_ch2_temp          ,
    input              [  31: 0]    i_ch3_temp          ,
    input              [  31: 0]    i_ch4_temp          ,
    input              [  31: 0]    i_ch5_temp          ,
    input              [  31: 0]    i_ch6_temp          ,
    input              [  31: 0]    i_ch7_temp          ,
//单元电流值选择
    output                          o_en_sample         ,
    output             [   2: 0]    o_sel_sample        ,
//V高低档采样切换开关默认高档位
    output                          o_vmod_l_sw         ,//Vmod_H/L_SW_FPGA
    output                          o_vsense_l_sw       ,//Vsense_H/L_SW_FPGA
//CV/CC环路切换
    output                          o_vin_select        ,//Vmod_Control/Vsense_control
    output                          o_cc_cv_select      ,//CELL_PROG_DA/CV_Hardware_LOOP
    output                          o_cv_limit_select   ,//CV_Lim_DA/CV_lim_PROG
    output                          o_cv_slow           ,//互斥关系
    output                          o_cv_mid            ,//互斥关系
    output                          o_cv_fast           ,//互斥关系
//并机控制
    input                           i_mcu_alarm         ,//axi_gpio
    input                           i_mcu_syn           ,//axi_gpio
    inout                           io_trig1            ,
    inout                           io_trig2            ,
    output                          o_m_s               ,// master_slave flag 1:主机 0:从机
//并机时CV
    output                          o_p_sw1             ,//单机:P_SW1(0) P_SW2(0) 
    output                          o_p_sw2             ,//主机:P_SW1(0) P_SW2(1) 从机:P_SW1(1) P_SW2(1) 
//输出保护开关
    output                          o_sw                ,//1:正常(SW短路) 0:无输出(SW开路) // hardward lock off
//正负电源检测(延时检测)
    input                           i_vop_pos           ,//1:err 0:normal 正电压检测
    input                           i_vop_neg           ,//1:err 0:normal 负电压检测
//CV_limit/ocp_board
    input                           i_cv_limit_trig     ,//1:normal 0:err 硬件CV模式时的电流控制量PROG大于CV_limit
    input                           i_ocp_da_trig       ,//1:normal 0:err hard ocp 
// AXI Lite Slave Interface connections    
    input              [  31: 0]    s_axil_awaddr       ,
    input                           s_axil_awvalid      ,
    output                          s_axil_awready      ,
    input              [  31: 0]    s_axil_wdata        ,
    input              [   3: 0]    s_axil_wstrb        ,
    input                           s_axil_wvalid       ,
    output                          s_axil_wready       ,
    output             [   1: 0]    s_axil_bresp        ,
    output                          s_axil_bvalid       ,
    input                           s_axil_bready       ,
    input              [  31: 0]    s_axil_araddr       ,
    input                           s_axil_arvalid      ,
    output                          s_axil_arready      ,
    output             [  31: 0]    s_axil_rdata        ,
    output             [   1: 0]    s_axil_rresp        ,
    output                          s_axil_rvalid       ,
    input                           s_axil_rready        
);
    wire               [  15: 0]    w_cnt_repeat_list   ;//单步重复计数(1-65535)
    wire               [  15: 0]    w_cnt_total_loop_list  ;//总循环计数(1-1000)
    wire               [  15: 0]    w_stepnum_do        ;//执行编号,1-1000
    wire               [  15: 0]    w_cnt_loop_list     ;//小循环计数(1-65535)
//PS_PL
    wire                            w_ps2pl_txen        ;
    wire               [  31: 0]    w_ps2pl_txd         ;
    wire               [   3: 0]    w_ps2pl_txdstrb     ;
    wire                            w_ps2pl_txdone      ;
    wire                            w_ps2pl_rxen        ;
    wire               [  31: 0]    w_ps2pl_rxd         ;
    wire                            w_ps2pl_rxdone      ;
    wire                            w_ps2pl_txawen      ;
    wire               [  31: 0]    w_ps2pl_txaw        ;
    wire                            w_ps2pl_rxaren      ;
    wire               [  31: 0]    w_ps2pl_rxar        ;
//register
//ps2pl 0x0000~0x00ff
    wire               [  31: 0]    w_reg0000out        ;//0000
    wire               [  31: 0]    w_reg0001out        ;//0001
    wire               [  31: 0]    w_reg0002out        ;//0002
    wire               [  31: 0]    w_reg0003out        ;//0003
    wire               [  31: 0]    w_reg0004out        ;//0004
    wire               [  31: 0]    w_reg0005out        ;//0005
    wire               [  31: 0]    w_reg0006out        ;//0006
    wire               [  31: 0]    w_reg0007out        ;//0007
    wire               [  31: 0]    w_reg0008out        ;//0008
    wire               [  31: 0]    w_reg0009out        ;//0009
    wire               [  31: 0]    w_reg000aout        ;//000a
    wire               [  31: 0]    w_reg000bout        ;//000b
    wire               [  31: 0]    w_reg000cout        ;//000c
    wire               [  31: 0]    w_reg000dout        ;//000d
    wire               [  31: 0]    w_reg000eout        ;//000e
    wire               [  31: 0]    w_reg000fout        ;//000f
    wire               [  31: 0]    w_reg0010out        ;//0010
    wire               [  31: 0]    w_reg0011out        ;//0011
    wire               [  31: 0]    w_reg0012out        ;//0012
    wire               [  31: 0]    w_reg0013out        ;//0013
    wire               [  31: 0]    w_reg0014out        ;//0014
    wire               [  31: 0]    w_reg0015out        ;//0015
    wire               [  31: 0]    w_reg0016out        ;//0016
    wire               [  31: 0]    w_reg0017out        ;//0017
    wire               [  31: 0]    w_reg0018out        ;//0018
    wire               [  31: 0]    w_reg0019out        ;//0019
    wire               [  31: 0]    w_reg001aout        ;//001a
    wire               [  31: 0]    w_reg001bout        ;//001b
    wire               [  31: 0]    w_reg001cout        ;//001c
    wire               [  31: 0]    w_reg001dout        ;//001d
    wire               [  31: 0]    w_reg001eout        ;//001e
    wire               [  31: 0]    w_reg001fout        ;//001f
    wire               [  31: 0]    w_reg0020out        ;//0020
    wire               [  31: 0]    w_reg0021out        ;//0021
    wire               [  31: 0]    w_reg0022out        ;//0022
    wire               [  31: 0]    w_reg0023out        ;//0023
    wire               [  31: 0]    w_reg0024out        ;//0024
    wire               [  31: 0]    w_reg0025out        ;//0025
    wire               [  31: 0]    w_reg0026out        ;//0026
    wire               [  31: 0]    w_reg0027out        ;//0027
    wire               [  31: 0]    w_reg0028out        ;//0028
    wire               [  31: 0]    w_reg0029out        ;//0029
    wire               [  31: 0]    w_reg002aout        ;//002a
    wire               [  31: 0]    w_reg002bout        ;//002b
    wire               [  31: 0]    w_reg002cout        ;//002c
    wire               [  31: 0]    w_reg002dout        ;//002d
    wire               [  31: 0]    w_reg002eout        ;//002e
    wire               [  31: 0]    w_reg002fout        ;//002f
    wire               [  31: 0]    w_reg0030out        ;//0030
    wire               [  31: 0]    w_reg0031out        ;//0031
    wire               [  31: 0]    w_reg0032out        ;//0032
    wire               [  31: 0]    w_reg0033out        ;//0033
    wire               [  31: 0]    w_reg0034out        ;//0034
    wire               [  31: 0]    w_reg0035out        ;//0035
    wire               [  31: 0]    w_reg0036out        ;//0036
    wire               [  31: 0]    w_reg0037out        ;//0037
    wire               [  31: 0]    w_reg0038out        ;//0038
    wire               [  31: 0]    w_reg0039out        ;//0039
    wire               [  31: 0]    w_reg003aout        ;//003a
    wire               [  31: 0]    w_reg003bout        ;//003b
    wire               [  31: 0]    w_reg003cout        ;//003c
    wire               [  31: 0]    w_reg003dout        ;//003d
    wire               [  31: 0]    w_reg003eout        ;//003e
    wire               [  31: 0]    w_reg003fout        ;//003f
    wire               [  31: 0]    w_reg0040out        ;//0040
    wire               [  31: 0]    w_reg0041out        ;//0041
    wire               [  31: 0]    w_reg0042out        ;//0042
    wire               [  31: 0]    w_reg0043out        ;//0043
    wire               [  31: 0]    w_reg0044out        ;//0044
    wire               [  31: 0]    w_reg0045out        ;//0045
    wire               [  31: 0]    w_reg0046out        ;//0046
    wire               [  31: 0]    w_reg0047out        ;//0047
    wire               [  31: 0]    w_reg0048out        ;//0048
    wire               [  31: 0]    w_reg0049out        ;//0049
    wire               [  31: 0]    w_reg004aout        ;//004a
    wire               [  31: 0]    w_reg004bout        ;//004b
    wire               [  31: 0]    w_reg004cout        ;//004c
    wire               [  31: 0]    w_reg004dout        ;//004d
    wire               [  31: 0]    w_reg004eout        ;//004e
    wire               [  31: 0]    w_reg004fout        ;//004f
    wire               [  31: 0]    w_reg0050out        ;//0050
    wire               [  31: 0]    w_reg0051out        ;//0051
    wire               [  31: 0]    w_reg0052out        ;//0052
    wire               [  31: 0]    w_reg0053out        ;//0053
    wire               [  31: 0]    w_reg0054out        ;//0054
    wire               [  31: 0]    w_reg0055out        ;//0055
    wire               [  31: 0]    w_reg0056out        ;//0056
    wire               [  31: 0]    w_reg0057out        ;//0057
    wire               [  31: 0]    w_reg0058out        ;//0058
    wire               [  31: 0]    w_reg0059out        ;//0059
    wire               [  31: 0]    w_reg005aout        ;//005a
    wire               [  31: 0]    w_reg005bout        ;//005b
    wire               [  31: 0]    w_reg005cout        ;//005c
    wire               [  31: 0]    w_reg005dout        ;//005d
    wire               [  31: 0]    w_reg005eout        ;//005e
    wire               [  31: 0]    w_reg005fout        ;//005f
    wire               [  31: 0]    w_reg0060out        ;//0060
    wire               [  31: 0]    w_reg0061out        ;//0061
    wire               [  31: 0]    w_reg0062out        ;//0062
    wire               [  31: 0]    w_reg0063out        ;//0063
    wire               [  31: 0]    w_reg0064out        ;//0064
    wire               [  31: 0]    w_reg0065out        ;//0065
    wire               [  31: 0]    w_reg0066out        ;//0066
    wire               [  31: 0]    w_reg0067out        ;//0067
    wire               [  31: 0]    w_reg0068out        ;//0068
    wire               [  31: 0]    w_reg0069out        ;//0069
    wire               [  31: 0]    w_reg006aout        ;//006a
    wire               [  31: 0]    w_reg006bout        ;//006b
    wire               [  31: 0]    w_reg006cout        ;//006c
    wire               [  31: 0]    w_reg006dout        ;//006d
    wire               [  31: 0]    w_reg006eout        ;//006e
    wire               [  31: 0]    w_reg006fout        ;//006f
    wire               [  31: 0]    w_reg0070out        ;//0070
    wire               [  31: 0]    w_reg0071out        ;//0071
    wire               [  31: 0]    w_reg0072out        ;//0072
    wire               [  31: 0]    w_reg0073out        ;//0073
    wire               [  31: 0]    w_reg0074out        ;//0074
    wire               [  31: 0]    w_reg0075out        ;//0075
    wire               [  31: 0]    w_reg0076out        ;//0076
    wire               [  31: 0]    w_reg0077out        ;//0077
    wire               [  31: 0]    w_reg0078out        ;//0078
    wire               [  31: 0]    w_reg0079out        ;//0079
    wire               [  31: 0]    w_reg007aout        ;//007a
    wire               [  31: 0]    w_reg007bout        ;//007b
    wire               [  31: 0]    w_reg007cout        ;//007c
    wire               [  31: 0]    w_reg007dout        ;//007d
    wire               [  31: 0]    w_reg007eout        ;//007e
    wire               [  31: 0]    w_reg007fout        ;//007f
    wire               [  31: 0]    w_reg0080out        ;//0080
    wire               [  31: 0]    w_reg0081out        ;//0081
    wire               [  31: 0]    w_reg0082out        ;//0082
    wire               [  31: 0]    w_reg0083out        ;//0083
    wire               [  31: 0]    w_reg0084out        ;//0084
    wire               [  31: 0]    w_reg0085out        ;//0085
    wire               [  31: 0]    w_reg0086out        ;//0086
    wire               [  31: 0]    w_reg0087out        ;//0087
    wire               [  31: 0]    w_reg0088out        ;//0088
    wire               [  31: 0]    w_reg0089out        ;//0089
    wire               [  31: 0]    w_reg008aout        ;//008a
    wire               [  31: 0]    w_reg008bout        ;//008b
    wire               [  31: 0]    w_reg008cout        ;//008c
    wire               [  31: 0]    w_reg008dout        ;//008d
    wire               [  31: 0]    w_reg008eout        ;//008e
    wire               [  31: 0]    w_reg008fout        ;//008f
    wire               [  31: 0]    w_reg0090out        ;//0090
    wire               [  31: 0]    w_reg0091out        ;//0091
    wire               [  31: 0]    w_reg0092out        ;//0092
    wire               [  31: 0]    w_reg0093out        ;//0093
    wire               [  31: 0]    w_reg0094out        ;//0094
    wire               [  31: 0]    w_reg0095out        ;//0095
    wire               [  31: 0]    w_reg0096out        ;//0096
    wire               [  31: 0]    w_reg0097out        ;//0097
    wire               [  31: 0]    w_reg0098out        ;//0098
    wire               [  31: 0]    w_reg0099out        ;//0099
    wire               [  31: 0]    w_reg009aout        ;//009a
    wire               [  31: 0]    w_reg009bout        ;//009b
    wire               [  31: 0]    w_reg009cout        ;//009c
    wire               [  31: 0]    w_reg009dout        ;//009d
    wire               [  31: 0]    w_reg009eout        ;//009e
    wire               [  31: 0]    w_reg009fout        ;//009f
    wire               [  31: 0]    w_reg00a0out        ;//00a0
    wire               [  31: 0]    w_reg00a1out        ;//00a1
    wire               [  31: 0]    w_reg00a2out        ;//00a2
    wire               [  31: 0]    w_reg00a3out        ;//00a3
    wire               [  31: 0]    w_reg00a4out        ;//00a4
    wire               [  31: 0]    w_reg00a5out        ;//00a5
    wire               [  31: 0]    w_reg00a6out        ;//00a6
    wire               [  31: 0]    w_reg00a7out        ;//00a7
    wire               [  31: 0]    w_reg00a8out        ;//00a8
    wire               [  31: 0]    w_reg00a9out        ;//00a9
    wire               [  31: 0]    w_reg00aaout        ;//00aa
    wire               [  31: 0]    w_reg00about        ;//00ab
    wire               [  31: 0]    w_reg00acout        ;//00ac
    wire               [  31: 0]    w_reg00adout        ;//00ad
    wire               [  31: 0]    w_reg00aeout        ;//00ae
    wire               [  31: 0]    w_reg00afout        ;//00af
    wire               [  31: 0]    w_reg00b0out        ;//00b0
    wire               [  31: 0]    w_reg00b1out        ;//00b1
    wire               [  31: 0]    w_reg00b2out        ;//00b2
    wire               [  31: 0]    w_reg00b3out        ;//00b3
    wire               [  31: 0]    w_reg00b4out        ;//00b4
    wire               [  31: 0]    w_reg00b5out        ;//00b5
    wire               [  31: 0]    w_reg00b6out        ;//00b6
    wire               [  31: 0]    w_reg00b7out        ;//00b7
    wire               [  31: 0]    w_reg00b8out        ;//00b8
    wire               [  31: 0]    w_reg00b9out        ;//00b9
    wire               [  31: 0]    w_reg00baout        ;//00ba
    wire               [  31: 0]    w_reg00bbout        ;//00bb
    wire               [  31: 0]    w_reg00bcout        ;//00bc
    wire               [  31: 0]    w_reg00bdout        ;//00bd
    wire               [  31: 0]    w_reg00beout        ;//00be
    wire               [  31: 0]    w_reg00bfout        ;//00bf
    wire               [  31: 0]    w_reg00c0out        ;//00c0
    wire               [  31: 0]    w_reg00c1out        ;//00c1
    wire               [  31: 0]    w_reg00c2out        ;//00c2
    wire               [  31: 0]    w_reg00c3out        ;//00c3
    wire               [  31: 0]    w_reg00c4out        ;//00c4
    wire               [  31: 0]    w_reg00c5out        ;//00c5
    wire               [  31: 0]    w_reg00c6out        ;//00c6
    wire               [  31: 0]    w_reg00c7out        ;//00c7
    wire               [  31: 0]    w_reg00c8out        ;//00c8
    wire               [  31: 0]    w_reg00c9out        ;//00c9
    wire               [  31: 0]    w_reg00caout        ;//00ca
    wire               [  31: 0]    w_reg00cbout        ;//00cb
    wire               [  31: 0]    w_reg00ccout        ;//00cc
    wire               [  31: 0]    w_reg00cdout        ;//00cd
    wire               [  31: 0]    w_reg00ceout        ;//00ce
    wire               [  31: 0]    w_reg00cfout        ;//00cf
    wire               [  31: 0]    w_reg00d0out        ;//00d0
    wire               [  31: 0]    w_reg00d1out        ;//00d1
    wire               [  31: 0]    w_reg00d2out        ;//00d2
    wire               [  31: 0]    w_reg00d3out        ;//00d3
    wire               [  31: 0]    w_reg00d4out        ;//00d4
    wire               [  31: 0]    w_reg00d5out        ;//00d5
    wire               [  31: 0]    w_reg00d6out        ;//00d6
    wire               [  31: 0]    w_reg00d7out        ;//00d7
    wire               [  31: 0]    w_reg00d8out        ;//00d8
    wire               [  31: 0]    w_reg00d9out        ;//00d9
    wire               [  31: 0]    w_reg00daout        ;//00da
    wire               [  31: 0]    w_reg00dbout        ;//00db
    wire               [  31: 0]    w_reg00dcout        ;//00dc
    wire               [  31: 0]    w_reg00ddout        ;//00dd
    wire               [  31: 0]    w_reg00deout        ;//00de
    wire               [  31: 0]    w_reg00dfout        ;//00df
    wire               [  31: 0]    w_reg00e0out        ;//00e0
    wire               [  31: 0]    w_reg00e1out        ;//00e1
    wire               [  31: 0]    w_reg00e2out        ;//00e2
    wire               [  31: 0]    w_reg00e3out        ;//00e3
    wire               [  31: 0]    w_reg00e4out        ;//00e4
    wire               [  31: 0]    w_reg00e5out        ;//00e5
    wire               [  31: 0]    w_reg00e6out        ;//00e6
    wire               [  31: 0]    w_reg00e7out        ;//00e7
    wire               [  31: 0]    w_reg00e8out        ;//00e8
    wire               [  31: 0]    w_reg00e9out        ;//00e9
    wire               [  31: 0]    w_reg00eaout        ;//00ea
    wire               [  31: 0]    w_reg00ebout        ;//00eb
    wire               [  31: 0]    w_reg00ecout        ;//00ec
    wire               [  31: 0]    w_reg00edout        ;//00ed
    wire               [  31: 0]    w_reg00eeout        ;//00ee
    wire               [  31: 0]    w_reg00efout        ;//00ef
    wire               [  31: 0]    w_reg00f0out        ;//00f0
    wire               [  31: 0]    w_reg00f1out        ;//00f1
    wire               [  31: 0]    w_reg00f2out        ;//00f2
    wire               [  31: 0]    w_reg00f3out        ;//00f3
    wire               [  31: 0]    w_reg00f4out        ;//00f4
    wire               [  31: 0]    w_reg00f5out        ;//00f5
    wire               [  31: 0]    w_reg00f6out        ;//00f6
    wire               [  31: 0]    w_reg00f7out        ;//00f7
    wire               [  31: 0]    w_reg00f8out        ;//00f8
    wire               [  31: 0]    w_reg00f9out        ;//00f9
    wire               [  31: 0]    w_reg00faout        ;//00fa
    wire               [  31: 0]    w_reg00fbout        ;//00fb
    wire               [  31: 0]    w_reg00fcout        ;//00fc
    wire               [  31: 0]    w_reg00fdout        ;//00fd
    wire               [  31: 0]    w_reg00feout        ;//00fe
    wire               [  31: 0]    w_reg00ffout        ;//00ff
//pl2ps 0x0000~0x01ff 0x0200~0x03ff
    wire               [  31: 0]    w_reg0000in         ;//0000
    wire               [  31: 0]    w_reg0001in         ;//0001
    wire               [  31: 0]    w_reg0002in         ;//0002
    wire               [  31: 0]    w_reg0003in         ;//0003
    wire               [  31: 0]    w_reg0004in         ;//0004
    wire               [  31: 0]    w_reg0005in         ;//0005
    wire               [  31: 0]    w_reg0006in         ;//0006
    wire               [  31: 0]    w_reg0007in         ;//0007
    wire               [  31: 0]    w_reg0008in         ;//0008
    wire               [  31: 0]    w_reg0009in         ;//0009
    wire               [  31: 0]    w_reg000ain         ;//000a
    wire               [  31: 0]    w_reg000bin         ;//000b
    wire               [  31: 0]    w_reg000cin         ;//000c
    wire               [  31: 0]    w_reg000din         ;//000d
    wire               [  31: 0]    w_reg000ein         ;//000e
    wire               [  31: 0]    w_reg000fin         ;//000f
    wire               [  31: 0]    w_reg0010in         ;//0010
    wire               [  31: 0]    w_reg0011in         ;//0011
    wire               [  31: 0]    w_reg0012in         ;//0012
    wire               [  31: 0]    w_reg0013in         ;//0013
    wire               [  31: 0]    w_reg0014in         ;//0014
    wire               [  31: 0]    w_reg0015in         ;//0015
    wire               [  31: 0]    w_reg0016in         ;//0016
    wire               [  31: 0]    w_reg0017in         ;//0017
    wire               [  31: 0]    w_reg0018in         ;//0018
    wire               [  31: 0]    w_reg0019in         ;//0019
    wire               [  31: 0]    w_reg001ain         ;//001a
    wire               [  31: 0]    w_reg001bin         ;//001b
    wire               [  31: 0]    w_reg001cin         ;//001c
    wire               [  31: 0]    w_reg001din         ;//001d
    wire               [  31: 0]    w_reg001ein         ;//001e
    wire               [  31: 0]    w_reg001fin         ;//001f
    wire               [  31: 0]    w_reg0020in         ;//0020
    wire               [  31: 0]    w_reg0021in         ;//0021
    wire               [  31: 0]    w_reg0022in         ;//0022
    wire               [  31: 0]    w_reg0023in         ;//0023
    wire               [  31: 0]    w_reg0024in         ;//0024
    wire               [  31: 0]    w_reg0025in         ;//0025
    wire               [  31: 0]    w_reg0026in         ;//0026
    wire               [  31: 0]    w_reg0027in         ;//0027
    wire               [  31: 0]    w_reg0028in         ;//0028
    wire               [  31: 0]    w_reg0029in         ;//0029
    wire               [  31: 0]    w_reg002ain         ;//002a
    wire               [  31: 0]    w_reg002bin         ;//002b
    wire               [  31: 0]    w_reg002cin         ;//002c
    wire               [  31: 0]    w_reg002din         ;//002d
    wire               [  31: 0]    w_reg002ein         ;//002e
    wire               [  31: 0]    w_reg002fin         ;//002f
    wire               [  31: 0]    w_reg0030in         ;//0030
    wire               [  31: 0]    w_reg0031in         ;//0031
    wire               [  31: 0]    w_reg0032in         ;//0032
    wire               [  31: 0]    w_reg0033in         ;//0033
    wire               [  31: 0]    w_reg0034in         ;//0034
    wire               [  31: 0]    w_reg0035in         ;//0035
    wire               [  31: 0]    w_reg0036in         ;//0036
    wire               [  31: 0]    w_reg0037in         ;//0037
    wire               [  31: 0]    w_reg0038in         ;//0038
    wire               [  31: 0]    w_reg0039in         ;//0039
    wire               [  31: 0]    w_reg003ain         ;//003a
    wire               [  31: 0]    w_reg003bin         ;//003b
    wire               [  31: 0]    w_reg003cin         ;//003c
    wire               [  31: 0]    w_reg003din         ;//003d
    wire               [  31: 0]    w_reg003ein         ;//003e
    wire               [  31: 0]    w_reg003fin         ;//003f
    wire               [  31: 0]    w_reg0040in         ;//0040
    wire               [  31: 0]    w_reg0041in         ;//0041
    wire               [  31: 0]    w_reg0042in         ;//0042
    wire               [  31: 0]    w_reg0043in         ;//0043
    wire               [  31: 0]    w_reg0044in         ;//0044
    wire               [  31: 0]    w_reg0045in         ;//0045
    wire               [  31: 0]    w_reg0046in         ;//0046
    wire               [  31: 0]    w_reg0047in         ;//0047
    wire               [  31: 0]    w_reg0048in         ;//0048
    wire               [  31: 0]    w_reg0049in         ;//0049
    wire               [  31: 0]    w_reg004ain         ;//004a
    wire               [  31: 0]    w_reg004bin         ;//004b
    wire               [  31: 0]    w_reg004cin         ;//004c
    wire               [  31: 0]    w_reg004din         ;//004d
    wire               [  31: 0]    w_reg004ein         ;//004e
    wire               [  31: 0]    w_reg004fin         ;//004f
    wire               [  31: 0]    w_reg0050in         ;//0050
    wire               [  31: 0]    w_reg0051in         ;//0051
    wire               [  31: 0]    w_reg0052in         ;//0052
    wire               [  31: 0]    w_reg0053in         ;//0053
    wire               [  31: 0]    w_reg0054in         ;//0054
    wire               [  31: 0]    w_reg0055in         ;//0055
    wire               [  31: 0]    w_reg0056in         ;//0056
    wire               [  31: 0]    w_reg0057in         ;//0057
    wire               [  31: 0]    w_reg0058in         ;//0058
    wire               [  31: 0]    w_reg0059in         ;//0059
    wire               [  31: 0]    w_reg005ain         ;//005a
    wire               [  31: 0]    w_reg005bin         ;//005b
    wire               [  31: 0]    w_reg005cin         ;//005c
    wire               [  31: 0]    w_reg005din         ;//005d
    wire               [  31: 0]    w_reg005ein         ;//005e
    wire               [  31: 0]    w_reg005fin         ;//005f
    wire               [  31: 0]    w_reg0060in         ;//0060
    wire               [  31: 0]    w_reg0061in         ;//0061
    wire               [  31: 0]    w_reg0062in         ;//0062
    wire               [  31: 0]    w_reg0063in         ;//0063
    wire               [  31: 0]    w_reg0064in         ;//0064
    wire               [  31: 0]    w_reg0065in         ;//0065
    wire               [  31: 0]    w_reg0066in         ;//0066
    wire               [  31: 0]    w_reg0067in         ;//0067
    wire               [  31: 0]    w_reg0068in         ;//0068
    wire               [  31: 0]    w_reg0069in         ;//0069
    wire               [  31: 0]    w_reg006ain         ;//006a
    wire               [  31: 0]    w_reg006bin         ;//006b
    wire               [  31: 0]    w_reg006cin         ;//006c
    wire               [  31: 0]    w_reg006din         ;//006d
    wire               [  31: 0]    w_reg006ein         ;//006e
    wire               [  31: 0]    w_reg006fin         ;//006f
    wire               [  31: 0]    w_reg0070in         ;//0070
    wire               [  31: 0]    w_reg0071in         ;//0071
    wire               [  31: 0]    w_reg0072in         ;//0072
    wire               [  31: 0]    w_reg0073in         ;//0073
    wire               [  31: 0]    w_reg0074in         ;//0074
    wire               [  31: 0]    w_reg0075in         ;//0075
    wire               [  31: 0]    w_reg0076in         ;//0076
    wire               [  31: 0]    w_reg0077in         ;//0077
    wire               [  31: 0]    w_reg0078in         ;//0078
    wire               [  31: 0]    w_reg0079in         ;//0079
    wire               [  31: 0]    w_reg007ain         ;//007a
    wire               [  31: 0]    w_reg007bin         ;//007b
    wire               [  31: 0]    w_reg007cin         ;//007c
    wire               [  31: 0]    w_reg007din         ;//007d
    wire               [  31: 0]    w_reg007ein         ;//007e
    wire               [  31: 0]    w_reg007fin         ;//007f
    wire               [  31: 0]    w_reg0080in         ;//0080
    wire               [  31: 0]    w_reg0081in         ;//0081
    wire               [  31: 0]    w_reg0082in         ;//0082
    wire               [  31: 0]    w_reg0083in         ;//0083
    wire               [  31: 0]    w_reg0084in         ;//0084
    wire               [  31: 0]    w_reg0085in         ;//0085
    wire               [  31: 0]    w_reg0086in         ;//0086
    wire               [  31: 0]    w_reg0087in         ;//0087
    wire               [  31: 0]    w_reg0088in         ;//0088
    wire               [  31: 0]    w_reg0089in         ;//0089
    wire               [  31: 0]    w_reg008ain         ;//008a
    wire               [  31: 0]    w_reg008bin         ;//008b
    wire               [  31: 0]    w_reg008cin         ;//008c
    wire               [  31: 0]    w_reg008din         ;//008d
    wire               [  31: 0]    w_reg008ein         ;//008e
    wire               [  31: 0]    w_reg008fin         ;//008f
    wire               [  31: 0]    w_reg0090in         ;//0090
    wire               [  31: 0]    w_reg0091in         ;//0091
    wire               [  31: 0]    w_reg0092in         ;//0092
    wire               [  31: 0]    w_reg0093in         ;//0093
    wire               [  31: 0]    w_reg0094in         ;//0094
    wire               [  31: 0]    w_reg0095in         ;//0095
    wire               [  31: 0]    w_reg0096in         ;//0096
    wire               [  31: 0]    w_reg0097in         ;//0097
    wire               [  31: 0]    w_reg0098in         ;//0098
    wire               [  31: 0]    w_reg0099in         ;//0099
    wire               [  31: 0]    w_reg009ain         ;//009a
    wire               [  31: 0]    w_reg009bin         ;//009b
    wire               [  31: 0]    w_reg009cin         ;//009c
    wire               [  31: 0]    w_reg009din         ;//009d
    wire               [  31: 0]    w_reg009ein         ;//009e
    wire               [  31: 0]    w_reg009fin         ;//009f
    wire               [  31: 0]    w_reg00a0in         ;//00a0
    wire               [  31: 0]    w_reg00a1in         ;//00a1
    wire               [  31: 0]    w_reg00a2in         ;//00a2
    wire               [  31: 0]    w_reg00a3in         ;//00a3
    wire               [  31: 0]    w_reg00a4in         ;//00a4
    wire               [  31: 0]    w_reg00a5in         ;//00a5
    wire               [  31: 0]    w_reg00a6in         ;//00a6
    wire               [  31: 0]    w_reg00a7in         ;//00a7
    wire               [  31: 0]    w_reg00a8in         ;//00a8
    wire               [  31: 0]    w_reg00a9in         ;//00a9
    wire               [  31: 0]    w_reg00aain         ;//00aa
    wire               [  31: 0]    w_reg00abin         ;//00ab
    wire               [  31: 0]    w_reg00acin         ;//00ac
    wire               [  31: 0]    w_reg00adin         ;//00ad
    wire               [  31: 0]    w_reg00aein         ;//00ae
    wire               [  31: 0]    w_reg00afin         ;//00af
    wire               [  31: 0]    w_reg00b0in         ;//00b0
    wire               [  31: 0]    w_reg00b1in         ;//00b1
    wire               [  31: 0]    w_reg00b2in         ;//00b2
    wire               [  31: 0]    w_reg00b3in         ;//00b3
    wire               [  31: 0]    w_reg00b4in         ;//00b4
    wire               [  31: 0]    w_reg00b5in         ;//00b5
    wire               [  31: 0]    w_reg00b6in         ;//00b6
    wire               [  31: 0]    w_reg00b7in         ;//00b7
    wire               [  31: 0]    w_reg00b8in         ;//00b8
    wire               [  31: 0]    w_reg00b9in         ;//00b9
    wire               [  31: 0]    w_reg00bain         ;//00ba
    wire               [  31: 0]    w_reg00bbin         ;//00bb
    wire               [  31: 0]    w_reg00bcin         ;//00bc
    wire               [  31: 0]    w_reg00bdin         ;//00bd
    wire               [  31: 0]    w_reg00bein         ;//00be
    wire               [  31: 0]    w_reg00bfin         ;//00bf
    wire               [  31: 0]    w_reg00c0in         ;//00c0
    wire               [  31: 0]    w_reg00c1in         ;//00c1
    wire               [  31: 0]    w_reg00c2in         ;//00c2
    wire               [  31: 0]    w_reg00c3in         ;//00c3
    wire               [  31: 0]    w_reg00c4in         ;//00c4
    wire               [  31: 0]    w_reg00c5in         ;//00c5
    wire               [  31: 0]    w_reg00c6in         ;//00c6
    wire               [  31: 0]    w_reg00c7in         ;//00c7
    wire               [  31: 0]    w_reg00c8in         ;//00c8
    wire               [  31: 0]    w_reg00c9in         ;//00c9
    wire               [  31: 0]    w_reg00cain         ;//00ca
    wire               [  31: 0]    w_reg00cbin         ;//00cb
    wire               [  31: 0]    w_reg00ccin         ;//00cc
    wire               [  31: 0]    w_reg00cdin         ;//00cd
    wire               [  31: 0]    w_reg00cein         ;//00ce
    wire               [  31: 0]    w_reg00cfin         ;//00cf
    wire               [  31: 0]    w_reg02cein         ;//02ce
    wire               [  31: 0]    w_reg02cfin         ;//02cf
    wire               [  31: 0]    w_reg00d0in         ;//00d0
    wire               [  31: 0]    w_reg00d1in         ;//00d1
    wire               [  31: 0]    w_reg00d2in         ;//00d2
    wire               [  31: 0]    w_reg00d3in         ;//00d3
    wire               [  31: 0]    w_reg00d4in         ;//00d4
    wire               [  31: 0]    w_reg00d5in         ;//00d5
    wire               [  31: 0]    w_reg00d6in         ;//00d6
    wire               [  31: 0]    w_reg00d7in         ;//00d7
    wire               [  31: 0]    w_reg00d8in         ;//00d8
    wire               [  31: 0]    w_reg00d9in         ;//00d9
    wire               [  31: 0]    w_reg00dain         ;//00da
    wire               [  31: 0]    w_reg00dbin         ;//00db
    wire               [  31: 0]    w_reg00dcin         ;//00dc
    wire               [  31: 0]    w_reg00ddin         ;//00dd
    wire               [  31: 0]    w_reg00dein         ;//00de
    wire               [  31: 0]    w_reg00dfin         ;//00df
    wire               [  31: 0]    w_reg02dein         ;//02de
    wire               [  31: 0]    w_reg02dfin         ;//02df
    wire               [  31: 0]    w_reg00e0in         ;//00e0
    wire               [  31: 0]    w_reg00e1in         ;//00e1
    wire               [  31: 0]    w_reg00e2in         ;//00e2
    wire               [  31: 0]    w_reg00e3in         ;//00e3
    wire               [  31: 0]    w_reg00e4in         ;//00e4
    wire               [  31: 0]    w_reg00e5in         ;//00e5
    wire               [  31: 0]    w_reg00e6in         ;//00e6
    wire               [  31: 0]    w_reg00e7in         ;//00e7
    wire               [  31: 0]    w_reg00e8in         ;//00e8
    wire               [  31: 0]    w_reg00e9in         ;//00e9
    wire               [  31: 0]    w_reg00eain         ;//00ea
    wire               [  31: 0]    w_reg00ebin         ;//00eb
    wire               [  31: 0]    w_reg00ecin         ;//00ec
    wire               [  31: 0]    w_reg00edin         ;//00ed
    wire               [  31: 0]    w_reg00eein         ;//00ee
    wire               [  31: 0]    w_reg00efin         ;//00ef
    wire               [  31: 0]    w_reg00f0in         ;//00f0
    wire               [  31: 0]    w_reg00f1in         ;//00f1
    wire               [  31: 0]    w_reg00f2in         ;//00f2
    wire               [  31: 0]    w_reg00f3in         ;//00f3
    wire               [  31: 0]    w_reg00f4in         ;//00f4
    wire               [  31: 0]    w_reg00f5in         ;//00f5
    wire               [  31: 0]    w_reg00f6in         ;//00f6
    wire               [  31: 0]    w_reg00f7in         ;//00f7
    wire               [  31: 0]    w_reg00f8in         ;//00f8
    wire               [  31: 0]    w_reg00f9in         ;//00f9
    wire               [  31: 0]    w_reg00fain         ;//00fa
    wire               [  31: 0]    w_reg00fbin         ;//00fb
    wire               [  31: 0]    w_reg00fcin         ;//00fc
    wire               [  31: 0]    w_reg00fdin         ;//00fd
    wire               [  31: 0]    w_reg00fein         ;//00fe
    wire               [  31: 0]    w_reg00ffin         ;//00ff

    wire               [  31: 0]    w_reg0100in         ;//0100
    wire               [  31: 0]    w_reg0101in         ;//0101
    wire               [  31: 0]    w_reg0102in         ;//0102
    wire               [  31: 0]    w_reg0103in         ;//0103
    wire               [  31: 0]    w_reg0104in         ;//0104
    wire               [  31: 0]    w_reg0105in         ;//0105
    wire               [  31: 0]    w_reg0106in         ;//0106
    wire               [  31: 0]    w_reg0107in         ;//0107
    wire               [  31: 0]    w_reg0108in         ;//0108
    wire               [  31: 0]    w_reg0109in         ;//0109
    wire               [  31: 0]    w_reg010ain         ;//010a
    wire               [  31: 0]    w_reg010bin         ;//010b
    wire               [  31: 0]    w_reg010cin         ;//010c
    wire               [  31: 0]    w_reg010din         ;//010d
    wire               [  31: 0]    w_reg010ein         ;//010e
    wire               [  31: 0]    w_reg010fin         ;//010f
    wire               [  31: 0]    w_reg0110in         ;//0110
    wire               [  31: 0]    w_reg0111in         ;//0111
    wire               [  31: 0]    w_reg0112in         ;//0112
    wire               [  31: 0]    w_reg0113in         ;//0113
    wire               [  31: 0]    w_reg0114in         ;//0114
    wire               [  31: 0]    w_reg0115in         ;//0115
    wire               [  31: 0]    w_reg0116in         ;//0116
    wire               [  31: 0]    w_reg0117in         ;//0117
    wire               [  31: 0]    w_reg0118in         ;//0118
    wire               [  31: 0]    w_reg0119in         ;//0119
    wire               [  31: 0]    w_reg011ain         ;//011a
    wire               [  31: 0]    w_reg011bin         ;//011b
    wire               [  31: 0]    w_reg011cin         ;//011c
    wire               [  31: 0]    w_reg011din         ;//011d
    wire               [  31: 0]    w_reg011ein         ;//011e
    wire               [  31: 0]    w_reg011fin         ;//011f
    wire               [  31: 0]    w_reg0120in         ;//0120
    wire               [  31: 0]    w_reg0121in         ;//0121
    wire               [  31: 0]    w_reg0122in         ;//0122
    wire               [  31: 0]    w_reg0123in         ;//0123
    wire               [  31: 0]    w_reg0124in         ;//0124
    wire               [  31: 0]    w_reg0125in         ;//0125
    wire               [  31: 0]    w_reg0126in         ;//0126
    wire               [  31: 0]    w_reg0127in         ;//0127
    wire               [  31: 0]    w_reg0128in         ;//0128
    wire               [  31: 0]    w_reg0129in         ;//0129
    wire               [  31: 0]    w_reg012ain         ;//012a
    wire               [  31: 0]    w_reg012bin         ;//012b
    wire               [  31: 0]    w_reg012cin         ;//012c
    wire               [  31: 0]    w_reg012din         ;//012d
    wire               [  31: 0]    w_reg012ein         ;//012e
    wire               [  31: 0]    w_reg012fin         ;//012f
    wire               [  31: 0]    w_reg0130in         ;//0130
    wire               [  31: 0]    w_reg0131in         ;//0131
    wire               [  31: 0]    w_reg0132in         ;//0132
    wire               [  31: 0]    w_reg0133in         ;//0133
    wire               [  31: 0]    w_reg0134in         ;//0134
    wire               [  31: 0]    w_reg0135in         ;//0135
    wire               [  31: 0]    w_reg0136in         ;//0136
    wire               [  31: 0]    w_reg0137in         ;//0137
    wire               [  31: 0]    w_reg0138in         ;//0138
    wire               [  31: 0]    w_reg0139in         ;//0139
    wire               [  31: 0]    w_reg013ain         ;//013a
    wire               [  31: 0]    w_reg013bin         ;//013b
    wire               [  31: 0]    w_reg013cin         ;//013c
    wire               [  31: 0]    w_reg013din         ;//013d
    wire               [  31: 0]    w_reg013ein         ;//013e
    wire               [  31: 0]    w_reg013fin         ;//013f
    wire               [  31: 0]    w_reg0140in         ;//0140
    wire               [  31: 0]    w_reg0141in         ;//0141
    wire               [  31: 0]    w_reg0142in         ;//0142
    wire               [  31: 0]    w_reg0143in         ;//0143
    wire               [  31: 0]    w_reg0144in         ;//0144
    wire               [  31: 0]    w_reg0145in         ;//0145
    wire               [  31: 0]    w_reg0146in         ;//0146
    wire               [  31: 0]    w_reg0147in         ;//0147
    wire               [  31: 0]    w_reg0148in         ;//0148
    wire               [  31: 0]    w_reg0149in         ;//0149
    wire               [  31: 0]    w_reg014ain         ;//014a
    wire               [  31: 0]    w_reg014bin         ;//014b
    wire               [  31: 0]    w_reg014cin         ;//014c
    wire               [  31: 0]    w_reg014din         ;//014d
    wire               [  31: 0]    w_reg014ein         ;//014e
    wire               [  31: 0]    w_reg014fin         ;//014f
    wire               [  31: 0]    w_reg0150in         ;//0150
    wire               [  31: 0]    w_reg0151in         ;//0151
    wire               [  31: 0]    w_reg0152in         ;//0152
    wire               [  31: 0]    w_reg0153in         ;//0153
    wire               [  31: 0]    w_reg0154in         ;//0154
    wire               [  31: 0]    w_reg0155in         ;//0155
    wire               [  31: 0]    w_reg0156in         ;//0156
    wire               [  31: 0]    w_reg0157in         ;//0157
    wire               [  31: 0]    w_reg0158in         ;//0158
    wire               [  31: 0]    w_reg0159in         ;//0159
    wire               [  31: 0]    w_reg015ain         ;//015a
    wire               [  31: 0]    w_reg015bin         ;//015b
    wire               [  31: 0]    w_reg015cin         ;//015c
    wire               [  31: 0]    w_reg015din         ;//015d
    wire               [  31: 0]    w_reg015ein         ;//015e
    wire               [  31: 0]    w_reg015fin         ;//015f
    wire               [  31: 0]    w_reg0160in         ;//0160
    wire               [  31: 0]    w_reg0161in         ;//0161
    wire               [  31: 0]    w_reg0162in         ;//0162
    wire               [  31: 0]    w_reg0163in         ;//0163
    wire               [  31: 0]    w_reg0164in         ;//0164
    wire               [  31: 0]    w_reg0165in         ;//0165
    wire               [  31: 0]    w_reg0166in         ;//0166
    wire               [  31: 0]    w_reg0167in         ;//0167
    wire               [  31: 0]    w_reg0168in         ;//0168
    wire               [  31: 0]    w_reg0169in         ;//0169
    wire               [  31: 0]    w_reg016ain         ;//016a
    wire               [  31: 0]    w_reg016bin         ;//016b
    wire               [  31: 0]    w_reg016cin         ;//016c
    wire               [  31: 0]    w_reg016din         ;//016d
    wire               [  31: 0]    w_reg016ein         ;//016e
    wire               [  31: 0]    w_reg016fin         ;//016f
    wire               [  31: 0]    w_reg0170in         ;//0170
    wire               [  31: 0]    w_reg0171in         ;//0171
    wire               [  31: 0]    w_reg0172in         ;//0172
    wire               [  31: 0]    w_reg0173in         ;//0173
    wire               [  31: 0]    w_reg0174in         ;//0174
    wire               [  31: 0]    w_reg0175in         ;//0175
    wire               [  31: 0]    w_reg0176in         ;//0176
    wire               [  31: 0]    w_reg0177in         ;//0177
    wire               [  31: 0]    w_reg0178in         ;//0178
    wire               [  31: 0]    w_reg0179in         ;//0179
    wire               [  31: 0]    w_reg017ain         ;//017a
    wire               [  31: 0]    w_reg017bin         ;//017b
    wire               [  31: 0]    w_reg017cin         ;//017c
    wire               [  31: 0]    w_reg017din         ;//017d
    wire               [  31: 0]    w_reg017ein         ;//017e
    wire               [  31: 0]    w_reg017fin         ;//017f
    wire               [  31: 0]    w_reg0180in         ;//0180
    wire               [  31: 0]    w_reg0181in         ;//0181
    wire               [  31: 0]    w_reg0182in         ;//0182
    wire               [  31: 0]    w_reg0183in         ;//0183
    wire               [  31: 0]    w_reg0184in         ;//0184
    wire               [  31: 0]    w_reg0185in         ;//0185
    wire               [  31: 0]    w_reg0186in         ;//0186
    wire               [  31: 0]    w_reg0187in         ;//0187
    wire               [  31: 0]    w_reg0188in         ;//0188
    wire               [  31: 0]    w_reg0189in         ;//0189
    wire               [  31: 0]    w_reg018ain         ;//018a
    wire               [  31: 0]    w_reg018bin         ;//018b
    wire               [  31: 0]    w_reg018cin         ;//018c
    wire               [  31: 0]    w_reg018din         ;//018d
    wire               [  31: 0]    w_reg018ein         ;//018e
    wire               [  31: 0]    w_reg018fin         ;//018f
    wire               [  31: 0]    w_reg0190in         ;//0190
    wire               [  31: 0]    w_reg0191in         ;//0191
    wire               [  31: 0]    w_reg0192in         ;//0192
    wire               [  31: 0]    w_reg0193in         ;//0193
    wire               [  31: 0]    w_reg0194in         ;//0194
    wire               [  31: 0]    w_reg0195in         ;//0195
    wire               [  31: 0]    w_reg0196in         ;//0196
    wire               [  31: 0]    w_reg0197in         ;//0197
    wire               [  31: 0]    w_reg0198in         ;//0198
    wire               [  31: 0]    w_reg0199in         ;//0199
    wire               [  31: 0]    w_reg019ain         ;//019a
    wire               [  31: 0]    w_reg019bin         ;//019b
    wire               [  31: 0]    w_reg019cin         ;//019c
    wire               [  31: 0]    w_reg019din         ;//019d
    wire               [  31: 0]    w_reg019ein         ;//019e
    wire               [  31: 0]    w_reg019fin         ;//019f
    wire               [  31: 0]    w_reg01a0in         ;//01a0
    wire               [  31: 0]    w_reg01a1in         ;//01a1
    wire               [  31: 0]    w_reg01a2in         ;//01a2
    wire               [  31: 0]    w_reg01a3in         ;//01a3
    wire               [  31: 0]    w_reg01a4in         ;//01a4
    wire               [  31: 0]    w_reg01a5in         ;//01a5
    wire               [  31: 0]    w_reg01a6in         ;//01a6
    wire               [  31: 0]    w_reg01a7in         ;//01a7
    wire               [  31: 0]    w_reg01a8in         ;//01a8
    wire               [  31: 0]    w_reg01a9in         ;//01a9
    wire               [  31: 0]    w_reg01aain         ;//01aa
    wire               [  31: 0]    w_reg01abin         ;//01ab
    wire               [  31: 0]    w_reg01acin         ;//01ac
    wire               [  31: 0]    w_reg01adin         ;//01ad
    wire               [  31: 0]    w_reg01aein         ;//01ae
    wire               [  31: 0]    w_reg01afin         ;//01af
    wire               [  31: 0]    w_reg01b0in         ;//01b0
    wire               [  31: 0]    w_reg01b1in         ;//01b1
    wire               [  31: 0]    w_reg01b2in         ;//01b2
    wire               [  31: 0]    w_reg01b3in         ;//01b3
    wire               [  31: 0]    w_reg01b4in         ;//01b4
    wire               [  31: 0]    w_reg01b5in         ;//01b5
    wire               [  31: 0]    w_reg01b6in         ;//01b6
    wire               [  31: 0]    w_reg01b7in         ;//01b7
    wire               [  31: 0]    w_reg01b8in         ;//01b8
    wire               [  31: 0]    w_reg01b9in         ;//01b9
    wire               [  31: 0]    w_reg01bain         ;//01ba
    wire               [  31: 0]    w_reg01bbin         ;//01bb
    wire               [  31: 0]    w_reg01bcin         ;//01bc
    wire               [  31: 0]    w_reg01bdin         ;//01bd
    wire               [  31: 0]    w_reg01bein         ;//01be
    wire               [  31: 0]    w_reg01bfin         ;//01bf
    wire               [  31: 0]    w_reg01c0in         ;//01c0
    wire               [  31: 0]    w_reg01c1in         ;//01c1
    wire               [  31: 0]    w_reg01c2in         ;//01c2
    wire               [  31: 0]    w_reg01c3in         ;//01c3
    wire               [  31: 0]    w_reg01c4in         ;//01c4
    wire               [  31: 0]    w_reg01c5in         ;//01c5
    wire               [  31: 0]    w_reg01c6in         ;//01c6
    wire               [  31: 0]    w_reg01c7in         ;//01c7
    wire               [  31: 0]    w_reg01c8in         ;//01c8
    wire               [  31: 0]    w_reg01c9in         ;//01c9
    wire               [  31: 0]    w_reg01cain         ;//01ca
    wire               [  31: 0]    w_reg01cbin         ;//01cb
    wire               [  31: 0]    w_reg01ccin         ;//01cc
    wire               [  31: 0]    w_reg01cdin         ;//01cd
    wire               [  31: 0]    w_reg01cein         ;//01ce
    wire               [  31: 0]    w_reg01cfin         ;//01cf
    wire               [  31: 0]    w_reg01d0in         ;//01d0
    wire               [  31: 0]    w_reg01d1in         ;//01d1
    wire               [  31: 0]    w_reg01d2in         ;//01d2
    wire               [  31: 0]    w_reg01d3in         ;//01d3
    wire               [  31: 0]    w_reg01d4in         ;//01d4
    wire               [  31: 0]    w_reg01d5in         ;//01d5
    wire               [  31: 0]    w_reg01d6in         ;//01d6
    wire               [  31: 0]    w_reg01d7in         ;//01d7
    wire               [  31: 0]    w_reg01d8in         ;//01d8
    wire               [  31: 0]    w_reg01d9in         ;//01d9
    wire               [  31: 0]    w_reg01dain         ;//01da
    wire               [  31: 0]    w_reg01dbin         ;//01db
    wire               [  31: 0]    w_reg01dcin         ;//01dc
    wire               [  31: 0]    w_reg01ddin         ;//01dd
    wire               [  31: 0]    w_reg01dein         ;//01de
    wire               [  31: 0]    w_reg01dfin         ;//01df
    wire               [  31: 0]    w_reg01e0in         ;//01e0
    wire               [  31: 0]    w_reg01e1in         ;//01e1
    wire               [  31: 0]    w_reg01e2in         ;//01e2
    wire               [  31: 0]    w_reg01e3in         ;//01e3
    wire               [  31: 0]    w_reg01e4in         ;//01e4
    wire               [  31: 0]    w_reg01e5in         ;//01e5
    wire               [  31: 0]    w_reg01e6in         ;//01e6
    wire               [  31: 0]    w_reg01e7in         ;//01e7
    wire               [  31: 0]    w_reg01e8in         ;//01e8
    wire               [  31: 0]    w_reg01e9in         ;//01e9
    wire               [  31: 0]    w_reg01eain         ;//01ea
    wire               [  31: 0]    w_reg01ebin         ;//01eb
    wire               [  31: 0]    w_reg01ecin         ;//01ec
    wire               [  31: 0]    w_reg01edin         ;//01ed
    wire               [  31: 0]    w_reg01eein         ;//01ee
    wire               [  31: 0]    w_reg01efin         ;//01ef
    wire               [  31: 0]    w_reg01f0in         ;//01f0
    wire               [  31: 0]    w_reg01f1in         ;//01f1
    wire               [  31: 0]    w_reg01f2in         ;//01f2
    wire               [  31: 0]    w_reg01f3in         ;//01f3
    wire               [  31: 0]    w_reg01f4in         ;//01f4
    wire               [  31: 0]    w_reg01f5in         ;//01f5
    wire               [  31: 0]    w_reg01f6in         ;//01f6
    wire               [  31: 0]    w_reg01f7in         ;//01f7
    wire               [  31: 0]    w_reg01f8in         ;//01f8
    wire               [  31: 0]    w_reg01f9in         ;//01f9
    wire               [  31: 0]    w_reg01fain         ;//01fa
    wire               [  31: 0]    w_reg01fbin         ;//01fb
    wire               [  31: 0]    w_reg01fcin         ;//01fc
    wire               [  31: 0]    w_reg01fdin         ;//01fd
    wire               [  31: 0]    w_reg01fein         ;//01fe
    wire               [  31: 0]    w_reg01ffin         ;//01ff
//----------------------------------------------------------------------
// AXIL ---- localbus
//----------------------------------------------------------------------
axi4_lite_lbus U_axi4_lite_lbus
(
    .axi_clk                        (i_clk              ),//input  
    .axi_reset                      (i_rst              ),//input  
															  
    .o_txen                         (w_ps2pl_txen       ),//output       
    .o_txd                          (w_ps2pl_txd        ),//output [31:0]
    .o_txdstrb                      (w_ps2pl_txdstrb    ),//output [ 3:0]
    .o_txdone                       (w_ps2pl_txdone     ),//output       
    .i_rxen                         (w_ps2pl_rxen       ),//input        
    .i_rxd                          (w_ps2pl_rxd        ),//input  [31:0]
    .o_rxdone                       (w_ps2pl_rxdone     ),//output       
    .o_txawen                       (w_ps2pl_txawen     ),//output       
    .o_txaw                         (w_ps2pl_txaw       ),//output [31:0]
    .o_rxaren                       (w_ps2pl_rxaren     ),//output       
    .o_rxar                         (w_ps2pl_rxar       ),//output [31:0]
															  
    .s_axil_awaddr                  (s_axil_awaddr      ),//input  [31:0] 
    .s_axil_awvalid                 (s_axil_awvalid     ),//input         
    .s_axil_awready                 (s_axil_awready     ),//output        
    .s_axil_wdata                   (s_axil_wdata       ),//input  [31:0] 
    .s_axil_wstrb                   (s_axil_wstrb       ),//input  [ 3:0] 
    .s_axil_wvalid                  (s_axil_wvalid      ),//input         
    .s_axil_wready                  (s_axil_wready      ),//output        
    .s_axil_bresp                   (s_axil_bresp       ),//output [ 1:0] 
    .s_axil_bvalid                  (s_axil_bvalid      ),//output        
    .s_axil_bready                  (s_axil_bready      ),//input         
    .s_axil_araddr                  (s_axil_araddr      ),//input  [31:0] 
    .s_axil_arvalid                 (s_axil_arvalid     ),//input         
    .s_axil_arready                 (s_axil_arready     ),//output        
    .s_axil_rdata                   (s_axil_rdata       ),//output [31:0] 
    .s_axil_rresp                   (s_axil_rresp       ),//output [ 1:0] 
    .s_axil_rvalid                  (s_axil_rvalid      ),//output        
    .s_axil_rready                  (s_axil_rready      ) //input         
);
Regtable_pl_ps #
(
    .MASK_DATA                      (MASK_DATA          ),
    .ADDR_WIDTH                     (14                 ),
    .DATA_WIDTH                     (32                 ) 
)
U_register
(
    .i_clk                          (i_clk              ),
    .i_rst                          (i_rst              ),
// localbus
    .i_wr                           (w_ps2pl_txdone     ),
    .i_rd                           (w_ps2pl_rxaren     ),
    .i_waddr                        ({w_ps2pl_txaw[15:2]}),
    .i_wdata                        (w_ps2pl_txd        ),
    .i_raddr                        ({w_ps2pl_rxar[15:2]}),
    .o_rdata                        (w_ps2pl_rxd        ),
    .o_rdata_vld                    (w_ps2pl_rxen       ),
// write
    .o_reg0000out                   (w_reg0000out       ),//0000
    .o_reg0001out                   (w_reg0001out       ),//0001
    .o_reg0002out                   (w_reg0002out       ),//0002
    .o_reg0003out                   (w_reg0003out       ),//0003
    .o_reg0004out                   (w_reg0004out       ),//0004
    .o_reg0005out                   (w_reg0005out       ),//0005
    .o_reg0006out                   (w_reg0006out       ),//0006
    .o_reg0007out                   (w_reg0007out       ),//0007
    .o_reg0008out                   (w_reg0008out       ),//0008
    .o_reg0009out                   (w_reg0009out       ),//0009
    .o_reg000aout                   (w_reg000aout       ),//000a
    .o_reg000bout                   (w_reg000bout       ),//000b
    .o_reg000cout                   (w_reg000cout       ),//000c
    .o_reg000dout                   (w_reg000dout       ),//000d
    .o_reg000eout                   (w_reg000eout       ),//000e
    .o_reg000fout                   (w_reg000fout       ),//000f
    .o_reg0010out                   (w_reg0010out       ),//0010
    .o_reg0011out                   (w_reg0011out       ),//0011
    .o_reg0012out                   (w_reg0012out       ),//0012
    .o_reg0013out                   (w_reg0013out       ),//0013
    .o_reg0014out                   (w_reg0014out       ),//0014
    .o_reg0015out                   (w_reg0015out       ),//0015
    .o_reg0016out                   (w_reg0016out       ),//0016
    .o_reg0017out                   (w_reg0017out       ),//0017
    .o_reg0018out                   (w_reg0018out       ),//0018
    .o_reg0019out                   (w_reg0019out       ),//0019
    .o_reg001aout                   (w_reg001aout       ),//001a
    .o_reg001bout                   (w_reg001bout       ),//001b
    .o_reg001cout                   (w_reg001cout       ),//001c
    .o_reg001dout                   (w_reg001dout       ),//001d
    .o_reg001eout                   (w_reg001eout       ),//001e
    .o_reg001fout                   (w_reg001fout       ),//001f
    .o_reg0020out                   (w_reg0020out       ),//0020
    .o_reg0021out                   (w_reg0021out       ),//0021
    .o_reg0022out                   (w_reg0022out       ),//0022
    .o_reg0023out                   (w_reg0023out       ),//0023
    .o_reg0024out                   (w_reg0024out       ),//0024
    .o_reg0025out                   (w_reg0025out       ),//0025
    .o_reg0026out                   (w_reg0026out       ),//0026
    .o_reg0027out                   (w_reg0027out       ),//0027
    .o_reg0028out                   (w_reg0028out       ),//0028
    .o_reg0029out                   (w_reg0029out       ),//0029
    .o_reg002aout                   (w_reg002aout       ),//002a
    .o_reg002bout                   (w_reg002bout       ),//002b
    .o_reg002cout                   (w_reg002cout       ),//002c
    .o_reg002dout                   (w_reg002dout       ),//002d
    .o_reg002eout                   (w_reg002eout       ),//002e
    .o_reg002fout                   (w_reg002fout       ),//002f
    .o_reg0030out                   (w_reg0030out       ),//0030
    .o_reg0031out                   (w_reg0031out       ),//0031
    .o_reg0032out                   (w_reg0032out       ),//0032
    .o_reg0033out                   (w_reg0033out       ),//0033
    .o_reg0034out                   (w_reg0034out       ),//0034
    .o_reg0035out                   (w_reg0035out       ),//0035
    .o_reg0036out                   (w_reg0036out       ),//0036
    .o_reg0037out                   (w_reg0037out       ),//0037
    .o_reg0038out                   (w_reg0038out       ),//0038
    .o_reg0039out                   (w_reg0039out       ),//0039
    .o_reg003aout                   (w_reg003aout       ),//003a
    .o_reg003bout                   (w_reg003bout       ),//003b
    .o_reg003cout                   (w_reg003cout       ),//003c
    .o_reg003dout                   (w_reg003dout       ),//003d
    .o_reg003eout                   (w_reg003eout       ),//003e
    .o_reg003fout                   (w_reg003fout       ),//003f
    .o_reg0040out                   (w_reg0040out       ),//0040
    .o_reg0041out                   (w_reg0041out       ),//0041
    .o_reg0042out                   (w_reg0042out       ),//0042
    .o_reg0043out                   (w_reg0043out       ),//0043
    .o_reg0044out                   (w_reg0044out       ),//0044
    .o_reg0045out                   (w_reg0045out       ),//0045
    .o_reg0046out                   (w_reg0046out       ),//0046
    .o_reg0047out                   (w_reg0047out       ),//0047
    .o_reg0048out                   (w_reg0048out       ),//0048
    .o_reg0049out                   (w_reg0049out       ),//0049
    .o_reg004aout                   (w_reg004aout       ),//004a
    .o_reg004bout                   (w_reg004bout       ),//004b
    .o_reg004cout                   (w_reg004cout       ),//004c
    .o_reg004dout                   (w_reg004dout       ),//004d
    .o_reg004eout                   (w_reg004eout       ),//004e
    .o_reg004fout                   (w_reg004fout       ),//004f
    .o_reg0050out                   (w_reg0050out       ),//0050
    .o_reg0051out                   (w_reg0051out       ),//0051
    .o_reg0052out                   (w_reg0052out       ),//0052
    .o_reg0053out                   (w_reg0053out       ),//0053
    .o_reg0054out                   (w_reg0054out       ),//0054
    .o_reg0055out                   (w_reg0055out       ),//0055
    .o_reg0056out                   (w_reg0056out       ),//0056
    .o_reg0057out                   (w_reg0057out       ),//0057
    .o_reg0058out                   (w_reg0058out       ),//0058
    .o_reg0059out                   (w_reg0059out       ),//0059
    .o_reg005aout                   (w_reg005aout       ),//005a
    .o_reg005bout                   (w_reg005bout       ),//005b
    .o_reg005cout                   (w_reg005cout       ),//005c
    .o_reg005dout                   (w_reg005dout       ),//005d
    .o_reg005eout                   (w_reg005eout       ),//005e
    .o_reg005fout                   (w_reg005fout       ),//005f
    .o_reg0060out                   (w_reg0060out       ),//0060
    .o_reg0061out                   (w_reg0061out       ),//0061
    .o_reg0062out                   (w_reg0062out       ),//0062
    .o_reg0063out                   (w_reg0063out       ),//0063
    .o_reg0064out                   (w_reg0064out       ),//0064
    .o_reg0065out                   (w_reg0065out       ),//0065
    .o_reg0066out                   (w_reg0066out       ),//0066
    .o_reg0067out                   (w_reg0067out       ),//0067
    .o_reg0068out                   (w_reg0068out       ),//0068
    .o_reg0069out                   (w_reg0069out       ),//0069
    .o_reg006aout                   (w_reg006aout       ),//006a
    .o_reg006bout                   (w_reg006bout       ),//006b
    .o_reg006cout                   (w_reg006cout       ),//006c
    .o_reg006dout                   (w_reg006dout       ),//006d
    .o_reg006eout                   (w_reg006eout       ),//006e
    .o_reg006fout                   (w_reg006fout       ),//006f
    .o_reg0070out                   (w_reg0070out       ),//0070
    .o_reg0071out                   (w_reg0071out       ),//0071
    .o_reg0072out                   (w_reg0072out       ),//0072
    .o_reg0073out                   (w_reg0073out       ),//0073
    .o_reg0074out                   (w_reg0074out       ),//0074
    .o_reg0075out                   (w_reg0075out       ),//0075
    .o_reg0076out                   (w_reg0076out       ),//0076
    .o_reg0077out                   (w_reg0077out       ),//0077
    .o_reg0078out                   (w_reg0078out       ),//0078
    .o_reg0079out                   (w_reg0079out       ),//0079
    .o_reg007aout                   (w_reg007aout       ),//007a
    .o_reg007bout                   (w_reg007bout       ),//007b
    .o_reg007cout                   (w_reg007cout       ),//007c
    .o_reg007dout                   (w_reg007dout       ),//007d
    .o_reg007eout                   (w_reg007eout       ),//007e
    .o_reg007fout                   (w_reg007fout       ),//007f
    .o_reg0080out                   (w_reg0080out       ),//0080
    .o_reg0081out                   (w_reg0081out       ),//0081
    .o_reg0082out                   (w_reg0082out       ),//0082
    .o_reg0083out                   (w_reg0083out       ),//0083
    .o_reg0084out                   (w_reg0084out       ),//0084
    .o_reg0085out                   (w_reg0085out       ),//0085
    .o_reg0086out                   (w_reg0086out       ),//0086
    .o_reg0087out                   (w_reg0087out       ),//0087
    .o_reg0088out                   (w_reg0088out       ),//0088
    .o_reg0089out                   (w_reg0089out       ),//0089
    .o_reg008aout                   (w_reg008aout       ),//008a
    .o_reg008bout                   (w_reg008bout       ),//008b
    .o_reg008cout                   (w_reg008cout       ),//008c
    .o_reg008dout                   (w_reg008dout       ),//008d
    .o_reg008eout                   (w_reg008eout       ),//008e
    .o_reg008fout                   (w_reg008fout       ),//008f
    .o_reg0090out                   (w_reg0090out       ),//0090
    .o_reg0091out                   (w_reg0091out       ),//0091
    .o_reg0092out                   (w_reg0092out       ),//0092
    .o_reg0093out                   (w_reg0093out       ),//0093
    .o_reg0094out                   (w_reg0094out       ),//0094
    .o_reg0095out                   (w_reg0095out       ),//0095
    .o_reg0096out                   (w_reg0096out       ),//0096
    .o_reg0097out                   (w_reg0097out       ),//0097
    .o_reg0098out                   (w_reg0098out       ),//0098
    .o_reg0099out                   (w_reg0099out       ),//0099
    .o_reg009aout                   (w_reg009aout       ),//009a
    .o_reg009bout                   (w_reg009bout       ),//009b
    .o_reg009cout                   (w_reg009cout       ),//009c
    .o_reg009dout                   (w_reg009dout       ),//009d
    .o_reg009eout                   (w_reg009eout       ),//009e
    .o_reg009fout                   (w_reg009fout       ),//009f
    .o_reg00a0out                   (w_reg00a0out       ),//00a0
    .o_reg00a1out                   (w_reg00a1out       ),//00a1
    .o_reg00a2out                   (w_reg00a2out       ),//00a2
    .o_reg00a3out                   (w_reg00a3out       ),//00a3
    .o_reg00a4out                   (w_reg00a4out       ),//00a4
    .o_reg00a5out                   (w_reg00a5out       ),//00a5
    .o_reg00a6out                   (w_reg00a6out       ),//00a6
    .o_reg00a7out                   (w_reg00a7out       ),//00a7
    .o_reg00a8out                   (w_reg00a8out       ),//00a8
    .o_reg00a9out                   (w_reg00a9out       ),//00a9
    .o_reg00aaout                   (w_reg00aaout       ),//00aa
    .o_reg00about                   (w_reg00about       ),//00ab
    .o_reg00acout                   (w_reg00acout       ),//00ac
    .o_reg00adout                   (w_reg00adout       ),//00ad
    .o_reg00aeout                   (w_reg00aeout       ),//00ae
    .o_reg00afout                   (w_reg00afout       ),//00af
    .o_reg00b0out                   (w_reg00b0out       ),//00b0
    .o_reg00b1out                   (w_reg00b1out       ),//00b1
    .o_reg00b2out                   (w_reg00b2out       ),//00b2
    .o_reg00b3out                   (w_reg00b3out       ),//00b3
    .o_reg00b4out                   (w_reg00b4out       ),//00b4
    .o_reg00b5out                   (w_reg00b5out       ),//00b5
    .o_reg00b6out                   (w_reg00b6out       ),//00b6
    .o_reg00b7out                   (w_reg00b7out       ),//00b7
    .o_reg00b8out                   (w_reg00b8out       ),//00b8
    .o_reg00b9out                   (w_reg00b9out       ),//00b9
    .o_reg00baout                   (w_reg00baout       ),//00ba
    .o_reg00bbout                   (w_reg00bbout       ),//00bb
    .o_reg00bcout                   (w_reg00bcout       ),//00bc
    .o_reg00bdout                   (w_reg00bdout       ),//00bd
    .o_reg00beout                   (w_reg00beout       ),//00be
    .o_reg00bfout                   (w_reg00bfout       ),//00bf
    .o_reg00c0out                   (w_reg00c0out       ),//00c0
    .o_reg00c1out                   (w_reg00c1out       ),//00c1
    .o_reg00c2out                   (w_reg00c2out       ),//00c2
    .o_reg00c3out                   (w_reg00c3out       ),//00c3
    .o_reg00c4out                   (w_reg00c4out       ),//00c4
    .o_reg00c5out                   (w_reg00c5out       ),//00c5
    .o_reg00c6out                   (w_reg00c6out       ),//00c6
    .o_reg00c7out                   (w_reg00c7out       ),//00c7
    .o_reg00c8out                   (w_reg00c8out       ),//00c8
    .o_reg00c9out                   (w_reg00c9out       ),//00c9
    .o_reg00caout                   (w_reg00caout       ),//00ca
    .o_reg00cbout                   (w_reg00cbout       ),//00cb
    .o_reg00ccout                   (w_reg00ccout       ),//00cc
    .o_reg00cdout                   (w_reg00cdout       ),//00cd
    .o_reg00ceout                   (w_reg00ceout       ),//00ce
    .o_reg00cfout                   (w_reg00cfout       ),//00cf
    .o_reg00d0out                   (w_reg00d0out       ),//00d0
    .o_reg00d1out                   (w_reg00d1out       ),//00d1
    .o_reg00d2out                   (w_reg00d2out       ),//00d2
    .o_reg00d3out                   (w_reg00d3out       ),//00d3
    .o_reg00d4out                   (w_reg00d4out       ),//00d4
    .o_reg00d5out                   (w_reg00d5out       ),//00d5
    .o_reg00d6out                   (w_reg00d6out       ),//00d6
    .o_reg00d7out                   (w_reg00d7out       ),//00d7
    .o_reg00d8out                   (w_reg00d8out       ),//00d8
    .o_reg00d9out                   (w_reg00d9out       ),//00d9
    .o_reg00daout                   (w_reg00daout       ),//00da
    .o_reg00dbout                   (w_reg00dbout       ),//00db
    .o_reg00dcout                   (w_reg00dcout       ),//00dc
    .o_reg00ddout                   (w_reg00ddout       ),//00dd
    .o_reg00deout                   (w_reg00deout       ),//00de
    .o_reg00dfout                   (w_reg00dfout       ),//00df
    .o_reg00e0out                   (w_reg00e0out       ),//00e0
    .o_reg00e1out                   (w_reg00e1out       ),//00e1
    .o_reg00e2out                   (w_reg00e2out       ),//00e2
    .o_reg00e3out                   (w_reg00e3out       ),//00e3
    .o_reg00e4out                   (w_reg00e4out       ),//00e4
    .o_reg00e5out                   (w_reg00e5out       ),//00e5
    .o_reg00e6out                   (w_reg00e6out       ),//00e6
    .o_reg00e7out                   (w_reg00e7out       ),//00e7
    .o_reg00e8out                   (w_reg00e8out       ),//00e8
    .o_reg00e9out                   (w_reg00e9out       ),//00e9
    .o_reg00eaout                   (w_reg00eaout       ),//00ea
    .o_reg00ebout                   (w_reg00ebout       ),//00eb
    .o_reg00ecout                   (w_reg00ecout       ),//00ec
    .o_reg00edout                   (w_reg00edout       ),//00ed
    .o_reg00eeout                   (w_reg00eeout       ),//00ee
    .o_reg00efout                   (w_reg00efout       ),//00ef
    .o_reg00f0out                   (w_reg00f0out       ),//00f0
    .o_reg00f1out                   (w_reg00f1out       ),//00f1
    .o_reg00f2out                   (w_reg00f2out       ),//00f2
    .o_reg00f3out                   (w_reg00f3out       ),//00f3
    .o_reg00f4out                   (w_reg00f4out       ),//00f4
    .o_reg00f5out                   (w_reg00f5out       ),//00f5
    .o_reg00f6out                   (w_reg00f6out       ),//00f6
    .o_reg00f7out                   (w_reg00f7out       ),//00f7
    .o_reg00f8out                   (w_reg00f8out       ),//00f8
    .o_reg00f9out                   (w_reg00f9out       ),//00f9
    .o_reg00faout                   (w_reg00faout       ),//00fa
    .o_reg00fbout                   (w_reg00fbout       ),//00fb
    .o_reg00fcout                   (w_reg00fcout       ),//00fc
    .o_reg00fdout                   (w_reg00fdout       ),//00fd
    .o_reg00feout                   (w_reg00feout       ),//00fe
    .o_reg00ffout                   (w_reg00ffout       ),//00ff
// read
    .i_reg0000in                    (w_reg0000in        ),//0000 w_reg0000out
    .i_reg0001in                    (w_reg0001out       ),//0001
    .i_reg0002in                    (w_reg0002out       ),//0002
    .i_reg0003in                    (w_reg0003out       ),//0003
    .i_reg0004in                    (w_reg0004out       ),//0004
    .i_reg0005in                    (w_reg0005out       ),//0005
    .i_reg0006in                    (w_reg0006out       ),//0006
    .i_reg0007in                    (w_reg0007out       ),//0007
    .i_reg0008in                    (w_reg0008in        ),//0008 w_reg0008out
    .i_reg0009in                    (w_reg0009out       ),//0009
    .i_reg000ain                    (w_reg000aout       ),//000a
    .i_reg000bin                    (w_reg000bout       ),//000b
    .i_reg000cin                    (w_reg000cout       ),//000c
    .i_reg000din                    (w_reg000dout       ),//000d
    .i_reg000ein                    (w_reg000eout       ),//000e
    .i_reg000fin                    (w_reg000fout       ),//000f
    .i_reg0010in                    (w_reg0010out       ),//0010
    .i_reg0011in                    (w_reg0011out       ),//0011
    .i_reg0012in                    (w_reg0012out       ),//0012
    .i_reg0013in                    (w_reg0013out       ),//0013
    .i_reg0014in                    (w_reg0014out       ),//0014
    .i_reg0015in                    (w_reg0015out       ),//0015
    .i_reg0016in                    (w_reg0016out       ),//0016
    .i_reg0017in                    (w_reg0017out       ),//0017
    .i_reg0018in                    (w_reg0018out       ),//0018
    .i_reg0019in                    (w_reg0019out       ),//0019
    .i_reg001ain                    (w_reg001aout       ),//001a
    .i_reg001bin                    (w_reg001bout       ),//001b
    .i_reg001cin                    (w_reg001cout       ),//001c
    .i_reg001din                    (w_reg001dout       ),//001d
    .i_reg001ein                    (w_reg001eout       ),//001e
    .i_reg001fin                    (w_reg001fout       ),//001f
    .i_reg0020in                    (w_reg0020out       ),//0020
    .i_reg0021in                    (w_reg0021out       ),//0021
    .i_reg0022in                    (w_reg0022out       ),//0022
    .i_reg0023in                    (w_reg0023out       ),//0023
    .i_reg0024in                    (w_reg0024out       ),//0024
    .i_reg0025in                    (w_reg0025out       ),//0025
    .i_reg0026in                    (w_reg0026out       ),//0026
    .i_reg0027in                    (w_reg0027out       ),//0027
    .i_reg0028in                    (w_reg0028out       ),//0028
    .i_reg0029in                    (w_reg0029out       ),//0029
    .i_reg002ain                    (w_reg002aout       ),//002a
    .i_reg002bin                    (w_reg002bout       ),//002b
    .i_reg002cin                    (w_reg002cout       ),//002c
    .i_reg002din                    (w_reg002dout       ),//002d
    .i_reg002ein                    (w_reg002eout       ),//002e
    .i_reg002fin                    (w_reg002fout       ),//002f
    .i_reg0030in                    (w_reg0030out       ),//0030
    .i_reg0031in                    (w_reg0031out       ),//0031
    .i_reg0032in                    (w_reg0032out       ),//0032
    .i_reg0033in                    (w_reg0033out       ),//0033
    .i_reg0034in                    (w_reg0034out       ),//0034
    .i_reg0035in                    (w_reg0035out       ),//0035
    .i_reg0036in                    (w_reg0036out       ),//0036
    .i_reg0037in                    (w_reg0037out       ),//0037
    .i_reg0038in                    (w_reg0038out       ),//0038
    .i_reg0039in                    (w_reg0039out       ),//0039
    .i_reg003ain                    (w_reg003aout       ),//003a
    .i_reg003bin                    (w_reg003bout       ),//003b
    .i_reg003cin                    (w_reg003cout       ),//003c
    .i_reg003din                    (w_reg003dout       ),//003d
    .i_reg003ein                    (w_reg003eout       ),//003e
    .i_reg003fin                    (w_reg003fout       ),//003f
    .i_reg0040in                    (w_reg0040out       ),//0040
    .i_reg0041in                    (w_reg0041out       ),//0041
    .i_reg0042in                    (w_reg0042out       ),//0042
    .i_reg0043in                    (w_reg0043out       ),//0043
    .i_reg0044in                    (w_reg0044out       ),//0044
    .i_reg0045in                    (w_reg0045out       ),//0045
    .i_reg0046in                    (w_reg0046out       ),//0046
    .i_reg0047in                    (w_reg0047out       ),//0047
    .i_reg0048in                    (w_reg0048out       ),//0048
    .i_reg0049in                    (w_reg0049out       ),//0049
    .i_reg004ain                    (w_reg004aout       ),//004a
    .i_reg004bin                    (w_reg004bout       ),//004b
    .i_reg004cin                    (w_reg004cout       ),//004c
    .i_reg004din                    (w_reg004dout       ),//004d
    .i_reg004ein                    (w_reg004eout       ),//004e
    .i_reg004fin                    (w_reg004fout       ),//004f
    .i_reg0050in                    (w_reg0050out       ),//0050
    .i_reg0051in                    (w_reg0051out       ),//0051
    .i_reg0052in                    (w_reg0052out       ),//0052
    .i_reg0053in                    (w_reg0053out       ),//0053
    .i_reg0054in                    (w_reg0054out       ),//0054
    .i_reg0055in                    (w_reg0055out       ),//0055
    .i_reg0056in                    (w_reg0056out       ),//0056
    .i_reg0057in                    (w_reg0057out       ),//0057
    .i_reg0058in                    (w_reg0058out       ),//0058
    .i_reg0059in                    (w_reg0059out       ),//0059
    .i_reg005ain                    (w_reg005aout       ),//005a
    .i_reg005bin                    (w_reg005bout       ),//005b
    .i_reg005cin                    (w_reg005cout       ),//005c
    .i_reg005din                    (w_reg005dout       ),//005d
    .i_reg005ein                    (w_reg005eout       ),//005e
    .i_reg005fin                    (w_reg005fout       ),//005f
    .i_reg0060in                    (w_reg0060out       ),//0060
    .i_reg0061in                    (w_reg0061out       ),//0061
    .i_reg0062in                    (w_reg0062out       ),//0062
    .i_reg0063in                    (w_reg0063out       ),//0063
    .i_reg0064in                    (w_reg0064out       ),//0064
    .i_reg0065in                    (w_reg0065out       ),//0065
    .i_reg0066in                    (w_reg0066out       ),//0066
    .i_reg0067in                    (w_reg0067out       ),//0067
    .i_reg0068in                    (w_reg0068out       ),//0068
    .i_reg0069in                    (w_reg0069out       ),//0069
    .i_reg006ain                    (w_reg006aout       ),//006a
    .i_reg006bin                    (w_reg006bout       ),//006b
    .i_reg006cin                    (w_reg006cout       ),//006c
    .i_reg006din                    (w_reg006dout       ),//006d
    .i_reg006ein                    (w_reg006eout       ),//006e
    .i_reg006fin                    (w_reg006fout       ),//006f
    .i_reg0070in                    (w_reg0070out       ),//0070
    .i_reg0071in                    (w_reg0071out       ),//0071
    .i_reg0072in                    (w_reg0072out       ),//0072
    .i_reg0073in                    (w_reg0073out       ),//0073
    .i_reg0074in                    (w_reg0074out       ),//0074
    .i_reg0075in                    (w_reg0075out       ),//0075
    .i_reg0076in                    (w_reg0076out       ),//0076
    .i_reg0077in                    (w_reg0077out       ),//0077
    .i_reg0078in                    (w_reg0078out       ),//0078
    .i_reg0079in                    (w_reg0079out       ),//0079
    .i_reg007ain                    (w_reg007aout       ),//007a
    .i_reg007bin                    (w_reg007bout       ),//007b
    .i_reg007cin                    (w_reg007cout       ),//007c
    .i_reg007din                    (w_reg007dout       ),//007d
    .i_reg007ein                    (w_reg007eout       ),//007e
    .i_reg007fin                    (w_reg007fout       ),//007f
    .i_reg0080in                    (w_reg0080out       ),//0080
    .i_reg0081in                    (w_reg0081out       ),//0081
    .i_reg0082in                    (w_reg0082out       ),//0082
    .i_reg0083in                    (w_reg0083out       ),//0083
    .i_reg0084in                    (w_reg0084out       ),//0084
    .i_reg0085in                    (w_reg0085out       ),//0085
    .i_reg0086in                    (w_reg0086out       ),//0086
    .i_reg0087in                    (w_reg0087out       ),//0087
    .i_reg0088in                    (w_reg0088out       ),//0088
    .i_reg0089in                    (w_reg0089out       ),//0089
    .i_reg008ain                    (w_reg008aout       ),//008a
    .i_reg008bin                    (w_reg008bout       ),//008b
    .i_reg008cin                    (w_reg008cout       ),//008c
    .i_reg008din                    (w_reg008dout       ),//008d
    .i_reg008ein                    (w_reg008eout       ),//008e
    .i_reg008fin                    (w_reg008fout       ),//008f
    .i_reg0090in                    (w_reg0090out       ),//0090
    .i_reg0091in                    (w_reg0091out       ),//0091
    .i_reg0092in                    (w_reg0092out       ),//0092
    .i_reg0093in                    (w_reg0093out       ),//0093
    .i_reg0094in                    (w_reg0094out       ),//0094
    .i_reg0095in                    (w_reg0095out       ),//0095
    .i_reg0096in                    (w_reg0096out       ),//0096
    .i_reg0097in                    (w_reg0097out       ),//0097
    .i_reg0098in                    (w_reg0098out       ),//0098
    .i_reg0099in                    (w_reg0099out       ),//0099
    .i_reg009ain                    (w_reg009aout       ),//009a
    .i_reg009bin                    (w_reg009bout       ),//009b
    .i_reg009cin                    (w_reg009cout       ),//009c
    .i_reg009din                    (w_reg009dout       ),//009d
    .i_reg009ein                    (w_reg009eout       ),//009e
    .i_reg009fin                    (w_reg009fout       ),//009f
    .i_reg00a0in                    (w_reg00a0out       ),//00a0
    .i_reg00a1in                    (w_reg00a1out       ),//00a1
    .i_reg00a2in                    (w_reg00a2out       ),//00a2
    .i_reg00a3in                    (w_reg00a3out       ),//00a3
    .i_reg00a4in                    (w_reg00a4out       ),//00a4
    .i_reg00a5in                    (w_reg00a5out       ),//00a5
    .i_reg00a6in                    (w_reg00a6out       ),//00a6
    .i_reg00a7in                    (w_reg00a7out       ),//00a7
    .i_reg00a8in                    (w_reg00a8out       ),//00a8
    .i_reg00a9in                    (w_reg00a9out       ),//00a9
    .i_reg00aain                    (w_reg00aaout       ),//00aa
    .i_reg00abin                    (w_reg00about       ),//00ab
    .i_reg00acin                    (w_reg00acout       ),//00ac
    .i_reg00adin                    (w_reg00adout       ),//00ad
    .i_reg00aein                    (w_reg00aeout       ),//00ae
    .i_reg00afin                    (w_reg00afout       ),//00af
    .i_reg00b0in                    (w_reg00b0out       ),//00b0
    .i_reg00b1in                    (w_reg00b1out       ),//00b1
    .i_reg00b2in                    (w_reg00b2out       ),//00b2
    .i_reg00b3in                    (w_reg00b3out       ),//00b3
    .i_reg00b4in                    (w_reg00b4out       ),//00b4
    .i_reg00b5in                    (w_reg00b5out       ),//00b5
    .i_reg00b6in                    (w_reg00b6out       ),//00b6
    .i_reg00b7in                    (w_reg00b7out       ),//00b7
    .i_reg00b8in                    (w_reg00b8out       ),//00b8
    .i_reg00b9in                    (w_reg00b9out       ),//00b9
    .i_reg00bain                    (w_reg00baout       ),//00ba
    .i_reg00bbin                    (w_reg00bbout       ),//00bb
    .i_reg00bcin                    (w_reg00bcout       ),//00bc
    .i_reg00bdin                    (w_reg00bdout       ),//00bd
    .i_reg00bein                    (w_reg00beout       ),//00be
    .i_reg00bfin                    (w_reg00bfout       ),//00bf
    .i_reg00c0in                    (w_reg00c0out       ),//00c0
    .i_reg00c1in                    (w_reg00c1out       ),//00c1
    .i_reg00c2in                    (w_reg00c2out       ),//00c2
    .i_reg00c3in                    (w_reg00c3out       ),//00c3
    .i_reg00c4in                    (w_reg00c4out       ),//00c4
    .i_reg00c5in                    (w_reg00c5out       ),//00c5
    .i_reg00c6in                    (w_reg00c6out       ),//00c6
    .i_reg00c7in                    (w_reg00c7out       ),//00c7
    .i_reg00c8in                    (w_reg00c8out       ),//00c8
    .i_reg00c9in                    (w_reg00c9out       ),//00c9
    .i_reg00cain                    (w_reg00caout       ),//00ca
    .i_reg00cbin                    (w_reg00cbout       ),//00cb
    .i_reg00ccin                    (w_reg00ccout       ),//00cc
    .i_reg00cdin                    (w_reg00cdout       ),//00cd
    .i_reg00cein                    (w_reg00cein        ),//00ce w_reg00ceout
    .i_reg00cfin                    (w_reg00cfin        ),//00cf w_reg00cfout
    .i_reg02cein                    (w_reg02cein        ),//02ce 
    .i_reg02cfin                    (w_reg02cfin        ),//02cf 
    .i_reg00d0in                    (w_reg00d0out       ),//00d0
    .i_reg00d1in                    (w_reg00d1out       ),//00d1
    .i_reg00d2in                    (w_reg00d2out       ),//00d2
    .i_reg00d3in                    (w_reg00d3out       ),//00d3
    .i_reg00d4in                    (w_reg00d4out       ),//00d4
    .i_reg00d5in                    (w_reg00d5out       ),//00d5
    .i_reg00d6in                    (w_reg00d6out       ),//00d6
    .i_reg00d7in                    (w_reg00d7out       ),//00d7
    .i_reg00d8in                    (w_reg00d8out       ),//00d8
    .i_reg00d9in                    (w_reg00d9out       ),//00d9
    .i_reg00dain                    (w_reg00daout       ),//00da
    .i_reg00dbin                    (w_reg00dbout       ),//00db
    .i_reg00dcin                    (w_reg00dcout       ),//00dc
    .i_reg00ddin                    (w_reg00ddout       ),//00dd
    .i_reg00dein                    (w_reg00dein        ),//00de  w_reg00deout
    .i_reg00dfin                    (w_reg00dfin        ),//00df  w_reg00dfout
    .i_reg02dein                    (w_reg02dein        ),//02de  
    .i_reg02dfin                    (w_reg02dfin        ),//02df  
    .i_reg00e0in                    (w_reg00e0out       ),//00e0
    .i_reg00e1in                    (w_reg00e1out       ),//00e1
    .i_reg00e2in                    (w_reg00e2out       ),//00e2
    .i_reg00e3in                    (w_reg00e3out       ),//00e3
    .i_reg00e4in                    (w_reg00e4out       ),//00e4
    .i_reg00e5in                    (w_reg00e5out       ),//00e5
    .i_reg00e6in                    (w_reg00e6out       ),//00e6
    .i_reg00e7in                    (w_reg00e7out       ),//00e7
    .i_reg00e8in                    (w_reg00e8out       ),//00e8
    .i_reg00e9in                    (w_reg00e9out       ),//00e9
    .i_reg00eain                    (w_reg00eaout       ),//00ea
    .i_reg00ebin                    (w_reg00ebout       ),//00eb
    .i_reg00ecin                    (w_reg00ecout       ),//00ec
    .i_reg00edin                    (w_reg00edout       ),//00ed
    .i_reg00eein                    (w_reg00eeout       ),//00ee
    .i_reg00efin                    (w_reg00efout       ),//00ef
    .i_reg00f0in                    (w_reg00f0out       ),//00f0
    .i_reg00f1in                    (w_reg00f1out       ),//00f1
    .i_reg00f2in                    (w_reg00f2out       ),//00f2
    .i_reg00f3in                    (w_reg00f3out       ),//00f3
    .i_reg00f4in                    (w_reg00f4out       ),//00f4
    .i_reg00f5in                    (w_reg00f5out       ),//00f5
    .i_reg00f6in                    (w_reg00f6out       ),//00f6
    .i_reg00f7in                    (w_reg00f7out       ),//00f7
    .i_reg00f8in                    (w_reg00f8out       ),//00f8
    .i_reg00f9in                    (w_reg00f9out       ),//00f9
    .i_reg00fain                    (w_reg00faout       ),//00fa
    .i_reg00fbin                    (w_reg00fbout       ),//00fb
    .i_reg00fcin                    (w_cnt_repeat_list  ),//00fc
    .i_reg00fdin                    (w_cnt_total_loop_list),//00fd
    .i_reg00fein                    (w_stepnum_do       ),//00fe
    .i_reg00ffin                    (w_cnt_loop_list    ),//00ff
											 
    .i_reg0100in                    (w_reg0100in        ),//0100
    .i_reg0101in                    (w_reg0101in        ),//0101
    .i_reg0102in                    (w_reg0102in        ),//0102
    .i_reg0103in                    (w_reg0103in        ),//0103
    .i_reg0104in                    (w_reg0104in        ),//0104
    .i_reg0105in                    (w_reg0105in        ),//0105
    .i_reg0106in                    (w_reg0106in        ),//0106
    .i_reg0107in                    (w_reg0107in        ),//0107
    .i_reg0108in                    (w_reg0108in        ),//0108
    .i_reg0109in                    (w_reg0109in        ),//0109
    .i_reg010ain                    (w_reg010ain        ),//010a
    .i_reg010bin                    (w_reg010bin        ),//010b
    .i_reg010cin                    (w_reg010cin        ),//010c
    .i_reg010din                    (w_reg010din        ),//010d
    .i_reg010ein                    (w_reg010ein        ),//010e
    .i_reg010fin                    (w_reg010fin        ),//010f
    .i_reg0110in                    (w_reg0110in        ),//0110
    .i_reg0111in                    (w_reg0111in        ),//0111
    .i_reg0112in                    (w_reg0112in        ),//0112
    .i_reg0113in                    (w_reg0113in        ),//0113
    .i_reg0114in                    (w_reg0114in        ),//0114
    .i_reg0115in                    (w_reg0115in        ),//0115
    .i_reg0116in                    (w_reg0116in        ),//0116
    .i_reg0117in                    (w_reg0117in        ),//0117
    .i_reg0118in                    (w_reg0118in        ),//0118
    .i_reg0119in                    (w_reg0119in        ),//0119
    .i_reg011ain                    (w_reg011ain        ),//011a
    .i_reg011bin                    (w_reg011bin        ),//011b
    .i_reg011cin                    (w_reg011cin        ),//011c
    .i_reg011din                    (w_reg011din        ),//011d
    .i_reg011ein                    (w_reg011ein        ),//011e
    .i_reg011fin                    (w_reg011fin        ),//011f
    .i_reg0120in                    (w_reg0120in        ),//0120
    .i_reg0121in                    (w_reg0121in        ),//0121
    .i_reg0122in                    (w_reg0122in        ),//0122
    .i_reg0123in                    (w_reg0123in        ),//0123
    .i_reg0124in                    (w_reg0124in        ),//0124
    .i_reg0125in                    (w_reg0125in        ),//0125
    .i_reg0126in                    (w_reg0126in        ),//0126
    .i_reg0127in                    (w_reg0127in        ),//0127
    .i_reg0128in                    (w_reg0128in        ),//0128
    .i_reg0129in                    (w_reg0129in        ),//0129
    .i_reg012ain                    (w_reg012ain        ),//012a
    .i_reg012bin                    (w_reg012bin        ),//012b
    .i_reg012cin                    (w_reg012cin        ),//012c
    .i_reg012din                    (w_reg012din        ),//012d
    .i_reg012ein                    (w_reg012ein        ),//012e
    .i_reg012fin                    (w_reg012fin        ),//012f
    .i_reg0130in                    (w_reg0130in        ),//0130
    .i_reg0131in                    (w_reg0131in        ),//0131
    .i_reg0132in                    (w_reg0132in        ),//0132
    .i_reg0133in                    (w_reg0133in        ),//0133
    .i_reg0134in                    (w_reg0134in        ),//0134
    .i_reg0135in                    (w_reg0135in        ),//0135
    .i_reg0136in                    (w_reg0136in        ),//0136
    .i_reg0137in                    (w_reg0137in        ),//0137
    .i_reg0138in                    (w_reg0138in        ),//0138
    .i_reg0139in                    (w_reg0139in        ),//0139
    .i_reg013ain                    (w_reg013ain        ),//013a
    .i_reg013bin                    (w_reg013bin        ),//013b
    .i_reg013cin                    (w_reg013cin        ),//013c
    .i_reg013din                    (w_reg013din        ),//013d
    .i_reg013ein                    (w_reg013ein        ),//013e
    .i_reg013fin                    (w_reg013fin        ),//013f
    .i_reg0140in                    (w_reg0140in        ),//0140
    .i_reg0141in                    (w_reg0141in        ),//0141
    .i_reg0142in                    (w_reg0142in        ),//0142
    .i_reg0143in                    (w_reg0143in        ),//0143
    .i_reg0144in                    (w_reg0144in        ),//0144
    .i_reg0145in                    (w_reg0145in        ),//0145
    .i_reg0146in                    (w_reg0146in        ),//0146
    .i_reg0147in                    (w_reg0147in        ),//0147
    .i_reg0148in                    (w_reg0148in        ),//0148
    .i_reg0149in                    (w_reg0149in        ),//0149
    .i_reg014ain                    (w_reg014ain        ),//014a
    .i_reg014bin                    (w_reg014bin        ),//014b
    .i_reg014cin                    (w_reg014cin        ),//014c
    .i_reg014din                    (w_reg014din        ),//014d
    .i_reg014ein                    (w_reg014ein        ),//014e
    .i_reg014fin                    (w_reg014fin        ),//014f
    .i_reg0150in                    (w_reg0150in        ),//0150
    .i_reg0151in                    (w_reg0151in        ),//0151
    .i_reg0152in                    (w_reg0152in        ),//0152
    .i_reg0153in                    (w_reg0153in        ),//0153
    .i_reg0154in                    (w_reg0154in        ),//0154
    .i_reg0155in                    (w_reg0155in        ),//0155
    .i_reg0156in                    (w_reg0156in        ),//0156
    .i_reg0157in                    (w_reg0157in        ),//0157
    .i_reg0158in                    (w_reg0158in        ),//0158
    .i_reg0159in                    (w_reg0159in        ),//0159
    .i_reg015ain                    (w_reg015ain        ),//015a
    .i_reg015bin                    (w_reg015bin        ),//015b
    .i_reg015cin                    (w_reg015cin        ),//015c
    .i_reg015din                    (w_reg015din        ),//015d
    .i_reg015ein                    (w_reg015ein        ),//015e
    .i_reg015fin                    (w_reg015fin        ),//015f
    .i_reg0160in                    (w_reg0160in        ),//0160
    .i_reg0161in                    (w_reg0161in        ),//0161
    .i_reg0162in                    (w_reg0162in        ),//0162
    .i_reg0163in                    (w_reg0163in        ),//0163
    .i_reg0164in                    (w_reg0164in        ),//0164
    .i_reg0165in                    (w_reg0165in        ),//0165
    .i_reg0166in                    (w_reg0166in        ),//0166
    .i_reg0167in                    (w_reg0167in        ),//0167
    .i_reg0168in                    (w_reg0168in        ),//0168
    .i_reg0169in                    (w_reg0169in        ),//0169
    .i_reg016ain                    (w_reg016ain        ),//016a
    .i_reg016bin                    (w_reg016bin        ),//016b
    .i_reg016cin                    (w_reg016cin        ),//016c
    .i_reg016din                    (w_reg016din        ),//016d
    .i_reg016ein                    (w_reg016ein        ),//016e
    .i_reg016fin                    (w_reg016fin        ),//016f
    .i_reg0170in                    (w_reg0170in        ),//0170
    .i_reg0171in                    (w_reg0171in        ),//0171
    .i_reg0172in                    (w_reg0172in        ),//0172
    .i_reg0173in                    (w_reg0173in        ),//0173
    .i_reg0174in                    (w_reg0174in        ),//0174
    .i_reg0175in                    (w_reg0175in        ),//0175
    .i_reg0176in                    (w_reg0176in        ),//0176
    .i_reg0177in                    (w_reg0177in        ),//0177
    .i_reg0178in                    (w_reg0178in        ),//0178
    .i_reg0179in                    (w_reg0179in        ),//0179
    .i_reg017ain                    (w_reg017ain        ),//017a
    .i_reg017bin                    (w_reg017bin        ),//017b
    .i_reg017cin                    (w_reg017cin        ),//017c
    .i_reg017din                    (w_reg017din        ),//017d
    .i_reg017ein                    (w_reg017ein        ),//017e
    .i_reg017fin                    (w_reg017fin        ),//017f
    .i_reg0180in                    (w_reg0180in        ),//0180
    .i_reg0181in                    (w_reg0181in        ),//0181
    .i_reg0182in                    (w_reg0182in        ),//0182
    .i_reg0183in                    (w_reg0183in        ),//0183
    .i_reg0184in                    (w_reg0184in        ),//0184
    .i_reg0185in                    (w_reg0185in        ),//0185
    .i_reg0186in                    (w_reg0186in        ),//0186
    .i_reg0187in                    (w_reg0187in        ),//0187
    .i_reg0188in                    (w_reg0188in        ),//0188
    .i_reg0189in                    (w_reg0189in        ),//0189
    .i_reg018ain                    (w_reg018ain        ),//018a
    .i_reg018bin                    (w_reg018bin        ),//018b
    .i_reg018cin                    (w_reg018cin        ),//018c
    .i_reg018din                    (w_reg018din        ),//018d
    .i_reg018ein                    (w_reg018ein        ),//018e
    .i_reg018fin                    (w_reg018fin        ),//018f
    .i_reg0190in                    (w_reg0190in        ),//0190
    .i_reg0191in                    (w_reg0191in        ),//0191
    .i_reg0192in                    (w_reg0192in        ),//0192
    .i_reg0193in                    (w_reg0193in        ),//0193
    .i_reg0194in                    (w_reg0194in        ),//0194
    .i_reg0195in                    (w_reg0195in        ),//0195
    .i_reg0196in                    (w_reg0196in        ),//0196
    .i_reg0197in                    (w_reg0197in        ),//0197
    .i_reg0198in                    (w_reg0198in        ),//0198
    .i_reg0199in                    (w_reg0199in        ),//0199
    .i_reg019ain                    (w_reg019ain        ),//019a
    .i_reg019bin                    (w_reg019bin        ),//019b
    .i_reg019cin                    (w_reg019cin        ),//019c
    .i_reg019din                    (w_reg019din        ),//019d
    .i_reg019ein                    (w_reg019ein        ),//019e
    .i_reg019fin                    (w_reg019fin        ),//019f
    .i_reg01a0in                    (w_reg01a0in        ),//01a0
    .i_reg01a1in                    (w_reg01a1in        ),//01a1
    .i_reg01a2in                    (w_reg01a2in        ),//01a2
    .i_reg01a3in                    (w_reg01a3in        ),//01a3
    .i_reg01a4in                    (w_reg01a4in        ),//01a4
    .i_reg01a5in                    (w_reg01a5in        ),//01a5
    .i_reg01a6in                    (w_reg01a6in        ),//01a6
    .i_reg01a7in                    (w_reg01a7in        ),//01a7
    .i_reg01a8in                    (w_reg01a8in        ),//01a8
    .i_reg01a9in                    (w_reg01a9in        ),//01a9
    .i_reg01aain                    (w_reg01aain        ),//01aa
    .i_reg01abin                    (w_reg01abin        ),//01ab
    .i_reg01acin                    (w_reg01acin        ),//01ac
    .i_reg01adin                    (w_reg01adin        ),//01ad
    .i_reg01aein                    (w_reg01aein        ),//01ae
    .i_reg01afin                    (w_reg01afin        ),//01af
    .i_reg01b0in                    (w_reg01b0in        ),//01b0
    .i_reg01b1in                    (w_reg01b1in        ),//01b1
    .i_reg01b2in                    (w_reg01b2in        ),//01b2
    .i_reg01b3in                    (w_reg01b3in        ),//01b3
    .i_reg01b4in                    (w_reg01b4in        ),//01b4
    .i_reg01b5in                    (w_reg01b5in        ),//01b5
    .i_reg01b6in                    (w_reg01b6in        ),//01b6
    .i_reg01b7in                    (w_reg01b7in        ),//01b7
    .i_reg01b8in                    (w_reg01b8in        ),//01b8
    .i_reg01b9in                    (w_reg01b9in        ),//01b9
    .i_reg01bain                    (w_reg01bain        ),//01ba
    .i_reg01bbin                    (w_reg01bbin        ),//01bb
    .i_reg01bcin                    (w_reg01bcin        ),//01bc
    .i_reg01bdin                    (w_reg01bdin        ),//01bd
    .i_reg01bein                    (w_reg01bein        ),//01be
    .i_reg01bfin                    (w_reg01bfin        ),//01bf
    .i_reg01c0in                    (w_reg01c0in        ),//01c0
    .i_reg01c1in                    (w_reg01c1in        ),//01c1
    .i_reg01c2in                    (w_reg01c2in        ),//01c2
    .i_reg01c3in                    (w_reg01c3in        ),//01c3
    .i_reg01c4in                    (w_reg01c4in        ),//01c4
    .i_reg01c5in                    (w_reg01c5in        ),//01c5
    .i_reg01c6in                    (w_reg01c6in        ),//01c6
    .i_reg01c7in                    (w_reg01c7in        ),//01c7
    .i_reg01c8in                    (w_reg01c8in        ),//01c8
    .i_reg01c9in                    (w_reg01c9in        ),//01c9
    .i_reg01cain                    (w_reg01cain        ),//01ca
    .i_reg01cbin                    (w_reg01cbin        ),//01cb
    .i_reg01ccin                    (w_reg01ccin        ),//01cc
    .i_reg01cdin                    (w_reg01cdin        ),//01cd
    .i_reg01cein                    (w_reg01cein        ),//01ce 
    .i_reg01cfin                    (w_reg01cfin        ),//01cf 
    .i_reg01d0in                    (w_reg01d0in        ),//01d0
    .i_reg01d1in                    (w_reg01d1in        ),//01d1
    .i_reg01d2in                    (w_reg01d2in        ),//01d2
    .i_reg01d3in                    (w_reg01d3in        ),//01d3
    .i_reg01d4in                    (w_reg01d4in        ),//01d4
    .i_reg01d5in                    (w_reg01d5in        ),//01d5
    .i_reg01d6in                    (w_reg01d6in        ),//01d6
    .i_reg01d7in                    (w_reg01d7in        ),//01d7
    .i_reg01d8in                    (w_reg01d8in        ),//01d8
    .i_reg01d9in                    (w_reg01d9in        ),//01d9
    .i_reg01dain                    (w_reg01dain        ),//01da
    .i_reg01dbin                    (w_reg01dbin        ),//01db
    .i_reg01dcin                    (w_reg01dcin        ),//01dc
    .i_reg01ddin                    (w_reg01ddin        ),//01dd
    .i_reg01dein                    (w_reg01dein        ),//01de
    .i_reg01dfin                    (w_reg01dfin        ),//01df
    .i_reg01e0in                    (w_reg01e0in        ),//01e0
    .i_reg01e1in                    (w_reg01e1in        ),//01e1
    .i_reg01e2in                    (w_reg01e2in        ),//01e2
    .i_reg01e3in                    (w_reg01e3in        ),//01e3
    .i_reg01e4in                    (w_reg01e4in        ),//01e4
    .i_reg01e5in                    (w_reg01e5in        ),//01e5
    .i_reg01e6in                    (w_reg01e6in        ),//01e6
    .i_reg01e7in                    (w_reg01e7in        ),//01e7
    .i_reg01e8in                    (w_reg01e8in        ),//01e8
    .i_reg01e9in                    (w_reg01e9in        ),//01e9
    .i_reg01eain                    (w_reg01eain        ),//01ea
    .i_reg01ebin                    (w_reg01ebin        ),//01eb
    .i_reg01ecin                    (w_reg01ecin        ),//01ec
    .i_reg01edin                    (w_reg01edin        ),//01ed
    .i_reg01eein                    (w_reg01eein        ),//01ee
    .i_reg01efin                    (w_reg01efin        ),//01ef
    .i_reg01f0in                    (w_reg01f0in        ),//01f0
    .i_reg01f1in                    (w_reg01f1in        ),//01f1
    .i_reg01f2in                    (w_reg01f2in        ),//01f2
    .i_reg01f3in                    (w_reg01f3in        ),//01f3
    .i_reg01f4in                    (w_reg01f4in        ),//01f4
    .i_reg01f5in                    (w_reg01f5in        ),//01f5
    .i_reg01f6in                    (w_reg01f6in        ),//01f6
    .i_reg01f7in                    (w_reg01f7in        ),//01f7
    .i_reg01f8in                    (w_reg01f8in        ),//01f8
    .i_reg01f9in                    (w_reg01f9in        ),//01f9
    .i_reg01fain                    (w_reg01fain        ),//01fa
    .i_reg01fbin                    (w_reg01fbin        ),//01fb
    .i_reg01fcin                    (w_reg01fcin        ),//01fc
    .i_reg01fdin                    (w_reg01fdin        ),//01fd
    .i_reg01fein                    (w_reg01fein        ),//01fe
    .i_reg01ffin                    ({8'd51,8'd01,8'd01,"D"}),//01ff w_reg01ffin
									                
    .o_test_data                    (                   ) 
);
/*
//--------------------------------------------------------------------------------------
// ila_lbus
//--------------------------------------------------------------------------------------
    wire                            w_ck_lbus           ;
    wire               [  31: 0]    w_p0_lbus           ;
    wire               [  31: 0]    w_p1_lbus           ;
    wire               [   0: 0]    w_p2_lbus           ;
    wire               [   0: 0]    w_p3_lbus           ;
    wire               [  31: 0]    w_p4_lbus           ;
    wire               [  31: 0]    w_p5_lbus           ;
    wire               [   0: 0]    w_p6_lbus           ;
    wire               [   0: 0]    w_p7_lbus           ;
    assign                          w_ck_lbus          = i_clk;
    assign                          w_p0_lbus          = {w_ps2pl_txaw[31:0]};
    assign                          w_p1_lbus          = w_ps2pl_txd;
    assign                          w_p2_lbus          = w_ps2pl_txdone;
    assign                          w_p3_lbus          = w_ps2pl_txdone;
    assign                          w_p4_lbus          = {w_ps2pl_rxar[31:0]};
    assign                          w_p5_lbus          = w_ps2pl_rxd;
    assign                          w_p6_lbus          = w_ps2pl_rxaren;
    assign                          w_p7_lbus          = w_ps2pl_rxen;
ila_lbus U_lbus
(
    .clk                            (w_ck_lbus          ) // input wire clk
    ,.probe0        ( w_p0_lbus   )                                 // input wire [31:0]  probe0  
    ,.probe1        ( w_p1_lbus   )                                 // input wire [31:0]  probe1 
    ,.probe2        ( w_p2_lbus   )                                 // input wire [0:0]   probe2 
    ,.probe3        ( w_p3_lbus   )                                 // input wire [0:0]   probe3 
    ,.probe4        ( w_p4_lbus   )                                 // input wire [31:0]  probe4 
    ,.probe5        ( w_p5_lbus   )                                 // input wire [31:0]  probe5 
    ,.probe6        ( w_p6_lbus   )                                 // input wire [0:0]   probe6 
    ,.probe7        ( w_p7_lbus   )                                 // input wire [0:0]   probe7 
);
*/
/*
//--------------------------------------------------------------------------------------
// ila_axi
//--------------------------------------------------------------------------------------
    wire                            w_ck_axi_aw         ;
    wire               [  31: 0]    w_p0_axi_aw         ;
    wire               [   0: 0]    w_p1_axi_aw         ;
    wire               [   0: 0]    w_p2_axi_aw         ;
    assign                          w_ck_axi_aw        = i_clk;
    assign                          w_p0_axi_aw        = s_axil_awaddr;
    assign                          w_p1_axi_aw        = s_axil_awvalid;
    assign                          w_p2_axi_aw        = s_axil_awready;
ila_axi U_axi_aw
(
    .clk                            (w_ck_axi_aw        ) // input wire clk
    ,.probe0        ( w_p0_axi_aw   )                               // input wire [31:0]  probe0  
    ,.probe1        ( w_p1_axi_aw   )                               // input wire [0:0]   probe1 
    ,.probe2        ( w_p2_axi_aw   )                               // input wire [0:0]   probe2 
);
    wire                            w_ck_axi_ar         ;
    wire               [  31: 0]    w_p0_axi_ar         ;
    wire               [   0: 0]    w_p1_axi_ar         ;
    wire               [   0: 0]    w_p2_axi_ar         ;
    assign                          w_ck_axi_ar        = i_clk;
    assign                          w_p0_axi_ar        = s_axil_araddr;
    assign                          w_p1_axi_ar        = s_axil_arvalid;
    assign                          w_p2_axi_ar        = s_axil_arready;
ila_axi U_axi_ar
(
    .clk                            (w_ck_axi_ar        ) // input wire clk
    ,.probe0        ( w_p0_axi_ar   )                               // input wire [31:0]  probe0  
    ,.probe1        ( w_p1_axi_ar   )                               // input wire [0:0]   probe1 
    ,.probe2        ( w_p2_axi_ar   )                               // input wire [0:0]   probe2 
);
    wire                            w_ck_axi_dw         ;
    wire               [  31: 0]    w_p0_axi_dw         ;
    wire               [   0: 0]    w_p1_axi_dw         ;
    wire               [   0: 0]    w_p2_axi_dw         ;
    assign                          w_ck_axi_dw        = i_clk;
    assign                          w_p0_axi_dw        = s_axil_wdata;
    assign                          w_p1_axi_dw        = s_axil_wvalid;
    assign                          w_p2_axi_dw        = s_axil_wready;
ila_axi U_axi_dw
(
    .clk                            (w_ck_axi_dw        ) // input wire clk
    ,.probe0        ( w_p0_axi_dw   )                               // input wire [31:0]  probe0  
    ,.probe1        ( w_p1_axi_dw   )                               // input wire [0:0]   probe1 
    ,.probe2        ( w_p2_axi_dw   )                               // input wire [0:0]   probe2 
);
    wire                            w_ck_axi_dr         ;
    wire               [  31: 0]    w_p0_axi_dr         ;
    wire               [   0: 0]    w_p1_axi_dr         ;
    wire               [   0: 0]    w_p2_axi_dr         ;
    assign                          w_ck_axi_dr        = i_clk;
    assign                          w_p0_axi_dr        = s_axil_rdata;
    assign                          w_p1_axi_dr        = s_axil_rvalid;
    assign                          w_p2_axi_dr        = s_axil_rready;
ila_axi U_axi_dr
(
    .clk                            (w_ck_axi_dr        ) // input wire clk
    ,.probe0        ( w_p0_axi_dr   )                               // input wire [31:0]  probe0  
    ,.probe1        ( w_p1_axi_dr   )                               // input wire [0:0]   probe1 
    ,.probe2        ( w_p2_axi_dr   )                               // input wire [0:0]   probe2 
);
*/

//1200V： 200A
//单模块电路电流： 200A/8/24 = 1.04166666A
//一个0.33R（3W） ， 单电阻功耗： P_R=0.521/3=0.358W
//1.0416666A*0.33R=0.34375V
//G=24K/2.4K=10
//Vsample_max = G*0.34375= 3.4375V   
//I_board_unit ?
//I总电流=200A时， 单板Vout（Isum） =（I1+I2+..+I24） *（0.5K/10K） = 4.125V  
//I_sum_unit ?

//8KW总电流采样：
//1200V： 200A
//单板电流为： 200A/4/2=25A
//八个20mR（3W） 并联,单电阻功耗： P=2.25/8=0.1953125W
//G1=24;G2=3
//I总电流=200A时， 单板Vout(IBoard)=25A*(0.02/8)*G1*G2=4.5V
//I_board ?

//采样总电流为200A： （单模块50A/单板25A）
//IS_UNIT1=IS_UNIT2=...=IS_UNIT8=4.125V
//I_SUM=(IS_UNIT1+IS_UNIT2+...+IS_UNIT8)*(1.37K/10K)=4.521V
//最高采样电流： V_AD=5V ->I_SUM= 221.19A
//I_sum ?

//---------------------------------------------------------------------------------
//  
// main control output
//  
//---------------------------------------------------------------------------------
    reg                             s_flag_run        =0;//
    reg                             s_flag_stop       =0;//
    wire                            w_doing_pull_out    ;
    reg                [  15: 0]    s_run_status      ='ha5a5;//
    reg                [  15: 0]    s_tocp_status     ='h0;//
    reg                [  15: 0]    s_topp_status     ='h0;//

    wire                            w_workmode_CC_rt    ;//当前工作CC模式
    wire                            w_workmode_CP_rt    ;//当前工作CP模式
    wire                            w_workmode_CR_rt    ;//当前工作CR模式
    wire                            w_workmode_CV_rt    ;//当前工作CV模式
    wire                            w_ocp_soft          ;//
    wire                            w_ovp_soft          ;//
    wire                            w_opp_soft          ;//
    wire                            w_ocp_maxI_soft     ;//
    wire                            w_ovp_maxU_soft     ;//
    wire                            w_opp_maxP_soft     ;//
    wire                            w_flag_1us          ;//1us脉冲
    wire                            w_flag_1ms          ;//1ms脉冲
    wire                            w_flag_1s           ;//1s脉冲
    wire               [  23: 0]    w_SR_slew_cur       ;//电流上升斜率
    wire               [  23: 0]    w_SF_slew_cur       ;//电流下降斜率
    wire                            w_enb_slew_cur      ;//电流按斜率控制使能
    wire                            w_enb_precharge     ;//预充使能
    wire                            w_err_sense         ;//Sense错误指示
    wire                            w_err_INV           ;//电流/电压反向错误指示
    wire                            w_other_err         ;//正负电压错误指示
    wire                            w_off_err           ;//错误停止脉冲
    wire                            w_off_cpl           ;//BATT/TOCP/TOPP测试完成脉冲
    wire                            w_ocp_hardCV        ;//硬件CV时OCP
    wire                            w_ocp_in_CV         ;//CV模式下输入的OCP信号
    wire                            w_deburrer_ocp_hardCV  ;//
    wire                            w_deburrer_ocp_in_CV  ;//
//ADC 采样值  二进制补码   +-
//ADC_code码
(*mark_debug = "true"*)    wire                            w_vld_adc           ;
(*mark_debug = "true"*)    wire     signed    [  15: 0]    w_HI_sum            ;//I_SUM_H_AD----高档位8路板卡汇总电流4.521V
(*mark_debug = "true"*)    wire     signed    [  15: 0]    w_LI_sum            ;//I_SUM_L_AD----低档位8路板卡汇总电流
(*mark_debug = "true"*)    wire     signed    [  15: 0]    w_HI_board          ;//I_BOARD_H_AD----高档位板卡电流4.5V
(*mark_debug = "true"*)    wire     signed    [  15: 0]    w_LI_board          ;//I_BOARD_L_AD----低档位板卡电流
(*mark_debug = "true"*)    wire     signed    [  15: 0]    w_U_mod             ;//AD_Vmod----非sense端电压
(*mark_debug = "true"*)    wire     signed    [  15: 0]    w_U_sense           ;//AD_Vsense----sense端电压
(*mark_debug = "true"*)    wire     signed    [  15: 0]    w_I_sum_unit        ;//I_SUM_UNIT_AD----单板卡24模块汇总电流4.125V
(*mark_debug = "true"*)    wire     signed    [  15: 0]    w_I_board_unit      ;//I_BOARD_UNIT_AD----单板卡单模块电流3.4375V
//-----------------------------------------------------------------------
// ADC
// AD7606 八通道
// SPI接口
// ADI
//-----------------------------------------------------------------------
AD7606_ctrl U_AD7606_ctrl
(
    .i_clk                          (i_clk              ),//100M
    .i_rst                          (i_rst              ),//
    
    .o_done                         (w_vld_adc          ),//
    .o_adcdata                      ({w_I_board_unit,w_I_sum_unit,w_U_sense,w_U_mod,w_LI_board,w_HI_board,w_LI_sum,w_HI_sum}),//                     
    
    .o_ic_reset                     (o_ad7606_reset     ),//reset
    .o_ic_cs                        (o_ad7606_cs        ),///cs
    .o_ic_sclk                      (o_ad7606_sclk      ),//rd
    .o_ic_conv                      (o_ad7606_conv      ),
    .i_ic_busy                      (i_ad7606_busy      ),
    .i_ic_miso                      (i_ad7606_miso      ) 
);
//DAC 输出 //控制MOS管的Vgs电压进而控制Ids (MOS管必须工作在线性区间)
//DAC_code码
(*mark_debug = "true"*)    wire                            w_dac_cha_set       ;
(*mark_debug = "true"*)    wire                            unsigned            [15:0]w_dac_cha_data;
(*mark_debug = "true"*)    wire                            w_dac_chb_set       ;
(*mark_debug = "true"*)    wire                            unsigned            [15:0]w_dac_chb_data;
//-----------------------------------------------------------------------
// DAC
// AD5689 双通道
// SPI接口
// ADI
//-----------------------------------------------------------------------
AD5689_ctrl U_AD5689_ctrl
(
    .i_clk                          (i_clk              ),//input          
    .i_rst                          (i_rst              ),//input          
													 
    .i_cha_set                      (w_dac_cha_set      ),//input        
    .i_cha_data                     (w_dac_cha_data     ),//input [15:0] 
    .i_chb_set                      (w_dac_chb_set      ),//input        
    .i_chb_data                     (w_dac_chb_data     ),//input [15:0] 
    .i_cmd_set                      (0                  ),//input        
    .i_cmd_data                     (0                  ),//input [19:0] 
    .i_cmd_type                     (0                  ),//input [ 3:0] 
													    
    .o_ic_resetn                    (o_ad5689_resetn    ),//output      
    .o_ic_ldac                      (o_ad5689_ldac      ),//output      
    .o_ic_pdl                       (o_ad5689_pdl       ),//output      
    .o_ic_sclk                      (o_ad5689_sclk      ),//output      
    .o_ic_cs                        (o_ad5689_cs        ),//output      
    .o_ic_mosi                      (o_ad5689_mosi      ),//output      
    .i_ic_miso                      (i_ad5689_miso      ),//input       
    .o_ic_dir                       (o_ad5689_dir       ) //output      
);
/*
//--------------------------------------------------------------------------------------
// ila_dac
//--------------------------------------------------------------------------------------
    wire                            w_ck_ila_dac        ;
    wire               [  15: 0]    w_p0_ila_dac        ;
    wire               [  15: 0]    w_p1_ila_dac        ;
    wire               [   0: 0]    w_p2_ila_dac        ;
    assign                          w_ck_ila_dac       = i_clk;
    assign                          w_p0_ila_dac       = w_dac_cha_data;
    assign                          w_p1_ila_dac       = w_dac_chb_data;
    assign                          w_p2_ila_dac       = w_dac_cha_set;
ila_dac U_ila_dac
(
    .clk                            (w_ck_ila_dac       ) // input wire clk
    ,.probe0        ( w_p0_ila_dac   )                              // input wire [15:0]  probe0  
    ,.probe1        ( w_p1_ila_dac   )                              // input wire [15:0]   probe1 
    ,.probe2        ( w_p2_ila_dac   )                              // input wire [0:0]   probe2 
);

 */
// CODE * 5 / 2^15 = Vin(V)
//---------------------------------------------------------------------------------
// ADC输出校准参数 校准后为 mA mV mW ohm 
// CODE * 5 / 2^15 * K1 * 1000
//---------------------------------------------------------------------------------
    wire     signed    [  15: 0]    w_k_I_board_unit  ,w_b_I_board_unit;//reserve
    wire     signed    [  15: 0]    w_k_I_sum_unit    ,w_b_I_sum_unit;//reserve
    wire     signed    [  15: 0]    w_k_U_sense       ,w_b_U_sense;//reg0053/reg0054
    wire     signed    [  15: 0]    w_k_U_mod         ,w_b_U_mod;//reg0051/reg0052
    wire     signed    [  15: 0]    w_k_LI_board      ,w_b_LI_board;//reg0057/reg0058
    wire     signed    [  15: 0]    w_k_HI_board      ,w_b_HI_board;//reg0055/reg0056
    wire     signed    [  15: 0]    w_k_LI_sum        ,w_b_LI_sum;//reg005f/reg0060
    wire     signed    [  15: 0]    w_k_HI_sum        ,w_b_HI_sum;//reg005d/reg005e
    wire     signed    [  15: 0]    w_k_LU_sense      ,w_b_LU_sense;//reg005b/reg005c
    wire     signed    [  15: 0]    w_k_LU_mod        ,w_b_LU_mod;//reg0059/reg005a
                                                           
// Reg_Beat #(.D_WIDTH(16)) U_k_I_board_unit (.i_clk(i_clk),.i_data({w_reg0057out[15:0]}),.o_data(w_k_I_board_unit));
// Reg_Beat #(.D_WIDTH(16)) U_b_I_board_unit (.i_clk(i_clk),.i_data({w_reg0058out[15:0]}),.o_data(w_b_I_board_unit));
// Reg_Beat #(.D_WIDTH(16)) U_k_I_sum_unit   (.i_clk(i_clk),.i_data({w_reg005fout[15:0]}),.o_data(w_k_I_sum_unit  ));
// Reg_Beat #(.D_WIDTH(16)) U_b_I_sum_unit   (.i_clk(i_clk),.i_data({w_reg0060out[15:0]}),.o_data(w_b_I_sum_unit  ));
    assign                          w_k_I_board_unit   = 'd30556;
    assign                          w_b_I_board_unit   = 'h0;
    assign                          w_k_I_sum_unit     = 'd33333;
    assign                          w_b_I_sum_unit     = 'h0;

Reg_Beat #(.D_WIDTH(16)) U_k_U_sense  (.i_clk(i_clk),.i_data({w_reg0053out[15:0]}),.o_data(w_k_U_sense     ));
Reg_Beat #(.D_WIDTH(16)) U_b_U_sense  (.i_clk(i_clk),.i_data({w_reg0054out[15:0]}),.o_data(w_b_U_sense     ));
Reg_Beat #(.D_WIDTH(16)) U_k_U_mod    (.i_clk(i_clk),.i_data({w_reg0051out[15:0]}),.o_data(w_k_U_mod       ));
Reg_Beat #(.D_WIDTH(16)) U_b_U_mod    (.i_clk(i_clk),.i_data({w_reg0052out[15:0]}),.o_data(w_b_U_mod       ));
Reg_Beat #(.D_WIDTH(16)) U_k_LI_board (.i_clk(i_clk),.i_data({w_reg0055out[15:0]}),.o_data(w_k_HI_board    ));
Reg_Beat #(.D_WIDTH(16)) U_b_LI_board (.i_clk(i_clk),.i_data({w_reg0056out[15:0]}),.o_data(w_b_HI_board    ));
Reg_Beat #(.D_WIDTH(16)) U_k_HI_board (.i_clk(i_clk),.i_data({w_reg0057out[15:0]}),.o_data(w_k_LI_board    ));
Reg_Beat #(.D_WIDTH(16)) U_b_HI_board (.i_clk(i_clk),.i_data({w_reg0058out[15:0]}),.o_data(w_b_LI_board    ));
Reg_Beat #(.D_WIDTH(16)) U_k_LI_sum   (.i_clk(i_clk),.i_data({w_reg005dout[15:0]}),.o_data(w_k_HI_sum      ));
Reg_Beat #(.D_WIDTH(16)) U_b_LI_sum   (.i_clk(i_clk),.i_data({w_reg005eout[15:0]}),.o_data(w_b_HI_sum      ));
Reg_Beat #(.D_WIDTH(16)) U_k_HI_sum   (.i_clk(i_clk),.i_data({w_reg005fout[15:0]}),.o_data(w_k_LI_sum      ));
Reg_Beat #(.D_WIDTH(16)) U_b_HI_sum   (.i_clk(i_clk),.i_data({w_reg0060out[15:0]}),.o_data(w_b_LI_sum      ));
Reg_Beat #(.D_WIDTH(16)) U_k_LU_sense (.i_clk(i_clk),.i_data({w_reg005bout[15:0]}),.o_data(w_k_LU_sense    ));
Reg_Beat #(.D_WIDTH(16)) U_b_LU_sense (.i_clk(i_clk),.i_data({w_reg005cout[15:0]}),.o_data(w_b_LU_sense    ));
Reg_Beat #(.D_WIDTH(16)) U_k_LU_mod   (.i_clk(i_clk),.i_data({w_reg0059out[15:0]}),.o_data(w_k_LU_mod      ));
Reg_Beat #(.D_WIDTH(16)) U_b_LU_mod   (.i_clk(i_clk),.i_data({w_reg005aout[15:0]}),.o_data(w_b_LU_mod      ));
//按实际项目截取数据位宽(这里电压和电流用24bit就够了,Dmax=2^23=8388607)
    wire     signed    [  23: 0]    w_cut_I_board_unit  ;//mA
    wire     signed    [  23: 0]    w_cut_I_sum_unit    ;//mA
    wire     signed    [  23: 0]    w_cut_U_sense       ;//mV(Sense ON)
    wire     signed    [  23: 0]    w_cut_U_mod         ;//mV(Sense OFF)
    wire     signed    [  23: 0]    w_cut_LI_board      ;//mA
    wire     signed    [  23: 0]    w_cut_HI_board      ;//mA
    wire     signed    [  23: 0]    w_cut_LI_sum        ;//mA
    wire     signed    [  23: 0]    w_cut_HI_sum        ;//mA
    wire     signed    [  23: 0]    w_cut_LU_sense      ;//mV(Sense ON)
    wire     signed    [  23: 0]    w_cut_LU_mod        ;//mV(Sense OFF)
//电流/电压绝对值
    wire                            unsigned            [23:0]w_abs_I_board_unit;//mA
    wire                            unsigned            [23:0]w_abs_I_sum_unit;//mA
    wire                            unsigned            [23:0]w_abs_U_sense;//mV(Sense ON)
    wire                            unsigned            [23:0]w_abs_U_mod;//mV(Sense OFF)
    wire                            unsigned            [23:0]w_abs_LI_board;//mA
    wire                            unsigned            [23:0]w_abs_HI_board;//mA
    wire                            unsigned            [23:0]w_abs_LI_sum;//mA
    wire                            unsigned            [23:0]w_abs_HI_sum;//mA
    wire                            unsigned            [23:0]w_abs_LU_sense;//mV(Sense ON)
    wire                            unsigned            [23:0]w_abs_LU_mod;//mV(Sense OFF)

ADC_Volt_Curr_wrapper U_ADC_Volt_Curr_wrapper
(
    .i_clk                          (i_clk              ),//
    .i_rst                          (i_rst              ),//
//ADC采集Code码
    .i_HI_sum                       (w_HI_sum           ),//
    .i_LI_sum                       (w_LI_sum           ),//
    .i_HI_board                     (w_HI_board         ),//
    .i_LI_board                     (w_LI_board         ),//
    .i_U_mod                        (w_U_mod            ),//
    .i_U_sense                      (w_U_sense          ),//
    .i_I_sum_unit                   (w_I_sum_unit       ),//
    .i_I_board_unit                 (w_I_board_unit     ),//
//采集校准参数 k/b
    .i_k_I_board_unit               (w_k_I_board_unit   ),//reserve
    .i_k_I_sum_unit                 (w_k_I_sum_unit     ),//reserve
    .i_k_U_sense                    (w_k_U_sense        ),//reg0053
    .i_k_U_mod                      (w_k_U_mod          ),//reg0051
    .i_k_LI_board                   (w_k_LI_board       ),//reg0057
    .i_k_HI_board                   (w_k_HI_board       ),//reg0055
    .i_k_LI_sum                     (w_k_LI_sum         ),//reg005f
    .i_k_HI_sum                     (w_k_HI_sum         ),//reg005d
    .i_k_LU_sense                   (w_k_LU_sense       ),//reg005b
    .i_k_LU_mod                     (w_k_LU_mod         ),//reg0059
												     
    .i_b_I_board_unit               (w_b_I_board_unit   ),//reserve
    .i_b_I_sum_unit                 (w_b_I_sum_unit     ),//reserve
    .i_b_U_sense                    (w_b_U_sense        ),//reg0054
    .i_b_U_mod                      (w_b_U_mod          ),//reg0052
    .i_b_LI_board                   (w_b_LI_board       ),//reg0058
    .i_b_HI_board                   (w_b_HI_board       ),//reg0056
    .i_b_LI_sum                     (w_b_LI_sum         ),//reg0060
    .i_b_HI_sum                     (w_b_HI_sum         ),//reg005e
    .i_b_LU_sense                   (w_b_LU_sense       ),//reg005c
    .i_b_LU_mod                     (w_b_LU_mod         ),//reg005a
//输出电压电流值                                     
    .o_I_board_unit                 (w_cut_I_board_unit ),//reserve
    .o_I_sum_unit                   (w_cut_I_sum_unit   ),//reserve
    .o_U_sense                      (w_cut_U_sense      ),//mV
    .o_U_mod                        (w_cut_U_mod        ),//mV
    .o_LI_board                     (w_cut_LI_board     ),//mA
    .o_HI_board                     (w_cut_HI_board     ),//mA
    .o_LI_sum                       (w_cut_LI_sum       ),//mA
    .o_HI_sum                       (w_cut_HI_sum       ),//mA
    .o_LU_sense                     (w_cut_LU_sense     ),//mV
    .o_LU_mod                       (w_cut_LU_mod       ),//mV
								   
    .o_abs_I_board_unit             (w_abs_I_board_unit ),//reserve
    .o_abs_I_sum_unit               (w_abs_I_sum_unit   ),//reserve
    .o_abs_U_sense                  (w_abs_U_sense      ),//mV
    .o_abs_U_mod                    (w_abs_U_mod        ),//mV
    .o_abs_LI_board                 (w_abs_LI_board     ),//mA
    .o_abs_HI_board                 (w_abs_HI_board     ),//mA
    .o_abs_LI_sum                   (w_abs_LI_sum       ),//mA
    .o_abs_HI_sum                   (w_abs_HI_sum       ),//mA
    .o_abs_LU_sense                 (w_abs_LU_sense     ),//mV
    .o_abs_LU_mod                   (w_abs_LU_mod       ) //,//mV
);
/*
//----------------------------------------------------------------------------
//
//   ila_adc
//   校准前code码
//----------------------------------------------------------------------------
    wire                            w_ck_ila_adc        ;
    wire               [  15: 0]    w_p0_ila_adc        ;
    wire               [  15: 0]    w_p1_ila_adc        ;
    wire               [  15: 0]    w_p2_ila_adc        ;
    wire               [  15: 0]    w_p3_ila_adc        ;
    wire               [  15: 0]    w_p4_ila_adc        ;
    wire               [  15: 0]    w_p5_ila_adc        ;
    wire               [  15: 0]    w_p6_ila_adc        ;
    wire               [  15: 0]    w_p7_ila_adc        ;
    assign                          w_ck_ila_adc       = i_clk;
    assign                          w_p0_ila_adc       = w_HI_sum;
    assign                          w_p1_ila_adc       = w_LI_sum;
    assign                          w_p2_ila_adc       = w_HI_board;
    assign                          w_p3_ila_adc       = w_LI_board;
    assign                          w_p4_ila_adc       = w_U_mod;
    assign                          w_p5_ila_adc       = w_U_sense;
    assign                          w_p6_ila_adc       = w_I_sum_unit;
    assign                          w_p7_ila_adc       = w_I_board_unit;
ila_adc U_ila_adc
(
    .clk                            (w_ck_ila_adc       ) // input wire clk
    ,.probe0        ( w_p0_ila_adc   )                              // input wire [15:0]  probe0  
    ,.probe1        ( w_p1_ila_adc   )                              // input wire [15:0]  probe1 
    ,.probe2        ( w_p2_ila_adc   )                              // input wire [15:0]  probe2 
    ,.probe3        ( w_p3_ila_adc   )                              // input wire [15:0]  probe3 
    ,.probe4        ( w_p4_ila_adc   )                              // input wire [15:0]  probe4 
    ,.probe5        ( w_p5_ila_adc   )                              // input wire [15:0]  probe5 
    ,.probe6        ( w_p6_ila_adc   )                              // input wire [15:0]  probe6 
    ,.probe7        ( w_p7_ila_adc   )                              // input wire [15:0]  probe7
);  */
//----------------------------------------------------------------------------
//
//   ila_iv
//   校准后电流电压值
//----------------------------------------------------------------------------
//     wire                            w_ck_ila_iv         ;
//     wire               [  23: 0]    w_p0_ila_iv         ;
//     wire               [  23: 0]    w_p1_ila_iv         ;
//     wire               [  23: 0]    w_p2_ila_iv         ;
//     wire               [  23: 0]    w_p3_ila_iv         ;
//     wire               [  23: 0]    w_p4_ila_iv         ;
//     wire               [  23: 0]    w_p5_ila_iv         ;
//     wire               [  23: 0]    w_p6_ila_iv         ;
//     wire               [  23: 0]    w_p7_ila_iv         ;
//     wire               [  23: 0]    w_p8_ila_iv         ;
//     wire               [  23: 0]    w_p9_ila_iv         ;
//     assign                          w_ck_ila_iv        = i_clk;
//     assign                          w_p0_ila_iv        = w_cut_I_board_unit;
//     assign                          w_p1_ila_iv        = w_cut_I_sum_unit;
//     assign                          w_p2_ila_iv        = w_cut_U_sense;
//     assign                          w_p3_ila_iv        = w_cut_U_mod;
//     assign                          w_p4_ila_iv        = w_cut_LI_board;
//     assign                          w_p5_ila_iv        = w_cut_HI_board;
//     assign                          w_p6_ila_iv        = w_cut_LI_sum;
//     assign                          w_p7_ila_iv        = w_cut_HI_sum;
//     assign                          w_p8_ila_iv        = w_cut_LU_sense;
//     assign                          w_p9_ila_iv        = w_cut_LU_mod;
// ila_iv U_ila_iv
// (
//     .clk                            (w_ck_ila_iv        ) // input wire clk
//     ,.probe0        ( w_p0_ila_iv   )                               // input wire [23:0]  probe0  
//     ,.probe1        ( w_p1_ila_iv   )                               // input wire [23:0]  probe1 
//     ,.probe2        ( w_p2_ila_iv   )                               // input wire [23:0]  probe2 
//     ,.probe3        ( w_p3_ila_iv   )                               // input wire [23:0]  probe3 
//     ,.probe4        ( w_p4_ila_iv   )                               // input wire [23:0]  probe4 
//     ,.probe5        ( w_p5_ila_iv   )                               // input wire [23:0]  probe5 
//     ,.probe6        ( w_p6_ila_iv   )                               // input wire [23:0]  probe6 
//     ,.probe7        ( w_p7_ila_iv   )                               // input wire [23:0]  probe7
//     ,.probe8        ( w_p8_ila_iv   )                               // input wire [23:0]  probe7
//     ,.probe9        ( w_p9_ila_iv   )                               // input wire [23:0]  probe7
// );

//根据机型得到最大电压电流功率限制
    wire                            unsigned            [15:0]w_model;//机型型号//reg0004
    wire                            unsigned            [23:0]w_maxI_limit;//mA//MAX=600000  //21bit
    wire                            unsigned            [23:0]w_maxU_limit;//mV//MAX=1200000 //22bit
    wire                            unsigned            [31:0]w_maxP_limit;//mW = w_U_I_used / 1000
    wire                            unsigned            [31:0]w_maxR_limit;//O*10**-4 //32bit

    wire                            w_SENSE_ON          ;//1:SENSE 0:MODE        //reg0003
    wire                            w_Vgear_L_ON        ;//1:L 0:H //Manual ctrl //reg002F
    wire                            w_Cgear_L_ON        ;//1:L 0:H 

    wire               [  23: 0]    w_detectsense_threshold  ;

    assign                          w_model            = {w_reg0004out[15:0]};
Max_U_I_P U_max_u_i_p_r (.i_clk(i_clk),.i_model(w_model),.o_maxI(w_maxI_limit),.o_maxU(w_maxU_limit),.o_maxP(w_maxP_limit),.o_maxR(w_maxR_limit));

    assign                          w_SENSE_ON         = w_reg0003out[15:0] == 16'hA5A5 ? 1'B1 : 1'B0;//SENSE功能
    assign                          w_Vgear_L_ON       = w_reg002fout[15:0] == 16'hA5A5 ? 1'B1 : 1'B0;//电压测量档位-低档

    localparam                      U_WATERSHED        = 24'H0186A0;//电压档位分水岭//100V=100000mV
    localparam                      I_WATERSHED        = 24'H004E20;//电流档位分水岭//20A=20000mA
				                                   
    wire                            w_enb_sample_used   ;
    wire                            w_enb_U_used        ;
    wire                            w_enb_I_used        ;
    wire                            w_enb_P_used        ;
    wire                            w_enb_R_used        ;
    wire     signed    [  23: 0]    w_I_used            ;//mA//MAX=600000  //21bit
    wire     signed    [  23: 0]    w_U_used            ;//mV//MAX=1200000 //22bit
    wire                            unsigned            [31:0]w_P_used;//mW = w_U_I_used / 1000
    wire                            unsigned            [31:0]w_R_used;//Ohm*10**-4 //32bit
    wire               [  23: 0]    w_vldI_used         ;//mA//MAX=600000  //21bit
    wire               [  23: 0]    w_vldU_used         ;//mV//MAX=1200000 //22bit
    wire               [  31: 0]    w_vldP_used         ;//mW = w_U_I_used / 1000
    wire               [  31: 0]    w_vldR_used         ;//Ohm*10**-4 //32bit
    wire                            w_igear_l_sw        ;//当前电流低档位
    wire                            w_vgear_l_sw        ;//当前电压低档位

Generate_vld_UIPR U_Generate_vld_UIPR
(
    .i_clk                          (i_clk              ),
											      
    .i_I                            (w_I_used           ),
    .i_U                            (w_U_used           ),
    .i_P                            (w_P_used           ),
    .i_R                            (w_R_used           ),
    
    .o_vldI                         (w_vldI_used        ),
    .o_vldU                         (w_vldU_used        ),
    .o_vldP                         (w_vldP_used        ),
    .o_vldR                         (w_vldR_used        ) 
);
Generate_U_I #(.U_WATERSHED(U_WATERSHED),.I_WATERSHED(I_WATERSHED)) U_Generate_U_I
(
    .i_clk                          (i_clk              ),
    .i_sense_on                     (w_SENSE_ON         ),
    .i_vgear_l                      (w_Vgear_L_ON       ),
    .i_cgear_l                      (w_Cgear_L_ON       ),
	
    .i_abs_LU_mod                   (w_abs_LU_mod       ),
    .i_abs_LU_sense                 (w_abs_LU_sense     ),
    .i_abs_HU_mod                   (w_abs_U_mod        ),
    .i_abs_HU_sense                 (w_abs_U_sense      ),
    .i_abs_LI                       (w_abs_LI_board     ),//w_abs_LI_sum 可以选择是sum电压，还是board电压，现在写死
    .i_abs_HI                       (w_abs_HI_board     ),//w_abs_HI_sum 可以选择是sum电压，还是board电压，现在写死
							        
    .i_LU_mod                       (w_cut_LU_mod       ),
    .i_LU_sense                     (w_cut_LU_sense     ),
    .i_HU_mod                       (w_cut_U_mod        ),
    .i_HU_sense                     (w_cut_U_sense      ),
    .i_LI                           (w_cut_LI_board     ),//w_cut_LI_sum 可以选择是sum电压，还是board电压，现在写死
    .i_HI                           (w_cut_HI_board     ),//w_cut_HI_sum 可以选择是sum电压，还是board电压，现在写死
	
    .i_maxU                         (w_maxU_limit       ),
    .i_maxI                         (w_maxI_limit       ),
    .o_U                            (w_U_used           ),
    .o_I                            (w_I_used           ),
	
    .o_igear_l_sw                   (w_igear_l_sw       ),
    .o_vgear_l_sw                   (w_vgear_l_sw       ),
    .o_sense_sw                     (o_vin_select       ),//1:sense 0:vmod
    .o_vsense_l_sw                  (o_vsense_l_sw      ),//1:sense_low 0:sense_high
    .o_vmod_l_sw                    (o_vmod_l_sw        ) //1:mod_low 0:mod_high
);
//P : delay 52 
//R : delay 28
Generate_P_R U_generate_P_R
(
    .i_clk                          (i_clk              ),//input   	
    .i_U                            (w_U_used           ),//input       signed      [23:0]
    .i_I                            (w_I_used           ),//input       signed      [23:0]
	
    .i_maxP                         (w_maxP_limit       ),//input                   [31:0]
    .i_maxR                         (w_maxR_limit       ),//input                   [31:0]
    .o_P                            (w_P_used           ),//output      unsigned    [31:0]
    .o_R                            (w_R_used           ) //output      unsigned    [31:0]
);

trig_dly #(.DLY_CKNUM (99)) U_sample_vld_out (.i_clk(i_clk),.i_trig(w_vld_adc),.o_trig(w_enb_sample_used));
trig_dly #(.DLY_CKNUM (8) ) U_U_used_dly_out (.i_clk(i_clk),.i_trig(w_vld_adc),.o_trig(w_enb_U_used));
trig_dly #(.DLY_CKNUM (8) ) U_I_used_dly_out (.i_clk(i_clk),.i_trig(w_vld_adc),.o_trig(w_enb_I_used));
trig_dly #(.DLY_CKNUM (64)) U_P_used_dly_out (.i_clk(i_clk),.i_trig(w_vld_adc),.o_trig(w_enb_P_used));
trig_dly #(.DLY_CKNUM (36)) U_R_used_dly_out (.i_clk(i_clk),.i_trig(w_vld_adc),.o_trig(w_enb_R_used));
//---------------------------------------------------------------------------------
// 20us平均值40us平均值
//---------------------------------------------------------------------------------
    wire               [  23: 0]    w_I_avg_20us        ;
    wire               [  23: 0]    w_U_avg_20us        ;
    wire               [  31: 0]    w_P_avg_20us        ;
    wire               [  31: 0]    w_R_avg_20us        ;
    wire               [  23: 0]    w_I_avg_40us        ;
    wire               [  23: 0]    w_U_avg_40us        ;
    wire               [  31: 0]    w_P_avg_40us        ;
    wire               [  31: 0]    w_R_avg_40us        ;
    wire               [  23: 0]    w_I_avg_80us        ;
    wire               [  23: 0]    w_U_avg_80us        ;
    wire               [  31: 0]    w_P_avg_80us        ;
    wire               [  31: 0]    w_R_avg_80us        ;

Volt_Curr_Avg_wrapper U_Volt_Curr_Avg_wrapper
(
    .i_clk                          (i_clk              ),//input        
    .i_rst                          (i_rst              ),//input        
													            
    .i_vld_rt                       (w_enb_sample_used  ),//input        
    .i_I_rt                         (w_I_used           ),//input  [23:0]
    .i_U_rt                         (w_U_used           ),//input  [23:0]
    .i_P_rt                         (w_P_used           ),//input  [31:0]
    .i_R_rt                         (w_R_used           ),//input  [31:0]
															    
    .o_I_avg_20us                   (w_I_avg_20us       ),//output [23:0]
    .o_U_avg_20us                   (w_U_avg_20us       ),//output [23:0]
    .o_P_avg_20us                   (w_P_avg_20us       ),//output [31:0]
    .o_R_avg_20us                   (w_R_avg_20us       ),//output [31:0]
    .o_I_avg_40us                   (w_I_avg_40us       ),//output [23:0]
    .o_U_avg_40us                   (w_U_avg_40us       ),//output [23:0]
    .o_P_avg_40us                   (w_P_avg_40us       ),//output [31:0]
    .o_R_avg_40us                   (w_R_avg_40us       ),//output [31:0]
    .o_I_avg_80us                   (w_I_avg_80us       ),//output [23:0]
    .o_U_avg_80us                   (w_U_avg_80us       ),//output [23:0]
    .o_P_avg_80us                   (w_P_avg_80us       ),//output [31:0]
    .o_R_avg_80us                   (w_R_avg_80us       ) //output [31:0]
);
//---------------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------------
    wire               [   3: 0]    w_avg_num           ;//reg0033
    wire               [  23: 0]    w_U_avg_CPR         ;//按平均个数输出电压平均值给到CR模式 

    assign                          w_avg_num          = {w_reg0033out[3:0]};
//滑动窗口平均窗口为2**N(Nmax=8)
// Avg_X_slide #(.D_WIDTH(24))  U_Avg_U
Avg_X #(.D_WIDTH(24))  U_Avg_U
(
    .i_clk                          (i_clk              ),//input        
    .i_rst                          (i_rst              ),//input        
    .i_xen                          (w_enb_U_used       ),//input        
    .i_X                            (w_U_avg_20us /* w_U_used */),//input  [23:0]
    .i_avg_num                      (w_avg_num          ),//input  [ 3:0] 
    .o_xen                          (                   ),//output       
    .o_X                            (w_U_avg_CPR        ) //output [23:0]
);
//---------------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------------
    wire                            w_BATT_cpl          ;
    wire                            w_TOCP_cpl          ;
    wire                            w_TOPP_cpl          ;
    wire                            w_LIST_cpl          ;
//---------------------------------------------------------------------------------
//
//
//
//---------------------------------------------------------------------------------
    wire                            w_workmode_CC     ,w_workmode_CV,w_workmode_CP, w_workmode_CR ;//reg0001
    wire                            w_func_STA        ,w_func_DYN,w_func_RIP, w_func_RE , w_func_FE , w_func_BAT_N , w_func_BAT_P , w_func_LIST , w_func_TOCP , w_func_TOPP ;//reg0002
    wire                            w_clr_Alarm         ;//reg0007
(*mark_debug = "true"*)    wire                            w_flag_STOP       ,w_flag_RUN;//reg0008
    wire                            w_flag_Short        ;//reg0009
    wire                            w_Von_Latch_ON    ,w_Von_Latch_OFF;//reg000F
    wire                            w_trigmode_DYN_C  ,w_trigmode_DYN_P,w_trigmode_DYN_T;//reg0090
//连续触发模式:在目标值A和B之间不停切换,目标值A的持续时间为T1,目标值B的持续时间为T2
//脉冲触发模式:默认工作在目标值A,触发一次,切换到目标值B并持续时间T2,然后恢复到目标值A,忽略T1的设置
//翻转触发模式:默认工作在目标值A,触发一次,切换到目标值B,触发一次,切换到目标值A,如此反复触发翻转,忽略T1/T2的设置
    wire                            w_trigsource_DYN_N,w_trigsource_DYN_M,w_trigsource_DYN_B,w_trigsource_DYN_O  ;//reg0091
//无触发(针对连续触发模式)//手动触发//总线触发//外部触发
    wire                            w_triggen_DYN       ;//reg0092
//MCU通过写FPGA的此寄存器来告知FPGA产生了一次触发,MCU接受到触发信号后,通过写0x092为0xa5a5,2us后复位为0x0000,来告知FPGA产生了一次触发,FPGA按照规则完成相应的触发模式
//电池放电测试
    wire                            w_BT_Stop_U       ,w_BT_Stop_T,w_BT_Stop_C;//reg00B1
//电压截止,时间截止,容量截止
    assign                          w_workmode_CC      = w_reg0001out[15:0] == 16'h5a5a ? 1'b1 : 1'b0;//Workmod
    assign                          w_workmode_CV      = w_reg0001out[15:0] == 16'ha5a5 ? 1'b1 : 1'b0;//Workmod
    assign                          w_workmode_CP      = w_reg0001out[15:0] == 16'h5a00 ? 1'b1 : 1'b0;//Workmod
    assign                          w_workmode_CR      = w_reg0001out[15:0] == 16'h005a ? 1'b1 : 1'b0;//Workmod
    assign                          w_func_STA         = w_reg0002out[15:0] == 16'h5a00 ? 1'b1 : 1'b0;//Func
    assign                          w_func_DYN         = w_reg0002out[15:0] == 16'ha500 ? 1'b1 : 1'b0;//Func
// assign  w_func_RIP         = 1'b0 ; // 2024.11.25.11:43 修改为0，防止误操作
    assign                          w_func_RIP         = w_reg0002out[15:0] == 16'h5a0F ? 1'b1 : 1'b0;//由5aff改成5a0f，防止误操作
    assign                          w_func_RE          = w_reg0002out[15:0] == 16'h5ae0 ? 1'b1 : 1'b0;//
    assign                          w_func_FE          = w_reg0002out[15:0] == 16'h5aef ? 1'b1 : 1'b0;//
    assign                          w_func_BAT_N       = w_reg0002out[15:0] == 16'h5ab0 ? 1'b1 : 1'b0;//Func
    assign                          w_func_BAT_P       = w_reg0002out[15:0] == 16'h5abf ? 1'b1 : 1'b0;//
    assign                          w_func_LIST        = w_reg0002out[15:0] == 16'h5aff ? 1'b1 : 1'b0;//Func
    assign                          w_func_TOCP        = w_reg0002out[15:0] == 16'h5a3c ? 1'b1 : 1'b0;//Func
    assign                          w_func_TOPP        = w_reg0002out[15:0] == 16'h5ac3 ? 1'b1 : 1'b0;//Func
    assign                          w_clr_Alarm        = w_reg0007out[15:0] == 16'h5a5a ? 1'b1 : 1'b0;//清除保护告警
    assign                          w_flag_STOP        = w_reg0008out[15:0] == 16'ha5a5 ? 1'b1 : 1'b0;//停止
    assign                          w_flag_RUN         = w_reg0008out[15:0] == 16'h5a5a ? 1'b1 : 1'b0;//运行
    assign                          w_flag_Short       = w_reg0009out[15:0] == 16'h5a5a ? 1'b1 : 1'b0;//短路测试
    assign                          w_Von_Latch_ON     = w_reg000fout[15:0] == 16'h5a5a ? 1'b1 : 1'b0;//Latch ON
    assign                          w_Von_Latch_OFF    = w_reg000fout[15:0] == 16'ha5a5 ? 1'b1 : 1'b0;//Latch OFF
    assign                          w_trigmode_DYN_C   = w_reg0090out[15:0] == 16'h5a5a ? 1'b1 : 1'b0;//连续触发
    assign                          w_trigmode_DYN_P   = w_reg0090out[15:0] == 16'ha5a5 ? 1'b1 : 1'b0;//脉冲触发
    assign                          w_trigmode_DYN_T   = w_reg0090out[15:0] == 16'h5aa5 ? 1'b1 : 1'b0;//翻转触发
    assign                          w_trigsource_DYN_N = w_reg0091out[15:0] == 16'h0000 ? 1'b1 : 1'b0;//无触发(针对连续触发模式)
    assign                          w_trigsource_DYN_M = w_reg0091out[15:0] == 16'h0001 ? 1'b1 : 1'b0;//手动触发
    assign                          w_trigsource_DYN_B = w_reg0091out[15:0] == 16'h0002 ? 1'b1 : 1'b0;//总线触发
    assign                          w_trigsource_DYN_O = w_reg0091out[15:0] == 16'h0003 ? 1'b1 : 1'b0;//外部触发
    assign                          w_triggen_DYN      = w_reg0092out[15:0] == 16'ha5a5 ? 1'b1 : 1'b0;//触发
    assign                          w_BT_Stop_U        = w_reg00b1out[15:0] == 16'h0000 ? 1'b1 : 1'b0;//电压截止
    assign                          w_BT_Stop_T        = w_reg00b1out[15:0] == 16'h5a5a ? 1'b1 : 1'b0;//时间截止
    assign                          w_BT_Stop_C        = w_reg00b1out[15:0] == 16'ha5a5 ? 1'b1 : 1'b0;//容量截止
//---------------------------------------------------------------------------------
// 并机,主从机
//---------------------------------------------------------------------------------
    wire                            w_worktype_Single ,w_worktype_Multi;//reg0005
    wire                            w_ms_Master       ,w_ms_Slave;//reg0006
    wire               [  15: 0]    w_parallel_num      ;//reg0040 并机数,默认1台
    wire                            w_trig_extend       ;//触发信号延展到1us

    assign                          w_worktype_Single  = w_reg0005out[15:0] == 16'h5a5a ? 1'b1 : 1'b0;//单机
    assign                          w_worktype_Multi   = w_reg0005out[15:0] == 16'ha5a5 ? 1'b1 : 1'b0;//多机
    assign                          w_ms_Master        = w_reg0006out[15:0] == 16'h5a5a ? 1'b1 : 1'b0;//主机
    assign                          w_ms_Slave         = w_reg0006out[15:0] == 16'ha5a5 ? 1'b1 : 1'b0;//从机
    assign                          w_parallel_num     = {w_reg0040out[15:0]};//并机数

Sig_delay U_trig_extension (.i_clk(i_clk),.i_sig(w_triggen_DYN),.o_sig(w_trig_extend));
    assign                          io_trig1           = w_worktype_Single ? 1'bz : w_ms_Master ? ~i_mcu_syn    : 1'bz;
    assign                          io_trig2           = w_worktype_Single ? 1'bz : w_ms_Master ? w_trig_extend : 1'bz;
    assign                          o_m_s              = w_worktype_Single ? 1'b1 : w_ms_Master;
    assign                          o_p_sw1            = w_worktype_Single ? 1'b0 : w_ms_Master ? 1'b0 : 1'b1;
    assign                          o_p_sw2            = w_worktype_Single ? 1'b0 : w_ms_Master ? 1'b1 : 1'b1;
//---------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------
    wire               [  31: 0]    w_setI_limit        ;//mA 限流保护值     //reg0041/reg0042 
    wire               [  31: 0]    w_setU_limit        ;//mV 限压保护值     //reg0043/reg0044 
    wire               [  31: 0]    w_setP_limit        ;//mW 限功率保护值   //reg0045/reg0046 
    wire               [  31: 0]    w_setI_limit_CV     ;//mA CV模式下限流值 //reg0047/reg0048 

    assign                          w_setI_limit       = {w_reg0042out[15:0],w_reg0041out[15:0]};
    assign                          w_setU_limit       = {w_reg0044out[15:0],w_reg0043out[15:0]};
    assign                          w_setP_limit       = {w_reg0046out[15:0],w_reg0045out[15:0]};
    assign                          w_setI_limit_CV    = {w_reg0048out[15:0],w_reg0047out[15:0]};

    wire               [  23: 0]    w_I_short           ;//mA 短路时的拉载电流
    wire               [  23: 0]    w_shortI_1R03       ;//mA 短路时的拉载电流
//MIN {w_setP_limit/U , w_maxI_limit}
Gen_limitI_short U_Gen_limitI_short
(
    .i_clk                          (i_clk              ),
    .i_U                            (w_U_avg_40us/* w_U_used */),
    .i_maxI                         (w_maxI_limit       ),
    .i_maxP                         (w_maxP_limit       ),
    .i_limitI                       (w_setI_limit       ),
    .i_limitP                       (w_setP_limit       ),
    .o_shortI                       (w_I_short          ) 
);
X_1R03 #(.D_WIDTH(24)) U_shortI_1R03(.i_clk(i_clk),.i_xen(1),.i_X(w_I_short),.o_X_1R03en(),.o_X_1R03(w_shortI_1R03));


    wire               [  15: 0]    w_proT              ;//mS*10**-1 保护时长设置 //reg0049 //1-立即保护 10-1mS 20-2mS ... 150-15mS
//控制逻辑:拉载电流超过I_lim持续达Pro_time时间,将产生OCP报警,并停止拉载
//控制逻辑:拉载功率超过P_lim持续达Pro_time时间,将产生OPP报警,并停止拉载
    assign                          w_proT             = {w_reg0049out[15:0]};
//---------------------------------------------------------------------------------
// CV模式 PI算法参数
//---------------------------------------------------------------------------------
    wire                            w_speed_slow_CV     ;//CV模式速度调节,0x0003-慢速(默认) //reg0030
    wire                            w_speed_mid_CV      ;//CV模式速度调节,0x0002-中速 //reg0030
    wire                            w_speed_fast_CV     ;//CV模式速度调节,0x0001-快速 //reg0030
    wire               [  23: 0]    w_slew_CV           ;//CV模式电压变化斜率(1mV/us) //reg0031
    wire                            w_hard_CV_ON        ;//0:软件CV 1:硬件CV //reg0071
    reg                             s_hardCV_1r       =0;//
    reg                             s_hardCV_2r       =0;//


    reg                [   3: 0]    CurWorkMode       =0;
    reg                [   3: 0]    OldWorkMode       =0;
    wire                            w_modechange        ;

    assign                          w_modechange       = |(CurWorkMode ^ OldWorkMode);//工作类型变化//针对静态/动态/List
always @ (posedge i_clk)
begin
    CurWorkMode <= {w_workmode_CV,w_workmode_CR,w_workmode_CP,w_workmode_CC};
    OldWorkMode <= CurWorkMode ;
end

    reg                             s_hardCV_sel_temp   ;
    reg                             s_hardCV_limitsel_temp  ;
    reg                             s_hardCV_speedslow_temp  ;
    reg                             s_hardCV_speedmid_temp  ;
    reg                             s_hardCV_speedfast_temp  ;
    reg                [  31: 0]    s_cnt_dly_hardCV_sel=0  ;
    reg                             s_sw_temp         =0;


//软件CV：0x0001-快速;0x0002-中速;0x0003-慢速
//硬件CV：0x0001-快速;0x0002-中速(实际慢速);0x0003-慢速
    assign                          w_speed_slow_CV    = w_reg0030out[15:0] == 16'h0003 ? 1'b1 : 1'b0;
    assign                          w_speed_mid_CV     = w_reg0030out[15:0] == 16'h0002 ? 1'b1 : 1'b0;
    assign                          w_speed_fast_CV    = w_reg0030out[15:0] == 16'h0001 ? 1'b1 : 1'b0;
    assign                          w_slew_CV          = (|w_reg0031out[23:0]) ? {w_reg0031out[23:0]} : 'h1;//至少1mV/us
    assign                          w_hard_CV_ON       = w_reg0071out[0] == 1'b1 ? 1'b1 : 1'b0;
//将寄存器值转为光耦开关控制量
    assign                          o_cc_cv_select     = ((CurWorkMode[3] == 1) && (s_hardCV_sel_temp == 1)) ? 1'b0 : 1'b1;//CELL_PROG_DA/CV_Hardware_LOOP
    assign                          o_cv_limit_select  = ((CurWorkMode[3] == 1) && (s_hardCV_sel_temp == 1)) ? ~i_cv_limit_trig : 1'b0;//CV_Lim_DA/CV_lim_PROG
    assign                          o_cv_slow          = ~s_hardCV_speedslow_temp;//互斥关系
    assign                          o_cv_mid           = ~s_hardCV_speedmid_temp;//互斥关系
    assign                          o_cv_fast          = ~s_hardCV_speedfast_temp;//互斥关系

// assign  o_sw =  i_rst == 1'b1 ? 1'b0 : w_off_err == 1'b1 ? 1'b0 : 1'b1 ;//打开:MOS管电路为闭环//关闭:MOS管电路为开环
    assign                          o_sw               = s_sw_temp;//打开:MOS管电路为闭环//关闭:MOS管电路为开环
//---------------------------------------------------------------------------------
// CV模式 PID系数
//---------------------------------------------------------------------------------
    wire               [  15: 0]    w_slowKP_CV         ;//软件CV慢速档PI控制的比例参数 //reg006B
    wire               [  15: 0]    w_slowKI_CV         ;//软件CV慢速档PI控制的积分参数 //reg006C
    wire               [  15: 0]    w_midKP_CV          ;//软件CV中速档PI控制的比例参数 //reg006D
    wire               [  15: 0]    w_midKI_CV          ;//软件CV中速档PI控制的积分参数 //reg006E
    wire               [  15: 0]    w_fastKP_CV         ;//软件CV快速档PI控制的比例参数 //reg006F
    wire               [  15: 0]    w_fastKI_CV         ;//软件CV快速档PI控制的积分参数 //reg0070
    wire               [  15: 0]    w_KP_PID_CV         ;//PI控制的比例参数
    wire               [  15: 0]    w_KI_PID_CV         ;//PI控制的积分参数

    assign                          w_slowKP_CV        = {w_reg006bout[15:0]};
    assign                          w_slowKI_CV        = {w_reg006cout[15:0]};
    assign                          w_midKP_CV         = {w_reg006dout[15:0]};
    assign                          w_midKI_CV         = {w_reg006eout[15:0]};
    assign                          w_fastKP_CV        = {w_reg006fout[15:0]};
    assign                          w_fastKI_CV        = {w_reg0070out[15:0]};
    assign                          w_KP_PID_CV        = w_speed_fast_CV ? w_fastKP_CV : w_speed_mid_CV ? w_midKP_CV : w_slowKP_CV;
    assign                          w_KI_PID_CV        = w_speed_fast_CV ? w_fastKI_CV : w_speed_mid_CV ? w_midKI_CV : w_slowKI_CV;
//---------------------------------------------------------------------------------
// 硬件CV模式参数 DAC输出校准 校准后为CODE
//---------------------------------------------------------------------------------
    wire               [  15: 0]    w_highK_mod_CV    ,w_highB_mod_CV;//CV模式高档校准 //reg0063/reg0064
    wire               [  15: 0]    w_lowK_mod_CV     ,w_lowB_mod_CV;//CV模式低档校准 //reg0065/reg0066
    wire               [  15: 0]    w_highK_sense_CV  ,w_highB_sense_CV;//CV模式sense高档校准 //reg0067/reg0068
    wire               [  15: 0]    w_lowK_sense_CV   ,w_lowB_sense_CV;//CV模式sense低档校准 //reg0069/reg006A
    wire               [  15: 0]    w_K_cali_CV       ,w_B_cali_CV;//CV模式校准参数

    assign                          w_highK_mod_CV     = {w_reg0063out[15:0]};//'d55277
    assign                          w_highB_mod_CV     = {w_reg0064out[15:0]};//'h0000 
    assign                          w_lowK_mod_CV      = {w_reg0065out[15:0]};
    assign                          w_lowB_mod_CV      = {w_reg0066out[15:0]};
    assign                          w_highK_sense_CV   = {w_reg0067out[15:0]};
    assign                          w_highB_sense_CV   = {w_reg0068out[15:0]};
    assign                          w_lowK_sense_CV    = {w_reg0069out[15:0]};
    assign                          w_lowB_sense_CV    = {w_reg006aout[15:0]};
assign  w_K_cali_CV =  (w_SENSE_ON == 0 && w_Vgear_L_ON == 0) ? w_highK_mod_CV :
                       (w_SENSE_ON == 0 && w_Vgear_L_ON == 1) ? w_lowK_mod_CV  :
                       (w_SENSE_ON == 1 && w_Vgear_L_ON == 0) ? w_highK_sense_CV  : w_lowK_sense_CV ;
assign  w_B_cali_CV =  (w_SENSE_ON == 0 && w_Vgear_L_ON == 0) ? w_highB_mod_CV :
                       (w_SENSE_ON == 0 && w_Vgear_L_ON == 1) ? w_lowB_mod_CV  :
                       (w_SENSE_ON == 1 && w_Vgear_L_ON == 0) ? w_highB_sense_CV  : w_lowB_sense_CV ;
//---------------------------------------------------------------------------------
// 启动电压/停止电压设置
//---------------------------------------------------------------------------------
    wire               [  15: 0]    w_start_Volt        ;//reg000A 启动电压
    wire               [  15: 0]    w_stop_Volt         ;//reg0010 停止电压,仅在Von Latch是OFF状态时有效

    assign                          w_start_Volt       = {w_reg000aout[15:0]};//Von
    assign                          w_stop_Volt        = {w_reg0010out[15:0]};//Voff
//---------------------------------------------------------------------------------
// 静态模式参数设置
//---------------------------------------------------------------------------------
    wire               [  23: 0]    w_slew_CR_STA       ;//reg000B 静态模式下,电流上升斜率
    wire               [  23: 0]    w_slew_CF_STA       ;//reg000C 静态模式下,电流下降斜率
    wire               [  31: 0]    w_Iset_STA          ;//reg0011/reg0012
    wire               [  31: 0]    w_Uset_STA          ;//reg0013/reg0014
    wire               [  31: 0]    w_Pset_STA          ;//reg0015/reg0016
    wire               [  31: 0]    w_Rset_STA          ;//reg0017/reg0018

    assign                          w_slew_CR_STA      = (|w_reg000bout[23:0]) ? {w_reg000bout[23:0]} : 'h1;//SR_slew 至少为1mA/us
    assign                          w_slew_CF_STA      = (|w_reg000cout[23:0]) ? {w_reg000cout[23:0]} : 'h1;//SF_slew 至少为1mA/us
    assign                          w_Iset_STA         = {w_reg0012out[15:0],w_reg0011out[15:0]};//Iset
    assign                          w_Uset_STA         = {w_reg0014out[15:0],w_reg0013out[15:0]};//Vset
    assign                          w_Pset_STA         = {w_reg0016out[15:0],w_reg0015out[15:0]};//Pset
    assign                          w_Rset_STA         = {w_reg0018out[15:0],w_reg0017out[15:0]};//Rset
//---------------------------------------------------------------------------------
// 动态模式参数设置
//---------------------------------------------------------------------------------
    wire               [  23: 0]    w_slew_CR_DYN       ;//reg002D 动态模式下,电流上升斜率(1mA/us)
    wire               [  23: 0]    w_slew_CF_DYN       ;//reg002E 动态模式下,电流下降斜率(1mA/us)
    wire               [  31: 0]    w_I1set_DYN       ,w_I2set_DYN;//reg0019/reg001A/reg001B/reg001C
    wire               [  31: 0]    w_U1set_DYN       ,w_U2set_DYN;//reg001D/reg001E/reg001F/reg0020
    wire               [  31: 0]    w_P1set_DYN       ,w_P2set_DYN;//reg0021/reg0022/reg0023/reg0024
    wire               [  31: 0]    w_R1set_DYN       ,w_R2set_DYN;//reg0025/reg0026/reg0027/reg0028
    wire               [  31: 0]    w_T1set_CC_DYN    ,w_T2set_CC_DYN;//mS//reg0080/reg0081/reg0082/reg0083
    wire               [  31: 0]    w_T1set_CV_DYN    ,w_T2set_CV_DYN;//mS//reg0084/reg0085/reg0086/reg0087
    wire               [  31: 0]    w_T1set_CP_DYN    ,w_T2set_CP_DYN;//mS//reg0088/reg0089/reg008A/reg008B
    wire               [  31: 0]    w_T1set_CR_DYN    ,w_T2set_CR_DYN;//mS//reg008C/reg008D/reg008E/reg008F

    assign                          w_slew_CR_DYN      = (|w_reg002dout[23:0]) ? {w_reg002dout[23:0]} : 'h1;//SR_slew 至少为1mA/us
    assign                          w_slew_CF_DYN      = (|w_reg002eout[23:0]) ? {w_reg002eout[23:0]} : 'h1;//SF_slew 至少为1mA/us
    assign                          w_I1set_DYN        = {w_reg001aout[15:0],w_reg0019out[15:0]};//I1set
    assign                          w_I2set_DYN        = {w_reg001cout[15:0],w_reg001bout[15:0]};//I2set
    assign                          w_U1set_DYN        = {w_reg001eout[15:0],w_reg001dout[15:0]};//U1set
    assign                          w_U2set_DYN        = {w_reg0020out[15:0],w_reg001fout[15:0]};//U2set
    assign                          w_P1set_DYN        = {w_reg0022out[15:0],w_reg0021out[15:0]};//P1set
    assign                          w_P2set_DYN        = {w_reg0024out[15:0],w_reg0023out[15:0]};//P2set
    assign                          w_R1set_DYN        = {w_reg0026out[15:0],w_reg0025out[15:0]};//R1set
    assign                          w_R2set_DYN        = {w_reg0028out[15:0],w_reg0027out[15:0]};//R2set
    assign                          w_T1set_CC_DYN     = {w_reg0081out[15:0],w_reg0080out[15:0]};//T1set
    assign                          w_T2set_CC_DYN     = {w_reg0083out[15:0],w_reg0082out[15:0]};//T2set
    assign                          w_T1set_CV_DYN     = {w_reg0085out[15:0],w_reg0084out[15:0]};//T1set
    assign                          w_T2set_CV_DYN     = {w_reg0087out[15:0],w_reg0086out[15:0]};//T2set
    assign                          w_T1set_CP_DYN     = {w_reg0089out[15:0],w_reg0088out[15:0]};//T1set
    assign                          w_T2set_CP_DYN     = {w_reg008bout[15:0],w_reg008aout[15:0]};//T2set
    assign                          w_T1set_CR_DYN     = {w_reg008dout[15:0],w_reg008cout[15:0]};//T1set
    assign                          w_T2set_CR_DYN     = {w_reg008fout[15:0],w_reg008eout[15:0]};//T2set
//---------------------------------------------------------------------------------
// 电池放电测试模式参数设置
//---------------------------------------------------------------------------------
    wire               [  31: 0]    w_offV_BT_Stop      ;//mV//reg00B3/reg00B4 放电截止电压
    wire               [  31: 0]    w_offT_BT_Stop      ;//S//reg00B5/reg00B6 放电截止时间
    wire               [  31: 0]    w_offC_BT_Stop      ;//mAh//reg00B7/reg00B8 放电截止容量
    wire               [  31: 0]    w_proV_BT_Stop      ;//mV//reg00B9/reg00BA 电池放电保护测试截止电压

    assign                          w_offV_BT_Stop     = {w_reg00b4out[15:0],w_reg00b3out[15:0]};//VB_stop
    assign                          w_offT_BT_Stop     = {w_reg00b6out[15:0],w_reg00b5out[15:0]};//TB_stop
    assign                          w_offC_BT_Stop     = {w_reg00b8out[15:0],w_reg00b7out[15:0]};//CB_stop
    assign                          w_proV_BT_Stop     = {w_reg00baout[15:0],w_reg00b9out[15:0]};//VB_pro
//---------------------------------------------------------------------------------
// TOCP测试模式参数设置
//---------------------------------------------------------------------------------
    wire               [  31: 0]    w_start_Volt_TOCP   ;//mV//reg00C0/reg00C1 OCP测试的启动电压值
    wire               [  31: 0]    w_start_Curr_TOCP   ;//mA//reg00C2/reg00C3 OCP测试的初始电流值
    wire               [  31: 0]    w_stop_Curr_TOCP    ;//mA//reg00C4/reg00C5 OCP测试的截止电流值
    wire               [  31: 0]    w_step_Curr_TOCP    ;//mA//reg00C6 OCP测试的步进电流值
    wire               [  31: 0]    w_step_Time_TOCP    ;//S//reg00C7 OCP测试的步进时间值
    wire               [  31: 0]    w_pro_Volt_TOCP     ;//mV//reg00C8/reg00C9 OCP测试的保护电压值
    wire               [  31: 0]    w_over_Curr_MIN_TOCP  ;//mA//reg00CA/reg00CB OCP测试的过电流最小值
    wire               [  31: 0]    w_over_Curr_MAX_TOCP  ;//mA//reg00CC/reg00CD OCP测试的过电流最大值
    wire                            w_pass_TOCP         ;
    wire                            w_fail_TOCP         ;
    wire               [  15: 0]    w_status_TOCP       ;
    wire               [  31: 0]    w_curTarget_TOCP    ;

    assign                          w_start_Volt_TOCP  = {w_reg00c1out[15:0],w_reg00c0out[15:0]};//TOCP_Von
    assign                          w_start_Curr_TOCP  = {w_reg00c3out[15:0],w_reg00c2out[15:0]};//TOCP_Istart
    assign                          w_stop_Curr_TOCP   = {w_reg00c5out[15:0],w_reg00c4out[15:0]};//TOCP_Icut
    assign                          w_step_Curr_TOCP   = {w_reg00c6out[31:0]};//TOCP_Istep
    assign                          w_step_Time_TOCP   = {w_reg00c7out[31:0]};//TOCP_Tstep
    assign                          w_pro_Volt_TOCP    = {w_reg00c9out[15:0],w_reg00c8out[15:0]};//TOCP_Vcut
    assign                          w_over_Curr_MIN_TOCP= {w_reg00cbout[15:0],w_reg00caout[15:0]};//TOCP_Imin
    assign                          w_over_Curr_MAX_TOCP= {w_reg00cdout[15:0],w_reg00ccout[15:0]};//TOCP_Imax
    assign                          w_reg00cein        = {w_curTarget_TOCP[15:0]};//TOCP_I
    assign                          w_reg00cfin        = {w_curTarget_TOCP[31:16]};//TOCP_I
//---------------------------------------------------------------------------------
// TOPP测试模式参数设置 ---- 存入buff
//---------------------------------------------------------------------------------
    wire               [  31: 0]    w_start_Volt_TOPP   ;//mV//reg00D0/reg00D1 OPP测试的启动电压值
    wire               [  31: 0]    w_start_Power_TOPP  ;//mW//reg00D2/reg00D3 OPP测试的初始功率值
    wire               [  31: 0]    w_stop_Power_TOPP   ;//mW//reg00D4/reg00D5 OPP测试的截止功率值
    wire               [  31: 0]    w_step_Power_TOPP   ;//mW//reg00D6 OPP测试的步进功率值
    wire               [  31: 0]    w_step_Time_TOPP    ;//S//reg00D7 OPP测试的步进时间值
    wire               [  31: 0]    w_pro_Volt_TOPP     ;//mV//reg00D8/reg00D9 OPP测试的保护电压值
    wire               [  31: 0]    w_over_Power_MIN_TOPP  ;//mW//reg00DA/reg00DB OPP测试的过功率最小值
    wire               [  31: 0]    w_over_Power_MAX_TOPP  ;//mW//reg00DC/reg00DD OPP测试的过功率最大值
    wire                            w_pass_TOPP         ;
    wire                            w_fail_TOPP         ;
    wire               [  15: 0]    w_status_TOPP       ;
    wire               [  31: 0]    w_curTarget_TOPP    ;

    assign                          w_start_Volt_TOPP  = {w_reg00d1out[15:0],w_reg00d0out[15:0]};//TOPP_Von
    assign                          w_start_Power_TOPP = {w_reg00d3out[15:0],w_reg00d2out[15:0]};//TOPP_Pstart
    assign                          w_stop_Power_TOPP  = {w_reg00d5out[15:0],w_reg00d4out[15:0]};//TOPP_Pcut
    assign                          w_step_Power_TOPP  = {w_reg00d6out[31:0]};//TOPP_Pstep
    assign                          w_step_Time_TOPP   = {w_reg00d7out[31:0]};//TOPP_Tstep
    assign                          w_pro_Volt_TOPP    = {w_reg00d9out[15:0],w_reg00d8out[15:0]};//TOPP_Vcut
    assign                          w_over_Power_MIN_TOPP= {w_reg00dbout[15:0],w_reg00daout[15:0]};//TOPP_Pmin
    assign                          w_over_Power_MAX_TOPP= {w_reg00ddout[15:0],w_reg00dcout[15:0]};//TOPP_Pmax
    assign                          w_reg00dein        = {w_curTarget_TOPP[15:0]};//TOPP_P
    assign                          w_reg00dfin        = {w_curTarget_TOPP[31:16]};//TOPP_P
//---------------------------------------------------------------------------------
// LIST序列模式参数设置
//---------------------------------------------------------------------------------
    wire               [  15: 0]    w_total_listnum     ;//reg00F1//1-1000,总步数
    wire               [  15: 0]    w_total_loopnum     ;//reg00F2//0-65535,总循环次数,0为无限循环
    wire               [  15: 0]    w_number_list       ;//reg00F3//1-1000,步数序列号
    wire               [  15: 0]    w_workmode_list     ;//reg00F4//工作模式
    wire                            w_workmode_CC_list,w_workmode_CV_list,w_workmode_CP_list,w_workmode_CR_list  ;//reg00F4
    wire               [  31: 0]    w_target_list       ;//reg00F5/reg00F6//拉载值
    wire               [  31: 0]    w_runtime_list      ;//uS//reg00F7/reg00F8//单步执行时间
    wire               [  15: 0]    w_repeat_list       ;//reg00F9//单步循环次数,1-65535
    wire               [  15: 0]    w_goto_list         ;//reg00FA//小循环跳转目的地,1-999,无效0xFFFF
    wire               [  15: 0]    w_loop_list         ;//reg00FB//小循环次数,1-65535
    wire                            w_enb_save_list     ;//reg00FC//平时0x0000,保存写一次0x5a5a

    assign                          w_total_listnum    = {w_reg00f1out[15:0]};//Stepnum
    assign                          w_total_loopnum    = {w_reg00f2out[15:0]};//Count
    assign                          w_number_list      = {w_reg00f3out[15:0]};//Step
    assign                          w_workmode_list    = {w_reg00f4out[15:0]};//Mode
    assign                          w_workmode_CC_list = w_workmode_list == 16'h5a5a ? 1'b1 : 1'b0;//Workmod
    assign                          w_workmode_CV_list = w_workmode_list == 16'ha5a5 ? 1'b1 : 1'b0;//Workmod
    assign                          w_workmode_CP_list = w_workmode_list == 16'h5a00 ? 1'b1 : 1'b0;//Workmod
    assign                          w_workmode_CR_list = w_workmode_list == 16'h005a ? 1'b1 : 1'b0;//Workmod
    assign                          w_target_list      = {w_reg00f6out[15:0],w_reg00f5out[15:0]};//Value
    assign                          w_runtime_list     = {w_reg00f8out[15:0],w_reg00f7out[15:0]};//Tstep
    assign                          w_repeat_list      = {w_reg00f9out[15:0]};//Repeat
    assign                          w_goto_list        = {w_reg00faout[15:0]};//Goto
    assign                          w_loop_list        = {w_reg00fbout[15:0]};//Loops
    assign                          w_enb_save_list    = w_reg00fcout[15:0] == 16'h5a5a ? 1'b1 : 1'b0;//Save_step
//---------------------------------------------------------------------------------
// LIST序列模式参数读取 ---- 读取buff
//---------------------------------------------------------------------------------
    wire                            w_workmode_CC_do, w_workmode_CV_do,w_workmode_CP_do,w_workmode_CR_do;//
    wire               [  31: 0]    w_target_do         ;//拉载值
    wire               [  31: 0]    w_runtime_do        ;//uS//单步执行时间
    wire               [  15: 0]    w_repeat_do         ;//单步循环次数,1-65535
    wire               [  15: 0]    w_goto_do           ;//小循环跳转目的地,1-999,无效0xFFFF
    wire               [  15: 0]    w_loop_do           ;//小循环次数,1-65535

List_Buff_wrapper U_List_Buff_wrapper
(
    .i_clk                          (i_clk              ),
    
    .i_number_list                  (w_number_list      ),
    .i_workmode_list                ({w_workmode_CC_list,w_workmode_CP_list,w_workmode_CR_list,w_workmode_CV_list}),//{CC,CP,CR,CV}
    .i_target_list                  (w_target_list      ),
    .i_runtime_list                 (w_runtime_list     ),
    .i_repeat_list                  (w_repeat_list      ),
    .i_goto_list                    (w_goto_list        ),
    .i_loop_list                    (w_loop_list        ),
    .i_enb_save_list                (w_enb_save_list    ),
								   
    .o_workmode_do                  ({w_workmode_CC_do,w_workmode_CP_do,w_workmode_CR_do,w_workmode_CV_do}),
    .o_target_do                    (w_target_do        ),
    .o_runtime_do                   (w_runtime_do       ),
    .o_repeat_do                    (w_repeat_do        ),
    .o_goto_do                      (w_goto_do          ),
    .o_loop_do                      (w_loop_do          ),
    .i_number_do                    (w_stepnum_do       ) 
);
//-----------------------------------------------------------------------
//  CC/CP/CR 拉载   ----  Vgs ---- Ids
//-----------------------------------------------------------------------
    localparam                      _PRECHARGE_T       = 40    ;//MOS预充电时间(mS)
    localparam                      _PRECHARGE_I       = 50    ;//MOS预充电电流(mA)

//
    wire               [  23: 0]    w_initI_pull        ;
    wire               [  23: 0]    w_curI_CC           ;
    wire               [  23: 0]    w_curI_CP           ;
    wire               [  23: 0]    w_curI_CR           ;
    wire               [  23: 0]    w_curI_CV           ;

    wire                            w_CC_pull_on        ;
    wire                            w_CC_pull_off       ;
    wire                            w_CC_pull_doing     ;
    wire                            w_CC_pull_cpl       ;
    wire     signed    [  23: 0]    w_curI_target_CC    ;//mA
    wire     signed    [  23: 0]    w_CC_pull_target    ;//mA
    wire     signed    [  15: 0]    w_CC_pull_K         ;//reg0061
    wire     signed    [  15: 0]    w_CC_pull_B         ;//reg0062
    wire                            w_CC_ctrl_enb       ;//
    wire               [  15: 0]    w_CC_ctrl_out       ;//TO DAC OUTA
    wire               [  15: 0]    w_CC_limit_ctrl_out  ;//TO DAC OUTA

Reg_Beat #(.D_WIDTH(16)) U_CC_pull_K (.i_clk(i_clk),.i_data({w_reg0061out[15:0]}),.o_data(w_CC_pull_K));
Reg_Beat #(.D_WIDTH(16)) U_CC_pull_B (.i_clk(i_clk),.i_data({w_reg0062out[15:0]}),.o_data(w_CC_pull_B));

Pull_load_CC #
(
    .S_SR_LIMIT                     (S_SR_LIMIT         ),
    ._PRECHARGE_T                   (_PRECHARGE_T       ),
    ._PRECHARGE_I                   (_PRECHARGE_I       ) 
)
U_CC_Pull_load
(
    .i_clk                          (i_clk              ),//input             
    .i_rst                          (i_rst              ),//input             
										            
    .i_on                           (w_CC_pull_on       ),//input                         
    .i_off                          (w_CC_pull_off      ),//input                         
    .o_doing                        (w_CC_pull_doing    ),//output                
    .o_done                         (w_CC_pull_cpl      ),//output                
    .o_cur_I_target                 (w_curI_target_CC   ),//output [23:0] 
    .o_cur_I                        (w_curI_CC          ),//output [23:0] 
    .i_target                       (w_CC_pull_target   ),//input [23:0]
    .i_initI                        (w_initI_pull       ),//input [23:0]
    .i_SR_slew                      (w_SR_slew_cur      ),//input [23:0] //电流向上斜率
    .i_SF_slew                      (w_SF_slew_cur      ),//input [23:0] //电流向下斜率
    .i_enb_slew                     (w_enb_slew_cur     ),//input        //电流按斜率变使能
    .i_enb_precharge                (w_enb_precharge    ),//input        //预充使能
    .i_flag_1us                     (w_flag_1us         ),//input       
    .i_flag_Short                   (w_flag_Short       ),//input        //短路测试 (STA/DYN)
    .i_I_short                      (w_I_short          ),//input [23:0] //短路时拉载电流		
								                     
    .i_xen                          (w_enb_sample_used  ),//input                         
    .i_limitI                       (w_shortI_1R03      ),//input [23:0]    
    .i_I                            (w_I_avg_20us /* {w_I_used} */),//input [23:0]    
    .i_U                            (w_U_avg_20us /* {w_U_used} */),//input [23:0]    
    .i_P                            (w_P_avg_20us /* {w_P_used} */),//input [31:0]    
    .i_R                            (w_R_avg_20us /* {w_R_used} */),//input [31:0]    
												   
    .i_K                            (w_CC_pull_K        ),//input [15:0] 
    .i_B                            (w_CC_pull_B        ),//input [15:0] 
    .o_vld                          (w_CC_ctrl_enb      ),//output        
    .o_y                            (w_CC_ctrl_out      ),//output [15:0] 
    .o_limity                       (w_CC_limit_ctrl_out) //output [15:0] 
);
//-----------------------------------------------------------------------
//  CC/CP/CR 拉载   ----  Vgs ---- Ids
//-----------------------------------------------------------------------
    wire                            w_CP_pull_on        ;
    wire                            w_CP_pull_off       ;
    wire                            w_CP_pull_doing     ;
    wire                            w_CP_pull_cpl       ;
    wire     signed    [  23: 0]    w_curI_target_CP    ;//mA
    wire     signed    [  31: 0]    w_CP_pull_target    ;//mW
    wire     signed    [  15: 0]    w_CP_pull_K         ;//reg0061
    wire     signed    [  15: 0]    w_CP_pull_B         ;//reg0062
    wire                            w_CP_ctrl_enb       ;
    wire               [  15: 0]    w_CP_ctrl_out       ;//TO DAC OUTA
    wire               [  15: 0]    w_CP_limit_ctrl_out  ;//TO DAC OUTA

Reg_Beat #(.D_WIDTH(16)) U_CP_pull_K (.i_clk(i_clk),.i_data({w_reg0061out[15:0]}),.o_data(w_CP_pull_K));
Reg_Beat #(.D_WIDTH(16)) U_CP_pull_B (.i_clk(i_clk),.i_data({w_reg0062out[15:0]}),.o_data(w_CP_pull_B));

Pull_load_CP #
(
    .S_SR_LIMIT                     (S_SR_LIMIT         ),
    ._PRECHARGE_T                   (_PRECHARGE_T       ),
    ._PRECHARGE_I                   (_PRECHARGE_I       ) 
)
U_CP_Pull_load
(
    .i_clk                          (i_clk              ),//input             
    .i_rst                          (i_rst              ),//input             
										            
    .i_on                           (w_CP_pull_on       ),//input        
    .i_off                          (w_CP_pull_off      ),//input 
    .o_doing                        (w_CP_pull_doing    ),//output	
    .o_done                         (w_CP_pull_cpl      ),//output       
    .o_cur_I_target                 (w_curI_target_CP   ),//output [23:0]    	
    .o_cur_I                        (w_curI_CP          ),//output [23:0]    	
    .i_target                       (w_CP_pull_target   ),//input  [31:0]
    .i_initI                        (w_initI_pull       ),//input [23:0]
    .i_SR_slew                      (w_SR_slew_cur      ),//input  [23:0] //电流向上斜率
    .i_SF_slew                      (w_SF_slew_cur      ),//input  [23:0] //电流向下斜率
    .i_enb_slew                     (w_enb_slew_cur     ),//input         //电流按斜率变使能
    .i_enb_precharge                (w_enb_precharge    ),//input        //预充使能
    .i_flag_1us                     (w_flag_1us         ),//input       
    .i_flag_Short                   (w_flag_Short       ),//input        //短路测试 (STA/DYN)
    .i_I_short                      (w_I_short          ),//input [23:0] //短路时拉载电流		
								                    
    .i_xen                          (w_enb_sample_used  ),//input                         
    .i_limitI                       (24'd1000_000 /* w_shortI_1R03 */),//input [23:0]    w_setI_limit_CV  CP模式下取消CV limit限制
    .i_I                            (w_I_avg_20us /* {w_I_used} */),//input [23:0]    
    .i_U                            (w_U_avg_20us /* {w_U_used} */),//input [23:0]  w_U_avg_CPR  
    .i_P                            (w_P_avg_20us /* {w_P_used} */),//input [31:0]    
    .i_R                            (w_R_avg_20us /* {w_R_used} */),//input [31:0] 
												   
    .i_K                            (w_CP_pull_K        ),//input  [15:0] 
    .i_B                            (w_CP_pull_B        ),//input  [15:0] 
    .o_vld                          (w_CP_ctrl_enb      ),//output        
    .o_y                            (w_CP_ctrl_out      ),//output [15:0] 
    .o_limity                       (w_CP_limit_ctrl_out) //output [15:0] 
);
//-----------------------------------------------------------------------
//  CC/CP/CR 拉载   ----  Vgs ---- Ids
//-----------------------------------------------------------------------
    wire                            w_CR_pull_on        ;
    wire                            w_CR_pull_off       ;
    wire                            w_CR_pull_doing     ;
    wire                            w_CR_pull_cpl       ;
    wire     signed    [  23: 0]    w_curI_target_CR    ;//mA
    wire     signed    [  31: 0]    w_CR_pull_target    ;//ohm * 10**(-4)
    wire     signed    [  15: 0]    w_CR_pull_K         ;//reg0061
    wire     signed    [  15: 0]    w_CR_pull_B         ;//reg0062
    wire                            w_CR_ctrl_enb       ;
    wire               [  15: 0]    w_CR_ctrl_out       ;//TO DAC OUTA
    wire               [  15: 0]    w_CR_limit_ctrl_out  ;//TO DAC OUTA

Reg_Beat #(.D_WIDTH(16)) U_CR_pull_K (.i_clk(i_clk),.i_data({w_reg0061out[15:0]}),.o_data(w_CR_pull_K));
Reg_Beat #(.D_WIDTH(16)) U_CR_pull_B (.i_clk(i_clk),.i_data({w_reg0062out[15:0]}),.o_data(w_CR_pull_B));

Pull_load_CR #
(
    .S_SR_LIMIT                     (S_SR_LIMIT         ),
    ._PRECHARGE_T                   (_PRECHARGE_T       ),
    ._PRECHARGE_I                   (_PRECHARGE_I       ) 
)
U_CR_Pull_load
(
    .i_clk                          (i_clk              ),//input             
    .i_rst                          (i_rst              ),//input             
										            
    .i_on                           (w_CR_pull_on       ),//input        
    .i_off                          (w_CR_pull_off      ),//input
    .o_doing                        (w_CR_pull_doing    ),//output	
    .o_done                         (w_CR_pull_cpl      ),//output       
    .o_cur_I_target                 (w_curI_target_CR   ),//output [23:0]    	
    .o_cur_I                        (w_curI_CR          ),//output [23:0] 
    .i_target                       (w_CR_pull_target   ),//input  [31:0]
    .i_initI                        (w_initI_pull       ),//input [23:0]
    .i_SR_slew                      (w_SR_slew_cur      ),//input  [23:0] //电流向上斜率
    .i_SF_slew                      (w_SF_slew_cur      ),//input  [23:0] //电流向下斜率
    .i_enb_slew                     (w_enb_slew_cur     ),//input         //电流按斜率变使能
    .i_enb_precharge                (w_enb_precharge    ),//input        //预充使能
    .i_flag_1us                     (w_flag_1us         ),//input 
    .i_flag_Short                   (w_flag_Short       ),//input        //短路测试 (STA/DYN)
    .i_I_short                      (w_I_short          ),//input [23:0] //短路时拉载电流		
								                    
    .i_xen                          (w_enb_sample_used  ),//input          
    .i_limitI                       (24'd1000_000 /* w_shortI_1R03 */),//input [23:0]   w_setI_limit_CV CR模式下取消CV limit限制	
    .i_I                            (w_I_avg_20us /* {w_I_used} */),//input [23:0]    
    .i_U                            (w_U_avg_CPR  /* {w_U_used} */),//input [23:0]    w_U_avg_20us
    .i_P                            (w_P_avg_20us /* {w_P_used} */),//input [31:0]    
    .i_R                            (w_R_avg_20us /* {w_R_used} */),//input [31:0] 
												   
    .i_K                            (w_CR_pull_K        ),//input  [15:0] 
    .i_B                            (w_CR_pull_B        ),//input  [15:0] 
    .o_vld                          (w_CR_ctrl_enb      ),//output        
    .o_y                            (w_CR_ctrl_out      ),//output [15:0] 
    .o_limity                       (w_CR_limit_ctrl_out) //output [15:0] 
);
//-----------------------------------------------------------------------
//  CV 拉载 ---- PID ---- Vgs ---- Ids
//-----------------------------------------------------------------------
    wire                            w_CV_pull_on        ;
    wire                            w_CV_pull_off       ;
    wire                            w_CV_pull_doing     ;
    wire                            w_CV_pull_cpl       ;
    wire     signed    [  23: 0]    w_curI_target_CV    ;//mA
    wire     signed    [  23: 0]    w_CV_pull_target    ;//
    wire     signed    [  15: 0]    w_CV_pull_kp        ;//reg006B/reg006D/reg006F
    wire     signed    [  15: 0]    w_CV_pull_ki        ;//reg006C/reg006E/reg0070
    wire     signed    [  15: 0]    w_CV_pull_kd        ;//
    wire     signed    [  15: 0]    w_CV_pull_K         ;//reg0063/reg0065/reg0067/reg0069
    wire     signed    [  15: 0]    w_CV_pull_B         ;//reg0064/reg0066/reg0068/reg006A
    wire                            w_CV_ctrl_enb       ;
    wire               [  15: 0]    w_CV_ctrl_out       ;//TO DAC OUTA
    wire               [  15: 0]    w_CV_limit_ctrl_out  ;//TO DAC OUTA
    wire               [  15: 0]    w_hard_CV_limit_ctrl_out  ;

Reg_Beat #(.D_WIDTH(16)) U_CV_pull_kp (.i_clk(i_clk),.i_data(w_KP_PID_CV),.o_data(w_CV_pull_kp));
Reg_Beat #(.D_WIDTH(16)) U_CV_pull_ki (.i_clk(i_clk),.i_data(w_KI_PID_CV),.o_data(w_CV_pull_ki));
Reg_Beat #(.D_WIDTH(16)) U_CV_pull_K  (.i_clk(i_clk),.i_data(w_K_cali_CV),.o_data(w_CV_pull_K ));
Reg_Beat #(.D_WIDTH(16)) U_CV_pull_B  (.i_clk(i_clk),.i_data(w_B_cali_CV),.o_data(w_CV_pull_B ));

Pull_load_CV #
(
    ._PRECHARGE_T                   (_PRECHARGE_T       ),
    ._PRECHARGE_I                   (_PRECHARGE_I       ) 
)
U_CV_Pull_load
(
    .i_clk                          (i_clk              ),//input             
    .i_rst                          (i_rst              ),//input             
										              
    .i_on                           (w_CV_pull_on       ),//input        
    .i_off                          (w_CV_pull_off      ),//input
    .o_doing                        (w_CV_pull_doing    ),//output	
    .o_done                         (w_CV_pull_cpl      ),//output       
    .o_cur_I_target                 (w_curI_target_CV   ),//input  [23:0]	   
    .o_cur_I                        (w_curI_CV          ),//output [23:0] 
    .i_target                       (w_CV_pull_target   ),//input  [23:0]	   
    .i_initI                        (w_initI_pull       ),//input [23:0]
    .i_SR_slew                      (w_SR_slew_cur      ),//input  [23:0] //电流向上斜率
    .i_SF_slew                      (w_SF_slew_cur      ),//input  [23:0] //电流向下斜率
    .i_enb_slew                     (w_enb_slew_cur     ),//input         //电流按斜率变使能
    .i_enb_precharge                (w_enb_precharge    ),//input        //预充使能
    .i_CV_slew                      (w_slew_CV          ),//input  [23:0] //电压变化斜率
    .i_flag_1us                     (w_flag_1us         ),//input      
    .i_flag_Short                   (w_flag_Short       ),//input        //短路测试 (STA/DYN)
    .i_I_short                      (w_I_short          ),//input [23:0] //短路时拉载电流	
								                                        
    .i_xen                          (w_enb_sample_used  ),//input                         
    .i_limitI                       (w_setI_limit_CV    ),//input [23:0] 
    .i_I                            (w_I_avg_20us /* {w_I_used} */),//input [23:0]    
    .i_U                            (w_U_avg_20us /* {w_U_used} */),//input [23:0]    
    .i_P                            (w_P_avg_20us /* {w_P_used} */),//input [31:0]    
    .i_R                            (w_R_avg_20us /* {w_R_used} */),//input [31:0] 
    .i_KP                           (w_CV_pull_kp       ),//input [15:0]
    .i_KI                           (w_CV_pull_ki       ),//input [15:0]
    .i_KD                           (16'h0              ),//input [15:0]
												      
    .i_K                            (w_CC_pull_K        ),//input  [15:0] 
    .i_B                            (w_CC_pull_B        ),//input  [15:0] 
    .o_vld                          (w_CV_ctrl_enb      ),//output        
    .o_y                            (w_CV_ctrl_out      ),//output [15:0] 
    .o_limity                       (w_CV_limit_ctrl_out) //output [15:0] 
);
// limit_ctrlout_CV U_limit_ctrlout_CV
// (
    // .i_clk                      ( i_clk               ),//input             
    // .i_rst                      ( i_rst               ),//input             
										              
    // .i_on                       ( w_CV_pull_on        ),//input        
    // .i_off                      ( w_CV_pull_off       ),//input        
    // .o_cur_I_target             ( w_curI_target_CV   ),//output [23:0]    	
    // .i_limitI                   ( w_setI_limit_CV     ),//input [23:0]    	
												      
    // .i_K                        ( w_CC_pull_K         ),//input  [15:0] 
	// .i_B                        ( w_CC_pull_B         ),//input  [15:0] 

    // .o_limity                   ( w_CV_limit_ctrl_out  )
// );

    wire                            w_hard_CV_pull_doing  ;
    wire                            w_hard_CV_pull_cpl  ;
    wire                            w_hard_CV_ctrl_enb  ;
    wire               [  15: 0]    w_hard_CV_ctrl_out  ;

Pull_load_Hard_CV #(
    .S_SR_LIMIT                     (S_SR_LIMIT         ) 
)
U_Hard_CV_Pull_load
(
    .i_clk                          (i_clk              ),//input             
    .i_rst                          (i_rst              ),//input             
										           
    .i_on                           (w_CV_pull_on       ),//input                         
    .i_off                          (w_CV_pull_off      ),//input                         
    .o_doing                        (w_hard_CV_pull_doing),//output                
    .o_done                         (w_hard_CV_pull_cpl ),//output                
    .o_cur_I_target                 (                   ),//output [23:0] 
    .i_target                       (w_CV_pull_target   ),//input [23:0]
    .i_CV_slew                      (w_slew_CV          ),//input  [23:0] //电压变化斜率	
    .i_SR_slew                      (w_SR_slew_cur      ),//input  [23:0] //电流向上斜率
    .i_SF_slew                      (w_SF_slew_cur      ),//input  [23:0] //电流向下斜率
    .i_flag_1us                     (w_flag_1us         ),//input
								                    
    .i_xen                          (w_enb_sample_used  ),//input                         
    .i_limitI                       (w_setI_limit_CV    ),//input [23:0]    
    .i_I                            (w_I_avg_20us /* {w_I_used} */),//input [23:0]    
    .i_U                            (w_U_avg_20us /* {w_U_used} */),//input [23:0]    
    .i_P                            (w_P_avg_20us /* {w_P_used} */),//input [31:0]    
    .i_R                            (w_R_avg_20us /* {w_R_used} */),//input [31:0]    
												   
    .i_K                            (w_CV_pull_K        ),//input [15:0] 
    .i_B                            (w_CV_pull_B        ),//input [15:0] 
    .i_cc_K                         (w_CC_pull_K        ),//input  [15:0] 
    .i_cc_B                         (w_CC_pull_B        ),//input  [15:0] 
    .o_vld                          (w_hard_CV_ctrl_enb ),//output        
    .o_y                            (w_hard_CV_ctrl_out ),//output [15:0] 
    .o_limity                       (w_hard_CV_limit_ctrl_out) //output [15:0] 
);
//----------------------------------------------------------------------------
//
//   w_Cgear_L_ON
//   
//----------------------------------------------------------------------------
Get_I_gear #(.I_WATERSHED(I_WATERSHED)) U_get_i_gear
(
    .i_clk                          (i_clk              ),
    .i_rst                          (i_rst              ),
								    
    .i_workmode                     ({w_workmode_CV_rt,w_workmode_CR_rt,w_workmode_CP_rt,w_workmode_CC_rt}),
    .i_cur_I_target_CC              (w_curI_target_CC   ),
    .i_cur_I_target_CP              (w_curI_target_CP   ),
    .i_cur_I_target_CR              (w_curI_target_CR   ),
    .i_cur_I_target_CV              (w_curI_target_CV   ),
								    
    .o_cgear_l                      (w_Cgear_L_ON       ) //电流测量档位-低档
);
//----------------------------------------------------------------------------
//
//   ila_pull_out
//   
//----------------------------------------------------------------------------
//     wire                            w_ck_pull_out       ;
//     wire               [  23: 0]    w_p0_pull_out       ;
//     wire               [  23: 0]    w_p1_pull_out       ;
//     wire               [  31: 0]    w_p2_pull_out       ;
//     wire               [  31: 0]    w_p3_pull_out       ;
//     assign                          w_ck_pull_out      = i_clk;
//     assign                          w_p0_pull_out      = w_CC_pull_target;
//     assign                          w_p1_pull_out      = w_CV_pull_target;
//     assign                          w_p2_pull_out      = w_CP_pull_target;
//     assign                          w_p3_pull_out      = w_CR_pull_target;
// ila_pull_out U_pull_out
// (
//     .clk                            (w_ck_pull_out      ) // input wire clk
//     ,.probe0        ( w_p0_pull_out   )                             // input wire [23:0]  probe0  
//     ,.probe1        ( w_p1_pull_out   )                             // input wire [23:0]  probe1 
//     ,.probe2        ( w_p2_pull_out   )                             // input wire [31:0]  probe2 
//     ,.probe3        ( w_p3_pull_out   )                             // input wire [31:0]  probe3 
// );
//-----------------------------------------------------------------------
// Battery discharge
//-----------------------------------------------------------------------
    wire                            w_BATT_on           ;
    wire                            w_BATT_off          ;
    wire               [  31: 0]    w_BATT_cap1         ;//容量mAh  
    wire               [  31: 0]    w_BATT_cap2         ;//容量mWh  
    wire               [  31: 0]    w_BATT_time         ;//时间S
    wire               [  23: 0]    w_BATT_U            ;//电压mV
    wire               [  23: 0]    w_BATT_I            ;//电流mA
    wire               [  31: 0]    w_BATT_R            ;//电阻ohm*10-4
    wire               [   1: 0]    w_BATT_err          ;//电池错误 b0:I反向 b1:U反向
Bat_Test U_Bat_Test
(
    .i_clk                          (i_clk              ),// 
    .i_rst                          (i_rst              ),// 
										             
    .i_on                           (w_BATT_on          ),//打开
    .i_off                          (w_BATT_off         ),//关闭
    .i_flag_1s                      (w_flag_1s          ),//1s 仿真改为1us w_flag_1us
											         
    .i_xen                          (w_enb_sample_used  ),//当前采样使能
    .i_I                            (w_I_avg_20us /* {w_U_used} */),//当前采样值mA
    .i_U                            (w_U_avg_20us /* {w_I_used} */),//当前采样值mV    
    .i_P                            (w_P_avg_20us /* {w_P_used} */),//当前采样值mW
    .i_R                            (w_R_avg_20us /* {w_R_used} */),//当前采样值ohm*10-4
											         
    .o_bat_cap1                     (w_BATT_cap1        ),//容量mAh  
    .o_bat_cap2                     (w_BATT_cap2        ),//容量mWh  
    .o_bat_time                     (w_BATT_time        ),//时间S
    .o_bat_U                        (w_BATT_U           ),//电压mV
    .o_bat_I                        (w_BATT_I           ),//电流mA
    .o_bat_R                        (w_BATT_R           ),//电阻ohm*10-4
    .o_bat_err                      (w_BATT_err         ) //电池错误 b0:I反向 b1:U反向
);
//-----------------------------------------------------------------------
// 将PS的CMD/CTRL/parameter转成拉载模块所需要的CMD/CTRL/parameter
//-----------------------------------------------------------------------
Async_sync U_other_err (.clk_dst(i_clk),.signal_src(i_vop_pos || i_vop_neg),.signal_dst(w_other_err));
                   
// assign  w_ocp_hardCV  = (w_hard_CV_ON == 1'b1 && w_workmode_CV_rt == 1'b1) ? ~i_cv_limit_trig : 1'b0 ;
// assign  w_ocp_in_CV   = (w_workmode_CV_rt == 1'b1) ? ~i_ocp_da_trig : 1'b0 ;
    assign                          w_ocp_in_CV        = 1'b0;

// Deburrer #(.FILTER(10000)) U_deburrer_ocp_hardCV (.clk(i_clk),.rst(i_rst),.signal_in(w_ocp_hardCV),.signal_out(w_deburrer_ocp_hardCV));
Deburrer #(.FILTER(10000)) U_deburrer_OCP_in_CV  (.clk(i_clk),.rst(i_rst),.signal_in(w_ocp_in_CV ),.signal_out(w_deburrer_ocp_in_CV ));

Get_off_err U_Get_off_err
(
    .i_clk                          (i_clk              ),//     
    .i_rst                          (i_rst              ),//     
    .i_ocp                          (w_ocp_soft | w_ocp_maxI_soft | w_deburrer_ocp_in_CV),//     
    .i_ovp                          (w_ovp_soft | w_ovp_maxU_soft),//
    .i_opp                          (w_opp_soft | w_opp_maxP_soft),//
    .i_inv                          (w_err_INV          ),//
    .i_other_err                    (w_other_err | w_err_sense),//
    .o_off                          (w_off_err          ) //
);
Get_off_cpl U_Get_off_cpl
(
    .i_clk                          (i_clk              ),
    .i_rst                          (i_rst              ),
    .i_batt_cpl                     (w_BATT_cpl         ),
    .i_tocp_cpl                     (w_TOCP_cpl         ),
    .i_topp_cpl                     (w_TOPP_cpl         ),
    .o_off                          (w_off_cpl          ) 
);

Main_ctrl_Pull_load #
(
    ._PRECHARGE_T                   (_PRECHARGE_T       ),//_PRECHARGE_T 10
    ._PRECHARGE_I                   (_PRECHARGE_I       ),//_PRECHARGE_I 10
    ._1US_CKNUM                     (100                ) //100 1
)
U_Main_ctrl
(
    .i_clk                          (i_clk              ),//input          
    .i_rst                          (i_rst              ),//input           
    //common                                            
    .i_on                           (s_flag_run         ),//input  //运行
    .i_off                          (s_flag_stop        ),//input  //停止
    .o_doing                        (w_doing_pull_out   ),//output //
    .i_hardCV_ON                    (s_hardCV_sel_temp  ),//input //
	//work_mode_function							            
    .i_workmode_CC                  (w_workmode_CC      ),//input         
    .i_workmode_CP                  (w_workmode_CP      ),//input         
    .i_workmode_CR                  (w_workmode_CR      ),//input         
    .i_workmode_CV                  (w_workmode_CV      ),//input         
    .i_func_STA                     (w_func_STA         ),//input            
    .i_func_DYN                     (w_func_DYN         ),//input            
    .i_func_RIP                     (w_func_RIP         ),//input            
    .i_func_RE                      (w_func_RE          ),//input             
    .i_func_FE                      (w_func_FE          ),//input             
    .i_func_BAT_N                   (w_func_BAT_N       ),//input          
    .i_func_BAT_P                   (w_func_BAT_P       ),//input          
    .i_func_LIST                    (w_func_LIST        ),//input           
    .i_func_TOCP                    (w_func_TOCP        ),//input           
    .i_func_TOPP                    (w_func_TOPP        ),//input           
    // .i_flag_Short               ( w_flag_Short          ),//input        //短路测试 (STA/DYN)
	// .i_I_short                  ( w_I_short             ),//input [31:0] //短路时拉载电流
    .i_worktype_Single              (w_worktype_Single  ),//input        //单机
    .i_ms_Master                    (w_ms_Master        ),//input        //主机
    //Von
    .i_Von_Latch_ON                 (w_Von_Latch_ON     ),//input        //Latch ON  
    .i_Von_Latch_OFF                (w_Von_Latch_OFF    ),//input        //Latch OFF  
    .i_start_Volt                   ({16'h0,w_start_Volt}),//input [31:0] //启动电压
    .i_stop_Volt                    (w_stop_Volt        ),//input [31:0] //停止电压
    //max
    .i_maxI_limit                   (w_maxI_limit       ),//input [31:0] //测试件最大电流限制
    .i_maxU_limit                   (w_maxU_limit       ),//input [31:0] //测试件最大电压限制
    .i_maxP_limit                   (w_maxP_limit       ),//input [31:0] //测试件最大功率限制
	//limit                                                 
    .i_setI_limit                   (w_setI_limit       ),//input [31:0] //被测件最大电流限制
    .i_setU_limit                   (w_setU_limit       ),//input [31:0] //被测件最大电压限制
    .i_setP_limit                   (w_setP_limit       ),//input [31:0] //被测件最大功率限制
    .i_setI_limit_CV                (w_setI_limit_CV    ),//input [31:0] //被测件CV时最大电流限制
    .i_T_pro                        (w_proT             ),//input [15:0] //保护时长设置
	//real-time                                         
    .i_vld_rt                       (w_enb_sample_used  ),//input        //5us采样更新
    .i_I_rt                         (w_vldI_used /* w_I_used */),//input [31:0] //实时采样电流
    .i_U_rt                         ({8'h0,w_vldU_used} /* w_U_used */),//input [31:0] //实时采样电压
    .i_P_rt                         (w_vldP_used /* w_P_used */),//input [31:0] //实时采样功率
    .i_R_rt                         (w_vldR_used /* w_R_used */),//input [31:0] //实时采样电阻
    //STA                                               
    .i_slew_CR_STA                  (w_slew_CR_STA      ),//input [23:0] //reg000B 静态模式下,电流上升斜率
    .i_slew_CF_STA                  (w_slew_CF_STA      ),//input [23:0] //reg000C 静态模式下,电流下降斜率
    .i_Iset_STA                     (w_Iset_STA         ),//input [31:0] //reg0011/reg0012
    .i_Uset_STA                     (w_Uset_STA         ),//input [31:0] //reg0013/reg0014
    .i_Pset_STA                     (w_Pset_STA         ),//input [31:0] //reg0015/reg0016
    .i_Rset_STA                     (w_Rset_STA         ),//input [31:0] //reg0017/reg0018
    //DYN                                               
    .i_trigmode_DYN_C               (w_trigmode_DYN_C   ),//input        //连续触发
    .i_trigmode_DYN_P               (w_trigmode_DYN_P   ),//input        //脉冲触发
    .i_trigmode_DYN_T               (w_trigmode_DYN_T   ),//input        //翻转触发
    .i_trigsource_DYN_N             (w_trigsource_DYN_N ),//input        //无触发(针对连续触发模式)
    .i_trigsource_DYN_M             (w_trigsource_DYN_M ),//input        //手动触发
    .i_trigsource_DYN_B             (w_trigsource_DYN_B ),//input        //总线触发
    .i_trigsource_DYN_O             (w_trigsource_DYN_O ),//input        //外部触发
    .i_triggen_DYN                  (w_triggen_DYN      ),//input        //触发(针对手动触发)
    .i_slew_CR_DYN                  (w_slew_CR_DYN      ),//input [23:0] //reg002D 动态模式下,电流上升斜率(1mA/us)
    .i_slew_CF_DYN                  (w_slew_CF_DYN      ),//input [23:0] //reg002E 动态模式下,电流下降斜率(1mA/us)
    .i_I1set_DYN                    (w_I1set_DYN        ),//input [31:0] //reg0019/reg001A
    .i_I2set_DYN                    (w_I2set_DYN        ),//input [31:0] //reg001B/reg001C
    .i_U1set_DYN                    (w_U1set_DYN        ),//input [31:0] //reg001D/reg001E
    .i_U2set_DYN                    (w_U2set_DYN        ),//input [31:0] //reg001F/reg0020
    .i_P1set_DYN                    (w_P1set_DYN        ),//input [31:0] //reg0021/reg0022
    .i_P2set_DYN                    (w_P2set_DYN        ),//input [31:0] //reg0023/reg0024
    .i_R1set_DYN                    (w_R1set_DYN        ),//input [31:0] //reg0025/reg0026
    .i_R2set_DYN                    (w_R2set_DYN        ),//input [31:0] //reg0027/reg0028
    .i_T1set_CC_DYN                 (w_T1set_CC_DYN     ),//input [31:0] //mS//reg0080/reg0081
    .i_T2set_CC_DYN                 (w_T2set_CC_DYN     ),//input [31:0] //mS//reg0082/reg0083
    .i_T1set_CV_DYN                 (w_T1set_CC_DYN/* w_T1set_CV_DYN */),//input [31:0] //mS//reg0084/reg0085
    .i_T2set_CV_DYN                 (w_T2set_CC_DYN/* w_T2set_CV_DYN */),//input [31:0] //mS//reg0086/reg0087
    .i_T1set_CP_DYN                 (w_T1set_CC_DYN/* w_T1set_CP_DYN */),//input [31:0] //mS//reg0088/reg0089
    .i_T2set_CP_DYN                 (w_T2set_CC_DYN/* w_T2set_CP_DYN */),//input [31:0] //mS//reg008A/reg008B
    .i_T1set_CR_DYN                 (w_T1set_CC_DYN/* w_T1set_CR_DYN */),//input [31:0] //mS//reg008C/reg008D
    .i_T2set_CR_DYN                 (w_T2set_CC_DYN/* w_T2set_CR_DYN */),//input [31:0] //mS//reg008E/reg008F
    //BAT                                               
    .i_BT_Stop_U                    (w_BT_Stop_U        ),//input         //电压截止
    .i_BT_Stop_T                    (w_BT_Stop_T        ),//input         //时间截止
    .i_BT_Stop_C                    (w_BT_Stop_C        ),//input         //容量截止
    .i_offV_BT_Stop                 (w_offV_BT_Stop     ),//input  [31:0] //mV//reg00B3/reg00B4 放电截止电压
    .i_offT_BT_Stop                 (w_offT_BT_Stop     ),//input  [31:0] //S//reg00B5/reg00B6 放电截止时间
    .i_offC_BT_Stop                 (w_offC_BT_Stop     ),//input  [31:0] //mAh//reg00B7/reg00B8 放电截止容量
    .i_proV_BT_Stop                 (w_proV_BT_Stop     ),//input  [31:0] //mV//reg00B9/reg00BA 电池放电保护测试截止电压
    .o_cpl_BATT                     (w_BATT_cpl         ),//output        //电池测试完成
	//BAT电池放电                                       
    .o_BAT_on                       (w_BATT_on          ),//output        //打开
    .o_BAT_off                      (w_BATT_off         ),//output        //关闭
    .i_BAT_cap                      (w_BATT_cap1        ),//input  [31:0] //放电容量mAh  
    .i_BAT_time                     (w_BATT_time        ),//input  [31:0] //放电时间S
    .i_BAT_U                        (w_BATT_U           ),//input  [23:0] //放电电压mV
    .i_BAT_I                        (w_BATT_I           ),//input  [23:0] //放电电流mA
    .i_BAT_R                        (w_BATT_R           ),//input  [31:0] //放电电阻ohm*10-4
    .i_BAT_err                      (w_BATT_err         ),//input  [1:0]  //电池错误 b0:I反向 b1:U反向
	//TOCP                                              
    .i_start_Volt_TOCP              (w_start_Volt_TOCP  ),//input  [31:0] //mV//reg00C0/reg00C1 OCP测试的启动电压值
    .i_start_Curr_TOCP              (w_start_Curr_TOCP  ),//input  [31:0] //mA//reg00C2/reg00C3 OCP测试的初始电流值
    .i_stop_Curr_TOCP               (w_stop_Curr_TOCP   ),//input  [31:0] //mA//reg00C4/reg00C5 OCP测试的截止电流值
    .i_step_Curr_TOCP               (w_step_Curr_TOCP   ),//input  [15:0] //mA//reg00C6 OCP测试的步进电流值
    .i_step_Time_TOCP               (w_step_Time_TOCP   ),//input  [15:0] //S//reg00C7 OCP测试的步进时间值
    .i_pro_Volt_TOCP                (w_pro_Volt_TOCP    ),//input  [31:0] //mV//reg00C8/reg00C9 OCP测试的保护电压值
    .i_over_Curr_MIN_TOCP           (w_over_Curr_MIN_TOCP),//input  [31:0] //mA//reg00CA/reg00CB OCP测试的过电流最小值
    .i_over_Curr_MAX_TOCP           (w_over_Curr_MAX_TOCP),//input  [31:0] //mA//reg00CC/reg00CD OCP测试的过电流最大值
    .o_pass_TOCP                    (w_pass_TOCP        ),//output        //
    .o_fail_TOCP                    (w_fail_TOCP        ),//output        //
    .o_status_TOCP                  (w_status_TOCP      ),//output [15:0] //
    .o_cpl_TOCP                     (w_TOCP_cpl         ),//output        //TOCP完成
    .o_curTarget_TOCP               (w_curTarget_TOCP   ),//output [31:0] //mA//reg00CE/reg00CF OCP测试的当前目标值(RO)
    //TOPP                         
    .i_start_Volt_TOPP              (w_start_Volt_TOPP  ),//input  [31:0] //mV//reg00D0/reg00D1 OPP测试的启动电压值
    .i_start_Power_TOPP             (w_start_Power_TOPP ),//input  [31:0] //mW//reg00D2/reg00D3 OPP测试的初始功率值
    .i_stop_Power_TOPP              (w_stop_Power_TOPP  ),//input  [31:0] //mW//reg00D4/reg00D5 OPP测试的截止功率值
    .i_step_Power_TOPP              (w_step_Power_TOPP  ),//input  [15:0] //mW//reg00D6 OPP测试的步进功率值
    .i_step_Time_TOPP               (w_step_Time_TOPP   ),//input  [15:0] //S//reg00D7 OPP测试的步进时间值
    .i_pro_Volt_TOPP                (w_pro_Volt_TOPP    ),//input  [31:0] //mV//reg00D8/reg00D9 OPP测试的保护电压值
    .i_over_Power_MIN_TOPP          (w_over_Power_MIN_TOPP),//input  [31:0] //mW//reg00DA/reg00DB OPP测试的过功率最小值
    .i_over_Power_MAX_TOPP          (w_over_Power_MAX_TOPP),//input  [31:0] //mW//reg00DC/reg00DD OPP测试的过功率最大值
    .o_pass_TOPP                    (w_pass_TOPP        ),//output        //
    .o_fail_TOPP                    (w_fail_TOPP        ),//output        //
    .o_status_TOPP                  (w_status_TOPP      ),//output [15:0] //
    .o_cpl_TOPP                     (w_TOPP_cpl         ),//output        //TOPP完成
    .o_curTarget_TOPP               (w_curTarget_TOPP   ),//output [31:0] //mW//reg00DE/reg00DF OPP测试的当前目标值(RO)
    //List                         
    .i_total_stepnum_list           (w_total_listnum    ),//input  [15:0] //总的步数
    .i_total_loopnum_list           (w_total_loopnum    ),//input  [15:0] //总的循环数//0:无限循环
    .i_workmode_CC_list             (w_workmode_CC_do   ),//input         //CC静态工作模式
    .i_workmode_CP_list             (w_workmode_CP_do   ),//input         //CP静态工作模式
    .i_workmode_CR_list             (w_workmode_CR_do   ),//input         //CR静态工作模式
    .i_workmode_CV_list             (w_workmode_CV_do   ),//input         //CV静态工作模式
    .i_target_list                  (w_target_do        ),//input  [31:0] //拉载值//mA/mW/ohm/mV
    .i_runtime_list                 (w_runtime_do       ),//input  [31:0] //单步执行时间//uS
    .i_repeat_list                  (w_repeat_do        ),//input  [15:0] //单步循环次数//1-65535
    .i_goto_list                    (w_goto_do          ),//input  [15:0] //小循环跳转目的地//1-999//无效0xFFFF
    .i_loop_list                    (w_loop_do          ),//input  [15:0] //小循环次数//1-65535
    .o_cnt_repeat_list              (w_cnt_repeat_list  ),//单步重复计数(1-65535)
    .o_cnt_total_loop_list          (w_cnt_total_loop_list),//总循环计数(1-1000)
    .o_curstepnum_list              (w_stepnum_do       ),//output [15:0] //当前执行编号//1-1000
    .o_cnt_loop_list                (w_cnt_loop_list    ),//小循环计数(1-65535)
    .o_cpl_list                     (w_LIST_cpl         ),//output        //列表执行完成
    //DAC控制                      
    .o_outa_enb                     (w_dac_cha_set      ),//output        //
    .o_outa_data                    (w_dac_cha_data     ),//output [15:0] //CELL_PROG_DA
    .o_outb_enb                     (w_dac_chb_set      ),//output        //
    .o_outb_data                    (w_dac_chb_data     ),//output [15:0] //CV_limit_DA
    //output                       
    .o_workmode_CC_rt               (w_workmode_CC_rt   ),//output //实时工作模式
    .o_workmode_CP_rt               (w_workmode_CP_rt   ),//output //实时工作模式
    .o_workmode_CR_rt               (w_workmode_CR_rt   ),//output //实时工作模式
    .o_workmode_CV_rt               (w_workmode_CV_rt   ),//output //实时工作模式
    .o_flag_1us                     (w_flag_1us         ),//output        //
    .o_flag_1ms                     (w_flag_1ms         ),//output        //
    .o_flag_1s                      (w_flag_1s          ),//output        //
    .o_SR_slew                      (w_SR_slew_cur      ),//output [23:0] //电流上升沿mA/1us
    .o_SF_slew                      (w_SF_slew_cur      ),//output [23:0] //电流下降沿mA/1us
    .o_enb_slew                     (w_enb_slew_cur     ),//output        //电流需要上升沿和下降沿使能
    .o_enb_precharge                (w_enb_precharge    ),//output        //电流需要上升沿和下降沿使能
    //
    .o_initI_pull                   (w_initI_pull       ),//
    .i_curI_CC                      (w_curI_CC          ),//
    .i_curI_CP                      (w_curI_CP          ),//
    .i_curI_CR                      (w_curI_CR          ),//
    .i_curI_CV                      (w_curI_CV          ),//
	//CC拉载
    .o_CC_on                        (w_CC_pull_on       ),//output        //打开         
    .o_CC_off                       (w_CC_pull_off      ),//output        //关闭        
    .o_CC_target                    (w_CC_pull_target   ),//output [23:0] //目标值mA    
    .i_CC_cpl                       (w_CC_pull_cpl      ),//input         //
    .i_CC_ctrlen                    (w_CC_ctrl_enb      ),//input         //    
    .i_CC_ctrl                      (w_CC_ctrl_out      ),//input  [15:0] //
    .i_CC_limit_ctrl                (w_CC_limit_ctrl_out),//input  [15:0] //
    //CP拉载                                       
    .o_CP_on                        (w_CP_pull_on       ),//output        //打开        
    .o_CP_off                       (w_CP_pull_off      ),//output        //关闭
    .o_CP_target                    (w_CP_pull_target   ),//output [31:0] //目标值mA
    .i_CP_cpl                       (w_CP_pull_cpl      ),//input         //
    .i_CP_ctrlen                    (w_CP_ctrl_enb      ),//input         //
    .i_CP_ctrl                      (w_CP_ctrl_out      ),//input  [15:0] //
    .i_CP_limit_ctrl                (w_CP_limit_ctrl_out),//input  [15:0] //
    //CR拉载
    .o_CR_on                        (w_CR_pull_on       ),//output        //打开
    .o_CR_off                       (w_CR_pull_off      ),//output        //关闭
    .o_CR_target                    (w_CR_pull_target   ),//output [31:0] //目标值mA
    .i_CR_cpl                       (w_CR_pull_cpl      ),//input         //
    .i_CR_ctrlen                    (w_CR_ctrl_enb      ),//input         //
    .i_CR_ctrl                      (w_CR_ctrl_out      ),//input  [15:0] //
    .i_CR_limit_ctrl                (w_CR_limit_ctrl_out),//input  [15:0] //
    //CV拉载
    .o_CV_on                        (w_CV_pull_on       ),//output        //打开
    .o_CV_off                       (w_CV_pull_off      ),//output        //关闭
    .o_CV_target                    (w_CV_pull_target   ),//output [23:0] //目标值mA
    .i_CV_cpl                       (((CurWorkMode[3] == 1) && (s_hardCV_sel_temp == 1)) ? w_hard_CV_pull_cpl : w_CV_pull_cpl),//input       
    .i_CV_ctrlen                    (((CurWorkMode[3] == 1) && (s_hardCV_sel_temp == 1)) ? w_hard_CV_ctrl_enb : w_CV_ctrl_enb),//input       
    .i_CV_ctrl                      (((CurWorkMode[3] == 1) && (s_hardCV_sel_temp == 1)) ? w_hard_CV_ctrl_out : w_CV_ctrl_out),//input [15:0]
    .i_CV_limit_ctrl                (((CurWorkMode[3] == 1) && (s_hardCV_sel_temp == 1)) ? w_hard_CV_limit_ctrl_out : w_CV_limit_ctrl_out) //,//input [15:0]
);

//---------------------------------------------------------------------------------
// detect SENSE
//---------------------------------------------------------------------------------
    assign                          w_detectsense_threshold= {w_reg000dout[23:0]};
Detect_Sense #(.D_WIDTH (24)) U_Detect_Sense
(
    .i_clk                          (i_clk              ),//
    .i_rst                          (w_SENSE_ON ? i_rst : 1'b1),//
    .i_U_sense                      (w_abs_U_sense      ),//
    .i_U_mod                        (w_abs_U_mod        ),//
    .i_LU_sense                     (w_abs_LU_sense     ),//
    .i_LU_mod                       (w_abs_LU_mod       ),//
    .i_clr                          (w_clr_Alarm        ),//
    .i_threshold                    (w_detectsense_threshold),//
    .o_err                          (w_err_sense        ) //
);
//---------------------------------------------------------------------------------
// detect INV
//---------------------------------------------------------------------------------
Detect_INV #(.D_WIDTH (24)) U_Detect_INV
(
    .i_clk                          (i_clk              ),//
    .i_rst                          (i_rst              ),//
    .i_I                            (w_I_used           ),//
    .i_U                            (w_Vgear_L_ON ? w_cut_LU_sense : w_cut_U_sense),//
    .i_clr                          (w_clr_Alarm        ),//
    .o_err_INV                      (w_err_INV          ) //
);
//---------------------------------------------------------------------------------
// OCP OPP OVP
//---------------------------------------------------------------------------------
Get_OCVP U_Get_OCVP
(
    .i_clk                          (i_clk              ),//
    .i_rst                          (i_rst              ),//仿真时设置为~i_rst，防止一直ocvp
    //max                                            
    .i_maxI_limit                   (w_maxI_limit       ),//测试件最大电流限制
    .i_maxU_limit                   (w_maxU_limit       ),//测试件最大电压限制
    .i_maxP_limit                   (w_maxP_limit       ),//测试件最大功率限制
    //limit                                              
    .i_setI_limit                   (w_setI_limit       ),//被测件最大电流限制
    .i_setU_limit                   (w_setU_limit       ),//被测件最大电压限制
    .i_setP_limit                   (w_setP_limit       ),//被测件最大功率限制
    // .i_setI_limit_CV            ( w_setI_limit_CV    ),//被测件CV时最大电流限制
    .i_T_pro                        (w_proT             ),//保护时长设置
    .i_workmode_CV_rt               (w_workmode_CV_rt   ),//当前为CV模式
    //real-time                                      
    .i_vld_rt                       (w_enb_sample_used  ),//5us采样更新
    .i_I_rt                         (w_vldI_used /* w_I_used */),//实时采样电流
    .i_U_rt                         (w_vldU_used /* w_U_used */),//实时采样电压
    .i_P_rt                         (w_vldP_used /* w_P_used */),//实时采样功率
    .i_R_rt                         (w_vldR_used /* w_R_used */),//实时采样电阻
    //output                         
    .i_clr                          (w_clr_Alarm        ),//
    .o_ocp                          (w_ocp_soft         ),//
    .o_ovp                          (w_ovp_soft         ),//
    .o_opp                          (w_opp_soft         ),//
    .o_ocp_maxI                     (w_ocp_maxI_soft    ),//
    .o_ovp_maxU                     (w_ovp_maxU_soft    ),//
    .o_opp_maxP                     (w_opp_maxP_soft    ) //
);

// assign  w_reg0000in = {w_TOPP_cpl,w_TOCP_cpl,w_BATT_cpl,w_err_sense,w_err_INV,i_mcu_alarm,w_ovp_soft,w_ocp_soft,w_ocp_maxI_soft,w_opp_soft,w_opp_maxP_soft};
    assign                          w_reg0000in        = {w_TOPP_cpl,w_TOCP_cpl,w_BATT_cpl,w_err_sense,w_err_INV,i_mcu_alarm,w_ovp_soft,(w_ocp_soft | w_deburrer_ocp_in_CV),w_ocp_maxI_soft,w_opp_soft,w_opp_maxP_soft};
    assign                          w_reg0008in        = s_run_status;



always @ (posedge i_clk)
begin
    if (w_flag_RUN)       s_flag_run  <= 1 ;
    else                  s_flag_run  <= 0 ;
end
always @ (posedge i_clk)
begin
    if (w_flag_STOP)      s_flag_stop <= 1 ;
    else if(w_LIST_cpl || w_TOPP_cpl || w_TOCP_cpl || w_BATT_cpl)   s_flag_stop <= 1 ;
    else if (w_off_err)   s_flag_stop <= 1 ;
    else if (w_off_cpl)   s_flag_stop <= 1 ;
    else                  s_flag_stop <= 0 ;
end
// reg             [15:0]                  s_run_status ='ha5a5 ;

always @ (posedge i_clk)
begin
    if (w_flag_RUN)       s_run_status <= 'h5a5a ;
    else if (w_flag_STOP) s_run_status <= 'ha5a5 ;
    else if (w_LIST_cpl || w_TOPP_cpl || w_TOCP_cpl || w_BATT_cpl)  s_run_status <= 'ha5a5 ;
    else if (w_off_err)   s_run_status <= {4'hf,w_reg0000in[11:0]} ;
    else if (w_off_cpl)   s_run_status <= {4'hf,w_reg0000in[11:0]} ;
    else                  s_run_status <= s_run_status ;
end

    assign                          w_reg02cfin        = {s_tocp_status};
    assign                          w_reg02dfin        = {s_topp_status};
// reg             [15:0]                  s_tocp_status  ='h0 ;//
// reg             [15:0]                  s_topp_status  ='h0 ;//
always @ (posedge i_clk)
begin
    if (w_TOCP_cpl == 1'B1)
        s_tocp_status <= w_status_TOCP ;
    else
        s_tocp_status <= s_tocp_status ;
		
    if (w_TOPP_cpl == 1'B1)
        s_topp_status <= w_status_TOPP ;
    else
        s_topp_status <= s_topp_status ;
end
                                              
    wire               [  31: 0]    w_I_display         ;
    wire               [  31: 0]    w_U_display         ;
Volt_Curr_Display U_I_U_Display
(
    .i_clk                          (i_clk              ),
    .i_rst                          (i_rst              ),
    .i_vld_rt                       (w_enb_sample_used  ),
    .i_I_rt                         ({{8{w_I_avg_40us[23]}},w_I_avg_40us}),
    .i_U_rt                         ({{8{w_U_avg_40us[23]}},w_U_avg_40us}),
    .o_I_avg_disp                   (w_I_display        ),
    .o_U_avg_disp                   (w_U_display        ) 
);
// assign  w_I_display  = w_I_avg_80us ; 
// assign  w_U_display  = w_U_avg_80us ; 

    assign                          w_reg0101in        = w_cut_LI_board[15:0];//0101
    assign                          w_reg0102in        = {{8{w_cut_LI_board[23]}},w_cut_LI_board[23:16]};//0102
    assign                          w_reg0103in        = w_cut_HI_board[15:0];//0103
    assign                          w_reg0104in        = {{8{w_cut_HI_board[23]}},w_cut_HI_board[23:16]};//0104
    assign                          w_reg0105in        = w_cut_LI_sum[15:0];//0105
    assign                          w_reg0106in        = {{8{w_cut_LI_sum[23]}},w_cut_LI_sum[23:16]};//0106
    assign                          w_reg0107in        = w_cut_HI_sum[15:0];//0107
    assign                          w_reg0108in        = {{8{w_cut_HI_sum[23]}},w_cut_HI_sum[23:16]};//0108
    assign                          w_reg0109in        = w_cut_I_board_unit[15:0];//0109
    assign                          w_reg010ain        = {{8{w_cut_I_board_unit[23]}},w_cut_I_board_unit[23:16]};//010a
    assign                          w_reg010bin        = w_cut_I_sum_unit[15:0];//010b
    assign                          w_reg010cin        = {{8{w_cut_I_sum_unit[23]}},w_cut_I_sum_unit[23:16]};//010c
    assign                          w_reg010ein        = w_P_avg_20us;
    assign                          w_reg010fin        = w_R_avg_20us;

    assign                          w_reg0111in        = w_U_display[15:0];//0111
    assign                          w_reg0112in        = {{8{w_U_display[23]}},w_U_display[23:16]};//0112
    assign                          w_reg0113in        = w_I_display[15:0];//0113
    assign                          w_reg0114in        = {{8{w_I_display[23]}},w_I_display[23:16]};//0114

    assign                          w_reg01b1in        = w_BATT_U[15:0];//01b1
    assign                          w_reg01b2in        = {{8{w_BATT_U[23]}},w_BATT_U[23:16]};//01b2
    assign                          w_reg01b3in        = w_BATT_R[15:0];//01b3
    assign                          w_reg01b4in        = w_BATT_R[31:16];//01b4
    assign                          w_reg01b5in        = w_BATT_time[15:0];//01b5
    assign                          w_reg01b6in        = w_BATT_time[31:16];//01b6
    assign                          w_reg01b7in        = w_BATT_cap1[15:0];//01b7
    assign                          w_reg01b8in        = w_BATT_cap1[31:16];//01b8
    assign                          w_reg01b9in        = w_BATT_cap2[15:0];//01b9
    assign                          w_reg01bain        = w_BATT_cap2[31:16];//01ba
    assign                          w_reg01bbin        = 0;//01bb
    assign                          w_reg01bcin        = 0;//01bc

    assign                          w_reg01c1in        = i_ch0_temp[31:0];//温度采集第一路
    assign                          w_reg01c2in        = i_ch1_temp[31:0];//温度采集第二路
    assign                          w_reg01c3in        = i_ch2_temp[31:0];//温度采集第三路
    assign                          w_reg01c4in        = i_ch3_temp[31:0];//温度采集第四路
    assign                          w_reg01c5in        = i_ch4_temp[31:0];//温度采集第五路
    assign                          w_reg01c6in        = i_ch5_temp[31:0];//温度采集第六路
    assign                          w_reg01c7in        = i_ch6_temp[31:0];//温度采集第七路
    assign                          w_reg01c8in        = i_ch7_temp[31:0];//温度采集第八路

    assign                          w_reg01d0in[0]     = w_ocp_soft;
    assign                          w_reg01d0in[1]     = w_ocp_maxI_soft;
    assign                          w_reg01d0in[2]     = w_ocp_hardCV;
    assign                          w_reg01d0in[3]     = w_ocp_in_CV;
    assign                          w_reg01d0in[4]     = w_ovp_soft;
    assign                          w_reg01d0in[5]     = w_ovp_maxU_soft;
    assign                          w_reg01d0in[6]     = w_opp_soft;
    assign                          w_reg01d0in[7]     = w_opp_maxP_soft;
    assign                          w_reg01d0in[8]     = w_err_INV;
    assign                          w_reg01d0in[9]     = w_other_err;
    assign                          w_reg01d0in[10]    = w_err_sense;
    assign                          w_reg01d0in[11]    = w_off_err;
    assign                          w_reg01d0in[12]    = w_BATT_cpl;
    assign                          w_reg01d0in[13]    = w_TOCP_cpl;
    assign                          w_reg01d0in[14]    = w_TOPP_cpl;
    assign                          w_reg01d0in[15]    = w_off_cpl;
    assign                          w_reg01d0in[16]    = w_doing_pull_out;

//--------------------------------------------------------------------------------------
// BOARD_UNIT
//--------------------------------------------------------------------------------------
    wire     signed    [  31: 0]    w_I0_BU_display     ;
    wire     signed    [  31: 0]    w_I1_BU_display     ;
    wire     signed    [  31: 0]    w_I2_BU_display     ;
    wire     signed    [  31: 0]    w_I3_BU_display     ;
    wire     signed    [  31: 0]    w_I4_BU_display     ;
    wire     signed    [  31: 0]    w_I5_BU_display     ;
    wire     signed    [  31: 0]    w_I6_BU_display     ;
    wire     signed    [  31: 0]    w_I7_BU_display     ;
    wire     signed    [  31: 0]    w_I0_SU_display     ;
    wire     signed    [  31: 0]    w_I1_SU_display     ;
    wire     signed    [  31: 0]    w_I2_SU_display     ;
    wire     signed    [  31: 0]    w_I3_SU_display     ;
    wire     signed    [  31: 0]    w_I4_SU_display     ;
    wire     signed    [  31: 0]    w_I5_SU_display     ;
    wire     signed    [  31: 0]    w_I6_SU_display     ;
    wire     signed    [  31: 0]    w_I7_SU_display     ;
// output                                  o_en_sample       ,
// output          [2:0]                   o_sel_sample      ,
Gen_I_unit U_Gen_I_unit
(
    .i_clk                          (i_clk              ),
    .i_rst                          (i_rst              ),
								     
    .i_enb_sample                   (w_enb_sample_used  ),
    
    .i_Iboard_unit                  ({{8{w_cut_I_board_unit[23]}},w_cut_I_board_unit[23:0]}),//
    .o_I0board_unit                 (w_I0_BU_display    ),
    .o_I1board_unit                 (w_I1_BU_display    ),
    .o_I2board_unit                 (w_I2_BU_display    ),
    .o_I3board_unit                 (w_I3_BU_display    ),
    .o_I4board_unit                 (w_I4_BU_display    ),
    .o_I5board_unit                 (w_I5_BU_display    ),
    .o_I6board_unit                 (w_I6_BU_display    ),
    .o_I7board_unit                 (w_I7_BU_display    ),
								    
    .i_Isum_unit                    ({{8{w_cut_I_sum_unit[23]}},w_cut_I_sum_unit[23:0]}),//
    .o_I0sum_unit                   (w_I0_SU_display    ),
    .o_I1sum_unit                   (w_I1_SU_display    ),
    .o_I2sum_unit                   (w_I2_SU_display    ),
    .o_I3sum_unit                   (w_I3_SU_display    ),
    .o_I4sum_unit                   (w_I4_SU_display    ),
    .o_I5sum_unit                   (w_I5_SU_display    ),
    .o_I6sum_unit                   (w_I6_SU_display    ),
    .o_I7sum_unit                   (w_I7_SU_display    ),
								    
    .o_en_sample                    (o_en_sample        ),
    .o_sel_sample                   (o_sel_sample       ) 
);
    assign                          w_reg01e1in        = {{8{w_I0_BU_display[23]}},w_I0_BU_display[23:0]};//unit0电流
    assign                          w_reg01e2in        = {{8{w_I1_BU_display[23]}},w_I1_BU_display[23:0]};//unit1电流
    assign                          w_reg01e3in        = {{8{w_I2_BU_display[23]}},w_I2_BU_display[23:0]};//unit2电流
    assign                          w_reg01e4in        = {{8{w_I3_BU_display[23]}},w_I3_BU_display[23:0]};//unit3电流
    assign                          w_reg01e5in        = {{8{w_I4_BU_display[23]}},w_I4_BU_display[23:0]};//unit4电流
    assign                          w_reg01e6in        = {{8{w_I5_BU_display[23]}},w_I5_BU_display[23:0]};//unit5电流
    assign                          w_reg01e7in        = {{8{w_I6_BU_display[23]}},w_I6_BU_display[23:0]};//unit6电流
    assign                          w_reg01e8in        = {{8{w_I7_BU_display[23]}},w_I7_BU_display[23:0]};//unit7电流
    assign                          w_reg01d1in        = {{8{w_I0_SU_display[23]}},w_I0_SU_display[23:0]};//unit0电流
    assign                          w_reg01d2in        = {{8{w_I1_SU_display[23]}},w_I1_SU_display[23:0]};//unit1电流
    assign                          w_reg01d3in        = {{8{w_I2_SU_display[23]}},w_I2_SU_display[23:0]};//unit2电流
    assign                          w_reg01d4in        = {{8{w_I3_SU_display[23]}},w_I3_SU_display[23:0]};//unit3电流
    assign                          w_reg01d5in        = {{8{w_I4_SU_display[23]}},w_I4_SU_display[23:0]};//unit4电流
    assign                          w_reg01d6in        = {{8{w_I5_SU_display[23]}},w_I5_SU_display[23:0]};//unit5电流
    assign                          w_reg01d7in        = {{8{w_I6_SU_display[23]}},w_I6_SU_display[23:0]};//unit6电流
    assign                          w_reg01d8in        = {{8{w_I7_SU_display[23]}},w_I7_SU_display[23:0]};//unit7电流
//--------------------------------------------------------------------------------------
// ila_ctrl
//--------------------------------------------------------------------------------------
    wire                            w_ck_ctrl           ;
    wire               [  31: 0]    w_p0_ctrl           ;

    assign                          w_ck_ctrl          = i_clk;
assign  w_p0_ctrl  = {
w_CV_pull_off,w_CV_pull_on,w_CR_pull_off,w_CR_pull_on,w_CP_pull_off,w_CP_pull_on,w_CC_pull_off,w_CC_pull_on,
s_flag_stop,s_flag_run,w_flag_STOP,w_flag_RUN,s_run_status[15:12],
w_reg01d0in[15:0]
};

// ila_ctrl U_ila_ctrl
// (
//     .clk                            (w_ck_ctrl          ) // input wire clk
//     ,.probe0        ( w_p0_ctrl   )                                 // input wire [31:0]  probe0  
// );

//--------------------------------------------------------------------------------------
// hardCV切换不能发生在拉载过程中
//--------------------------------------------------------------------------------------
// reg                                     s_hardCV_sel_temp ;
// reg                                     s_hardCV_limitsel_temp ;
// reg                                     s_hardCV_speedslow_temp ;
// reg                                     s_hardCV_speedmid_temp ;
// reg                                     s_hardCV_speedfast_temp ;
// reg             [31:0]                  s_cnt_dly_hardCV_sel    =0;
// reg                                     s_sw_temp               =0;
// reg                                     s_hardCV_1r   =0 ;//
// reg                                     s_hardCV_2r   =0 ;//

    wire                            w_CV_pull_on_doing  ;

    assign                          w_CV_pull_on_doing = (s_hardCV_sel_temp) ? w_hard_CV_pull_doing : w_CV_pull_doing;

always @ (posedge i_clk)
begin
    if (w_doing_pull_out == 1'b1)
        begin
            s_cnt_dly_hardCV_sel      <=  s_cnt_dly_hardCV_sel ;
            s_hardCV_sel_temp         <=  s_hardCV_sel_temp       ;
            s_hardCV_speedslow_temp   <=  s_hardCV_speedslow_temp ;
            s_hardCV_speedmid_temp    <=  s_hardCV_speedmid_temp  ;
            s_hardCV_speedfast_temp   <=  s_hardCV_speedfast_temp ;
            s_hardCV_1r <= s_hardCV_1r ;                            //
            s_hardCV_2r <= s_hardCV_2r ;                            //
        end
    else
        begin
            s_hardCV_1r <= w_hard_CV_ON ;                           //
            s_hardCV_2r <= s_hardCV_1r ;                            //
			
            if ((w_modechange == 1) && (s_hardCV_1r == 1) && (CurWorkMode[3] == 1))//模式切换到CV且硬件CV打开
                s_cnt_dly_hardCV_sel <= 'h0 ;
            else if ((s_hardCV_1r == 1) && (s_hardCV_2r == 0) && (CurWorkMode[3] == 1))//CV模式下切换硬件CV
                s_cnt_dly_hardCV_sel <= 'h0 ;
            else if ((s_hardCV_1r == 1) && (CurWorkMode[3] == 1) && (s_cnt_dly_hardCV_sel < 'd20000000))
                s_cnt_dly_hardCV_sel <= s_cnt_dly_hardCV_sel + 'h1 ;
            else if ((s_hardCV_1r == 1) && (CurWorkMode[3] == 1))
                s_cnt_dly_hardCV_sel <= s_cnt_dly_hardCV_sel ;
            else
                s_cnt_dly_hardCV_sel <= 'h0 ;
			
            if ((s_hardCV_1r == 1) && (CurWorkMode[3] == 1) && (s_cnt_dly_hardCV_sel >= 'd10000000))//切换到硬件CV后100ms
                begin
                    s_hardCV_sel_temp         <=  w_hard_CV_ON      ;//CELL_PROG_DA/CV_Hardware_LOOP
                    s_hardCV_speedslow_temp   <=  w_speed_slow_CV   ;//互斥关系
                    s_hardCV_speedmid_temp    <=  w_speed_mid_CV    ;//互斥关系
                    s_hardCV_speedfast_temp   <=  w_speed_fast_CV   ;//互斥关系
                end
            else
                begin
                    s_hardCV_sel_temp         <=  0   ;             //CELL_PROG_DA/CV_Hardware_LOOP
                    s_hardCV_speedslow_temp   <=  0   ;             //互斥关系
                    s_hardCV_speedmid_temp    <=  0   ;             //互斥关系
                    s_hardCV_speedfast_temp   <=  0   ;             //互斥关系
                end
        end
end
always @ (posedge i_clk)
begin
    if (i_rst == 1'b1)
        s_sw_temp <= 0 ;
    else if (w_off_err == 1'b1)
        s_sw_temp <= 0 ;
    else if ((w_doing_pull_out == 1'b0) && (s_hardCV_1r == 1) && (CurWorkMode[3] == 1) && (s_cnt_dly_hardCV_sel < 'd20000000))//切换到硬件CV后200ms
        s_sw_temp <= 0 ;
    else
        s_sw_temp <= 1 ;
end



endmodule
