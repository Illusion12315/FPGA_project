`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             zx_us_burst_cache_wrapper
// Create Date:           2024/07/12 09:53:48
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v2\cfg_ku_top_v2.srcs\sources_1\imports\up_stream_wrapper\zx_us_burst_cache_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module zx_us_burst_cache_wrapper #(
    parameter                           ZX_CHANNEL                = 2     
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire        [ZX_CHANNEL-1: 0]zx_us_burst_valid_i        ,
    input  wire        [ZX_CHANNEL*128-1: 0]zx_us_burst_data_i     ,

    input  wire        [ZX_CHANNEL-1: 0]us_burst_rd_en_i           ,
    output wire        [ZX_CHANNEL*128-1: 0]us_burst_dout_o        ,
    output wire        [ZX_CHANNEL-1: 0]us_burst_empty_o           ,
    output wire        [ZX_CHANNEL*12-1: 0]us_burst_cache_count_o   

);

    wire               [ZX_CHANNEL-1: 0]zx_us_burst_prog_full_o    ;

generate
    genvar i;
    for (i = 0; i<ZX_CHANNEL; i=i+1) begin : fifo2048
        fifo_2048x128b fifo_2048x128b_inst (
            .clk                                (sys_clk_i                 ),// input wire clk
            .srst                               (~rst_n_i                  ),// input wire srst

            .wr_en                              (zx_us_burst_valid_i[i]    ),// input wire wr_en
            .din                                (zx_us_burst_data_i[i*128 +: 128]),// input wire [127 : 0] din
            .full                               (                          ),// output wire full
            .prog_full                          (zx_us_burst_prog_full_o[i]),// output wire prog_full

            .rd_en                              (us_burst_rd_en_i[i]       ),// input wire rd_en
            .dout                               (us_burst_dout_o[i*128 +: 128]),// output wire [127 : 0] dout
            .empty                              (us_burst_empty_o[i]       ),// output wire empty
            .data_count                         (us_burst_cache_count_o[i*12 +: 12]) // output wire [11 : 0] data_count
        );
    end
endgenerate






endmodule


`default_nettype wire