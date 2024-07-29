`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             ad9516_warpper
// Create Date:           2024/06/07 16:26:03
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\7z045\cfg_7z045_top\cfg_7z045_top.srcs\sources_1\imports\AD9516_warpper\ad9516_warpper.v
// Descriptions:          
// 
// ********************************************************************************** // 

// `default_nettype none

module ad9516_warpper (
    input  wire                         sys_clk_i                  ,
    input  wire                         hw_arst_n                  ,

    input  wire                         ad9516_1_rst_n             ,
    output wire                         AD9516_1_RESET_B           ,
    output wire                         AD9516_1_PD_B              ,// power down

    output wire                         AD9516_1_SCLK              ,
    output wire                         AD9516_1_SDIO              ,
    input  wire                         AD9516_1_SDO               ,
    output wire                         AD9516_1_CS                ,

    input  wire                         AD9516_1_STATUS            ,
    output wire                         AD9516_1_REFSEL            ,// low choose ref1, high choose ref2

    input  wire                         ad9516_2_rst_n             ,
    output wire                         AD9516_2_RESET_B           ,
    output wire                         AD9516_2_PD_B              ,

    output wire                         AD9516_2_SCLK              ,
    output wire                         AD9516_2_SDIO              ,
    input  wire                         AD9516_2_SDO               ,
    output wire                         AD9516_2_CS                ,

    input  wire                         AD9516_2_STATUS            ,
    output wire                         AD9516_2_REFSEL             // low choose ref1, high choose ref2
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declaration
//---------------------------------------------------------------------


// ********************************************************************************** // 
//---------------------------------------------------------------------
// assigns
//---------------------------------------------------------------------
    assign                              AD9516_1_RESET_B          = 'd1;
    assign                              AD9516_1_PD_B             = 'd1;
    assign                              AD9516_1_REFSEL           = 'd0;

    assign                              AD9516_2_RESET_B          = 'd1;
    assign                              AD9516_2_PD_B             = 'd1;
    assign                              AD9516_2_REFSEL           = 'd0;

ad9516_1_warpper  ad9516_1_warpper_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (hw_arst_n                 ),
    .CS                                 (AD9516_1_CS               ),
    .SCLK                               (AD9516_1_SCLK             ),
    .SDIO                               (AD9516_1_SDIO             ),
    .SDO                                (AD9516_1_SDO              ),
    .write_busy_o                       (                          ),
    .spi_write_start_i                  (ad9516_1_rst_n            ) 
);

ad9516_2_warpper  ad9516_2_warpper_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (hw_arst_n                 ),
    .CS                                 (AD9516_2_CS               ),
    .SCLK                               (AD9516_2_SCLK             ),
    .SDIO                               (AD9516_2_SDIO             ),
    .SDO                                (AD9516_2_SDO              ),
    .write_busy_o                       (                          ),
    .spi_write_start_i                  (ad9516_2_rst_n            ) 
);

endmodule