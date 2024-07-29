// file: lvds_test_ip.v
// (c) Copyright 2009 - 2011 Xilinx, Inc. All rights reserved.
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
//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// None
//----------------------------------------------------------------------------

`timescale 1ps/1ps

(* CORE_GENERATION_INFO = "lvds_test_ip,selectio_wiz_v4_1,{component_name=lvds_test_ip,bus_dir=SEPARATE,bus_sig_type=DIFF,bus_io_std=LVDS_25,use_serialization=false,use_phase_detector=false,serialization_factor=4,enable_bitslip=false,enable_train=false,system_data_width=2,bus_in_delay=NONE,bus_out_delay=NONE,clk_sig_type=DIFF,clk_io_std=LVCMOS18,clk_buf=BUFIO2,active_edge=RISING,clk_delay=NONE,v6_bus_in_delay=NONE,v6_bus_out_delay=NONE,v6_clk_buf=BUFIO,v6_active_edge=SDR,v6_ddr_alignment=SAME_EDGE_PIPELINED,v6_oddr_alignment=SAME_EDGE,ddr_alignment=C0,v6_interface_type=NETWORKING,interface_type=NETWORKING,v6_bus_in_tap=0,v6_bus_out_tap=0,v6_clk_io_std=LVDS_25,v6_clk_sig_type=DIFF}" *)

module lvds_test_ip1
   // width of the data for the system
 #(parameter sys_w = 4,
   // width of the data for the device
   parameter dev_w = 4)
 (
  // From the system into the device
  input  [sys_w-1:0] DATA_IN_FROM_PINS_P,
  input  [sys_w-1:0] DATA_IN_FROM_PINS_N,
  output [dev_w-1:0] DATA_IN_TO_DEVICE,
  // From the device out to the system
  input  				clk_100m_from_dev,
  input  [dev_w-1:0] DATA_OUT_FROM_DEVICE,
  output [sys_w-1:0] DATA_OUT_TO_PINS_P,
  output [sys_w-1:0] DATA_OUT_TO_PINS_N,
  output             clk_to_pins_p,
  output             clk_to_pins_n,
  input              CLK_IN_P,      // Differential clock from IOB
  input              CLK_IN_N,
  output             CLK_OUT,
  
  input              data_vld_from_pin,
  input              data_vld_from_device,
  
  
  output             data_vld_to_pin,
  output             data_vld_to_device, 

  
  input              IO_RESET);
  // Signal declarations
  ////------------------------------
  wire               clock_enable = 1'b1;
  // After the buffer
  wire   [sys_w-1:0] data_in_from_pins_int;
  // Between the delay and serdes
  wire [sys_w-1:0]  data_in_from_pins_delay;
  // Before the buffer
  wire   [sys_w-1:0] data_out_to_pins_int;
  // Between the delay and serdes
  wire   [sys_w-1:0] data_out_to_pins_predelay;
  wire     clk_div_out;
  
  wire      clk_div;
  wire      clk_in_int;
  
  // Create the clock logic
  IBUFGDS
    #(.IOSTANDARD ("LVDS"))
   ibufds_clk_inst
     (.I          (CLK_IN_P),
      .IB         (CLK_IN_N),
      .O          (clk_in_int));


  
   // BUFR generates the slow clock
   BUFR
    #(.SIM_DEVICE("7SERIES"),
    .BUFR_DIVIDE("BYPASS"))
    clkin_buf_inst
    (.O (clk_div),
     .CE(),
     .CLR(),
     .I (clk_in_int));
	  
	    BUFR
    #(.SIM_DEVICE("7SERIES"),
    .BUFR_DIVIDE("BYPASS"))
    clkout_buf_inst
    (.O (clk_div_out),
     .CE(),
     .CLR(),
     .I (clk_100m_from_dev)); 
	  
	  	  OBUFDS
     #(.IOSTANDARD ("LVDS"))
     obufds_inst
       (.O          (clk_to_pins_p),
        .OB         (clk_to_pins_n),
        .I          (clk_div_out));

   assign CLK_OUT = clk_div; // This is regional clock;

  // We have multiple bits- step over every bit, instantiating the required elements
  genvar pin_count;
  generate for (pin_count = 0; pin_count < sys_w; pin_count = pin_count + 1) begin: pins
    // Instantiate the buffers
    ////------------------------------
    // Instantiate a buffer for every bit of the data bus
    OBUFDS
      #(.IOSTANDARD ("LVDS"))
     obufds_inst
       (.O          (DATA_OUT_TO_PINS_P  [pin_count]),
        .OB         (DATA_OUT_TO_PINS_N  [pin_count]),
        .I          (data_out_to_pins_int[pin_count]));
    IBUFDS
      #(.DIFF_TERM  ("FALSE"),             // Differential termination
        .IOSTANDARD ("LVDS"))
     ibufds_inst
       (.I          (DATA_IN_FROM_PINS_P  [pin_count]),
        .IB         (DATA_IN_FROM_PINS_N  [pin_count]),
        .O          (data_in_from_pins_int[pin_count]));

    // Pass through the delay
    ////-------------------------------
   assign data_in_from_pins_delay[pin_count] = data_in_from_pins_int[pin_count];
   assign data_out_to_pins_int[pin_count]    = data_out_to_pins_predelay[pin_count];
 
    // Connect the delayed data to the fabric
    ////--------------------------------------

    // Pack the registers into the IOB

    wire data_in_to_device_int;
    (* IOB = "true" *)
    FDRE fdre_in_inst
      (.D              (data_in_from_pins_delay[pin_count]),
       .C              (clk_div),
       .CE             (clock_enable),
       .R              (IO_RESET),
       .Q              (data_in_to_device_int)
      );
    assign DATA_IN_TO_DEVICE[pin_count] = data_in_to_device_int;
    wire data_out_from_device_q;
    (* IOB = "true" *)
    FDRE fdre_out_inst
      (.D              (DATA_OUT_FROM_DEVICE[pin_count]),
       .C              (clk_100m_from_dev),
       .CE             (clock_enable),
       .R              (IO_RESET),
       .Q              (data_out_from_device_q)
      );
    assign data_out_to_pins_predelay[pin_count] = data_out_from_device_q;
  end
  endgenerate




//////////////revieve

wire    dat_vld_in_tmp;
wire    dat_vld_in_tmp_int;
wire    data_vld_to_pin_tmp_delay_int;
wire    data_vld_to_pin_tmp ;
wire    data_vld_to_pin_tmp_delay;




IBUF
 #(.IOSTANDARD ("LVCMOS18"))
ibuf_clk_inst
  (.I          (data_vld_from_pin),
   .O          (dat_vld_in_tmp));

  (* IOB = "true" *)
FDRE fdre_in_inst_vld
    (.D              (dat_vld_in_tmp),
     .C              (clk_div),
     .CE             (clock_enable),
     .R              (IO_RESET),
     .Q              (dat_vld_in_tmp_int)
    );
  assign data_vld_to_device = dat_vld_in_tmp_int;
  
  
///////////////////////////////////////////////////////////

OBUF
      #(.IOSTANDARD ("LVCMOS18"))
     obuf_inst
       (.O          (data_vld_to_pin               ),
        .I          (data_vld_to_pin_tmp_delay_int) );

    // Pass through the delay
    ////-------------------------------
   assign data_vld_to_pin_tmp_delay_int   = data_vld_to_pin_tmp_delay;
 
    // Connect the delayed data to the fabric
    ////--------------------------------------

    // Pack the registers into the IOB
    wire data_out_from_device_q;
    (* IOB = "true" *)
    FDRE fdre_out_inst
      (.D              (data_vld_from_device       ),
       .C              (clk_100m_from_dev),
       .CE             (clock_enable),
       .R              (IO_RESET),
       .Q              (data_vld_to_pin_tmp)
      );
    assign data_vld_to_pin_tmp_delay = data_vld_to_pin_tmp;
  
  
  
//ILA_LVDS_IP    ila_lvds_ip (
//      .clk        (clk_in_int),              // input wire clk
  
//      .probe0     (4'd0    ), // input wire [3:0]  probe0  
//      .probe1     (4'd0       ), // input wire [3:0]  probe1 
//      .probe2     (data_in_from_pins_int            ), // input wire [3:0]  probe2 
//      .probe3     (DATA_IN_TO_DEVICE            ) // input wire [3:0]  probe2 
 
//  );



endmodule
