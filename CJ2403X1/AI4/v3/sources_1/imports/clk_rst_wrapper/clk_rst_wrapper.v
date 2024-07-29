`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             clk_rst_wrapper
// Create Date:           2024/06/28 14:11:42
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\AI2\AI2_top_v1\AI2_top_v1.srcs\sources_1\imports\clk_rst_wrapper\clk_rst_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none



module clk_rst_wrapper (
    input  wire                         SYSCLK                     ,// from ctystal oscillator . Unpaster . 100m

    input  wire                         SYSCLK_P                   ,// from lvds ctystal oscillator 100m
    input  wire                         SYSCLK_N                   ,

    input  wire                         K7_REFCLK_P                ,// from vpx . 100m .
    input  wire                         K7_REFCLK_N                ,
    output wire                         vpx_clk_100m               ,
    output wire                         vpx_clk_100m_locked        ,
     
    output wire                         clk_50m                    ,
    output wire                         clk_100m                   ,
    output reg                          sw_arst_n                  ,// clk 100 m
    output reg                          hw_arst_n                   // clk 100 m
    );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                          time_1s                   = 100_000_000;
    wire                                locked                     ;
    wire                                vio_rst_n                  ;

    reg                [  31: 0]        hw_clk_cnt                 ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// assigns
//---------------------------------------------------------------------

// ********************************************************************************** // 
//---------------------------------------------------------------------
// instance
//---------------------------------------------------------------------
// IBUFDS #(
//     .DIFF_TERM                          ("FALSE"                   ),// Differential Termination
//     .IBUF_LOW_PWR                       ("TRUE"                    ),// Low power="TRUE", Highest performance="FALSE" 
//     .IOSTANDARD                         ("DEFAULT"                 ) // Specify the input I/O standard
// ) IBUFDS_inst_K7_REFCLK (
//     .O                                  (K7_REFCLK                 ),// Buffer output
//     .I                                  (K7_REFCLK_P               ),// Diff_p buffer input (connect directly to top-level port)
//     .IB                                 (K7_REFCLK_N               ) // Diff_n buffer input (connect directly to top-level port)
// );

// BUFG BUFG_inst (
//     .O                                  (vpx_clk_100m              ),// 1-bit output: Clock output
//     .I                                  (K7_REFCLK                 ) // 1-bit input: Clock input
//  );

clk_wiz_1 clk_wiz_1_inst(
    // Clock out ports
    .clk_out1                           (vpx_clk_100m              ),// output clk_out1
    // Status and control signals
    .reset                              ('d0                       ),// input reset
    .locked                             (vpx_clk_100m_locked       ),// output locked
    // Clock in ports
    .clk_in1_p                          (K7_REFCLK_P               ),// input clk_in1_p
    .clk_in1_n                          (K7_REFCLK_N               ) // input clk_in1_n
);

clk_wiz_0 clk_wiz_0_inst
(
    // Clock out ports
    .clk_out1                           (clk_50m                   ),// output clk_out1
    .clk_out2                           (clk_100m                  ),// output clk_out2
    // Status and control signals
    .reset                              ('d0                       ),// input reset
    .locked                             (locked                    ),// output locked
    // Clock in ports
    .clk_in1_p                          (SYSCLK_P                  ),// input clk_in1_p
    .clk_in1_n                          (SYSCLK_N                  ) // input clk_in1_n
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// reset
//---------------------------------------------------------------------
// wait 1s ,then start hardware reset
always@(posedge clk_100m or negedge locked)begin
    if (!locked) begin
        hw_clk_cnt <= 'd0;
        hw_arst_n <= 'd0;
    end
    else if (hw_clk_cnt >= time_1s - 1) begin
        hw_clk_cnt <= hw_clk_cnt;
        hw_arst_n <= 'd1;
    end
    else begin
        hw_clk_cnt <= hw_clk_cnt + 'd1;
        hw_arst_n <= hw_arst_n;
    end
end
// software reset
always@(posedge clk_100m or negedge hw_arst_n)begin
    if (!hw_arst_n) begin
        sw_arst_n <= 'd0;
    end
    else
        sw_arst_n <= vio_rst_n;
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
vio_clk_rst vio_clk_rst_inst (
    .clk                                (clk_100m                  ),// input wire clk
    .probe_out0                         (vio_rst_n                 ) // output wire [0 : 0] probe_out0
);
endmodule