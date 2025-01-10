`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             get_I_short.v
// Create Date:           2025/01/08 16:57:38
// Version:               V1.0
// PATH:                  srcs\rtl\e_load_wrapper\get_I_short.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module get_I_short #(
    parameter                       AXI_REG_WIDTH      = 24    ,
    parameter                       CALCULATE_WIDTH    = 24    
) (
    input  wire                     sys_clk_i           ,

    input  wire        [  31: 0]    U_abs_i             ,
    input  wire        [  31: 0]    I_max_i             ,
    input  wire        [  31: 0]    P_max_i             ,
    input  wire        [  31: 0]    I_limit_i           ,
    input  wire        [  31: 0]    P_limit_i           ,

    output reg         [  31: 0]    I_short_o            
);
    reg                [  31: 0]    min_P               ;
    reg                [  31: 0]    min_I               ;

    reg                [AXI_REG_WIDTH-1: 0]target_current  ;
    wire               [AXI_REG_WIDTH+24-1: 0]target_mult1000  ;
    wire               [AXI_REG_WIDTH-1: 0]P_div_U      ;
    wire               [AXI_REG_WIDTH+CALCULATE_WIDTH+24-1: 0]P_div_U_temp  ;

always@(posedge sys_clk_i)begin
    if (P_max_i > P_limit_i) begin
        min_P <= P_limit_i;
    end
    else begin
        min_P <= P_max_i;
    end
end

always@(posedge sys_clk_i)begin
    if (I_max_i > I_limit_i) begin
        min_I <= I_limit_i;
    end
    else begin
        min_I <= I_max_i;
    end
end

    assign                          target_mult1000[AXI_REG_WIDTH+24-1:34]= 0;

mult_u24_u10 u_target_mult1000 (
    .CLK                            (sys_clk_i          ),// input wire CLK
    .A                              (min_P[23:0]        ),// input wire [23 : 0] A
    .B                              (10'd1000           ),// input wire [9 : 0] B
    .P                              (target_mult1000[33:0]) // output wire [33 : 0] P
);

div_s48_s24 u_target_current (
    .aclk                           (sys_clk_i          ),// input wire aclk
    .s_axis_divisor_tvalid          (1'd1               ),// input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata           ((U_abs_i == 0) ? 24'b1 : U_abs_i),// input wire [23 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid         (1'd1               ),// input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata          (target_mult1000    ),// input wire [47 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid             (                   ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata              (P_div_U_temp       ) // output wire [71 : 0] m_axis_dout_tdata
);

    assign                          P_div_U            = P_div_U_temp[AXI_REG_WIDTH+CALCULATE_WIDTH+24-1:24];//È¡ÉÌ

always@(posedge sys_clk_i)begin
    if (min_I > P_div_U) begin
        I_short_o <= P_div_U;
    end
    else begin
        I_short_o <= min_I;
    end
end


endmodule


`default_nettype wire
