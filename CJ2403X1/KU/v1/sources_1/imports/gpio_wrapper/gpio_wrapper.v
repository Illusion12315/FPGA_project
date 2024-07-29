`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             gpio_wrapper
// Create Date:           2024/07/03 10:58:13
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\AI3\AI3_top_v1\AI3_top_v1.srcs\sources_1\imports\clk_rst_wrapper\gpio_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module gpio_wrapper (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire                         gpio_start_trigger_i       ,
    output wire        [  44: 0]        GPIO1V8                     
);

    reg                [   7: 0]        clk_cnt                    ;
    reg                [  44: 0]        gpio_r1,gpio_r2            ;
    reg                                 GPIO_PWM                   ;

    assign                              GPIO1V8[44:17]            = gpio_r2[44:17];
    assign                              GPIO1V8[16]               = GPIO_PWM;
    assign                              GPIO1V8[15:0]             = gpio_r2[15:0];

always@(posedge sys_clk_i)begin
    gpio_r1 <= {45{gpio_start_trigger_i}};
    gpio_r2 <= gpio_r1;

    GPIO_PWM <= 'd0;
end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------


endmodule