// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Oct 20 16:04:10 2023
// Host        : DESKTOP-Q7D4HV3 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/Administrator/Desktop/project/CL2304/CL2304_PCIE_V6/CL2304_PCIE_V6.srcs/sources_1/ip/vio_clk_rst/vio_clk_rst_stub.v
// Design      : vio_clk_rst
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2018.3" *)
module vio_clk_rst(clk, probe_in0, probe_in1, probe_in2, probe_in3, 
  probe_in4, probe_in5, probe_out0, probe_out1, probe_out2, probe_out3, probe_out4, probe_out5)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[19:0],probe_in1[19:0],probe_in2[19:0],probe_in3[3:0],probe_in4[0:0],probe_in5[0:0],probe_out0[0:0],probe_out1[3:0],probe_out2[63:0],probe_out3[63:0],probe_out4[0:0],probe_out5[0:0]" */;
  input clk;
  input [19:0]probe_in0;
  input [19:0]probe_in1;
  input [19:0]probe_in2;
  input [3:0]probe_in3;
  input [0:0]probe_in4;
  input [0:0]probe_in5;
  output [0:0]probe_out0;
  output [3:0]probe_out1;
  output [63:0]probe_out2;
  output [63:0]probe_out3;
  output [0:0]probe_out4;
  output [0:0]probe_out5;
endmodule
