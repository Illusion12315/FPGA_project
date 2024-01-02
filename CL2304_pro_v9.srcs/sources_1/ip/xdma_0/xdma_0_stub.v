// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Nov 23 23:07:12 2023
// Host        : chenxiongzhi running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               H:/FPGA/CL2304_pro_v9/CL2304_pro_v9.srcs/sources_1/ip/xdma_0/xdma_0_stub.v
// Design      : xdma_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1927-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "xdma_0_core_top,Vivado 2018.3" *)
module xdma_0(sys_clk, sys_rst_n, user_lnk_up, pci_exp_txp, 
  pci_exp_txn, pci_exp_rxp, pci_exp_rxn, axi_aclk, axi_aresetn, usr_irq_req, usr_irq_ack, 
  msi_enable, msi_vector_width, m_axil_awaddr, m_axil_awprot, m_axil_awvalid, m_axil_awready, 
  m_axil_wdata, m_axil_wstrb, m_axil_wvalid, m_axil_wready, m_axil_bvalid, m_axil_bresp, 
  m_axil_bready, m_axil_araddr, m_axil_arprot, m_axil_arvalid, m_axil_arready, m_axil_rdata, 
  m_axil_rresp, m_axil_rvalid, m_axil_rready, s_axis_c2h_tdata_0, s_axis_c2h_tlast_0, 
  s_axis_c2h_tvalid_0, s_axis_c2h_tready_0, s_axis_c2h_tkeep_0, m_axis_h2c_tdata_0, 
  m_axis_h2c_tlast_0, m_axis_h2c_tvalid_0, m_axis_h2c_tready_0, m_axis_h2c_tkeep_0, 
  s_axis_c2h_tdata_1, s_axis_c2h_tlast_1, s_axis_c2h_tvalid_1, s_axis_c2h_tready_1, 
  s_axis_c2h_tkeep_1, m_axis_h2c_tdata_1, m_axis_h2c_tlast_1, m_axis_h2c_tvalid_1, 
  m_axis_h2c_tready_1, m_axis_h2c_tkeep_1, s_axis_c2h_tdata_2, s_axis_c2h_tlast_2, 
  s_axis_c2h_tvalid_2, s_axis_c2h_tready_2, s_axis_c2h_tkeep_2, m_axis_h2c_tdata_2, 
  m_axis_h2c_tlast_2, m_axis_h2c_tvalid_2, m_axis_h2c_tready_2, m_axis_h2c_tkeep_2, 
  s_axis_c2h_tdata_3, s_axis_c2h_tlast_3, s_axis_c2h_tvalid_3, s_axis_c2h_tready_3, 
  s_axis_c2h_tkeep_3, m_axis_h2c_tdata_3, m_axis_h2c_tlast_3, m_axis_h2c_tvalid_3, 
  m_axis_h2c_tready_3, m_axis_h2c_tkeep_3)
