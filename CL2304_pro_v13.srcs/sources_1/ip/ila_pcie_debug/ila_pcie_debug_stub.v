// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon Nov 27 13:42:20 2023
// Host        : DESKTOP-Q7D4HV3 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/Administrator/Desktop/project/CL2304/CL2304_pro_v11/CL2304_pro_v11.srcs/sources_1/ip/ila_pcie_debug/ila_pcie_debug_stub.v
// Design      : ila_pcie_debug
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2018.3" *)
module ila_pcie_debug(clk, probe0, probe1, probe2)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[0:0],probe1[255:0],probe2[0:0]" */;
  input clk;
  input [0:0]probe0;
  input [255:0]probe1;
  input [0:0]probe2;
endmodule
