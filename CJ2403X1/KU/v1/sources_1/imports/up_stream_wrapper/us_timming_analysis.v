`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             us_timming_analysis
// Create Date:           2024/06/26 11:14:31
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\up_stream_wrapper\us_timming_analysis.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module us_timming_analysis #(
    parameter                           TOTAL_NUM                 = 104   
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire        [  23: 0]        wr_current_cache_addr      ,
    
    input  wire                         us_timming_valid_i         ,
    input  wire        [ 127: 0]        us_timming_data_i          ,

    output reg         [TOTAL_NUM-1: 0] cache_wr_en_o              ,
    output reg         [ 127: 0]        cache_wr_data_o            ,
    input  wire        [TOTAL_NUM-1: 0] cache_prog_full_i           
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    reg                [  23: 0]        expected_cache_id  [0:TOTAL_NUM-1]  ;
    wire               [TOTAL_NUM-1: 0] wr_addr_match              ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// main code
//---------------------------------------------------------------------
initial begin
    `include "expected_cache_id.vh"
end

always@(posedge sys_clk_i)begin
    cache_wr_data_o <= us_timming_data_i;
end

generate
    genvar i;
    begin : wr_ctrl
        for (i = 0; i<TOTAL_NUM; i=i+1) begin

        assign                              wr_addr_match[i]          = (wr_current_cache_addr == expected_cache_id[i]);
        
        always@(posedge sys_clk_i)begin
            if (!rst_n_i) begin
                cache_wr_en_o[i] <= 'd0;
            end
            else if (wr_addr_match[i]) begin
                cache_wr_en_o[i] <= us_timming_valid_i;
            end
            else
                cache_wr_en_o[i] <= 'd0;
        end

        end
    end
endgenerate
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------


endmodule