`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             get_I_gear.v
// Create Date:           2025/01/07 14:10:46
// Version:               V1.0
// PATH:                  srcs\rtl\cali_wrapper\get_I_gear.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module get_I_gear #(
    parameter                       I_WATERSHED        = 20_000,//������λ�л���ˮ��20A
    parameter                       I_STANDARD_DEVIATION= 1_000 //��׼��1A
) (
    input  wire                     sys_clk_i           ,//clk100m
    input  wire                     rst_n_i             ,

    input  wire                     I_cali_abs_i        ,
    output reg                      I_gear_H_ON_o        //�ߴ���ߵ�
);
    localparam                      TIME_1MS           = 100_000;

    reg                [  31: 0]    gear_switch_cnt     ;

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        I_gear_H_ON_o <= 'd0;                                       //��ʼΪ�͵�
    end
    else if (gear_switch_cnt == TIME_1MS - 1) begin                 //�����е�λ�������ҳ���1ms
        I_gear_H_ON_o <= ~I_gear_H_ON_o;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        gear_switch_cnt <= 'd0;
    end
    else if (I_cali_abs_i > I_WATERSHED + I_STANDARD_DEVIATION) begin
        gear_switch_cnt <= gear_switch_cnt + 'd1;
    end
    else if (I_cali_abs_i < I_WATERSHED - I_STANDARD_DEVIATION) begin
        gear_switch_cnt <= gear_switch_cnt + 'd1;
    end
    else begin
        gear_switch_cnt <= 'd0;
    end
end





endmodule


`default_nettype wire
