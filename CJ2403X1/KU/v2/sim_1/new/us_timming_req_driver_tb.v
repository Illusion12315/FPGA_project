`timescale 1ns / 1ps
//****************************************VSCODE PLUG-IN**********************************//
//----------------------------------------------------------------------------------------
// IDE :                   VSCODE plug-in 
// VSCODE plug-in version: Verilog-Hdl-Format-2.3.20240512
// VSCODE plug-in author : Jiang Percy
//----------------------------------------------------------------------------------------
//****************************************Copyright (c)***********************************//
// Copyright(C)            Please Write Company name
// All rights reserved     
// File name:              us_timming_req_driver_tb.v
// Last modified Date:     2024/06/27 14:54:35
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Chen Xiong Zhi
// Created date:           2024/06/27 14:54:35
// Version:                V1.0
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module    us_timming_req_driver_tb();
    reg                                 sys_clk_i                  ;
    reg                                 rst_n_i                    ;
    reg                                 transmit_start_trigger_i   ;
    wire                                us_timming_rd_en_o         ;
    reg                [ 127: 0]        us_timming_dout_i          ;
    reg                                 us_timming_empty_i         ;
    reg                [  11: 0]        us_timming_cache_count_i   ;
    wire                                transmit_done_pluse_o      ;
    wire                                us_timming_flow_vld_o      ;
    wire               [ 127: 0]        us_timming_flow_o          ;



    initial
        begin
            #2
            us_timming_cache_count_i = 12;
            transmit_start_trigger_i = 0;
            us_timming_empty_i = 1;
            rst_n_i = 0   ;
            sys_clk_i = 0     ;
            #100
            rst_n_i = 1   ;
            #100
            us_timming_empty_i = 0;
            transmit_start_trigger_i = 1;
            #200
            transmit_start_trigger_i = 0;
            us_timming_cache_count_i = 0;
            #100
            transmit_start_trigger_i = 1;
            #200
            $stop;
        end
                                                           




    parameter                           CLK_FREQ                  = 100   ;//Mhz                       
    always # ( 1000/CLK_FREQ/2 ) sys_clk_i = ~sys_clk_i ;
                                                           
                                                           
us_timming_req_driver u_us_timming_req_driver(
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),

    .transmit_start_trigger_i           (transmit_start_trigger_i  ),
    .us_timming_rd_en_o                 (us_timming_rd_en_o        ),
    .us_timming_dout_i                  (us_timming_dout_i         ),
    .us_timming_empty_i                 (us_timming_empty_i        ),
    .us_timming_cache_count_i           (us_timming_cache_count_i  ),

    .transmit_done_pluse_o              (transmit_done_pluse_o     ),
    .us_timming_flow_vld_o              (us_timming_flow_vld_o     ),
    .us_timming_flow_o                  (us_timming_flow_o         ) 
);




endmodule