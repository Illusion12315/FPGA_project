`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/11 09:30:01
// Design Name: 
// Module Name: rec_ctrl
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


module rec_ctrl(
    input  wire                         i_clk163m84                ,
    input  wire                         i_clk20m                   ,
    input  wire                         i_rstn                     ,
    input  wire                         i_rst_n                    ,
    
    input  wire                         BCTRL_RX_CLK               ,
    input  wire                         BCTRL_RX_DATA              ,
    input  wire                         BCTRL_RX_EN                ,
     
         
    output wire        [   7: 0]        o_soft_rst_n               ,
    output wire        [   7: 0]        o_FixedFre_or_FreHop_mod   ,
    output wire        [  63: 0]        o_rx_freq                  ,
    output wire        [  31: 0]        o_down_step_freq           ,
    output wire        [  47: 0]        o_init_tod_in              ,
    output wire        [  47: 0]        o_us_ds_para               ,
    output wire        [ 255: 0]        o_ds_timeslot              ,
    output wire        [   7: 0]        o_config                   ,// 0x16
    output wire                         o_config_valid             ,
    output wire        [   7: 0]        o_statistical_info_rst     ,
    output wire        [  31: 0]        o_trans_latency_compens    ,
    output wire        [  31: 0]        o_us_ms_addr_crc           ,
    output wire        [  31: 0]        o_us_fre_offset_compens    ,
    output wire        [ 135: 0]        o_us_sync_en               ,
    output wire        [  23: 0]        o_us_send_choose           ,
    output wire        [ 135: 0]        o_ls_carrier_cfg           ,
    output wire        [ 175: 0]        o_ms_timeslot              ,
    output wire        [ 103: 0]        o_ds_sync_data             ,
    output wire        [  39: 0]        o_ms_ls_status             ,
    output wire        [ 351: 0]        o_ds_statistics            ,
    output wire        [ 415: 0]        o_us_statistics            ,
    output wire        [  31: 0]        o_software_info             
    );
    
    wire               [   7: 0]        n_1to8_out                 ;
    wire                                n_1to8_valid               ;
    wire               [  15: 0]        n_crc_out                  ;
    wire                                n_crc_out_valid            ;
//  wire          n_crc_valid;
  
  
    wire                                fifo_full                  ;
    wire                                fifo_empty                 ;
    wire               [   1: 0]        fifo_in                    ;
    wire               [   1: 0]        fifo_out                   ;
  
    assign                              fifo_in                   = {BCTRL_RX_DATA,BCTRL_RX_EN};
  fifo_MRX fifo_MRX_inst (
    .rst                                (1'b0                      ),// input wire rst
    .wr_clk                             (BCTRL_RX_CLK              ),// input wire wr_clk
    .rd_clk                             (i_clk20m                  ),// input wire rd_clk
    .din                                (fifo_in                   ),// input wire [1 : 0] din
    .wr_en                              (!fifo_full                ),// input wire wr_en
    .rd_en                              (!fifo_empty               ),// input wire rd_en
    .dout                               (fifo_out                  ),// output wire [1 : 0] dout
    .full                               (fifo_full                 ),// output wire full
    .empty                              (fifo_empty                ) // output wire empty
);

//ila_MRX_in ila_MRX_in_inst (
//    .clk                                (BCTRL_RX_CLK              ),// input wire clk


//    .probe0                             (BCTRL_RX_DATA             ),// input wire [0:0]  probe0  
//    .probe1                             (BCTRL_RX_EN               ) // input wire [0:0]  probe1
//);

    reg     r_BCTRL_Data_vld  = 'b0;
    reg     r_BCTRL_Data      = 'b0;
    reg     r1_BCTRL_Data_vld = 'b0;
    reg     r1_BCTRL_Data     = 'b0;
    wire    w_BCTRL_Data_Sel;
    wire    w_BCTRL_Data_vld;
    wire    w_BCTRL_Data    ;
assign w_BCTRL_Data_vld = w_BCTRL_Data_Sel ? r1_BCTRL_Data_vld : fifo_out[0];
assign w_BCTRL_Data     = w_BCTRL_Data_Sel ? r1_BCTRL_Data     : fifo_out[1];
vio_BCTRL u_vio_BCTRL (
    .clk(i_clk20m),                // input wire clk
    .probe_out0(w_BCTRL_Data_Sel)  // output wire [0 : 0] probe_out0
);
//ila_MRX_out ila_MRX_out_inst (
//    .clk                               (i_clk20m          ),// input wire clk
//    .probe0                            (r1_BCTRL_Data_vld ),// input wire [0:0]  probe0  
//    .probe1                            (r1_BCTRL_Data     ),// input wire [0:0]  probe1
//    .probe2                            (fifo_out[0]       ),// input wire [0:0]  probe1
//    .probe3                            (fifo_out[1]       ) // input wire [0:0]  probe1
//);
always @(posedge i_clk20m) begin
    r_BCTRL_Data_vld  <= BCTRL_RX_DATA   ;
    r_BCTRL_Data      <= BCTRL_RX_EN     ;
    r1_BCTRL_Data_vld <= r_BCTRL_Data_vld;
    r1_BCTRL_Data     <= r_BCTRL_Data    ;
end
module1to8 module1to8_inst(
    .i_clk163m84                        (i_clk163m84               ),
    .i_clk20m                           (i_clk20m                  ),
    .i_rstn                             (i_rstn                    ),
    .i_rst_n                            (i_rst_n                   ),
    
    .i_data_in                          (w_BCTRL_Data_vld          ),
    .i_data_en                          (w_BCTRL_Data              ),
    
    .i_data_crc                         (n_crc_out                 ),
    .i_data_crc_valid                   (n_crc_out_valid           ),
    
    .o_1to8_data                        (n_1to8_out                ),
    .o_1to8_valid                       (n_1to8_valid              ),
    
      
    .o_soft_rst_n                       (o_soft_rst_n              ),
    .o_FixedFre_or_FreHop_mod           (o_FixedFre_or_FreHop_mod  ),
    .o_rx_freq                          (o_rx_freq                 ),
    .o_down_step_freq                   (o_down_step_freq          ),
    .o_init_tod_in                      (o_init_tod_in             ),
    .o_us_ds_para                       (o_us_ds_para              ),
    .o_ds_timeslot                      (o_ds_timeslot             ),
    .o_config                           (o_config                  ),
    .o_config_valid                     (o_config_valid            ),
    .o_statistical_info_rst             (o_statistical_info_rst    ),
    .o_trans_latency_compens            (o_trans_latency_compens   ),
    .o_us_ms_addr_crc                   (o_us_ms_addr_crc          ),
    .o_us_fre_offset_compens            (o_us_fre_offset_compens   ),
    .o_us_sync_en                       (o_us_sync_en              ),
    .o_us_send_choose                   (o_us_send_choose          ),
    .o_ls_carrier_cfg                   (o_ls_carrier_cfg          ),
    .o_ms_timeslot                      (o_ms_timeslot             ),
    .o_ds_sync_data                     (o_ds_sync_data            ),
    .o_ms_ls_status                     (o_ms_ls_status            ),
    .o_ds_statistics                    (o_ds_statistics           ),
    .o_us_statistics                    (o_us_statistics           ),
    .o_software_info                    (o_software_info           ) 
    );

 crc16_rec
#(
    .POLYNOMIAL                         (16'h8005                  ),//支持1021,8005
    .INIT_VALUE                         (16'hFFFF                  ) 
)
crc16_rec_inst
(
    .clk_in                             (i_clk163m84               ),
    .rst_n                              (i_rst_n                   ),
//	.start_in	          (!i_rst_n),
//	.start_in	          (!valid_in),
    .data_in                            (n_1to8_out                ),
    .valid_in                           (n_1to8_valid              ),
    .crc_out                            (n_crc_out                 ),
    .crc_out_valid                      (n_crc_out_valid           ) 
	
//	.o_data_crc           (),
//	.o_data_crc_valid     (n_crc_valid)

);





endmodule