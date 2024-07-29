`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             us_data_forwarding
// Create Date:           2024/06/27 13:43:19
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sources_1\imports\up_stream_wrapper\us_data_forwarding.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module us_data_forwarding #(
    parameter                           ZX_CHANNEL                = 2     ,
    parameter                           TOTAL_NUM                 = 114   
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire                         time25ms_pluse_i           ,

    output wire        [ZX_CHANNEL-1: 0]us_burst_rd_en_o           ,
    input  wire        [ZX_CHANNEL*128-1: 0]us_burst_dout_i        ,
    input  wire        [ZX_CHANNEL-1: 0]us_burst_empty_i           ,
    input  wire        [ZX_CHANNEL*12-1: 0]us_burst_cache_count_i  ,

    output wire        [TOTAL_NUM-1: 0] us_timming_rd_en_o         ,
    input  wire        [TOTAL_NUM*128-1: 0]us_timming_dout_i       ,
    input  wire        [TOTAL_NUM-1: 0] us_timming_empty_i         ,
    input  wire        [TOTAL_NUM*12-1: 0]us_timming_cache_count_i ,

    output reg                          us_timming_flow_vld_o      ,
    output reg         [ 127: 0]        us_timming_flow_o          ,
    input  wire                         us_timming_flow_prog_full_i     
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                          S_IDLE                    = 0     ;
    localparam                          S_READ_DATA               = 1     ;

    reg                [  11: 0]        us_timming_cache_count_cache[0:TOTAL_NUM-1]  ;

    reg                [   1: 0]        state                      ;

    wire               [TOTAL_NUM-1: 0] transmit_done_pluse        ;
    reg                [TOTAL_NUM-1: 0] transmit_start_trigger     ;

    reg                [   7: 0]        transmit_cnt               ;
    reg                [   7: 0]        transmit_cnt_r1            ;
    wire               [TOTAL_NUM-1: 0] us_timming_flow_vld        ;
    wire               [ 127: 0]        us_timming_flow    [ 0:TOTAL_NUM-1]  ;

    reg                [TOTAL_NUM*12-1: 0]us_timming_cache_count_r1  ;
    reg                [  15: 0]        frame_cnt                  ;
    reg                                 time25ms_pluse_r1          ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// main code
//---------------------------------------------------------------------
    assign                              us_burst_rd_en_o[1]       = (state == S_IDLE) ? ~us_burst_empty_i[1] : 'd0;
    assign                              us_burst_rd_en_o[0]       = (state == S_IDLE) ? ~us_burst_empty_i[0] : 'd0;

always@(posedge sys_clk_i)begin
    if (!rst_n_i) 
        time25ms_pluse_r1 <= 'd0;
    else if (transmit_done_pluse[TOTAL_NUM-1])
        time25ms_pluse_r1 <= 'd0;
    else if (time25ms_pluse_i)
        time25ms_pluse_r1 <= 'd1;
    else
        time25ms_pluse_r1 <= time25ms_pluse_r1;
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i)
        state <= S_IDLE;
    else case (state)
        S_IDLE:
            if(time25ms_pluse_r1 && (&us_burst_empty_i))
                state <= S_READ_DATA;
            else
                state <= state;
        S_READ_DATA:
            if(transmit_done_pluse[TOTAL_NUM-1])
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
            if(transmit_done_pluse[TOTAL_NUM-1])
                transmit_cnt <= 'd0;
            else if(|transmit_done_pluse)
                transmit_cnt <= transmit_cnt + 'd1;
            else
                transmit_cnt <= transmit_cnt;
        default: transmit_cnt <= 'd0;
    endcase
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        transmit_start_trigger <= 'd0;
    end
    else case (state)
        S_READ_DATA:
            if (transmit_done_pluse[transmit_cnt])
                transmit_start_trigger[transmit_cnt] <= 'd0;
            else
                transmit_start_trigger[transmit_cnt] <= 'd1;
        
        default: transmit_start_trigger <= 'd0;
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
        us_timming_flow_vld_o <= 'd0;
        us_timming_flow_o     <= 'd0;
    end
    else case (state)
        S_IDLE: begin
            us_timming_flow_vld_o <= us_burst_rd_en_o[0];
            us_timming_flow_o     <= us_burst_dout_i[0*128 +: 128];
        end
        S_READ_DATA: begin
            us_timming_flow_vld_o <= us_timming_flow_vld[transmit_cnt_r1];
            us_timming_flow_o     <= us_timming_flow[transmit_cnt_r1];
        end
        default: begin
            us_timming_flow_vld_o <= 'd0;
            us_timming_flow_o     <= 'd0;
        end
    endcase
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if (!rst_n_i) begin
        us_timming_cache_count_r1 <= 'd0;
    end
    else if (time25ms_pluse_i) begin
        us_timming_cache_count_r1 <= us_timming_cache_count_i;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        frame_cnt <= 'd0;
    end
    else if (transmit_done_pluse[TOTAL_NUM-1]) begin
        frame_cnt <= frame_cnt + 'd1;
    end
end

generate
    begin : us_timming
        genvar i;
        for (i = 0; i<TOTAL_NUM; i=i+1) begin : req_driver

            us_timming_req_driver #(
                .TOTAL_NUM                          (TOTAL_NUM                 ) 
            ) u_us_timming_req_driver (
                .sys_clk_i                          (sys_clk_i                 ),
                .rst_n_i                            (rst_n_i                   ),
                .transmit_start_trigger_i           (transmit_start_trigger[i] ),
                .cache_num_i                        (transmit_cnt              ),
                .frame_cnt_i                        (frame_cnt                 ),

                .us_timming_rd_en_o                 (us_timming_rd_en_o[i]     ),
                .us_timming_dout_i                  (us_timming_dout_i[i*128 +: 128]),
                .us_timming_empty_i                 (us_timming_empty_i[i]     ),
                .us_timming_cache_count_i           (us_timming_cache_count_r1[i*12 +: 12]),

                .transmit_done_pluse_o              (transmit_done_pluse[i]    ),
                .us_timming_flow_vld_o              (us_timming_flow_vld[i]    ),
                .us_timming_flow_o                  (us_timming_flow[i]        ) 
            );

        end
    end
endgenerate

// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
ila_us_forwarding ila_us_forwarding_inst (
    .clk                                (sys_clk_i                 ),// input wire clk

    .probe0                             (state                     ),// input wire [1:0]  probe0  
    .probe1                             (transmit_cnt              ),// input wire [7:0]  probe1 
    .probe2                             (us_timming_flow_vld_o     ),// input wire [0:0]  probe2 
    .probe3                             (us_timming_flow_o         ),// input wire [127:0]  probe3 
    .probe4                             (transmit_start_trigger    ),// input wire [113:0]  probe4 
    .probe5                             (transmit_done_pluse       ),// input wire [113:0]  probe5
    .probe6                             (us_timming_flow_prog_full_i) // input wire [0:0]  probe6
);

endmodule