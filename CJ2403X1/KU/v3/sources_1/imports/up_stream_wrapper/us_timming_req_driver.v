`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             us_timming_req_driver
// Create Date:           2024/06/27 14:30:38
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\up_stream_wrapper\us_timming_req_driver.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module us_timming_req_driver #(
    parameter                           TOTAL_NUM                 = 104   
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire                         transmit_start_trigger_i   ,
    input  wire        [   7: 0]        cache_num_i                ,
    input  wire        [  15: 0]        frame_cnt_i                ,

    output reg                          us_timming_rd_en_o         ,
    input  wire        [ 127: 0]        us_timming_dout_i          ,
    input  wire                         us_timming_empty_i         ,
    input  wire        [  11: 0]        us_timming_cache_count_i   ,

    output reg                          transmit_done_pluse_o      ,
    output reg                          us_timming_flow_vld_o      ,
    output reg         [ 127: 0]        us_timming_flow_o           
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                          S_IDLE                    = 0     ;
    localparam                          S_READ_DATA               = 1     ;
    localparam                          S_SIM_DATA                = 2     ;

    wire                                msg_done_pluse             ;
    wire                                msg_sim_en                 ;
    wire                                msg_sim_vld                ;
    wire               [ 127: 0]        msg_sim_data               ;

    reg                [   1: 0]        state                      ;
    reg                [  11: 0]        us_timming_cache_count_cache  ;

    reg                [  11: 0]        us_timming_cache_rd_cnt    ;

// ********************************************************************************** // 
//---------------------------------------------------------------------
// main code
//---------------------------------------------------------------------
    assign                              msg_sim_en                = state == S_SIM_DATA;

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if (!rst_n_i) begin
        state <= S_IDLE;
    end
    else case (state)
        S_IDLE:
            if(transmit_start_trigger_i)
                if(us_timming_cache_count_i == 0)
                    state <= S_SIM_DATA;
                else
                    state <= S_READ_DATA;
            else
                state <= state;
        S_SIM_DATA,S_READ_DATA:
            if(transmit_done_pluse_o)
                state <= S_IDLE;
            else
                state <= state;
        default: state <= state;
    endcase
end

always@(posedge sys_clk_i)begin
    if (transmit_start_trigger_i && state == S_IDLE)
        us_timming_cache_count_cache <= us_timming_cache_count_i;
end

always@(*)begin
    case (state)
        S_READ_DATA: us_timming_rd_en_o = ~us_timming_empty_i;
        default: us_timming_rd_en_o = 'd0;
    endcase
end

always@(posedge sys_clk_i)begin
    case (state)
        S_READ_DATA:
            if(us_timming_rd_en_o)
                us_timming_cache_rd_cnt <= us_timming_cache_rd_cnt + 'd1;
        default: us_timming_cache_rd_cnt <= 'd0;
    endcase
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if (!rst_n_i) begin
        transmit_done_pluse_o <= 'd0;
    end
    else case (state)
        S_READ_DATA:
            if(us_timming_cache_rd_cnt == us_timming_cache_count_cache - 2)
                transmit_done_pluse_o <= 'd1;
            else
                transmit_done_pluse_o <= 'd0;
        S_SIM_DATA: transmit_done_pluse_o <= msg_done_pluse;
        default: transmit_done_pluse_o <= 'd0;
    endcase
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        us_timming_flow_vld_o <= 'd0;
        us_timming_flow_o     <= 'd0;
    end
    else case (state)
        S_READ_DATA: begin
            us_timming_flow_vld_o <= us_timming_rd_en_o;
            us_timming_flow_o     <= us_timming_dout_i;
        end
        S_SIM_DATA: begin
            us_timming_flow_vld_o <= msg_sim_vld;
            us_timming_flow_o     <= msg_sim_data;
        end
        default: begin
            us_timming_flow_vld_o <= 'd0;
            us_timming_flow_o     <= 'd0;
        end
    endcase
end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// for sim data
//---------------------------------------------------------------------
    reg                [  23: 0]        expected_cache_id  [0:TOTAL_NUM-1]  ;

    wire               [   7: 0]        sim_src_id                 ;
    wire               [   7: 0]        sim_data_type              ;
    wire               [   7: 0]        sim_data_channel           ;

    
initial begin
    `include "expected_cache_id.vh"
end

    assign                              {sim_src_id,sim_data_type,sim_data_channel}= expected_cache_id[cache_num_i];

msg_transmit_simulation  msg_transmit_simulation_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),

    .msg_sim_en_i                       (msg_sim_en                ),
    .msg_done_pluse_o                   (msg_done_pluse            ),

    .sim_frame_header                   (32'hfdf7_eb90             ),
    .sim_frame_len                      (16'h0000                  ),
    .sim_frame_type                     (4'h4                      ),
    .sim_frame_cnt                      (frame_cnt_i               ),
    .sim_src_id                         (sim_src_id                ),
    .sim_des_id                         (8'h00                     ),
    .sim_data_type                      (sim_data_type             ),
    .sim_data_channel                   (sim_data_channel          ),
    .sim_data_field_len                 (16'd16                    ),

    .msg_sim_vld_o                      (msg_sim_vld               ),
    .msg_sim_data_o                     (msg_sim_data              ) 
  );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------


endmodule