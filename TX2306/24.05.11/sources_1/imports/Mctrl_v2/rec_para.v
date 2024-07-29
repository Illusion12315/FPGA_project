`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: chen xiongzhi
// 
// Create Date: 2023/08/25 00:20:10
// Design Name: 
// Module Name: rec_para
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


module rec_para(
    input                               i_clk163m84                ,
    input                               i_rst_n                    ,
    
    input                               i_crc_ok                   ,
    input              [   7: 0]        i_para_type                ,
    input              [   7: 0]        i_ram_in                   ,
    input              [  15: 0]        i_rd_cnt                   ,

    output reg         [   7: 0]        o_soft_rst_n               ,// 0x00
    output reg         [   7: 0]        o_FixedFre_or_FreHop_mod   ,// 0x10 fixed frequency and frequency hopping mod
    output reg         [  63: 0]        o_rx_freq                  ,// 0x11
    output reg         [  31: 0]        o_down_step_freq           ,// 0x12
    output reg         [  47: 0]        o_init_tod_in              ,// 0x13
    output reg         [  47: 0]        o_us_ds_para               ,// 0x14
    output reg         [ 255: 0]        o_ds_timeslot              ,// 0x15
    output reg         [   7: 0]        o_config                   ,// 0x16
    output reg                          o_config_valid             ,

    output reg         [   7: 0]        o_statistical_info_rst     ,// 0x18

    output reg         [  31: 0]        o_trans_latency_compens    ,// 0x05
    output reg         [  31: 0]        o_us_ms_addr_crc           ,// 0x06
    output reg         [  31: 0]        o_us_fre_offset_compens    ,// 0x07
    output reg         [ 135: 0]        o_us_sync_en               ,// 0x08
    output reg         [  23: 0]        o_us_send_choose           ,// 0x09
    output reg         [ 135: 0]        o_ls_carrier_cfg           ,// 0x0B
    output reg         [ 175: 0]        o_ms_timeslot              ,// 0x0C

    output reg         [ 103: 0]        o_ds_sync_data             ,// 0x20
    output reg         [  39: 0]        o_ms_ls_status             ,// 0x21
    output reg         [ 351: 0]        o_ds_statistics            ,// 0x22
    output reg         [ 415: 0]        o_us_statistics            ,// 0x23
    output reg         [  31: 0]        o_software_info             // 0x30
    );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
    reg                [   7: 0]        r_soft_rst_n               ;// 0x00
    reg                [   7: 0]        r_FixedFre_or_FreHop_mod   ;// 0x10 fixed frequency and frequency hopping mod
    reg                [  63: 0]        r_rx_freq                  ;// 0x11
    reg                [  31: 0]        r_down_step_freq           ;// 0x12
    reg                [  47: 0]        r_init_tod_in              ;// 0x13
    reg                [  47: 0]        r_us_ds_para               ;// 0x14
    reg                [ 255: 0]        r_ds_timeslot              ;// 0x15

    reg                [   7: 0]        r_statistical_info_rst     ;// 0x18

    reg                [  31: 0]        r_trans_latency_compens    ;// 0x05
    reg                [  31: 0]        r_us_ms_addr_crc           ;// 0x06
    reg                [  31: 0]        r_us_fre_offset_compens    ;// 0x07
    reg                [ 135: 0]        r_us_sync_en               ;// 0x08
    reg                [  23: 0]        r_us_send_choose           ;// 0x09
    reg                [ 135: 0]        r_ls_carrier_cfg           ;// 0x0B
    reg                [ 175: 0]        r_ms_timeslot              ;// 0x0C

    reg                [ 103: 0]        r_ds_sync_data             ;// 0x20
    reg                [  39: 0]        r_ms_ls_status             ;// 0x21
    reg                [ 351: 0]        r_ds_statistics            ;// 0x22
    reg                [ 415: 0]        r_us_statistics            ;// 0x23
    reg                [  31: 0]        r_software_info            ;// 0x30
// ********************************************************************************** // 
//---------------------------------------------------------------------
// assign
//---------------------------------------------------------------------
    integer i;
    wire               [  15: 0]        i_rd_cnt_sub_d23           ;
    assign                              i_rd_cnt_sub_d23          = i_rd_cnt - 'd23;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// logic
//---------------------------------------------------------------------
// 0x00 复位功能 触发690T全局复位，包括通信信息、调制解调模块等的复位
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_soft_rst_n <= 'd0;
    else case (i_para_type)
        8'h00:begin
            case(i_rd_cnt)
                16'd23:r_soft_rst_n[7:0]          <= i_ram_in;
                default:r_soft_rst_n              <= r_soft_rst_n;
            endcase
        end
        default: r_soft_rst_n              <= r_soft_rst_n;
    endcase
end
// 0x10 fixed frequency and frequency hopping mod 定频/跳频模式
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_FixedFre_or_FreHop_mod <= 'd0;
    else case (i_para_type)
        8'h10:begin
            case(i_rd_cnt)
                16'd23:r_FixedFre_or_FreHop_mod <= i_ram_in;
                default:r_FixedFre_or_FreHop_mod <= r_FixedFre_or_FreHop_mod;
            endcase
        end
        default: r_FixedFre_or_FreHop_mod <= r_FixedFre_or_FreHop_mod;
    endcase
end
// 0x11 跳频基准频点
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_rx_freq <= 'd0;
    else case (i_para_type)
        8'h11: begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd30)
                r_rx_freq[63 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_rx_freq <= r_rx_freq;
        end
        default: r_rx_freq      <= r_rx_freq;
    endcase
end
// 0x12 下行频偏补偿值
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_down_step_freq <= 'd0;
    else case (i_para_type)
        8'h12:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd26)
                r_down_step_freq[31 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_down_step_freq <= r_down_step_freq;
        end
        default: r_down_step_freq      <= r_down_step_freq;
    endcase
end
// 0x13 初始TOD
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_init_tod_in <= 'd0;
    else case (i_para_type)
        8'h13:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd28)
                r_init_tod_in[47 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_init_tod_in <= r_init_tod_in;
        end
        default: r_init_tod_in <= r_init_tod_in;
    endcase
end
// 0x14 上下行跳频参数配置
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_us_ds_para <= 'd0;
    else case (i_para_type)
        8'h14:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd28)
                r_us_ds_para[47 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_us_ds_para <= r_us_ds_para;
        end
        default: r_us_ds_para                 <= r_us_ds_para;
    endcase
end
// 0x15 下行时隙档位配置
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_ds_timeslot <= 'd0;
    else case (i_para_type)
        8'h15:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd54)
                r_ds_timeslot[255 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_ds_timeslot <= r_ds_timeslot;
        end
        default: r_ds_timeslot <= r_ds_timeslot;
    endcase
end
// 0x16 下行解帧范式配置
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)begin
        o_config <= 'd0;
        o_config_valid <= 'd0;
    end
    else case (i_para_type)
        8'h16:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd85)begin
                o_config <= i_ram_in;
                o_config_valid <= 'd1;
            end
            else begin
                o_config <= o_config;
                o_config_valid <= 'd0;
            end
        end
        default: begin
            o_config <= o_config;
            o_config_valid <= 'd0;
        end
    endcase
end
// 0x18 统计信息清零
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_statistical_info_rst <= 'd0;
    else case (i_para_type)
        8'h18:begin
            if (i_rd_cnt == 'd23)
                r_statistical_info_rst <= i_ram_in;
            else
                r_statistical_info_rst <= r_statistical_info_rst;
        end
        default: r_statistical_info_rst <= r_statistical_info_rst;
    endcase
end
//-------------------------------------------------------------------------//
// 0x05 星地传输延迟补偿值
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_trans_latency_compens <= 'd0;
    else case (i_para_type)
        8'h05:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd26)
                r_trans_latency_compens[31 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_trans_latency_compens <= r_trans_latency_compens;
        end
        default: r_trans_latency_compens <= r_trans_latency_compens;
    endcase
end
// 0x06 上行中速同步站地址和CRC
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_us_ms_addr_crc <= 'd0;
    else case (i_para_type)
        8'h06:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd26)
                r_us_ms_addr_crc[31 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_us_ms_addr_crc <= r_us_ms_addr_crc;
        end
        default: r_us_ms_addr_crc <= r_us_ms_addr_crc;
    endcase
end
// 0x07 上行频偏补偿值
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_us_fre_offset_compens <= 'd0;
    else case (i_para_type)
        8'h07:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd26)
                r_us_fre_offset_compens[31 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_us_fre_offset_compens <= r_us_fre_offset_compens;
        end
        default: r_us_fre_offset_compens <= r_us_fre_offset_compens;
    endcase
end
// 0x08 上行中速/低速同步信道使能
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_us_sync_en <= 'd0;
    else case (i_para_type)
        8'h08:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd39)
                r_us_sync_en[135 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_us_sync_en <= r_us_sync_en;
        end
        default: r_us_sync_en <= r_us_sync_en;
    endcase
end
// 0x09 上行发送数据选择
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_us_send_choose <= 'd0;
    else case (i_para_type)
        8'h09:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd25)
                r_us_send_choose[23 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_us_send_choose <= r_us_send_choose;
        end
        default: r_us_send_choose <= r_us_send_choose;
    endcase
end
// 0x0B 上行低速载波配置
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_ls_carrier_cfg <= 'd0;
    else case (i_para_type)
        8'h0B:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd39)
                r_ls_carrier_cfg[135 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_ls_carrier_cfg <= r_ls_carrier_cfg;
        end
        default: r_ls_carrier_cfg <= r_ls_carrier_cfg;
    endcase
end
// 0x0C 上行中速时隙配置
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_ms_timeslot <= 'd0;
    else case (i_para_type)
        8'h0C:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd44)
                r_ms_timeslot[175 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_ms_timeslot <= r_ms_timeslot;
        end
        default: r_ms_timeslot <= r_ms_timeslot;
    endcase
end
//-------------------------------------------------------------------//
// 0x20 同步信道下行同步数据
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_ds_sync_data <= 'd0;
    else case (i_para_type)
        8'h20:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd35)
                r_ds_sync_data[103 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_ds_sync_data <= r_ds_sync_data;
        end
        default: r_ds_sync_data <= r_ds_sync_data;
    endcase
end
// 0x21 中速/低速状态信息
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_ms_ls_status <= 'd0;
    else case (i_para_type)
        8'h21:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd27)
                r_ms_ls_status[39 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_ms_ls_status <= r_ms_ls_status;
        end
        default: r_ms_ls_status <= r_ms_ls_status;
    endcase
end
// 0x22 下行统计信息
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_ds_statistics <= 'd0;
    else case (i_para_type)
        8'h22:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd66)
                r_ds_statistics[351 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_ds_statistics <= r_ds_statistics;
        end
        default: r_ds_statistics <= r_ds_statistics;
    endcase
end
// 0x23 上行统计信息
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_us_statistics <= 'd0;
    else case (i_para_type)
        8'h23:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd74)
                r_us_statistics[415 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_us_statistics <= r_us_statistics;
        end
        default: r_us_statistics <= r_us_statistics;
    endcase
end
// 0x30 软件版本信息
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(!i_rst_n)
        r_software_info <= 'd0;
    else case (i_para_type)
        8'h30:begin
            if (i_rd_cnt >= 'd23 && i_rd_cnt <= 'd26)
                r_software_info[31 - i_rd_cnt_sub_d23*8 -:8] <= i_ram_in;
            else
                r_software_info <= r_software_info;
        end
        default: r_software_info <= r_software_info;
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// output
//---------------------------------------------------------------------
initial begin
    o_soft_rst_n             = 'd0;                                 // 0x00 output reg         [   7: 0] 
    o_FixedFre_or_FreHop_mod = 'd0;                                 // 0x10 output reg         [   7: 0] 
    o_rx_freq                = 'd0;                                 // 0x11 output reg         [  63: 0] 
    o_down_step_freq         = 'd0;                                 // 0x12 output reg         [  31: 0] 
    o_init_tod_in            = 'd0;                                 // 0x13 output reg         [  47: 0] 
    o_us_ds_para             = 'd0;                                 // 0x14 output reg         [  47: 0] 
    o_ds_timeslot            = 'd0;                                 // 0x15 output reg         [ 255: 0] 

    o_statistical_info_rst   = 'd0;                                 // 0x18 output reg         [   7: 0]       

    o_trans_latency_compens  = 'd0;                                 // 0x05 output reg         [  31: 0]     
    o_us_ms_addr_crc         = 'd0;                                 // 0x06 output reg         [  31: 0]     
    o_us_fre_offset_compens  = 'd0;                                 // 0x07 output reg         [  31: 0]     
    o_us_sync_en             = 'd0;                                 // 0x08 output reg         [ 135: 0]     
    o_us_send_choose         = 'd0;                                 // 0x09 output reg         [  23: 0]     
    o_ls_carrier_cfg         = 'd0;                                 // 0x0B output reg         [ 135: 0]     
    o_ms_timeslot            = 'd0;                                 // 0x0C output reg         [ 175: 0]     

    o_ds_sync_data           = 'd0;                                 // 0x20 output reg         [ 103: 0]   
    o_ms_ls_status           = 'd0;                                 // 0x21 output reg         [  39: 0]   
    o_ds_statistics          = 'd0;                                 // 0x22 output reg         [ 351: 0]   
    o_us_statistics          = 'd0;                                 // 0x23 output reg         [ 415: 0]   
    o_software_info          = 'd0;                                 // 0x30 output reg         [  31: 0]   
end

always@(posedge i_clk163m84)begin
    if (i_crc_ok) begin
        o_soft_rst_n             <= r_soft_rst_n             ;
        o_FixedFre_or_FreHop_mod <= r_FixedFre_or_FreHop_mod ;
        o_rx_freq                <= r_rx_freq                ;
        o_down_step_freq         <= r_down_step_freq         ;
        o_init_tod_in            <= r_init_tod_in            ;
        o_us_ds_para             <= r_us_ds_para             ;
        o_ds_timeslot            <= r_ds_timeslot            ;
    
        o_statistical_info_rst   <= r_statistical_info_rst;
    
        o_trans_latency_compens  <= r_trans_latency_compens ;
        o_us_ms_addr_crc         <= r_us_ms_addr_crc        ;
        o_us_fre_offset_compens  <= r_us_fre_offset_compens ;
        o_us_sync_en             <= r_us_sync_en            ;
        o_us_send_choose         <= r_us_send_choose        ;
        o_ls_carrier_cfg         <= r_ls_carrier_cfg        ;
        o_ms_timeslot            <= r_ms_timeslot           ;
    
        o_ds_sync_data           <= r_ds_sync_data ;
        o_ms_ls_status           <= r_ms_ls_status ;
        o_ds_statistics          <= r_ds_statistics;
        o_us_statistics          <= r_us_statistics;
        o_software_info          <= r_software_info;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//--------------------------------------------------------------------- 
ila_rec_para ila_rec_para_inst (
    .clk                                (i_clk163m84               ),// input wire clk

    .probe0                             (i_crc_ok                  ),// input wire [0:0]  probe0  
    .probe1                             (i_para_type               ),// input wire [7:0]  probe1 
    .probe2                             (i_ram_in                  ),// input wire [7:0]  probe2 
    .probe3                             (i_rd_cnt                  ),// input wire [15:0]  probe3 
    .probe4                             (r_trans_latency_compens   ),// input wire [31:0]  probe4 
    .probe5                             (r_init_tod_in             ),// input wire [47:0]  probe5 
    .probe6                             (r_soft_rst_n              ),// input wire [7:0]  probe6
    .probe7                             (o_config_valid            ),// input wire [0:0]  probe7 
    .probe8                             (o_config                  ) // input wire [7:0]  probe8
);

vio_Mctrl_rec_para vio_Mctrl_rec_para_inst (
    .clk                                (i_clk163m84               ),// input wire clk
    .probe_in0                          (o_FixedFre_or_FreHop_mod  ),// input wire [7 : 0] probe_in0
    .probe_in1                          (o_rx_freq                 ),// input wire [63 : 0] probe_in1
    .probe_in2                          (o_down_step_freq          ),// input wire [31 : 0] probe_in2
    .probe_in3                          (o_init_tod_in             ),// input wire [47 : 0] probe_in3
    .probe_in4                          (o_us_ds_para              ),// input wire [47 : 0] probe_in4
    .probe_in5                          (o_ds_timeslot             ),// input wire [255 : 0] probe_in5
    .probe_in6                          (o_statistical_info_rst    ),// input wire [7 : 0] probe_in6
    .probe_in7                          (o_trans_latency_compens   ),// input wire [31 : 0] probe_in7
    .probe_in8                          (o_us_ms_addr_crc          ),// input wire [31 : 0] probe_in8
    .probe_in9                          (o_us_fre_offset_compens   ),// input wire [31 : 0] probe_in9
    .probe_in10                         (o_us_sync_en              ),// input wire [135 : 0] probe_in10
    .probe_in11                         (o_us_send_choose          ),// input wire [23 : 0] probe_in11
    .probe_in12                         (o_ls_carrier_cfg          ),// input wire [135 : 0] probe_in12
    .probe_in13                         (o_ms_timeslot             ),// input wire [174 : 0] probe_in13
    .probe_in14                         (o_ds_sync_data            ),// input wire [103 : 0] probe_in14
    .probe_in15                         (o_ms_ls_status            ),// input wire [39 : 0] probe_in15
    .probe_in16                         (o_ds_statistics[351:256]  ),// input wire [95 : 0] probe_in16
    .probe_in17                         (o_ds_statistics[255:0]    ),// input wire [255 : 0] probe_in17
    .probe_in18                         (o_us_statistics[415:256]  ),// input wire [159 : 0] probe_in18
    .probe_in19                         (o_us_statistics[255:0]    ),// input wire [255 : 0] probe_in19
    .probe_in20                         (o_software_info           ) // input wire [31 : 0] probe_in20
);
endmodule