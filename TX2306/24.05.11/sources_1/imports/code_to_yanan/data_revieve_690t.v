`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2023 06:54:01 PM
// Design Name: 
// Module Name: receive_fifo
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


module receive_fifo(
    clk_out,         
    clk_100m,  
    rst_n,     
    data_out_tmp_2d ,
    data_out        
    );
    
    
 input   clk_out;
 input   clk_100m;
 input   rst_n;
 input [3:0]  data_out_tmp_2d;
 output [3:0] data_out;
  wire  empty;
 wire  full;
 wire   vld_in;
 reg   empty_d1;
 wire [3:0]dout;
 wire empty_1;
 reg   rd_en;
 reg   rd_en_d1;
 
 
assign vld_in=data_out_tmp_2d[3];
// assign empty_1= !empty;

always@(posedge clk_100m)begin
   rd_en <= !empty;
   rd_en_d1 <= rd_en;
  end
  
  
assign data_out={rd_en_d1,2'd0,dout[0]};

   
FIFO_4X1024_4X1024 U_FIFO_4X1024_4X1024 (
  .rst(!rst_n),                  // input wire rst
  .wr_clk(clk_out),            // input wire wr_clk
  .rd_clk(clk_100m),            // input wire rd_clk
  .din(data_out_tmp_2d),                  // input wire [3 : 0] din
  .wr_en(vld_in),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(dout),                // output wire [3 : 0] dout
  .full(full),                // output wire full
  .empty(empty),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);
   

 /*
  ILA_RECEIVE_FIFO   U_ILA_RECEIVE_FIFO_IN   (
                            .clk        ( clk_out                  ), // input wire clk
                           
                            .probe0     ( data_out_tmp_2d          ), // input wire [3:0]  probe0 
                            .probe1     ( vld_in                   ), // input wire [0:0]  probe1 
                            .probe2     ( full                     ) // input wire [0:0]  probe2 
 
 );
 
 
   ILA_RECEIVE_FIFO   U_ILA_RECEIVE_FIFO_OUT   (
                           .clk        ( clk_100m                  ), // input wire clk
                          
                           .probe0     ( data_out          ), // input wire [3:0]  probe0 
                           .probe1     ( empty                   ), // input wire [0:0]  probe1 
                           .probe2     ( rd_en                     ) // input wire [0:0]  probe2 

);
 */   
endmodule
