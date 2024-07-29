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

module kq_hp_drv(
    input			sys_clk,
	input			rst_n,
	
    input	[31:0]	uplink_freq,
    input			uplink_freq_vld,
    input	[31:0]	downlink_freq,
    input			downlink_freq_vld,

    output  		sclk_spi_hp,
	output 	       	cs_spi_hp,
	output 		    sdo_spi_hp                                   
);
//*************************************************************    

wire	[47:0]	uplink_ftw;
wire			uplink_ftw_vld;
wire	[47:0]	downlink_ftw;
wire			downlink_ftw_vld;

wire [23:0] 	data_to_write;
wire 			data_to_write_vld;




//1.将freq转换成ftw
kq_hp_ftw u_kq_hp_ftw(
	.sys_clk			(sys_clk			),
	.rst_n				(rst_n				),
	.uplink_freq		(uplink_freq		),
	.uplink_freq_vld	(uplink_freq_vld	),
	.downlink_freq		(downlink_freq		),
	.downlink_freq_vld	(downlink_freq_vld	),
	.uplink_ftw			(uplink_ftw		),
	.uplink_ftw_vld		(uplink_ftw_vld	),
	.downlink_ftw		(downlink_ftw		),
	.downlink_ftw_vld	(downlink_ftw_vld	)
);


//2.hp控制
kq_hp_ctrl u_kq_hp_ctrl(
	.sys_clk			(sys_clk			),
	.rst_n				(rst_n				),
	.uplink_ftw			(uplink_ftw		),
	.uplink_ftw_vld		(uplink_ftw_vld	),
	.downlink_ftw		(downlink_ftw		),
	.downlink_ftw_vld	(downlink_ftw_vld	),
	
	.data_to_write		(data_to_write		),
	.data_to_write_vld	(data_to_write_vld	)
);


//3.读写spi
write_spi wirte_spi_hp(
	.clk				(sys_clk			),
	.rst_n				(rst_n				),
	.write_data			(data_to_write		),
	.write_data_valid	(data_to_write_vld  ),
	.sclk_w				(sclk_spi_hp		),
	.write_data_out		(sdo_spi_hp			),
	.csb_w				(cs_spi_hp			),
	.once_end_w    		(					)		
);

//ila_1 u_ila_kq_hp_drv (
//	.clk(sys_clk), // input wire clk
//	.probe0(uplink_freq), // input wire [31:0]  probe0  
//	.probe1(uplink_freq_vld), // input wire [0:0]  probe1 
//	.probe2(downlink_freq), // input wire [31:0]  probe2 
//	.probe3(downlink_freq_vld), // input wire [0:0]  probe3 
//	.probe4(uplink_ftw), // input wire [47:0]  probe4 
//	.probe5(uplink_ftw_vld), // input wire [0:0]  probe5 
//	.probe6(downlink_ftw), // input wire [47:0]  probe6 
//	.probe7(downlink_ftw_vld), // input wire [0:0]  probe7 
//	.probe8(data_to_write), // input wire [23:0]  probe8 
//	.probe9(data_to_write_vld), // input wire [0:0]  probe9 
//	.probe10(sclk_spi_hp), // input wire [0:0]  probe10 
//	.probe11(sdo_spi_hp), // input wire [0:0]  probe11 
//	.probe12(cs_spi_hp) // input wire [0:0]  probe12
//);

endmodule

