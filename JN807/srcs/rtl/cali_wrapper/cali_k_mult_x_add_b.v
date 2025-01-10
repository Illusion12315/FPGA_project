`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             cali_k_mult_x_add_b.v
// Create Date:           2024/12/30 17:21:50
// Version:               V1.0
// PATH:                  srcs\cali_wrapper\cali_k_mult_x_add_b.v
// Descriptions:          k * x + b
// 
// ********************************************************************************** // 
`default_nettype none


module cali_k_mult_x_add_b #(
    parameter                       X_WIDTH            = 16    ,
    parameter                       K_WIDTH            = 16    ,
    parameter                       B_WIDTH            = 16    
) (
    input  wire                     sys_clk_i           ,

    input  wire signed [X_WIDTH-1: 0]x_i                ,
    input  wire        [K_WIDTH-1: 0]k_i                ,
    input  wire signed [B_WIDTH-1: 0]b_i                ,
    input  wire        [   7: 0]    right_shift_i       ,

    output wire signed [X_WIDTH+K_WIDTH: 0]y_o           
);

    wire     signed    [X_WIDTH+K_WIDTH-1: 0]kx_temp    ;
    reg      signed    [X_WIDTH+K_WIDTH-1: 0]y_temp     ;

    assign                          y_o                = y_temp >>> right_shift_i;

generate
    if (X_WIDTH == 16 && K_WIDTH == 16) begin : s16_s16

mult_s16_u16 u_mult_s16_u16 (
    .CLK                            (sys_clk_i          ),// input wire CLK
    .A                              (x_i[X_WIDTH-1:0]   ),// input wire [15 : 0] A
    .B                              (k_i[K_WIDTH-1:0]   ),// input wire [15 : 0] B
    .P                              (kx_temp[X_WIDTH+K_WIDTH-1:0]) // output wire [31 : 0] P
);

    end
    else if (X_WIDTH == 24 && K_WIDTH == 16) begin : s24_s16
        
mult_s24_u16 u_mult_s24_u16 (
    .CLK                            (sys_clk_i          ),// input wire CLK
    .A                              (x_i[X_WIDTH-1:0]   ),// input wire [23 : 0] A
    .B                              (k_i[K_WIDTH-1:0]   ),// input wire [15 : 0] B
    .P                              (kx_temp[X_WIDTH+K_WIDTH-1:0]) // output wire [47 : 0] P
);

    end
    else begin : df

mult_s16_s16 u_mult_s16_s16 (
    .CLK                            (sys_clk_i          ),// input wire CLK
    .A                              (k_i[K_WIDTH-1:0]   ),// input wire [15 : 0] A
    .B                              (x_i[X_WIDTH-1:0]   ),// input wire [15 : 0] B
    .P                              (kx_temp[X_WIDTH+K_WIDTH-1:0]) // output wire [31 : 0] P
);

    end

endgenerate

always@(posedge sys_clk_i)begin
    y_temp <= kx_temp[X_WIDTH+K_WIDTH-1:0] + b_i[B_WIDTH-1:0];
end


endmodule


`default_nettype wire
