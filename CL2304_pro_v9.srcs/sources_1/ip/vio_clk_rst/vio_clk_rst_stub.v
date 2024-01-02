// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Oct 25 20:18:10 2023
// Host        : chenxiongzhi running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/FPGA/project/CL2304_pro_v3/CL2304_pro_v3.srcs/sources_1/ip/vio_clk_rst/vio_clk_rst_stub.v
// Design      : vio_clk_rst
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2018.3" *)
module vio_clk_rst(clk, probe_in0, probe_in1, probe_in2, probe_in3, 
  probe_in4, probe_in5, probe_out0)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[19:0],probe_in1[19:0],probe_in2[19:0],probe_in3[3:0],probe_in4[0:0],probe_in5[0:0],probe_out0[0:0]" */;
  input clk;
  input [19:0]probe_in0;
  input [19:0]probe_in1;
  input [19:0]probe_in2;
  input [3:0]probe_in3;
  input [0:0]probe_in4;
  input [0:0]probe_in5;
  output [0:0]probe_out0;
endmodule
