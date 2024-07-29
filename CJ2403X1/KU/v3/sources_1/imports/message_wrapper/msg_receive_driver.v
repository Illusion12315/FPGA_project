`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             msg_receive_driver
// Create Date:           2024/06/25 19:01:47
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\message_wrapper\msg_receive_driver.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none



module msg_receive_driver (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    output wire                         rd_clk_o                   ,
    output wire                         rd_en_o                    ,
    input  wire        [ 127: 0]        rd_din_i                   ,
    input  wire                         rd_empty_i                 ,
    // msg header info
    output reg         [  15: 0]        prased_frame_len           ,
    output reg         [   3: 0]        prased_frame_type          ,
    output reg         [  15: 0]        prased_frame_cnt           ,
    output reg         [   7: 0]        prased_src_id              ,
    output reg         [   7: 0]        prased_des_id              ,
    output reg         [   7: 0]        prased_data_type           ,
    output reg         [   7: 0]        prased_data_channel        ,
    output reg         [  15: 0]        prased_data_field_len      ,
    // msg data flow
    output reg                          msg_rec_valid_o            ,
    output reg         [ 127: 0]        msg_rec_data_o             ,

    output reg                          msg_rec_crc_vld_o          ,
    output reg         [   7: 0]        msg_rec_crc_data_o          
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                          S_IDLE                    = 0     ;
    localparam                          S_HEADER                  = 1     ;
    localparam                          S_REC_DATA                = 2     ;

    reg                [   1: 0]        cur_state                  ;
    reg                [   1: 0]        next_state                 ;
    
    wire               [  31: 0]        current_header             ;
    wire               [  15: 0]        current_frame_len          ;
    wire               [   3: 0]        current_frame_type         ;
    wire               [  15: 0]        current_frame_cnt          ;
    wire               [   7: 0]        current_src_id             ;
    wire               [   7: 0]        current_des_id             ;
    wire               [   7: 0]        current_data_type          ;
    wire               [   7: 0]        current_data_channel       ;
    wire               [  15: 0]        current_data_field_len     ;

    wire               [  18: 0]        prased_frame_len_exact     ;
    reg                [  18: 0]        rec_cnt                    ;// 16byte + 1

    wire                                start_pluse                ;
    wire                                end_pluse                  ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// main code
//---------------------------------------------------------------------
    assign                              current_header            = rd_din_i[127 -: 32];
    assign                              current_frame_len         = rd_din_i[95  -: 16];
    assign                              current_frame_type        = rd_din_i[67  -: 4 ];
    assign                              current_frame_cnt         = rd_din_i[63  -: 16];
    assign                              current_src_id            = rd_din_i[47  -: 8 ];
    assign                              current_des_id            = rd_din_i[39  -: 8 ];
    assign                              current_data_type         = rd_din_i[31  -: 8 ];
    assign                              current_data_channel      = rd_din_i[23  -: 8 ];
    assign                              current_data_field_len    = rd_din_i[15  -: 16];

    assign                              start_pluse               = rd_en_o && (current_header == 32'hFDF7_EB90);

    assign                              end_pluse                 = rd_en_o && (rec_cnt + 'd1 == prased_frame_len_exact);

    assign                              prased_frame_len_exact    = (prased_frame_len + 'd1) << 2;

    assign                              rd_clk_o                  = sys_clk_i;

    assign                              rd_en_o                   = ~rd_empty_i;

//第一段,状态跳转,时序逻辑
always@(posedge sys_clk_i)begin
    if(!rst_n_i)
        cur_state <= S_IDLE;
    else
        cur_state <= next_state;
end

//第二段,跳转条件,组合逻辑
always@(*)begin
    case(cur_state)
        S_IDLE:
            if(start_pluse)
                next_state = S_HEADER;
            else
                next_state = S_IDLE;
        S_HEADER: next_state = S_REC_DATA;
        S_REC_DATA:
            if(end_pluse)
                next_state = S_IDLE;
            else
                next_state = S_REC_DATA;
        default: next_state = S_IDLE;
    endcase
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        rec_cnt <= 'd0;
    end
    else case (next_state)
        S_IDLE:
            if(start_pluse)
                rec_cnt <= rec_cnt + 'd1;
        S_HEADER,S_REC_DATA:
            if(end_pluse)
                rec_cnt <= 'd0;
            else if(rd_en_o)
                rec_cnt <= rec_cnt + 'd1;
        default: rec_cnt <= rec_cnt;
    endcase
end

always@(posedge sys_clk_i)begin
    if (start_pluse) begin
        prased_frame_len      <= current_frame_len     ;
        prased_frame_type     <= current_frame_type    ;
        prased_frame_cnt      <= current_frame_cnt     ;
        prased_src_id         <= current_src_id        ;
        prased_des_id         <= current_des_id        ;
        prased_data_type      <= current_data_type     ;
        prased_data_channel   <= current_data_channel  ;
        prased_data_field_len <= current_data_field_len;
    end
end

always@(posedge sys_clk_i)begin
    msg_rec_valid_o <= rd_en_o;
    msg_rec_data_o  <= rd_din_i;
end

always@(posedge sys_clk_i)begin
    msg_rec_crc_vld_o <= end_pluse;
end

always@(posedge sys_clk_i)begin
    if(!rst_n_i)
        msg_rec_crc_data_o <= 'd0;
    else if(end_pluse)
        msg_rec_crc_data_o <= rd_din_i[7:0];
end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------



endmodule