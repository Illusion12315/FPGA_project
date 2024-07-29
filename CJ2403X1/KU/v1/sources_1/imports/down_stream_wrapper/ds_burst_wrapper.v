`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             ds_burst_wrapper
// Create Date:           2024/06/29 14:36:09
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\down_stream_wrapper\ds_burst_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module ds_burst_wrapper (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire        [   7: 0]        prased_des_id_r1           ,

    input  wire                         ds_burst_valid_i           ,
    input  wire        [ 127: 0]        ds_burst_data_i             

);






endmodule