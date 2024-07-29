`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/14 09:32:50
// Design Name: 
// Module Name: info_clk_convert
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


module info_clk_convert(
    input               clk163m84           ,
    input               clk100m             ,
    input               rst_n_100m          ,
    input               rst_n_163m84        ,
    
    input   [7:0]       i_DL_GearEverySlot  ,
    input   [7:0]       i_slottimesw_cnt    ,   
    input   [7:0]       i_ldpc_cnt          ,
    
    output  [7:0]       o_DL_GearEverySlot  ,
    output  [7:0]       o_slottimesw_id     ,  
    output  [7:0]       o_ldpc_id           ,
    
    output              o_p2s_rstn      

    );
//*************************************************************

wire            s_fifo_en;
wire [23:0]     s_ffio_in;
wire            s_fifo_rd;
wire [23:0]     s_fifo_dout;
wire            s_fifo_empty;
wire            s_fifo_full;

assign s_ffio_in = {i_DL_GearEverySlot, i_slottimesw_cnt, i_ldpc_cnt};
assign s_fifo_en = !s_fifo_full;
assign s_fifo_rd = !s_fifo_empty;

assign o_DL_GearEverySlot = s_fifo_dout[23:16];
assign o_slottimesw_id    = s_fifo_dout[15:8];
assign o_ldpc_id          = s_fifo_dout[7:0];


info_fifo u_info_fifo (
  .rst(!rst_n_163m84),        // input wire rst
  .wr_clk(clk163m84),  // input wire wr_clk
  .rd_clk(clk100m),  // input wire rd_clk
  .din(s_ffio_in),        // input wire [23 : 0] din
  .wr_en(s_fifo_en),    // input wire wr_en
  .rd_en(s_fifo_rd),    // input wire rd_en
  .dout(s_fifo_dout),      // output wire [23 : 0] dout
  .full(s_fifo_full),      // output wire full
  .empty(s_fifo_empty)    // output wire empty
);
    reg [7:0]   r_DL_GearEverySlot ;
    reg [7:0]   r1_DL_GearEverySlot;
    reg [7:0]   r2_DL_GearEverySlot;
    reg         r_p2s_rstn         ;
always @(posedge clk100m)begin
    r_DL_GearEverySlot  <= o_DL_GearEverySlot ;
    r1_DL_GearEverySlot <= r_DL_GearEverySlot ;
    r2_DL_GearEverySlot <= r1_DL_GearEverySlot;
end 
always @(posedge clk100m or negedge rst_n_100m)begin
    if(rst_n_100m == 1'b0)begin
        r_p2s_rstn <= 1'b1;
    end 
    else if(r_DL_GearEverySlot != r2_DL_GearEverySlot)begin
         r_p2s_rstn <= 1'b0;
    end 
    else begin
         r_p2s_rstn <= 1'b1;
    end 
end 
assign o_p2s_rstn = r_p2s_rstn;
endmodule
