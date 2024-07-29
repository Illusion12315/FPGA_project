`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/24 15:35:33
// Design Name: 
// Module Name: lvds_top
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


module lvds_top(
    input                               clk_100m                   ,
    
    input                               clk163m84                  ,
    input                               rst_n_100m                 ,
    input                               rst_n_163m84               ,
   
    // LVD
    input              [   3: 0]        dat_in_p                   ,
    input              [   3: 0]        dat_in_n                   ,
    input                               clk_in_p                   ,
    input                               clk_in_n                   ,
    input                               dat_vld_in                 ,
   
    output             [   3: 0]        dat_out_p                  ,
    output             [   3: 0]        dat_out_n                  ,
    output                              clk_to_pins_p              ,
    output                              clk_to_pins_n              ,
    output                              dat_vld_o                  ,
    //from690to7045
    input                               uplink_40ms                ,
//    input              [   7:0]         down_gear                  ,
    
    input              [   7: 0]        i_DL_GearEverySlot         ,
    input                               i_DecScr_valid             ,
    input              [   7: 0]        i_DecScr_data              ,
    input              [   7: 0]        i_ldpc_cnt                 ,
    input              [   7: 0]        i_slottimesw_cnt           ,
//    input   [15:0]             frame_len               ,
//    input                      fd_in                   ,
//    input                      vld_in                  ,
//    input                      eof_in                  ,
//    input   [7:0]              dat_in                  ,
    //from7045to690
//    output                     dout_start                ,
//    //output                     fl_vld                  ,
//    output   [8:0]             s2p_dout                 ,
    //cnt
    output             [  31: 0]        rt_rev_cnt                 ,
    output             [  31: 0]        fl_send_cnt                ,
    output             [  31: 0]        cnt_sdl_output             ,
    
    output             [  47: 0]        us_data_cache_cnt          ,
    
    output             [  31: 0]        GD_ctrl_cnt                ,
    output             [  31: 0]        ctrl_sdl_cnt               ,
    output             [  31: 0]        yw_sdl_cnt                 ,
    output             [  31: 0]        DL_cnt                     ,
    //----------------------from 7045-----------//
    input              [   7: 0]        i_MC_StatCLR               ,
    input                               config_vld                 ,
    input              [   7: 0]        config_data                ,
    
    input              [  31: 0]        ctrl_timeslot_i            ,
    input              [  31: 0]        busi_timeslot_i            ,
    input              [  31: 0]        circuit_timeslot_i         ,
    //----------------phy data
    input              [  15: 0]        tx_data1_length_out        ,
    input                               tx_data1_ask_out           ,
    input              [  15: 0]        tx_data2_length_out        ,
    input                               tx_data2_ask_out           ,
    output             [   7: 0]        tx_data1_in                ,
    output                              tx_data1_valid_in          ,
    output             [   7: 0]        tx_data2_in                ,
    output                              tx_data2_valid_in          ,
    output             [   7: 0]        up_gear                     
    
    
    );
    wire                                p2s_rstn                   ;

    
    wire               [  15: 0]        channel_mang               ;
    wire                                channel_flag               ;
    wire               [   7: 0]        yw_data                    ;
    wire                                yw_data_valid              ;

    wire               [   7: 0]        w_info_type                ;

    wire                                dout_start                 ;
    wire               [   8: 0]        s2p_dout                   ;

//from690to7045
    wire               [  15: 0]        frame_len                  ;
    wire                                fd_in                      ;
    wire                                vld_in                     ;
    wire                                eof_in                     ;
    wire               [   7: 0]        dat_in                     ;

    wire                                o_info_start_flag          ;
    wire                                dout_start_w               ;
    wire               [   7: 0]        s2p_dout_w                 ;

    wire               [   7: 0]        dangwei_N                  ;
    wire               [  31: 0]        send_period                ;
    wire                                in_turn_send               ;
//------------------------------------------------------------------------------//

lvds lvds_inst(
    .clk_100m                           (clk_100m                  ),
    .clk163m84                          (clk163m84                 ),
    .rstn                               (rst_n_100m                ),
    .rst_n                              (rst_n_163m84              ),
    
    .p2s_rstn                           (p2s_rstn                  ),
   
    // LVD
    .dat_in_p                           (dat_in_p                  ),
    .dat_in_n                           (dat_in_n                  ),
    .clk_in_p                           (clk_in_p                  ),
    .clk_in_n                           (clk_in_n                  ),
    .dat_vld_in                         (dat_vld_in                ),
   
    .dat_out_p                          (dat_out_p                 ),
    .dat_out_n                          (dat_out_n                 ),
    .clk_to_pins_p                      (clk_to_pins_p             ),
    .clk_to_pins_n                      (clk_to_pins_n             ),
    .dat_vld_o                          (dat_vld_o                 ),
    //from690to7045
    .frame_len                          (frame_len                 ),//16bit
    .fd_in                              (fd_in                     ),//1bit
    .vld_in                             (vld_in                    ),//1bit
    .eof_in                             (1'b0                      ),//1bit
    .dat_in                             (dat_in                    ),//8bit
    //from7045to690
    .dout_start                         (dout_start                ),
    //output                     fl_vld                  ,
    .s2p_dout                           (s2p_dout                  ),
    //cnt
    .rt_rev_cnt                         (rt_rev_cnt                ),
    .fl_send_cnt                        (fl_send_cnt               ),
    .cnt_sdl_output                     (cnt_sdl_output            ) 
    );
//-----------up link   
    
    wire               [  31: 0]        ctrl_timeslot              ;
    wire               [  31: 0]        busi_timeslot              ;
    wire               [  31: 0]        circuit_timeslot           ;
    wire               [  31: 0]        ctrl_timeslot_vio          ;
    wire               [  31: 0]        busi_timeslot_vio          ;
    wire               [  31: 0]        circuit_timeslot_vio       ;

    wire                                choose_updata_from         ;
    wire                                slot_hvio_l7045            ;

    wire                                guding_ctrl_en             ;
    wire                                ctrl_en                    ;
    wire                                yw_en                      ;
    wire                                circuit_en                 ;
    wire               [   7: 0]        s2p_dout_choose_out        ;
    wire                                dout_start_choose_out      ;

    assign                              s2p_dout_choose_out       = (0)? s2p_dout_w : s2p_dout[7:0];// high ,then choose vio ctrl
    assign                              dout_start_choose_out     = (0)? dout_start_w : dout_start;// high ,then choose vio ctrl

    assign                              ctrl_timeslot             = (0)? ctrl_timeslot_vio    : ctrl_timeslot_i;// high , then choose vio ctrl
    assign                              busi_timeslot             = (0)? busi_timeslot_vio    : busi_timeslot_i;// high , then choose vio ctrl
    assign                              circuit_timeslot          = (0)? circuit_timeslot_vio : circuit_timeslot_i;// high , then choose vio ctrl

//vio_sxdata u_vio_sxdata (
//    .clk                               (clk_m_144                 ),// input wire clk
//    .probe_out0                        (ctrl_timeslot_vio         ),// output wire [31 : 0] probe_out0
//    .probe_out1                        (busi_timeslot_vio         ),// output wire [31 : 0] probe_out1
//    .probe_out2                        (circuit_timeslot_vio      ),// output wire [31 : 0] probe_out2
//    .probe_out3                        (guding_ctrl_en            ),// output wire [0 : 0] probe_out3
//    .probe_out4                        (ctrl_en                   ),// output wire [0 : 0] probe_out4
//    .probe_out5                        (yw_en                     ),// output wire [0 : 0] probe_out5
//    .probe_out6                        (circuit_en                ),// output wire [0 : 0] probe_out6
//    .probe_out7                        (dangwei_N                 ),// output wire [7 : 0] probe_out7
//    .probe_out8                        (send_period               ),// output wire [31 : 0] probe_out8
//    .probe_out9                        (in_turn_send              ),
//    .probe_out10                       (choose_updata_from        ),
//    .probe_out11                       (slot_hvio_l7045           ) // high choose vio,low choose 7045
//);

// up data stream
sx_up_data_stream sx_up_data_stream_inst(
    .sys_clk_i                          (clk163m84                 ),
    .rst_n_i                            (rst_n_163m84              ),
    
    .s2p_dout                           (s2p_dout_choose_out       ),// data from 7045 . with frame head
    .dout_start                         (dout_start_choose_out     ),// data from 7045

    .uplink_40ms                        (uplink_40ms               ),// control signal from arithmetic(suanfa)
    .ctrl_timeslot                      (ctrl_timeslot             ),// control signal from arithmetic(suanfa)
    .busi_timeslot                      (busi_timeslot             ),// control signal from arithmetic(suanfa)
    .circuit_timeslot                   (circuit_timeslot          ),// control signal from arithmetic(suanfa)
    
    .i_MC_StatCLR                       (i_MC_StatCLR              ),
    .tx_data1_length_out                (tx_data1_length_out       ),// guding contrl require length
    .tx_data1_ask_out                   (tx_data1_ask_out          ),// guding contrl require
    .tx_data2_length_out                (tx_data2_length_out       ),// ye wu data
    .tx_data2_ask_out                   (tx_data2_ask_out          ),
    .tx_data1_in                        (tx_data1_in               ),// guding control data
    .tx_data1_valid_in                  (tx_data1_valid_in         ),// guding control valid
    .tx_data2_in                        (tx_data2_in               ),// ye wu data
    .tx_data2_valid_in                  (tx_data2_valid_in         ),// ye wu data

    .us_data_cache_cnt                  (us_data_cache_cnt         ),

    .GD_ctrl_cnt                        (GD_ctrl_cnt               ),
    .ctrl_sdl_cnt                       (ctrl_sdl_cnt              ),
    .yw_sdl_cnt                         (yw_sdl_cnt                ),
    .DL_cnt                             (DL_cnt                    ),

    .up_gear                            (up_gear                   ) // dang wei xin xi
);

//---------down link------

lvds_tx lvds_tx_inst(
    .clk163m84                          (clk163m84                 ),
    .clk100m                            (clk_100m                  ),
    
    .rst_n_100m                         (rst_n_100m                ),
    .rst_n_163m84                       (rst_n_163m84              ),
//    .down_gear                         (down_gear                 ),
        
    .i_DL_GearEverySlot                 (i_DL_GearEverySlot        ),
    .i_DecScr_vld                       (i_DecScr_valid            ),
    .i_DecScr_Data                      (i_DecScr_data             ),
    .i_ldpc_cnt                         (i_ldpc_cnt                ),
    .i_slottimesw_cnt                   (i_slottimesw_cnt          ),

    .config_vld                         (config_vld                ),
    .config_data                        (config_data               ),
        
    .txdata                             (dat_in                    ),
    .txen                               (vld_in                    ),
    .data_len                           (frame_len                 ),
    .len_en                             (fd_in                     ),
    .o_p2s_rstn                         (p2s_rstn                  ) 
//       .o_p2s_rstn          
    );
    
//test_sim_data test_sim_data_inst(
//    .sys_clk_i                         (clk163m84                 ),
//    .rst_n_i                           (rst_n_163m84                     ),
//    .guding_ctrl_en_i                  (guding_ctrl_en            ),
//    .ctrl_en_i                         (ctrl_en                   ),
//    .yw_en_i                           (yw_en                     ),
//    .circuit_en_i                      (circuit_en                ),
        
//    .in_turn_send_i                    (in_turn_send              ),
        
//    .send_period_i                     (send_period               ),
//    .dangwei_N                         (dangwei_N                 ),

//    .s2p_dout_o                        (s2p_dout_w                ),
//    .dout_start                        (dout_start_w              ) 
//);
endmodule