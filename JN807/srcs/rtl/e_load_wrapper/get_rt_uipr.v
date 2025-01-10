`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             get_rt_uipr.v
// Create Date:           2025/01/10 11:37:35
// Version:               V1.0
// PATH:                  srcs\rtl\e_load_wrapper\get_rt_uipr.v
// Descriptions:          获取实时的UIPR
// 
// ********************************************************************************** // 
`default_nettype none


module get_rt_uipr #(
    parameter                       CALCULATE_WIDTH    = 24    ,
    parameter                       AXI_REG_WIDTH      = 24    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,

//实时的采样数据
    input  wire signed [CALCULATE_WIDTH-1: 0]U_abs_i    ,//实时采样电压
    input  wire signed [CALCULATE_WIDTH-1: 0]I_abs_i    ,//实时采样电流

    output wire signed [  31: 0]    P_rt_o              ,
    output wire signed [  31: 0]    R_rt_o               
);

    wire               [CALCULATE_WIDTH*2-1: 0]P_temp   ;
    wire               [CALCULATE_WIDTH*2+16-1: 0]P_div_1000  ;

// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计算实时P mW
//---------------------------------------------------------------------
    assign                          P_rt_o             = P_div_1000[CALCULATE_WIDTH*2+16-1: 16];

mult_u24_u24 u_U_mult_I (
    .CLK                            (sys_clk_i          ),// input wire CLK
    .A                              (U_abs_i[CALCULATE_WIDTH-1: 0]),// input wire [23 : 0] A
    .B                              (I_abs_i[CALCULATE_WIDTH-1: 0]),// input wire [23 : 0] B
    .P                              (P_temp             ) // output wire [47 : 0] P
);

div_u48_u16 u_P_div_1000 (
    .aclk                           (sys_clk_i          ),// input wire aclk
    .s_axis_divisor_tvalid          ('d1                ),// input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata           (16'd1000           ),// input wire [15 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid         ('d1                ),// input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata          (P_temp             ),// input wire [47 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid             (                   ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata              (P_div_1000         ) // output wire [63 : 0] m_axis_dout_tdata
);


// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计算实时R 
//---------------------------------------------------------------------
    wire               [  71: 0]    U_div_I_temp        ;
    wire               [  47: 0]    U_abs_mult10000     ;

    assign                          U_abs_mult10000[AXI_REG_WIDTH+24-1:38]= 0;

mult_u24_u14 u_target_mult1000 (
    .CLK                            (sys_clk_i          ),// input wire CLK
    .A                              (U_abs_i            ),// input wire [23 : 0] A
    .B                              (14'd10000          ),// input wire [13 : 0] B
    .P                              (U_abs_mult10000[38:0]) // output wire [38 : 0] P
);

div_s48_s24 u_target_current (
    .aclk                           (sys_clk_i          ),// input wire aclk
    .s_axis_divisor_tvalid          (1'd1               ),// input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata           ((I_abs_i == 0) ? 24'b1 : I_abs_i),// input wire [23 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid         (1'd1               ),// input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata          (U_abs_mult10000    ),// input wire [47 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid             (                   ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata              (U_div_I_temp       ) // output wire [71 : 0] m_axis_dout_tdata
);

    assign                          R_rt_o             = U_div_I_temp[AXI_REG_WIDTH+CALCULATE_WIDTH+24-1:24];//取商







endmodule


`default_nettype wire
