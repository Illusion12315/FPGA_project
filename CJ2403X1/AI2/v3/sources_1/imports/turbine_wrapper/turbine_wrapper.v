`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             turbine_wrapper
// Create Date:           2024/07/11 18:29:48
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\AI2\AI2_top_v1\AI2_top_v1.srcs\sources_1\imports\turbine_wrapper\turbine_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module turbine_wrapper #(
    parameter                           TURBINE_NUM               = 10    
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire                         turbine_acq_start_pluse_i  ,
    input  wire        [TURBINE_NUM-1: 0]TURBINE_START             ,

    output wire        [TURBINE_NUM-1: 0]wr_en_o                   ,
    output wire        [TURBINE_NUM*16-1: 0]wr_din_o                
);

    reg                [TURBINE_NUM-1: 0]turbine_start_r1,turbine_start_r2,turbine_start_r3  ;

    wire               [TURBINE_NUM-1: 0]turbine_start_pe          ;
    wire               [TURBINE_NUM-1: 0]turbine_start_ne          ;
    wire               [   9: 0]        empty                      ;

    reg                [  31: 0]        start_pe_period_cnt[0:TURBINE_NUM-1]  ;
    reg                [  31: 0]        start_pe2ne_period_cnt[0:TURBINE_NUM-1]  ;
    reg                [  31: 0]        start_pe_period_cnt_cache[0:TURBINE_NUM-1]  ;// 上升沿到上升沿时间
    reg                [  31: 0]        start_pe2ne_period_cnt_cache[0:TURBINE_NUM-1]  ;// 上升沿到下降沿时间

    reg                                 turbine_acq_start_pluse_r1  ;
    
    reg                [TURBINE_NUM-1: 0]wr_en_r                   ;
    reg                [TURBINE_NUM*32-1: 0]wr_din_r               ;
    
always@(posedge sys_clk_i)begin
    turbine_acq_start_pluse_r1 <= turbine_acq_start_pluse_i;
end

generate
    genvar i;
    for (i = 0; i<TURBINE_NUM; i=i+1) begin
        always@(posedge sys_clk_i)begin
            turbine_start_r1[i] <= TURBINE_START[i];
            turbine_start_r2[i] <= turbine_start_r1[i];
            turbine_start_r3[i] <= turbine_start_r2[i];
        end

    assign                              turbine_start_pe[i]       = turbine_start_r2[i] & ~turbine_start_r3[i];

    assign                              turbine_start_ne[i]       = ~turbine_start_r2[i] & turbine_start_r3[i];

        always@(posedge sys_clk_i)begin
            if (!rst_n_i) begin
                start_pe_period_cnt[i] <= 'd0;
                start_pe_period_cnt_cache[i] <= 'd0;
            end
            else if(turbine_start_pe[i]) begin
                start_pe_period_cnt[i] <= 'd0;
                start_pe_period_cnt_cache[i] <= start_pe_period_cnt[i];
            end
            else begin
                start_pe_period_cnt[i] <= start_pe_period_cnt[i] + 'd1;
                start_pe_period_cnt_cache[i] <= start_pe_period_cnt_cache[i];
            end
        end

        always@(posedge sys_clk_i)begin
            if (!rst_n_i) begin
                start_pe2ne_period_cnt[i] <= 'd0;
                start_pe2ne_period_cnt_cache[i] <= 'd0;
            end
            else if (turbine_start_ne[i]) begin
                start_pe2ne_period_cnt[i] <= 'd0;
                start_pe2ne_period_cnt_cache[i] <= start_pe2ne_period_cnt[i];
            end
            else if (turbine_start_pe[i]) begin
                start_pe2ne_period_cnt[i] <= 'd0;
                start_pe2ne_period_cnt_cache[i] <= start_pe2ne_period_cnt_cache[i];
            end
            else begin
                start_pe2ne_period_cnt[i] <= start_pe2ne_period_cnt[i] + 'd1;
                start_pe2ne_period_cnt_cache[i] <= start_pe2ne_period_cnt_cache[i];
            end
        end

        always@(posedge sys_clk_i)begin
            if(turbine_acq_start_pluse_i | turbine_acq_start_pluse_r1)
                wr_en_r[i] <= 'd1;
            else
                wr_en_r[i] <= 'd0;
        end

        always@(posedge sys_clk_i)begin
            if(turbine_acq_start_pluse_i)
                wr_din_r[i*32 +: 32] <= start_pe_period_cnt_cache[i];
            else if(turbine_acq_start_pluse_r1)
                wr_din_r[i*32 +: 32] <= start_pe2ne_period_cnt_cache[i];
        end

        fifo_32to16 fifo_32to16_inst (
            .clk                                (sys_clk_i                 ),// input wire clk
            .srst                               (~rst_n_i                  ),// input wire srst

            .wr_en                              (wr_en_r[i]                ),// input wire wr_en
            .din                                (wr_din_r[i*32 +: 32]      ),// input wire [31 : 0] din
            .full                               (                          ),// output wire full

            .rd_en                              (wr_en_o[i]                ),// input wire rd_en
            .dout                               (wr_din_o[i*16 +: 16]      ),// output wire [15 : 0] dout
            .empty                              (empty[i]                  ) // output wire empty
        );

    assign                              wr_en_o[i]                = ~empty[i];

    if(i == 0 || i == 9) begin : ch
        ila_turbine ila_turbine_inst (
            .clk                                (sys_clk_i                 ),// input wire clk

            .probe0                             (turbine_start_r3[i]       ),// input wire [0:0]  probe0  
            .probe1                             (turbine_start_pe[i]       ),// input wire [0:0]  probe1 
            .probe2                             (turbine_start_ne[i]       ),// input wire [0:0]  probe2 
            .probe3                             (start_pe_period_cnt[i]    ),// input wire [31:0]  probe3 
            .probe4                             (start_pe_period_cnt_cache[i]),// input wire [31:0]  probe4 
            .probe5                             (start_pe2ne_period_cnt[i] ),// input wire [31:0]  probe5 
            .probe6                             (start_pe2ne_period_cnt_cache[i]),// input wire [31:0]  probe6 
            .probe7                             (wr_en_r[i]                ),// input wire [0:0]  probe7 
            .probe8                             (wr_din_r[i*32 +: 32]      ) // input wire [31:0]  probe8
        );
    end

    end
endgenerate










endmodule


`default_nettype wire