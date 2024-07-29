// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Sat Jun 15 13:38:40 2024
// Host        : LIAN running 64-bit major release  (build 9200)
// Command     : write_verilog -mode synth_stub H:/04_EDF_File/srio_app_fsm/srio_app_fsm.v
// Design      : srio_app_fsm
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module srio_app_fsm(log_clk, log_rst, srio_tx_en, srio_rx_en, 
  srio_once_len, port_initialized, link_initialized, mode_1x, source_id, dest_id, device_id, 
  device_id_set, id_set_done, m_axis_treq_tvalid, m_axis_treq_tlast, m_axis_treq_tkeep, 
  m_axis_treq_tready, m_axis_treq_tuser, m_axis_treq_tdata, s_axis_tresp_tvalid, 
  s_axis_tresp_tlast, s_axis_tresp_tkeep, s_axis_tresp_tready, s_axis_tresp_tuser, 
  s_axis_tresp_tdata, s_axis_ireq_tvalid, s_axis_ireq_tlast, s_axis_ireq_tkeep, 
  s_axis_ireq_tready, s_axis_ireq_tuser, s_axis_ireq_tdata, m_axis_iresp_tvalid, 
  m_axis_iresp_tlast, m_axis_iresp_tkeep, m_axis_iresp_tready, m_axis_iresp_tuser, 
  m_axis_iresp_tdata, s_axi_maintr_awvalid, s_axi_maintr_awready, s_axi_maintr_awaddr, 
  s_axi_maintr_wvalid, s_axi_maintr_wready, s_axi_maintr_wdata, s_axi_maintr_bvalid, 
  s_axi_maintr_bready, s_axi_maintr_bresp, s_axi_maintr_arvalid, s_axi_maintr_arready, 
  s_axi_maintr_araddr, s_axi_maintr_rvalid, s_axi_maintr_rready, s_axi_maintr_rdata, 
  s_axi_maintr_rresp, fifo_wrreq_pkt_rx, fifo_data_pkt_rx, fifo_prog_full_pkt_rx, 
  fifo_rdreq_pkt_tx, fifo_q_pkt_tx, fifo_empty_pkt_tx, fifo_prog_empty_pkt_tx)
/* synthesis syn_black_box black_box_pad_pin="log_clk,log_rst,srio_tx_en,srio_rx_en,srio_once_len[7:0],port_initialized,link_initialized,mode_1x,source_id[15:0],dest_id[15:0],device_id[15:0],device_id_set[15:0],id_set_done,m_axis_treq_tvalid,m_axis_treq_tlast,m_axis_treq_tkeep[7:0],m_axis_treq_tready,m_axis_treq_tuser[31:0],m_axis_treq_tdata[63:0],s_axis_tresp_tvalid,s_axis_tresp_tlast,s_axis_tresp_tkeep[7:0],s_axis_tresp_tready,s_axis_tresp_tuser[31:0],s_axis_tresp_tdata[63:0],s_axis_ireq_tvalid,s_axis_ireq_tlast,s_axis_ireq_tkeep[7:0],s_axis_ireq_tready,s_axis_ireq_tuser[31:0],s_axis_ireq_tdata[63:0],m_axis_iresp_tvalid,m_axis_iresp_tlast,m_axis_iresp_tkeep[7:0],m_axis_iresp_tready,m_axis_iresp_tuser[31:0],m_axis_iresp_tdata[63:0],s_axi_maintr_awvalid,s_axi_maintr_awready,s_axi_maintr_awaddr[31:0],s_axi_maintr_wvalid,s_axi_maintr_wready,s_axi_maintr_wdata[31:0],s_axi_maintr_bvalid,s_axi_maintr_bready,s_axi_maintr_bresp[1:0],s_axi_maintr_arvalid,s_axi_maintr_arready,s_axi_maintr_araddr[31:0],s_axi_maintr_rvalid,s_axi_maintr_rready,s_axi_maintr_rdata[31:0],s_axi_maintr_rresp[1:0],fifo_wrreq_pkt_rx,fifo_data_pkt_rx[63:0],fifo_prog_full_pkt_rx,fifo_rdreq_pkt_tx,fifo_q_pkt_tx[63:0],fifo_empty_pkt_tx,fifo_prog_empty_pkt_tx" */;
  input log_clk;
  input log_rst;
  input srio_tx_en;
  input srio_rx_en;
  input [7:0]srio_once_len;
  input port_initialized;
  input link_initialized;
  input mode_1x;
  output [15:0]source_id;
  input [15:0]dest_id;
  input [15:0]device_id;
  input [15:0]device_id_set;
  output id_set_done;
  input m_axis_treq_tvalid;
  input m_axis_treq_tlast;
  input [7:0]m_axis_treq_tkeep;
  output m_axis_treq_tready;
  input [31:0]m_axis_treq_tuser;
  input [63:0]m_axis_treq_tdata;
  output s_axis_tresp_tvalid;
  output s_axis_tresp_tlast;
  output [7:0]s_axis_tresp_tkeep;
  input s_axis_tresp_tready;
  output [31:0]s_axis_tresp_tuser;
  output [63:0]s_axis_tresp_tdata;
  output s_axis_ireq_tvalid;
  output s_axis_ireq_tlast;
  output [7:0]s_axis_ireq_tkeep;
  input s_axis_ireq_tready;
  output [31:0]s_axis_ireq_tuser;
  output [63:0]s_axis_ireq_tdata;
  input m_axis_iresp_tvalid;
  input m_axis_iresp_tlast;
  input [7:0]m_axis_iresp_tkeep;
  output m_axis_iresp_tready;
  input [31:0]m_axis_iresp_tuser;
  input [63:0]m_axis_iresp_tdata;
  output s_axi_maintr_awvalid;
  input s_axi_maintr_awready;
  output [31:0]s_axi_maintr_awaddr;
  output s_axi_maintr_wvalid;
  input s_axi_maintr_wready;
  output [31:0]s_axi_maintr_wdata;
  input s_axi_maintr_bvalid;
  output s_axi_maintr_bready;
  input [1:0]s_axi_maintr_bresp;
  output s_axi_maintr_arvalid;
  input s_axi_maintr_arready;
  output [31:0]s_axi_maintr_araddr;
  input s_axi_maintr_rvalid;
  output s_axi_maintr_rready;
  input [31:0]s_axi_maintr_rdata;
  input [1:0]s_axi_maintr_rresp;
  output fifo_wrreq_pkt_rx;
  output [63:0]fifo_data_pkt_rx;
  input fifo_prog_full_pkt_rx;
  output fifo_rdreq_pkt_tx;
  input [63:0]fifo_q_pkt_tx;
  input fifo_empty_pkt_tx;
  input fifo_prog_empty_pkt_tx;
endmodule
