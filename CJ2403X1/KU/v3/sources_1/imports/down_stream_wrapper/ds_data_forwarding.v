`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             ds_data_forwarding
// Create Date:           2024/06/29 14:37:20
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\down_stream_wrapper\ds_data_forwarding.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module ds_data_forwarding #(
    parameter                           DS_CHANNEL                = 8    
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire        [   7: 0]        prased_src_id_r1           ,
    input  wire        [   7: 0]        prased_des_id_r1           ,
    input  wire        [   7: 0]        prased_data_type_r1        ,
    input  wire        [   7: 0]        prased_data_channel_r1     ,
    input  wire        [  15: 0]        prased_data_field_len_r1   ,

    input  wire                         ds_burst_valid_i           ,
    input  wire        [ 127: 0]        ds_burst_data_i            ,

    output reg         [DS_CHANNEL-1: 0]ds_burst_wr_en_o           ,
    output reg         [DS_CHANNEL*128-1: 0]ds_burst_dout_o        ,
    input  wire        [DS_CHANNEL-1: 0]ds_burst_prog_full_i        
);

always@(posedge sys_clk_i)begin
    begin
        ds_burst_wr_en_o <= 'd0;
        ds_burst_dout_o <= 'd0;
    end
    case (prased_des_id_r1)
        8'h17: begin
            ds_burst_wr_en_o[0] <= ds_burst_valid_i;
            ds_burst_dout_o[128*0 +: 128] <= ds_burst_data_i;
        end
        8'h18: begin
            ds_burst_wr_en_o[1] <= ds_burst_valid_i;
            ds_burst_dout_o[128*1 +: 128] <= ds_burst_data_i;
        end
        8'h19: begin
            ds_burst_wr_en_o[2] <= ds_burst_valid_i;
            ds_burst_dout_o[128*2 +: 128] <= ds_burst_data_i;
        end
        8'h1a: begin
            ds_burst_wr_en_o[3] <= ds_burst_valid_i;
            ds_burst_dout_o[128*3 +: 128] <= ds_burst_data_i;
        end
        8'h1b: begin
            ds_burst_wr_en_o[4] <= ds_burst_valid_i;
            ds_burst_dout_o[128*4 +: 128] <= ds_burst_data_i;
        end
        8'h1c: begin
            ds_burst_wr_en_o[5] <= ds_burst_valid_i;
            ds_burst_dout_o[128*5 +: 128] <= ds_burst_data_i;
        end
        8'h11: begin
            ds_burst_wr_en_o[6] <= ds_burst_valid_i;
            ds_burst_dout_o[128*6 +: 128] <= ds_burst_data_i;
        end
        8'h10: begin
            ds_burst_wr_en_o[7] <= ds_burst_valid_i;
            ds_burst_dout_o[128*7 +: 128] <= ds_burst_data_i;
        end
        default: begin
            ds_burst_wr_en_o <= 'd0;
            ds_burst_dout_o <= 'd0;
        end
    endcase
end

endmodule