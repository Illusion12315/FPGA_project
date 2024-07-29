`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             msg_receive_wrapper
// Create Date:           2024/06/26 16:26:59
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\message_wrapper\msg_receive_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module msg_receive_wrapper #(
    parameter                           CHANNEL                   = 6     
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    output wire        [CHANNEL-1: 0]   rd_clk_o                   ,
    output wire        [CHANNEL-1: 0]   rd_en_o                    ,
    input  wire        [CHANNEL*128-1: 0]rd_din_i                  ,
    input  wire        [CHANNEL-1: 0]   rd_empty_i                 ,

    output wire        [CHANNEL*8-1: 0] prased_src_id_r1           ,
    output wire        [CHANNEL*8-1: 0] prased_des_id_r1           ,
    output wire        [CHANNEL*8-1: 0] prased_data_type_r1        ,
    output wire        [CHANNEL*8-1: 0] prased_data_channel_r1     ,
    output wire        [CHANNEL*16-1: 0]prased_data_field_len_r1   ,

    output wire        [CHANNEL-1: 0]   us_timming_valid_o         ,
    output wire        [CHANNEL*128-1: 0]us_timming_data_o         ,

    output wire        [CHANNEL-1: 0]   ds_burst_valid_o           ,
    output wire        [CHANNEL*128-1: 0]ds_burst_data_o           ,

    output wire        [CHANNEL-1: 0]   us_burst_valid_o           ,
    output wire        [CHANNEL*128-1: 0]us_burst_data_o            
);
    integer                             i                          ;

generate
    begin : msg
        genvar i;
        begin: receive
            for (i = 0; i<CHANNEL; i=i+1) begin : channel
                msg_receive_analysis  msg_receive_analysis_inst (
                    .sys_clk_i                          (sys_clk_i                 ),
                    .rst_n_i                            (rst_n_i                   ),

                    .rd_clk_o                           (rd_clk_o[i]               ),
                    .rd_en_o                            (rd_en_o[i]                ),
                    .rd_din_i                           (rd_din_i[i*128 +: 128]    ),
                    .rd_empty_i                         (rd_empty_i[i]             ),

                    .prased_src_id_r1                   (prased_src_id_r1        [i*8 +: 8]),
                    .prased_des_id_r1                   (prased_des_id_r1        [i*8 +: 8]),
                    .prased_data_type_r1                (prased_data_type_r1     [i*8 +: 8]),
                    .prased_data_channel_r1             (prased_data_channel_r1  [i*8 +: 8]),
                    .prased_data_field_len_r1           (prased_data_field_len_r1[i*16 +: 16]),

                    .us_timming_valid_o                 (us_timming_valid_o[i]     ),
                    .us_timming_data_o                  (us_timming_data_o[i*128 +: 128]),

                    .ds_burst_valid_o                   (ds_burst_valid_o[i]       ),
                    .ds_burst_data_o                    (ds_burst_data_o[i*128 +: 128]),

                    .us_burst_valid_o                   (us_burst_valid_o[i]       ),
                    .us_burst_data_o                    (us_burst_data_o[i*128 +: 128]) 
                );
            end
        end
    end
endgenerate

endmodule