`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             clk_rst_warpper
// Create Date:           2024/06/06 17:11:09
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\7z045\cfg_7z045_top\cfg_7z045_top.srcs\sources_1\imports\clk_rst_warpper\clk_rst_warpper.v
// Descriptions:          
// 
// ********************************************************************************** // 


module clk_rst_warpper (
    input  wire                         SYSCLK                     ,// 100mhz input

    output wire                         clk_100m                   ,
    output wire                         clk_50m                    ,

    output reg                          hw_arst_n                  ,
    output reg                          sw_arst_n                  ,
    output reg                          ad9516_1_rst_n             ,
    output reg                          ad9516_2_rst_n              
);
    wire                                locked                     ;
    wire                                vio_rst_n                  ;

    localparam                          time_250ms                = 12_500_000;
    localparam                          time_500ms                = 25_000_000;
    localparam                          time_1s                   = 50_000_000;
    localparam                          time_125ms                = 50_000_000 / 8;

    reg                [  31: 0]        hw_clk_cnt                 ;
    reg                [  31: 0]        sw_clk_cnt                 ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// clock ip core
//---------------------------------------------------------------------
sys_pll sys_pll_inst (
    // Clock out ports
    .clk_100m                           (clk_100m                  ),// output clk_100m
    .clk_50m                            (clk_50m                   ),// output clk_50m
    // Status and control signals
    .reset                              (1'd0                      ),// input reset
    .locked                             (locked                    ),// output locked
    // Clock in ports
    .clk_in1                            (SYSCLK                    ) // input clk_in1
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// reset
//---------------------------------------------------------------------
// wait 1s
always@(posedge clk_50m or negedge locked)begin
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
always@(posedge clk_50m or negedge hw_arst_n)begin
    if (!hw_arst_n) begin
        sw_arst_n <= 'd0;
        sw_clk_cnt <= 'd0;
    end
    else if (sw_clk_cnt >= time_1s - 1) begin
        sw_clk_cnt <= sw_clk_cnt;
        sw_arst_n <= vio_rst_n;
    end
    else begin
        sw_clk_cnt <= sw_clk_cnt + 'd1;
        sw_arst_n <= sw_arst_n;
    end
end
// ad9516 - 1
always@(posedge clk_50m or negedge hw_arst_n)begin
    if (!hw_arst_n) begin
        ad9516_1_rst_n <= 'd0;
    end
    else if (sw_clk_cnt >= time_250ms - 1) begin
        ad9516_1_rst_n <= 'd1;
    end
end
// ad9516 - 2
always@(posedge clk_50m or negedge hw_arst_n)begin
    if (!hw_arst_n) begin
        ad9516_2_rst_n <= 'd0;
    end
    else if (sw_clk_cnt >= time_500ms - 1) begin
        ad9516_2_rst_n <= 'd1;
    end
end


// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
vio_clk_rst vio_clk_rst_inst (
    .clk                                (clk_50m                   ),// input wire clk
    .probe_in0                          (ad9516_2_rst_n            ),// input wire [0 : 0] probe_in0
    .probe_out0                         (vio_rst_n                 ) // output wire [0 : 0] probe_out0
);

endmodule