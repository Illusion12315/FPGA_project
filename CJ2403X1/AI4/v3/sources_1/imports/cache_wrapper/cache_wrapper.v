`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             cache_wrapper
// Create Date:           2024/07/02 20:37:29
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\AI3\AI3_top_v1\AI3_top_v1.srcs\sources_1\imports\cache_wrapper\cache_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none
`define cache_wrapper_ila_debug_valid

module cache_wrapper #(
    parameter                           SENSOR_NUM                = 18    
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    input  wire        [SENSOR_NUM-1: 0]wr_en_i                    ,
    input  wire        [SENSOR_NUM*16-1: 0]wr_dout_i               ,
    input  wire                         adc_acq_start_pluse_i      ,
    input  wire                         sim_data_en_i              ,

    input  wire        [SENSOR_NUM-1: 0]rd_en_i                    ,
    output wire        [SENSOR_NUM*8-1: 0]rd_dout_o                ,
    output wire        [SENSOR_NUM-1: 0]empty_o                    ,
    output wire        [SENSOR_NUM*16-1: 0]rd_data_count_o          
);

    wire               [  11: 0]        rd_data_count     [0: SENSOR_NUM-1]  ;

    wire               [SENSOR_NUM-1: 0]prog_full                  ;
    reg                [SENSOR_NUM-1: 0]wr_en                      ;
    reg                [SENSOR_NUM*16-1: 0]wr_data                 ;
    reg                [SENSOR_NUM*16-1: 0]wr_sim_data             ;

    reg                                 sim_data_en_r1,sim_data_en_r2  ;

always@(posedge sys_clk_i)begin
    sim_data_en_r1 <= sim_data_en_i;
    sim_data_en_r2 <= sim_data_en_r1;
end

generate
    genvar i;
    begin : sensor
        for (i = 0; i<SENSOR_NUM; i=i+1) begin : fifo
            always@(posedge sys_clk_i)begin
                if (!rst_n_i)
                    wr_en[i] <= 'd0;
                else if (sim_data_en_r2)
                    wr_en[i] <= adc_acq_start_pluse_i;
                else
                    wr_en[i] <= wr_en_i[i];
            end

            always@(posedge sys_clk_i)begin
                if (!rst_n_i)
                    wr_sim_data[i*16 +: 16] <= 'd0;
                else if (sim_data_en_r2 && wr_en[i])
                    wr_sim_data[i*16 +: 16] <= wr_sim_data[i*16 +: 16] + 'd1;
            end

            always@(posedge sys_clk_i)begin
                if (sim_data_en_r2)
                    wr_data[i*16 +: 16] <= {2{wr_sim_data[i*16 +: 8]}};
                else
                    wr_data[i*16 +: 16] <= wr_dout_i[i*16 +: 16];
            end

            fifo_16_to_8 fifo_16_to_8_inst (
                .clk                                (sys_clk_i                 ),// input wire clk
                .srst                               (~rst_n_i                  ),// input wire srst

                .wr_en                              (wr_en[i]                  ),// input wire wr_en
                .din                                (wr_data[i*16 +: 16]       ),// input wire [15 : 0] din
                .prog_full                          (prog_full[i]              ),// output wire prog_full
                .full                               (                          ),// output wire full

                .rd_en                              (rd_en_i[i]                ),// input wire rd_en
                .dout                               (rd_dout_o[i*8 +: 8]       ),// output wire [7 : 0] dout
                .empty                              (empty_o[i]                ),// output wire empty
                .rd_data_count                      (rd_data_count[i]          ) // output wire [11 : 0] rd_data_count
            );

                assign                              rd_data_count_o[i*16 +: 16]= {4'b0,rd_data_count[i]};
        end
    end
endgenerate
            
`ifdef cache_wrapper_ila_debug_valid
ila_cache_debug ila_cache_debug_inst (
    .clk                                (sys_clk_i                 ),// input wire clk
        
    .probe0                             (wr_en_i[0]                ),// input wire [0:0]  probe0  
    .probe1                             (wr_dout_i[0*16 +: 16]     ),// input wire [15:0]  probe1 
    .probe2                             (prog_full[0]              ),// input wire [0:0]  probe2 
    .probe3                             (rd_en_i[0]                ),// input wire [0:0]  probe3 
    .probe4                             (rd_dout_o[0*8 +: 8]       ),// input wire [7:0]  probe4 
    .probe5                             (empty_o[0]                ),// input wire [0:0]  probe5 
    .probe6                             (rd_data_count[0]          ) // input wire [11:0]  probe6
);
`endif

endmodule