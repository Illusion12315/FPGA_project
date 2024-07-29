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
// File name:              turbine_wrapper_tb.v
// Last modified Date:     2024/07/22 11:27:25
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Chen Xiong Zhi
// Created date:           2024/07/22 11:27:25
// Version:                V1.0
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module    turbine_wrapper_tb();
    parameter                           TURBINE_NUM               = 10    ;
    reg                                 sys_clk_i                  ;
    reg                                 rst_n_i                    ;
    reg                                 turbine_acq_start_pluse_i  ;
    reg                [TURBINE_NUM-1: 0]TURBINE_START             ;
    wire               [TURBINE_NUM-1: 0]wr_en_o                   ;
    wire               [TURBINE_NUM*16-1: 0]wr_din_o               ;



    initial
        begin
            #2
            rst_n_i = 0   ;
            sys_clk_i = 0     ;
            turbine_acq_start_pluse_i = 0;
            TURBINE_START = 0;
            #10
            rst_n_i = 1   ;
            #100
            turbine_acq_start_pluse_i = 1;
            #10
            turbine_acq_start_pluse_i = 0;
            #50
            TURBINE_START = -1;
            #200
            TURBINE_START = 0;
            #50
            TURBINE_START = -1;
            #200
            TURBINE_START = 0;
            #100
            turbine_acq_start_pluse_i = 1;
            #10
            turbine_acq_start_pluse_i = 0;
        end
                                                           
    parameter                           CLK_FREQ                  = 100   ;//Mhz                       
    always # ( 1000/CLK_FREQ/2 ) sys_clk_i = ~sys_clk_i ;
                                                           
                                                           
turbine_wrapper#(
    .TURBINE_NUM                        (TURBINE_NUM               ) 
)
 u_turbine_wrapper(
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),
    .turbine_acq_start_pluse_i          (turbine_acq_start_pluse_i ),
    .TURBINE_START                      (TURBINE_START             ),
    .wr_en_o                            (wr_en_o                   ),
    .wr_din_o                           (wr_din_o                  ) 
);




endmodule