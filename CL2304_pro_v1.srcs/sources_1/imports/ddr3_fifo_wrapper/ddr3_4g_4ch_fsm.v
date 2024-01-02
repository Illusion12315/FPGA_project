// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Fri Sep 15 13:46:42 2023
// Host        : Lian-Book running 64-bit major release  (build 9200)
// Command     : write_verilog -mode synth_stub D:/09_Mod/04_EDF_File/ddr3_4g_once64/ddr3_4g_4ch_fsm.v
// Design      : ddr3_4g_4ch_fsm
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module ddr3_4g_4ch_fsm(log_clk, log_rst_n, phy_init_done, 
  ddr3_fifo_usedw, fifo_rdreq_ddr3_us, fifo_q_ddr3_us, fifo_prog_empty_ddr3_us, app_en, 
  app_cmd, app_addr, app_rdy, app_wdf_wren, app_wdf_data, app_wdf_mask, app_wdf_end, app_wdf_rdy, 
  app_rd_data_valid, app_rd_data, app_rd_data_end, fifo_wrreq_ddr3_ds, fifo_data_ddr3_ds, 
  fifo_prog_full_ddr3_ds)
/* synthesis syn_black_box black_box_pad_pin="log_clk,log_rst_n,phy_init_done,ddr3_fifo_usedw[111:0],fifo_rdreq_ddr3_us[3:0],fifo_q_ddr3_us[2047:0],fifo_prog_empty_ddr3_us[3:0],app_en,app_cmd[2:0],app_addr[28:0],app_rdy,app_wdf_wren,app_wdf_data[511:0],app_wdf_mask[63:0],app_wdf_end,app_wdf_rdy,app_rd_data_valid,app_rd_data[511:0],app_rd_data_end,fifo_wrreq_ddr3_ds[3:0],fifo_data_ddr3_ds[2047:0],fifo_prog_full_ddr3_ds[3:0]" */;
  input log_clk;
  input log_rst_n;
  input phy_init_done;
  output [111:0]ddr3_fifo_usedw;
  output [3:0]fifo_rdreq_ddr3_us;
  input [2047:0]fifo_q_ddr3_us;
  input [3:0]fifo_prog_empty_ddr3_us;
  output app_en;
  output [2:0]app_cmd;
  output [28:0]app_addr;
  input app_rdy;
  output app_wdf_wren;
  output [511:0]app_wdf_data;
  output [63:0]app_wdf_mask;
  output app_wdf_end;
  input app_wdf_rdy;
  input app_rd_data_valid;
  input [511:0]app_rd_data;
  input app_rd_data_end;
  output [3:0]fifo_wrreq_ddr3_ds;
  output [2047:0]fifo_data_ddr3_ds;
  input [3:0]fifo_prog_full_ddr3_ds;
endmodule
