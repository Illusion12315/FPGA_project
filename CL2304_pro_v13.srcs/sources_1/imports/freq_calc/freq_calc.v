// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Wed Dec 29 11:28:54 2021
// Host        : LONGLIAN running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -mode synth_stub E:/12_CJ2009_2U/03_Clock_test/edf/clock_test/clock_test.srcs/freq_calc.v
// Design      : freq_calc
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1158-2L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module freq_calc(clk_50m, rst_n, calc_clk, freq_cnt)
/* synthesis syn_black_box black_box_pad_pin="clk_50m,rst_n,calc_clk,freq_cnt[19:0]" */;
  input clk_50m;
  input rst_n;
  input calc_clk;
  output [19:0]freq_cnt;
endmodule
