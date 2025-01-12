`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             pull_load_wrapper.v
// Create Date:           2025/01/07 17:55:30
// Version:               V1.0
// PATH:                  srcs\rtl\main_ctrl_pull_load\pull_load_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module pull_load_wrapper #(
    parameter                       SIMULATION         = 0     ,
    parameter                       WORKMOD_CC         = 16'h5a5a,
    parameter                       WORKMOD_CV         = 16'ha5a5,
    parameter                       WORKMOD_CP         = 16'h5a00,
    parameter                       WORKMOD_CR         = 16'h005a,

    parameter                       CALCULATE_WIDTH    = 24    ,
    parameter                       RF_MAX_LIMIT       = 30_000_000,//最大上升下降斜率限制，单位1mA/ms
    parameter                       PRECHARGE_I        = 30    ,//MOS预充电电流(mA)
    parameter                       AXI_REG_WIDTH      = 24    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,
    //software CV
    input  wire                     CV_mode_hard_ON_i   ,

    input  wire        [CALCULATE_WIDTH-1: 0]Von_i      ,//开启电压mV
    input  wire        [  15: 0]    Workmod_i           ,
    input  wire                     global_1us_flag_i   ,
    
    input  wire                     pull_on_i           ,
    input  wire                     pull_precharge_en_i ,
    input  wire        [  31: 0]    pull_target_i       ,
    input  wire        [  31: 0]    pull_initI_i        ,
    input  wire        [  31: 0]    pull_limitI_i       ,
    output reg                      pull_on_doing_o     ,
    input  wire        [AXI_REG_WIDTH-1: 0]pull_Rslew_i ,
    input  wire        [AXI_REG_WIDTH-1: 0]pull_Fslew_i ,
    input  wire        [AXI_REG_WIDTH-1: 0]CV_slew_i    ,//CV模式电压变化斜率(1mV/ms)    

    input  wire                     Short_flag_i        ,//短路测试 (STA/DYN)
    input  wire        [AXI_REG_WIDTH-1: 0]I_short_i    ,//短路时拉载电流    

    input  wire        [  15: 0]    CC_k_i              ,
    input  wire        [  15: 0]    CC_a_i              ,
    input  wire        [  15: 0]    CV_k_i              ,
    input  wire        [  15: 0]    CV_a_i              ,
    input  wire        [  15: 0]    KP_i                ,
    input  wire        [  15: 0]    KI_i                ,
    input  wire        [  15: 0]    KD_i                ,

    input  wire        [CALCULATE_WIDTH-1: 0]U_abs_i    ,//mV
    input  wire        [CALCULATE_WIDTH-1: 0]I_abs_i    ,//mV
    //部分硬件管脚控制信号
    input  wire                     cv_limit_trig_i     ,//1:normal 0:error 硬件CV时电流控制量PROG大于CV_LIMIT
    output wire                     hardware_lock_off_en_o,
    output wire                     cc_cv_select_o      ,//1:CELL PROG DA 0:CV HARDWARE LOOP
    output wire                     cv_limit_select_o   ,//1:CV LIMIT DA 0:CV LIMIT PROG

    output reg                      dac_data_valid_o    ,
    output reg         [  15: 0]    dac_data_o          ,
    output reg         [  15: 0]    dac_data_limit_o     
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                      TIME_20MS          = 20_000_00;
    integer                         i                   ;

    wire                            CV_slew             ;//保护后的cv slew
    wire               [AXI_REG_WIDTH-1: 0]SR_slew_i    ;//电流上升斜率单位1mA/ms 需要保护
    wire               [AXI_REG_WIDTH-1: 0]SF_slew_i    ;//电流下降斜率单位1mA/ms 需要保护 
    wire     signed    [AXI_REG_WIDTH+20-1: 0]SR_slew_period  ;//电流上升斜率单位1mA/10ns(every period) slew_i除以100_000
    wire     signed    [AXI_REG_WIDTH+20-1: 0]SF_slew_period  ;//电流下降斜率单位1mA/10ns(every period) slew_i除以100_000
    wire     signed    [AXI_REG_WIDTH+20-1: 0]CV_slew_period  ;//电流下降斜率单位1mA/10ns(every period) slew_i除以100_000
    wire     signed    [AXI_REG_WIDTH+48-1: 0]CV_slew_period_temp  ;//电流上升斜率单位1mA/10ns(every period) slew_i除以100_000
    wire     signed    [AXI_REG_WIDTH+48-1: 0]SR_slew_period_temp  ;//电流上升斜率单位1mA/10ns(every period) slew_i除以100_000
    wire     signed    [AXI_REG_WIDTH+48-1: 0]SF_slew_period_temp  ;//电流下降斜率单位1mA/10ns(every period) slew_i除以100_000

    reg                             pull_on             [0:4]  ;// cc cv cp cr
    reg                             pull_precharge_en   [0:4]  ;
    reg                [  31: 0]    pull_target         [0:4]  ;
    reg                [  31: 0]    pull_initI          [0:4]  ;
    reg                [  31: 0]    pull_limitI         [0:4]  ;
    wire               [   4: 0]    pull_on_doing       ;

    wire                            dac_data_valid      [0:4]  ;
    wire               [  15: 0]    dac_data            [0:4]  ;
    wire               [  15: 0]    dac_data_limit      [0:4]  ;

    reg                [  23: 0]    cv_sw2hw_hold_cnt   ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// assigns
//---------------------------------------------------------------------
    assign                          SR_slew_i          = (pull_Rslew_i == 0) ? 'd1 : pull_Rslew_i;
    assign                          SF_slew_i          = (pull_Fslew_i == 0) ? 'd1 : pull_Rslew_i;
    assign                          CV_slew            = (CV_slew_i == 0) ? 'd1 : CV_slew_i;

    assign                          cc_cv_select_o     = ((Workmod_i == WORKMOD_CV) & CV_mode_hard_ON_i) ? 1'b0 : 1'b1;//1:CELL PROG DA 0:CV HARDWARE LOOP
    assign                          cv_limit_select_o  = ((Workmod_i == WORKMOD_CV) & CV_mode_hard_ON_i) ? ~cv_limit_trig_i : 1'b1;//1:CV LIMIT DA 0:CV LIMIT PROG
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 分配
//---------------------------------------------------------------------
    assign                          hardware_lock_off_en_o= (cv_sw2hw_hold_cnt == TIME_20MS - 1);

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        cv_sw2hw_hold_cnt <= 'd0;
    end
    else if (CV_mode_hard_ON_i)
        if (cv_sw2hw_hold_cnt == TIME_20MS - 1)
            cv_sw2hw_hold_cnt <= cv_sw2hw_hold_cnt;                 //软件切换到硬件CV后20ms，关闭硬件保护使能
        else
            cv_sw2hw_hold_cnt <= cv_sw2hw_hold_cnt + 1;
    else
        cv_sw2hw_hold_cnt <= 'd0;
end


always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        for (i = 0; i<5; i=i+1) begin
            pull_on          [i] <= 'd0;
            pull_precharge_en[i] <= 'd0;
            pull_target      [i] <= 'd0;
            pull_initI       [i] <= 'd0;
            pull_limitI      [i] <= 'd0;
        end

        pull_on_doing_o  <= 'd0;
        dac_data_valid_o <= 'd0;
        dac_data_o       <= 'd0;
        dac_data_limit_o <= 'd0;
    end
    else begin
        //这段代码的意思是，没有声明的情况就赋0
        for (i = 0; i<5; i=i+1) begin
            pull_on          [i] <= 'd0;
            pull_precharge_en[i] <= 'd0;
            pull_target      [i] <= 'd0;
            pull_initI       [i] <= 'd0;
            pull_limitI      [i] <= 'd0;
        end

        case (Workmod_i)
            WORKMOD_CC:begin
                pull_on          [0] <= pull_on_i          ;
                pull_precharge_en[0] <= pull_precharge_en_i;
                pull_target      [0] <= pull_target_i      ;
                pull_initI       [0] <= pull_initI_i       ;
                pull_limitI      [0] <= pull_limitI_i      ;

                pull_on_doing_o  <= pull_on_doing [0];
                dac_data_valid_o <= dac_data_valid[0];
                dac_data_o       <= dac_data      [0];
                dac_data_limit_o <= dac_data_limit[0];
            end
            WORKMOD_CP:begin
                pull_on          [1] <= pull_on_i          ;
                pull_precharge_en[1] <= pull_precharge_en_i;
                pull_target      [1] <= pull_target_i      ;
                pull_initI       [1] <= pull_initI_i       ;
                pull_limitI      [1] <= pull_limitI_i      ;

                pull_on_doing_o  <= pull_on_doing [1];
                dac_data_valid_o <= dac_data_valid[1];
                dac_data_o       <= dac_data      [1];
                dac_data_limit_o <= dac_data_limit[1];
            end
            WORKMOD_CR:begin
                pull_on          [2] <= pull_on_i          ;
                pull_precharge_en[2] <= pull_precharge_en_i;
                pull_target      [2] <= pull_target_i      ;
                pull_initI       [2] <= pull_initI_i       ;
                pull_limitI      [2] <= pull_limitI_i      ;

                pull_on_doing_o  <= pull_on_doing [2];
                dac_data_valid_o <= dac_data_valid[2];
                dac_data_o       <= dac_data      [2];
                dac_data_limit_o <= dac_data_limit[2];
            end
            WORKMOD_CV: begin
                if (CV_mode_hard_ON_i && hardware_lock_off_en_o) begin
                    pull_on          [4] <= pull_on_i          ;
                    pull_precharge_en[4] <= pull_precharge_en_i;
                    pull_target      [4] <= pull_target_i      ;
                    pull_initI       [4] <= pull_initI_i       ;
                    pull_limitI      [4] <= pull_limitI_i      ;

                    pull_on_doing_o  <= pull_on_doing [4];
                    dac_data_valid_o <= dac_data_valid[4];
                    dac_data_o       <= dac_data      [4];
                    dac_data_limit_o <= dac_data_limit[4];
                end
                else begin
                    pull_on          [3] <= pull_on_i          ;
                    pull_precharge_en[3] <= pull_precharge_en_i;
                    pull_target      [3] <= pull_target_i      ;
                    pull_initI       [3] <= pull_initI_i       ;
                    pull_limitI      [3] <= pull_limitI_i      ;

                    pull_on_doing_o  <= pull_on_doing [3];
                    dac_data_valid_o <= dac_data_valid[3];
                    dac_data_o       <= dac_data      [3];
                    dac_data_limit_o <= dac_data_limit[3];
                end
            end
            default: begin
                
            end
        endcase
    end
end


// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计算
//---------------------------------------------------------------------
div_s48_s24 u_SR_slew_period (
    .aclk                           (sys_clk_i          ),// input wire aclk
    .s_axis_divisor_tvalid          (1'd1               ),// input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata           (24'd100_000        ),// input wire [23 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid         (1'd1               ),// input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata          ({4'd0,pull_Rslew_i,20'd0}),// input wire [47 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid             (                   ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata              (SR_slew_period_temp) // output wire [71 : 0] m_axis_dout_tdata
);

    assign                          SR_slew_period     = SR_slew_period_temp[AXI_REG_WIDTH+48-1: 24];


div_s48_s24 u_SF_slew_period (
    .aclk                           (sys_clk_i          ),// input wire aclk
    .s_axis_divisor_tvalid          (1'd1               ),// input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata           (24'd100_000        ),// input wire [23 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid         (1'd1               ),// input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata          ({4'd0,SF_slew_i,20'd0}),// input wire [47 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid             (                   ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata              (SF_slew_period_temp) // output wire [71 : 0] m_axis_dout_tdata
);

    assign                          SF_slew_period     = SF_slew_period_temp[AXI_REG_WIDTH+48-1: 24];

div_s48_s24 u_CV_slew_period (
    .aclk                           (sys_clk_i          ),// input wire aclk
    .s_axis_divisor_tvalid          (1'd1               ),// input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata           (24'd100_000        ),// input wire [23 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid         (1'd1               ),// input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata          ({4'd0,CV_slew,20'd0}),// input wire [47 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid             (                   ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata              (CV_slew_period_temp) // output wire [71 : 0] m_axis_dout_tdata
);

    assign                          CV_slew_period     = CV_slew_period_temp[AXI_REG_WIDTH+48-1: 24];
// ********************************************************************************** // 
//---------------------------------------------------------------------
// CC PULL
//---------------------------------------------------------------------
pull_load_cc#(
    .SIMULATION                     (SIMULATION         ),
    .RF_MAX_LIMIT                   (RF_MAX_LIMIT       ),
    .PRECHARGE_I                    (PRECHARGE_I        ),
    .AXI_REG_WIDTH                  (AXI_REG_WIDTH      ) 
)
u_pull_load_cc(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),

    .on_i                           (pull_on          [0]),
    .precharge_en_i                 (pull_precharge_en[0]),// 预充使能
    .target_i                       (pull_target      [0]),// 目标值mA
    .initI_i                        (pull_initI       [0]),// 初始电流值mA
    .limitI_i                       (pull_limitI      [0]),// 限制电流mA
    .SR_slew_i                      (SR_slew_i          ),// 电流上升斜率单位1mA/ms 需要保护
    .SF_slew_i                      (SF_slew_i          ),// 电流下降斜率单位1mA/ms 需要保护
    .SR_slew_period_i               (SR_slew_period     ),// 电流上升斜率单位1mA/10ns(every period) slew_i除以100_000
    .SF_slew_period_i               (SF_slew_period     ),// 电流下降斜率单位1mA/10ns(every period) slew_i除以100_000
    .Short_flag_i                   (Short_flag_i       ),// 短路测试 (STA/DYN)
    .I_short_i                      (I_short_i          ),// 短路时拉载电流
    .k_i                            (CC_k_i             ),
    .b_i                            (CC_a_i             ),
    .pull_on_doing_o                (pull_on_doing   [0]),
    .dac_data_valid_o               (dac_data_valid  [0]),
    .dac_data_o                     (dac_data        [0]),
    .dac_data_limit_o               (dac_data_limit  [0]) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// CP PULL
//---------------------------------------------------------------------
pull_load_cp#(
    .SIMULATION                     (SIMULATION         ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ),
    .RF_MAX_LIMIT                   (RF_MAX_LIMIT       ),
    .PRECHARGE_I                    (PRECHARGE_I        ),
    .AXI_REG_WIDTH                  (AXI_REG_WIDTH      ) 
)
u_pull_load_cp(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .global_1us_flag_i              (global_1us_flag_i  ),

    .on_i                           (pull_on          [1]),
    .precharge_en_i                 (pull_precharge_en[1]),// 预充使能
    .target_i                       (pull_target      [1]),// 目标值mW
    .initI_i                        (pull_initI       [1]),// 初始电流值mA
    .limitI_i                       (pull_limitI      [1]),// 限制电流mA
    .SR_slew_i                      (SR_slew_i          ),// 电流上升斜率单位1mA/ms 需要保护
    .SF_slew_i                      (SF_slew_i          ),// 电流下降斜率单位1mA/ms 需要保护
    .SR_slew_period_i               (SR_slew_period     ),// 电流上升斜率单位1mA/10ns(every period) slew_i除以100_000
    .SF_slew_period_i               (SF_slew_period     ),// 电流下降斜率单位1mA/10ns(every period) slew_i除以100_000
    .Short_flag_i                   (Short_flag_i       ),// 短路测试 (STA/DYN)
    .I_short_i                      (I_short_i          ),// 短路时拉载电流
    .k_i                            (CC_k_i             ),
    .b_i                            (CC_a_i             ),
    .U_abs_i                        (U_abs_i            ),// mV
    .pull_on_doing_o                (pull_on_doing   [1]),// 表面当前正在进行电流输出控制
    .dac_data_valid_o               (dac_data_valid  [1]),
    .dac_data_o                     (dac_data        [1]),
    .dac_data_limit_o               (dac_data_limit  [1]) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// CR PULL
//---------------------------------------------------------------------

pull_load_cr#(
    .SIMULATION                     (SIMULATION         ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ),
    .RF_MAX_LIMIT                   (RF_MAX_LIMIT       ),
    .PRECHARGE_I                    (PRECHARGE_I        ),
    .AXI_REG_WIDTH                  (AXI_REG_WIDTH      ) 
)
 u_pull_load_cr(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .global_1us_flag_i              (global_1us_flag_i  ),

    .on_i                           (pull_on          [2]),
    .precharge_en_i                 (pull_precharge_en[2]),// 预充使能
    .target_i                       (pull_target      [2]),// 目标值ohm*10**-4
    .initI_i                        (pull_initI       [2]),// 初始电流值mA
    .limitI_i                       (pull_limitI      [2]),// 限制电流mA
    .SR_slew_i                      (SR_slew_i          ),// 电流上升斜率单位1mA/ms 需要保护
    .SF_slew_i                      (SF_slew_i          ),// 电流下降斜率单位1mA/ms 需要保护
    .SR_slew_period_i               (SR_slew_period     ),// 电流上升斜率单位1mA/10ns(every period) slew_i除以100_000
    .SF_slew_period_i               (SF_slew_period     ),// 电流下降斜率单位1mA/10ns(every period) slew_i除以100_000
    .Short_flag_i                   (Short_flag_i       ),// 短路测试 (STA/DYN)
    .I_short_i                      (I_short_i          ),// 短路时拉载电流
    .k_i                            (CC_k_i             ),
    .b_i                            (CC_a_i             ),
    .U_abs_i                        (U_abs_i            ),// mV
    .pull_on_doing_o                (pull_on_doing   [2]),// 表面当前正在进行电流输出控制
    .dac_data_valid_o               (dac_data_valid  [2]),
    .dac_data_o                     (dac_data        [2]),
    .dac_data_limit_o               (dac_data_limit  [2]) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// software CV PULL
//---------------------------------------------------------------------    

pull_load_software_cv#(
    .SIMULATION                     (SIMULATION         ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ),
    .RF_MAX_LIMIT                   (RF_MAX_LIMIT       ),
    .PRECHARGE_I                    (PRECHARGE_I        ),
    .AXI_REG_WIDTH                  (AXI_REG_WIDTH      ) 
)
u_pull_load_software_cv(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .Von_i                          (Von_i              ),// 开启电压mV
    .global_1us_flag_i              (global_1us_flag_i  ),

    .on_i                           (pull_on          [3]),
    .target_i                       (pull_target      [3]),// 目标值mV
    .initI_i                        (pull_initI       [3]),// 初始电流值mA
    .limitI_i                       (pull_limitI      [3]),// 限制电流mA
    .CV_slew_i                      (CV_slew            ),// CV模式电压变化斜率(1mV/ms)
    .CV_slew_period_i               (CV_slew_period     ),// CV模式电压变化斜率(1mV/ms)
    .SR_slew_i                      (SR_slew_i          ),// 电流上升斜率单位1mA/ms 需要保护
    .SF_slew_i                      (SF_slew_i          ),// 电流下降斜率单位1mA/ms 需要保护
    .SR_slew_period_i               (SR_slew_period     ),// 电流上升斜率单位1mA/10ns(every period) slew_i除以100_000
    .SF_slew_period_i               (SF_slew_period     ),// 电流下降斜率单位1mA/10ns(every period) slew_i除以100_000
    .Short_flag_i                   (Short_flag_i       ),// 短路测试 (STA/DYN)
    .I_short_i                      (I_short_i          ),// 短路时拉载电流
    .k_i                            (CC_k_i             ),
    .b_i                            (CC_a_i             ),
    .KP_i                           (KP_i               ),// 比例系数*2^16
    .KI_i                           (KI_i               ),// 积分系数*2^16
    .KD_i                           (KD_i               ),// 微分系数*2^16
    .U_abs_i                        (U_abs_i            ),// mV
    .I_abs_i                        (I_abs_i            ),// mV
    .pull_on_doing_o                (pull_on_doing   [3]),// 表面当前正在进行电流输出控制
    .dac_data_valid_o               (dac_data_valid  [3]),
    .dac_data_o                     (dac_data        [3]),
    .dac_data_limit_o               (dac_data_limit  [3]) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// hardware CV PULL
//---------------------------------------------------------------------    
pull_load_hardware_cv#(
    .SIMULATION                     (SIMULATION         ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ),
    .RF_MAX_LIMIT                   (RF_MAX_LIMIT       ),
    .PRECHARGE_I                    (PRECHARGE_I        ),
    .AXI_REG_WIDTH                  (AXI_REG_WIDTH      ) 
)
u_pull_load_hardware_cv(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .global_1us_flag_i              (global_1us_flag_i  ),

    .on_i                           (pull_on          [4]),
    .target_i                       (pull_target      [4]),// 目标值mV
    .initI_i                        (pull_initI       [4]),// 初始电流值mA
    .limitI_i                       (pull_limitI      [4]),// 限制电流mA
    .CV_slew_i                      (CV_slew            ),// CV模式电压变化斜率(1mV/ms)
    .CV_slew_period_i               (CV_slew_period     ),// CV模式电压变化斜率(1mV/ms)
    .SR_slew_i                      (SR_slew_i          ),// 电流上升斜率单位1mA/ms 需要保护
    .SF_slew_i                      (SF_slew_i          ),// 电流下降斜率单位1mA/ms 需要保护
    .SR_slew_period_i               (SR_slew_period     ),// 电流上升斜率单位1mA/10ns(every period) slew_i除以100_000
    .SF_slew_period_i               (SF_slew_period     ),// 电流下降斜率单位1mA/10ns(every period) slew_i除以100_000
    .Short_flag_i                   (Short_flag_i       ),// 短路测试 (STA/DYN)
    .k_i                            (CC_k_i             ),//CV limit校准
    .b_i                            (CC_a_i             ),
    .k_cv_i                         (CV_k_i             ),//CV target校准
    .b_cv_i                         (CV_a_i             ),
    .U_abs_i                        (U_abs_i            ),// mV
    .pull_on_doing_o                (pull_on_doing   [4]),// 表面当前正在进行电流输出控制
    .dac_data_valid_o               (dac_data_valid  [4]),
    .dac_data_o                     (dac_data        [4]),
    .dac_data_limit_o               (dac_data_limit  [4]) 
);









endmodule


`default_nettype wire
