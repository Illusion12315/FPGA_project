`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/13 16:10:07
// Design Name: 
// Module Name: frame_parse
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


module frame_check(
    input                   sys_clk,
    input                   rst_n,
    
    input       [7:0]       frame_data_in,
    input                   data_vld_in,
    input       [15:0]      frame_len_in,
    input                   len_vld_in,

    output  reg [7:0]       frame_data_out,
    output  reg             data_vld_out,
    output  reg [15:0]      frame_len_out,
    output  reg             len_vld_out

    );
    
//**************************input proc*********************************** 
reg     [7:0]       frame_data_in_d1;
reg     [7:0]       frame_data_in_d2;
reg                 data_vld_in_d1;
reg                 data_vld_in_d2;
reg     [15:0]      frame_len_reg;

wire    [15:0]      crc_out;
reg     [15:0]      crc_out_d1;
wire                crc_out_vld;
reg                 check_result;    //0: crc ok; 1: crc err
reg                 fifo_out_start;

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        frame_data_in_d1 <= 'd0;
        frame_data_in_d2 <= 'd0;
        data_vld_in_d1 <= 'd0;
        data_vld_in_d2 <= 'd0;
        crc_out_d1 <= 'd0;
    end
    else begin
        frame_data_in_d1 <= frame_data_in;
        frame_data_in_d2 <= frame_data_in_d1;
        data_vld_in_d1 <= data_vld_in;
        data_vld_in_d2 <= data_vld_in_d1;
        crc_out_d1 <= crc_out;
    end
end


crc16_frame bsn_crc16_frame (
  .clk_in           (sys_clk),
  .rst_n            (rst_n),
  .data_in          (frame_data_in_d2), 
  .valid_in         (data_vld_in_d2),
  .crc_out          (crc_out),
  .crc_out_valid    (crc_out_vld)
);

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        check_result <= 'd0;
    end
    else if(data_vld_in && data_vld_in_d1 && data_vld_in_d2) begin
        check_result <= 'd0;
    end
    else if(!data_vld_in && data_vld_in_d1) begin
        if (frame_data_in_d2 != crc_out[15:8]) begin
            check_result <= 'd1;
        end
    end
    else if(!data_vld_in_d1 && data_vld_in_d2) begin
        if (frame_data_in_d2 != crc_out_d1[7:0]) begin
            check_result <= 'd1;
        end
    end
    else begin
        check_result <= check_result;
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        fifo_out_start <= 'd0;
    end
    else if(!data_vld_in_d1 && data_vld_in_d2) begin
        fifo_out_start <= 'd1;
    end
    else begin
        fifo_out_start <= 'd0;
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        frame_len_reg <= 'd0;
    end
    else if(len_vld_in) begin
        frame_len_reg <= frame_len_in;
    end
    else begin
        frame_len_reg <= frame_len_reg;
    end
end

//**************************fifo*********************************** 
reg             fifo_rd_en;
reg             fifo_rd_en_d1;
wire    [7:0]   fifo_dout;
wire            fifo_almost_empty;



frame_check_fifo u_frame_check_fifo (
  .clk(sys_clk),                    // input wire clk
  .rst(!rst_n),                    // input wire rst
  .din(frame_data_in),                    // input wire [7 : 0] din
  .wr_en(data_vld_in),                // input wire wr_en
  .rd_en(fifo_rd_en),                // input wire rd_en
  .dout(fifo_dout),                  // output wire [7 : 0] dout
  .full( ),                  // output wire full
  .empty( ),                // output wire empty
  .almost_empty(fifo_almost_empty),  // output wire almost_empty
  .wr_rst_busy( ),    // output wire wr_rst_busy
  .rd_rst_busy( )    // output wire rd_rst_busy
);

//**************************output proc*********************************** 
reg             len_vld;
reg             len_vld_d1;
reg		[31:0]	frame_cnt;

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        frame_len_out <= 'd0;
        len_vld <= 'd0;
		frame_cnt <= 'd0;
    end
    else if(fifo_out_start && !check_result) begin
        frame_len_out <= frame_len_reg;
        len_vld <= 'd1;
		frame_cnt <= frame_cnt + 1;
    end
    else begin
        frame_len_out <= frame_len_out;
        len_vld <= 'd0;
		frame_cnt <= frame_cnt;
    end
end

//len_vld_out must vld at start of frame, so it is 2 clock later than len_vld
always @(posedge sys_clk)
begin
    if(!rst_n) begin
        len_vld_d1 <= 'd0;
        len_vld_out <= 'd0;
    end
    else begin
        len_vld_d1 <= len_vld;
        len_vld_out <= len_vld_d1;
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        fifo_rd_en <= 'd0;
    end
    else if(fifo_out_start) begin
        fifo_rd_en <= 'd1;
    end
    else if(fifo_almost_empty) begin
        fifo_rd_en <= 'd0;
    end
    else begin
        fifo_rd_en <= fifo_rd_en;
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        fifo_rd_en_d1 <= 'd0;
        frame_data_out <= 'd0;
        data_vld_out <= 'd0;
    end
    else begin
        fifo_rd_en_d1 <= fifo_rd_en;
        if (!check_result) begin
            frame_data_out <= fifo_dout;
            data_vld_out <= fifo_rd_en_d1;
        end
        else begin
            frame_data_out <= 'd0;
            data_vld_out <= 'd0;
        end
    end
end

endmodule
