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
// File name:              msg_transmit_driver_tb.v
// Last modified Date:     2024/06/29 12:57:30
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Chen Xiong Zhi
// Created date:           2024/06/29 12:57:30
// Version:                V1.0
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module    msg_transmit_driver_tb();
    reg                                 sys_clk_i                  ;
    reg                                 rst_n_i                    ;
    reg                                 transmit_start_pluse_i     ;
    reg                [  31: 0]        transmit_header            ;
    reg                [  15: 0]        transmit_frame_len         ;
    reg                [   3: 0]        transmit_frame_type        ;
    reg                [  15: 0]        transmit_frame_cnt         ;
    reg                [   7: 0]        transmit_src_id            ;
    reg                [   7: 0]        transmit_des_id            ;
    reg                [   7: 0]        transmit_data_type         ;
    reg                [   7: 0]        transmit_data_channel      ;
    wire                                rd_clk_o                   ;
    wire                                rd_en_o                    ;
    reg                [   7: 0]        din_i                      ;
    reg                [  15: 0]        data_count_i               ;
    reg                                 empty_i                    ;
    wire                                flow_valid_o               ;
    wire               [ 127: 0]        flow_data_o                ;

    initial begin
        transmit_header       = 32'hfdf7eb90;
        transmit_frame_type   = 4'h1;
        transmit_frame_cnt    = 16'h0;
        transmit_src_id       = 8'h11;
        transmit_des_id       = 8'h22;
        transmit_data_type    = 8'h33;
        transmit_data_channel = 8'h44;
    end

    initial
        begin
            rst_n_i = 0   ;
            sys_clk_i = 0     ;
            transmit_start_pluse_i = 0;
            empty_i = 0;
            data_count_i = 99;
            din_i = 0;
            #10
            rst_n_i = 1   ;
            // #50
            // @(posedge sys_clk_i)
            //     transmit_start_pluse_i = 1;
            // @(posedge sys_clk_i)
            //     transmit_start_pluse_i = 0;
            #1000
                transmit_header       = 32'hfdf7eb90;
                transmit_frame_type   = 4'h4;
                transmit_frame_cnt    = 16'h0;
                transmit_src_id       = 8'haa;
                transmit_des_id       = 8'h55;
                transmit_data_type    = 8'haa;
                transmit_data_channel = 8'h55;
                data_count_i = 0;
                empty_i = 1;
            #50
            @(posedge sys_clk_i)
                transmit_start_pluse_i = 1;
            @(posedge sys_clk_i)
                transmit_start_pluse_i = 0;
            
            // #1000
            //     transmit_header       = 32'hfdf7eb90;
            //     transmit_frame_type   = 4'h4;
            //     transmit_frame_cnt    = 16'h0;
            //     transmit_src_id       = 8'haa;
            //     transmit_des_id       = 8'h55;
            //     transmit_data_type    = 8'haa;
            //     transmit_data_channel = 8'h55;
            //     data_count_i = 1234;
            // #50
            // @(posedge sys_clk_i)
            //     transmit_start_pluse_i = 1;
            // @(posedge sys_clk_i)
            //     transmit_start_pluse_i = 0;

                
        end
                                                           
    parameter                           CLK_FREQ                  = 100   ;//Mhz                       
    always # ( 1000/CLK_FREQ/2 ) sys_clk_i = ~sys_clk_i ;
          
    
always@(posedge sys_clk_i)begin
    if(rd_en_o)
        din_i <= din_i + 1;
end    
                                                           
msg_transmit_driver u_msg_transmit_driver(
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),
    .transmit_start_pluse_i             (transmit_start_pluse_i    ),
    .transmit_header                    (transmit_header           ),
    // .transmit_frame_len                 (transmit_frame_len        ),
    .transmit_frame_type                (transmit_frame_type       ),
    .transmit_frame_cnt                 (transmit_frame_cnt        ),
    .transmit_src_id                    (transmit_src_id           ),
    .transmit_des_id                    (transmit_des_id           ),
    .transmit_data_type                 (transmit_data_type        ),
    .transmit_data_channel              (transmit_data_channel     ),
    .rd_clk_o                           (rd_clk_o                  ),
    .rd_en_o                            (rd_en_o                   ),
    .din_i                              (din_i                     ),
    .data_count_i                       (data_count_i              ),
    .empty_i                            (empty_i                   ),
    .flow_valid_o                       (flow_valid_o              ),
    .flow_data_o                        (flow_data_o               ) 
);




endmodule