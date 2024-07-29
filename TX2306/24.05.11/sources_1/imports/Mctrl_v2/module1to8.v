`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/21 14:36:59
// Design Name: 
// Module Name: module1to8
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


module module1to8(
    input  wire                         i_clk163m84                ,
    input  wire                         i_clk20m                   ,
    input  wire                         i_rstn                     ,
    input  wire                         i_rst_n                    ,
    
    input  wire                         i_data_in                  ,
    input  wire                         i_data_en                  ,
    input  wire                         i_data_crc_valid           ,
    input  wire        [  15: 0]        i_data_crc                 ,
    
    
    output wire        [   7: 0]        o_1to8_data                ,
    output wire                         o_1to8_valid               ,
    
    
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
    wire                                n_crc_ok                   ;
    wire               [  15: 0]        n_rd_cnt                   ;
    wire               [   7: 0]        n_para_type                ;
    wire               [   7: 0]        n_ram_in                   ;
    
rec_frame rec_frame_inst(
    .i_clk163m84                        (i_clk163m84               ),
    .i_clk20m                           (i_clk20m                  ),
    .i_rstn                             (i_rstn                    ),
    .i_rst_n                            (i_rst_n                   ),
    
    .i_data_in                          (i_data_in                 ),
    .i_data_en                          (i_data_en                 ),
    .i_data_crc_valid                   (i_data_crc_valid          ),
    .i_data_crc                         (i_data_crc                ),
    
    .o_crc_ok                           (n_crc_ok                  ),
    .o_rd_cnt                           (n_rd_cnt                  ),
    .o_para_type                        (n_para_type               ),
    .o_ram_in                           (n_ram_in                  ),
    
    .o_1to8_data                        (o_1to8_data               ),
    .o_1to8_valid                       (o_1to8_valid              ) 
    );

    
rec_para u_rec_para(
    .i_clk163m84                        (i_clk163m84               ),
    .i_rst_n                            (i_rst_n                   ),

    .i_crc_ok                           (n_crc_ok                  ),
    .i_para_type                        (n_para_type               ),
    .i_ram_in                           (n_ram_in                  ),
    .i_rd_cnt                           (n_rd_cnt                  ),

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
endmodule