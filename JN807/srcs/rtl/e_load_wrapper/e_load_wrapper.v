`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             e_load_wrapper.v
// Create Date:           2025/01/03 15:56:33
// Version:               V1.0
// PATH:                  rtl\e_load_wrapper\e_load_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module e_load_wrapper #(
    parameter                       SIMULATION         = 0     ,
    parameter                       C_S_AXI_DATA_WIDTH = 32    ,
    parameter                       C_S_AXI_ADDR_WIDTH = 12    
) (
    input  wire                     sys_clk_i           ,// 100MHz
    input  wire                     rst_n_i             ,
    // ADC signal
    input  wire                     adc_acq_valid_i     ,
    input  wire signed [  15: 0]    I_SUM_H_AD          ,//I_SUM_H_AD----高档位8路板卡汇总电流4.521V
    input  wire signed [  15: 0]    I_SUM_L_AD          ,//I_SUM_L_AD----低档位8路板卡汇总电流
    input  wire signed [  15: 0]    I_BOARD_H_AD        ,//I_BOARD_H_AD----高档位板卡电流4.5V
    input  wire signed [  15: 0]    I_BOARD_L_AD        ,//I_BOARD_L_AD----低档位板卡电流
    input  wire signed [  15: 0]    AD_Vmod             ,//AD_Vmod----非sense端电压
    input  wire signed [  15: 0]    AD_Vsense           ,//AD_Vsense----sense端电压
    input  wire signed [  15: 0]    I_SUM_UNIT_AD       ,//I_SUM_UNIT_AD----单板卡24模块汇总电流4.125V
    input  wire signed [  15: 0]    I_BOARD_UNIT_AD     ,//I_BOARD_UNIT_AD----单板卡单模块电流3.4375V
    // CC/CV环路切换
    output wire                     vin_select_o        ,//0:Vmod 1:Vsense
    output wire                     cc_cv_select_o      ,//1:CELL PROG DA 0:CV HARDWARE LOOP
    output wire                     cv_limit_select_o   ,//1:CV LIMIT DA 0:CV LIMIT PROG
    output wire                     cv_sp_slow_o        ,
    output wire                     cv_sp_mid_o         ,
    output wire                     cv_sp_fast_o        ,
    //cv limit / ocp board
    input  wire                     cv_limit_trig_i     ,//1:normal 0:error 硬件CV时电流控制量PROG大于CV_LIMIT
    input  wire                     ocp_da_trig_i       ,//1:normal 0:error 硬件OCP,暂时没用到
    // DAC signal
    output wire                     dac_ch1_en_o        ,
    output wire        [  15: 0]    dac_ch1_data_o      ,
    output wire                     dac_ch2_en_o        ,
    output wire        [  15: 0]    dac_ch2_data_o      ,
//温度采集值
    input  wire        [  31: 0]    ch0_temp_i          ,
    input  wire        [  31: 0]    ch1_temp_i          ,
    input  wire        [  31: 0]    ch2_temp_i          ,
    input  wire        [  31: 0]    ch3_temp_i          ,
    input  wire        [  31: 0]    ch4_temp_i          ,
    input  wire        [  31: 0]    ch5_temp_i          ,
    input  wire        [  31: 0]    ch6_temp_i          ,
    input  wire        [  31: 0]    ch7_temp_i          ,
//单元电流值选择
    output wire                     en_sample_o         ,
    output wire        [   2: 0]    sel_sample_o        ,
//输出保护开关
    output reg                      hardware_lock_off_o ,//高代表正常(sw短路，硬件不保护)，低代表sw开路硬件保护 hardward lock off
//正负电源检测（延时检测）
    input  wire                     vop_negedge_i       ,//1 error . 0 normal .正电压检测
    input  wire                     vop_posedge_i       ,//1 error . 0 normal .负电压检测
//V高低档采样切换开关默认高档位
    output wire                     vmod_l_sw_o         ,//Vmod_H/L_SW_FPGA
    output wire                     vsense_l_sw_o       ,//Vsense_H/L_SW_FPGA
//并机控制
    input  wire                     mcu_alarm_i         ,//axi_gpio
    input  wire                     i_mcu_syn           ,//axi_gpio
    inout  wire                     io_trig1            ,
    inout  wire                     io_trig2            ,
    output wire                     o_m_s               ,// master_slave flag 1:主机 0:从机
//并机时cv
    output wire                     p_sw1               ,//单机，sw1(0),sw2(0)
    output wire                     p_sw2               ,//主机，sw1(0),sw2(1)，从机，sw1(1),sw2(1)
	// User ports ends
    input  wire        [C_S_AXI_ADDR_WIDTH-1: 0]S_AXI_AWADDR,
    input  wire        [   2: 0]    S_AXI_AWPROT        ,
    input  wire                     S_AXI_AWVALID       ,
    output wire                     S_AXI_AWREADY       ,
    input  wire        [C_S_AXI_DATA_WIDTH-1: 0]S_AXI_WDATA,
    input  wire        [(C_S_AXI_DATA_WIDTH/8)-1: 0]S_AXI_WSTRB,
    input  wire                     S_AXI_WVALID        ,
    output wire                     S_AXI_WREADY        ,
    output wire        [   1: 0]    S_AXI_BRESP         ,
    output wire                     S_AXI_BVALID        ,
    input  wire                     S_AXI_BREADY        ,
    input  wire        [C_S_AXI_ADDR_WIDTH-1: 0]S_AXI_ARADDR,
    input  wire        [   2: 0]    S_AXI_ARPROT        ,
    input  wire                     S_AXI_ARVALID       ,
    output wire                     S_AXI_ARREADY       ,
    output wire        [C_S_AXI_DATA_WIDTH-1: 0]S_AXI_RDATA,
    output wire        [   1: 0]    S_AXI_RRESP         ,
    output wire                     S_AXI_RVALID        ,
    input  wire                     S_AXI_RREADY         
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declaration
//---------------------------------------------------------------------
    localparam                      CALCULATE_WIDTH    = 24    ;
    localparam                      AXI_REG_WIDTH      = 24    ;
    localparam                      CALI_WIDTH         = 16    ;
    localparam                      WORKMOD_CC         = 16'h5a5a;
    localparam                      WORKMOD_CV         = 16'ha5a5;
    localparam                      WORKMOD_CP         = 16'h5a00;
    localparam                      WORKMOD_CR         = 16'h005a;
    
    localparam                      FUNC_STA           = 16'h5a00;
    localparam                      FUNC_DYN           = 16'ha500;
    localparam                      FUNC_LIST          = 16'h5aFF;
    localparam                      FUNC_TOCP          = 16'h5a3C;
    localparam                      FUNC_TOPP          = 16'h5AC3;

    wire                            ram_wr_en           ;
    wire               [C_S_AXI_ADDR_WIDTH-1: 0]ram_wr_addr  ;
    wire               [(C_S_AXI_DATA_WIDTH/8)-1: 0]ram_wr_wstrb  ;
    wire               [C_S_AXI_DATA_WIDTH-1: 0]ram_wr_data  ;
    wire                            ram_rd_en           ;
    wire               [C_S_AXI_ADDR_WIDTH-1: 0]ram_rd_addr  ;
    wire               [C_S_AXI_DATA_WIDTH-1: 0]ram_rd_data  ;

    wire               [16-1: 0]    Workmod             ;
    wire               [16-1: 0]    Func                ;
    wire               [16-1: 0]    SENSE               ;
    wire               [16-1: 0]    Model               ;
    wire               [16-1: 0]    Worktype            ;
    wire               [16-1: 0]    M_S                 ;
    wire               [16-1: 0]    Clear_alarm         ;
    wire               [16-1: 0]    RUN_flag            ;
    wire               [16-1: 0]    Short               ;
    wire               [32-1: 0]    Von                 ;
    wire               [32-1: 0]    SR_slew             ;
    wire               [32-1: 0]    SF_slew             ;
    wire               [16-1: 0]    sense_err_threshold  ;
    wire               [16-1: 0]    Von_Latch           ;
    wire               [32-1: 0]    Voff                ;
    wire               [32-1: 0]    Iset_L              ;
    wire               [32-1: 0]    Iset_H              ;
    wire               [32-1: 0]    Vset_L              ;
    wire               [32-1: 0]    Vset_H              ;
    wire               [32-1: 0]    Pset_L              ;
    wire               [32-1: 0]    Pset_H              ;
    wire               [32-1: 0]    Rset_L              ;
    wire               [32-1: 0]    Rset_H              ;
    wire               [32-1: 0]    Iset1_L             ;
    wire               [32-1: 0]    Iset1_H             ;
    wire               [32-1: 0]    Iset2_L             ;
    wire               [32-1: 0]    Iset2_H             ;
    wire               [32-1: 0]    Vset1_L             ;
    wire               [32-1: 0]    Vset1_H             ;
    wire               [32-1: 0]    Vset2_L             ;
    wire               [32-1: 0]    Vset2_H             ;
    wire               [32-1: 0]    Pset1_L             ;
    wire               [32-1: 0]    Pset1_H             ;
    wire               [32-1: 0]    Pset2_L             ;
    wire               [32-1: 0]    Pset2_H             ;
    wire               [32-1: 0]    Rset1_L             ;
    wire               [32-1: 0]    Rset1_H             ;
    wire               [32-1: 0]    Rset2_L             ;
    wire               [32-1: 0]    Rset2_H             ;
    wire               [32-1: 0]    DR_slew             ;
    wire               [32-1: 0]    DF_slew             ;
    wire               [16-1: 0]    Vrange              ;
    wire               [32-1: 0]    CVspeed             ;
    wire               [32-1: 0]    CV_slew             ;
    wire               [32-1: 0]    filter_period       ;
    wire               [32-1: 0]    num_paral           ;
    wire               [32-1: 0]    I_lim_L             ;
    wire               [32-1: 0]    I_lim_H             ;
    wire               [32-1: 0]    V_lim_L             ;
    wire               [32-1: 0]    V_lim_H             ;
    wire               [32-1: 0]    P_lim_L             ;
    wire               [32-1: 0]    P_lim_H             ;
    wire               [32-1: 0]    CV_lim_L            ;
    wire               [32-1: 0]    CV_lim_H            ;
    wire               [32-1: 0]    Pro_time            ;
    wire               [32-1: 0]    VH_k                ;
    wire               [32-1: 0]    VH_a                ;
    wire               [32-1: 0]    VsH_k               ;
    wire               [32-1: 0]    VsH_a               ;
    wire               [32-1: 0]    I1_k                ;
    wire               [32-1: 0]    I1_a                ;
    wire               [32-1: 0]    I2_k                ;
    wire               [32-1: 0]    I2_a                ;
    wire               [32-1: 0]    VL_k                ;
    wire               [32-1: 0]    VL_a                ;
    wire               [32-1: 0]    VsL_k               ;
    wire               [32-1: 0]    VsL_a               ;
    wire               [32-1: 0]    It1_k               ;
    wire               [32-1: 0]    It1_a               ;
    wire               [32-1: 0]    It2_k               ;
    wire               [32-1: 0]    It2_a               ;

    wire               [32-1: 0]    CC_k                ;
    wire               [32-1: 0]    CC_a                ;
    wire               [32-1: 0]    CVH_k               ;
    wire               [32-1: 0]    CVH_a               ;
    wire               [32-1: 0]    CVL_k               ;
    wire               [32-1: 0]    CVL_a               ;
    wire               [32-1: 0]    CVHs_k              ;
    wire               [32-1: 0]    CVHs_a              ;
    wire               [32-1: 0]    CVLs_k              ;
    wire               [32-1: 0]    CVLs_a              ;

    wire               [32-1: 0]    s_k                 ;
    wire               [32-1: 0]    s_a                 ;
    wire               [32-1: 0]    m_k                 ;
    wire               [32-1: 0]    m_a                 ;
    wire               [32-1: 0]    f_k                 ;
    wire               [32-1: 0]    f_a                 ;
    wire               [32-1: 0]    CV_mode             ;
    wire               [32-1: 0]    T1_L_cc             ;
    wire               [32-1: 0]    T1_H_cc             ;
    wire               [32-1: 0]    T2_L_cc             ;
    wire               [32-1: 0]    T2_H_cc             ;
    wire               [32-1: 0]    Dyn_trig_mode       ;
    wire               [32-1: 0]    Dyn_trig_source     ;
    wire               [32-1: 0]    Dyn_trig_gen        ;
    wire               [32-1: 0]    BT_STOP             ;
    wire               [32-1: 0]    VB_stop_L           ;
    wire               [32-1: 0]    VB_stop_H           ;
    wire               [32-1: 0]    TB_stop_L           ;
    wire               [32-1: 0]    TB_stop_H           ;
    wire               [32-1: 0]    CB_stop_L           ;
    wire               [32-1: 0]    CB_stop_H           ;
    wire               [32-1: 0]    VB_pro_L            ;
    wire               [32-1: 0]    VB_pro_H            ;
    wire               [32-1: 0]    TOCP_Von_set_L      ;
    wire               [32-1: 0]    TOCP_Von_set_H      ;
    wire               [32-1: 0]    TOCP_Istart_set_L   ;
    wire               [32-1: 0]    TOCP_Istartl_set_H  ;
    wire               [32-1: 0]    TOCP_Icut_set_L     ;
    wire               [32-1: 0]    TOCP_Icut_set_H     ;
    wire               [32-1: 0]    TOCP_Istep_set      ;
    wire               [32-1: 0]    TOCP_Tstep_set      ;
    wire               [32-1: 0]    TOCP_Vcut_set_L     ;
    wire               [32-1: 0]    TOCP_Vcut_set_H     ;
    wire               [32-1: 0]    TOCP_Imin_set_L     ;
    wire               [32-1: 0]    TOCP_Imin_set_H     ;
    wire               [32-1: 0]    TOCP_Imax_set_L     ;
    wire               [32-1: 0]    TOCP_Imax_set_H     ;
    reg                [32-1: 0]    TOCP_I_L            ;
    reg                [32-1: 0]    TOCP_I_H            ;
    wire               [32-1: 0]    TOPP_Von_set_L      ;
    wire               [32-1: 0]    TOPP_Von_set_H      ;
    wire               [32-1: 0]    TOPP_Pstart_set_L   ;
    wire               [32-1: 0]    TOPP_Pstart_set_H   ;
    wire               [32-1: 0]    TOPP_Pcut_set_L     ;
    wire               [32-1: 0]    TOPP_Pcut_set_H     ;
    wire               [32-1: 0]    TOPP_Pstep_set      ;
    wire               [32-1: 0]    TOPP_Tstep_set      ;
    wire               [32-1: 0]    TOPP_Vcut_set_L     ;
    wire               [32-1: 0]    TOPP_Vcut_set_H     ;
    wire               [32-1: 0]    TOPP_Pmin_set_L     ;
    wire               [32-1: 0]    TOPP_Pmin_set_H     ;
    wire               [32-1: 0]    TOPP_Pmax_set_L     ;
    wire               [32-1: 0]    TOPP_Pmax_set_H     ;
    reg                [32-1: 0]    TOPP_P_L            ;
    reg                [32-1: 0]    TOPP_P_H            ;
    wire               [32-1: 0]    Stepnum             ;
    wire               [32-1: 0]    Count               ;
    wire               [32-1: 0]    Step                ;
    wire               [32-1: 0]    Mode                ;
    wire               [32-1: 0]    Value_L             ;
    wire               [32-1: 0]    Value_H             ;
    wire               [32-1: 0]    Tstep_L             ;
    wire               [32-1: 0]    Tstep_H             ;
    wire               [32-1: 0]    Repeat              ;
    wire               [32-1: 0]    Goto                ;
    wire               [32-1: 0]    Loops               ;
    wire               [32-1: 0]    Save_step           ;

    wire               [16-1: 0]    rd_Fault_status     ;//0x200 错误状态
    reg                [16-1: 0]    rd_Run_status       ;
    reg                [32-1: 0]    rd_TOCP_result      ;
    reg                [32-1: 0]    rd_TOPP_result      ;

    reg                [32-1: 0]    rd_Repeat_now       ;
    reg                [32-1: 0]    rd_Count_now        ;
    reg                [32-1: 0]    rd_Step_now         ;
    reg                [32-1: 0]    rd_Loops_now        ;
    reg                [32-1: 0]    rd_I_Board_L_l      ;
    reg                [32-1: 0]    rd_I_Board_L_h      ;
    reg                [32-1: 0]    rd_I_Board_H_l      ;
    reg                [32-1: 0]    rd_I_Board_H_h      ;
    reg                [32-1: 0]    rd_I_SUM_Total_L_l  ;
    reg                [32-1: 0]    rd_I_SUM_Total_L_h  ;
    reg                [32-1: 0]    rd_I_SUM_Total_H_l  ;
    reg                [32-1: 0]    rd_I_SUM_Total_H_h  ;
    reg                [32-1: 0]    rd_I_Board_unit_l   ;
    reg                [32-1: 0]    rd_I_Board_unit_h   ;
    reg                [32-1: 0]    rd_I_Sum_unit_l     ;
    reg                [32-1: 0]    rd_I_Sum_unit_h     ;
    reg                [32-1: 0]    rd_P_rt             ;
    reg                [32-1: 0]    rd_R_rt             ;
    reg                [32-1: 0]    rd_V_L              ;
    reg                [32-1: 0]    rd_V_H              ;
    reg                [32-1: 0]    rd_I_L              ;
    reg                [32-1: 0]    rd_I_H              ;
    reg                [32-1: 0]    Vopen_L             ;
    reg                [32-1: 0]    Vopen_H             ;
    reg                [32-1: 0]    Ri_L                ;
    reg                [32-1: 0]    Ri_H                ;
    reg                [32-1: 0]    TB_L                ;
    reg                [32-1: 0]    TB_H                ;
    reg                [32-1: 0]    Cap1_L              ;
    reg                [32-1: 0]    Cap1_H              ;
    reg                [32-1: 0]    Cap2_L              ;
    reg                [32-1: 0]    Cap2_H              ;
    reg                [32-1: 0]    Tpro_L              ;
    reg                [32-1: 0]    Tpro_H              ;
    wire               [32-1: 0]    temperature_0       ;
    wire               [32-1: 0]    temperature_1       ;
    wire               [32-1: 0]    temperature_2       ;
    wire               [32-1: 0]    temperature_3       ;
    wire               [32-1: 0]    temperature_4       ;
    wire               [32-1: 0]    temperature_5       ;
    wire               [32-1: 0]    temperature_6       ;
    wire               [32-1: 0]    temperature_7       ;
    wire               [32-1: 0]    SUM_UNIT_0          ;
    wire               [32-1: 0]    SUM_UNIT_1          ;
    wire               [32-1: 0]    SUM_UNIT_2          ;
    wire               [32-1: 0]    SUM_UNIT_3          ;
    wire               [32-1: 0]    SUM_UNIT_4          ;
    wire               [32-1: 0]    SUM_UNIT_5          ;
    wire               [32-1: 0]    SUM_UNIT_6          ;
    wire               [32-1: 0]    SUM_UNIT_7          ;
    wire               [32-1: 0]    BOARD_UNIT_0        ;
    wire               [32-1: 0]    BOARD_UNIT_1        ;
    wire               [32-1: 0]    BOARD_UNIT_2        ;
    wire               [32-1: 0]    BOARD_UNIT_3        ;
    wire               [32-1: 0]    BOARD_UNIT_4        ;
    wire               [32-1: 0]    BOARD_UNIT_5        ;
    wire               [32-1: 0]    BOARD_UNIT_6        ;
    wire               [32-1: 0]    BOARD_UNIT_7        ;
    reg                [32-1: 0]    Version_number      ;


    wire                            Clear_alarm_ON      ;
    wire                            Short_ON            ;
    wire                            RUN_flag_ON         ;
    wire                            Von_Latch_ON        ;
    wire                            SENSE_ON            ;
    wire                            U_gear_H_ON         ;
    wire                            I_gear_H_ON         ;
    wire                            I_sum_ON            ;//拉高时切换到I_sum作为采样电流，默认为0
    wire                            CV_mode_hard_ON     ;

    wire               [  31: 0]    Iset                ;
    wire               [  31: 0]    Vset                ;
    wire               [  31: 0]    Pset                ;
    wire               [  31: 0]    Rset                ;
    wire               [  31: 0]    Iset1               ;
    wire               [  31: 0]    Iset2               ;
    wire               [  31: 0]    Vset1               ;
    wire               [  31: 0]    Vset2               ;
    wire               [  31: 0]    Pset1               ;
    wire               [  31: 0]    Pset2               ;
    wire               [  31: 0]    Rset1               ;
    wire               [  31: 0]    Rset2               ;

    wire               [  31: 0]    I_limit             ;
    wire               [  31: 0]    V_limit             ;
    wire               [  31: 0]    P_limit             ;
    wire               [  31: 0]    CV_limit            ;

    wire               [  31: 0]    T1                  ;
    wire               [  31: 0]    T2                  ;

    wire     signed    [  15: 0]    CV_k                ;//CV模式K
    wire     signed    [  15: 0]    CV_a                ;//CV模式A
    
    wire               [  15: 0]    KP                  ;
    wire               [  15: 0]    KI                  ;
    
    wire                            ovp_maxU_alarm      ;
    wire                            ocp_maxI_alarm      ;
    wire                            ocp_alarm           ;
    wire                            opp_maxP_alarm      ;
    wire                            opp_alarm           ;
    wire                            sense_error         ;
    wire                            Umod_inv_alarm      ;
    wire                            Usense_inv_alarm    ;

    wire                            VOP_alarm           ;
(*ASYNC_REG = "true"*)
    reg                             vop_negedge_r1,vop_negedge_r2  ;//1 error . 0 normal .正电压检测
(*ASYNC_REG = "true"*)
    reg                             vop_posedge_r1,vop_posedge_r2  ;//1 error . 0 normal .负电压检测

    wire                            cv_hard_lock_off_en  ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// assigns
//---------------------------------------------------------------------
    assign                          RUN_flag_ON        = (RUN_flag == 16'h5a5a);
    assign                          Short_ON           = (Short == 16'h5a5a) ? 1'b1 : 1'b0;
    assign                          Von_Latch_ON       = (Von_Latch == 16'h5a5a) ? 1'b1 : 1'b0;
    assign                          Clear_alarm_ON     = (Clear_alarm == 16'h5a5a);

    assign                          SENSE_ON           = (SENSE == 16'ha5a5) ? 1'b1 : 1'b0;
    assign                          U_gear_H_ON        = (Vrange == 16'h5a5a) ? 1'b1 : 1'b0;
    assign                          I_sum_ON           = 0;
    // assign                       I_gear_H_ON        = 单独设计;//自动切换挡位
    assign                          CV_mode_hard_ON    = CV_mode[0];//软件CV、硬件CV选择，默认0，软件CV

    assign                          vmod_l_sw_o        = ~U_gear_H_ON;
    assign                          vsense_l_sw_o      = ~U_gear_H_ON;
    assign                          vin_select_o       = SENSE_ON;

    assign                          Iset               = {Iset_H[15:0],Iset_L[15:0]};
    assign                          Vset               = {Vset_H[15:0],Vset_L[15:0]};
    assign                          Pset               = {Pset_H[15:0],Pset_L[15:0]};
    assign                          Rset               = {Rset_H[15:0],Rset_L[15:0]};
    assign                          Iset1              = {Iset1_H[15:0],Iset1_L[15:0]};
    assign                          Iset2              = {Iset2_H[15:0],Iset2_L[15:0]};
    assign                          Vset1              = {Vset1_H[15:0],Vset1_L[15:0]};
    assign                          Vset2              = {Vset2_H[15:0],Vset2_L[15:0]};
    assign                          Pset1              = {Pset1_H[15:0],Pset1_L[15:0]};
    assign                          Pset2              = {Pset2_H[15:0],Pset2_L[15:0]};
    assign                          Rset1              = {Rset1_H[15:0],Rset1_L[15:0]};
    assign                          Rset2              = {Rset2_H[15:0],Rset2_L[15:0]};

    assign                          I_limit            = {I_lim_H[15:0],I_lim_L[15:0]};
    assign                          V_limit            = {V_lim_H[15:0],V_lim_L[15:0]};
    assign                          P_limit            = {P_lim_H[15:0],P_lim_L[15:0]};
    assign                          CV_limit           = {CV_lim_H[15:0],CV_lim_L[15:0]};

    assign                          T1                 = {T1_H_cc[15:0],T1_L_cc[15:0]};
    assign                          T2                 = {T2_H_cc[15:0],T2_L_cc[15:0]};


    assign                          temperature_0      = ch0_temp_i;
    assign                          temperature_1      = ch1_temp_i;
    assign                          temperature_2      = ch2_temp_i;
    assign                          temperature_3      = ch3_temp_i;
    assign                          temperature_4      = ch4_temp_i;
    assign                          temperature_5      = ch5_temp_i;
    assign                          temperature_6      = ch6_temp_i;
    assign                          temperature_7      = ch7_temp_i;
//报警信息
    assign                          rd_Fault_status    = {
        4'd0, VOP_alarm, 1'b0/*TOPP_stop*/, 1'b0/*TOCP_stop*/, 1'b0/*电池*/, sense_error, (Umod_inv_alarm | Usense_inv_alarm),
        mcu_alarm_i, ovp_maxU_alarm, ocp_alarm, ocp_maxI_alarm, opp_alarm, opp_maxP_alarm
    };

    assign                          VOP_alarm          = vop_negedge_r2 || vop_posedge_r2;

// ********************************************************************************** // 
//---------------------------------------------------------------------
// simple logic
//---------------------------------------------------------------------
// async to sync
always@(posedge sys_clk_i)begin
    vop_negedge_r1 <= vop_negedge_i;
    vop_negedge_r2 <= vop_negedge_r1;

    vop_posedge_r1 <= vop_posedge_i;
    vop_posedge_r2 <= vop_posedge_r1;
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i)
        hardware_lock_off_o <= 'd0;
    else if ((rd_Fault_status[7:0] != 'd0) || cv_hard_lock_off_en || VOP_alarm)//出现错误,或者，切换到硬件CV模式20ms后，开启硬件保护
        hardware_lock_off_o <= 'd0;
    else
        hardware_lock_off_o <= 'd1;                                 //正常情况不保护
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// cali and calculate absolute value
//---------------------------------------------------------------------
    wire                            adc_cali_valid      ;
    wire     signed    [CALCULATE_WIDTH-1: 0]U_cali     ;
    wire     signed    [CALCULATE_WIDTH-1: 0]I_cali     ;
    wire     signed    [CALCULATE_WIDTH-1: 0]Umod_cali  ;
    wire     signed    [CALCULATE_WIDTH-1: 0]Usense_cali  ;
    wire     signed    [CALCULATE_WIDTH-1: 0]I_board_L_cali  ;//borad 低档电流，校准后的值
    wire     signed    [CALCULATE_WIDTH-1: 0]I_board_H_cali  ;//board 高档电流，校准后的值
    wire     signed    [CALCULATE_WIDTH-1: 0]I_sum_L_cali  ;//sum 低档电流，校准后的值
    wire     signed    [CALCULATE_WIDTH-1: 0]I_sum_H_cali  ;//sum 高档电流，校准后的值
    wire     signed    [CALCULATE_WIDTH-1: 0]I_sum_unit_cali  ;//sum_unit电流，校准后的值
    wire     signed    [CALCULATE_WIDTH-1: 0]I_board_unit_cali  ;//board_unit电流，校准后的值
     
    wire               [CALCULATE_WIDTH-1: 0]U_cali_abs  ;
    wire               [CALCULATE_WIDTH-1: 0]I_cali_abs  ;

get_I_gear#(
    .I_WATERSHED                    (20_000             ),//电流挡位切换分水岭20A
    .I_STANDARD_DEVIATION           (1_000              ) //标准差1A
)
 u_get_I_gear(
    .sys_clk_i                      (sys_clk_i          ),// clk100m
    .rst_n_i                        (rst_n_i            ),
    .I_cali_abs_i                   (I_cali_abs         ),
    .I_gear_H_ON_o                  (I_gear_H_ON        ) // 高代表高档
);

adc_Volt_Curr_Cali_wrapper#(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ),
    .CALI_WIDTH                     (16                 ) 
)
 u_adc_Volt_Curr_Cali_wrapper(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    // ADC signal
    .adc_acq_valid_i                (adc_acq_valid_i    ),
    .I_SUM_H_AD                     (I_SUM_H_AD         ),// I_SUM_H_AD----高档位8路板卡汇总电流4.521V
    .I_SUM_L_AD                     (I_SUM_L_AD         ),// I_SUM_L_AD----低档位8路板卡汇总电流
    .I_BOARD_H_AD                   (I_BOARD_H_AD       ),// I_BOARD_H_AD----高档位板卡电流4.5V
    .I_BOARD_L_AD                   (I_BOARD_L_AD       ),// I_BOARD_L_AD----低档位板卡电流
    .AD_Vmod                        (AD_Vmod            ),// AD_Vmod----非sense端电压
    .AD_Vsense                      (AD_Vsense          ),// AD_Vsense----sense端电压
    .I_SUM_UNIT_AD                  (I_SUM_UNIT_AD      ),// I_SUM_UNIT_AD----单板卡24模块汇总电流4.125V
    .I_BOARD_UNIT_AD                (I_BOARD_UNIT_AD    ),// I_BOARD_UNIT_AD----单板卡单模块电流3.4375V
    // 电压电流选择参数控制
    .SENSE_ON_i                     (SENSE_ON           ),
    .U_gear_H_ON_i                  (U_gear_H_ON        ),
    .I_sum_ON_i                     (I_sum_ON           ),
    .I_gear_H_ON_i                  (I_gear_H_ON        ),
    // cali系数
    .VH_k                           (VH_k               ),// VH_k：电压mod高档校准（默认值:39219）
    .VH_a                           (VH_a               ),
    .VsH_k                          (VsH_k              ),// VsH_k：电压sense采样高档校准（默认值: 0X ）
    .VsH_a                          (VsH_a              ),
    .I1_k                           (I1_k               ),// I_Board_H高档校准（默认值: 57870）
    .I1_a                           (I1_a               ),
    .I2_k                           (I2_k               ),// I_Board_L低档校准（默认值: 5787）
    .I2_a                           (I2_a               ),
    .VL_k                           (VL_k               ),// VL_k：电压采样低档校准（默认值: 3565）
    .VL_a                           (VL_a               ),
    .VsL_k                          (VsL_k              ),// VsL_k：电压sense采样低档校准（默认值: 0X ）
    .VsL_a                          (VsL_a              ),
    .It1_k                          (It1_k              ),// It1_k：总电流高档I_SUM_Total_H校准（默认值: 55298）
    .It1_a                          (It1_a              ),
    .It2_k                          (It2_k              ),// It2_k：总电流低档I_SUM_Total_L校准（默认值: 5530）
    .It2_a                          (It2_a              ),

    .CVH_k                          (CVH_k              ),//CV模式高档校准（默认值: 0X ）
    .CVH_a                          (CVH_a              ),
    .CVL_k                          (CVL_k              ),//CV模式低档校准（默认值: 0X ）
    .CVL_a                          (CVL_a              ),
    .CVHs_k                         (CVHs_k             ),//CV模式sense高档校准（默认值: 0X ）
    .CVHs_a                         (CVHs_a             ),
    .CVLs_k                         (CVLs_k             ),//CV模式sense低档校准（默认值: 0X ）
    .CVLs_a                         (CVLs_a             ),
    .CV_k                           (CV_k               ),//CV模式K
    .CV_a                           (CV_a               ),//CV模式A
    //校准后的结果输出
    .adc_cali_valid_o               (adc_cali_valid     ),
    .U_cali_o                       (U_cali             ),// 电压，校准后的值
    .I_cali_o                       (I_cali             ),// 电流，校准后的值
    .Umod_cali_o                    (Umod_cali          ),// 端口电压，校准后的值
    .Usense_cali_o                  (Usense_cali        ),// Sense电流，校准后的值
    .I_board_L_cali_o               (I_board_L_cali     ),// borad 低档电流，校准后的值
    .I_board_H_cali_o               (I_board_H_cali     ),// board 高档电流，校准后的值
    .I_sum_L_cali_o                 (I_sum_L_cali       ),// sum 低档电流，校准后的值
    .I_sum_H_cali_o                 (I_sum_H_cali       ),// sum 高档电流，校准后的值
    .I_sum_unit_cali_o              (I_sum_unit_cali    ),// sum_unit电流，校准后的值
    .I_board_unit_cali_o            (I_board_unit_cali  ),// board_unit电流，校准后的值
    .U_cali_abs_o                   (U_cali_abs         ),// 电压，校准后的绝对值
    .I_cali_abs_o                   (I_cali_abs         ) // 电流，校准后的绝对值
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计算实时功率和电阻
//---------------------------------------------------------------------
    wire     signed    [  31: 0]    P_rt                ;
    wire     signed    [  31: 0]    R_rt                ;

get_rt_uipr#(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ),
    .AXI_REG_WIDTH                  (AXI_REG_WIDTH      ) 
)
u_get_rt_uipr(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
//实时的采样数据
    .U_abs_i                        (U_cali_abs         ),// 实时采样电压
    .I_abs_i                        (I_cali_abs         ),// 实时采样电流
    .P_rt_o                         (P_rt               ),
    .R_rt_o                         (R_rt               ) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// 均值滤波
//---------------------------------------------------------------------
    wire                            adc_cali_mean_valid  ;
    wire     signed    [CALCULATE_WIDTH-1: 0]U_cali_mean  ;
    wire     signed    [CALCULATE_WIDTH-1: 0]I_cali_mean  ;
    wire     signed    [CALCULATE_WIDTH-1: 0]U_cali_mean_abs  ;
    wire     signed    [CALCULATE_WIDTH-1: 0]I_cali_mean_abs  ;

filtering_wrapper#(
    .MEAN_FILTER_LENGTH             (4                  ),
    .DATA_WIDTH                     (CALCULATE_WIDTH    ) 
)
u_filtering_wrapper(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
//校准后的结果输入
    .adc_cali_valid_i               (adc_cali_valid     ),
    .U_cali_i                       (U_cali             ),// 电压，校准后的值
    .I_cali_i                       (I_cali             ),// 电流，校准后的值
//滤波后输出
    .adc_cali_mean_valid_o          (adc_cali_mean_valid),
    .U_cali_mean_o                  (U_cali_mean        ),// 电压,滤波后的值
    .I_cali_mean_o                  (I_cali_mean        ),// 电流,滤波后的值
    .U_cali_mean_abs_o              (U_cali_mean_abs    ),// 电压,滤波后的绝对值
    .I_cali_mean_abs_o              (I_cali_mean_abs    ) // 电流,滤波后的绝对值
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 得到机型最大电压电流等参数
//---------------------------------------------------------------------
    wire               [  31: 0]    U_max               ;
    wire               [  31: 0]    I_max               ;
    wire               [  31: 0]    P_max               ;
    wire               [  31: 0]    R_max               ;

    wire               [AXI_REG_WIDTH-1: 0]I_short      ;

get_max_uipr u_get_max_uipr(
    .sys_clk_i                      (sys_clk_i          ),
    .Model_i                        (Model              ),
    .U_max_o                        (U_max              ),
    .I_max_o                        (I_max              ),
    .P_max_o                        (P_max              ),
    .R_max_o                        (R_max              ) 
);

get_I_short#(
    .AXI_REG_WIDTH                  (AXI_REG_WIDTH      ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_get_I_short(
    .sys_clk_i                      (sys_clk_i          ),
    .U_abs_i                        (U_cali_mean_abs    ),
    .I_max_i                        (I_max              ),
    .P_max_i                        (P_max              ),
    .I_limit_i                      (I_limit            ),
    .P_limit_i                      (P_limit            ),
    .I_short_o                      (I_short            ) 
);

get_cv_speed u_get_cv_speed(
    .sys_clk_i                      (sys_clk_i          ),
    .CVspeed_i                      (CVspeed            ),
    .s_k                            (s_k                ),
    .s_a                            (s_a                ),
    .m_k                            (m_k                ),
    .m_a                            (m_a                ),
    .f_k                            (f_k                ),
    .f_a                            (f_a                ),
    .KP                             (KP                 ),
    .KI                             (KI                 ),
    .cv_sp_slow_o                   (cv_sp_slow_o       ),
    .cv_sp_mid_o                    (cv_sp_mid_o        ),
    .cv_sp_fast_o                   (cv_sp_fast_o       ) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// 主要功能实现
//---------------------------------------------------------------------
    wire                            global_1us_flag     ;
    wire                            pull_on             ;
    wire                            pull_precharge_en   ;
    wire               [  31: 0]    pull_target         ;
    wire               [  31: 0]    pull_initI          ;
    wire               [  31: 0]    pull_limitI         ;
    wire                            pull_on_doing       ;
    wire               [AXI_REG_WIDTH-1: 0]pull_Rslew   ;
    wire               [AXI_REG_WIDTH-1: 0]pull_Fslew   ;
    wire                            dac_data_valid      ;
    wire               [  15: 0]    dac_data            ;
    wire               [  15: 0]    dac_data_limit      ;

    assign                          dac_ch1_en_o       = dac_data_valid;
    assign                          dac_ch1_data_o     = dac_data;
    assign                          dac_ch2_en_o       = dac_data_valid;
    assign                          dac_ch2_data_o     = dac_data_limit;

main_ctrl_pull_load#(
    .SIMULATION                     (SIMULATION         ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ),
    .AXI_REG_WIDTH                  (AXI_REG_WIDTH      ),
    .PRECHARGE_TIME                 (38                 ),//单位us，38MS预充电时间，仿真设为38加快预充电时间

    .WORKMOD_CC                     (WORKMOD_CC         ),
    .WORKMOD_CV                     (WORKMOD_CV         ),
    .WORKMOD_CP                     (WORKMOD_CP         ),
    .WORKMOD_CR                     (WORKMOD_CR         ),

    .FUNC_STA                       (FUNC_STA           ),
    .FUNC_DYN                       (FUNC_DYN           ),
    .FUNC_LIST                      (FUNC_LIST          ),
    .FUNC_TOCP                      (FUNC_TOCP          ),
    .FUNC_TOPP                      (FUNC_TOPP          ) 
)
u_main_ctrl_pull_load(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .RUN_flag_ON_i                  (RUN_flag_ON        ),
    .Von_Latch_ON_i                 (Von_Latch_ON       ),
    .Workmod_i                      (Workmod            ),
    .Func_i                         (Func               ),
    .global_1us_flag_o              (global_1us_flag    ),
    .Von_i                          (Von                ),// 启动电压
    .Voff_i                         (Voff               ),// 截至电压
    .Iset_i                         (Iset               ),
    .Vset_i                         (Vset               ),
    .Pset_i                         (Pset               ),
    .Rset_i                         (Rset               ),
    .Iset1_i                        (Iset1              ),
    .Iset2_i                        (Iset2              ),
    .Vset1_i                        (Vset1              ),
    .Vset2_i                        (Vset2              ),
    .Pset1_i                        (Pset1              ),
    .Pset2_i                        (Pset2              ),
    .Rset1_i                        (Rset1              ),
    .Rset2_i                        (Rset2              ),
    .SR_slew_i                      (SR_slew            ),// 电流上升斜率单位1mA/ms 需要保护
    .SF_slew_i                      (SF_slew            ),// 电流下降斜率单位1mA/ms 需要保护
    .DR_slew_i                      (DR_slew            ),// 电流上升斜率单位1mA/ms 需要保护
    .DF_slew_i                      (DF_slew            ),// 电流下降斜率单位1mA/ms 需要保护
    .I_limit_i                      (I_limit            ),
    .V_limit_i                      (V_limit            ),
    .P_limit_i                      (P_limit            ),
    .CV_limit_i                     (CV_limit           ),
    .Pro_time_i                     (Pro_time           ),
    .T1_i                           (T1                 ),
    .T2_i                           (T2                 ),
//CC拉载                             
    .pull_on_o                      (pull_on            ),
    .pull_precharge_en_o            (pull_precharge_en  ),
    .pull_target_o                  (pull_target        ),
    .pull_initI_o                   (pull_initI         ),
    .pull_limitI_o                  (pull_limitI        ),
    .pull_Rslew_o                   (pull_Rslew         ),
    .pull_Fslew_o                   (pull_Fslew         ),
    .pull_on_doing_i                (pull_on_doing      ),
    .U_i                            (U_cali             ),// mV 实时值，有符号数
    .I_i                            (I_cali             ),// mV 实时值，有符号数
    .U_abs_i                        (U_cali_abs         ),// mV 实时值
    .I_abs_i                        (I_cali_abs         ),// mV 实时值
    .i_BAT_err                      (                   ) // 电池错误 b0:I反向 b1:U反向
);

pull_load_wrapper#(
    .SIMULATION                     (0                  ),
    .WORKMOD_CC                     (WORKMOD_CC         ),
    .WORKMOD_CV                     (WORKMOD_CV         ),
    .WORKMOD_CP                     (WORKMOD_CP         ),
    .WORKMOD_CR                     (WORKMOD_CR         ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ),
    .RF_MAX_LIMIT                   (30_000_000         ),
    .PRECHARGE_I                    (30                 ),//单位mA
    .AXI_REG_WIDTH                  (AXI_REG_WIDTH      ) 
)
u_pull_load_wrapper(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
//software CV
    .CV_mode_hard_ON_i              (CV_mode_hard_ON    ),
    .Von_i                          (Von                ),// 开启电压mV
    .Workmod_i                      (Workmod            ),
    .global_1us_flag_i              (global_1us_flag    ),

    .pull_on_i                      (pull_on            ),
    .pull_precharge_en_i            (pull_precharge_en  ),
    .pull_target_i                  (pull_target        ),
    .pull_initI_i                   (pull_initI         ),
    .pull_limitI_i                  (pull_limitI        ),
    .pull_on_doing_o                (pull_on_doing      ),
    .pull_Rslew_i                   (pull_Rslew         ),
    .pull_Fslew_i                   (pull_Fslew         ),
    .CV_slew_i                      (CV_slew            ),// CV模式电压变化斜率(1mV/ms)
    .Short_flag_i                   (Short_ON           ),// 短路测试 (STA/DYN)
    .I_short_i                      (I_short            ),// 短路时拉载电流
    .CC_k_i                         (CC_k               ),
    .CC_a_i                         (CC_a               ),
    .CV_k_i                         (CV_k               ),
    .CV_a_i                         (CV_a               ),
    .KP_i                           (KP                 ),
    .KI_i                           (KI                 ),
    .KD_i                           ('d0                ),
    .U_abs_i                        (U_cali_mean_abs    ),// mV
    .I_abs_i                        (I_cali_mean_abs    ),// mV

    .cv_limit_trig_i                (cv_limit_trig_i    ),//1:normal 0:error 硬件CV时电流控制量PROG大于CV_LIMIT
    .hardware_lock_off_en_o         (cv_hard_lock_off_en),
    .cc_cv_select_o                 (cc_cv_select_o     ),//1:CELL PROG DA 0:CV HARDWARE LOOP
    .cv_limit_select_o              (cv_limit_select_o  ),//1:CV LIMIT DA 0:CV LIMIT PROG

    .dac_data_valid_o               (dac_data_valid     ),
    .dac_data_o                     (dac_data           ),
    .dac_data_limit_o               (dac_data_limit     ) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// detect alarm
//---------------------------------------------------------------------

alarm_wrapper#(
    .SIMULATION                     (0                  ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_alarm_wrapper(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .global_1us_flag_i              (global_1us_flag    ),
    .Clear_alarm_ON_i               (Clear_alarm_ON     ),
//max
    .U_max_i                        (U_max              ),// 最大电压限制
    .I_max_i                        (I_max              ),// 最大电流限制
    .P_max_i                        (P_max              ),// 最大功率限制
//max
    .U_limit_i                      (                   ),// 电压限制
    .I_limit_i                      (I_limit            ),// 电流限制
    .P_limit_i                      (P_limit            ),// 功率限制
    .Pro_time_i                     (Pro_time           ),// 1-立即保护；10-1mS；20-2mS……150-15mS
//实时的采样数据
    .U_rt_i                         (U_cali             ),// 实时采样电压
    .I_rt_i                         (I_cali             ),// 实时采样电流
    .P_rt_i                         (P_rt               ),
    .threshold_i                    (sense_err_threshold),
    .Umod_rt_i                      (Umod_cali          ),
    .Usense_rt_i                    (Usense_cali        ),
    .ovp_maxU_alarm_o               (ovp_maxU_alarm     ),
    .ocp_maxI_alarm_o               (ocp_maxI_alarm     ),
    .ocp_alarm_o                    (ocp_alarm          ),
    .opp_maxP_alarm_o               (opp_maxP_alarm     ),
    .opp_alarm_o                    (opp_alarm          ),
    .sense_error_o                  (sense_error        ),
    .Umod_inv_alarm_o               (Umod_inv_alarm     ),
    .Usense_inv_alarm_o             (Usense_inv_alarm   ) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 用于显示电压和电流
//---------------------------------------------------------------------
get_I_unit#(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_get_I_unit(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .global_1us_flag_i              (global_1us_flag    ),
// ADC signal
    .adc_valid_i                    (adc_cali_valid     ),
    .I_sum_unit_i                   (I_sum_unit_cali    ),// sum_unit电流，校准后的值
    .I_board_unit_i                 (I_board_unit_cali  ),// board_unit电流，校准后的值
    .SUM_UNIT_0                     (SUM_UNIT_0         ),
    .SUM_UNIT_1                     (SUM_UNIT_1         ),
    .SUM_UNIT_2                     (SUM_UNIT_2         ),
    .SUM_UNIT_3                     (SUM_UNIT_3         ),
    .SUM_UNIT_4                     (SUM_UNIT_4         ),
    .SUM_UNIT_5                     (SUM_UNIT_5         ),
    .SUM_UNIT_6                     (SUM_UNIT_6         ),
    .SUM_UNIT_7                     (SUM_UNIT_7         ),
    .BOARD_UNIT_0                   (BOARD_UNIT_0       ),
    .BOARD_UNIT_1                   (BOARD_UNIT_1       ),
    .BOARD_UNIT_2                   (BOARD_UNIT_2       ),
    .BOARD_UNIT_3                   (BOARD_UNIT_3       ),
    .BOARD_UNIT_4                   (BOARD_UNIT_4       ),
    .BOARD_UNIT_5                   (BOARD_UNIT_5       ),
    .BOARD_UNIT_6                   (BOARD_UNIT_6       ),
    .BOARD_UNIT_7                   (BOARD_UNIT_7       ),
    .en_sample_o                    (en_sample_o        ),
    .sel_sample_o                   (sel_sample_o       ) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// reg table
//---------------------------------------------------------------------
jn807_reg_map_cfg u_jn807_reg_map_cfg(
    //System
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    //Ram interface
    .ram_wr_en_i                    (ram_wr_en          ),
    .ram_wr_addr_i                  ({{(32-C_S_AXI_ADDR_WIDTH){1'b0}},ram_wr_addr}),
    .ram_wr_data_i                  (ram_wr_data        ),
    .ram_rd_en_i                    (ram_rd_en          ),
    .ram_rd_addr_i                  ({{(32-C_S_AXI_ADDR_WIDTH){1'b0}},ram_rd_addr}),
    .ram_rd_data_o                  (ram_rd_data        ),
    //reg map
    .Workmod                        (Workmod            ),// output slv_reg001 Workmod [16-1:0]
    .Func                           (Func               ),// output slv_reg002 Func [16-1:0]
    .SENSE                          (SENSE              ),// output slv_reg003 SENSE [16-1:0]
    .Model                          (Model              ),// output slv_reg004 Model [16-1:0]
    .Worktype                       (Worktype           ),// output slv_reg005 Worktype [16-1:0]
    .M_S                            (M_S                ),// output slv_reg006 M_S [16-1:0]
    .Clear_alarm                    (Clear_alarm        ),// output slv_reg007 Clear_alarm [16-1:0]
    .RUN_flag                       (RUN_flag           ),// output slv_reg008 RUN_flag [16-1:0]
    .Short                          (Short              ),// output slv_reg009 Short [16-1:0]
    .Von                            (Von                ),// output slv_reg00a Von [32-1:0]
    .SR_slew                        (SR_slew            ),// output slv_reg00b SR_slew [32-1:0]
    .SF_slew                        (SF_slew            ),// output slv_reg00c SF_slew [32-1:0]
    .sense_err_threshold            (sense_err_threshold),// output slv_reg00d sense_err_threshold [16-1:0]
    .Von_Latch                      (Von_Latch          ),// output slv_reg00f Von_Latch [16-1:0]
    .Voff                           (Voff               ),// output slv_reg010 Voff [32-1:0]
    .Iset_L                         (Iset_L             ),// output slv_reg011 Iset_L [32-1:0]
    .Iset_H                         (Iset_H             ),// output slv_reg012 Iset_H [32-1:0]
    .Vset_L                         (Vset_L             ),// output slv_reg013 Vset_L [32-1:0]
    .Vset_H                         (Vset_H             ),// output slv_reg014 Vset_H [32-1:0]
    .Pset_L                         (Pset_L             ),// output slv_reg015 Pset_L [32-1:0]
    .Pset_H                         (Pset_H             ),// output slv_reg016 Pset_H [32-1:0]
    .Rset_L                         (Rset_L             ),// output slv_reg017 Rset_L [32-1:0]
    .Rset_H                         (Rset_H             ),// output slv_reg018 Rset_H [32-1:0]
    .Iset1_L                        (Iset1_L            ),// output slv_reg019 Iset1_L [32-1:0]
    .Iset1_H                        (Iset1_H            ),// output slv_reg01a Iset1_H [32-1:0]
    .Iset2_L                        (Iset2_L            ),// output slv_reg01b Iset2_L [32-1:0]
    .Iset2_H                        (Iset2_H            ),// output slv_reg01c Iset2_H [32-1:0]
    .Vset1_L                        (Vset1_L            ),// output slv_reg01d Vset1_L [32-1:0]
    .Vset1_H                        (Vset1_H            ),// output slv_reg01e Vset1_H [32-1:0]
    .Vset2_L                        (Vset2_L            ),// output slv_reg01f Vset2_L [32-1:0]
    .Vset2_H                        (Vset2_H            ),// output slv_reg020 Vset2_H [32-1:0]
    .Pset1_L                        (Pset1_L            ),// output slv_reg021 Pset1_L [32-1:0]
    .Pset1_H                        (Pset1_H            ),// output slv_reg022 Pset1_H [32-1:0]
    .Pset2_L                        (Pset2_L            ),// output slv_reg023 Pset2_L [32-1:0]
    .Pset2_H                        (Pset2_H            ),// output slv_reg024 Pset2_H [32-1:0]
    .Rset1_L                        (Rset1_L            ),// output slv_reg025 Rset1_L [32-1:0]
    .Rset1_H                        (Rset1_H            ),// output slv_reg026 Rset1_H [32-1:0]
    .Rset2_L                        (Rset2_L            ),// output slv_reg027 Rset2_L [32-1:0]
    .Rset2_H                        (Rset2_H            ),// output slv_reg028 Rset2_H [32-1:0]
    .DR_slew                        (DR_slew            ),// output slv_reg02d DR_slew [32-1:0]
    .DF_slew                        (DF_slew            ),// output slv_reg02e DF_slew [32-1:0]
    .Vrange                         (Vrange             ),// output slv_reg02f Vrange [16-1:0]
    .CVspeed                        (CVspeed            ),// output slv_reg030 CVspeed [32-1:0]
    .CV_slew                        (CV_slew            ),// output slv_reg031 CV_slew [32-1:0]
    .filter_period                  (filter_period      ),// output slv_reg033 filter_period [32-1:0]
    .num_paral                      (num_paral          ),// output slv_reg034 num_paral [32-1:0]
    .I_lim_L                        (I_lim_L            ),// output slv_reg041 I_lim_L [32-1:0]
    .I_lim_H                        (I_lim_H            ),// output slv_reg042 I_lim_H [32-1:0]
    .V_lim_L                        (V_lim_L            ),// output slv_reg043 V_lim_L [32-1:0]
    .V_lim_H                        (V_lim_H            ),// output slv_reg044 V_lim_H [32-1:0]
    .P_lim_L                        (P_lim_L            ),// output slv_reg045 P_lim_L [32-1:0]
    .P_lim_H                        (P_lim_H            ),// output slv_reg046 P_lim_H [32-1:0]
    .CV_lim_L                       (CV_lim_L           ),// output slv_reg047 CV_lim_L [32-1:0]
    .CV_lim_H                       (CV_lim_H           ),// output slv_reg048 CV_lim_H [32-1:0]
    .Pro_time                       (Pro_time           ),// output slv_reg049 Pro_time [32-1:0]
    .VH_k                           (VH_k               ),// output slv_reg051 VH_k [32-1:0]
    .VH_a                           (VH_a               ),// output slv_reg052 VH_a [32-1:0]
    .VsH_k                          (VsH_k              ),// output slv_reg053 VsH_k [32-1:0]
    .VsH_a                          (VsH_a              ),// output slv_reg054 VsH_a [32-1:0]
    .I1_k                           (I1_k               ),// output slv_reg055 I1_k [32-1:0]
    .I1_a                           (I1_a               ),// output slv_reg056 I1_a [32-1:0]
    .I2_k                           (I2_k               ),// output slv_reg057 I2_k [32-1:0]
    .I2_a                           (I2_a               ),// output slv_reg058 I2_a [32-1:0]
    .VL_k                           (VL_k               ),// output slv_reg059 VL_k [32-1:0]
    .VL_a                           (VL_a               ),// output slv_reg05a VL_a [32-1:0]
    .VsL_k                          (VsL_k              ),// output slv_reg05b VsL_k [32-1:0]
    .VsL_a                          (VsL_a              ),// output slv_reg05c VsL_a [32-1:0]
    .It1_k                          (It1_k              ),// output slv_reg05d It1_k [32-1:0]
    .It1_a                          (It1_a              ),// output slv_reg05e It1_a [32-1:0]
    .It2_k                          (It2_k              ),// output slv_reg05f It2_k [32-1:0]
    .It2_a                          (It2_a              ),// output slv_reg060 It2_a [32-1:0]
    .CC_k                           (CC_k               ),// output slv_reg061 CC_k [32-1:0]
    .CC_a                           (CC_a               ),// output slv_reg062 CC_a [32-1:0]
    .CVH_k                          (CVH_k              ),// output slv_reg063 CVH_k [32-1:0]
    .CVH_a                          (CVH_a              ),// output slv_reg064 CVH_a [32-1:0]
    .CVL_k                          (CVL_k              ),// output slv_reg065 CVL_k [32-1:0]
    .CVL_a                          (CVL_a              ),// output slv_reg066 CVL_a [32-1:0]
    .CVHs_k                         (CVHs_k             ),// output slv_reg067 CVHs_k [32-1:0]
    .CVHs_a                         (CVHs_a             ),// output slv_reg068 CVHs_a [32-1:0]
    .CVLs_k                         (CVLs_k             ),// output slv_reg069 CVLs_k [32-1:0]
    .CVLs_a                         (CVLs_a             ),// output slv_reg06a CVLs_a [32-1:0]
    .s_k                            (s_k                ),// output slv_reg06b s_k [32-1:0]
    .s_a                            (s_a                ),// output slv_reg06c s_a [32-1:0]
    .m_k                            (m_k                ),// output slv_reg06d m_k [32-1:0]
    .m_a                            (m_a                ),// output slv_reg06e m_a [32-1:0]
    .f_k                            (f_k                ),// output slv_reg06f f_k [32-1:0]
    .f_a                            (f_a                ),// output slv_reg070 f_a [32-1:0]
    .CV_mode                        (CV_mode            ),// output slv_reg071 CV_mode [32-1:0]
    .T1_L_cc                        (T1_L_cc            ),// output slv_reg080 T1_L_cc [32-1:0]
    .T1_H_cc                        (T1_H_cc            ),// output slv_reg086 T1_H_cc [32-1:0]
    .T2_L_cc                        (T2_L_cc            ),// output slv_reg087 T2_L_cc [32-1:0]
    .T2_H_cc                        (T2_H_cc            ),// output slv_reg088 T2_H_cc [32-1:0]
    .Dyn_trig_mode                  (Dyn_trig_mode      ),// output slv_reg090 Dyn_trig_mode [32-1:0]
    .Dyn_trig_source                (Dyn_trig_source    ),// output slv_reg091 Dyn_trig_source [32-1:0]
    .Dyn_trig_gen                   (Dyn_trig_gen       ),// output slv_reg092 Dyn_trig_gen [32-1:0]
    .BT_STOP                        (BT_STOP            ),// output slv_reg0B1 BT_STOP [32-1:0]
    .VB_stop_L                      (VB_stop_L          ),// output slv_reg0B3 VB_stop_L [32-1:0]
    .VB_stop_H                      (VB_stop_H          ),// output slv_reg0B4 VB_stop_H [32-1:0]
    .TB_stop_L                      (TB_stop_L          ),// output slv_reg0B5 TB_stop_L [32-1:0]
    .TB_stop_H                      (TB_stop_H          ),// output slv_reg0B6 TB_stop_H [32-1:0]
    .CB_stop_L                      (CB_stop_L          ),// output slv_reg0B7 CB_stop_L [32-1:0]
    .CB_stop_H                      (CB_stop_H          ),// output slv_reg0B8 CB_stop_H [32-1:0]
    .VB_pro_L                       (VB_pro_L           ),// output slv_reg0B9 VB_pro_L [32-1:0]
    .VB_pro_H                       (VB_pro_H           ),// output slv_reg0Ba VB_pro_H [32-1:0]
    .TOCP_Von_set_L                 (TOCP_Von_set_L     ),// output slv_reg0C0 TOCP_Von_set_L [32-1:0]
    .TOCP_Von_set_H                 (TOCP_Von_set_H     ),// output slv_reg0C1 TOCP_Von_set_H [32-1:0]
    .TOCP_Istart_set_L              (TOCP_Istart_set_L  ),// output slv_reg0C2 TOCP_Istart_set_L [32-1:0]
    .TOCP_Istartl_set_H             (TOCP_Istartl_set_H ),// output slv_reg0C3 TOCP_Istartl_set_H [32-1:0]
    .TOCP_Icut_set_L                (TOCP_Icut_set_L    ),// output slv_reg0C4 TOCP_Icut_set_L [32-1:0]
    .TOCP_Icut_set_H                (TOCP_Icut_set_H    ),// output slv_reg0C5 TOCP_Icut_set_H [32-1:0]
    .TOCP_Istep_set                 (TOCP_Istep_set     ),// output slv_reg0C6 TOCP_Istep_set [32-1:0]
    .TOCP_Tstep_set                 (TOCP_Tstep_set     ),// output slv_reg0C7 TOCP_Tstep_set [32-1:0]
    .TOCP_Vcut_set_L                (TOCP_Vcut_set_L    ),// output slv_reg0C8 TOCP_Vcut_set_L [32-1:0]
    .TOCP_Vcut_set_H                (TOCP_Vcut_set_H    ),// output slv_reg0C9 TOCP_Vcut_set_H [32-1:0]
    .TOCP_Imin_set_L                (TOCP_Imin_set_L    ),// output slv_reg0Ca TOCP_Imin_set_L [32-1:0]
    .TOCP_Imin_set_H                (TOCP_Imin_set_H    ),// output slv_reg0Cb TOCP_Imin_set_H [32-1:0]
    .TOCP_Imax_set_L                (TOCP_Imax_set_L    ),// output slv_reg0Cc TOCP_Imax_set_L [32-1:0]
    .TOCP_Imax_set_H                (TOCP_Imax_set_H    ),// output slv_reg0Cd TOCP_Imax_set_H [32-1:0]
    .TOCP_I_L                       (TOCP_I_L           ),// input slv_reg0CE TOCP_I_L [32-1:0]
    .TOCP_I_H                       (TOCP_I_H           ),// input slv_reg0CF TOCP_I_H [32-1:0]
    .TOPP_Von_set_L                 (TOPP_Von_set_L     ),// output slv_reg0D0 TOPP_Von_set_L  [32-1:0]
    .TOPP_Von_set_H                 (TOPP_Von_set_H     ),// output slv_reg0D1 TOPP_Von_set_H  [32-1:0]
    .TOPP_Pstart_set_L              (TOPP_Pstart_set_L  ),// output slv_reg0D2 TOPP_Pstart_set_L [32-1:0]
    .TOPP_Pstart_set_H              (TOPP_Pstart_set_H  ),// output slv_reg0D3 TOPP_Pstart_set_H [32-1:0]
    .TOPP_Pcut_set_L                (TOPP_Pcut_set_L    ),// output slv_reg0D4 TOPP_Pcut_set_L [32-1:0]
    .TOPP_Pcut_set_H                (TOPP_Pcut_set_H    ),// output slv_reg0D5 TOPP_Pcut_set_H [32-1:0]
    .TOPP_Pstep_set                 (TOPP_Pstep_set     ),// output slv_reg0D6 TOPP_Pstep_set [32-1:0]
    .TOPP_Tstep_set                 (TOPP_Tstep_set     ),// output slv_reg0D7 TOPP_Tstep_set [32-1:0]
    .TOPP_Vcut_set_L                (TOPP_Vcut_set_L    ),// output slv_reg0D8 TOPP_Vcut_set_L [32-1:0]
    .TOPP_Vcut_set_H                (TOPP_Vcut_set_H    ),// output slv_reg0D9 TOPP_Vcut_set_H [32-1:0]
    .TOPP_Pmin_set_L                (TOPP_Pmin_set_L    ),// output slv_reg0Da TOPP_Pmin_set_L [32-1:0]
    .TOPP_Pmin_set_H                (TOPP_Pmin_set_H    ),// output slv_reg0Db TOPP_Pmin_set_H [32-1:0]
    .TOPP_Pmax_set_L                (TOPP_Pmax_set_L    ),// output slv_reg0Dc TOPP_Pmax_set_L [32-1:0]
    .TOPP_Pmax_set_H                (TOPP_Pmax_set_H    ),// output slv_reg0Dd TOPP_Pmax_set_H [32-1:0]
    .TOPP_P_L                       (TOPP_P_L           ),// input slv_reg0De TOPP_P_L [32-1:0]
    .TOPP_P_H                       (TOPP_P_H           ),// input slv_reg0Df TOPP_P_H  [32-1:0]
    .Stepnum                        (Stepnum            ),// output slv_reg0f1 Stepnum [32-1:0]
    .Count                          (Count              ),// output slv_reg0f2 Count [32-1:0]
    .Step                           (Step               ),// output slv_reg0f3 Step [32-1:0]
    .Mode                           (Mode               ),// output slv_reg0f4 Mode [32-1:0]
    .Value_L                        (Value_L            ),// output slv_reg0f5 Value_L [32-1:0]
    .Value_H                        (Value_H            ),// output slv_reg0f6 Value_H [32-1:0]
    .Tstep_L                        (Tstep_L            ),// output slv_reg0f7 Tstep_L [32-1:0]
    .Tstep_H                        (Tstep_H            ),// output slv_reg0f8 Tstep_H [32-1:0]
    .Repeat                         (Repeat             ),// output slv_reg0f9 Repeat [32-1:0]
    .Goto                           (Goto               ),// output slv_reg0fa Goto [32-1:0]
    .Loops                          (Loops              ),// output slv_reg0fb Loops [32-1:0]
    .Save_step                      (Save_step          ),// output slv_reg0fc Save_step [32-1:0]
    .rd_Fault_status                (rd_Fault_status    ),// input rd_slv_reg000 rd_Fault_status [16-1:0]
    .rd_Workmod                     (Workmod            ),// input rd_slv_reg001 rd_Workmod [16-1:0]
    .rd_Func                        (Func               ),// input rd_slv_reg202 rd_Func [16-1:0]
    .rd_SENSE                       (SENSE              ),// input rd_slv_reg203 rd_SENSE [16-1:0]
    .rd_Model                       (Model              ),// input rd_slv_reg204 rd_Model [16-1:0]
    .rd_Worktype                    (Worktype           ),// input rd_slv_reg205 rd_Worktype [16-1:0]
    .rd_M_S                         (M_S                ),// input rd_slv_reg206 rd_M_S [16-1:0]
    .rd_Clear_alarm                 (Clear_alarm        ),// input rd_slv_reg207 rd_Clear_alarm [16-1:0]
    .rd_Run_status                  (rd_Run_status      ),// input rd_slv_reg208 rd_Run_status [16-1:0]
    .rd_Short                       (Short              ),// input rd_slv_reg209 rd_Short [16-1:0]
    .rd_Von                         (Von                ),// input rd_slv_reg210 rd_Von [32-1:0]
    .rd_SR_slew                     (SR_slew            ),// input rd_slv_reg211 rd_SR_slew [32-1:0]
    .rd_SF_slew                     (SF_slew            ),// input rd_slv_reg212 rd_SF_slew [32-1:0]
    .rd_sense_err_threshold         (sense_err_threshold),// input rd_slv_reg213 rd_sense_err_threshold [16-1:0]
    .rd_Von_Latch                   (Von_Latch          ),// input rd_slv_reg00f rd_Von_Latch [16-1:0]
    .rd_Voff                        (Voff               ),// input rd_slv_reg010 rd_Voff [32-1:0]
    .rd_Iset_L                      (Iset_L             ),// input rd_slv_reg011 rd_Iset_L [32-1:0]
    .rd_Iset_H                      (Iset_H             ),// input rd_slv_reg012 rd_Iset_H [32-1:0]
    .rd_Vset_L                      (Vset_L             ),// input rd_slv_reg013 rd_Vset_L [32-1:0]
    .rd_Vset_H                      (Vset_H             ),// input rd_slv_reg014 rd_Vset_H [32-1:0]
    .rd_Pset_L                      (Pset_L             ),// input rd_slv_reg015 rd_Pset_L [32-1:0]
    .rd_Pset_H                      (Pset_H             ),// input rd_slv_reg016 rd_Pset_H [32-1:0]
    .rd_Rset_L                      (Rset_L             ),// input rd_slv_reg017 rd_Rset_L [32-1:0]
    .rd_Rset_H                      (Rset_H             ),// input rd_slv_reg018 rd_Rset_H [32-1:0]
    .rd_Iset1_L                     (Iset1_L            ),// input rd_slv_reg019 rd_Iset1_L [32-1:0]
    .rd_Iset1_H                     (Iset1_H            ),// input rd_slv_reg01a rd_Iset1_H [32-1:0]
    .rd_Iset2_L                     (Iset2_L            ),// input rd_slv_reg01b rd_Iset2_L [32-1:0]
    .rd_Iset2_H                     (Iset2_H            ),// input rd_slv_reg01c rd_Iset2_H [32-1:0]
    .rd_Vset1_L                     (Vset1_L            ),// input rd_slv_reg01d rd_Vset1_L [32-1:0]
    .rd_Vset1_H                     (Vset1_H            ),// input rd_slv_reg01e rd_Vset1_H [32-1:0]
    .rd_Vset2_L                     (Vset2_L            ),// input rd_slv_reg01f rd_Vset2_L [32-1:0]
    .rd_Vset2_H                     (Vset2_H            ),// input rd_slv_reg020 rd_Vset2_H [32-1:0]
    .rd_Pset1_L                     (Pset1_L            ),// input rd_slv_reg021 rd_Pset1_L [32-1:0]
    .rd_Pset1_H                     (Pset1_H            ),// input rd_slv_reg022 rd_Pset1_H [32-1:0]
    .rd_Pset2_L                     (Pset2_L            ),// input rd_slv_reg023 rd_Pset2_L [32-1:0]
    .rd_Pset2_H                     (Pset2_H            ),// input rd_slv_reg024 rd_Pset2_H [32-1:0]
    .rd_Rset1_L                     (Rset1_L            ),// input rd_slv_reg025 rd_Rset1_L [32-1:0]
    .rd_Rset1_H                     (Rset1_H            ),// input rd_slv_reg026 rd_Rset1_H [32-1:0]
    .rd_Rset2_L                     (Rset2_L            ),// input rd_slv_reg027 rd_Rset2_L [32-1:0]
    .rd_Rset2_H                     (Rset2_H            ),// input rd_slv_reg028 rd_Rset2_H [32-1:0]
    .rd_DR_slew                     (DR_slew            ),// input rd_slv_reg02d rd_DR_slew [32-1:0]
    .rd_DF_slew                     (DF_slew            ),// input rd_slv_reg02e rd_DF_slew [32-1:0]
    .rd_Vrange                      (Vrange             ),// input rd_slv_reg02f rd_Vrange [16-1:0]
    .rd_CVspeed                     (CVspeed            ),// input rd_slv_reg030 rd_CVspeed [32-1:0]
    .rd_CV_slew                     (CV_slew            ),// input rd_slv_reg031 rd_CV_slew [32-1:0]
    .rd_filter_period               (filter_period      ),// input rd_slv_reg033 rd_filter_period [32-1:0]
    .rd_num_paral                   (num_paral          ),// input rd_slv_reg034 rd_num_paral [32-1:0]
    .rd_I_lim_L                     (I_lim_L            ),// input rd_slv_reg041 rd_I_lim_L [32-1:0]
    .rd_I_lim_H                     (I_lim_H            ),// input rd_slv_reg042 rd_I_lim_H [32-1:0]
    .rd_V_lim_L                     (V_lim_L            ),// input rd_slv_reg043 rd_V_lim_L [32-1:0]
    .rd_V_lim_H                     (V_lim_H            ),// input rd_slv_reg044 rd_V_lim_H [32-1:0]
    .rd_P_lim_L                     (P_lim_L            ),// input rd_slv_reg045 rd_P_lim_L [32-1:0]
    .rd_P_lim_H                     (P_lim_H            ),// input rd_slv_reg046 rd_P_lim_H [32-1:0]
    .rd_CV_lim_L                    (CV_lim_L           ),// input rd_slv_reg047 rd_CV_lim_L [32-1:0]
    .rd_CV_lim_H                    (CV_lim_H           ),// input rd_slv_reg048 rd_CV_lim_H [32-1:0]
    .rd_Pro_time                    (Pro_time           ),// input rd_slv_reg049 rd_Pro_time [32-1:0]
    .rd_VH_k                        (VH_k               ),// input rd_slv_reg051 rd_VH_k [32-1:0]
    .rd_VH_a                        (VH_a               ),// input rd_slv_reg052 rd_VH_a [32-1:0]
    .rd_VsH_k                       (VsH_k              ),// input rd_slv_reg053 rd_VsH_k [32-1:0]
    .rd_VsH_a                       (VsH_a              ),// input rd_slv_reg054 rd_VsH_a [32-1:0]
    .rd_I1_k                        (I1_k               ),// input rd_slv_reg055 rd_I1_k [32-1:0]
    .rd_I1_a                        (I1_a               ),// input rd_slv_reg056 rd_I1_a [32-1:0]
    .rd_I2_k                        (I2_k               ),// input rd_slv_reg057 rd_I2_k [32-1:0]
    .rd_I2_a                        (I2_a               ),// input rd_slv_reg058 rd_I2_a [32-1:0]
    .rd_VL_k                        (VL_k               ),// input rd_slv_reg059 rd_VL_k [32-1:0]
    .rd_VL_a                        (VL_a               ),// input rd_slv_reg05a rd_VL_a [32-1:0]
    .rd_VsL_k                       (VsL_k              ),// input rd_slv_reg05b rd_VsL_k [32-1:0]
    .rd_VsL_a                       (VsL_a              ),// input rd_slv_reg05c rd_VsL_a [32-1:0]
    .rd_It1_k                       (It1_k              ),// input rd_slv_reg05d rd_It1_k [32-1:0]
    .rd_It1_a                       (It1_a              ),// input rd_slv_reg05e rd_It1_a [32-1:0]
    .rd_It2_k                       (It2_k              ),// input rd_slv_reg05f rd_It2_k [32-1:0]
    .rd_It2_a                       (It2_a              ),// input rd_slv_reg060 rd_It2_a [32-1:0]
    .rd_CC_k                        (CC_k               ),// input rd_slv_reg061 rd_CC_k [32-1:0]
    .rd_CC_a                        (CC_a               ),// input rd_slv_reg062 rd_CC_a [32-1:0]
    .rd_CVH_k                       (CVH_k              ),// input rd_slv_reg063 rd_CVH_k [32-1:0]
    .rd_CVH_a                       (CVH_a              ),// input rd_slv_reg064 rd_CVH_a [32-1:0]
    .rd_CVL_k                       (CVL_k              ),// input rd_slv_reg065 rd_CVL_k [32-1:0]
    .rd_CVL_a                       (CVL_a              ),// input rd_slv_reg066 rd_CVL_a [32-1:0]
    .rd_CVHs_k                      (CVHs_k             ),// input rd_slv_reg067 rd_CVHs_k [32-1:0]
    .rd_CVHs_a                      (CVHs_a             ),// input rd_slv_reg068 rd_CVHs_a [32-1:0]
    .rd_CVLs_k                      (CVLs_k             ),// input rd_slv_reg069 rd_CVLs_k [32-1:0]
    .rd_CVLs_a                      (CVLs_a             ),// input rd_slv_reg06a rd_CVLs_a [32-1:0]
    .rd_s_k                         (s_k                ),// input rd_slv_reg06b rd_s_k [32-1:0]
    .rd_s_a                         (s_a                ),// input rd_slv_reg06c rd_s_a [32-1:0]
    .rd_m_k                         (m_k                ),// input rd_slv_reg06d rd_m_k [32-1:0]
    .rd_m_a                         (m_a                ),// input rd_slv_reg06e rd_m_a [32-1:0]
    .rd_f_k                         (f_k                ),// input rd_slv_reg06f rd_f_k [32-1:0]
    .rd_f_a                         (f_a                ),// input rd_slv_reg070 rd_f_a [32-1:0]
    .rd_CV_mode                     (CV_mode            ),// input rd_slv_reg071 rd_CV_mode [32-1:0]
    .rd_T1_L_cc                     (T1_L_cc            ),// input rd_slv_reg080 rd_T1_L_cc [32-1:0]
    .rd_T1_H_cc                     (T1_H_cc            ),// input rd_slv_reg086 rd_T1_H_cc [32-1:0]
    .rd_T2_L_cc                     (T2_L_cc            ),// input rd_slv_reg087 rd_T2_L_cc [32-1:0]
    .rd_T2_H_cc                     (T2_H_cc            ),// input rd_slv_reg088 rd_T2_H_cc [32-1:0]
    .rd_Dyn_trig_mode               (Dyn_trig_mode      ),// input rd_slv_reg090 rd_Dyn_trig_mode [32-1:0]
    .rd_Dyn_trig_source             (Dyn_trig_source    ),// input rd_slv_reg091 rd_Dyn_trig_source [32-1:0]
    .rd_Dyn_trig_gen                (Dyn_trig_gen       ),// input rd_slv_reg092 rd_Dyn_trig_gen [32-1:0]
    .rd_BT_STOP                     (BT_STOP            ),// input rd_slv_reg0B1 rd_BT_STOP [32-1:0]
    .rd_VB_stop_L                   (VB_stop_L          ),// input rd_slv_reg0B3 rd_VB_stop_L [32-1:0]
    .rd_VB_stop_H                   (VB_stop_H          ),// input rd_slv_reg0B4 rd_VB_stop_H [32-1:0]
    .rd_TB_stop_L                   (TB_stop_L          ),// input rd_slv_reg0B5 rd_TB_stop_L [32-1:0]
    .rd_TB_stop_H                   (TB_stop_H          ),// input rd_slv_reg0B6 rd_TB_stop_H [32-1:0]
    .rd_CB_stop_L                   (CB_stop_L          ),// input rd_slv_reg0B7 rd_CB_stop_L [32-1:0]
    .rd_CB_stop_H                   (CB_stop_H          ),// input rd_slv_reg0B8 rd_CB_stop_H [32-1:0]
    .rd_VB_pro_L                    (VB_pro_L           ),// input rd_slv_reg0B9 rd_VB_pro_L [32-1:0]
    .rd_VB_pro_H                    (VB_pro_H           ),// input rd_slv_reg0Ba rd_VB_pro_H [32-1:0]
    .rd_TOCP_Von_set_L              (TOCP_Von_set_L     ),// input rd_slv_reg0C0 rd_TOCP_Von_set_L [32-1:0]
    .rd_TOCP_Von_set_H              (TOCP_Von_set_H     ),// input rd_slv_reg0C1 rd_TOCP_Von_set_H [32-1:0]
    .rd_TOCP_Istart_set_L           (TOCP_Istart_set_L  ),// input rd_slv_reg0C2 rd_TOCP_Istart_set_L [32-1:0]
    .rd_TOCP_Istartl_set_H          (TOCP_Istartl_set_H ),// input rd_slv_reg0C3 rd_TOCP_Istartl_set_H [32-1:0]
    .rd_TOCP_Icut_set_L             (TOCP_Icut_set_L    ),// input rd_slv_reg0C4 rd_TOCP_Icut_set_L [32-1:0]
    .rd_TOCP_Icut_set_H             (TOCP_Icut_set_H    ),// input rd_slv_reg0C5 rd_TOCP_Icut_set_H [32-1:0]
    .rd_TOCP_Istep_set              (TOCP_Istep_set     ),// input rd_slv_reg0C6 rd_TOCP_Istep_set [32-1:0]
    .rd_TOCP_Tstep_set              (TOCP_Tstep_set     ),// input rd_slv_reg0C7 rd_TOCP_Tstep_set [32-1:0]
    .rd_TOCP_Vcut_set_L             (TOCP_Vcut_set_L    ),// input rd_slv_reg0C8 rd_TOCP_Vcut_set_L [32-1:0]
    .rd_TOCP_Vcut_set_H             (TOCP_Vcut_set_H    ),// input rd_slv_reg0C9 rd_TOCP_Vcut_set_H [32-1:0]
    .rd_TOCP_Imin_set_L             (TOCP_Imin_set_L    ),// input rd_slv_reg0Ca rd_TOCP_Imin_set_L [32-1:0]
    .rd_TOCP_Imin_set_H             (TOCP_Imin_set_H    ),// input rd_slv_reg0Cb rd_TOCP_Imin_set_H [32-1:0]
    .rd_TOCP_Imax_set_L             (TOCP_Imax_set_L    ),// input rd_slv_reg0Cc rd_TOCP_Imax_set_L [32-1:0]
    .rd_TOCP_Imax_set_H             (TOCP_Imax_set_H    ),// input rd_slv_reg0Cd rd_TOCP_Imax_set_H [32-1:0]
    .rd_TOCP_I_L                    (TOCP_I_L           ),// input rd_slv_reg0CE rd_TOCP_I_L [32-1:0]
    .rd_TOCP_result                 (rd_TOCP_result     ),// input rd_slv_reg0CF rd_TOCP_result [32-1:0]
    .rd_TOPP_Von_set_L              (TOPP_Von_set_L     ),// input rd_slv_reg0D0 rd_TOPP_Von_set_L  [32-1:0]
    .rd_TOPP_Von_set_H              (TOPP_Von_set_H     ),// input rd_slv_reg0D1 rd_TOPP_Von_set_H  [32-1:0]
    .rd_TOPP_Pstart_set_L           (TOPP_Pstart_set_L  ),// input rd_slv_reg0D2 rd_TOPP_Pstart_set_L [32-1:0]
    .rd_TOPP_Pstart_set_H           (TOPP_Pstart_set_H  ),// input rd_slv_reg0D3 rd_TOPP_Pstart_set_H [32-1:0]
    .rd_TOPP_Pcut_set_L             (TOPP_Pcut_set_L    ),// input rd_slv_reg0D4 rd_TOPP_Pcut_set_L [32-1:0]
    .rd_TOPP_Pcut_set_H             (TOPP_Pcut_set_H    ),// input rd_slv_reg0D5 rd_TOPP_Pcut_set_H [32-1:0]
    .rd_TOPP_Pstep_set              (TOPP_Pstep_set     ),// input rd_slv_reg0D6 rd_TOPP_Pstep_set [32-1:0]
    .rd_TOPP_Tstep_set              (TOPP_Tstep_set     ),// input rd_slv_reg0D7 rd_TOPP_Tstep_set [32-1:0]
    .rd_TOPP_Vcut_set_L             (TOPP_Vcut_set_L    ),// input rd_slv_reg0D8 rd_TOPP_Vcut_set_L [32-1:0]
    .rd_TOPP_Vcut_set_H             (TOPP_Vcut_set_H    ),// input rd_slv_reg0D9 rd_TOPP_Vcut_set_H [32-1:0]
    .rd_TOPP_Pmin_set_L             (TOPP_Pmin_set_L    ),// input rd_slv_reg0Da rd_TOPP_Pmin_set_L [32-1:0]
    .rd_TOPP_Pmin_set_H             (TOPP_Pmin_set_H    ),// input rd_slv_reg0Db rd_TOPP_Pmin_set_H [32-1:0]
    .rd_TOPP_Pmax_set_L             (TOPP_Pmax_set_L    ),// input rd_slv_reg0Dc rd_TOPP_Pmax_set_L [32-1:0]
    .rd_TOPP_Pmax_set_H             (TOPP_Pmax_set_H    ),// input rd_slv_reg0Dd rd_TOPP_Pmax_set_H [32-1:0]
    .rd_TOPP_P_L                    (TOPP_P_L           ),// input rd_slv_reg0De rd_TOPP_P_L [32-1:0]
    .rd_TOPP_result                 (rd_TOPP_result     ),// input rd_slv_reg0Df rd_TOPP_result [32-1:0]
    .rd_Stepnum                     (Stepnum            ),// input rd_slv_reg0f1 rd_Stepnum [32-1:0]
    .rd_Count                       (Count              ),// input rd_slv_reg0f2 rd_Count [32-1:0]
    .rd_Step                        (Step               ),// input rd_slv_reg0f3 rd_Step [32-1:0]
    .rd_Mode                        (Mode               ),// input rd_slv_reg0f4 rd_Mode [32-1:0]
    .rd_Value_L                     (Value_L            ),// input rd_slv_reg0f5 rd_Value_L [32-1:0]
    .rd_Value_H                     (Value_H            ),// input rd_slv_reg0f6 rd_Value_H [32-1:0]
    .rd_Tstep_L                     (Tstep_L            ),// input rd_slv_reg0f7 rd_Tstep_L [32-1:0]
    .rd_Tstep_H                     (Tstep_H            ),// input rd_slv_reg0f8 rd_Tstep_H [32-1:0]
    .rd_Repeat                      (Repeat             ),// input rd_slv_reg0f9 rd_Repeat [32-1:0]
    .rd_Goto                        (Goto               ),// input rd_slv_reg0fa rd_Goto [32-1:0]
    .rd_Loops                       (Loops              ),// input rd_slv_reg0fb rd_Loops [32-1:0]
    .rd_Repeat_now                  (rd_Repeat_now      ),// input rd_slv_reg0fc rd_Repeat_now [32-1:0]
    .rd_Count_now                   (rd_Count_now       ),// input rd_slv_reg0fd rd_Count_now [32-1:0]
    .rd_Step_now                    (rd_Step_now        ),// input rd_slv_reg0fe rd_Step_now [32-1:0]
    .rd_Loops_now                   (rd_Loops_now       ),// input rd_slv_reg0ff rd_Loops_now [32-1:0]

    .rd_I_Board_L_l                 (rd_I_Board_L_l     ),// input rd_slv_reg301 rd_I_Board_L_l [32-1:0]
    .rd_I_Board_L_h                 (rd_I_Board_L_h     ),// input rd_slv_reg302 rd_I_Board_L_h [32-1:0]
    .rd_I_Board_H_l                 (rd_I_Board_H_l     ),// input rd_slv_reg303 rd_I_Board_H_l [32-1:0]
    .rd_I_Board_H_h                 (rd_I_Board_H_h     ),// input rd_slv_reg304 rd_I_Board_H_h [32-1:0]
    .rd_I_SUM_Total_L_l             (rd_I_SUM_Total_L_l ),// input rd_slv_reg305 rd_I_SUM_Total_L_l [32-1:0]
    .rd_I_SUM_Total_L_h             (rd_I_SUM_Total_L_h ),// input rd_slv_reg306 rd_I_SUM_Total_L_h [32-1:0]
    .rd_I_SUM_Total_H_l             (rd_I_SUM_Total_H_l ),// input rd_slv_reg307 rd_I_SUM_Total_H_l [32-1:0]
    .rd_I_SUM_Total_H_h             (rd_I_SUM_Total_H_h ),// input rd_slv_reg308 rd_I_SUM_Total_H_h [32-1:0]
    .rd_I_Board_unit_l              (rd_I_Board_unit_l  ),// input rd_slv_reg309 rd_I_Board_unit_l [32-1:0]
    .rd_I_Board_unit_h              (rd_I_Board_unit_h  ),// input rd_slv_reg30a rd_I_Board_unit_h [32-1:0]
    .rd_I_Sum_unit_l                (rd_I_Sum_unit_l    ),// input rd_slv_reg30b rd_I_Sum_unit_l [32-1:0]
    .rd_I_Sum_unit_h                (rd_I_Sum_unit_h    ),// input rd_slv_reg30c rd_I_Sum_unit_h [32-1:0]
    .rd_P_rt                        (rd_P_rt            ),// input rd_slv_reg30e rd_P_rt [32-1:0]
    .rd_R_rt                        (rd_R_rt            ),// input rd_slv_reg30f rd_R_rt [32-1:0]
    .rd_V_L                         (rd_V_L             ),// input rd_slv_reg311 rd_V_L [32-1:0]
    .rd_V_H                         (rd_V_H             ),// input rd_slv_reg312 rd_V_H [32-1:0]
    .rd_I_L                         (rd_I_L             ),// input rd_slv_reg313 rd_I_L [32-1:0]
    .rd_I_H                         (rd_I_H             ),// input rd_slv_reg314 rd_I_H [32-1:0]
    .Vopen_L                        (Vopen_L            ),// input rd_slv_reg3b1 Vopen_L [32-1:0]
    .Vopen_H                        (Vopen_H            ),// input rd_slv_reg3b2 Vopen_H [32-1:0]
    .Ri_L                           (Ri_L               ),// input rd_slv_reg3b3 Ri_L [32-1:0]
    .Ri_H                           (Ri_H               ),// input rd_slv_reg3b4 Ri_H [32-1:0]
    .TB_L                           (TB_L               ),// input rd_slv_reg3b5 TB_L [32-1:0]
    .TB_H                           (TB_H               ),// input rd_slv_reg3b6 TB_H [32-1:0]
    .Cap1_L                         (Cap1_L             ),// input rd_slv_reg3b7 Cap1_L [32-1:0]
    .Cap1_H                         (Cap1_H             ),// input rd_slv_reg3b8 Cap1_H [32-1:0]
    .Cap2_L                         (Cap2_L             ),// input rd_slv_reg3b9 Cap2_L [32-1:0]
    .Cap2_H                         (Cap2_H             ),// input rd_slv_reg3ba Cap2_H [32-1:0]
    .Tpro_L                         (Tpro_L             ),// input rd_slv_reg3bb Tpro_L [32-1:0]
    .Tpro_H                         (Tpro_H             ),// input rd_slv_reg3bc Tpro_H [32-1:0]
    .temperature_0                  (temperature_0      ),// input rd_slv_reg3c1 temperature_0 [32-1:0]
    .temperature_1                  (temperature_1      ),// input rd_slv_reg3c2 temperature_1 [32-1:0]
    .temperature_2                  (temperature_2      ),// input rd_slv_reg3c3 temperature_2 [32-1:0]
    .temperature_3                  (temperature_3      ),// input rd_slv_reg3c4 temperature_3 [32-1:0]
    .temperature_4                  (temperature_4      ),// input rd_slv_reg3c5 temperature_4 [32-1:0]
    .temperature_5                  (temperature_5      ),// input rd_slv_reg3c6 temperature_5 [32-1:0]
    .temperature_6                  (temperature_6      ),// input rd_slv_reg3c7 temperature_6 [32-1:0]
    .temperature_7                  (temperature_7      ),// input rd_slv_reg3c8 temperature_7 [32-1:0]
    .SUM_UNIT_0                     (SUM_UNIT_0         ),// input rd_slv_reg3d1 SUM_UNIT_0 [32-1:0]
    .SUM_UNIT_1                     (SUM_UNIT_1         ),// input rd_slv_reg3d2 SUM_UNIT_1 [32-1:0]
    .SUM_UNIT_2                     (SUM_UNIT_2         ),// input rd_slv_reg3d3 SUM_UNIT_2 [32-1:0]
    .SUM_UNIT_3                     (SUM_UNIT_3         ),// input rd_slv_reg3d4 SUM_UNIT_3 [32-1:0]
    .SUM_UNIT_4                     (SUM_UNIT_4         ),// input rd_slv_reg3d5 SUM_UNIT_4 [32-1:0]
    .SUM_UNIT_5                     (SUM_UNIT_5         ),// input rd_slv_reg3d6 SUM_UNIT_5 [32-1:0]
    .SUM_UNIT_6                     (SUM_UNIT_6         ),// input rd_slv_reg3d7 SUM_UNIT_6 [32-1:0]
    .SUM_UNIT_7                     (SUM_UNIT_7         ),// input rd_slv_reg3d8 SUM_UNIT_7 [32-1:0]
    .BOARD_UNIT_0                   (BOARD_UNIT_0       ),// input rd_slv_reg3e1 BOARD_UNIT_0 [32-1:0]
    .BOARD_UNIT_1                   (BOARD_UNIT_1       ),// input rd_slv_reg3e2 BOARD_UNIT_1 [32-1:0]
    .BOARD_UNIT_2                   (BOARD_UNIT_2       ),// input rd_slv_reg3e3 BOARD_UNIT_2 [32-1:0]
    .BOARD_UNIT_3                   (BOARD_UNIT_3       ),// input rd_slv_reg3e4 BOARD_UNIT_3 [32-1:0]
    .BOARD_UNIT_4                   (BOARD_UNIT_4       ),// input rd_slv_reg3e5 BOARD_UNIT_4 [32-1:0]
    .BOARD_UNIT_5                   (BOARD_UNIT_5       ),// input rd_slv_reg3e6 BOARD_UNIT_5 [32-1:0]
    .BOARD_UNIT_6                   (BOARD_UNIT_6       ),// input rd_slv_reg3e7 BOARD_UNIT_6 [32-1:0]
    .BOARD_UNIT_7                   (BOARD_UNIT_7       ),// input rd_slv_reg3e8 BOARD_UNIT_7 [32-1:0]
    .Version_number                 (Version_number     ) // input rd_slv_reg3ff Version_number [32-1:0]
);

s_axi_lite2ram_interface#(
    .C_S_AXI_DATA_WIDTH             (C_S_AXI_DATA_WIDTH ),
    .C_S_AXI_ADDR_WIDTH             (C_S_AXI_ADDR_WIDTH ) 
)
u_s_axi_lite2ram_interface(
//-------------------------customrize---------------------------//
    .ram_wr_en_o                    (ram_wr_en          ),// output ram write enable
    .ram_wr_addr_o                  (ram_wr_addr        ),// output ram write address
    .ram_wr_wstrb_o                 (ram_wr_wstrb       ),// output ram write strobe
    .ram_wr_data_o                  (ram_wr_data        ),// output ram write data
    .ram_rd_en_o                    (ram_rd_en          ),// output ram read enable
    .ram_rd_addr_o                  (ram_rd_addr        ),// output ram read address
    .ram_rd_data_i                  (ram_rd_data        ),// input ram read data
//-----------------------axi lite interface---------------------//
    .S_AXI_ACLK                     (sys_clk_i          ),// Global Clock Signal
    .S_AXI_ARESETN                  (rst_n_i            ),// Global Reset Signal. This Signal is Active LOW
    .S_AXI_AWADDR                   (S_AXI_AWADDR       ),// Write address (issued by master, acceped by Slave)
    .S_AXI_AWPROT                   (S_AXI_AWPROT       ),// Write channel Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
    .S_AXI_AWVALID                  (S_AXI_AWVALID      ),// Write address valid. This signal indicates that the master signaling valid write address and control information.
    .S_AXI_AWREADY                  (S_AXI_AWREADY      ),// Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    .S_AXI_WDATA                    (S_AXI_WDATA        ),// Write data (issued by master, acceped by Slave)
    .S_AXI_WSTRB                    (S_AXI_WSTRB        ),// Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
    .S_AXI_WVALID                   (S_AXI_WVALID       ),// Write valid. This signal indicates that valid write  data and strobes are available.
    .S_AXI_WREADY                   (S_AXI_WREADY       ),// Write ready. This signal indicates that the slave  can accept the write data.
    .S_AXI_BRESP                    (S_AXI_BRESP        ),// Write response. This signal indicates the status of the write transaction.
    .S_AXI_BVALID                   (S_AXI_BVALID       ),// Write response valid. This signal indicates that the channel is signaling a valid write response.
    .S_AXI_BREADY                   (S_AXI_BREADY       ),// Response ready. This signal indicates that the master can accept a write response.
    .S_AXI_ARADDR                   (S_AXI_ARADDR       ),// Read address (issued by master, acceped by Slave)
    .S_AXI_ARPROT                   (S_AXI_ARPROT       ),// Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
    .S_AXI_ARVALID                  (S_AXI_ARVALID      ),// Read address valid. This signal indicates that the channel is signaling valid read address and control information.
    .S_AXI_ARREADY                  (S_AXI_ARREADY      ),// Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    .S_AXI_RDATA                    (S_AXI_RDATA        ),// Read data (issued by slave)
    .S_AXI_RRESP                    (S_AXI_RRESP        ),// Read response. This signal indicates the status of the read transfer.
    .S_AXI_RVALID                   (S_AXI_RVALID       ),// Read valid. This signal indicates that the channel is signaling the required read data.
    .S_AXI_RREADY                   (S_AXI_RREADY       ) // Read ready. This signal indicates that the master can accept the read data and response information.
);


endmodule


`default_nettype wire
