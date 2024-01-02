// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Oct 25 20:27:31 2023
// Host        : chenxiongzhi running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/FPGA/project/CL2304_pro_v3/CL2304_pro_v3.srcs/sources_1/ip/ila_uart_tx_debug/ila_uart_tx_debug_stub.v
// Design      : ila_uart_tx_debug
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2018.3" *)
module ila_uart_tx_debug(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7, probe8)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[15:0],probe1[1:0],probe2[1:0],probe3[0:0],probe4[7:0],probe5[0:0],probe6[3:0],probe7[2:0],probe8[0:0]" */;
  input clk;
  input [15:0]probe0;
  input [1:0]probe1;
  input [1:0]probe2;
  input [0:0]probe3;
  input [7:0]probe4;
  input [0:0]probe5;
  input [3:0]probe6;
  input [2:0]probe7;
  input [0:0]probe8;
endmodule
