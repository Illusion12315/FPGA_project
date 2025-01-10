`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             alarm_wrapper.v
// Create Date:           2025/01/09 09:30:55
// Version:               V1.0
// PATH:                  srcs\rtl\e_load_wrapper\alarm_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module alarm_wrapper #(
    parameter                       SIMULATION         = 0     ,
    parameter                       CALCULATE_WIDTH    = 24    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,
    input  wire                     global_1us_flag_i   ,

    input  wire                     Clear_alarm_ON_i    ,//
//max
    input  wire        [CALCULATE_WIDTH-1: 0]U_max_i    ,//最大电压限制
    input  wire        [CALCULATE_WIDTH-1: 0]I_max_i    ,//最大电流限制
    input  wire        [CALCULATE_WIDTH-1: 0]P_max_i    ,//最大功率限制
//max
    input  wire        [CALCULATE_WIDTH-1: 0]U_limit_i  ,//电压限制
    input  wire        [CALCULATE_WIDTH-1: 0]I_limit_i  ,//电流限制
    input  wire        [CALCULATE_WIDTH-1: 0]P_limit_i  ,//功率限制
    input  wire        [  15: 0]    Pro_time_i          ,//1-立即保护；10-1mS；20-2mS……150-15mS
//实时的采样数据
    input  wire signed [CALCULATE_WIDTH-1: 0]U_rt_i     ,//实时采样电压
    input  wire signed [CALCULATE_WIDTH-1: 0]I_rt_i     ,//实时采样电流
    input  wire signed [  31: 0]    P_rt_i              ,//mW

    input  wire        [CALCULATE_WIDTH-1: 0]threshold_i,
    input  wire        [CALCULATE_WIDTH-1: 0]Umod_rt_i  ,
    input  wire        [CALCULATE_WIDTH-1: 0]Usense_rt_i,

    output wire                     ovp_maxU_alarm_o    ,
    output wire                     ocp_maxI_alarm_o    ,
    output wire                     ocp_alarm_o         ,
    output wire                     opp_maxP_alarm_o    ,
    output wire                     opp_alarm_o         ,
    output wire                     sense_error_o       ,
    output wire                     Umod_inv_alarm_o    ,
    output wire                     Usense_inv_alarm_o   
);


get_sense_error#(
    .SIMULATION                     (SIMULATION         ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
 u_get_sense_error(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .global_1us_flag_i              (global_1us_flag_i  ),
    .threshold_i                    (threshold_i        ),
    .Umod_rt_i                      (Umod_rt_i          ),
    .Usense_rt_i                    (Usense_rt_i        ),
    .Clear_alarm_ON_i               (Clear_alarm_ON_i   ),
    .sense_error_o                  (sense_error_o      ) 
);

get_ovcp_wrapper #(
    .SIMULATION                     (SIMULATION         ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_get_ovcp_wrapper(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .global_1us_flag_i              (global_1us_flag_i  ),
//max
    .U_max_i                        (U_max_i            ),// 最大电压限制
    .I_max_i                        (I_max_i            ),// 最大电流限制
    .P_max_i                        (P_max_i            ),// 最大功率限制
//max
    .U_limit_i                      (U_limit_i          ),// 电压限制
    .I_limit_i                      (I_limit_i          ),// 电流限制
    .P_limit_i                      (P_limit_i          ),// 功率限制
    .Pro_time_i                     (Pro_time_i         ),// 1-立即保护；10-1mS；20-2mS……150-15mS
//实时的采样数据
    .U_rt_i                         (U_rt_i             ),// 实时采样电压
    .I_rt_i                         (I_rt_i             ),// 实时采样电流
    .P_rt_i                         (P_rt_i             ),
    .Clear_alarm_ON_i               (Clear_alarm_ON_i   ),
    .ovp_maxU_alarm_o               (ovp_maxU_alarm_o   ),
    .ocp_maxI_alarm_o               (ocp_maxI_alarm_o   ),
    .ocp_alarm_o                    (ocp_alarm_o        ),
    .opp_maxP_alarm_o               (opp_maxP_alarm_o   ),
    .opp_alarm_o                    (opp_alarm_o        ) 
);

get_INV_alarm#(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_get_INV_alarm(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .global_1us_flag_i              (global_1us_flag_i  ),
    .Clear_alarm_ON_i               (Clear_alarm_ON_i   ),
    .Umod_rt_i                      (Umod_rt_i          ),
    .Usense_rt_i                    (Usense_rt_i        ),
    .Umod_inv_alarm_o               (Umod_inv_alarm_o   ),
    .Usense_inv_alarm_o             (Usense_inv_alarm_o ) 
);



endmodule


`default_nettype wire
