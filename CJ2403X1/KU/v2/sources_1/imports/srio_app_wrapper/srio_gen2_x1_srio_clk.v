//
// (c) Copyright 2010 - 2014 Xilinx, Inc. All rights reserved.
//
//                                                                 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// 	PART OF THIS FILE AT ALL TIMES.                                

`timescale 1ps/1ps

module srio_gen2_x1_srio_clk
 (// Clock in ports
  input         sys_clkp,
  input         sys_clkn,
  input         txoutclk,
  input         gtpowergood_out,
  input  [0:0]       gt_txpmaresetdone,
  output        freerun_clk,
  // Status and control signals
  input         sys_rst,
  input         mode_1x,
  // Clock out ports
  output        log_clk,
  output        phy_clk,
  output        gt_pcs_clk,
  output        gt_clk,
  output        refclk,
 
  // Status and control signals
  output        clk_lock
 );

  //------------------------------------
  // wire declarations
  //------------------------------------
  wire        refclk_bufg;
  wire        clkout0;
  wire        clkout1;
  wire        clkout2;
  wire        clkout3;
  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        clkfbout;
  wire        to_feedback_in;
  wire        clkfboutb_unused;
  wire        clkout0b_unused;
  wire        clkout1b_unused;
  wire        clkout2b_unused;
  wire        clkout3_unused;
  wire        clkout3b_unused;
  wire        clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  // End wire declarations
  //------------------------------------


//  // input buffering

  //---- start of Ultrascale clocking structure --------------------------------

  wire        freerun_clk_in;
  
  parameter integer P_FREQ_RATIO_SOURCE_TO_USRCLK  = 1;
  localparam integer P_USRCLK_INT_DIV  = P_FREQ_RATIO_SOURCE_TO_USRCLK - 1;
  localparam   [2:0] P_USRCLK_DIV      = P_USRCLK_INT_DIV[2:0];

  IBUFDS_GTE3 
  #(.REFCLK_HROW_CK_SEL (2'b01))
  u_refclk_ibufds(
    .O      (refclk),
    .I      (sys_clkp),
    .IB     (sys_clkn),
    .CEB    (1'b0),
    .ODIV2  (freerun_clk_in)
  );


//______________________________________________________________________________

  // output buffering
  //-----------------------------------


assign drpclk = refclk;

  BUFG_GT freerun_clk_bufg_inst (
    .CE      (gtpowergood_out),
    .CEMASK  (1'b0),
    .CLR     (1'b0),
    .CLRMASK (1'b0),
    .DIV     (3'b001),
    .I       (freerun_clk_in),
    .O       (freerun_clk)
  );

BUFG_GT gt_clk_bufg_inst (
          .CE      (1'b1),
          .CEMASK  (1'b0),
                                                       
          .CLR     (sys_rst),
                                                       
          .CLRMASK (1'b0),
          .DIV     (3'b000),
          .I       (txoutclk),
          .O       (gt_clk)
        );


BUFG_GT gt_pcs_clk_bufg_inst (
          .CE      (1'b1),
          .CEMASK  (1'b0),
                                                       
          .CLR     (sys_rst),
                                                       
          .CLRMASK (1'b0),
          .DIV     (3'b001),
          .I       (txoutclk),
          .O       (gt_pcs_clk)
        );

//(* DONT_TOUCH = "true" *) BUFG phy_clk_bufg_inst
// Note that this bufg is a duplicate of the log_clk bufg, and is not necessary if BUFG_GT resources are limited.

BUFG_GT phy_clk_bufg_inst (
          .CE      (1'b1),
          .CEMASK  (1'b0),
                                                       
          .CLR     (sys_rst),
                                                       
          .CLRMASK (1'b0),
          .DIV     (3'b011),
          .I       (txoutclk),
          .O       (phy_clk)
        );


//(* DONT_TOUCH = "true" *) BUFG log_clk_bufg_inst

BUFG_GT log_clk_bufg_inst (
          .CE      (1'b1),
          .CEMASK  (1'b0),
                                                       
          .CLR     (sys_rst),
                                                       
          .CLRMASK (1'b0),
          .DIV     (3'b011),
          .I       (txoutclk),
          .O       (log_clk)
        );


  // End output buffering
//______________________________________________________________________________

endmodule

