`timescale 1ns / 1ps
module sx_data_v4 (
    input                               sys_clk_i                  ,//clk163m84
    input                               rst_n_i                    ,//rst_n_i
    
    input              [   7: 0]        yw_data                    ,
    input                               yw_data_valid              ,

    input                               info_start_flag_i          ,//lvds_rx_data模块引出的开始信号
    input              [   7: 0]        info_type_i                ,//帧头第一字节
    // input              [  15:0]         info_fram_leng             ,
    input              [  15: 0]        channel_mang_i             ,//信道控制信息
    //-------------------------读通道-------------------------------
    input              [   7: 0]        i_MC_StatCLR               ,
    input                               uplink_40ms                ,//40ms脉冲信号输入
    input              [  31: 0]        ctrl_timeslot              ,//三种时隙，暂用VIO控制
    input              [  31: 0]        busi_timeslot              ,//三种时隙，暂用VIO控制
    input              [  31: 0]        circuit_timeslot           ,//三种时隙，暂用VIO控制

    input              [  15: 0]        tx_data1_length_out        ,//固定控制数据请求
    input                               tx_data1_ask_out           ,//固定控制数据请求
    output reg         [   7: 0]        tx_data1_in                ,//固定控制数据请求
    output reg                          tx_data1_valid_in          ,//固定控制数据请求

    input              [  15: 0]        tx_data2_length_out        ,//ctrl busi circuit
    input                               tx_data2_ask_out           ,//ctrl busi circuit
    output reg         [   7: 0]        tx_data2_in                ,//ctrl busi circuit
    output reg                          tx_data2_valid_in          ,//ctrl busi circuit
    
    output             [  15: 0]        ctrl_data_count            ,
    output             [  15: 0]        busi_data_count            ,
    output             [  15: 0]        circuit_data_count         ,
    
    input                               byte_cnt_equal_25          ,
    output reg         [  31: 0]        GD_ctrl_cnt                ,
    output reg         [  31: 0]        ctrl_sdl_cnt               ,
    output reg         [  31: 0]        yw_sdl_cnt                 ,
    output reg         [  31: 0]        DL_cnt                     ,
    
    output             [   7: 0]        up_gear                     //档位
);
    wire               [   7: 0]        ls_tx_data1_in             ;
    wire                                ls_tx_data1_valid_in       ;
    wire               [   7: 0]        ls_tx_data2_in             ;
    wire                                ls_tx_data2_valid_in       ;
    wire               [   7: 0]        ms_tx_data1_in             ;
    wire                                ms_tx_data1_valid_in       ;
    wire               [   7: 0]        ms_tx_data2_in             ;
    wire                                ms_tx_data2_valid_in       ;

    reg                                 ls_yw_data_valid           ;// low speed data
    reg                [   7: 0]        ls_yw_data                 ;// low speed data
    reg                                 ms_yw_data_valid           ;// medium speed data
    reg                [   7: 0]        ms_yw_data                 ;// medium speed data
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 选择上行中速or低速
//---------------------------------------------------------------------
always@(posedge sys_clk_i)begin
    case (up_gear)
        8'h8E,
        8'h8F,
        8'h8C,
        8'h8D,
        8'h8A,
        8'h8B,
        8'h88,
        8'h94,
        8'h89,
        8'h86,
        8'h93,
        8'h87,
        8'h84,
        8'h92,
        8'h85,
        8'h82,
        8'h91,
        8'h83,
        8'h80,
        8'h90,
        8'h81: begin                                                // up low speed data
            ls_yw_data        <= yw_data;
            ls_yw_data_valid  <= yw_data_valid;
            ms_yw_data_valid  <= 'd0;
            ms_yw_data        <= 'd0;
            tx_data1_in       <= ls_tx_data1_in      ;
            tx_data1_valid_in <= ls_tx_data1_valid_in;
            tx_data2_in       <= ls_tx_data2_in      ;
            tx_data2_valid_in <= ls_tx_data2_valid_in;
        end
        8'hC7,
        8'hC6,
        8'hC5,
        8'hC4,
        8'hC3,
        8'hC2,
        8'hC1,
        8'hC0,
        8'hCA: begin                                                // up medium speed data
            ls_yw_data        <= 'd0;
            ls_yw_data_valid  <= 'd0;
            ms_yw_data        <= yw_data;
            ms_yw_data_valid  <= yw_data_valid;
            tx_data1_in       <= ms_tx_data1_in      ;
            tx_data1_valid_in <= ms_tx_data1_valid_in;
            tx_data2_in       <= ms_tx_data2_in      ;
            tx_data2_valid_in <= ms_tx_data2_valid_in;
        end
        default: begin
            ls_yw_data        <= 'd0;
            ls_yw_data_valid  <= 'd0;
            ms_yw_data_valid  <= 'd0;
            ms_yw_data        <= 'd0;
            tx_data1_in       <= 'd0;
            tx_data1_valid_in <= 'd0;
            tx_data2_in       <= 'd0;
            tx_data2_valid_in <= 'd0;
        end
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计算从lvds收到的帧计数
//---------------------------------------------------------------------

    reg     r_MC_StatCLR = 'b0;
always@(posedge sys_clk_i)begin
    r_MC_StatCLR <= i_MC_StatCLR[0];
end
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        GD_ctrl_cnt  <= 'd0;
        ctrl_sdl_cnt <= 'd0;
        yw_sdl_cnt   <= 'd0;
        DL_cnt       <= 'd0;
    end
    else if(r_MC_StatCLR) begin
        GD_ctrl_cnt  <= 'd0;
        ctrl_sdl_cnt <= 'd0;
        yw_sdl_cnt   <= 'd0;
        DL_cnt       <= 'd0;
    end
    else if(byte_cnt_equal_25)begin
        if (info_type_i[3:0] == 4'hB) begin
            case (channel_mang_i[2:0])
                3'd1: GD_ctrl_cnt <= GD_ctrl_cnt + 'd1;
                3'd2: ctrl_sdl_cnt <= ctrl_sdl_cnt + 'd1;
                3'd3: yw_sdl_cnt <= yw_sdl_cnt + 'd1;
                default: begin
                    GD_ctrl_cnt  <= 'd0;
                    ctrl_sdl_cnt <= 'd0;
                    yw_sdl_cnt   <= 'd0;
                    DL_cnt       <= 'd0;
                end
            endcase
        end
        else if(info_type_i[3:0] == 4'hD)
            DL_cnt <= DL_cnt + 'd1;
    end
end

sx_medium_speed  sx_medium_speed_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),

    .yw_data                            (ms_yw_data                ),
    .yw_data_valid                      (ms_yw_data_valid          ),
    .info_start_flag_i                  (info_start_flag_i         ),
    .info_type_i                        (info_type_i               ),
    .channel_mang_i                     (channel_mang_i            ),
    .uplink_40ms                        (uplink_40ms               ),
    .ctrl_timeslot                      (ctrl_timeslot             ),
    .busi_timeslot                      (busi_timeslot             ),
    .circuit_timeslot                   (circuit_timeslot          ),
    .tx_data1_length_out                (tx_data1_length_out       ),
    .tx_data1_ask_out                   (tx_data1_ask_out          ),
    .tx_data1_in                        (ms_tx_data1_in            ),
    .tx_data1_valid_in                  (ms_tx_data1_valid_in      ),
    .tx_data2_length_out                (tx_data2_length_out       ),
    .tx_data2_ask_out                   (tx_data2_ask_out          ),
    .tx_data2_in                        (ms_tx_data2_in            ),
    .tx_data2_valid_in                  (ms_tx_data2_valid_in      ),

    .ctrl_data_count                    (ctrl_data_count           ),
    .busi_data_count                    (busi_data_count           ),
    .circuit_data_count                 (circuit_data_count        ),

    .up_gear                            (up_gear                   ) 
  );

sx_low_speed  sx_low_speed_inst (
    .clk163m84                          (sys_clk_i                 ),
    .rst_n                              (rst_n_i                   ),

    .channel_mang                       (channel_mang_i            ),
    .yw_data                            (ls_yw_data                ),
    .yw_data_valid                      (ls_yw_data_valid          ),
    .i_info_type                        (info_type_i               ),
    .tx_data1_length_out                (tx_data1_length_out       ),
    .tx_data1_ask_out                   (tx_data1_ask_out          ),
    .tx_data2_length_out                (tx_data2_length_out       ),
    .tx_data2_ask_out                   (tx_data2_ask_out          ),
    .tx_data1_in                        (ls_tx_data1_in            ),
    .tx_data1_valid_in                  (ls_tx_data1_valid_in      ),
    .tx_data2_in                        (ls_tx_data2_in            ),
    .tx_data2_valid_in                  (ls_tx_data2_valid_in      ),
    .up_gear                            (                          ) 
  );

endmodule