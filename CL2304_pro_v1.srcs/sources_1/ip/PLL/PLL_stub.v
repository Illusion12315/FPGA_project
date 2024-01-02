// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Sep  6 16:04:45 2023
// Host        : WIN-CQ0NU0JNMTI running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               f:/CL2209/CL2209_BLK2711/CL2209_BLK2711.srcs/sources_1/ip/PLL/PLL_stub.v
// Design      : PLL
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module PLL(clk_50m, clk_100m, reset, locked, clk_in1_p, 
  clk_in1_n)
/* synthesis syn_black_box black_box_pad_pin="clk_50m,clk_100m,reset,locked,clk_in1_p,clk_in1_n" */;
  output clk_50m;
  output clk_100m;
  input reset;
  output locked;
  input clk_in1_p;
  input clk_in1_n;
endmodule
