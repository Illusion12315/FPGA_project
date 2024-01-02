// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon Oct 23 10:51:03 2023
// Host        : WIN-CQ0NU0JNMTI running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -mode synth_stub F:/blk2711_fsm
// Design      : blk2711_fsm
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module blk2711_fsm(rx_100m, log_rst_n, rx_reset_n, pw_rst_done, 
  send_data_num, send_k_num, frame_header, frame_tail, frame_start_flag, fifo_us_rdclk, 
  fifo_us_empty, fifo_us_rdreq, fifo_us_q, fifo_ds_wrclk, fifo_ds_prog_full, fifo_ds_rx_data, 
  fifo_ds_wrreq, TKMSB, TKLSB, RKMSB, RKLSB, TX_Data, RX_Data)
/* synthesis syn_black_box black_box_pad_pin="rx_100m,log_rst_n,rx_reset_n,pw_rst_done,send_data_num[15:0],send_k_num[15:0],frame_header[15:0],frame_tail[15:0],frame_start_flag,fifo_us_rdclk,fifo_us_empty,fifo_us_rdreq,fifo_us_q[15:0],fifo_ds_wrclk,fifo_ds_prog_full,fifo_ds_rx_data[7:0],fifo_ds_wrreq,TKMSB,TKLSB,RKMSB,RKLSB,TX_Data[15:0],RX_Data[15:0]" */;
  input rx_100m;
  input log_rst_n;
  input rx_reset_n;
  input pw_rst_done;
  input [15:0]send_data_num;
  input [15:0]send_k_num;
  input [15:0]frame_header;
  input [15:0]frame_tail;
  output frame_start_flag;
  input fifo_us_rdclk;
  input fifo_us_empty;
  output fifo_us_rdreq;
  input [15:0]fifo_us_q;
  input fifo_ds_wrclk;
  input fifo_ds_prog_full;
  output [7:0]fifo_ds_rx_data;
  output fifo_ds_wrreq;
  output TKMSB;
  output TKLSB;
  input RKMSB;
  input RKLSB;
  output [15:0]TX_Data;
  input [15:0]RX_Data;
endmodule
