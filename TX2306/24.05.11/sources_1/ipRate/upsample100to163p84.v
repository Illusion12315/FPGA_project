// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Wed Jun 14 14:26:32 2023
// Host        : DESKTOP-LIA5CMM running 64-bit major release  (build 9200)
// Command     : write_verilog -mode synth_stub
//               E:/kgrsx/project_clk100to16384_14i16o_cube_coefficient_in_reverse_order/upsample100to163p84.v
// Design      : upsample100to163p84
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module upsample100to163p84(i_clk100, i_clk163, i_rst_n, i_din_valid, 
  i_din_data_i, i_din_data_q, da_vld_o, dai_o, daq_o)
/* synthesis syn_black_box black_box_pad_pin="i_clk100,i_clk163,i_rst_n,i_din_valid,i_din_data_i[13:0],i_din_data_q[13:0],da_vld_o,dai_o[15:0],daq_o[15:0]" */;
  input i_clk100;
  input i_clk163;
  input i_rst_n;
  input i_din_valid;
  input [13:0]i_din_data_i;
  input [13:0]i_din_data_q;
  output da_vld_o;
  output [15:0]dai_o;
  output [15:0]daq_o;
endmodule
