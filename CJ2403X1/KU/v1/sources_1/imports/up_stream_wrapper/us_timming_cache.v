`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             us_timming_cache
// Create Date:           2024/06/25 19:25:42
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\up_stream_wrapper\us_timming_cache.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module us_timming_cache #(
    parameter                           FIFO_DEEPTH               = 128   
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire                         us_timming_wr_en_i         ,
    input  wire        [ 127: 0]        us_timming_din_i           ,
    output wire                         us_timming_prog_full_o     ,

    input  wire                         us_timming_rd_en_i         ,
    output wire        [ 127: 0]        us_timming_dout_o          ,
    output wire                         us_timming_empty_o         ,
    output wire        [  11: 0]        us_timming_cache_count_o    
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    wire                                us_timming_rd_en           ;
    wire               [ 127: 0]        us_timming_dout            ;
    wire                                us_timming_empty           ;
    wire               [  11: 0]        us_timming_cache_count     ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// main code
//---------------------------------------------------------------------
    assign                              us_timming_rd_en          = us_timming_rd_en_i;

    assign                              us_timming_dout_o         = us_timming_dout;

    assign                              us_timming_empty_o        = us_timming_empty;

    assign                              us_timming_cache_count_o  = us_timming_cache_count;

generate
    begin : fifo
//        if(FIFO_DEEPTH == 128) begin : deepth128

//            fifo_128x128b fifo_128x128b_inst (
//                .clk                                (sys_clk_i                 ),// input wire clk
//                .srst                               (~rst_n_i                  ),// input wire srst

//                .wr_en                              (us_timming_wr_en_i        ),// input wire wr_en
//                .din                                (us_timming_din_i          ),// input wire [127 : 0] din
//                .full                               (                          ),// output wire full
//                .prog_full                          (us_timming_prog_full_o    ),// output wire prog_full

//                .rd_en                              (us_timming_rd_en          ),// input wire rd_en
//                .dout                               (us_timming_dout           ),// output wire [127 : 0] dout
//                .empty                              (us_timming_empty          ),// output wire empty
//                .data_count                         (us_timming_cache_count[7:0]) // output wire [7 : 0] data_count
//            );
//                assign                              us_timming_cache_count[11:8]= 'd0;

//        end
//        else 
        if(FIFO_DEEPTH == 2048) begin : deepth2048

            fifo_2048x128b fifo_2048x128b_inst (
                .clk                                (sys_clk_i                 ),// input wire clk
                .srst                               (~rst_n_i                  ),// input wire srst

                .wr_en                              (us_timming_wr_en_i        ),// input wire wr_en
                .din                                (us_timming_din_i          ),// input wire [127 : 0] din
                .full                               (                          ),// output wire full
                .prog_full                          (us_timming_prog_full_o    ),// output wire prog_full

                .rd_en                              (us_timming_rd_en          ),// input wire rd_en
                .dout                               (us_timming_dout           ),// output wire [127 : 0] dout
                .empty                              (us_timming_empty          ),// output wire empty
                .data_count                         (us_timming_cache_count    ) // output wire [11 : 0] data_count
            );
        end
        else begin : deepth512

            fifo_512x128b fifo_512x128b_inst (
                .clk                                (sys_clk_i                 ),// input wire clk
                .srst                               (~rst_n_i                  ),// input wire srst

                .wr_en                              (us_timming_wr_en_i        ),// input wire wr_en
                .din                                (us_timming_din_i          ),// input wire [127 : 0] din
                .full                               (                          ),// output wire full
                .prog_full                          (us_timming_prog_full_o    ),// output wire prog_full

                .rd_en                              (us_timming_rd_en          ),// input wire rd_en
                .dout                               (us_timming_dout           ),// output wire [127 : 0] dout
                .empty                              (us_timming_empty          ),// output wire empty
                .data_count                         (us_timming_cache_count[9:0]),// output wire [9 : 0] data_count
                .wr_rst_busy                        (                          ),// output wire wr_rst_busy
                .rd_rst_busy                        (                          ) // output wire rd_rst_busy
            );
                assign                              us_timming_cache_count[11:10]= 'd0;

        end
end
endgenerate

endmodule