-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Fri Oct 20 16:04:10 2023
-- Host        : DESKTOP-Q7D4HV3 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/Users/Administrator/Desktop/project/CL2304/CL2304_PCIE_V6/CL2304_PCIE_V6.srcs/sources_1/ip/vio_clk_rst/vio_clk_rst_stub.vhdl
-- Design      : vio_clk_rst
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7vx690tffg1927-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vio_clk_rst is
  Port ( 
    clk : in STD_LOGIC;
    probe_in0 : in STD_LOGIC_VECTOR ( 19 downto 0 );
    probe_in1 : in STD_LOGIC_VECTOR ( 19 downto 0 );
    probe_in2 : in STD_LOGIC_VECTOR ( 19 downto 0 );
    probe_in3 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    probe_in4 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in5 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out1 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    probe_out2 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    probe_out3 : out STD_LOGIC_VECTOR ( 63 downto 0 );
    probe_out4 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out5 : out STD_LOGIC_VECTOR ( 0 to 0 )
  );

end vio_clk_rst;

architecture stub of vio_clk_rst is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe_in0[19:0],probe_in1[19:0],probe_in2[19:0],probe_in3[3:0],probe_in4[0:0],probe_in5[0:0],probe_out0[0:0],probe_out1[3:0],probe_out2[63:0],probe_out3[63:0],probe_out4[0:0],probe_out5[0:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "vio,Vivado 2018.3";
begin
end;
