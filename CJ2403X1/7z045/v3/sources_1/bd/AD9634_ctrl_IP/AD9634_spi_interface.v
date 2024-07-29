`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/08/12 11:18:58
// Design Name: 
// Module Name: AAD01S040G_spi_interface
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


module AD9634_spi_interface
	#(
		parameter integer NO_OF_CLKS = 10
	)
	(
		input wire [7:0] ADDR_i,
		input wire [15:0] COMMD_i,
		input wire clk_i,
		input wire rst_i,
		input wire MISO_i,
		input wire SPI_send_i,
		output wire RST_o,
		output reg MOSI_o,
		output reg SCLK_o,
		output reg CS_N_o,
		output reg SPI_busy_o,
		output reg [15:0] dout_o
	);

	`ifdef SIMULATION
		localparam idle = "idle";
		localparam write = "write";
		localparam read = "read";
		localparam state_wid_msb = 255;
	`else 
		localparam idle = 8'h0;
		localparam write = 8'h1;
		localparam read = 8'h2;
		localparam state_wid_msb = 7;
	`endif

	reg [state_wid_msb:0] current_state = idle;
	reg [state_wid_msb:0] next_state = idle;

	reg SPI_send_l1;
	reg SPI_send_l2;
	wire pos_SPI_send;
	integer cnt_clks;
	integer cnt_scks;
	localparam integer half_of_clks = NO_OF_CLKS / 2;

	always @(posedge clk_i) begin
		SPI_send_l1 <= SPI_send_i;
		SPI_send_l2 <= SPI_send_l1;
	end
	assign pos_SPI_send = SPI_send_l1 & ~SPI_send_l2;

	assign RST_o = rst_i;

	always @(posedge clk_i or posedge rst_i) begin
		if(rst_i)
			current_state <= idle;
		else
			current_state <= next_state;
	end

	always @(*) begin
		if(rst_i) begin
			next_state <= idle;
		end else begin
			case (current_state)
				idle :
					next_state <= pos_SPI_send ? (ADDR_i[7] ? write : read) : current_state;
				write :
					next_state <= (cnt_scks >= 26) ? idle : current_state;
				read :
					next_state <= (cnt_scks >= 26) ? idle : current_state;
				default :
					next_state <= idle;
			endcase
		end
	end

	always @(posedge clk_i) begin
		case (next_state)
			idle : 
				begin
					MOSI_o <= 'b0;
					SCLK_o <= 'b0;
					CS_N_o <= 'b1;
					SPI_busy_o <= 'b0;
					//dout_o <= 'b0;
					cnt_clks <= 0;
					cnt_scks <= 0;
				end
			write :
				begin
					cnt_clks <= (cnt_clks < NO_OF_CLKS-1) ? cnt_clks + 1 : 0;
					cnt_scks <= (cnt_clks == NO_OF_CLKS-1) ? cnt_scks + 1 : cnt_scks;
					SCLK_o <= (cnt_scks>=1 && cnt_scks<=24)? ((cnt_clks < half_of_clks) ? 'b0 : 'b1) : 'b0;
					CS_N_o <= 'b0;
					SPI_busy_o <= 'b1;
					case (cnt_scks)
						0 : MOSI_o <= 'b0;
						1 : MOSI_o <= ADDR_i[7];
						2 : MOSI_o <= ADDR_i[6];
						3 : MOSI_o <= ADDR_i[5];
						4 : MOSI_o <= ADDR_i[4];
						5 : MOSI_o <= ADDR_i[3];
						6 : MOSI_o <= ADDR_i[2];
						7 : MOSI_o <= ADDR_i[1];
						8 : MOSI_o <= ADDR_i[0];
						9 : MOSI_o <= COMMD_i[15];
						10 : MOSI_o <= COMMD_i[14];
						11 : MOSI_o <= COMMD_i[13];
						12 : MOSI_o <= COMMD_i[12];
						13 : MOSI_o <= COMMD_i[11];
						14 : MOSI_o <= COMMD_i[10];
						15 : MOSI_o <= COMMD_i[9];
						16 : MOSI_o <= COMMD_i[8];
						17 : MOSI_o <= COMMD_i[7];
						18 : MOSI_o <= COMMD_i[6];
						19 : MOSI_o <= COMMD_i[5];
						20 : MOSI_o <= COMMD_i[4];
						21 : MOSI_o <= COMMD_i[3];
						22 : MOSI_o <= COMMD_i[2];
						23 : MOSI_o <= COMMD_i[1];
						24 : MOSI_o <= COMMD_i[0];
						25 : MOSI_o <= 'b0;
					endcase
				end
			read :
				begin
					cnt_clks <= (cnt_clks < NO_OF_CLKS-1) ? cnt_clks + 1 : 0;
					cnt_scks <= (cnt_clks == NO_OF_CLKS-1) ? cnt_scks + 1 : cnt_scks;
					SCLK_o <= (cnt_scks>=1 && cnt_scks<=24)? ((cnt_clks < half_of_clks) ? 'b0 : 'b1) : 'b0;
					CS_N_o <= 'b0;
					SPI_busy_o <= 'b1;
					case (cnt_scks)
						0 : MOSI_o <= 'b0;
						1 : MOSI_o <= ADDR_i[7];
						2 : MOSI_o <= ADDR_i[6];
						3 : MOSI_o <= ADDR_i[5];
						4 : MOSI_o <= ADDR_i[4];
						5 : MOSI_o <= ADDR_i[3];
						6 : MOSI_o <= ADDR_i[2];
						7 : MOSI_o <= ADDR_i[1];
						8 : MOSI_o <= ADDR_i[0];
						default : MOSI_o <= 'b0;
					endcase
					if(cnt_scks<9) begin
						dout_o <= 15'b0;
					end else if(cnt_scks==9) begin
						if(cnt_clks==0) begin
							dout_o[15] <= MISO_i;
						end
					end else if(cnt_scks==10) begin
						if(cnt_clks==0) begin
							dout_o[14] <= MISO_i;
						end
					end else if(cnt_scks==11) begin
						if(cnt_clks==0) begin
							dout_o[13] <= MISO_i;
						end
					end else if(cnt_scks==12) begin
						if(cnt_clks==0) begin
							dout_o[12] <= MISO_i;
						end
					end else if(cnt_scks==13) begin
						if(cnt_clks==0) begin
							dout_o[11] <= MISO_i;
						end
					end else if(cnt_scks==14) begin
						if(cnt_clks==0) begin
							dout_o[10] <= MISO_i;
						end
					end else if(cnt_scks==15) begin
						if(cnt_clks==0) begin
							dout_o[9] <= MISO_i;
						end
					end else if(cnt_scks==16) begin
						if(cnt_clks==0) begin
							dout_o[8] <= MISO_i;
						end
					end else if(cnt_scks==17) begin
						if(cnt_clks==0) begin
							dout_o[7] <= MISO_i;
						end
					end else if(cnt_scks==18) begin
						if(cnt_clks==0) begin
							dout_o[6] <= MISO_i;
						end
					end else if(cnt_scks==19) begin
						if(cnt_clks==0) begin
							dout_o[5] <= MISO_i;
						end
					end else if(cnt_scks==20) begin
						if(cnt_clks==0) begin
							dout_o[4] <= MISO_i;
						end
					end else if(cnt_scks==21) begin
						if(cnt_clks==0) begin
							dout_o[3] <= MISO_i;
						end
					end else if(cnt_scks==22) begin
						if(cnt_clks==0) begin
							dout_o[2] <= MISO_i;
						end
					end else if(cnt_scks==23) begin
						if(cnt_clks==0) begin
							dout_o[1] <= MISO_i;
						end
					end else if(cnt_scks==24) begin
						if(cnt_clks==0) begin
							dout_o[0] <= MISO_i;
						end
					end
				end
			default : /* default */;
		endcase
	end
endmodule
