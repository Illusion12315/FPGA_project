`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2023 15:34:22 
// Design Name: 
// Module Name: kq_hp_drv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module kq_hp_ftw(
    input			sys_clk,
	input			rst_n,
	
    input	[31:0]	uplink_freq,
    input			uplink_freq_vld,
    input	[31:0]	downlink_freq,
    input			downlink_freq_vld,

	output	[47:0]	uplink_ftw,
	output			uplink_ftw_vld,
	output	[47:0]	downlink_ftw,
	output			downlink_ftw_vld                          
);
//*************************************************************    


wire [63:0]     uplink_freq_div;
wire [63:0]     downlink_freq_div;
wire [87:0]     up_div_out;
wire [87:0]     down_div_out;

assign uplink_freq_div = uplink_freq<<31;
assign downlink_freq_div = downlink_freq<<31;

assign uplink_ftw = up_div_out[66:24]<<6;
assign downlink_ftw = down_div_out[66:24]<<6;

div_gen_1 up_div_gen_1 (
  .aclk(sys_clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(1'b1),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(24'd5859375),      // input wire [23 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(uplink_freq_vld),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(uplink_freq_div),    // input wire [63 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(uplink_ftw_vld),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(up_div_out)            // output wire [87 : 0] m_axis_dout_tdata
);

div_gen_1 down_div_gen_1 (
  .aclk(sys_clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(1'b1),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(24'd5859375),      // input wire [23 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(downlink_freq_vld),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(downlink_freq_div),    // input wire [63 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(downlink_ftw_vld),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(down_div_out)            // output wire [87 : 0] m_axis_dout_tdata
);



endmodule

