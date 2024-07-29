`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/14 20:49:55
// Design Name: 
// Module Name: tx_ctrl
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


module tx_ctrl(
    input  wire                         clk163m84                  ,
    input  wire                         clk20m                     ,
    input  wire                         rst_n                      ,
    input  wire                         rstn                       ,
    
    input  wire        [   7: 0]        i_para_type                ,

    input              [   7: 0]        info_unit_idenf_i          ,
    
    
    input  wire        [   7: 0]        i_data_in                  ,
    input  wire                         i_data_valid               ,
    
    output wire                         o_data8to1                 ,
    output wire                         o_data8to1_valid            
    );
    
//--------------------------------------
    wire               [   7: 0]        n_data_frame               ;
    wire                                n_frame_valid              ;
    wire               [  15: 0]        n_crc_out                  ;
    wire               [   7: 0]        n_data_crc                 ;
    wire                                n_data_crc_valid           ;
    wire               [   7: 0]        n_crc_fram_out             ;
    wire                                n_crc_fram_valid           ;

tx_data_frame tx_data_frame_inst(
    .i_clk163m84                        (clk163m84                 ),
    .i_rst_n                            (rst_n                     ),
    
    .i_data_in                          (i_data_in                 ),
    .i_data_valid                       (i_data_valid              ),
    
    .i_para_type                        (i_para_type               ),
    
    .o_data_out                         (n_data_frame              ),
    .o_data_valid                       (n_frame_valid             ) 
    );
   
    
 crc16_tx
#(
    .POLYNOMIAL                         (16'h8005                  ),//支持1021,8005
    .INIT_VALUE                         (16'hFFFF                  ) 
)
crc16_tx_inst
(
    .clk_in                             (clk163m84                 ),
    .rst_n                              (rst_n                     ),
	
    .data_in                            (n_data_frame              ),
    .valid_in                           (n_frame_valid             ),
    .crc_out                            (n_crc_out                 ),
    .crc_out_valid                      (                          ),
	
    .o_data_crc                         (n_data_crc                ),
    .o_data_crc_valid                   (n_data_crc_valid          ) 

);

 tx_crc_frame tx_crc_frame_inst(
    .i_clk163m84                        (clk163m84                 ),
    .i_rst_n                            (rst_n                     ),
    
    .i_data_in                          (n_data_crc                ),
    .i_data_valid                       (n_data_crc_valid          ),

    .info_unit_idenf_i                  (info_unit_idenf_i         ),
    
    .o_data_out                         (n_crc_fram_out            ),
    .o_data_valid                       (n_crc_fram_valid          ) 
    );

module8to1 module8to1_inst(
    .clk163m84                          (clk163m84                 ),
    .clk20m                             (clk20m                    ),
    .rst_n                              (rst_n                     ),
    .rstn                               (rstn                      ),
    
    .i_data_in                          (n_crc_fram_out            ),
    .i_data_vald                        (n_crc_fram_valid          ),
    
    .o_data8to1                         (o_data8to1                ),
    .o_data8to1_valid                   (o_data8to1_valid          ) 
    );
    
    
endmodule
