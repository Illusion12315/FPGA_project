`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/28 12:38:06
// Design Name: 
// Module Name: MCtrl_top
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


module MCtrl_top(
    input  wire                         i_clk163m84                ,
    input  wire                         i_clk20m                   ,
    input  wire                         i_rst_n                    ,
    input  wire                         i_rstn                     ,
   
    input  wire                         BCTRL_RX_CLK               ,
    input  wire                         BCTRL_RX_DATA              ,
    input  wire                         BCTRL_RX_EN                ,
     
    output wire                         BCTRL_TX_CLK               ,
    output wire                         BCTRL_TX_DATA              ,
    output wire                         BCTRL_TX_EN                ,
    
    input  wire        [   7: 0]        vio_para_type              ,
    input  wire                         vio_para_en                ,
    
    input              [ 103: 0]        ds_sync_data_i             ,// 0x20 同步信道下行同步数据
    input              [  39: 0]        ms_ls_status_i             ,// 0x21 中速/低速状态信息
    input              [ 351: 0]        ds_statistics_i            ,// 0x22 下行统计信息
    input              [ 415: 0]        us_statistics_i            ,// 0x23 上行统计信息
    input              [  47: 0]        us_data_cache_cnt_i        ,// 0x24 上行缓存剩余空间
    input              [  31: 0]        software_info_i            ,// 0x30 软件版本信息
    
    output wire        [   7: 0]        o_soft_rst_n               ,// 0x00 复位功能 触发690T全局复位，包括通信信息、调制解调模块等的复位
    output wire        [   7: 0]        o_FixedFre_or_FreHop_mod   ,// 0x10 定频/跳频模式
    output wire        [  63: 0]        o_rx_freq                  ,// 0x11 跳频基准频点
    output wire        [  31: 0]        o_down_step_freq           ,// 0x12 下行频偏补偿值
    output wire        [  47: 0]        o_init_tod_in              ,// 0x13 初始TOD
    output wire        [  47: 0]        o_us_ds_para               ,// 0x14 上下行跳频参数配置
    output wire        [ 255: 0]        o_ds_timeslot              ,// 0x15 下行时隙档位配置
    output wire        [   7: 0]        o_config                   ,// 0x16 下行解帧范式配置
    output wire                         o_config_valid             ,
    output wire        [   7: 0]        o_statistical_info_rst     ,// 0x18 统计信息清零
    output wire        [  31: 0]        o_trans_latency_compens    ,// 0x05 星地传输延迟补偿值
    output wire        [  31: 0]        o_us_ms_addr_crc           ,// 0x06 上行中速同步站地址和CRC
    output wire        [  31: 0]        o_us_fre_offset_compens    ,// 0x07 上行频偏补偿值
    output wire        [ 135: 0]        o_us_sync_en               ,// 0x08 上行中速/低速同步信道使能
    output wire        [  23: 0]        o_us_send_choose           ,// 0x09 上行发送数据选择
    output wire        [ 135: 0]        o_ls_carrier_cfg           ,// 0x0B 上行低速载波配置
    output wire        [ 175: 0]        o_ms_timeslot              ,// 0x0C 上行中速时隙配置
    output wire        [ 103: 0]        o_ds_sync_data             ,// 0x20 同步信道下行同步数据
    output wire        [  39: 0]        o_ms_ls_status             ,// 0x21 中速/低速状态信息
    output wire        [ 351: 0]        o_ds_statistics            ,// 0x22 下行统计信息
    output wire        [ 415: 0]        o_us_statistics            ,// 0x23 上行统计信息
    output wire        [  31: 0]        o_software_info             // 0x30 软件版本信息
    );

    assign                              BCTRL_TX_CLK              = ~ i_clk20m;

    wire               [   7: 0]        i_data_in                  ;
    wire                                i_data_valid               ;

    wire               [  15: 0]        ctrl_data_count            ;
    wire               [  15: 0]        busi_data_count            ;
    wire               [  15: 0]        circuit_data_count         ;
    reg                [  15: 0]        ctrl_data_count_remain     ;
    reg                [  15: 0]        busi_data_count_remain     ;
    reg                [  15: 0]        circuit_data_count_remain  ;
    wire               [  47: 0]        us_data_cache_cnt_remain   ;

    reg                [   7: 0]        para_type                  ;
    reg                                 para_en                    ;

    reg                [   7: 0]        info_unit_idenf_i          ;

    assign                              {ctrl_data_count,busi_data_count,circuit_data_count}= us_data_cache_cnt_i;

    assign                              us_data_cache_cnt_remain  = {ctrl_data_count_remain,busi_data_count_remain,circuit_data_count_remain};
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 定时发送
//---------------------------------------------------------------------
    localparam                          half_cache                = 16384;
    localparam                          time_2s                   = 163_840_000 * 2;
    localparam                          time_0s                   = 0;
    localparam                          time_0_1s                 = 163_840_000 / 10 * 1;
    localparam                          time_0_3s                 = 163_840_000 / 10 * 3;
    localparam                          time_0_5s                 = 163_840_000 / 10 * 5;
    localparam                          time_0_2s                 = 163_840_000 / 10 * 2;
    reg                [  31: 0]        time_cnt                   ;

always@(posedge i_clk163m84)begin
    ctrl_data_count_remain    <= 16'd32768 - ctrl_data_count    ;
    busi_data_count_remain    <= 16'd32768 - busi_data_count    ;
    circuit_data_count_remain <= 16'd32768 - circuit_data_count ;
end

always@(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        time_cnt <= 'd0;
    else if(time_cnt >= time_2s)
        time_cnt <= 'd0;
    else
        time_cnt <= time_cnt + 'd1;
end

always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)begin
        para_en <= 'd0;
        para_type <= 'd0;
    end
    else if(~|time_cnt[23:0])begin
        case({time_cnt[25],time_cnt[24]})
            'bX0: begin                         //发送fifo容量
                if((ctrl_data_count >= half_cache) || (busi_data_count >= half_cache) || (circuit_data_count >= half_cache))begin
                    para_en <= 'd1;
                    para_type <= 8'h24;
                end
                else begin
                    para_en <= 'd0;
                    para_type <= para_type;
                end
            end
            'b01: begin                         //发送下行统计信息
                para_en <= 'd1;
                para_type <= 8'h22;
            end
            'b11: begin
                para_en <= 'd1;
                para_type <= 8'h23;
            end
            default: begin
                para_en <= 'd0;
                para_type <= 'd0;
            end
        endcase
    end
end
//always@(posedge i_clk163m84 or negedge i_rst_n)begin
//    if(!i_rst_n)begin
//        para_en <= 'd0;
//        para_type <= 'd0;
//    end
//    else case (time_cnt)
//        time_0s: begin                                              // 0s 时刻发送下行统计信息
//            para_en <= 'd1;
//            para_type <= 8'h22;
//        end
//        time_0_2s: begin                                            // 0.2s 时刻发送上行统计信息
//            para_en <= 'd1;
//            para_type <= 8'h23;
//        end
//        time_0_1s,time_0_3s,time_0_5s: begin                        // 0.1s,0.3s,0.5s 时刻发送fifo容量
//            if((ctrl_data_count >= half_cache) || (busi_data_count >= half_cache) || (circuit_data_count >= half_cache))begin
//                para_en <= 'd1;
//                para_type <= 8'h24;
//            end
//            else begin
//                para_en <= 'd0;
//                para_type <= para_type;
//            end
//        end
//        default: begin
//            para_en <= 'd0;
//            para_type <= para_type;
//        end
//    endcase
//end

always@(posedge i_clk163m84)begin
    case (para_type)
        8'h20,8'h22: info_unit_idenf_i <= 8'd40;
        8'h21,8'h23,8'h24: info_unit_idenf_i <= 8'd41;
        8'h30: info_unit_idenf_i <= 8'd42;
        default: info_unit_idenf_i <= info_unit_idenf_i;
    endcase
end

crc_sim  crc_sim_inst (
    .sys_clk_i                          (i_clk163m84               ),
    .rst_n_i                            (i_rst_n                   ),

    .i_para_type                        (para_type                 ),
    .i_para_en                          (para_en && vio_para_en    ),

    .ds_sync_data_i                     (ds_sync_data_i            ),
    .ms_ls_status_i                     (ms_ls_status_i            ),
    .ds_statistics_i                    (ds_statistics_i           ),
    .us_statistics_i                    (us_statistics_i           ),
    .us_data_cache_cnt_i                (us_data_cache_cnt_remain  ),
    .software_info_i                    (software_info_i           ),
    .data_in                            (i_data_in                 ),
    .data_valid                         (i_data_valid              ) 
    );

tx_ctrl tx_ctrl_inst(
    .clk163m84                          (i_clk163m84               ),
    .clk20m                             (i_clk20m                  ),
    .rst_n                              (i_rst_n                   ),
    .rstn                               (i_rstn                    ),
    .i_para_type                        (para_type                 ),

    .info_unit_idenf_i                  (info_unit_idenf_i         ),
    
    .i_data_in                          (i_data_in                 ),
    .i_data_valid                       (i_data_valid              ),
    
    .o_data8to1                         (BCTRL_TX_DATA             ),
    .o_data8to1_valid                   (BCTRL_TX_EN               ) 
    );

rec_ctrl rec_ctrl_inst(
    .i_clk163m84                        (i_clk163m84               ),
    .i_clk20m                           (i_clk20m                  ),
    .i_rstn                             (i_rstn                    ),
    .i_rst_n                            (i_rst_n                   ),
    
    .BCTRL_RX_CLK                       (BCTRL_RX_CLK              ),
    .BCTRL_RX_DATA                      (BCTRL_RX_DATA             ),
    .BCTRL_RX_EN                        (BCTRL_RX_EN               ),
        
    .o_soft_rst_n                       (o_soft_rst_n              ),// 0x00 [   7: 0] 复位功能 触发690T全局复位，包括通信信息、调制解调模块等的复位  
    .o_FixedFre_or_FreHop_mod           (o_FixedFre_or_FreHop_mod  ),// 0x10 [   7: 0] 定频/跳频模式  
    .o_rx_freq                          (o_rx_freq                 ),// 0x11 [  63: 0] 跳频基准频点  
    .o_down_step_freq                   (o_down_step_freq          ),// 0x12 [  31: 0] 下行频偏补偿值  
    .o_init_tod_in                      (o_init_tod_in             ),// 0x13 [  47: 0] 初始TOD  
    .o_us_ds_para                       (o_us_ds_para              ),// 0x14 [  47: 0] 上下行跳频参数配置  
    .o_ds_timeslot                      (o_ds_timeslot             ),// 0x15 [ 255: 0] 下行时隙档位配置  
    .o_config                           (o_config                  ),// 0x16 [   7: 0] 下行解帧范式配置  
    .o_config_valid                     (o_config_valid            ),
    .o_statistical_info_rst             (o_statistical_info_rst    ),// 0x18 [   7: 0] 统计信息清零
    .o_trans_latency_compens            (o_trans_latency_compens   ),// 0x05 [  31: 0] 星地传输延迟补偿值
    .o_us_ms_addr_crc                   (o_us_ms_addr_crc          ),// 0x06 [  31: 0] 上行中速同步站地址和CRC
    .o_us_fre_offset_compens            (o_us_fre_offset_compens   ),// 0x07 [  31: 0] 上行频偏补偿值
    .o_us_sync_en                       (o_us_sync_en              ),// 0x08 [ 135: 0] 上行中速/低速同步信道使能
    .o_us_send_choose                   (o_us_send_choose          ),// 0x09 [  23: 0] 上行发送数据选择
    .o_ls_carrier_cfg                   (o_ls_carrier_cfg          ),// 0x0B [ 135: 0] 上行低速载波配置
    .o_ms_timeslot                      (o_ms_timeslot             ),// 0x0C [ 175: 0] 上行中速时隙配置
    .o_ds_sync_data                     (o_ds_sync_data            ),// 0x20 [ 103: 0] 同步信道下行同步数据
    .o_ms_ls_status                     (o_ms_ls_status            ),// 0x21 [  39: 0] 中速/低速状态信息
    .o_ds_statistics                    (o_ds_statistics           ),// 0x22 [ 351: 0] 下行统计信息
    .o_us_statistics                    (o_us_statistics           ),// 0x23 [ 415: 0] 上行统计信息
    .o_software_info                    (o_software_info           ) // 0x30 [  31: 0] 软件版本信息
    );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
ila_Mctrl_debug ila_Mctrl_debug_inst (
    .clk                                (i_clk163m84               ),// input wire clk

    .probe0                             (para_en                   ),// input wire [0:0]  probe0  
    .probe1                             (para_type                 ),// input wire [7:0]  probe1 
    .probe2                             (ctrl_data_count           ),// input wire [31:0]  probe2 
    .probe3                             (busi_data_count           ),// input wire [31:0]  probe3 
    .probe4                             (circuit_data_count        ) // input wire [31:0]  probe4
);

endmodule
/*
MCtrl_top  MCtrl_top_inst (
    .i_clk163m84                        (i_clk163m84               ),
    .i_clk20m                           (i_clk20m                  ),
    .i_rst_n                            (i_rst_n                   ),
    .i_rstn                             (i_rstn                    ),

    .BCTRL_RX_CLK                       (BCTRL_RX_CLK              ),
    .BCTRL_RX_DATA                      (BCTRL_RX_DATA             ),
    .BCTRL_RX_EN                        (BCTRL_RX_EN               ),
    .BCTRL_TX_CLK                       (BCTRL_TX_CLK              ),
    .BCTRL_TX_DATA                      (BCTRL_TX_DATA             ),
    .BCTRL_TX_EN                        (BCTRL_TX_EN               ),

    .vio_para_type                      (vio_para_type             ),
    .vio_para_en                        (vio_para_en               ),
    // -------------------------690t to 7045------------------------
    .ds_sync_data_i                     (ds_sync_data_i            ),// 0x20 [ 103: 0] 同步信道下行同步数据
    .ms_ls_status_i                     (ms_ls_status_i            ),// 0x21 [  39: 0] 中速/低速状态信息
    .ds_statistics_i                    (ds_statistics_i           ),// 0x22 [ 351: 0] 下行统计信息
    .us_statistics_i                    (us_statistics_i           ),// 0x23 [ 415: 0] 上行统计信息
    .software_info_i                    (software_info_i           ),// 0x30 [  31: 0] 软件版本信息
    // -------------------------7045 to 690t------------------------
    .o_soft_rst_n                       (o_soft_rst_n              ),// 0x00 [   7: 0] 复位功能 触发690T全局复位，包括通信信息、调制解调模块等的复位  
    .o_FixedFre_or_FreHop_mod           (o_FixedFre_or_FreHop_mod  ),// 0x10 [   7: 0] 定频/跳频模式  
    .o_rx_freq                          (o_rx_freq                 ),// 0x11 [  63: 0] 跳频基准频点  
    .o_down_step_freq                   (o_down_step_freq          ),// 0x12 [  31: 0] 下行频偏补偿值  
    .o_init_tod_in                      (o_init_tod_in             ),// 0x13 [  47: 0] 初始TOD  
    .o_us_ds_para                       (o_us_ds_para              ),// 0x14 [  47: 0] 上下行跳频参数配置  
    .o_ds_timeslot                      (o_ds_timeslot             ),// 0x15 [ 255: 0] 下行时隙档位配置  
    .o_config                           (o_config                  ),// 0x16 [   7: 0] 下行解帧范式配置  
    .o_config_valid                     (o_config_valid            ),
    .o_statistical_info_rst             (o_statistical_info_rst    ),// 0x18 [   7: 0] 统计信息清零
    .o_trans_latency_compens            (o_trans_latency_compens   ),// 0x05 [  31: 0] 星地传输延迟补偿值
    .o_us_ms_addr_crc                   (o_us_ms_addr_crc          ),// 0x06 [  31: 0] 上行中速同步站地址和CRC
    .o_us_fre_offset_compens            (o_us_fre_offset_compens   ),// 0x07 [  31: 0] 上行频偏补偿值
    .o_us_sync_en                       (o_us_sync_en              ),// 0x08 [ 135: 0] 上行中速/低速同步信道使能
    .o_us_send_choose                   (o_us_send_choose          ),// 0x09 [  23: 0] 上行发送数据选择
    .o_ls_carrier_cfg                   (o_ls_carrier_cfg          ),// 0x0B [ 135: 0] 上行低速载波配置
    .o_ms_timeslot                      (o_ms_timeslot             ),// 0x0C [ 175: 0] 上行中速时隙配置
    .o_ds_sync_data                     (o_ds_sync_data            ),// 0x20 [ 103: 0] 同步信道下行同步数据
    .o_ms_ls_status                     (o_ms_ls_status            ),// 0x21 [  39: 0] 中速/低速状态信息
    .o_ds_statistics                    (o_ds_statistics           ),// 0x22 [ 351: 0] 下行统计信息
    .o_us_statistics                    (o_us_statistics           ),// 0x23 [ 415: 0] 上行统计信息
    .o_software_info                    (o_software_info           ) // 0x30 [  31: 0] 软件版本信息
  );
*/