`timescale 1ns / 1ps
//****************************************VSCODE PLUG-IN**********************************//
//----------------------------------------------------------------------------------------
// IDE :                   VSCODE plug-in 
// VSCODE plug-in version: Verilog-Hdl-Format-2.7.20240716
// VSCODE plug-in author : Jiang Percy
//----------------------------------------------------------------------------------------
//****************************************Copyright (c)***********************************//
// Copyright(C)            Xiaoxin2ciyuan
// All rights reserved     
// File name:              ad9833_engine_tb.v
// Last modified Date:     2024/07/20 17:37:47
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Chen Xiong Zhi
// Created date:           2024/07/20 17:37:47
// Version:                V1.0
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module    ad9833_engine_tb();
    reg                                 sys_clk_i                  ;
    reg                                 rst_n_i                    ;
    wire                                SCLK                       ;
    wire                                FSYNC                      ;
    wire                                SDATA                      ;
    reg                                 start_cfg_pluse_i          ;
    wire                                start_pluse_o              ;
    wire               [  15: 0]        ad9833_cfg_data_o          ;
    wire                                ad9833_bus_busy_o          ;



    initial
        begin
            #2
            rst_n_i = 0   ;
            sys_clk_i = 0     ;
            start_cfg_pluse_i = 0;
            #10
            rst_n_i = 1   ;
            #50
            start_cfg_pluse_i = 1;
            #20
            start_cfg_pluse_i = 0;
            #100000
            start_cfg_pluse_i = 1;
            #20
            start_cfg_pluse_i = 0;
        end
                                                           
    parameter                           CLK_FREQ                  = 100   ;//Mhz                       
    always # ( 1000/CLK_FREQ/2 ) sys_clk_i = ~sys_clk_i ;
                                                           
                                                           
ad9833_engine u_ad9833_engine(
    .sys_clk_i                          (sys_clk_i                 ),// clk100m
    .rst_n_i                            (rst_n_i                   ),
    .start_pluse_i                      (start_pluse_o             ),
    .ad9833_cfg_data_i                  (ad9833_cfg_data_o         ),// 3k hz . sin(x)
    .SCLK                               (SCLK                      ),// max clk40m
    .FSYNC                              (FSYNC                     ),
    .SDATA                              (SDATA                     ),
    .ad9833_bus_busy_o                  (ad9833_bus_busy_o         ) 
);

ad9833_ctrl u_ad9833_ctrl(
    .sys_clk_i                          (sys_clk_i                 ),// clk100m
    .rst_n_i                            (rst_n_i                   ),
    .start_cfg_pluse_i                  (start_cfg_pluse_i         ),
    .start_pluse_o                      (start_pluse_o             ),
    .ad9833_cfg_data_o                  (ad9833_cfg_data_o         ),// 3k hz . sin(x)
    .ad9833_bus_busy_i                  (ad9833_bus_busy_o         ) 
);

ad9833_wrapper#(
    .AD9833_NUM                         (6                         ) 
)
u_ad9833_wrapper(
    .sys_clk_i                          (sys_clk_i                 ),// clk100m
    .rst_n_i                            (rst_n_i                   ),
    .start_cfg_pluse_i                  (start_cfg_pluse_i         ),
    .AD9833_SCLK                        (                          ),// max clk40m
    .AD9833_FSYNC                       (                          ),
    .AD9833_SDATA                       (                          ) 
);



endmodule