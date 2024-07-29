`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             clk_sel
// Create Date:           2024/07/03 10:58:13
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\AI3\AI3_top_v1\AI3_top_v1.srcs\sources_1\imports\clk_rst_wrapper\clk_sel.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module clk_sel (
    input  wire                         clk_0_i                    ,
    input  wire                         clk_1_i                    ,

    input  wire                         arst_n_i                   ,
    input  wire                         sel_i                      ,// 1 choose clk1. 0 choose clk 0
    output wire                         clk_sel_o                   
);

    reg                                 sel_r1,sel_r2              ;

always@(posedge clk_0_i or negedge arst_n_i)begin
    if (!arst_n_i) begin
        sel_r1 <= 'd0;
        sel_r2 <= 'd0;
    end
    else begin
        sel_r1 <= sel_i;
        sel_r2 <= sel_r1;
    end
end

BUFGMUX #(
    .CLK_SEL_TYPE                       ("ASYNC"                   ) // ASYNC, SYNC
)
BUFGMUX_inst (
    .O                                  (clk_sel_o                 ),// 1-bit output: Clock output
    .I0                                 (clk_0_i                   ),// 1-bit input: Clock input (S=0)
    .I1                                 (clk_1_i                   ),// 1-bit input: Clock input (S=1)
    .S                                  (sel_r2                    ) // 1-bit input: Clock select
);

//     reg                                 select_1_r,select_1        ;
//     reg                                 select_0_r,select_0        ;

// always@(posedge clk_1_i or negedge arst_n_i)begin
//     if (!arst_n_i) begin
//         select_1_r <= 'd0;
//         select_1 <= 'd0;
//     end
//     else begin
//         select_1_r <= ~select_0 && sel_i;
//         select_1 <= select_1_r;
//     end
// end

// always@(posedge clk_0_i or negedge arst_n_i)begin
//     if (!arst_n_i) begin
//         select_0_r <= 'd0;
//         select_0 <= 'd0;
//     end
//     else begin
//         select_0_r <= ~select_1 && ~sel_i;
//         select_0 <= select_0_r;
//     end
// end

//     assign                              clk_sel_o                 = (select_1 & clk_1_i) | (select_0 & clk_0_i);

endmodule