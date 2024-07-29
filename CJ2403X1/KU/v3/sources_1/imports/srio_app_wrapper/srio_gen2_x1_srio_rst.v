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

module srio_gen2_x1_srio_rst
   (
    input            cfg_clk,                 // CFG interface clock
    input            log_clk,                 // LOG interface clock
    input            phy_clk,                 // PHY interface clock
    input            gt_pcs_clk,              // GT Fabric interface clock
    input         freerun_clk_in,
    output        gt_rst,

    input            sys_rst,                 // Global reset signal
    input            port_initialized,        // Port is intialized
    input            phy_rcvd_link_reset,     // Received 4 consecutive reset symbols
    input            force_reinit,            // Force reinitialization
    input            clk_lock,                // Indicates the MMCM has achieved a stable clock

    output reg       controlled_force_reinit, // Force reinitialization

    output           cfg_rst,                 // CFG dedicated reset
    output           log_rst,                 // LOG dedicated reset
    output           buf_rst,                 // BUF dedicated reset
    output           phy_rst,                 // PHY dedicated reset
    output           gt_pcs_rst               // GT dedicated reset
   );


  // {{{ Parameter declarations -----------
  // Reset State Machine
  localparam  IDLE       = 4'b0001;
  localparam  LINKRESET  = 4'b0010;
  localparam  PHY_RESET1 = 4'b0100;
  localparam  PHY_RESET2 = 4'b1000;

  // }}} End Parameter declarations -------
  
  wire sys_rst_buffered;


  // {{{ wire declarations ----------------
  reg   [0:3]   reset_state      = IDLE;
  reg   [0:3]   reset_next_state = IDLE;


  reg               sys_rst_int;
  wire              reset_condition = sys_rst || phy_rcvd_link_reset || sys_rst_int;

  // }}} End wire declarations ------------



  reg clk_lock_inv = 1'b1;

  always @(posedge gt_pcs_clk) begin
    if (reset_condition) begin
      clk_lock_inv  <= 1'b1;
    end
    else begin
      clk_lock_inv  <= ~clk_lock;
    end
  end 

  (* ASYNC_REG = "TRUE" *) reg gt_rst_in_meta  = 1'b1;
  (* ASYNC_REG = "TRUE" *) reg gt_rst_in_sync1 = 1'b1;
  (* ASYNC_REG = "TRUE" *) reg gt_rst_in_sync2 = 1'b1;
  (* ASYNC_REG = "TRUE" *) reg gt_rst_in_sync3 = 1'b1;
                           reg gt_rst_in_out   = 1'b1;

  always @(posedge freerun_clk_in) begin
    if (reset_condition) begin
      gt_rst_in_meta  <= 1'b1;
      gt_rst_in_sync1 <= 1'b1;
      gt_rst_in_sync2 <= 1'b1;
      gt_rst_in_sync3 <= 1'b1;
      gt_rst_in_out   <= 1'b1;
    end
    else begin
      gt_rst_in_meta  <= 1'b0;
      gt_rst_in_sync1 <= gt_rst_in_meta;
      gt_rst_in_sync2 <= gt_rst_in_sync1;
      gt_rst_in_sync3 <= gt_rst_in_sync2;
      gt_rst_in_out   <= gt_rst_in_sync3;
    end
  end

  assign gt_rst = gt_rst_in_out;


  (* ASYNC_REG = "TRUE" *) reg log_rst_in_meta  = 1'b1;
  (* ASYNC_REG = "TRUE" *) reg log_rst_in_sync1 = 1'b1;
  (* ASYNC_REG = "TRUE" *) reg log_rst_in_sync2 = 1'b1;
  (* ASYNC_REG = "TRUE" *) reg log_rst_in_sync3 = 1'b1;
                           reg log_rst_in_out   = 1'b1;

  always @(posedge log_clk) begin
  //always @(posedge log_clk ) begin
    if (reset_condition) begin
      log_rst_in_meta  <= 1'b1;
      log_rst_in_sync1 <= 1'b1;
      log_rst_in_sync2 <= 1'b1;
      log_rst_in_sync3 <= 1'b1;
      log_rst_in_out   <= 1'b1;
    end
    else begin
      log_rst_in_meta  <= clk_lock_inv;
      log_rst_in_sync1 <= log_rst_in_meta;
      log_rst_in_sync2 <= log_rst_in_sync1;
      log_rst_in_sync3 <= log_rst_in_sync2;
      log_rst_in_out   <= log_rst_in_sync3;
    end
  end

  assign log_rst = log_rst_in_out;
  assign cfg_rst = log_rst_in_out;

  // The Buffer actively manages the reset due to the
  // nature of the domain crossing being done in the buffer.
  assign buf_rst = reset_condition;

  (* ASYNC_REG = "TRUE" *) reg phy_rst_in_meta  = 1'b1;
  (* ASYNC_REG = "TRUE" *) reg phy_rst_in_sync1 = 1'b1;
  (* ASYNC_REG = "TRUE" *) reg phy_rst_in_sync2 = 1'b1;
  (* ASYNC_REG = "TRUE" *) reg phy_rst_in_sync3 = 1'b1;
                           reg phy_rst_in_out   = 1'b1;

  always @(posedge phy_clk) begin
    if (reset_condition) begin
      phy_rst_in_meta  <= 1'b1;
      phy_rst_in_sync1 <= 1'b1;
      phy_rst_in_sync2 <= 1'b1;
      phy_rst_in_sync3 <= 1'b1;
      phy_rst_in_out   <= 1'b1;
    end
    else begin
      phy_rst_in_meta  <= clk_lock_inv;
      phy_rst_in_sync1 <= phy_rst_in_meta;
      phy_rst_in_sync2 <= phy_rst_in_sync1;
      phy_rst_in_sync3 <= phy_rst_in_sync2;
      phy_rst_in_out   <= phy_rst_in_sync3;
    end
  end

  assign phy_rst = phy_rst_in_out;
  assign gt_pcs_rst = clk_lock_inv;



  // This controller is used to properly send link reset requests that were
  // made by the user.
  always@(posedge log_clk) begin
    reset_state <= reset_next_state;
  end


  always @* begin
    casex (reset_state)

      IDLE: begin
        // Current State Outputs
        sys_rst_int             = 1'b0;
        controlled_force_reinit = 1'b0;
        // Next State Outputs
        if (force_reinit)
          reset_next_state = LINKRESET;
        else
          reset_next_state = IDLE;
      end

      LINKRESET: begin
        // Current State Outputs
        sys_rst_int             = 1'b0;
        controlled_force_reinit = 1'b1;
        // Next State Outputs
        if (~port_initialized)
          reset_next_state = PHY_RESET1;
        else
          reset_next_state = LINKRESET;
      end

      PHY_RESET1: begin
        // Current State Outputs
        sys_rst_int             = 1'b1;
        controlled_force_reinit = 1'b0;
        // Next State Outputs
        reset_next_state = PHY_RESET2;
      end

      PHY_RESET2: begin
        // Current State Outputs
        sys_rst_int             = 1'b1;
        controlled_force_reinit = 1'b0;
        // Next State Outputs
        if (force_reinit)
          reset_next_state = PHY_RESET2;
        else
          reset_next_state = IDLE;
      end

      default: begin
        // Current State Outputs
        sys_rst_int             = 1'b0;
        controlled_force_reinit = 1'b0;
        // Next State Outputs
        reset_next_state = IDLE;
      end

    endcase
  end



endmodule
// {{{ DISCLAIMER OF LIABILITY
// -----------------------------------------------------------------
// (c) Copyright 2014 Xilinx, Inc. All rights reserved.
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
// PART OF THIS FILE AT ALL TIMES.
// }}}
