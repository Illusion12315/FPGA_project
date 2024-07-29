`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             us_timming_wrapper
// Create Date:           2024/06/26 16:37:28
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\up_stream_wrapper\us_timming_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module us_timming_wrapper #(
    parameter                           US_CHANNEL                = 6    ,
    parameter                           TOTAL_NUM                 = 104   
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire        [US_CHANNEL*8-1: 0]prased_src_id_r1         ,
    input  wire        [US_CHANNEL*8-1: 0]prased_des_id_r1         ,
    input  wire        [US_CHANNEL*8-1: 0]prased_data_type_r1      ,
    input  wire        [US_CHANNEL*8-1: 0]prased_data_channel_r1   ,
    input  wire        [US_CHANNEL*16-1: 0]prased_data_field_len_r1,

    input  wire        [US_CHANNEL-1: 0]us_timming_valid_i         ,
    input  wire        [US_CHANNEL*128-1: 0]us_timming_data_i      ,

    input  wire        [US_CHANNEL-1: 0]us_burst_valid_i           ,
    input  wire        [US_CHANNEL*128-1: 0]us_burst_data_i        ,

    input  wire        [TOTAL_NUM-1: 0] us_timming_rd_en_i         ,
    output wire        [TOTAL_NUM*128-1: 0]us_timming_dout_o       ,
    output wire        [TOTAL_NUM-1: 0] us_timming_empty_o         ,
    output wire        [TOTAL_NUM*12-1: 0]us_timming_cache_count_o  
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    wire               [  23: 0]        wr_current_cache_addr[0:US_CHANNEL-1]  ;
    wire               [TOTAL_NUM-1: 0] cache_wr_en_o     [0:US_CHANNEL-1]  ;
    wire               [ 127: 0]        cache_wr_data_o   [0:US_CHANNEL-1]  ;
    wire               [TOTAL_NUM-1: 0] cache_prog_full_i [0:US_CHANNEL-1]  ;

    wire               [US_CHANNEL-1: 0]cache_wr_en_bus    [0:TOTAL_NUM-1]  ;

    integer                             i,j                        ;

    wire               [TOTAL_NUM-1: 0] us_timming_wr_en_i         ;
    wire               [ 127: 0]        us_timming_din_i   [0:TOTAL_NUM-1]  ;
    wire               [TOTAL_NUM-1: 0] us_timming_prog_full_o     ;

generate
begin : us
    genvar i;
    begin : timming
        for (i = 0; i<US_CHANNEL; i=i+1) begin : analysis
            assign wr_current_cache_addr[i] = {
                prased_src_id_r1[i*8 +: 8],
                prased_data_type_r1[i*8 +: 8],
                prased_data_channel_r1[i*8 +: 8]
            };

            us_timming_analysis#(
                .TOTAL_NUM                          (TOTAL_NUM                 ) 
            )
            us_timming_analysis_inst(
                .sys_clk_i                          (sys_clk_i                 ),
                .rst_n_i                            (rst_n_i                   ),
            
                .wr_current_cache_addr              (wr_current_cache_addr[i]  ),
                .us_timming_valid_i                 (us_timming_valid_i[i]     ),
                .us_timming_data_i                  (us_timming_data_i[i*128 +: 128]),
            
                .cache_wr_en_o                      (cache_wr_en_o[i]          ),
                .cache_wr_data_o                    (cache_wr_data_o[i]        ),
                .cache_prog_full_i                  (cache_prog_full_i[i]      ) 
            );
        end
    end
end
endgenerate


generate
    begin : us_timming
        genvar i,j;
        begin : wr
            for (i = 0; i<TOTAL_NUM; i=i+1) begin : cache

                for (j = 0; j<US_CHANNEL; j=j+1) begin

                    assign cache_wr_en_bus[i][j] = {
                        cache_wr_en_o[j][i]
                    };

                    assign cache_prog_full_i[j] = {
                        us_timming_prog_full_o
                    };

                end

                
                
                if(i >= 0 && i <= 24)begin
                    assign us_timming_wr_en_i[i] = cache_wr_en_bus[i][0];
                    assign us_timming_din_i[i] = cache_wr_data_o[0];
                end
                else if (i >= 25 && i <= 46) begin
                    assign us_timming_wr_en_i[i] = cache_wr_en_bus[i][1];
                    assign us_timming_din_i[i]  = cache_wr_data_o[1];
                end
                else if (i >= 47 && i <= 66) begin
                    assign us_timming_wr_en_i[i] = cache_wr_en_bus[i][2];
                    assign us_timming_din_i[i]  = cache_wr_data_o[2];
                end
                else if (i >= 67 && i <= 84) begin
                    assign us_timming_wr_en_i[i] = cache_wr_en_bus[i][3];
                    assign us_timming_din_i[i]  = cache_wr_data_o[3];
                end
                else if (i >= 85 && i <= 102) begin
                    assign us_timming_wr_en_i[i] = cache_wr_en_bus[i][4];
                    assign us_timming_din_i[i]  = cache_wr_data_o[4];
                end
                else if (i >= 103 && i <= 103) begin
                    assign us_timming_wr_en_i[i] = cache_wr_en_bus[i][5];
                    assign us_timming_din_i[i]  = cache_wr_data_o[5];
                end
                else begin
                    assign us_timming_wr_en_i[i] = "You make a big mistake !!!";
                    assign us_timming_din_i[i]  = "You make a big mistake once again !!!";
                end



                if((i >= 0 && i <= 24) || (i >= 31 && i <= 103))begin : fifo
                    us_timming_cache # (
                        .FIFO_DEEPTH                        (512                       ) 
                      )
                      us_timming_cache_inst (
                        .sys_clk_i                          (sys_clk_i                 ),
                        .rst_n_i                            (rst_n_i                   ),

                        .us_timming_wr_en_i                 (us_timming_wr_en_i[i]     ),
                        .us_timming_din_i                   (us_timming_din_i[i]       ),
                        .us_timming_prog_full_o             (us_timming_prog_full_o[i] ),

                        .us_timming_rd_en_i                 (us_timming_rd_en_i[i]     ),
                        .us_timming_dout_o                  (us_timming_dout_o[i*128 +: 128]),
                        .us_timming_empty_o                 (us_timming_empty_o[i]     ),
                        .us_timming_cache_count_o           (us_timming_cache_count_o[i*12 +: 12]) 
                      );
                end
                else begin : fifo
                    us_timming_cache # (
                        .FIFO_DEEPTH                        (2048                      ) 
                      )
                      us_timming_cache_inst (
                        .sys_clk_i                          (sys_clk_i                 ),
                        .rst_n_i                            (rst_n_i                   ),

                        .us_timming_wr_en_i                 (us_timming_wr_en_i[i]     ),
                        .us_timming_din_i                   (us_timming_din_i[i]       ),
                        .us_timming_prog_full_o             (us_timming_prog_full_o[i] ),

                        .us_timming_rd_en_i                 (us_timming_rd_en_i[i]     ),
                        .us_timming_dout_o                  (us_timming_dout_o[i*128 +: 128]),
                        .us_timming_empty_o                 (us_timming_empty_o[i]     ),
                        .us_timming_cache_count_o           (us_timming_cache_count_o[i*12 +: 12]) 
                      );
                end

            end
        end
    end
endgenerate

// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
ila_us_timming ila_us_timming_inst (
    .clk                                (sys_clk_i                 ),// input wire clk

    .probe0                             (us_timming_wr_en_i        ),// input wire [103:0]  probe0  
    .probe1                             (us_timming_prog_full_o    ) // input wire [103:0]  probe1
);

endmodule