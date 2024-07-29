`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             msg_transmit_driver
// Create Date:           2024/06/25 19:02:43
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\message_wrapper\msg_transmit_driver.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none
`define msg_trans_driver_debug_valid


module msg_transmit_driver #(
    parameter                           ILA_CH                    = 1     
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire                         transmit_start_pluse_i     ,
    output wire                         send_done_o                ,
    
    input  wire        [  31: 0]        transmit_header            ,
    input  wire        [   3: 0]        transmit_frame_type        ,
    input  wire        [  15: 0]        transmit_frame_cnt         ,
    input  wire        [   7: 0]        transmit_src_id            ,
    input  wire        [   7: 0]        transmit_des_id            ,
    input  wire        [   7: 0]        transmit_data_type         ,
    input  wire        [   7: 0]        transmit_data_channel      ,

    output wire                         rd_clk_o                   ,
    output reg                          rd_en_o                    ,
    input  wire        [   7: 0]        din_i                      ,
    input  wire        [  15: 0]        data_count_i               ,
    input  wire                         empty_i                    ,

    output reg                          flow_valid_o               ,
    output reg         [ 127: 0]        flow_data_o                 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                          S_IDLE                    = 0     ;
    localparam                          S_ARBIT                   = 1     ;
    localparam                          S_MSG_BODY                = 2     ;
    localparam                          S_MSG_BODY_REMAIN_S1      = 3     ;
    localparam                          S_MSG_BODY_REMAIN_S2      = 4     ;
    localparam                          S_MSG_TRANS               = 5     ;
    integer                             i                          ;

    wire               [ 127: 0]        current_msg_header         ;
    reg                [ 127: 0]        msg_header_cache           ;
    reg                [ 127: 0]        current_msg_body_cache     ;
    reg                [ 127: 0]        current_msg_body_remain_cache  ;

    wire                                rd_data_fifo_done          ;
    wire               [  18: 0]        exact_transmit_frame_len   ;

    reg                [   2: 0]        state                      ;
    wire               [  15: 0]        transmit_frame_len         ;
    reg                [  15: 0]        transmit_data_field_len  ='d0;
    wire               [  15: 0]        transmit_data_field_len_plus1  ;

    reg                [  15: 0]        rd_cnt                     ;
    reg                [  18: 0]        send_cnt                   ;

    reg                [   7: 0]        verify_num                 ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// main code
