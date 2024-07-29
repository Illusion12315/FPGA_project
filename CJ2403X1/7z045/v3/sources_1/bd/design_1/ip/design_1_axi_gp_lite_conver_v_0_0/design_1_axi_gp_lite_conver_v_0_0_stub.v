// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Jul 11 21:17:58 2024
// Host        : WIN-4RTIEJNT4N5 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               g:/GitDir/CJ2403X1/03_Sys_Code/01_PZ_Z7/cfg_7z045_topV1.2/cfg_7z045_top.srcs/sources_1/bd/design_1/ip/design_1_axi_gp_lite_conver_v_0_0/design_1_axi_gp_lite_conver_v_0_0_stub.v
// Design      : design_1_axi_gp_lite_conver_v_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z045ffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "axi_gp_lite_conver_v1_0,Vivado 2018.3" *)
module design_1_axi_gp_lite_conver_v_0_0(slv_reg_rden, axi_araddr, S_AXI_RDATA_ext, 
  slv_reg_wren, axi_awaddr, S_AXI_WDATA_ext, s00_axi_aclk, s00_axi_aresetn, s00_axi_awaddr, 
  s00_axi_awprot, s00_axi_awvalid, s00_axi_awready, s00_axi_wdata, s00_axi_wstrb, 
  s00_axi_wvalid, s00_axi_wready, s00_axi_bresp, s00_axi_bvalid, s00_axi_bready, 
  s00_axi_araddr, s00_axi_arprot, s00_axi_arvalid, s00_axi_arready, s00_axi_rdata, 
  s00_axi_rresp, s00_axi_rvalid, s00_axi_rready)
/* synthesis syn_black_box black_box_pad_pin="slv_reg_rden,axi_araddr[31:0],S_AXI_RDATA_ext[31:0],slv_reg_wren,axi_awaddr[31:0],S_AXI_WDATA_ext[31:0],s00_axi_aclk,s00_axi_aresetn,s00_axi_awaddr[31:0],s00_axi_awprot[2:0],s00_axi_awvalid,s00_axi_awready,s00_axi_wdata[31:0],s00_axi_wstrb[3:0],s00_axi_wvalid,s00_axi_wready,s00_axi_bresp[1:0],s00_axi_bvalid,s00_axi_bready,s00_axi_araddr[31:0],s00_axi_arprot[2:0],s00_axi_arvalid,s00_axi_arready,s00_axi_rdata[31:0],s00_axi_rresp[1:0],s00_axi_rvalid,s00_axi_rready" */;
  output slv_reg_rden;
  output [31:0]axi_araddr;
  input [31:0]S_AXI_RDATA_ext;
  output slv_reg_wren;
  output [31:0]axi_awaddr;
  output [31:0]S_AXI_WDATA_ext;
  input s00_axi_aclk;
  input s00_axi_aresetn;
  input [31:0]s00_axi_awaddr;
  input [2:0]s00_axi_awprot;
  input s00_axi_awvalid;
  output s00_axi_awready;
  input [31:0]s00_axi_wdata;
  input [3:0]s00_axi_wstrb;
  input s00_axi_wvalid;
  output s00_axi_wready;
  output [1:0]s00_axi_bresp;
  output s00_axi_bvalid;
  input s00_axi_bready;
  input [31:0]s00_axi_araddr;
  input [2:0]s00_axi_arprot;
  input s00_axi_arvalid;
  output s00_axi_arready;
  output [31:0]s00_axi_rdata;
  output [1:0]s00_axi_rresp;
  output s00_axi_rvalid;
  input s00_axi_rready;
endmodule
