`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/14 19:11:28
// Design Name: 
// Module Name: crc_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module crc_sim(
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    
    input              [   7: 0]        i_para_type                ,
    input                               i_para_en                  ,
    input              [ 103: 0]        ds_sync_data_i             ,
    input              [  39: 0]        ms_ls_status_i             ,
    input              [ 351: 0]        ds_statistics_i            ,
    input              [ 415: 0]        us_statistics_i            ,
    input              [  47: 0]        us_data_cache_cnt_i        ,
    input              [  31: 0]        software_info_i            ,
    
    output reg         [   7: 0]        data_in                    ,
    output reg                          data_valid                  
    );


    reg                [   9: 0]        data_cnt                   ;
    reg                [   3: 0]        state                      ;

    reg                [   9: 0]        r_frame_leng               ;

    reg                                 vio_para_en_r1,vio_para_en_r2  ;

    wire               [   7: 0]        w_para_type                ;
    wire                                pos_para_en                ;

// assign w_para_type = 8'h0A;
    assign                              w_para_type               = i_para_type;

// assign o_para_type = w_para_type;
always @(posedge sys_clk_i)begin
    vio_para_en_r1 <= i_para_en;
    vio_para_en_r2 <= vio_para_en_r1;
end

    assign                              pos_para_en               = !vio_para_en_r2 && vio_para_en_r1;

always @(posedge sys_clk_i or negedge rst_n_i)begin
    if(rst_n_i == 1'b0)begin
        r_frame_leng <= 10'd0;
    end
    else case(w_para_type)
            8'h00,8'h10,8'h18:r_frame_leng <= 'd1;
            8'h09:r_frame_leng <= 'd3;
            8'h12,8'h05,8'h06,8'h07,8'h30:r_frame_leng <= 'd4;

            // 690t to 7045
            8'h20:r_frame_leng <= 'd13;
            8'h21:r_frame_leng <= 'd5;                              // this way plz!
            8'h22:r_frame_leng <= 'd44;
            8'h23:r_frame_leng <= 'd52;
            8'h24:r_frame_leng <= 'd6;

            8'h13,8'h14:r_frame_leng <= 'd6;
            8'h11:r_frame_leng <= 'd8;
            8'h08,8'h0B:r_frame_leng <= 'd17;
            8'h0C:r_frame_leng <= 'd22;
            8'h15:r_frame_leng <= 'd32;
            8'h16:r_frame_leng <= 'd63;
        default:begin r_frame_leng <= 10'd0;end
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// zhuang tai ji
//---------------------------------------------------------------------
    localparam                          IDLE                      = 0;
    localparam                          HEAD                      = 1;
    localparam                          DATA                      = 2;
    localparam                          WAIT                      = 3;

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        state <= 'd0;
    else case (state)
        IDLE:
            if(pos_para_en==1'b1)begin
                state <= HEAD;
            end
            else begin
                state <= IDLE;
            end
        HEAD:
            if(data_cnt == 10'd50)begin
                state <= DATA;
            end
            else begin
                state <= HEAD;
            end
        DATA:
            if (data_cnt == r_frame_leng) begin
                state <= WAIT;
            end
            else begin
                state <= DATA;
            end
        WAIT: state <= IDLE;
        default: state <= state;
    endcase
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        data_in <= 'd0;
    else case (state)
        IDLE,HEAD: data_in <= 'd0;
        DATA:
            if (data_cnt == r_frame_leng) begin
                data_in <= data_in;
            end
            else case (w_para_type)
                // 690t to 7045
                8'h20: data_in <= ds_sync_data_i[103 - 8*data_cnt -: 8];
                8'h21: data_in <= ms_ls_status_i[39 - 8*data_cnt -: 8];// sir! this way!
                8'h22: data_in <= ds_statistics_i[351 - 8*data_cnt -: 8];
                8'h23: data_in <= us_statistics_i[415 - 8*data_cnt -: 8];
                8'h24: data_in <= us_data_cache_cnt_i[47 - 8*data_cnt -: 8];
                8'h30: data_in <= software_info_i[31 - 8*data_cnt -: 8];
                
                default: data_in <= data_in + 1'b1;                 // default: send increasing number
            endcase
        default: data_in <= data_in;
    endcase
end

always @(posedge sys_clk_i or negedge rst_n_i)begin
    if(rst_n_i == 1'b0)begin
        data_valid <= 1'b0;
        data_cnt   <= 10'd0;
    end
    else case(state)
        IDLE:begin
            data_valid <= 1'b0;
            data_cnt   <= 10'd0;
        end
        HEAD:begin
            data_valid <= 1'b0;
            if(data_cnt == 10'd50)begin
                data_cnt   <= 10'd0;
            end
            else begin
                data_cnt <= data_cnt + 1'b1;
            end
        end
        DATA:begin
            if(data_cnt == r_frame_leng)begin
                data_cnt <= 10'd0;
                data_valid <= 1'b0;
            end
            else begin
                data_cnt <= data_cnt + 1'b1;
                data_valid <= 1'b1;
            end
        end
        default:begin
            data_valid <= data_valid;
            data_cnt   <= data_cnt  ;
        end
    endcase
end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
//ila_crc_sim ila_crc_sim_inst (
//    .clk                                (sys_clk_i                 ),// input wire clk

//    .probe0                             (data_in                   ),// input wire [7:0]  probe0  
//    .probe1                             (data_valid                ),// input wire [0:0]  probe1 
//    .probe2                             (data_cnt                  ),// input wire [9:0]  probe2 
//    .probe3                             (state                     ),// input wire [3:0]  probe3 
//    .probe4                             (r_frame_leng              ),// input wire [9:0]  probe4 
//    .probe5                             (w_para_type               ),// input wire [7:0]  probe5 
//    .probe6                             (pos_para_en               ) // input wire [0:0]  probe6
//);
endmodule