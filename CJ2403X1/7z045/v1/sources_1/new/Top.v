`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: chen xiong zhi
// 
// Create Date: 2024/06/04 17:15:57
// Design Name: 
// Module Name: Top
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

//`default_nettype none

module Top(
    input  wire                         SYSCLK_Z7_PL               ,// from ad9516

    input  wire                         SYSCLK                     ,// from ctystal oscillator
    // ad9516
    output wire                         AD9516_1_RESET_B           ,
    output wire                         AD9516_1_PD_B              ,// power down

    output wire                         AD9516_1_SCLK              ,
    output wire                         AD9516_1_SDIO              ,
    input  wire                         AD9516_1_SDO               ,
    output wire                         AD9516_1_CS                ,

    input  wire                         AD9516_1_STATUS            ,
    output wire                         AD9516_1_REFSEL            ,

    output wire                         AD9516_2_RESET_B           ,
    output wire                         AD9516_2_PD_B              ,

    output wire                         AD9516_2_SCLK              ,
    output wire                         AD9516_2_SDIO              ,
    input  wire                         AD9516_2_SDO               ,
    output wire                         AD9516_2_CS                ,

    input  wire                         AD9516_2_STATUS            ,
    output wire                         AD9516_2_REFSEL            ,
    // reset
    input  wire                         RESET_N_3V3                ,

    // ddr3
    input  wire                         Z7_PL_DDR3_CLK_P           ,
    input  wire                         Z7_PL_DDR3_CLK_N           ,

    // srio
    input  wire                         SRIO_REFCLK13_P            ,
    input  wire                         SRIO_REFCLK13_N            ,

    // gpio
    output wire                         Z7_PL_GPIO0                ,
    output wire                         Z7_PL_GPIO1                ,
    output wire                         Z7_PL_GPIO2                ,
    output wire                         Z7_PL_GPIO3                ,
    output wire                         Z7_PL_GPIO4                ,
    output wire                         Z7_PL_GPIO5                ,
    output wire                         Z7_PL_GPIO6                ,
    output wire                         Z7_PL_GPIO7                ,
    output wire                         Z7_PL_GPIO8                ,
    output wire                         Z7_PL_GPIO9                ,
    output wire                         Z7_PL_GPIO10               ,
    output wire                         Z7_PL_GPIO11               ,
    output wire                         Z7_PL_GPIO12               ,
    output wire                         Z7_PL_GPIO13               ,

    output wire                         Z7_KU115_GPIO1             ,
    output wire                         Z7_KU115_GPIO2             ,
    output wire                         Z7_KU115_GPIO3             ,
    output wire                         Z7_KU115_GPIO4             ,
    output wire                         Z7_KU115_GPIO5             ,
    output wire                         Z7_KU115_GPIO6              
    );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declaration
//---------------------------------------------------------------------
    wire                                clk_100m                   ;
    wire                                clk_50m                    ;
    wire                                hw_arst_n                  ;// clk50m
    wire                                sw_arst_n                  ;// clk50m
    wire                                ad9516_1_rst_n             ;// clk50m
    wire                                ad9516_2_rst_n             ;// clk50m

    wire                                Z7_PL_DDR3_CLK             ;
    wire                                SRIO_REFCLK13              ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// clk and rst
//---------------------------------------------------------------------
clk_rst_warpper  clk_rst_warpper_inst (
    .SYSCLK                             (SYSCLK                    ),

    .clk_100m                           (clk_100m                  ),
    .clk_50m                            (clk_50m                   ),
    .hw_arst_n                          (hw_arst_n                 ),
    .sw_arst_n                          (sw_arst_n                 ),
    .ad9516_1_rst_n                     (ad9516_1_rst_n            ),
    .ad9516_2_rst_n                     (ad9516_2_rst_n            ) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// ad9516 config
//---------------------------------------------------------------------
ad9516_warpper  ad9516_warpper_inst (
    .sys_clk_i                          (clk_50m                   ),
    .hw_arst_n                          (hw_arst_n                 ),

    .ad9516_1_rst_n                     (ad9516_1_rst_n            ),
    .AD9516_1_RESET_B                   (AD9516_1_RESET_B          ),
    .AD9516_1_PD_B                      (AD9516_1_PD_B             ),
    .AD9516_1_SCLK                      (AD9516_1_SCLK             ),
    .AD9516_1_SDIO                      (AD9516_1_SDIO             ),
    .AD9516_1_SDO                       (AD9516_1_SDO              ),
    .AD9516_1_CS                        (AD9516_1_CS               ),
    .AD9516_1_STATUS                    (AD9516_1_STATUS           ),
    .AD9516_1_REFSEL                    (AD9516_1_REFSEL           ),

    .ad9516_2_rst_n                     (ad9516_2_rst_n            ),
    .AD9516_2_RESET_B                   (AD9516_2_RESET_B          ),
    .AD9516_2_PD_B                      (AD9516_2_PD_B             ),
    .AD9516_2_SCLK                      (AD9516_2_SCLK             ),
    .AD9516_2_SDIO                      (AD9516_2_SDIO             ),
    .AD9516_2_SDO                       (AD9516_2_SDO              ),
    .AD9516_2_CS                        (AD9516_2_CS               ),
    .AD9516_2_STATUS                    (AD9516_2_STATUS           ),
    .AD9516_2_REFSEL                    (AD9516_2_REFSEL           ) 
  );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 
//---------------------------------------------------------------------
IBUFDS #(
    .DIFF_TERM                          ("FALSE"                   ),// Differential Termination
    .IBUF_LOW_PWR                       ("TRUE"                    ),// Low power="TRUE", Highest performance="FALSE" 
    .IOSTANDARD                         ("DEFAULT"                 ) // Specify the input I/O standard
) IBUFDS_ddr3 (
    .O                                  (Z7_PL_DDR3_CLK            ),// Buffer output
    .I                                  (Z7_PL_DDR3_CLK_P          ),// Diff_p buffer input (connect directly to top-level port)
    .IB                                 (Z7_PL_DDR3_CLK_N          ) // Diff_n buffer input (connect directly to top-level port)
);

IBUFDS_GTE2 #(
    .CLKCM_CFG                          ("TRUE"                    ),// Refer to Transceiver User Guide
    .CLKRCV_TRST                        ("TRUE"                    ),// Refer to Transceiver User Guide
    .CLKSWING_CFG                       (2'b11                     ) // Refer to Transceiver User Guide
) IBUFDS_GTE2_pcie (
    .O                                  (SRIO_REFCLK13             ),// 1-bit output: Refer to Transceiver User Guide
    .ODIV2                              (                          ),// 1-bit output: Refer to Transceiver User Guide
    .CEB                                (1'b0                      ),// 1-bit input: Refer to Transceiver User Guide
    .I                                  (SRIO_REFCLK13_P           ),// 1-bit input: Refer to Transceiver User Guide
    .IB                                 (SRIO_REFCLK13_N           ) // 1-bit input: Refer to Transceiver User Guide
);



endmodule
