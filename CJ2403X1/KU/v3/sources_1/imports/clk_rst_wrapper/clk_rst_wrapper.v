`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             clk_rst_wrapper
// Create Date:           2024/06/18 17:26:49
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\clk_rst_wrapper\clk_rst_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module clk_rst_wrapper (
//---------------------------------SLR 0--------------------------------//
    input  wire                         SYSCLK1_SLR0_P             ,// from ad9516
    input  wire                         SYSCLK1_SLR0_N             ,// from ad9516
    input  wire                         SYSCLK_SLR0                ,
    // output wire                         clk50m_slr0                ,
    // output wire                         clk100m_slr0               ,
(*MAX_FANOUT = 1000*)
    output reg                          hw_arst_n_slr0             ,// clk50m_slr0
    output reg                          sw_arst_n_slr0             ,// clk50m_slr0
//---------------------------------SLR 1--------------------------------//
    input  wire                         SYSCLK1_SLR1_P             ,// from ad9516
    input  wire                         SYSCLK1_SLR1_N             ,// from ad9516
    input  wire                         SYSCLK_SLR1                ,
    // output wire                         clk50m_slr1                ,
    // output wire                         clk100m_slr1               ,
(*MAX_FANOUT = 1000*)
    output reg                          hw_arst_n_slr1             ,// clk50m_slr1
    output reg                          sw_arst_n_slr1             ,// clk50m_slr1
//-----------------------------global--------------------------------//
    output wire                         global_clk100m             ,
    output wire                         global_clk50m               
    );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                          time_1s                   = 100_000_000;
    wire                                SYSCLK1_SLR0               ;
    wire                                SYSCLK1_SLR1               ;
    wire                                locked_slr0                ;
    wire                                vio_rst_n                  ;
    reg                [  31: 0]        hw_clk_cnt                 ;
    reg                                 sw_arst_n_slr0_r1='d0,sw_arst_n_slr0_r2='d0,sw_arst_n_slr0_r3='d0  ;
    reg                                 hw_arst_n_slr0_r1='d0,hw_arst_n_slr0_r2='d0,hw_arst_n_slr0_r3='d0  ;
    
    wire                                clk50m_slr0                ;
    wire                                clk100m_slr0               ;
    wire                                clk50m_slr1                ;
    wire                                clk100m_slr1               ;
    wire                                SYSCLK1_SLR1_clk100m       ;
    wire                                SYSCLK1_SLR1_clk50m        ;
    wire                                SYSCLK1_SLR1_locked        ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// assigns
//---------------------------------------------------------------------
// 时钟信号跨slr不需要处理
    assign                              clk50m_slr1               = clk50m_slr0;
    assign                              clk100m_slr1              = clk100m_slr0;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// instance
//---------------------------------------------------------------------

clk_diff_slr0 clk_diff_slr1_inst
(
    // Clock out ports
    .clk_out1                           (SYSCLK1_SLR1_clk100m      ),// output clk_out1
    .clk_out2                           (SYSCLK1_SLR1_clk50m       ),// output clk_out2
    // Status and control signals
    .reset                              (1'd0                      ),// input reset
    .locked                             (SYSCLK1_SLR1_locked       ),// output locked
    // Clock in ports
    .clk_in1_p                          (SYSCLK1_SLR1_P            ),// input clk_in1_p
    .clk_in1_n                          (SYSCLK1_SLR1_N            ) // input clk_in1_n
);

IBUFDS #(
    .DIFF_TERM                          ("FALSE"                   ),// Differential Termination
    .IBUF_LOW_PWR                       ("TRUE"                    ),// Low power="TRUE", Highest performance="FALSE" 
    .IOSTANDARD                         ("DEFAULT"                 ) // Specify the input I/O standard
) IBUFDS_inst0 (
    .O                                  (SYSCLK1_SLR0              ),// Buffer output
    .I                                  (SYSCLK1_SLR0_P            ),// Diff_p buffer input (connect directly to top-level port)
    .IB                                 (SYSCLK1_SLR0_N            ) // Diff_n buffer input (connect directly to top-level port)
);

clk_slr0 clk_slr0_inst (
    // Clock out ports
    .clk_out1                           (clk50m_slr0               ),// output clk_out1
    .clk_out2                           (clk100m_slr0              ),// output clk_out2
    // Status and control signals
    .reset                              (1'd0                      ),// input reset
    .locked                             (locked_slr0               ),// output locked
    // Clock in ports
    .clk_in1                            (SYSCLK_SLR0               ) // input clk_in1
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// reset
//---------------------------------------------------------------------
// wait 1s ,then start hardware reset
always@(posedge clk100m_slr0 or negedge locked_slr0)begin
    if (!locked_slr0) begin
        hw_clk_cnt <= 'd0;
        hw_arst_n_slr0 <= 'd0;
    end
    else if (hw_clk_cnt >= time_1s - 1) begin
        hw_clk_cnt <= hw_clk_cnt;
        hw_arst_n_slr0 <= 'd1;
    end
    else begin
        hw_clk_cnt <= hw_clk_cnt + 'd1;
        hw_arst_n_slr0 <= hw_arst_n_slr0;
    end
end
// software reset
always@(posedge clk100m_slr0 or negedge hw_arst_n_slr0)begin
    if (!hw_arst_n_slr0) begin
        sw_arst_n_slr0 <= 'd0;
    end
    else
        sw_arst_n_slr0 <= vio_rst_n;
end
// beat it twice
always@(posedge clk100m_slr1)begin
    sw_arst_n_slr0_r1 <= sw_arst_n_slr0;
    sw_arst_n_slr0_r2 <= sw_arst_n_slr0_r1;

    hw_arst_n_slr0_r1 <= hw_arst_n_slr0;
    hw_arst_n_slr0_r2 <= hw_arst_n_slr0_r1;
end


// sw reset sync to slr1
always@(posedge clk100m_slr1 or negedge sw_arst_n_slr0_r2)begin
    if (!sw_arst_n_slr0_r2) begin
        sw_arst_n_slr0_r3 <= 'd0;
        sw_arst_n_slr1 <= 'd0;
    end
    else begin
        sw_arst_n_slr0_r3 <= sw_arst_n_slr0_r2;
        sw_arst_n_slr1 <= sw_arst_n_slr0_r3;
    end
end
// hw reset sync to slr1
always@(posedge clk100m_slr1 or negedge hw_arst_n_slr0_r2)begin
    if (!hw_arst_n_slr0_r2) begin
        hw_arst_n_slr0_r3 <= 'd0;
        hw_arst_n_slr1 <= 'd0;
    end
    else begin
        hw_arst_n_slr0_r3 <= hw_arst_n_slr0_r2;
        hw_arst_n_slr1 <= hw_arst_n_slr0_r3;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// clk sel
//---------------------------------------------------------------------
clk_sel clk_sel100m_inst(
    .clk_0_i                            (clk100m_slr0              ),
    .clk_1_i                            (SYSCLK1_SLR1_clk100m      ),

    .arst_n_i                           (hw_arst_n_slr0            ),

    .sel_i                              (SYSCLK1_SLR1_locked       ),
    .clk_sel_o                          (global_clk100m            ) 
);

clk_sel clk_sel50m_inst(
    .clk_0_i                            (clk50m_slr0               ),
    .clk_1_i                            (SYSCLK1_SLR1_clk50m       ),

    .arst_n_i                           (hw_arst_n_slr0            ),

    .sel_i                              (SYSCLK1_SLR1_locked       ),
    .clk_sel_o                          (global_clk50m             ) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
vio_clk_rst vio_clk_rst_inst (
    .clk                                (clk100m_slr0              ),// input wire clk
    .probe_out0                         (vio_rst_n                 ) // output wire [0 : 0] probe_out0
);
endmodule