`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             ad7656_wrapper
// Create Date:           2024/07/02 18:18:40
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\AI3\AI3_top_v1\AI3_top_v1.srcs\sources_1\imports\ad7656_wrapper\ad7656_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none

module ad7656_wrapper #(
    parameter                           ADC_NUM                   = 5     ,
    parameter                           SENSOR_NUM                = 25    
) (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,
    
    input  wire                         time_25ms_pluse_i          ,
    input  wire                         start_flag_i               ,

    output wire                         ADC1_CS_FPGA               ,
    output wire                         ADC1_CONVST_FPGA           ,
    output wire                         ADC1_RESET_FPGA            ,
    output wire                         ADC1_RD_FPGA               ,
    output wire                         WR_1_FPGA                  ,
    input  wire                         ADC1_BUSY_FPGA             ,
    inout  wire        [  15: 0]        ADC1_DB                    ,

    output wire                         ADC2_CS_FPGA               ,
    output wire                         ADC2_CONVST_FPGA           ,
    output wire                         ADC2_RESET_FPGA            ,
    output wire                         ADC2_RD_FPGA               ,
    output wire                         WR_2_FPGA                  ,
    input  wire                         ADC2_BUSY_FPGA             ,
    inout  wire        [  15: 0]        ADC2_DB                    ,
    
    output wire                         ADC3_CS_FPGA               ,
    output wire                         ADC3_CONVST_FPGA           ,
    output wire                         ADC3_RESET_FPGA            ,
    output wire                         ADC3_RD_FPGA               ,
    output wire                         WR_3_FPGA                  ,
    input  wire                         ADC3_BUSY_FPGA             ,
    inout  wire        [  15: 0]        ADC3_DB                    ,
    
    output wire                         ADC4_CS_FPGA               ,
    output wire                         ADC4_CONVST_FPGA           ,
    output wire                         ADC4_RESET_FPGA            ,
    output wire                         ADC4_RD_FPGA               ,
    output wire                         WR_4_FPGA                  ,
    input  wire                         ADC4_BUSY_FPGA             ,
    inout  wire        [  15: 0]        ADC4_DB                    ,
    
    output wire                         ADC5_CS_FPGA               ,
    output wire                         ADC5_CONVST_FPGA           ,
    output wire                         ADC5_RESET_FPGA            ,
    output wire                         ADC5_RD_FPGA               ,
    output wire                         WR_5_FPGA                  ,
    input  wire                         ADC5_BUSY_FPGA             ,
    inout  wire        [  15: 0]        ADC5_DB                    ,
    
    input  wire        [79:0]           megnetic_freq              ,
    output wire        [SENSOR_NUM-1: 0]wr_en_o                    ,
    output wire        [SENSOR_NUM*16-1: 0]wr_dout_o                
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 
//---------------------------------------------------------------------
    wire               [ADC_NUM-1: 0]   convst_A_o                 ;
    wire               [ADC_NUM-1: 0]   BUSY_i                     ;
    wire               [ADC_NUM-1: 0]   cs_n_o                     ;
    wire               [ADC_NUM-1: 0]   rd_n_o                     ;
    wire               [ADC_NUM-1: 0]   adc_reset                  ;
    wire               [ADC_NUM*16-1: 0]DB_i                       ;

    wire               [  15: 0]        ch1_data_o          [0: ADC_NUM-1]  ;
    wire               [  15: 0]        ch2_data_o          [0: ADC_NUM-1]  ;
    wire               [  15: 0]        ch3_data_o          [0: ADC_NUM-1]  ;
    wire               [  15: 0]        ch4_data_o          [0: ADC_NUM-1]  ;
    wire               [  15: 0]        ch5_data_o          [0: ADC_NUM-1]  ;
    wire               [  15: 0]        ch6_data_o          [0: ADC_NUM-1]  ;
    wire               [ADC_NUM-1: 0]   convst_done_o              ;
    
    reg                [79:0]           megnetic_freq_r,megnetic_freq_r2;
    reg                                 start_flag_r,start_flag_r2;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// assigns
//---------------------------------------------------------------------
    always@(posedge sys_clk_i)begin
        megnetic_freq_r     <=  megnetic_freq;
        megnetic_freq_r2    <=  megnetic_freq_r;
    end
    
    always@(posedge sys_clk_i)begin
        start_flag_r    <=  start_flag_i;
        start_flag_r2   <=  start_flag_r;
    end

    assign                              wr_en_o[6]                = convst_done_o[0];
    assign                              wr_en_o[1]                = convst_done_o[0];
    assign                              wr_en_o[0]                = convst_done_o[0];
    assign                              wr_en_o[5]                = convst_done_o[0];
    assign                              wr_en_o[9]                = convst_done_o[0];
    assign                              wr_en_o[8]                = convst_done_o[1];
    assign                              wr_en_o[3]                = convst_done_o[1];
    assign                              wr_en_o[4]                = convst_done_o[1];
    assign                              wr_en_o[7]                = convst_done_o[1];
    assign                              wr_en_o[2]                = convst_done_o[1];
    assign                              wr_en_o[19]               = convst_done_o[2];
    assign                              wr_en_o[11]               = convst_done_o[2];
    assign                              wr_en_o[18]               = convst_done_o[2];
    assign                              wr_en_o[14]               = convst_done_o[2];
    assign                              wr_en_o[10]               = convst_done_o[2];
    assign                              wr_en_o[17]               = convst_done_o[3];
    assign                              wr_en_o[13]               = convst_done_o[3];
    assign                              wr_en_o[12]               = convst_done_o[3];
    assign                              wr_en_o[16]               = convst_done_o[3];
    assign                              wr_en_o[15]               = convst_done_o[3];
    assign                              wr_en_o[22]               = (start_flag_r2)	?	1'B1	:	convst_done_o[4];
    assign                              wr_en_o[21]               = (start_flag_r2)	?	1'B1	:	convst_done_o[4];
    assign                              wr_en_o[24]               = (start_flag_r2)	?	1'B1	:	convst_done_o[4];
    assign                              wr_en_o[20]               = (start_flag_r2)	?	1'B1	:	convst_done_o[4];
    assign                              wr_en_o[23]               = (start_flag_r2)	?	1'B1	:	convst_done_o[4];


    assign                              wr_dout_o [6*16 +: 16]    = ch1_data_o[0];
    assign                              wr_dout_o [1*16 +: 16]    = ch2_data_o[0];
    assign                              wr_dout_o [0*16 +: 16]    = ch3_data_o[0];
    assign                              wr_dout_o [5*16 +: 16]    = ch4_data_o[0];
    assign                              wr_dout_o [9*16 +: 16]    = ch5_data_o[0];
    assign                              wr_dout_o [8*16 +: 16]    = ch1_data_o[1];
    assign                              wr_dout_o [3*16 +: 16]    = ch2_data_o[1];
    assign                              wr_dout_o [4*16 +: 16]    = ch3_data_o[1];
    assign                              wr_dout_o [7*16 +: 16]    = ch4_data_o[1];
    assign                              wr_dout_o [2*16 +: 16]    = ch5_data_o[1];
    assign                              wr_dout_o [19*16 +: 16]   = ch1_data_o[2];
    assign                              wr_dout_o [11*16 +: 16]   = ch2_data_o[2];
    assign                              wr_dout_o [18*16 +: 16]   = ch3_data_o[2];
    assign                              wr_dout_o [14*16 +: 16]   = ch4_data_o[2];
    assign                              wr_dout_o [10*16 +: 16]   = ch5_data_o[2];
    assign                              wr_dout_o [17*16 +: 16]   = ch1_data_o[3];
    assign                              wr_dout_o [13*16 +: 16]   = ch2_data_o[3];
    assign                              wr_dout_o [12*16 +: 16]   = ch3_data_o[3];
    assign                              wr_dout_o [16*16 +: 16]   = ch4_data_o[3];
    assign                              wr_dout_o [15*16 +: 16]   = ch5_data_o[3];
    assign                              wr_dout_o [22*16 +: 16]   = (start_flag_r2)	?	megnetic_freq_r2[47:32]	:	ch1_data_o[4];
    assign                              wr_dout_o [21*16 +: 16]   = (start_flag_r2)	?	megnetic_freq_r2[31:16]	:	ch2_data_o[4];
    assign                              wr_dout_o [24*16 +: 16]   = (start_flag_r2)	?	megnetic_freq_r2[79:64]	:	ch3_data_o[4];
    assign                              wr_dout_o [20*16 +: 16]   = (start_flag_r2)	?	megnetic_freq_r2[15:0]		:	ch4_data_o[4];
    assign                              wr_dout_o [23*16 +: 16]   = (start_flag_r2)	?	megnetic_freq_r2[63:48]	:	ch5_data_o[4];

    assign                              WR_1_FPGA                 = 'd0;
    assign                              WR_2_FPGA                 = 'd0;
    assign                              WR_3_FPGA                 = 'd0;
    assign                              WR_4_FPGA                 = 'd0;
    assign                              WR_5_FPGA                 = 'd0;
    

    assign                              {ADC5_RESET_FPGA,ADC4_RESET_FPGA,ADC3_RESET_FPGA,ADC2_RESET_FPGA,ADC1_RESET_FPGA}= adc_reset;
    assign                              {ADC5_CONVST_FPGA,ADC4_CONVST_FPGA,ADC3_CONVST_FPGA,ADC2_CONVST_FPGA,ADC1_CONVST_FPGA}= convst_A_o;
    assign                              {ADC5_CS_FPGA,ADC4_CS_FPGA,ADC3_CS_FPGA,ADC2_CS_FPGA,ADC1_CS_FPGA}= cs_n_o;
    assign                              {ADC5_RD_FPGA,ADC4_RD_FPGA,ADC3_RD_FPGA,ADC2_RD_FPGA,ADC1_RD_FPGA}= rd_n_o;
    
    assign                              DB_i                      = {ADC5_DB,ADC4_DB,ADC3_DB,ADC2_DB,ADC1_DB};
    assign                              BUSY_i                    = {ADC5_BUSY_FPGA,ADC4_BUSY_FPGA,ADC3_BUSY_FPGA,ADC2_BUSY_FPGA,ADC1_BUSY_FPGA};

//    assign                              {ADC4_RESET_FPGA,ADC3_RESET_FPGA,ADC2_RESET_FPGA,ADC1_RESET_FPGA}= adc_reset;
//    assign                              {ADC4_CONVST_FPGA,ADC3_CONVST_FPGA,ADC2_CONVST_FPGA,ADC1_CONVST_FPGA}= convst_A_o;
//    assign                              {ADC4_CS_FPGA,ADC3_CS_FPGA,ADC2_CS_FPGA,ADC1_CS_FPGA}= cs_n_o;
//    assign                              {ADC4_RD_FPGA,ADC3_RD_FPGA,ADC2_RD_FPGA,ADC1_RD_FPGA}= rd_n_o;

//    assign                              DB_i                      = {ADC4_DB,ADC3_DB,ADC2_DB,ADC1_DB};
//    assign                              BUSY_i                    = {ADC4_BUSY_FPGA,ADC3_BUSY_FPGA,ADC2_BUSY_FPGA,ADC1_BUSY_FPGA};
// ********************************************************************************** // 
//---------------------------------------------------------------------
// gene
//---------------------------------------------------------------------
generate
    genvar i;
    begin : ad7656
        for (i = 0; i<ADC_NUM; i=i+1) begin : ch
            ad7656_rd_driver u_ad7656_rd_driver(
                .sys_clk_i                          (sys_clk_i                 ),
                .rst_n_i                            (rst_n_i                   ),
                // 开始标志
                .start_flag_i                       (start_flag_i              ),
                // 
                .convst_A_o                         (convst_A_o[i]             ),
                .convst_B_o                         (                          ),
                .convst_C_o                         (                          ),
                .BUSY_i                             (BUSY_i[i]                 ),
                .cs_n_o                             (cs_n_o[i]                 ),
                .rd_n_o                             (rd_n_o[i]                 ),
                .adc_reset                          (adc_reset[i]              ),
                .DB_i                               (DB_i[i*16 +: 16]          ),

                .ch1_data_o                         (ch1_data_o[i]             ),
                .ch2_data_o                         (ch2_data_o[i]             ),
                .ch3_data_o                         (ch3_data_o[i]             ),
                .ch4_data_o                         (ch4_data_o[i]             ),
                .ch5_data_o                         (ch5_data_o[i]             ),
                .ch6_data_o                         (ch6_data_o[i]             ),
                .convst_done_o                      (convst_done_o[i]          ) 
            );
        end
    end
endgenerate

endmodule