/* synthesis syn_black_box black_box_pad_pin="sys_clk,sys_rst_n,user_lnk_up,pci_exp_txp[7:0],pci_exp_txn[7:0],pci_exp_rxp[7:0],pci_exp_rxn[7:0],axi_aclk,axi_aresetn,usr_irq_req[0:0],usr_irq_ack[0:0],msi_enable,msi_vector_width[2:0],m_axil_awaddr[31:0],m_axil_awprot[2:0],m_axil_awvalid,m_axil_awready,m_axil_wdata[31:0],m_axil_wstrb[3:0],m_axil_wvalid,m_axil_wready,m_axil_bvalid,m_axil_bresp[1:0],m_axil_bready,m_axil_araddr[31:0],m_axil_arprot[2:0],m_axil_arvalid,m_axil_arready,m_axil_rdata[31:0],m_axil_rresp[1:0],m_axil_rvalid,m_axil_rready,s_axis_c2h_tdata_0[255:0],s_axis_c2h_tlast_0,s_axis_c2h_tvalid_0,s_axis_c2h_tready_0,s_axis_c2h_tkeep_0[31:0],m_axis_h2c_tdata_0[255:0],m_axis_h2c_tlast_0,m_axis_h2c_tvalid_0,m_axis_h2c_tready_0,m_axis_h2c_tkeep_0[31:0],s_axis_c2h_tdata_1[255:0],s_axis_c2h_tlast_1,s_axis_c2h_tvalid_1,s_axis_c2h_tready_1,s_axis_c2h_tkeep_1[31:0],m_axis_h2c_tdata_1[255:0],m_axis_h2c_tlast_1,m_axis_h2c_tvalid_1,m_axis_h2c_tready_1,m_axis_h2c_tkeep_1[31:0],s_axis_c2h_tdata_2[255:0],s_axis_c2h_tlast_2,s_axis_c2h_tvalid_2,s_axis_c2h_tready_2,s_axis_c2h_tkeep_2[31:0],m_axis_h2c_tdata_2[255:0],m_axis_h2c_tlast_2,m_axis_h2c_tvalid_2,m_axis_h2c_tready_2,m_axis_h2c_tkeep_2[31:0],s_axis_c2h_tdata_3[255:0],s_axis_c2h_tlast_3,s_axis_c2h_tvalid_3,s_axis_c2h_tready_3,s_axis_c2h_tkeep_3[31:0],m_axis_h2c_tdata_3[255:0],m_axis_h2c_tlast_3,m_axis_h2c_tvalid_3,m_axis_h2c_tready_3,m_axis_h2c_tkeep_3[31:0]" */;
  input sys_clk;
  input sys_rst_n;
  output user_lnk_up;
  output [7:0]pci_exp_txp;
  output [7:0]pci_exp_txn;
  input [7:0]pci_exp_rxp;
  input [7:0]pci_exp_rxn;
  output axi_aclk;
  output axi_aresetn;
  input [0:0]usr_irq_req;
  output [0:0]usr_irq_ack;
  output msi_enable;
  output [2:0]msi_vector_width;
  output [31:0]m_axil_awaddr;
  output [2:0]m_axil_awprot;
  output m_axil_awvalid;
  input m_axil_awready;
  output [31:0]m_axil_wdata;
  output [3:0]m_axil_wstrb;
  output m_axil_wvalid;
  input m_axil_wready;
  input m_axil_bvalid;
  input [1:0]m_axil_bresp;
  output m_axil_bready;
  output [31:0]m_axil_araddr;
  output [2:0]m_axil_arprot;
  output m_axil_arvalid;
  input m_axil_arready;
  input [31:0]m_axil_rdata;
  input [1:0]m_axil_rresp;
  input m_axil_rvalid;
  output m_axil_rready;
  input [255:0]s_axis_c2h_tdata_0;
  input s_axis_c2h_tlast_0;
  input s_axis_c2h_tvalid_0;
  output s_axis_c2h_tready_0;
  input [31:0]s_axis_c2h_tkeep_0;
  output [255:0]m_axis_h2c_tdata_0;
  output m_axis_h2c_tlast_0;
  output m_axis_h2c_tvalid_0;
  input m_axis_h2c_tready_0;
  output [31:0]m_axis_h2c_tkeep_0;
  input [255:0]s_axis_c2h_tdata_1;
  input s_axis_c2h_tlast_1;
  input s_axis_c2h_tvalid_1;
  output s_axis_c2h_tready_1;
  input [31:0]s_axis_c2h_tkeep_1;
  output [255:0]m_axis_h2c_tdata_1;
  output m_axis_h2c_tlast_1;
  output m_axis_h2c_tvalid_1;
  input m_axis_h2c_tready_1;
  output [31:0]m_axis_h2c_tkeep_1;
  input [255:0]s_axis_c2h_tdata_2;
  input s_axis_c2h_tlast_2;
  input s_axis_c2h_tvalid_2;
  output s_axis_c2h_tready_2;
  input [31:0]s_axis_c2h_tkeep_2;
  output [255:0]m_axis_h2c_tdata_2;
  output m_axis_h2c_tlast_2;
  output m_axis_h2c_tvalid_2;
  input m_axis_h2c_tready_2;
  output [31:0]m_axis_h2c_tkeep_2;
  input [255:0]s_axis_c2h_tdata_3;
  input s_axis_c2h_tlast_3;
  input s_axis_c2h_tvalid_3;
  output s_axis_c2h_tready_3;
  input [31:0]s_axis_c2h_tkeep_3;
  output [255:0]m_axis_h2c_tdata_3;
  output m_axis_h2c_tlast_3;
  output m_axis_h2c_tvalid_3;
  input m_axis_h2c_tready_3;
  output [31:0]m_axis_h2c_tkeep_3;
endmodule