//---------------------------------------------------------------------
    assign                              transmit_frame_len        = (transmit_data_field_len + 'd16) >> 6;

    assign                              exact_transmit_frame_len  = (transmit_frame_len + 'd1) << 2;

    assign                              rd_clk_o                  = sys_clk_i;

    assign                              rd_data_fifo_done         = (rd_cnt == transmit_data_field_len - 1);

    assign                              transmit_data_field_len_plus1= transmit_data_field_len - 1;

    assign                              send_done_o               = (state == S_MSG_BODY_REMAIN_S2 || state == S_MSG_TRANS) ? (send_cnt == (exact_transmit_frame_len - 1)) : 'd0;

assign current_msg_header = {
                                transmit_header,
                                transmit_frame_len,
                                12'b0,
                                transmit_frame_type,
                                transmit_frame_cnt,
                                transmit_src_id,
                                transmit_des_id,
                                transmit_data_type,
                                transmit_data_channel,
                                transmit_data_field_len
                            };

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if (!rst_n_i)
        state <= S_IDLE;
    else case (state)
        S_IDLE:
            if (transmit_start_pluse_i)
                state <= S_ARBIT;
        S_ARBIT: state <= S_MSG_BODY;
        S_MSG_BODY:

            if(transmit_data_field_len == 16'd0)
                state <= S_MSG_TRANS;
            else if(rd_data_fifo_done)
                if(rd_cnt[3:0] == 4'hf)
                    state <= S_MSG_TRANS;
                else
                    state <= S_MSG_BODY_REMAIN_S1;
            else
                state <= state;
        S_MSG_BODY_REMAIN_S1: state <= S_MSG_BODY_REMAIN_S2;
        S_MSG_BODY_REMAIN_S2: 
            if(send_done_o)
                state <= S_IDLE;
            else
                state <= S_MSG_TRANS;
        S_MSG_TRANS:
            if(send_done_o)
                state <= S_IDLE;
        default:state <= state;
    endcase
end
// msg header
always@(*)begin
    msg_header_cache[15:0] = transmit_data_field_len;
end

always@(posedge sys_clk_i)begin
    if(transmit_start_pluse_i)
        msg_header_cache[127:16] <= current_msg_header[127:16];
end
// cache field len
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if (!rst_n_i) begin
        transmit_data_field_len <= 'd0;
    end
    else case (state)
        S_ARBIT: transmit_data_field_len <= data_count_i;
        default: transmit_data_field_len <= transmit_data_field_len;
    endcase
end
// 8 bit width fifo rd cnt
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if (!rst_n_i) begin
        rd_cnt <= 'd0;
    end
    else case (state)
        S_MSG_BODY:
            if(rd_data_fifo_done)
                rd_cnt <= rd_cnt;
            else
                rd_cnt <= rd_cnt + 'd1;
        S_MSG_BODY_REMAIN_S1,S_MSG_BODY_REMAIN_S2: rd_cnt <= rd_cnt;
        default: rd_cnt <= 'd0;
    endcase
end
// drive rd en
always@(*)begin
    case (state)
        S_MSG_BODY: rd_en_o = ~empty_i;
        default: rd_en_o = 'd0;
    endcase
end
// cur msg body
always@(posedge sys_clk_i)begin
    case (state)
        S_MSG_BODY: current_msg_body_cache[127-8*rd_cnt[3:0] -: 8] <= din_i;
        default: current_msg_body_cache <= 'd0;
    endcase
end

always@(posedge sys_clk_i)begin
    case (state)
        S_MSG_BODY:
            // if(transmit_data_field_len[5:0] == 6'b11_0000)          // 48 + n*64
            //     current_msg_body_remain_cache <= 'd0;
            // else 
            if(rd_cnt[15:4] == transmit_data_field_len_plus1[15:4])
                current_msg_body_remain_cache[127-8*rd_cnt[3:0] -: 8] <= din_i;
            else
                current_msg_body_remain_cache <= current_msg_body_remain_cache;
        S_MSG_BODY_REMAIN_S1,S_MSG_BODY_REMAIN_S2: current_msg_body_remain_cache <= current_msg_body_remain_cache;
        S_MSG_TRANS: current_msg_body_remain_cache <= current_msg_body_remain_cache;
        default: current_msg_body_remain_cache <= 'd0;
    endcase
end
// 128bit data sent cnt
always@(posedge sys_clk_i)begin
    case (state)
        S_MSG_BODY: begin
            casex (rd_cnt)
                16'h0000: send_cnt <= send_cnt + 'd1;
                16'hxxxf: send_cnt <= send_cnt + 'd1;
                default: send_cnt <= send_cnt;
            endcase
        end
        S_MSG_BODY_REMAIN_S1: send_cnt <= send_cnt;
        S_MSG_BODY_REMAIN_S2: send_cnt <= send_cnt + 'd1;
        S_MSG_TRANS: begin
            if(send_done_o)
                send_cnt <= 'd0;
            else
                send_cnt <= send_cnt + 'd1;
        end
        default: send_cnt <= 'd0;
    endcase
end
// + verify
always@(posedge sys_clk_i)begin
    case (state)
        S_ARBIT:
            verify_num <= msg_header_cache[8*0 +: 8] + msg_header_cache[8*1 +: 8]
                        + msg_header_cache[8*2 +: 8] + msg_header_cache[8*3 +: 8]
                        + msg_header_cache[8*4 +: 8] + msg_header_cache[8*5 +: 8]
                        + msg_header_cache[8*6 +: 8] + msg_header_cache[8*7 +: 8]
                        + msg_header_cache[8*8 +: 8] + msg_header_cache[8*9 +: 8]
                        + msg_header_cache[8*10 +: 8] + msg_header_cache[8*11 +: 8]
                        + msg_header_cache[8*12 +: 8] + msg_header_cache[8*13 +: 8]
                        + msg_header_cache[8*14 +: 8] + msg_header_cache[8*15 +: 8];
        S_MSG_BODY:
            if(rd_en_o)
                verify_num <= verify_num + din_i;
        S_MSG_BODY_REMAIN_S1,S_MSG_BODY_REMAIN_S2: verify_num <= verify_num;
        S_MSG_TRANS: verify_num <= verify_num;
        default: verify_num <= 'd0;
    endcase
end

always@(posedge sys_clk_i)begin
    case (state)
        S_MSG_BODY: begin
            casex (rd_cnt)
                16'h0000: begin
                    flow_valid_o <= 'd1;
                    flow_data_o <= msg_header_cache;
                end
                16'hxxxf: begin
                    flow_valid_o <= 'd1;
                    flow_data_o <= {current_msg_body_cache[127:8],din_i};
                end
                default: begin
                    flow_valid_o <= 'd0;
                    flow_data_o <= flow_data_o;
                end
            endcase
        end
        S_MSG_BODY_REMAIN_S2: begin
            flow_valid_o <= 'd1;
            flow_data_o <= (send_done_o) ? {current_msg_body_remain_cache[127:8],verify_num} : current_msg_body_remain_cache;
        end
        S_MSG_TRANS: begin
            flow_valid_o <= 'd1;
            
            if(send_done_o)
                flow_data_o <= {current_msg_body_cache[127:8],verify_num};
            else if(rd_cnt[3:0] == 4'hf)
                flow_data_o <= 'd0;
            else
                flow_data_o <= current_msg_body_cache;
        end
        default: begin
            flow_valid_o <= 'd0;
        end
    endcase
end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
`ifdef msg_trans_driver_debug_valid
generate
    if(ILA_CH == 20) begin : ch0
        ila_msg_trans_driver ila_msg_trans_driver_inst (
            .clk                                (sys_clk_i                 ),// input wire clk

            .probe0                             (transmit_start_pluse_i    ),// input wire [0:0]  probe0  
            .probe1                             (state                     ),// input wire [2:0]  probe1 
            .probe2                             (data_count_i[11:0]        ),// input wire [11:0]  probe2 
            .probe3                             (rd_data_fifo_done         ),// input wire [0:0]  probe3 
            .probe4                             (send_done_o               ),// input wire [0:0]  probe4 
            .probe5                             (flow_data_o               ),// input wire [127:0]  probe5 
            .probe6                             (flow_valid_o              ),// input wire [0:0]  probe6 
            .probe7                             (rd_cnt                    ),// input wire [15:0]  probe7 
            .probe8                             (send_cnt                  ),// input wire [18:0]  probe8
            .probe9                             (din_i                     ),// input wire [15:0]  probe9
            .probe10                            (rd_en_o                   ),// input wire [0:0]  probe10
            .probe11                            (current_msg_body_remain_cache) // input wire [127:0]  probe11
        );
    end
endgenerate
`endif



endmodule