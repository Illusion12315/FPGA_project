// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Tue Sep 19 20:38:17 2023
// Host        : LIAN running 64-bit major release  (build 9200)
// Command     : write_verilog -mode synth_stub H:/04_EDF_File/xadc/xadc_wrapper.v
// Design      : xadc_wrapper
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module xadc_wrapper(DCLK, RESET, VAUXP, VAUXN, VP, VN, MEASURED_TEMP, 
  MEASURED_VCCINT, MEASURED_VCCAUX, MEASURED_VCCBRAM, MEASURED_AUX0, MEASURED_AUX1, 
  MEASURED_AUX2, MEASURED_AUX3, ALM, CHANNEL, OT, XADC_EOC, XADC_EOS)
/* synthesis syn_black_box black_box_pad_pin="DCLK,RESET,VAUXP[3:0],VAUXN[3:0],VP,VN,MEASURED_TEMP[15:0],MEASURED_VCCINT[15:0],MEASURED_VCCAUX[15:0],MEASURED_VCCBRAM[15:0],MEASURED_AUX0[15:0],MEASURED_AUX1[15:0],MEASURED_AUX2[15:0],MEASURED_AUX3[15:0],ALM[7:0],CHANNEL[4:0],OT,XADC_EOC,XADC_EOS" */;
  input DCLK;
  input RESET;
  input [3:0]VAUXP;
  input [3:0]VAUXN;
  input VP;
  input VN;
  output [15:0]MEASURED_TEMP;
  output [15:0]MEASURED_VCCINT;
  output [15:0]MEASURED_VCCAUX;
  output [15:0]MEASURED_VCCBRAM;
  output [15:0]MEASURED_AUX0;
  output [15:0]MEASURED_AUX1;
  output [15:0]MEASURED_AUX2;
  output [15:0]MEASURED_AUX3;
  output [7:0]ALM;
  output [4:0]CHANNEL;
  output OT;
  output XADC_EOC;
  output XADC_EOS;
endmodule
