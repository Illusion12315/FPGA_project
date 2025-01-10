`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             get_ovcp_wrapper.v
// Create Date:           2025/01/08 18:15:51
// Version:               V1.0
// PATH:                  srcs\rtl\e_load_wrapper\get_ovcp_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module get_ovcp_wrapper #(
    parameter                       SIMULATION         = 0     ,
    parameter                       CALCULATE_WIDTH    = 24    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,
    input  wire                     global_1us_flag_i   ,
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
    input  wire signed [  31: 0]    P_rt_i              ,

    input  wire                     Clear_alarm_ON_i    ,//
    output wire                     ovp_maxU_alarm_o    ,//
    output wire                     ocp_maxI_alarm_o    ,//
    output wire                     ocp_alarm_o         ,//
    output wire                     opp_maxP_alarm_o    ,//
    output wire                     opp_alarm_o          //
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    wire                            ocp_I_max_1R12_alarm  ;
    wire                            ocp_I_max_1R03_alarm  ;
    wire               [CALCULATE_WIDTH-1: 0]I_max_1R12  ;
    wire               [CALCULATE_WIDTH-1: 0]I_max_1R03  ;
    
    wire                            ocp_I_limit_alarm   ;

    // wire                            ocp_P_max_1R03_alarm  ;
    wire                            ocp_P_max_1R12_alarm  ;
    wire                            ocp_P_max_2R25_alarm  ;
    wire                            ocp_P_max_4R00_alarm  ;
    // wire               [  31: 0]    P_max_1R03          ;
    wire               [  31: 0]    P_max_1R12          ;
    wire               [  31: 0]    P_max_2R25          ;
    wire               [  31: 0]    P_max_4R00          ;

    wire                            ocp_P_limit_alarm   ;

    reg                [CALCULATE_WIDTH-1: 0]U_max_add_500  ;

    wire                            ocp_U_max_alarm     ;

    assign                          ovp_maxU_alarm_o   = ocp_U_max_alarm;
    assign                          ocp_maxI_alarm_o   = ocp_I_max_1R12_alarm || ocp_I_max_1R03_alarm;// 1 2级别保护
    assign                          ocp_alarm_o        = ocp_I_limit_alarm;
    assign                          opp_maxP_alarm_o   = ocp_P_max_1R12_alarm || ocp_P_max_2R25_alarm || ocp_P_max_4R00_alarm;// 1 2 3级别保护
    assign                          opp_alarm_o        = ocp_P_limit_alarm;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计算保护时间
//---------------------------------------------------------------------
    reg                [  23: 0]    sw_pro_time         ;

always@(posedge sys_clk_i)begin
    if (Pro_time_i == 0) begin
        sw_pro_time <= 1'd0;
    end
    else begin
        sw_pro_time <= (Pro_time_i << 6) + (Pro_time_i << 5) + (Pro_time_i << 2);// 64 + 32 + 4
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 电流峰值保护OCP MAX
//---------------------------------------------------------------------

mult_x_fixed_point#(
    .FIXED_POINT                    (1.12               ),//x乘以的定点数
    .MULTIPLE                       (8                  ) //计算时扩大2**MULTIPLE倍
)
u_I_max_1R12(
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            (I_max_i[23:0]      ),
    .y_o                            (I_max_1R12         ) 
);

get_protect #(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_I_max_1R12_protect(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (0                  ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (I_max_1R12         ),//都是绝对值
    .protect_signal_i               (I_rt_i             ),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (ocp_I_max_1R12_alarm) 
);

mult_x_fixed_point#(
    .FIXED_POINT                    (1.03               ),//x乘以的定点数
    .MULTIPLE                       (8                  ) //计算时扩大2**MULTIPLE倍
)
u_I_max_1R03(
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            (I_max_i[23:0]      ),
    .y_o                            (I_max_1R03         ) 
);

get_protect #(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_I_max_1R03_protect(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (2000               ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (I_max_1R03         ),//都是绝对值
    .protect_signal_i               (I_rt_i             ),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (ocp_I_max_1R03_alarm) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// 电流保护OCP，预设值
//---------------------------------------------------------------------
get_protect #(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_I_limit_protect(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (sw_pro_time        ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (I_limit_i          ),//都是绝对值
    .protect_signal_i               (I_rt_i             ),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (ocp_I_limit_alarm  ) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// 功率峰值保护OPP MAX
//---------------------------------------------------------------------
mult_x_fixed_point#(
    .FIXED_POINT                    (4                  ),//x乘以的定点数
    .MULTIPLE                       (8                  ) //计算时扩大2**MULTIPLE倍
)
u_P_max_4R00(
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            ({{(32-CALCULATE_WIDTH){1'b0}},P_max_i[23:0]}),
    .y_o                            (P_max_4R00         ) 
);

get_protect #(
    .CALCULATE_WIDTH                (32                 ) 
)
u_P_max_4R00_protect(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (0                  ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (P_max_4R00         ),//都是绝对值
    .protect_signal_i               (P_rt_i             ),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (ocp_P_max_4R00_alarm) 
);


mult_x_fixed_point#(
    .FIXED_POINT                    (2.25               ),//x乘以的定点数
    .MULTIPLE                       (8                  ) //计算时扩大2**MULTIPLE倍
)
u_P_max_2R25(
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            ({{(32-CALCULATE_WIDTH){1'b0}},P_max_i[23:0]}),
    .y_o                            (P_max_2R25         ) 
);

get_protect #(
    .CALCULATE_WIDTH                (32                 ) 
)
u_P_max_2R25_protect(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (40                 ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (P_max_2R25         ),//都是绝对值
    .protect_signal_i               (P_rt_i             ),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (ocp_P_max_2R25_alarm) 
);

mult_x_fixed_point#(
    .FIXED_POINT                    (1.12               ),//x乘以的定点数
    .MULTIPLE                       (8                  ) //计算时扩大2**MULTIPLE倍
)
u_P_max_1R12(
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            ({{(32-CALCULATE_WIDTH){1'b0}},P_max_i[23:0]}),
    .y_o                            (P_max_1R12         ) 
);

get_protect #(
    .CALCULATE_WIDTH                (32                 ) 
)
u_P_max_1R12_protect(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (2400               ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (P_max_1R12         ),//都是绝对值
    .protect_signal_i               (P_rt_i             ),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (ocp_P_max_1R12_alarm) 
);

// mult_x_fixed_point#(
//     .FIXED_POINT                    (1.03               ),//x乘以的定点数
//     .MULTIPLE                       (8                  ) //计算时扩大2**MULTIPLE倍
// )
// u_P_max_1R03(
//     .sys_clk_i                      (sys_clk_i          ),
//     .x_i                            (P_max_i[23:0]      ),
//     .y_o                            (P_max_1R03         ) 
// );

// get_protect #(
//     .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
// )
// u_P_max_1R03_protect(
//     .sys_clk_i                      (sys_clk_i          ),
//     .rst_n_i                        (rst_n_i            ),

//     .global_1us_flag_i              (global_1us_flag_i  ),
//     .protect_time_i                 (20_000             ),//单位,us,如果为0代表立即保护
//     .protect_limit_i                (P_max_1R03         ),//都是绝对值
//     .protect_signal_i               (P_rt_i             ),//都是绝对值
//     .protect_clear_i                (Clear_alarm_ON_i   ),
//     .protect_alarm_o                (ocp_P_max_1R03_alarm) 
// );

// ********************************************************************************** // 
//---------------------------------------------------------------------
// 功率保护OPP 
//---------------------------------------------------------------------
get_protect #(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_P_limit_protect(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (sw_pro_time        ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (P_limit_i          ),//都是绝对值
    .protect_signal_i               (P_rt_i             ),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (ocp_P_limit_alarm  ) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// OVP
//---------------------------------------------------------------------
always@(posedge sys_clk_i)begin
    U_max_add_500 <= U_max_i + 500;
end

get_protect #(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_U_max_protect(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (100_000            ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (U_max_add_500      ),//都是绝对值
    .protect_signal_i               (U_rt_i             ),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (ocp_U_max_alarm    ) 
);

endmodule


`default_nettype wire
