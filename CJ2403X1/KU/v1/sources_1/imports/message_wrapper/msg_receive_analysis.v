`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             msg_receive_analysis
// Create Date:           2024/06/25 19:01:28
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\message_wrapper\msg_receive_analysis.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module msg_receive_analysis (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    output wire                         rd_clk_o                   ,
    output wire                         rd_en_o                    ,
    input  wire        [ 127: 0]        rd_din_i                   ,
    input  wire                         rd_empty_i                 ,

    output reg         [   7: 0]        prased_src_id_r1           ,
    output reg         [   7: 0]        prased_des_id_r1           ,
    output reg         [   7: 0]        prased_data_type_r1        ,
    output reg         [   7: 0]        prased_data_channel_r1     ,
    output reg         [  15: 0]        prased_data_field_len_r1   ,

    output reg                          us_timming_valid_o         ,
    output reg         [ 127: 0]        us_timming_data_o          ,

    output reg                          ds_burst_valid_o           ,
    output reg         [ 127: 0]        ds_burst_data_o            ,

    output reg                          us_burst_valid_o           ,
    output reg         [ 127: 0]        us_burst_data_o             

);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    wire               [ 127: 0]        msg_rec_data               ;
    wire                                msg_rec_data_valid         ;

    wire               [   3: 0]        prased_frame_type          ;
    wire               [  15: 0]        prased_frame_cnt           ;
    wire               [   7: 0]        prased_src_id              ;
    wire               [   7: 0]        prased_des_id              ;
    wire               [   7: 0]        prased_data_type           ;
    wire               [   7: 0]        prased_data_channel        ;
    wire               [  15: 0]        prased_data_field_len      ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// main code
//---------------------------------------------------------------------

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        us_timming_valid_o <= 'd0;
        us_timming_data_o  <= 'd0;

        ds_burst_valid_o <= 'd0;
        ds_burst_data_o  <= 'd0;
        
        us_burst_valid_o <= 'd0;
        us_burst_data_o  <= 'd0;
    end
    else case (prased_frame_type)
        4'h1: begin
            us_timming_valid_o <= msg_rec_data_valid;
            us_timming_data_o  <= msg_rec_data;
        end
        4'h2: begin
            ds_burst_valid_o <= msg_rec_data_valid;
            ds_burst_data_o  <= msg_rec_data;
        end
        4'h3: begin
            us_burst_valid_o <= msg_rec_data_valid;
            us_burst_data_o  <= msg_rec_data;
        end
        default: begin
            us_timming_valid_o <= 'd0;
            us_timming_data_o  <= 'd0;
            
            ds_burst_valid_o <= 'd0;
            ds_burst_data_o  <= 'd0;
            
            us_burst_valid_o <= 'd0;
            us_burst_data_o  <= 'd0;
        end
    endcase
end

always@(posedge sys_clk_i)begin
    prased_src_id_r1         <= prased_src_id        ;
    prased_des_id_r1         <= prased_des_id        ;
    prased_data_type_r1      <= prased_data_type     ;
    prased_data_channel_r1   <= prased_data_channel  ;
    prased_data_field_len_r1 <= prased_data_field_len;
end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// instance
//---------------------------------------------------------------------
msg_receive_driver  msg_receive_driver_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),

    .rd_clk_o                           (rd_clk_o                  ),
    .rd_en_o                            (rd_en_o                   ),
    .rd_din_i                           (rd_din_i                  ),
    .rd_empty_i                         (rd_empty_i                ),

    .prased_frame_len                   (                          ),
    .prased_frame_type                  (prased_frame_type         ),
    .prased_frame_cnt                   (prased_frame_cnt          ),
    .prased_src_id                      (prased_src_id             ),
    .prased_des_id                      (prased_des_id             ),
    .prased_data_type                   (prased_data_type          ),
    .prased_data_channel                (prased_data_channel       ),
    .prased_data_field_len              (prased_data_field_len     ),

    .msg_rec_valid_o                    (msg_rec_data_valid        ),
    .msg_rec_data_o                     (msg_rec_data              ),

    .msg_rec_crc_vld_o                  (                          ),
    .msg_rec_crc_data_o                 (                          ) 
  );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------

endmodule
