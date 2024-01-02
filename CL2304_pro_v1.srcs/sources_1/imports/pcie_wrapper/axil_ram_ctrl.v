// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Thu Aug 24 19:28:42 2023
// Host        : LIAN running 64-bit major release  (build 9200)
// Command     : write_verilog -mode synth_stub H:/04_EDF_File/pcie_axil_ram_ctrl/axil_ram_ctrl.v
// Design      : axil_ram_ctrl
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module axil_ram_ctrl(axi_clk, log_rst_n, m_axil_awaddr, 
  m_axil_awprot, m_axil_awvalid, m_axil_awready, m_axil_wdata, m_axil_wstrb, m_axil_wvalid, 
  m_axil_wready, m_axil_bvalid, m_axil_bresp, m_axil_bready, m_axil_araddr, m_axil_arprot, 
  m_axil_arvalid, m_axil_arready, m_axil_rdata, m_axil_rresp, m_axil_rvalid, m_axil_rready, 
  ram_wren, ram_waddr, ram_wdata, ram_rden, ram_raddr, ram_rdata)
/* synthesis syn_black_box black_box_pad_pin="axi_clk,log_rst_n,m_axil_awaddr[31:0],m_axil_awprot[2:0],m_axil_awvalid,m_axil_awready,m_axil_wdata[31:0],m_axil_wstrb[3:0],m_axil_wvalid,m_axil_wready,m_axil_bvalid,m_axil_bresp[1:0],m_axil_bready,m_axil_araddr[31:0],m_axil_arprot[2:0],m_axil_arvalid,m_axil_arready,m_axil_rdata[31:0],m_axil_rresp[1:0],m_axil_rvalid,m_axil_rready,ram_wren,ram_waddr[31:0],ram_wdata[31:0],ram_rden,ram_raddr[31:0],ram_rdata[31:0]" */;
  input axi_clk;
  input log_rst_n;
  input [31:0]m_axil_awaddr;
  input [2:0]m_axil_awprot;
  input m_axil_awvalid;
  output m_axil_awready;
  input [31:0]m_axil_wdata;
  input [3:0]m_axil_wstrb;
  input m_axil_wvalid;
  output m_axil_wready;
  output m_axil_bvalid;
  output [1:0]m_axil_bresp;
  input m_axil_bready;
  input [31:0]m_axil_araddr;
  input [2:0]m_axil_arprot;
  input m_axil_arvalid;
  output m_axil_arready;
  output [31:0]m_axil_rdata;
  output [1:0]m_axil_rresp;
  output m_axil_rvalid;
  input m_axil_rready;
  output ram_wren;
  output [31:0]ram_waddr;
  output [31:0]ram_wdata;
  output ram_rden;
  output [31:0]ram_raddr;
  input [31:0]ram_rdata;
endmodule
