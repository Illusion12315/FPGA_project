`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/29 13:51:07
// Design Name: 
// Module Name: lvds_tx
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


module lvds_tx(
    input   wire        clk163m84       ,
    input   wire        clk100m         ,
    
    input   wire        rst_n_100m      ,
    input   wire        rst_n_163m84    ,
//    input   wire[7:0]   down_gear       ,
    
//    input   wire[7:0]   data_in         ,
//    input   wire        data_en         ,
    
    input   wire        i_DecScr_vld    ,
    input   wire[7:0]   i_DecScr_Data   ,
    input   wire[7:0]   i_DL_GearEverySlot,
    input   wire[7:0]   i_ldpc_cnt      ,
    input   wire[7:0]   i_slottimesw_cnt,
    
    input   wire        config_vld      ,
    input   wire[7:0]   config_data     ,
        
    output  wire[7:0]   txdata          ,
    output  wire        txen            ,
    output  wire[15:0]  data_len        ,
    output  wire        len_en          ,
    
    output  wire        o_p2s_rstn
);  
//    wire[7:0]   data_out;
//    wire        data_valid;
    
//    wire[7:0]   w_lvds_data;
//    wire        w_lvds_data_vld; 
    
// dem_data dem_data_inst(
//        .clk163m84          (clk163m84),
//        .clk100m            (clk100m  ),
    
//        .rst_n              (rst_n    ),
//        .down_gear          (down_gear),
        
//        .data_in            ('b0      ),
//        .data_en            ('b0      ),
        
////        .data_out           (data_out),
////        .data_valid         (data_valid),
        
//        .o_p2s_rstn         (o_p2s_rstn)
//    );
    
    wire        config_vld_100m;
    wire[7:0]   config_data_100m;
    wire        empty;
assign config_vld_100m = !empty;
fifo_163m84to100 fifo_163m84to100_inst (
//  .rst(!rst_n),        // input wire rst
  .wr_clk(clk163m84),  // input wire wr_clk
  .wr_en(config_vld),    // input wire wr_en
  .din(config_data),        // input wire [7 : 0] din
  .full(),      // output wire full
  
  .rd_clk(clk100m),  // input wire rd_clk
  .rd_en(config_vld_100m),    // input wire rd_en
  .dout(config_data_100m),      // output wire [7 : 0] dout
  .empty(empty)    // output wire empty
);
    reg         r_DecScr_vld  = 'b0;
    reg [7:0]   r_DecScr_Data = 'b0;
always @(posedge clk163m84) begin
    r_DecScr_vld  <= i_DecScr_vld ;
    r_DecScr_Data <= i_DecScr_Data;
end
    wire        w_FIFO_rden  ;
    wire[7:0]   w_FIFO_Dout  ;
    wire        w_FIFO_Full  ;
    wire        w_FIFO_Empty ;
    wire        w_LDPC_vld   ;
    wire[7:0]   w_LDPC_Data  ;
assign w_FIFO_rden = !w_FIFO_Empty;
assign w_LDPC_vld  = w_FIFO_rden;
assign w_LDPC_Data = w_FIFO_Dout;
FIFO_CDC_DecScrData u_FIFO_CDC_DecScrData (
//    .rst( ),         // input wire rst
    .wr_clk(clk163m84  ),  // input wire wr_clk
    .rd_clk(clk100m    ),  // input wire rd_clk
    .din(r_DecScr_Data ),  // input wire [7 : 0] din
    .wr_en(r_DecScr_vld),  // input wire wr_en
    .rd_en(w_FIFO_rden ),  // input wire rd_en
    .dout(w_FIFO_Dout  ),  // output wire [7 : 0] dout
    .full(w_FIFO_Full  ),  // output wire full
    .empty(w_FIFO_Empty)  // output wire empty
);

 downlink_parse u_downlink_parse(
	.clk100m                   (clk100m),
	.clk163m84                 (clk163m84),
    .rst_n_100m                (rst_n_100m),
    .rst_n_163m84              (rst_n_163m84),
	
	.ldpc_vld                  (w_LDPC_vld ),
	.ldpc_data                 (w_LDPC_Data),
	
	//clk with 163.84MHz. need hold until ldpc finish.
	.i_DL_GearEverySlot        (i_DL_GearEverySlot),
	.i_slottimesw_cnt          (i_slottimesw_cnt),	
	.i_ldpc_cnt                (i_ldpc_cnt),
	
	.config_vld                (config_vld_100m),
	.config_data               (config_data_100m),
    
	.lvds_data                 (txdata),
	.lvds_data_vld             (txen),
	.lvds_data_len             (data_len),
	.lvds_len_vld              (len_en),
    
    .o_p2s_rstn                (o_p2s_rstn)
    );
endmodule
