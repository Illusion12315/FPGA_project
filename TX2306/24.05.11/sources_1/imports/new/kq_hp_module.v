`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/09 14:48:32
// Design Name: 
// Module Name: kq_hp_module
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


module kq_hp_module(
    input           clk163m84,
    input			hp_clk,
    
	input			rst_n,
	
    input	[31:0]	uplink_freq,
    input			uplink_freq_vld,
    input	[31:0]	downlink_freq,
    input			downlink_freq_vld,

    output  		sclk_spi_hp,
	output 	       	cs_spi_hp,
	output 		    sdo_spi_hp     
    );
 wire               fifo_full_up;
 wire               fifo_full_down;
 wire               fifo_empty_up;
 wire               fifo_empty_down;
 wire               fifo_freq_en_up;
 wire               fifo_freq_en_down;
 wire [31:0]        freq_up_data;
 wire               freq_up_en;
 wire [31:0]        freq_down_data;
 wire               freq_down_en;
 
 assign fifo_freq_en_up = uplink_freq_vld && !fifo_full_up;
 assign fifo_freq_en_down = downlink_freq_vld && !fifo_full_down;
// assign fifo_din={uplink_freq_vld,uplink_freq,downlink_freq_vld,downlink_freq};
 assign freq_up_en = !fifo_empty_up;
 assign freq_down_en = !fifo_empty_down;
 
  fifo_hp fifo_hp_up_inst (
  .rst(!rst_n),        // input wire rst
  .wr_clk(clk163m84),  // input wire wr_clk
  .rd_clk(hp_clk),  // input wire rd_clk
  .din(uplink_freq),        // input wire [31 : 0] din
  .wr_en(fifo_freq_en_up),    // input wire wr_en
  .rd_en(freq_up_en),    // input wire rd_en
  .dout(freq_up_data),      // output wire [31 : 0] dout
  .full(fifo_full_up),      // output wire full
  .empty(fifo_empty_up)    // output wire empty
);

  fifo_hp fifo_hp_down_inst (
  .rst(!rst_n),        // input wire rst
  .wr_clk(clk163m84),  // input wire wr_clk
  .rd_clk(hp_clk),  // input wire rd_clk
  .din(downlink_freq),        // input wire [31 : 0] din
  .wr_en(fifo_freq_en_down),    // input wire wr_en
  .rd_en(freq_down_en),    // input wire rd_en
  .dout(freq_down_data),      // output wire [31 : 0] dout
  .full(fifo_full_down),      // output wire full
  .empty(fifo_empty_down)    // output wire empty
);
  
  
//-------------------------------------  
    wire    hp_rst_n;
xpm_cdc_single #(
   .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
   .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
)
xpm_cdc_single_inst (
   .dest_out(hp_rst_n), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                        // registered.

   .dest_clk(hp_clk), // 1-bit input: Clock signal for the destination clock domain.
   .src_clk(clk163m84),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
   .src_in(rst_n)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
);

    kq_hp_drv U_kq_hp_drv
(
	.sys_clk(hp_clk),
	.rst_n   (hp_rst_n),
	.uplink_freq(freq_up_data),
	.uplink_freq_vld(freq_up_en),
	.downlink_freq(freq_down_data),
	.downlink_freq_vld(freq_down_en),
	.sclk_spi_hp(sclk_spi_hp),
	.cs_spi_hp(cs_spi_hp),
	.sdo_spi_hp(sdo_spi_hp)
); 

reg [31:0] freq_up_data_reg;
always @(posedge hp_clk or negedge hp_rst_n) begin
    if(!hp_rst_n) begin
        freq_up_data_reg <= 'b0;
    end
    else begin
        freq_up_data_reg <= freq_up_data;
    end
end
reg [7:0] same_cnt;
always @(posedge hp_clk or negedge hp_rst_n) begin
    if(!hp_rst_n) begin
        same_cnt <= 'b0;
    end
    else if(freq_up_en) begin
        if(freq_up_data_reg == freq_up_data) begin
            same_cnt <= same_cnt + 'b1;
        end
        else begin
            same_cnt <= 'b0;
        end
    end
end

reg [23:0]  cnt_50us = 0;
always @(posedge hp_clk) begin
    if(freq_up_en) begin
        cnt_50us <= 'b0;
    end
    else begin
        cnt_50us <= cnt_50us + 'b1;
    end
end
reg         freq_switch;
always @(posedge hp_clk or negedge hp_rst_n) begin
    if(!hp_rst_n) begin
        freq_switch <= 'b0; 
    end
    else if(freq_up_data_reg != freq_up_data) begin
        freq_switch <= 'b1; 
    end
    else begin
        freq_switch <= 'b0; 
    end
end
reg         freq_up_en_reg;
always @(posedge hp_clk or negedge hp_rst_n) begin
    if(!hp_rst_n) begin
        freq_up_en_reg <= 'b0; 
    end 
    else begin
        freq_up_en_reg <= freq_up_en; 
    end
end

//ila_fifo_out u_ila_fifo_out (
//	.clk(hp_clk),              // input wire clk
//	.probe0(freq_up_data),     // input wire [31:0]  probe0  
//	.probe1(freq_up_data_reg), // input wire [31:0]  probe1 
//	.probe2(freq_down_data),   // input wire [31:0]  probe2 
//	.probe3(freq_down_en),     // input wire [0:0]  probe3 
//	.probe4(freq_up_en),       // input wire [0:0]  probe4 
//	.probe5(freq_up_en_reg),   // input wire [0:0]  probe5 
//	.probe6(freq_switch)       // input wire [0:0]  probe6
//);

endmodule
