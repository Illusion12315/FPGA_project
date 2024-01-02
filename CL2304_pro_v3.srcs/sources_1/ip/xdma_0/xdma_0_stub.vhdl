-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Sat Oct  7 16:12:14 2023
-- Host        : DESKTOP-Q7D4HV3 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/Users/Administrator/Desktop/project/CL2304/pcie_test/pcie_test.srcs/sources_1/ip/xdma_0/xdma_0_stub.vhdl
-- Design      : xdma_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7vx690tffg1927-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xdma_0 is
  Port ( 
    sys_clk : in STD_LOGIC;
    sys_rst_n : in STD_LOGIC;
    user_lnk_up : out STD_LOGIC;
    pci_exp_txp : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pci_exp_txn : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pci_exp_rxp : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pci_exp_rxn : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axi_aclk : out STD_LOGIC;
    axi_aresetn : out STD_LOGIC;
    usr_irq_req : in STD_LOGIC_VECTOR ( 0 to 0 );
    usr_irq_ack : out STD_LOGIC_VECTOR ( 0 to 0 );
    msi_enable : out STD_LOGIC;
    msi_vector_width : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axil_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axil_awvalid : out STD_LOGIC;
    m_axil_awready : in STD_LOGIC;
    m_axil_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axil_wvalid : out STD_LOGIC;
    m_axil_wready : in STD_LOGIC;
    m_axil_bvalid : in STD_LOGIC;
    m_axil_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axil_bready : out STD_LOGIC;
    m_axil_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axil_arvalid : out STD_LOGIC;
    m_axil_arready : in STD_LOGIC;
    m_axil_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axil_rvalid : in STD_LOGIC;
    m_axil_rready : out STD_LOGIC;
    s_axis_c2h_tdata_0 : in STD_LOGIC_VECTOR ( 255 downto 0 );
    s_axis_c2h_tlast_0 : in STD_LOGIC;
    s_axis_c2h_tvalid_0 : in STD_LOGIC;
    s_axis_c2h_tready_0 : out STD_LOGIC;
    s_axis_c2h_tkeep_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_h2c_tdata_0 : out STD_LOGIC_VECTOR ( 255 downto 0 );
    m_axis_h2c_tlast_0 : out STD_LOGIC;
    m_axis_h2c_tvalid_0 : out STD_LOGIC;
    m_axis_h2c_tready_0 : in STD_LOGIC;
    m_axis_h2c_tkeep_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_c2h_tdata_1 : in STD_LOGIC_VECTOR ( 255 downto 0 );
    s_axis_c2h_tlast_1 : in STD_LOGIC;
    s_axis_c2h_tvalid_1 : in STD_LOGIC;
    s_axis_c2h_tready_1 : out STD_LOGIC;
    s_axis_c2h_tkeep_1 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_h2c_tdata_1 : out STD_LOGIC_VECTOR ( 255 downto 0 );
    m_axis_h2c_tlast_1 : out STD_LOGIC;
    m_axis_h2c_tvalid_1 : out STD_LOGIC;
    m_axis_h2c_tready_1 : in STD_LOGIC;
    m_axis_h2c_tkeep_1 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_c2h_tdata_2 : in STD_LOGIC_VECTOR ( 255 downto 0 );
    s_axis_c2h_tlast_2 : in STD_LOGIC;
    s_axis_c2h_tvalid_2 : in STD_LOGIC;
    s_axis_c2h_tready_2 : out STD_LOGIC;
    s_axis_c2h_tkeep_2 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_h2c_tdata_2 : out STD_LOGIC_VECTOR ( 255 downto 0 );
    m_axis_h2c_tlast_2 : out STD_LOGIC;
    m_axis_h2c_tvalid_2 : out STD_LOGIC;
    m_axis_h2c_tready_2 : in STD_LOGIC;
    m_axis_h2c_tkeep_2 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_c2h_tdata_3 : in STD_LOGIC_VECTOR ( 255 downto 0 );
    s_axis_c2h_tlast_3 : in STD_LOGIC;
    s_axis_c2h_tvalid_3 : in STD_LOGIC;
    s_axis_c2h_tready_3 : out STD_LOGIC;
    s_axis_c2h_tkeep_3 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_h2c_tdata_3 : out STD_LOGIC_VECTOR ( 255 downto 0 );
    m_axis_h2c_tlast_3 : out STD_LOGIC;
    m_axis_h2c_tvalid_3 : out STD_LOGIC;
    m_axis_h2c_tready_3 : in STD_LOGIC;
    m_axis_h2c_tkeep_3 : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end xdma_0;

architecture stub of xdma_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "sys_clk,sys_rst_n,user_lnk_up,pci_exp_txp[7:0],pci_exp_txn[7:0],pci_exp_rxp[7:0],pci_exp_rxn[7:0],axi_aclk,axi_aresetn,usr_irq_req[0:0],usr_irq_ack[0:0],msi_enable,msi_vector_width[2:0],m_axil_awaddr[31:0],m_axil_awprot[2:0],m_axil_awvalid,m_axil_awready,m_axil_wdata[31:0],m_axil_wstrb[3:0],m_axil_wvalid,m_axil_wready,m_axil_bvalid,m_axil_bresp[1:0],m_axil_bready,m_axil_araddr[31:0],m_axil_arprot[2:0],m_axil_arvalid,m_axil_arready,m_axil_rdata[31:0],m_axil_rresp[1:0],m_axil_rvalid,m_axil_rready,s_axis_c2h_tdata_0[255:0],s_axis_c2h_tlast_0,s_axis_c2h_tvalid_0,s_axis_c2h_tready_0,s_axis_c2h_tkeep_0[31:0],m_axis_h2c_tdata_0[255:0],m_axis_h2c_tlast_0,m_axis_h2c_tvalid_0,m_axis_h2c_tready_0,m_axis_h2c_tkeep_0[31:0],s_axis_c2h_tdata_1[255:0],s_axis_c2h_tlast_1,s_axis_c2h_tvalid_1,s_axis_c2h_tready_1,s_axis_c2h_tkeep_1[31:0],m_axis_h2c_tdata_1[255:0],m_axis_h2c_tlast_1,m_axis_h2c_tvalid_1,m_axis_h2c_tready_1,m_axis_h2c_tkeep_1[31:0],s_axis_c2h_tdata_2[255:0],s_axis_c2h_tlast_2,s_axis_c2h_tvalid_2,s_axis_c2h_tready_2,s_axis_c2h_tkeep_2[31:0],m_axis_h2c_tdata_2[255:0],m_axis_h2c_tlast_2,m_axis_h2c_tvalid_2,m_axis_h2c_tready_2,m_axis_h2c_tkeep_2[31:0],s_axis_c2h_tdata_3[255:0],s_axis_c2h_tlast_3,s_axis_c2h_tvalid_3,s_axis_c2h_tready_3,s_axis_c2h_tkeep_3[31:0],m_axis_h2c_tdata_3[255:0],m_axis_h2c_tlast_3,m_axis_h2c_tvalid_3,m_axis_h2c_tready_3,m_axis_h2c_tkeep_3[31:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "xdma_0_core_top,Vivado 2018.3";
begin
end;
