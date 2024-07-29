`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             msg_transmit_simulation
// Create Date:           2024/06/27 13:46:22
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\message_wrapper\msg_transmit_simulation.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module msg_transmit_simulation (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire                         msg_sim_en_i               ,
    output reg                          msg_done_pluse_o           ,
    
    input  wire        [  31: 0]        sim_frame_header           ,
    input  wire        [  15: 0]        sim_frame_len              ,
    input  wire        [   3: 0]        sim_frame_type             ,
    input  wire        [  15: 0]        sim_frame_cnt              ,
    input  wire        [   7: 0]        sim_src_id                 ,
    input  wire        [   7: 0]        sim_des_id                 ,
    input  wire        [   7: 0]        sim_data_type              ,
    input  wire        [   7: 0]        sim_data_channel           ,
    input  wire        [  15: 0]        sim_data_field_len         ,

    output reg                          msg_sim_vld_o              ,
    output reg         [ 127: 0]        msg_sim_data_o              
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                          S_IDLE                    = 0     ;
    localparam                          S_SIM                     = 1     ;

    integer                             i                          ;

    wire               [ 127: 0]        msg_header                 ;
    wire               [  18: 0]        exact_frame_len            ;

    reg                [   0: 0]        state                      ;

    reg                [   7: 0]        msg_send_cnt               ;
    reg                [   7: 0]        current_verify_num         ;
    reg                                 msg_state_done_pluse       ;

    wire               [ 127: 0]        increasing_num             ;
    reg                                 msg_sim_en_r1              ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// main code
//---------------------------------------------------------------------
    assign msg_header = {
        sim_frame_header,
        sim_frame_len,
        12'h0,
        sim_frame_type,
        sim_frame_cnt,
        sim_src_id,
        sim_des_id,
        sim_data_type,
        sim_data_channel,
        sim_data_field_len
    };

    assign                              exact_frame_len           = (sim_frame_len + 'd1) << 2;

    assign                              increasing_num            = 128'h0001_0203_0405_0607_0809_0a0b_0c0d_0e0f;

always@(posedge sys_clk_i)begin
    msg_sim_en_r1 <= msg_sim_en_i;
end

always@(posedge sys_clk_i)begin
    case (state)
        S_SIM:
            if(msg_state_done_pluse)
                current_verify_num <= current_verify_num;
            else case (msg_send_cnt)
                0: begin
                    current_verify_num <= msg_header[8*0 +: 8] + msg_header[8*1 +: 8]
                                        + msg_header[8*2 +: 8] + msg_header[8*3 +: 8]
                                        + msg_header[8*4 +: 8] + msg_header[8*5 +: 8]
                                        + msg_header[8*6 +: 8] + msg_header[8*7 +: 8]
                                        + msg_header[8*8 +: 8] + msg_header[8*9 +: 8]
                                        + msg_header[8*10 +: 8] + msg_header[8*11 +: 8]
                                        + msg_header[8*12 +: 8] + msg_header[8*13 +: 8]
                                        + msg_header[8*14 +: 8] + msg_header[8*15 +: 8]
                                        + current_verify_num;
                end
                1: begin
                    current_verify_num <= increasing_num[8*0 +: 8]  + increasing_num[8*1 +: 8]
                                        + increasing_num[8*2 +: 8]  + increasing_num[8*3 +: 8]
                                        + increasing_num[8*4 +: 8]  + increasing_num[8*5 +: 8]
                                        + increasing_num[8*6 +: 8]  + increasing_num[8*7 +: 8]
                                        + increasing_num[8*8 +: 8]  + increasing_num[8*9 +: 8]
                                        + increasing_num[8*10 +: 8] + increasing_num[8*11 +: 8]
                                        + increasing_num[8*12 +: 8] + increasing_num[8*13 +: 8]
                                        + increasing_num[8*14 +: 8] + increasing_num[8*15 +: 8]
                                        + current_verify_num;
                end
                default: current_verify_num <= current_verify_num;
            endcase
        default: current_verify_num <= 'd0;
    endcase
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if (!rst_n_i)
        state <= S_IDLE;
    else case (state)
        S_IDLE:
            if(msg_sim_en_i && ~msg_sim_en_r1)
                state <= S_SIM;
        S_SIM:
            if(msg_state_done_pluse)
                state <= S_IDLE;
        default: state <= state;
    endcase
end

always@(posedge sys_clk_i)begin
    case (state)
        S_SIM: msg_send_cnt <= msg_send_cnt + 'd1;
        default: msg_send_cnt <= 'd0;
    endcase
end

always@(posedge sys_clk_i)begin
    case (state)
        S_SIM:
            if(msg_send_cnt == exact_frame_len - 'd2)
                msg_state_done_pluse <= 'd1;
            else
                msg_state_done_pluse <= 'd0;
        default: msg_state_done_pluse <= 'd0;
    endcase
end

always@(posedge sys_clk_i)begin
    msg_done_pluse_o <= msg_state_done_pluse;
end

always@(posedge sys_clk_i)begin
    case (state)
        S_SIM: msg_sim_vld_o <= 'd1;
        default: msg_sim_vld_o <= 'd0;
    endcase
end
// really important

always@(posedge sys_clk_i)begin
    case (state)
        S_SIM:
            if(msg_state_done_pluse)
                msg_sim_data_o <= {120'd0,current_verify_num};
            else case (msg_send_cnt)
                0: msg_sim_data_o <= msg_header;
                1: msg_sim_data_o <= increasing_num;
            default: msg_sim_data_o <= 'd0;
            endcase
        default: msg_sim_data_o <= 'd0;
    endcase
end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------



endmodule