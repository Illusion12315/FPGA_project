
module sx_up_data_stream (
    input                               sys_clk_i                  ,//163.84mhz
    input                               rst_n_i                    ,//active low

    input              [   7: 0]        s2p_dout                   ,
    input                               dout_start                 ,
    //-------------------------读通道-------------------------------
    input                               uplink_40ms                ,//40ms脉冲信号输入
    input              [  31: 0]        ctrl_timeslot              ,//三种时隙，暂用VIO控制
    input              [  31: 0]        busi_timeslot              ,//三种时隙，暂用VIO控制
    input              [  31: 0]        circuit_timeslot           ,//三种时隙，暂用VIO控制

    input              [   7: 0]        i_MC_StatCLR               ,
    input              [  15: 0]        tx_data1_length_out        ,//固定控制数据请求
    input                               tx_data1_ask_out           ,//固定控制数据请求
    output             [   7: 0]        tx_data1_in                ,//固定控制数据请求
    output                              tx_data1_valid_in          ,//固定控制数据请求

    input              [  15: 0]        tx_data2_length_out        ,//ctrl busi circuit
    input                               tx_data2_ask_out           ,//ctrl busi circuit
    output             [   7: 0]        tx_data2_in                ,//ctrl busi circuit
    output                              tx_data2_valid_in          ,//ctrl busi circuit
    
    output             [  47: 0]        us_data_cache_cnt          ,
    
    output             [  31: 0]        GD_ctrl_cnt                ,
    output             [  31: 0]        ctrl_sdl_cnt               ,
    output             [  31: 0]        yw_sdl_cnt                 ,
    output             [  31: 0]        DL_cnt                     ,
    
    output             [   7: 0]        up_gear                     //档位
);
    wire               [   7: 0]        yw_data                    ;
    wire                                yw_data_valid              ;
    wire               [  15: 0]        channel_mang               ;
    wire                                info_start_flag            ;
    wire               [   7: 0]        info_type                  ;
    wire                                byte_cnt_equal_25          ;

    wire               [  15: 0]        ctrl_data_count            ;
    wire               [  15: 0]        busi_data_count            ;
    wire               [  15: 0]        circuit_data_count         ;

    assign                              us_data_cache_cnt         = {ctrl_data_count,busi_data_count,circuit_data_count};

sx_lvds_rx_data_analysis  sx_lvds_rx_data_analysis_inst (
    .clk_m_144                          (sys_clk_i                 ),
    .rst_n                              (rst_n_i                   ),

    .s2p_dout                           (s2p_dout                  ),
    .dout_start                         (dout_start                ),

    .channel_mang_r                     (channel_mang              ),
    .o_yworcirc_data                    (yw_data                   ),
    .o_yworcirc_data_valid              (yw_data_valid             ),
    .o_info_start_flag                  (info_start_flag           ),
    .byte_cnt_equal_25                  (byte_cnt_equal_25         ),
    .o_info_type                        (info_type                 ) 
  );

sx_data_v4  sx_data_v4_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),
    .yw_data                            (yw_data                   ),
    .yw_data_valid                      (yw_data_valid             ),
    .info_start_flag_i                  (info_start_flag           ),
    .info_type_i                        (info_type                 ),
    .channel_mang_i                     (channel_mang              ),

    .i_MC_StatCLR                       (i_MC_StatCLR              ),
    .uplink_40ms                        (uplink_40ms               ),
    .ctrl_timeslot                      (ctrl_timeslot             ),
    .busi_timeslot                      (busi_timeslot             ),
    .circuit_timeslot                   (circuit_timeslot          ),
    .tx_data1_length_out                (tx_data1_length_out       ),
    .tx_data1_ask_out                   (tx_data1_ask_out          ),
    .tx_data1_in                        (tx_data1_in               ),
    .tx_data1_valid_in                  (tx_data1_valid_in         ),
    .tx_data2_length_out                (tx_data2_length_out       ),
    .tx_data2_ask_out                   (tx_data2_ask_out          ),
    .tx_data2_in                        (tx_data2_in               ),
    .tx_data2_valid_in                  (tx_data2_valid_in         ),

    .ctrl_data_count                    (ctrl_data_count           ),
    .busi_data_count                    (busi_data_count           ),
    .circuit_data_count                 (circuit_data_count        ),

    .byte_cnt_equal_25                  (byte_cnt_equal_25         ),
    .GD_ctrl_cnt                        (GD_ctrl_cnt               ),
    .ctrl_sdl_cnt                       (ctrl_sdl_cnt              ),
    .yw_sdl_cnt                         (yw_sdl_cnt                ),
    .DL_cnt                             (DL_cnt                    ),

    .up_gear                            (up_gear                   ) 
  );
endmodule