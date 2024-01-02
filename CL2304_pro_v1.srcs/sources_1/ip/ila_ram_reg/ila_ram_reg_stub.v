// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Tue Oct 17 10:57:17 2023
// Host        : WIN-CQ0NU0JNMTI running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               F:/CL2304/CL2304_Pro/CL2304_Pro.srcs/sources_1/ip/ila_ram_reg/ila_ram_reg_stub.v
// Design      : ila_ram_reg
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2018.3" *)
module ila_ram_reg(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[0:0],probe1[31:0],probe2[31:0],probe3[0:0],probe4[31:0],probe5[31:0],probe6[31:0],probe7[31:0]" */;
  input clk;
  input [0:0]probe0;
  input [31:0]probe1;
  input [31:0]probe2;
  input [0:0]probe3;
  input [31:0]probe4;
  input [31:0]probe5;
  input [31:0]probe6;
  input [31:0]probe7;
endmodule
