// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
// Date        : Sun May 19 17:22:37 2024
// Host        : aknw-hdl running 64-bit Ubuntu 22.04.2 LTS
// Command     : write_verilog -mode synth_stub /mnt/Disk02/work/chengxiongzhi/sxandxx.v
// Design      : sxandxx
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module sxandxx(sys_clk, I_ADC_DATA_I, I_ADC_DATA_Q, 
  adc_valid_in, i_UL_Gear, tx_data1_in, tx_data1_valid_in, tx_data2_in, tx_data2_valid_in, 
  rx_freq_in, rx_freq_en_in, tx_freq_in, tx_freq_en_in, o_DAC_DATA_I, o_DAC_DATA_Q, 
  tx_data1_length_out, tx_data1_ask_out, tx_data2_length_out, tx_data2_ask_out, 
  o_UL_Flag40ms, sync_lock2, o_DecScr_valid, o_DecScr_data, o_ldpc_vld_r, o_ldpc_da_r, 
  o_ldpc_cnt, o_slottimesw_cnt, o_DL_GearEverySlot, i_MC_GlobalRst, i_MC_HopMode, 
  i_MC_FreqBase, i_MC_DL_FreqOffset, i_MC_TOD_Initial, i_MC_FH_Param, i_MC_GearEverySlot, 
  i_MC_StatCLR, i_MC_SE_unidt, i_MC_UL_Address, i_MC_UL_FreqOffset, i_MC_UL_Sync_Slot, 
  i_MC_UL_TxDataSet, i_MC_UL_LDR_CarrierSet, i_MC_UL_MDR_SlotSet, i_MC_UL_MDR_GDCtrlSlot, 
  o_MC_DL_SyncInfo, o_MC_DL_StateInfo, o_MC_DL_Statistics, o_MC_UL_Statistics, 
  o_MC_Version)
/* synthesis syn_black_box black_box_pad_pin="sys_clk,I_ADC_DATA_I[15:0],I_ADC_DATA_Q[15:0],adc_valid_in,i_UL_Gear[7:0],tx_data1_in[7:0],tx_data1_valid_in,tx_data2_in[7:0],tx_data2_valid_in,rx_freq_in[31:0],rx_freq_en_in,tx_freq_in[31:0],tx_freq_en_in,o_DAC_DATA_I[15:0],o_DAC_DATA_Q[15:0],tx_data1_length_out[15:0],tx_data1_ask_out,tx_data2_length_out[15:0],tx_data2_ask_out,o_UL_Flag40ms,sync_lock2,o_DecScr_valid,o_DecScr_data[7:0],o_ldpc_vld_r,o_ldpc_da_r[7:0],o_ldpc_cnt[7:0],o_slottimesw_cnt[7:0],o_DL_GearEverySlot[7:0],i_MC_GlobalRst[7:0],i_MC_HopMode[7:0],i_MC_FreqBase[63:0],i_MC_DL_FreqOffset[31:0],i_MC_TOD_Initial[47:0],i_MC_FH_Param[47:0],i_MC_GearEverySlot[255:0],i_MC_StatCLR[7:0],i_MC_SE_unidt[31:0],i_MC_UL_Address[31:0],i_MC_UL_FreqOffset[31:0],i_MC_UL_Sync_Slot[135:0],i_MC_UL_TxDataSet[23:0],i_MC_UL_LDR_CarrierSet[135:0],i_MC_UL_MDR_SlotSet[175:0],i_MC_UL_MDR_GDCtrlSlot,o_MC_DL_SyncInfo[103:0],o_MC_DL_StateInfo[39:0],o_MC_DL_Statistics[255:0],o_MC_UL_Statistics[127:0],o_MC_Version[31:0]" */;
  input sys_clk;
  input [15:0]I_ADC_DATA_I;
  input [15:0]I_ADC_DATA_Q;
  input adc_valid_in;
  input [7:0]i_UL_Gear;
  input [7:0]tx_data1_in;
  input tx_data1_valid_in;
  input [7:0]tx_data2_in;
  input tx_data2_valid_in;
  output [31:0]rx_freq_in;
  output rx_freq_en_in;
  output [31:0]tx_freq_in;
  output tx_freq_en_in;
  output [15:0]o_DAC_DATA_I;
  output [15:0]o_DAC_DATA_Q;
  output [15:0]tx_data1_length_out;
  output tx_data1_ask_out;
  output [15:0]tx_data2_length_out;
  output tx_data2_ask_out;
  output o_UL_Flag40ms;
  output sync_lock2;
  output o_DecScr_valid;
  output [7:0]o_DecScr_data;
  output o_ldpc_vld_r;
  output [7:0]o_ldpc_da_r;
  output [7:0]o_ldpc_cnt;
  output [7:0]o_slottimesw_cnt;
  output [7:0]o_DL_GearEverySlot;
  input [7:0]i_MC_GlobalRst;
  input [7:0]i_MC_HopMode;
  input [63:0]i_MC_FreqBase;
  input [31:0]i_MC_DL_FreqOffset;
  input [47:0]i_MC_TOD_Initial;
  input [47:0]i_MC_FH_Param;
  input [255:0]i_MC_GearEverySlot;
  input [7:0]i_MC_StatCLR;
  input [31:0]i_MC_SE_unidt;
  input [31:0]i_MC_UL_Address;
  input [31:0]i_MC_UL_FreqOffset;
  input [135:0]i_MC_UL_Sync_Slot;
  input [23:0]i_MC_UL_TxDataSet;
  input [135:0]i_MC_UL_LDR_CarrierSet;
  input [175:0]i_MC_UL_MDR_SlotSet;
  input i_MC_UL_MDR_GDCtrlSlot;
  output [103:0]o_MC_DL_SyncInfo;
  output [39:0]o_MC_DL_StateInfo;
  output [255:0]o_MC_DL_Statistics;
  output [127:0]o_MC_UL_Statistics;
  output [31:0]o_MC_Version;
endmodule
