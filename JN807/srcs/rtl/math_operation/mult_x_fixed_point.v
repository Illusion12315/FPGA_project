`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             mult_x_fixed_point.v
// Create Date:           2025/01/09 08:30:12
// Version:               V1.0
// PATH:                  srcs\rtl\math_operation\mult_x_fixed_point.v
// Descriptions:          x乘以定点数
// 
// ********************************************************************************** // 
`default_nettype none


module mult_x_fixed_point #(
    parameter                       DATA_WIDTH         = 32    ,//输入数据宽度
    parameter                       FIXED_POINT        = 1.03  ,//x乘以的定点数
    parameter integer               MULTIPLE           = 10     //扩大2**MULTIPLE倍
) (
    input  wire                     sys_clk_i           ,

    input  wire        [DATA_WIDTH-1: 0]x_i             ,
    output wire        [DATA_WIDTH-1: 0]y_o              
);
    localparam integer              FIXED_POINT_EXPAND = FIXED_POINT * (2**MULTIPLE);

    reg                [DATA_WIDTH-1: 0]temp            ;

    assign                          y_o                = temp >> MULTIPLE;

always@(posedge sys_clk_i)begin
    temp <= (x_i << MULTIPLE) + FIXED_POINT_EXPAND;
end

endmodule


`default_nettype wire
