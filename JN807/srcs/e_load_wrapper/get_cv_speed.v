`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             get_cv_speed.v
// Create Date:           2025/01/08 17:28:11
// Version:               V1.0
// PATH:                  srcs\rtl\e_load_wrapper\get_cv_speed.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module get_cv_speed (
    input  wire                     sys_clk_i           ,

    input  wire        [32-1: 0]    CVspeed_i           ,
    input  wire        [32-1: 0]    s_k                 ,
    input  wire        [32-1: 0]    s_a                 ,
    input  wire        [32-1: 0]    m_k                 ,
    input  wire        [32-1: 0]    m_a                 ,
    input  wire        [32-1: 0]    f_k                 ,
    input  wire        [32-1: 0]    f_a                 ,

    output reg         [  31: 0]    KP                  ,
    output reg         [  31: 0]    KI                  ,

    output reg                      cv_sp_slow_o        ,
    output reg                      cv_sp_mid_o         ,
    output reg                      cv_sp_fast_o         
);

always@(posedge sys_clk_i)begin
    case (CVspeed_i[3:0])
        1: begin
            KP <= f_k;
            KI <= f_a;

            cv_sp_slow_o <= 0;
            cv_sp_mid_o  <= 0;
            cv_sp_fast_o <= 1;
        end 
        2: begin
            KP <= m_k;
            KI <= m_a;

            cv_sp_slow_o <= 0;
            cv_sp_mid_o  <= 1;
            cv_sp_fast_o <= 0;
        end 
        3: begin
            KP <= s_k;
            KI <= s_a;

            cv_sp_slow_o <= 1;
            cv_sp_mid_o  <= 0;
            cv_sp_fast_o <= 0;
        end 
        default: begin
            KP <= s_k;
            KI <= s_a;

            cv_sp_slow_o <= 1;
            cv_sp_mid_o  <= 0;
            cv_sp_fast_o <= 0;
        end 
    endcase
end




endmodule


`default_nettype wire
