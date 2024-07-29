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

module kq_hp_ctrl(
    input			sys_clk,
	input			rst_n,
	
	input	[47:0]	uplink_ftw,
	input			uplink_ftw_vld,
	input	[47:0]	downlink_ftw,
	input			downlink_ftw_vld,

	output reg	[23:0] 	data_to_write,
	output reg			data_to_write_vld
);
//*************************************************************    

parameter      TIME_WIDTH       =      'd12      ;

 
//************************************************************* 

reg	[47:0]				uplink_ftw_reg;
reg						uplink_ftw_vld_reg;
reg	[47:0]				downlink_ftw_reg;
reg						downlink_ftw_vld_reg;

reg                     uplink_proc_end;
reg                     downlink_proc_end;
reg	[TIME_WIDTH-1:0]	uplink_time;
reg	[TIME_WIDTH-1:0]	downlink_time;

//标识是否进行了相关操作
reg                     uplink_write_flag;
reg                     downlink_write_flag;
reg                     uplink_upgrade_flag;
reg                     downlink_upgrade_flag;

//********************spi write*********************************
//reg [23:0] 	data_to_write;
//reg			data_to_write_vld;

parameter 	WRITE_REG_NUM	=      'd8 ;

reg [2:0]	spi_write_i;

wire [23:0] write_uplink_byte [WRITE_REG_NUM - 1:0];
wire [23:0] write_downlink_byte [WRITE_REG_NUM - 1:0];
wire [23:0]	upgrade_all_byte [1:0];
wire [23:0]	upgrade_uplink_byte [1:0];
wire [23:0]	upgrade_downlink_byte [1:0];


//1.ftw
always @(posedge sys_clk)
begin
	if(!rst_n)
	begin
		uplink_ftw_reg <= 48'd0;
		uplink_ftw_vld_reg <= 0;
	end
	else begin
		if(uplink_ftw_vld)
			begin
			uplink_ftw_reg <= uplink_ftw;
			uplink_ftw_vld_reg <= uplink_ftw_vld;
			end
		else if(uplink_proc_end)
			begin
			uplink_ftw_reg <= 48'd0;
			uplink_ftw_vld_reg <= 0;
			end
		else
			begin
			uplink_ftw_reg <= uplink_ftw_reg;
			uplink_ftw_vld_reg <= uplink_ftw_vld_reg;
			end
	end
end

always @(posedge sys_clk)
begin
	if(!rst_n)
	begin
		downlink_ftw_reg <= 48'd0;
		downlink_ftw_vld_reg <= 0;
	end
	else begin
		if(downlink_ftw_vld)
			begin
			downlink_ftw_reg <= downlink_ftw;
			downlink_ftw_vld_reg <= downlink_ftw_vld;
			end
		else if(downlink_proc_end)
			begin
			downlink_ftw_reg <= 48'd0;
			downlink_ftw_vld_reg <= 0;
			end
		else
			begin
			downlink_ftw_reg <= downlink_ftw_reg;
			downlink_ftw_vld_reg <= downlink_ftw_vld_reg;
			end
	end
end

