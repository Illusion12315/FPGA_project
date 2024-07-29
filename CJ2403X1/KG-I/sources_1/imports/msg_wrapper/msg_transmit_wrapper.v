`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             msg_transmit_wrapper
// Create Date:           2024/06/30 14:16:25
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\AI2\AI2_top_v1\AI2_top_v1.srcs\sources_1\imports\msg_wrapper\msg_transmit_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module msg_transmit_wrapper #(
    parameter                           SENSOR_CHANNEL            = 20    
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire                         timming_start_pluse_i      ,

    input  wire        [   7: 0]        MSG_ID                     ,
    output wire        [SENSOR_CHANNEL-1: 0]rd_clk_o               ,
    output wire        [SENSOR_CHANNEL-1: 0]rd_en_o                ,
    input  wire        [SENSOR_CHANNEL*8-1: 0]din_i                ,
    input  wire        [SENSOR_CHANNEL*16-1: 0]data_count_i        ,
    input  wire        [SENSOR_CHANNEL-1: 0]empty_i                ,

    output wire                         us_wr_clk_o                ,
    output reg                          us_wr_en_o                 ,
    output reg         [ 127: 0]        us_wr_dout_o               ,
    input  wire                         us_prog_full_i              
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                          S_IDLE                    = 0     ;
    localparam                          S_READ_DATA               = 1     ;
    integer                             i                          ;
    
    wire               [SENSOR_CHANNEL-1: 0]send_done              ;
    reg                [   1: 0]        state                      ;
    reg                [   7: 0]        transmit_cnt               ;
    reg                [   7: 0]        transmit_cnt_r1            ;
    reg                [SENSOR_CHANNEL-1: 0]transmit_start_pluse   ;

    wire               [SENSOR_CHANNEL-1: 0]flow_valid             ;
    wire               [ 127: 0]        flow_data     [0:SENSOR_CHANNEL-1]  ;
    
    reg                [  31: 0]        transmit_header            ;
    reg                [   3: 0]        transmit_frame_type        ;
    reg                [  15: 0]        transmit_frame_cnt         ;

    wire               [   7: 0]        transmit_src_id[0:SENSOR_CHANNEL-1]  ;
    wire               [   7: 0]        transmit_des_id[0:SENSOR_CHANNEL-1]  ;
    wire               [   7: 0]        transmit_data_type[0:SENSOR_CHANNEL-1]  ;
    wire               [   7: 0]        transmit_data_channel[0:SENSOR_CHANNEL-1]  ;

    reg                [  31: 0]        sensor_id     [0:SENSOR_CHANNEL-1]  ;
    reg                [SENSOR_CHANNEL*16-1: 0]data_count_r1       ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// main code
//---------------------------------------------------------------------
initial begin
    `include "sensor_id.vh"

    transmit_header = 32'hFDF7_EB90;
    transmit_frame_type = 4'h1;
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i)
        state <= S_IDLE;
    else case (state)
        S_IDLE:
            if(timming_start_pluse_i)
                state <= S_READ_DATA;
            else
                state <= state;
        S_READ_DATA:
            if(send_done[SENSOR_CHANNEL-1])
                state <= S_IDLE;
            else
                state <= state;
        default: state <= state;
    endcase
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        transmit_cnt <= 'd0;
    end
    else case (state)
        S_READ_DATA:
            if(send_done[SENSOR_CHANNEL-1])
                transmit_cnt <= 'd0;
            else if(|send_done)
                transmit_cnt <= transmit_cnt + 'd1;
            else
                transmit_cnt <= transmit_cnt;
        default: transmit_cnt <= 'd0;
    endcase
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        transmit_start_pluse <= 'd0;
    end
    else case (state)
        S_READ_DATA:
            if (send_done[transmit_cnt])
                transmit_start_pluse[transmit_cnt] <= 'd0;
            else
                transmit_start_pluse[transmit_cnt] <= 'd1;
        
        default: transmit_start_pluse <= 'd0;
    endcase
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        transmit_cnt_r1 <= 'd0;
    end
    else
        transmit_cnt_r1 <= transmit_cnt;
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        us_wr_en_o <= 'd0;
        us_wr_dout_o <= 'd0;
    end
    else begin
        us_wr_en_o <= flow_valid[transmit_cnt_r1];
        us_wr_dout_o <= flow_data[transmit_cnt_r1];
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        transmit_frame_cnt <= 'd0;
    end
    else if (send_done[SENSOR_CHANNEL-1]) begin
        transmit_frame_cnt <= transmit_frame_cnt + 'd1;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        data_count_r1 <= 'd0;
    end
    else if (timming_start_pluse_i) begin
        data_count_r1 <= data_count_i;
    end
end

generate
    begin : transmit
        genvar i;
        for (i = 0; i<SENSOR_CHANNEL; i=i+1) begin : channel
            assign                              transmit_src_id[i]        = MSG_ID;
            assign                              transmit_des_id[i]        = sensor_id[i][23:16];
            assign                              transmit_data_type[i]     = sensor_id[i][15:8];
            assign                              transmit_data_channel[i]  = sensor_id[i][7:0];

            msg_transmit_driver #(
                .ILA_CH                             (i                         )
            ) u_msg_transmit_driver(
                .sys_clk_i                          (sys_clk_i                 ),
                .rst_n_i                            (rst_n_i                   ),
                    
                .transmit_start_pluse_i             (transmit_start_pluse[i]   ),
                .send_done_o                        (send_done[i]              ),
                    
                .transmit_header                    (transmit_header           ),
                .transmit_frame_type                (transmit_frame_type       ),
                .transmit_frame_cnt                 (transmit_frame_cnt        ),
                .transmit_src_id                    (transmit_src_id[i]        ),
                .transmit_des_id                    (transmit_des_id[i]        ),
                .transmit_data_type                 (transmit_data_type[i]     ),
                .transmit_data_channel              (transmit_data_channel[i]  ),
                    
                .rd_clk_o                           (rd_clk_o[i]               ),
                .rd_en_o                            (rd_en_o[i]                ),
                .din_i                              (din_i[i*8 +: 8]           ),
                .data_count_i                       (data_count_r1[i*16 +: 16] ),
                .empty_i                            (empty_i[i]                ),
                    
                .flow_valid_o                       (flow_valid[i]             ),
                .flow_data_o                        (flow_data[i]              ) 
            );
        end
    end
endgenerate

// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
ila_msg_trans ila_msg_trans_inst (
    .clk                                (sys_clk_i                 ),// input wire clk

    .probe0                             (state                     ),// input wire [1:0]  probe0  
    .probe1                             (transmit_cnt              ),// input wire [7:0]  probe1 
    .probe2                             (us_wr_en_o                ),// input wire [0:0]  probe2 
    .probe3                             (us_wr_dout_o              ),// input wire [127:0]  probe3 
    .probe4                             (us_prog_full_i            ),// input wire [0:0]  probe4 
    .probe5                             (transmit_start_pluse      ),// input wire [19:0]  probe5 
    .probe6                             (send_done                 ) // input wire [19:0]  probe6
);


endmodule