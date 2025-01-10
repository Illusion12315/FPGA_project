`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             get_sense_error.v
// Create Date:           2025/01/09 09:57:38
// Version:               V1.0
// PATH:                  srcs\rtl\e_load_wrapper\get_sense_error.v
// Descriptions:          Sense端和Mod端电压差过大，报Sense错误
// 
// ********************************************************************************** // 
`default_nettype none


module get_sense_error #(
    parameter                       SIMULATION         = 0     ,
    parameter                       CALCULATE_WIDTH    = 24    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,
    input  wire                     global_1us_flag_i   ,

    input  wire        [CALCULATE_WIDTH-1: 0]threshold_i,
    input  wire        [CALCULATE_WIDTH-1: 0]Umod_rt_i  ,
    input  wire        [CALCULATE_WIDTH-1: 0]Usense_rt_i,

    input  wire                     Clear_alarm_ON_i    ,
    output wire                     sense_error_o        
);
    reg                [CALCULATE_WIDTH-1: 0]threshold_temp  ;
    wire               [CALCULATE_WIDTH-1: 0]U_xor      ;

    assign                          U_xor              = Umod_rt_i ^ Usense_rt_i;

always@(posedge sys_clk_i)begin
    if ((threshold_i > 500) && (threshold_i < 5000)) begin
        threshold_temp <= threshold_i;
    end
    else if (threshold_i < 500) begin
        threshold_temp <= 500;
    end
    else begin
        threshold_temp <= 5000;
    end
end

get_protect #(
    .SIMULATION                     (SIMULATION         ),
    .CALCULATE_WIDTH                (CALCULATE_WIDTH    ) 
)
u_U_max_protect(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .global_1us_flag_i              (global_1us_flag_i  ),
    .protect_time_i                 (10_000             ),//单位,us,如果为0代表立即保护
    .protect_limit_i                (threshold_temp     ),//都是绝对值
    .protect_signal_i               (U_xor              ),//都是绝对值
    .protect_clear_i                (Clear_alarm_ON_i   ),
    .protect_alarm_o                (sense_error_o      ) 
);



endmodule


`default_nettype wire
