// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Jul 11 21:17:58 2024
// Host        : WIN-4RTIEJNT4N5 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode funcsim
//               g:/GitDir/CJ2403X1/03_Sys_Code/01_PZ_Z7/cfg_7z045_topV1.2/cfg_7z045_top.srcs/sources_1/bd/design_1/ip/design_1_axi_gp_lite_conver_v_0_0/design_1_axi_gp_lite_conver_v_0_0_sim_netlist.v
// Design      : design_1_axi_gp_lite_conver_v_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z045ffg900-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_axi_gp_lite_conver_v_0_0,axi_gp_lite_conver_v1_0,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "package_project" *) 
(* X_CORE_INFO = "axi_gp_lite_conver_v1_0,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module design_1_axi_gp_lite_conver_v_0_0
   (slv_reg_rden,
    axi_araddr,
    S_AXI_RDATA_ext,
    slv_reg_wren,
    axi_awaddr,
    S_AXI_WDATA_ext,
    s00_axi_aclk,
    s00_axi_aresetn,
    s00_axi_awaddr,
    s00_axi_awprot,
    s00_axi_awvalid,
    s00_axi_awready,
    s00_axi_wdata,
    s00_axi_wstrb,
    s00_axi_wvalid,
    s00_axi_wready,
    s00_axi_bresp,
    s00_axi_bvalid,
    s00_axi_bready,
    s00_axi_araddr,
    s00_axi_arprot,
    s00_axi_arvalid,
    s00_axi_arready,
    s00_axi_rdata,
    s00_axi_rresp,
    s00_axi_rvalid,
    s00_axi_rready);
  output slv_reg_rden;
  output [31:0]axi_araddr;
  input [31:0]S_AXI_RDATA_ext;
  output slv_reg_wren;
  output [31:0]axi_awaddr;
  output [31:0]S_AXI_WDATA_ext;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s00_axi_aclk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi_aclk, ASSOCIATED_BUSIF s00_axi, ASSOCIATED_RESET s00_axi_aresetn, FREQ_HZ 200000000, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input s00_axi_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s00_axi_aresetn RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input s00_axi_aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWADDR" *) input [31:0]s00_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWPROT" *) input [2:0]s00_axi_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWVALID" *) input s00_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi AWREADY" *) output s00_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WDATA" *) input [31:0]s00_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WSTRB" *) input [3:0]s00_axi_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WVALID" *) input s00_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi WREADY" *) output s00_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi BRESP" *) output [1:0]s00_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi BVALID" *) output s00_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi BREADY" *) input s00_axi_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARADDR" *) input [31:0]s00_axi_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARPROT" *) input [2:0]s00_axi_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARVALID" *) input s00_axi_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi ARREADY" *) output s00_axi_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RDATA" *) output [31:0]s00_axi_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RRESP" *) output [1:0]s00_axi_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RVALID" *) output s00_axi_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi RREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 200000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input s00_axi_rready;

  wire \<const0> ;
  wire [31:0]S_AXI_RDATA_ext;
  wire [31:0]axi_araddr;
  wire [31:0]axi_awaddr;
  wire s00_axi_aclk;
  wire [31:0]s00_axi_araddr;
  wire s00_axi_aresetn;
  wire s00_axi_arready;
  wire s00_axi_arvalid;
  wire [31:0]s00_axi_awaddr;
  wire s00_axi_awready;
  wire s00_axi_awvalid;
  wire s00_axi_bready;
  wire s00_axi_bvalid;
  wire s00_axi_rready;
  wire s00_axi_rvalid;
  wire [31:0]s00_axi_wdata;
  wire s00_axi_wready;
  wire s00_axi_wvalid;
  wire slv_reg_rden;
  wire slv_reg_wren;

  assign S_AXI_WDATA_ext[31:0] = s00_axi_wdata;
  assign s00_axi_bresp[1] = \<const0> ;
  assign s00_axi_bresp[0] = \<const0> ;
  assign s00_axi_rdata[31:0] = S_AXI_RDATA_ext;
  assign s00_axi_rresp[1] = \<const0> ;
  assign s00_axi_rresp[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  design_1_axi_gp_lite_conver_v_0_0_axi_gp_lite_conver_v1_0 inst
       (.S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WREADY(s00_axi_wready),
        .axi_araddr(axi_araddr),
        .axi_awaddr(axi_awaddr),
        .s00_axi_aclk(s00_axi_aclk),
        .s00_axi_araddr(s00_axi_araddr),
        .s00_axi_aresetn(s00_axi_aresetn),
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_awaddr(s00_axi_awaddr),
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_bready(s00_axi_bready),
        .s00_axi_bvalid(s00_axi_bvalid),
        .s00_axi_rready(s00_axi_rready),
        .s00_axi_rvalid(s00_axi_rvalid),
        .s00_axi_wvalid(s00_axi_wvalid),
        .slv_reg_rden(slv_reg_rden),
        .slv_reg_wren(slv_reg_wren));
endmodule

(* ORIG_REF_NAME = "axi_gp_lite_conver_v1_0" *) 
module design_1_axi_gp_lite_conver_v_0_0_axi_gp_lite_conver_v1_0
   (S_AXI_ARREADY,
    axi_araddr,
    S_AXI_AWREADY,
    S_AXI_WREADY,
    axi_awaddr,
    s00_axi_rvalid,
    s00_axi_bvalid,
    slv_reg_rden,
    slv_reg_wren,
    s00_axi_aclk,
    s00_axi_araddr,
    s00_axi_awaddr,
    s00_axi_aresetn,
    s00_axi_arvalid,
    s00_axi_rready,
    s00_axi_wvalid,
    s00_axi_awvalid,
    s00_axi_bready);
  output S_AXI_ARREADY;
  output [31:0]axi_araddr;
  output S_AXI_AWREADY;
  output S_AXI_WREADY;
  output [31:0]axi_awaddr;
  output s00_axi_rvalid;
  output s00_axi_bvalid;
  output slv_reg_rden;
  output slv_reg_wren;
  input s00_axi_aclk;
  input [31:0]s00_axi_araddr;
  input [31:0]s00_axi_awaddr;
  input s00_axi_aresetn;
  input s00_axi_arvalid;
  input s00_axi_rready;
  input s00_axi_wvalid;
  input s00_axi_awvalid;
  input s00_axi_bready;

  wire S_AXI_ARREADY;
  wire S_AXI_AWREADY;
  wire S_AXI_WREADY;
  wire [31:0]axi_araddr;
  wire [31:0]axi_awaddr;
  wire s00_axi_aclk;
  wire [31:0]s00_axi_araddr;
  wire s00_axi_aresetn;
  wire s00_axi_arvalid;
  wire [31:0]s00_axi_awaddr;
  wire s00_axi_awvalid;
  wire s00_axi_bready;
  wire s00_axi_bvalid;
  wire s00_axi_rready;
  wire s00_axi_rvalid;
  wire s00_axi_wvalid;
  wire slv_reg_rden;
  wire slv_reg_wren;

  design_1_axi_gp_lite_conver_v_0_0_axi_gp_lite_conver_v1_0_S00_AXI axi_gp_lite_conver_v1_0_S00_AXI_inst
       (.axi_araddr(axi_araddr),
        .axi_awaddr(axi_awaddr),
        .s00_axi_aclk(s00_axi_aclk),
        .s00_axi_araddr(s00_axi_araddr),
        .s00_axi_aresetn(s00_axi_aresetn),
        .s00_axi_arready(S_AXI_ARREADY),
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_awaddr(s00_axi_awaddr),
        .s00_axi_awready(S_AXI_AWREADY),
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_bready(s00_axi_bready),
        .s00_axi_bvalid(s00_axi_bvalid),
        .s00_axi_rready(s00_axi_rready),
        .s00_axi_rvalid(s00_axi_rvalid),
        .s00_axi_wready(S_AXI_WREADY),
        .s00_axi_wvalid(s00_axi_wvalid),
        .slv_reg_rden(slv_reg_rden),
        .slv_reg_wren(slv_reg_wren));
endmodule

(* ORIG_REF_NAME = "axi_gp_lite_conver_v1_0_S00_AXI" *) 
module design_1_axi_gp_lite_conver_v_0_0_axi_gp_lite_conver_v1_0_S00_AXI
   (s00_axi_arready,
    axi_araddr,
    s00_axi_awready,
    s00_axi_wready,
    axi_awaddr,
    s00_axi_rvalid,
    s00_axi_bvalid,
    slv_reg_rden,
    slv_reg_wren,
    s00_axi_aclk,
    s00_axi_araddr,
    s00_axi_awaddr,
    s00_axi_aresetn,
    s00_axi_arvalid,
    s00_axi_rready,
    s00_axi_wvalid,
    s00_axi_awvalid,
    s00_axi_bready);
  output s00_axi_arready;
  output [31:0]axi_araddr;
  output s00_axi_awready;
  output s00_axi_wready;
  output [31:0]axi_awaddr;
  output s00_axi_rvalid;
  output s00_axi_bvalid;
  output slv_reg_rden;
  output slv_reg_wren;
  input s00_axi_aclk;
  input [31:0]s00_axi_araddr;
  input [31:0]s00_axi_awaddr;
  input s00_axi_aresetn;
  input s00_axi_arvalid;
  input s00_axi_rready;
  input s00_axi_wvalid;
  input s00_axi_awvalid;
  input s00_axi_bready;

  wire [31:0]axi_araddr;
  wire axi_arready0;
  wire [31:0]axi_awaddr;
  wire axi_awready0;
  wire axi_bvalid_i_1_n_0;
  wire axi_rvalid_i_1_n_0;
  wire axi_wready0;
  wire p_0_in;
  wire s00_axi_aclk;
  wire [31:0]s00_axi_araddr;
  wire s00_axi_aresetn;
  wire s00_axi_arready;
  wire s00_axi_arvalid;
  wire [31:0]s00_axi_awaddr;
  wire s00_axi_awready;
  wire s00_axi_awvalid;
  wire s00_axi_bready;
  wire s00_axi_bvalid;
  wire s00_axi_rready;
  wire s00_axi_rvalid;
  wire s00_axi_wready;
  wire s00_axi_wvalid;
  wire slv_reg_rden;
  wire slv_reg_wren;

  LUT1 #(
    .INIT(2'h1)) 
    \axi_araddr[31]_i_1 
       (.I0(s00_axi_aresetn),
        .O(p_0_in));
  LUT2 #(
    .INIT(4'h2)) 
    \axi_araddr[31]_i_2 
       (.I0(s00_axi_arvalid),
        .I1(s00_axi_arready),
        .O(axi_arready0));
  FDRE \axi_araddr_reg[0] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[0]),
        .Q(axi_araddr[0]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[10] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[10]),
        .Q(axi_araddr[10]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[11] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[11]),
        .Q(axi_araddr[11]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[12] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[12]),
        .Q(axi_araddr[12]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[13] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[13]),
        .Q(axi_araddr[13]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[14] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[14]),
        .Q(axi_araddr[14]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[15] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[15]),
        .Q(axi_araddr[15]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[16] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[16]),
        .Q(axi_araddr[16]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[17] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[17]),
        .Q(axi_araddr[17]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[18] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[18]),
        .Q(axi_araddr[18]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[19] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[19]),
        .Q(axi_araddr[19]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[1] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[1]),
        .Q(axi_araddr[1]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[20] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[20]),
        .Q(axi_araddr[20]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[21] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[21]),
        .Q(axi_araddr[21]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[22] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[22]),
        .Q(axi_araddr[22]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[23] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[23]),
        .Q(axi_araddr[23]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[24] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[24]),
        .Q(axi_araddr[24]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[25] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[25]),
        .Q(axi_araddr[25]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[26] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[26]),
        .Q(axi_araddr[26]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[27] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[27]),
        .Q(axi_araddr[27]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[28] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[28]),
        .Q(axi_araddr[28]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[29] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[29]),
        .Q(axi_araddr[29]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[2] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[2]),
        .Q(axi_araddr[2]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[30] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[30]),
        .Q(axi_araddr[30]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[31] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[31]),
        .Q(axi_araddr[31]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[3] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[3]),
        .Q(axi_araddr[3]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[4] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[4]),
        .Q(axi_araddr[4]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[5] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[5]),
        .Q(axi_araddr[5]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[6] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[6]),
        .Q(axi_araddr[6]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[7] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[7]),
        .Q(axi_araddr[7]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[8] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[8]),
        .Q(axi_araddr[8]),
        .R(p_0_in));
  FDRE \axi_araddr_reg[9] 
       (.C(s00_axi_aclk),
        .CE(axi_arready0),
        .D(s00_axi_araddr[9]),
        .Q(axi_araddr[9]),
        .R(p_0_in));
  FDRE axi_arready_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_arready0),
        .Q(s00_axi_arready),
        .R(p_0_in));
  LUT3 #(
    .INIT(8'h08)) 
    \axi_awaddr[31]_i_1 
       (.I0(s00_axi_wvalid),
        .I1(s00_axi_awvalid),
        .I2(s00_axi_awready),
        .O(axi_awready0));
  FDRE \axi_awaddr_reg[0] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[0]),
        .Q(axi_awaddr[0]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[10] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[10]),
        .Q(axi_awaddr[10]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[11] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[11]),
        .Q(axi_awaddr[11]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[12] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[12]),
        .Q(axi_awaddr[12]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[13] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[13]),
        .Q(axi_awaddr[13]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[14] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[14]),
        .Q(axi_awaddr[14]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[15] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[15]),
        .Q(axi_awaddr[15]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[16] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[16]),
        .Q(axi_awaddr[16]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[17] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[17]),
        .Q(axi_awaddr[17]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[18] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[18]),
        .Q(axi_awaddr[18]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[19] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[19]),
        .Q(axi_awaddr[19]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[1] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[1]),
        .Q(axi_awaddr[1]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[20] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[20]),
        .Q(axi_awaddr[20]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[21] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[21]),
        .Q(axi_awaddr[21]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[22] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[22]),
        .Q(axi_awaddr[22]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[23] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[23]),
        .Q(axi_awaddr[23]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[24] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[24]),
        .Q(axi_awaddr[24]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[25] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[25]),
        .Q(axi_awaddr[25]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[26] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[26]),
        .Q(axi_awaddr[26]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[27] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[27]),
        .Q(axi_awaddr[27]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[28] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[28]),
        .Q(axi_awaddr[28]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[29] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[29]),
        .Q(axi_awaddr[29]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[2] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[2]),
        .Q(axi_awaddr[2]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[30] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[30]),
        .Q(axi_awaddr[30]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[31] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[31]),
        .Q(axi_awaddr[31]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[3] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[3]),
        .Q(axi_awaddr[3]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[4] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[4]),
        .Q(axi_awaddr[4]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[5] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[5]),
        .Q(axi_awaddr[5]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[6] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[6]),
        .Q(axi_awaddr[6]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[7] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[7]),
        .Q(axi_awaddr[7]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[8] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[8]),
        .Q(axi_awaddr[8]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[9] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[9]),
        .Q(axi_awaddr[9]),
        .R(p_0_in));
  FDRE axi_awready_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awready0),
        .Q(s00_axi_awready),
        .R(p_0_in));
  LUT6 #(
    .INIT(64'h0000FFFF80008000)) 
    axi_bvalid_i_1
       (.I0(s00_axi_wvalid),
        .I1(s00_axi_awvalid),
        .I2(s00_axi_wready),
        .I3(s00_axi_awready),
        .I4(s00_axi_bready),
        .I5(s00_axi_bvalid),
        .O(axi_bvalid_i_1_n_0));
  FDRE axi_bvalid_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_bvalid_i_1_n_0),
        .Q(s00_axi_bvalid),
        .R(p_0_in));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h08F8)) 
    axi_rvalid_i_1
       (.I0(s00_axi_arvalid),
        .I1(s00_axi_arready),
        .I2(s00_axi_rvalid),
        .I3(s00_axi_rready),
        .O(axi_rvalid_i_1_n_0));
  FDRE axi_rvalid_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_rvalid_i_1_n_0),
        .Q(s00_axi_rvalid),
        .R(p_0_in));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'h08)) 
    axi_wready_i_1
       (.I0(s00_axi_wvalid),
        .I1(s00_axi_awvalid),
        .I2(s00_axi_wready),
        .O(axi_wready0));
  FDRE axi_wready_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_wready0),
        .Q(s00_axi_wready),
        .R(p_0_in));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h20)) 
    slv_reg_rden__0
       (.I0(s00_axi_arready),
        .I1(s00_axi_rvalid),
        .I2(s00_axi_arvalid),
        .O(slv_reg_rden));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    slv_reg_wren_INST_0
       (.I0(s00_axi_awready),
        .I1(s00_axi_wready),
        .I2(s00_axi_wvalid),
        .I3(s00_axi_awvalid),
        .O(slv_reg_wren));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
