`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/06 19:40:45
// Design Name: 
// Module Name: blk2711_fsm
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

module bk2711_clk_rst

    (
    input                               clk_100m                   ,
    
    output             [   4:0]         OE                         ,
    output                              GTX_CLK                    ,
    input                               RX_CLK                     ,
    output                              rx_100m                    ,
    output                              rx_200m                    ,
    output                              rxclk_locked               ,

    output reg                          rx_reset_n                  
);

reg                    [  31:0]         rx_rst_cnt        =   32'd0;

    parameter                           time_1s           =   32'd100_000_000;
//---------------------------------------------------------------------
// assign
//---------------------------------------------------------------------    
assign       OE         =   5'b01000;
                //
assign      GTX_CLK     =  ~clk_100m;
//---------------------------------------------------------------------
// clk_rx
//---------------------------------------------------------------------      
//  
  clk_rx clk_rx
 (
  // Clock out ports
    .clk_out1                          (rx_100m                   ),// output clk_out1
    .clk_out2                          (rx_200m                   ),// output clk_out2
  // Status and control signals
    .reset                             (1'b0                      ),// input reset
    .locked                            (rxclk_locked              ),// output locked
 // Clock in ports
    .clk_in1                           (RX_CLK                    ) // input clk_in1  
  );
        
//---------------------------------------------------------------------  
//  Ω” ’∂À∏¥Œª
//---------------------------------------------------------------------  
always@(posedge rx_100m or negedge rxclk_locked) begin
    if(!rxclk_locked) begin
        rx_reset_n   <= 1'b0;
        rx_rst_cnt   <= 32'd0;
    end
    else if(rx_rst_cnt >= time_1s- 1'd1) begin
        rx_reset_n <= 1'b1;
        rx_rst_cnt <= rx_rst_cnt;
    end
    else begin
        rx_reset_n  <= 1'b0;
        rx_rst_cnt  <= rx_rst_cnt+ 32'd1;
    end
end
                    
  
endmodule
