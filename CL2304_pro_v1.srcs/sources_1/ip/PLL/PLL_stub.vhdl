-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Wed Sep  6 16:04:45 2023
-- Host        : WIN-CQ0NU0JNMTI running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub
--               f:/CL2209/CL2209_BLK2711/CL2209_BLK2711.srcs/sources_1/ip/PLL/PLL_stub.vhdl
-- Design      : PLL
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7vx690tffg1927-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PLL is
  Port ( 
    clk_50m : out STD_LOGIC;
    clk_100m : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1_p : in STD_LOGIC;
    clk_in1_n : in STD_LOGIC
  );

end PLL;

architecture stub of PLL is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_50m,clk_100m,reset,locked,clk_in1_p,clk_in1_n";
begin
end;