assign write_uplink_byte[0] = 24'h000841;
assign write_uplink_byte[1] = 24'h011302;
assign write_uplink_byte[2] = {16'h0114, uplink_ftw_reg[7:0]};
assign write_uplink_byte[3] = {16'h0115, uplink_ftw_reg[15:8]};
assign write_uplink_byte[4] = {16'h0116, uplink_ftw_reg[23:16]};
assign write_uplink_byte[5] = {16'h0117, uplink_ftw_reg[31:24]};
assign write_uplink_byte[6] = {16'h0118, uplink_ftw_reg[39:32]};
assign write_uplink_byte[7] = {16'h0119, uplink_ftw_reg[47:40]};

assign write_downlink_byte[0] = 24'h000882;
assign write_downlink_byte[1] = 24'h011302;
assign write_downlink_byte[2] = {16'h0114, downlink_ftw_reg[7:0]};
assign write_downlink_byte[3] = {16'h0115, downlink_ftw_reg[15:8]};
assign write_downlink_byte[4] = {16'h0116, downlink_ftw_reg[23:16]};
assign write_downlink_byte[5] = {16'h0117, downlink_ftw_reg[31:24]};
assign write_downlink_byte[6] = {16'h0118, downlink_ftw_reg[39:32]};
assign write_downlink_byte[7] = {16'h0119, downlink_ftw_reg[47:40]};

assign upgrade_all_byte[0] = 24'h0008C3;
assign upgrade_all_byte[1] = 24'h011303;
assign upgrade_uplink_byte[0] = 24'h000841;
assign upgrade_uplink_byte[1] = 24'h011303;
assign upgrade_downlink_byte[0] = 24'h000882;
assign upgrade_downlink_byte[1] = 24'h011303;

//2.状态机计时
always @(posedge sys_clk)
begin
	if(!rst_n)
	begin
	uplink_time	<=0;
	end
	else begin
		if(uplink_ftw_vld_reg)
			begin
			uplink_time <= uplink_time + 1;
			end
		else
			begin
			uplink_time <= 0;
			end
	end
end


always @(posedge sys_clk)
begin
	if(!rst_n)
	begin
	downlink_time	<=0;
	end
	else begin
		if(downlink_ftw_vld_reg)
			begin
			downlink_time <= downlink_time + 1;
			end
		else
			begin
			downlink_time = 0;
			end
	end
end

//状态机
parameter IDLE			=7'b0000001;
parameter WRITE_UP		=7'b0000010;
parameter WRITE_DN		=7'b0000100;
parameter UPDATE_ALL	=7'b0001000;
parameter UPDATE_UP		=7'b0010000;
parameter UPDATE_DN		=7'b0100000;
parameter END			=7'b1000000;


reg [6:0] top_state;
reg [9:0] write_uplink_cnt;
reg [9:0] write_downlink_cnt;
reg [7:0] upgrade_all_cnt;
reg [7:0] upgrade_uplink_cnt;
reg [7:0] upgrade_downlink_cnt;


//for sys_clk/spi_clk == 4
parameter CLK_DIV		= 'd2;
parameter WRITE_MID		= 'd650;
parameter UPGRADE_START	= 'd1250;
parameter UPGRADE_NEAR	= 'd1200;

parameter SPICLK_EVERY_BYTE	= 'd28;
parameter WRITE_MAX		= SPICLK_EVERY_BYTE*CLK_DIV*8;		
parameter UPGRADE_MAX	= SPICLK_EVERY_BYTE*CLK_DIV*2;


//状态控制变量
always @(posedge sys_clk)
begin
	if(!rst_n)
		uplink_write_flag	<=0;
	else begin
		if(uplink_time == 1)
			uplink_write_flag <= 1'd1;
		else if(top_state == WRITE_UP)
			uplink_write_flag <= 0;
		else
			uplink_write_flag <= uplink_write_flag;
	end
end

always @(posedge sys_clk)
begin
	if(!rst_n)
		downlink_write_flag	<=0;
	else begin
		if(downlink_time == 1)
			downlink_write_flag <= 1'd1;
		else if(top_state == WRITE_DN)
			downlink_write_flag <= 0;
		else
			downlink_write_flag <= downlink_write_flag;
	end
end

always @(posedge sys_clk)
begin
	if(!rst_n)
		uplink_upgrade_flag	<=0;
	else begin
		if(top_state == WRITE_UP)
			uplink_upgrade_flag <= 1'd1;
		else if((top_state == UPDATE_ALL) || (top_state == UPDATE_UP))
			uplink_upgrade_flag <= 0;
		else
			uplink_upgrade_flag <= uplink_upgrade_flag;
	end
end

always @(posedge sys_clk)
begin
	if(!rst_n)
		downlink_upgrade_flag	<=0;
	else begin
		if(top_state == WRITE_DN)
			downlink_upgrade_flag <= 1'd1;
		else if((top_state == UPDATE_ALL) || (top_state == UPDATE_DN))
			downlink_upgrade_flag <= 0;
		else
			downlink_upgrade_flag <= downlink_upgrade_flag;
	end
end






always @(posedge sys_clk)
begin
if(!rst_n)
    begin
	top_state	<=IDLE;
	write_uplink_cnt <= 0;
	write_downlink_cnt <= 0;
	upgrade_all_cnt <= 0;
	upgrade_uplink_cnt <= 0;
	upgrade_downlink_cnt <= 0;
	uplink_proc_end <= 1'b0;
	downlink_proc_end <= 1'b0;
	end
else
    begin
	case(top_state)
		IDLE:begin
			write_uplink_cnt <= 0;
			write_downlink_cnt <= 0;
			upgrade_all_cnt <= 0;
			upgrade_uplink_cnt <= 0;
			upgrade_downlink_cnt <= 0;
			uplink_proc_end <= 1'b0;
			downlink_proc_end <= 1'b0;
			
			if((uplink_write_flag) && (downlink_time <= WRITE_MID))
				top_state	<=WRITE_UP;
			else if((downlink_write_flag) && (uplink_time <= WRITE_MID))
				top_state	<=WRITE_DN;
			else if((uplink_time > UPGRADE_NEAR) && (downlink_time > UPGRADE_NEAR) && (uplink_upgrade_flag) && (downlink_upgrade_flag))
				top_state	<=UPDATE_ALL;
			else if((uplink_time > UPGRADE_START) && (uplink_upgrade_flag))
				top_state	<=UPDATE_UP;
			else if((downlink_time > UPGRADE_START) && (downlink_upgrade_flag))
				top_state	<=UPDATE_DN;
			else
				top_state	<=IDLE;
		end
		WRITE_UP:begin
			if(write_uplink_cnt == WRITE_MAX)
				top_state	<=END;
			else
				begin
				write_uplink_cnt <= write_uplink_cnt + 1;
				top_state	<=WRITE_UP;
				end
		end
		WRITE_DN:begin
			if(write_downlink_cnt == WRITE_MAX)
				top_state	<=END;
			else
				begin
				write_downlink_cnt <= write_downlink_cnt + 1;
				top_state	<=WRITE_DN;
				end
		end
		UPDATE_ALL:begin
			if(upgrade_all_cnt == UPGRADE_MAX)
				begin
				uplink_proc_end <= 1'b1;
				downlink_proc_end <= 1'b1;
				top_state	<=END;
				end
			else
				begin
				upgrade_all_cnt <= upgrade_all_cnt + 1;
				top_state	<=UPDATE_ALL;
				end
		end
		UPDATE_UP:begin
			if(upgrade_uplink_cnt == UPGRADE_MAX)
				begin
				uplink_proc_end <= 1'b1;
				top_state	<=END;
				end
			else
				begin
				upgrade_uplink_cnt <= upgrade_uplink_cnt + 1;
				top_state	<=UPDATE_UP;
				end
		end
		UPDATE_DN:begin
			if(upgrade_downlink_cnt == UPGRADE_MAX)
				begin
				downlink_proc_end <= 1'b1;
				top_state	<=END;
				end
			else
				begin
				upgrade_downlink_cnt <= upgrade_downlink_cnt + 1;
				top_state	<=UPDATE_DN;
				end
		end
		END:begin
			write_uplink_cnt <= 0;
			write_downlink_cnt <= 0;
			upgrade_all_cnt <= 0;
			upgrade_uplink_cnt <= 0;
			upgrade_downlink_cnt <= 0;
			
			uplink_proc_end <= 1'b0;
			downlink_proc_end <= 1'b0;
			top_state	<=IDLE;
		end
		default:
		  top_state	<=IDLE;
	endcase 	
    end
end



always@(posedge sys_clk)
begin
	if(!rst_n)
	begin  
		spi_write_i		<= 0;
		data_to_write	<= 24'd0;
		data_to_write_vld <= 1'b0;
		
	end
	else begin
		if(top_state == WRITE_UP)
		begin
			if((write_uplink_cnt == SPICLK_EVERY_BYTE*CLK_DIV*spi_write_i) && (spi_write_i < WRITE_REG_NUM))
				begin
				data_to_write <= write_uplink_byte[spi_write_i];
				data_to_write_vld <= 1'b1;
				spi_write_i <= spi_write_i + 1;
				end
			else
				begin
				data_to_write_vld <= 1'b0;
				end
		end
		else if(top_state==WRITE_DN)
		begin
			if((write_downlink_cnt == SPICLK_EVERY_BYTE*CLK_DIV*spi_write_i) && (spi_write_i < WRITE_REG_NUM))
				begin
				data_to_write <= write_downlink_byte[spi_write_i];
				data_to_write_vld <= 1'b1;
				spi_write_i <= spi_write_i + 1;
				end
			else
				begin
				data_to_write_vld <= 1'b0;
				end
		end
		else if(top_state==UPDATE_ALL)
		begin
			if((upgrade_all_cnt == SPICLK_EVERY_BYTE*CLK_DIV*spi_write_i) && (spi_write_i < 2))
				begin
				data_to_write <= upgrade_all_byte[spi_write_i];
				data_to_write_vld <= 1'b1;
				spi_write_i <= spi_write_i + 1;
				end
			else
				begin
				data_to_write_vld <= 1'b0;
				end
		end
		else if(top_state==UPDATE_UP)
		begin
			if((upgrade_uplink_cnt == SPICLK_EVERY_BYTE*CLK_DIV*spi_write_i) && (spi_write_i < 2))
				begin
				data_to_write <= upgrade_uplink_byte[spi_write_i];
				data_to_write_vld <= 1'b1;
				spi_write_i <= spi_write_i + 1;
				end
			else
				begin
				data_to_write_vld <= 1'b0;
				end
		end
		else if(top_state==UPDATE_DN)
		begin
			if((upgrade_downlink_cnt == SPICLK_EVERY_BYTE*CLK_DIV*spi_write_i) && (spi_write_i < 2))
				begin
				data_to_write <= upgrade_downlink_byte[spi_write_i];
				data_to_write_vld <= 1'b1;
				spi_write_i <= spi_write_i + 1;
				end
			else
				begin
				data_to_write_vld <= 1'b0;
				end
		end
		else
		begin
			data_to_write <= 24'd0;
			data_to_write_vld <= 1'b0;
			spi_write_i <= 3'b0;
		end
	end
end

//ila_2 u_ila_kq_hp_ctrl (
//	.clk(sys_clk), // input wire clk


//	.probe0(uplink_ftw_reg), // input wire [47:0]  probe0  
//	.probe1(uplink_ftw_vld_reg), // input wire [0:0]  probe1 
//	.probe2(downlink_ftw_reg), // input wire [47:0]  probe2 
//	.probe3(downlink_ftw_vld_reg), // input wire [0:0]  probe3 
//	.probe4(uplink_proc_end), // input wire [0:0]  probe4 
//	.probe5(downlink_proc_end), // input wire [0:0]  probe5 
//	.probe6(uplink_time), // input wire [11:0]  probe6 
//	.probe7(downlink_time), // input wire [11:0]  probe7 
//	.probe8(top_state), // input wire [6:0]  probe8 
//	.probe9(write_uplink_cnt), // input wire [9:0]  probe9 
//	.probe10(write_downlink_cnt), // input wire [9:0]  probe10 
//	.probe11(upgrade_all_cnt), // input wire [7:0]  probe11 
//	.probe12(upgrade_uplink_cnt), // input wire [7:0]  probe12 
//	.probe13(upgrade_downlink_cnt), // input wire [7:0]  probe13 
//	.probe14(uplink_write_flag), // input wire [0:0]  probe14 
//	.probe15(downlink_write_flag), // input wire [0:0]  probe15 
//	.probe16(uplink_upgrade_flag), // input wire [0:0]  probe16 
//	.probe17(downlink_upgrade_flag) // input wire [0:0]  probe17
//);


endmodule

