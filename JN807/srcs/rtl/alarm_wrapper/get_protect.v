`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             get_protect.v
// Create Date:           2025/01/08 18:27:10
// Version:               V1.0
// PATH:                  srcs\rtl\e_load_wrapper\get_protect.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module get_protect #(
    parameter                       SIMULATION         = 0     ,
    parameter                       CALCULATE_WIDTH    = 24    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,

    input  wire                     global_1us_flag_i   ,
    input  wire        [  23: 0]    protect_time_i      ,//单位,us,如果为0代表立即保护
    input  wire        [CALCULATE_WIDTH-1: 0]protect_limit_i,//都是绝对值
    input  wire        [CALCULATE_WIDTH-1: 0]protect_signal_i,//都是绝对值
    input  wire                     protect_clear_i     ,
    output reg                      protect_alarm_o      
);

    reg                [  23: 0]    protect_time_reg    ;


always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        protect_time_reg <= 0;
    end
    else if (protect_signal_i > protect_limit_i) begin
        if (global_1us_flag_i) begin
            protect_time_reg <= protect_time_reg + 'd1;
        end
    end
    else begin
        protect_time_reg <= 0;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        protect_alarm_o <= 0;
    end
    else if (protect_clear_i) begin
        protect_alarm_o <= 0;
    end
    else if ((protect_time_i == 0) && (protect_signal_i > protect_limit_i)) begin
        protect_alarm_o <= 1'd1;
    end
    else if ((protect_time_reg >= protect_time_i - 1)) begin
        protect_alarm_o <= 1'd1;
    end
end


endmodule


`default_nettype wire
