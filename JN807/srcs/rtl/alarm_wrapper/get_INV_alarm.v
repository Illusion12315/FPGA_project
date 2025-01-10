`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             get_INV_alarm.v
// Create Date:           2025/01/09 10:15:10
// Version:               V1.0
// PATH:                  srcs\rtl\e_load_wrapper\get_INV_alarm.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module get_INV_alarm #(
    parameter                       CALCULATE_WIDTH    = 24    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,
    input  wire                     global_1us_flag_i   ,

    input  wire                     Clear_alarm_ON_i    ,
    input  wire signed [CALCULATE_WIDTH-1: 0]Umod_rt_i  ,
    input  wire signed [CALCULATE_WIDTH-1: 0]Usense_rt_i,

    output wire                     Umod_inv_alarm_o    ,
    output wire                     Usense_inv_alarm_o   
);

    wire                            Umod_inv_alarm_temp  ;
    wire                            Usense_inv_alarm_temp  ;
    wire     signed    [CALCULATE_WIDTH-1: 0]limit      ;

    assign                          limit              = 300;//0.3V

    //必须是负数，且绝对值大于0.3V
    assign                          Umod_inv_alarm_o   = Umod_rt_i[CALCULATE_WIDTH-1] && Umod_inv_alarm_temp;
    assign                          Usense_inv_alarm_o = Usense_rt_i[CALCULATE_WIDTH-1] && Usense_inv_alarm_temp;

get_protect #(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_Umod_inv_alarm(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (100_000            ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (limit              ),//都是绝对值
    .protect_signal_i               (signed2unsigned(Umod_rt_i)),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (Umod_inv_alarm_temp) 
);

get_protect #(
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_Usense_inv_alarm(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (100_000            ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (limit              ),//都是绝对值
    .protect_signal_i               (signed2unsigned(Usense_rt_i)),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (Usense_inv_alarm_temp) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// functions
//---------------------------------------------------------------------
function [CALCULATE_WIDTH-1: 0] signed2unsigned;
    input              [CALCULATE_WIDTH-1: 0]signed_in  ;
    signed2unsigned    = (signed_in[CALCULATE_WIDTH-1]) ? ~(signed_in - 1) : signed_in;
endfunction




endmodule


`default_nettype wire
