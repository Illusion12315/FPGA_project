`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: chen xiong zhi
// 
// Create Date: 2024/06/01 16:48:01
// Design Name: 
// Module Name: PZ_ku115_top
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
// `default_nettype none
//`define srio_4x_debug 

module PZ_ku115_top #(
    parameter                           SRIO_4X_CH_NUM            = 8     ,  
    parameter                           SRIO_4X_GT_CLOCK_NUM      = 8     ,
    parameter                           SRIO_1X_CH_NUM            = 12    ,  
    parameter                           SRIO_1X_GT_CLOCK_NUM      = 3     ,
    parameter                           SRIO_ONCE_LENGTH          = 8     ,
    parameter                           SRIO_WR_DATA_WIDTH        = 128   , 
    parameter                           SRIO_RD_DATA_WIDTH        = 128   ,
    parameter                           SRIO_4X_LINK_WIDTH        = 4     ,                          // 1- X1; 2 - X2; 4 - X4; 8 - X8   
    parameter                           SRIO_1X_LINK_WIDTH        = 1     ,

    parameter                           US_CHANNEL                = 6     ,
    // 0x12 0x13 0x14 0x15 0x16 0x1d
    // 0    1    2    3    4    5
    parameter                           DS_CHANNEL                = 6     ,
    // 0x17 0x18 0x19 0x1a 0x1b 0x1c
    // 0    1    2    3    4    5
    parameter                           TOTAL_NUM                 = 104   
) (
//---------------------------------SLR 0--------------------------------//
    input  wire                         SYSCLK1_SLR0_P             ,
    input  wire                         SYSCLK1_SLR0_N             ,

    input  wire                         SYSCLK_SLR0                ,

    input  wire                         PS_GPIO0                   ,
    input  wire                         PS_GPIO1                   ,
    input  wire                         PS_GPIO2                   ,
    
    output wire        [  44: 0]        GPIO1V8                    ,
    
    input  wire                         Z7_I2C0_SCL                ,
    inout  wire                         Z7_I2C0_SDA                ,
    input  wire                         Z7_I2C1_SCL                ,
    inout  wire                         Z7_I2C1_SDA                ,

    input  wire                         Z7_KU115_GPIO1             ,
    input  wire                         Z7_KU115_GPIO2             ,
    input  wire                         Z7_KU115_GPIO3             ,
    input  wire                         Z7_KU115_GPIO4             ,
    input  wire                         Z7_KU115_GPIO5             ,
    input  wire                         Z7_KU115_GPIO6             ,
    // SRIO LOCATION SLR0
    // 4x
    // [0] bank 224; [1] bank 225; [2] bank 226; [3] bank 227; [4] bank 228;
    // [7] bank 126;

//---------------------------------SLR 1--------------------------------//
    input  wire                         SYSCLK1_SLR1_P             ,
    input  wire                         SYSCLK1_SLR1_N             ,

    input  wire                         SYSCLK_SLR1                ,
    // SRIO LOCATION SLR1
    // 4x
    // [5] bank 229; [6] bank 230; 
    
    // 1x
    // [0] [1] [2] [3] bank 231; [4] [5] [6] [7] bank 232; [8] [9] [10] [11] bank 233; 


//-------------------------------SRIO Interface------------------------//
    input  wire        [SRIO_4X_GT_CLOCK_NUM-1: 0]srio_refclkp_4x  ,// 125MHz differential clock
    input  wire        [SRIO_4X_GT_CLOCK_NUM-1: 0]srio_refclkn_4x  ,// 125MHz differential clock
    input  wire        [SRIO_4X_CH_NUM*SRIO_4X_LINK_WIDTH-1: 0]srio_rxp_4x,// Serial Receive Data +
    input  wire        [SRIO_4X_CH_NUM*SRIO_4X_LINK_WIDTH-1: 0]srio_rxn_4x,// Serial Receive Data -
    output wire        [SRIO_4X_CH_NUM*SRIO_4X_LINK_WIDTH-1: 0]srio_txp_4x,// Serial Transmit Data +
    output wire        [SRIO_4X_CH_NUM*SRIO_4X_LINK_WIDTH-1: 0]srio_txn_4x,// Serial Transmit Data -

    input  wire        [SRIO_1X_GT_CLOCK_NUM-1: 0]srio_refclkp_1x  ,// 125MHz differential clock
    input  wire        [SRIO_1X_GT_CLOCK_NUM-1: 0]srio_refclkn_1x  ,// 125MHz differential clock
    input  wire        [SRIO_1X_CH_NUM*SRIO_1X_LINK_WIDTH-1: 0]srio_rxp_1x,// Serial Receive Data +
    input  wire        [SRIO_1X_CH_NUM*SRIO_1X_LINK_WIDTH-1: 0]srio_rxn_1x,// Serial Receive Data -
    output wire        [SRIO_1X_CH_NUM*SRIO_1X_LINK_WIDTH-1: 0]srio_txp_1x,// Serial Transmit Data +
    output wire        [SRIO_1X_CH_NUM*SRIO_1X_LINK_WIDTH-1: 0]srio_txn_1x 

    );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
    wire                                global_clk100m             ;
    wire                                global_clk50m              ;

    // wire                                clk50m_slr0                ;
    // wire                                clk100m_slr0               ;
    wire                                hw_arst_n_slr0             ;
    wire                                sw_arst_n_slr0             ;
    
(*MAX_FANOUT = 500*)
    reg                                 sw_srst_n_slr0             ;
    reg                                 sw_srst_n_slr0_r1          ;
    // wire                                clk50m_slr1                ;
    // wire                                clk100m_slr1               ;

    wire                                hw_arst_n_slr1             ;
    wire                                sw_arst_n_slr1             ;
(*MAX_FANOUT = 500*)
    reg                                 sw_srst_n_slr1             ;

    wire               [US_CHANNEL-1: 0]us_rd_clk                  ;
    wire               [US_CHANNEL-1: 0]us_rd_en                   ;
    wire               [US_CHANNEL*128-1: 0]us_rd_dout             ;
    wire               [US_CHANNEL-1: 0]us_rd_empty                ;

    wire                                ds_rd_clk                  ;
    wire                                ds_rd_en                   ;
    reg                [ 127: 0]        ds_rd_out                  ;
    reg                                 ds_rd_empty                ;

    wire               [US_CHANNEL*8-1: 0]us_prased_src_id_r1      ;
    wire               [US_CHANNEL*8-1: 0]us_prased_des_id_r1      ;
    wire               [US_CHANNEL*8-1: 0]us_prased_data_type_r1   ;
    wire               [US_CHANNEL*8-1: 0]us_prased_data_channel_r1  ;
    wire               [US_CHANNEL*16-1: 0]us_prased_data_field_len_r1  ;
    wire               [US_CHANNEL-1: 0]us_timming_valid           ;
    wire               [US_CHANNEL*128-1: 0]us_timming_data        ;
    wire               [US_CHANNEL-1: 0]us_burst_valid             ;
    wire               [US_CHANNEL*128-1: 0]us_burst_data          ;

    wire               [TOTAL_NUM-1: 0] us_timming_rd_en           ;
    wire               [TOTAL_NUM*128-1: 0]us_timming_dout         ;
    wire               [TOTAL_NUM-1: 0] us_timming_empty           ;
    wire               [TOTAL_NUM*12-1: 0]us_timming_cache_count   ;

    wire               [   7: 0]        ds_prased_src_id_r1        ;
    wire               [   7: 0]        ds_prased_des_id_r1        ;
    wire               [   7: 0]        ds_prased_data_type_r1     ;
    wire               [   7: 0]        ds_prased_data_channel_r1  ;
    wire               [  15: 0]        ds_prased_data_field_len_r1  ;
    wire                                ds_burst_valid             ;
    wire               [ 127: 0]        ds_burst_data              ;
    wire               [DS_CHANNEL-1: 0]ds_burst_wr_en             ;
    wire               [DS_CHANNEL*128-1: 0]ds_burst_dout          ;
    wire               [DS_CHANNEL-1: 0]ds_burst_prog_full         ;

    wire                                us_timming_flow_vld        ;
    wire               [ 127: 0]        us_timming_flow            ;
    reg                                 us_timming_flow_prog_full  ;

//  srio_app_wrapper_4x
    wire                                srio_4x_log_clk            ;
    wire               [SRIO_4X_CH_NUM-1: 0]srio_4x_log_rst        ;
    wire               [SRIO_4X_CH_NUM-1: 0]srio_4x_clk_lock       ;
    wire               [SRIO_4X_CH_NUM-1: 0]srio_4x_core_rst       ;
    wire               [SRIO_4X_CH_NUM-1: 0]srio_4x_sys_reset_n    ;
    // SRIO ID   
    wire               [SRIO_4X_CH_NUM*16-1: 0]source_id_4x        ;
    wire               [SRIO_4X_CH_NUM*16-1: 0]dest_id_4x          ;
    wire               [SRIO_4X_CH_NUM*16-1: 0]device_id_4x        ;
    wire               [SRIO_4X_CH_NUM*16-1: 0]device_id_set_4x    ;
    wire               [SRIO_4X_CH_NUM-1: 0]id_set_done_4x         ;
    // Status Signals
    wire               [SRIO_4X_CH_NUM-1: 0]port_4x_initialized    ;
    wire               [SRIO_4X_CH_NUM-1: 0]link_4x_initialized    ;
    wire               [SRIO_4X_CH_NUM-1: 0]mode_4x_1x             ;
    // FIFO Interface for Packet Transmit
    wire               [SRIO_4X_CH_NUM-1: 0]fifo_wrreq_pkt_tx_4x   ;
    wire               [SRIO_4X_CH_NUM*SRIO_WR_DATA_WIDTH-1: 0]fifo_data_pkt_tx_4x  ;
    wire               [SRIO_4X_CH_NUM-1: 0]fifo_prog_full_pkt_tx_4x  ;
    // FIFO Interface for Packet Receive
    wire               [SRIO_4X_CH_NUM-1: 0]fifo_rdreq_pkt_rx_4x   ;
    wire               [SRIO_4X_CH_NUM*SRIO_RD_DATA_WIDTH-1: 0]fifo_q_pkt_rx_4x  ;
    wire               [SRIO_4X_CH_NUM-1: 0]fifo_empty_pkt_rx_4x   ;
    wire               [SRIO_4X_CH_NUM-1: 0]fifo_prog_empty_pkt_rx_4x  ;

//  srio_app_wrapper_1x
    wire                                srio_1x_log_clk            ;
    wire               [SRIO_1X_CH_NUM-1: 0]srio_1x_log_rst        ;
    wire               [SRIO_1X_CH_NUM-1: 0]srio_1x_clk_lock       ;
    wire               [SRIO_1X_CH_NUM-1: 0]srio_1x_core_rst       ;
    wire               [SRIO_1X_CH_NUM-1: 0]srio_1x_sys_reset_n    ;

    // SRIO ID   
    wire               [SRIO_1X_CH_NUM*16-1: 0]source_id_1x        ;
    wire               [SRIO_1X_CH_NUM*16-1: 0]dest_id_1x          ;
    wire               [SRIO_1X_CH_NUM*16-1: 0]device_id_1x        ;
    wire               [SRIO_1X_CH_NUM*16-1: 0]device_id_set_1x    ;
    wire               [SRIO_1X_CH_NUM-1: 0]id_set_done_1x         ;
    // Status Signals
    wire               [SRIO_1X_CH_NUM-1: 0]port_1x_initialized    ;
    wire               [SRIO_1X_CH_NUM-1: 0]link_1x_initialized    ;
    wire               [SRIO_1X_CH_NUM-1: 0]mode_1x_1x             ;
    // FIFO Interface for Packet Transmit
    wire               [SRIO_1X_CH_NUM-1: 0]fifo_wrreq_pkt_tx_1x   ;
    wire               [SRIO_1X_CH_NUM*SRIO_WR_DATA_WIDTH-1: 0]fifo_data_pkt_tx_1x  ;
    wire               [SRIO_1X_CH_NUM-1: 0]fifo_prog_full_pkt_tx_1x  ;
    // FIFO Interface for Packet Receive
    wire               [SRIO_1X_CH_NUM-1: 0]fifo_rdreq_pkt_rx_1x   ;
    wire               [SRIO_1X_CH_NUM*SRIO_RD_DATA_WIDTH-1: 0]fifo_q_pkt_rx_1x  ;
    wire               [SRIO_1X_CH_NUM-1: 0]fifo_empty_pkt_rx_1x   ;
    wire               [SRIO_1X_CH_NUM-1: 0]fifo_prog_empty_pkt_rx_1x  ;

    //---------------------------re assign------------------------//
    // FIFO Interface for Packet Transmit
    wire               [(SRIO_1X_CH_NUM+SRIO_4X_CH_NUM)-1: 0]fifo_wrreq_pkt_tx  ;
    wire               [(SRIO_1X_CH_NUM+SRIO_4X_CH_NUM)*SRIO_WR_DATA_WIDTH-1: 0]fifo_data_pkt_tx  ;
    wire               [(SRIO_1X_CH_NUM+SRIO_4X_CH_NUM)-1: 0]fifo_prog_full_pkt_tx  ;
    // FIFO Interface for Packet Receive
    wire               [(SRIO_1X_CH_NUM+SRIO_4X_CH_NUM)-1: 0]fifo_rdreq_pkt_rx  ;
    wire               [(SRIO_1X_CH_NUM+SRIO_4X_CH_NUM)*SRIO_RD_DATA_WIDTH-1: 0]fifo_q_pkt_rx  ;
    wire               [(SRIO_1X_CH_NUM+SRIO_4X_CH_NUM)-1: 0]fifo_empty_pkt_rx  ;
    wire               [(SRIO_1X_CH_NUM+SRIO_4X_CH_NUM)-1: 0]fifo_prog_empty_pkt_rx  ;
    // Status Signals
    wire               [(SRIO_1X_CH_NUM+SRIO_4X_CH_NUM)-1: 0]port_initialized  ;// srio_log_clk
    wire               [(SRIO_1X_CH_NUM+SRIO_4X_CH_NUM)-1: 0]link_initialized  ;// srio_log_clk
    wire               [(SRIO_1X_CH_NUM+SRIO_4X_CH_NUM)-1: 0]mode_1x  ;
    
    wire                                fiber_sw_rst               ;
    wire                                loopback_sel               ;// "0" 不回环;"1"内回环;
    wire               [  15: 0]        dest_id                    ;
    wire               [  15: 0]        device_id_set              ;

    wire               [   7: 0]        base_mode_switch           ;
    wire                                gpio_start_trigger_i       ;

    wire                                time_period_0_25ms         ;
    wire                                time_period_25ms_pluse     ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// assigns
//---------------------------------------------------------------------
    assign                              srio_4x_core_rst          = {hw_arst_n_slr0, {2{hw_arst_n_slr1}}, {5{hw_arst_n_slr0}}};
    assign                              srio_4x_sys_reset_n       = {sw_srst_n_slr0, {2{sw_srst_n_slr1}}, {5{sw_srst_n_slr0}}};

    assign                              srio_1x_core_rst          = {SRIO_1X_CH_NUM{hw_arst_n_slr1}};
    assign                              srio_1x_sys_reset_n       = {SRIO_1X_CH_NUM{sw_srst_n_slr1}};

    assign                              port_initialized          = {
                                                                        port_1x_initialized[11:4],
                                                                        port_4x_initialized[7],
                                                                        port_1x_initialized[3:0],
                                                                        port_4x_initialized[6:0]
                                                                    };
    assign                              link_initialized          = {
                                                                        link_1x_initialized[11:4],
                                                                        link_4x_initialized[7],
                                                                        link_1x_initialized[3:0],
                                                                        link_4x_initialized[6:0]
                                                                    };
    assign                              mode_1x                   = {
                                                                        mode_1x_1x[11:4],
                                                                        mode_4x_1x[7],
                                                                        mode_1x_1x[3:0],
                                                                        mode_4x_1x[6:0]
                                                                    };
    // FIFO Interface for Packet Transmit
    assign                              {
                                            fifo_wrreq_pkt_tx_1x[11:4],
                                            fifo_wrreq_pkt_tx_4x[7],
                                            fifo_wrreq_pkt_tx_1x[3:0],
                                            fifo_wrreq_pkt_tx_4x[6:0]
                                        }                         = fifo_wrreq_pkt_tx;

    assign                              {
                                            fifo_data_pkt_tx_1x[11*128+127 : 4*128],
                                            fifo_data_pkt_tx_4x[7*128+127 : 7*128],
                                            fifo_data_pkt_tx_1x[3*128+127 : 0*128],
                                            fifo_data_pkt_tx_4x[6*128+127 : 0*128]
                                        }                         = fifo_data_pkt_tx;

    assign                              fifo_prog_full_pkt_tx     = {
                                                                        fifo_prog_full_pkt_tx_1x[11:4],
                                                                        fifo_prog_full_pkt_tx_4x[7],
                                                                        fifo_prog_full_pkt_tx_1x[3:0],
                                                                        fifo_prog_full_pkt_tx_4x[6:0]
                                                                    };
    // FIFO Interface for Packet Receive
    assign                              {
                                            fifo_rdreq_pkt_rx_1x[11:4],
                                            fifo_rdreq_pkt_rx_4x[7],
                                            fifo_rdreq_pkt_rx_1x[3:0],
                                            fifo_rdreq_pkt_rx_4x[6:0]
                                        }                         = fifo_rdreq_pkt_rx;

    assign                              fifo_q_pkt_rx             = {
                                                                        fifo_q_pkt_rx_1x[11*128+127 : 4*128],
                                                                        fifo_q_pkt_rx_4x[7*128+127 : 7*128],
                                                                        fifo_q_pkt_rx_1x[3*128+127 : 0*128],
                                                                        fifo_q_pkt_rx_4x[6*128+127 : 0*128]
                                                                    };

    assign                              fifo_empty_pkt_rx         = {
                                                                        fifo_empty_pkt_rx_1x[11:4],
                                                                        fifo_empty_pkt_rx_4x[7],
                                                                        fifo_empty_pkt_rx_1x[3:0],
                                                                        fifo_empty_pkt_rx_4x[6:0]
                                                                    };
    assign                              fifo_prog_empty_pkt_rx    = {
                                                                        fifo_prog_empty_pkt_rx_1x[11:4],
                                                                        fifo_prog_empty_pkt_rx_4x[7],
                                                                        fifo_prog_empty_pkt_rx_1x[3:0],
                                                                        fifo_prog_empty_pkt_rx_4x[6:0]
                                                                    };
    //--------------------------- assign us fifos--------------------//
    assign                              {
                                            fifo_rdreq_pkt_rx[19],  // us_rd[5] KG-I
                                            fifo_rdreq_pkt_rx[12],  // us_rd[4] AI4-2
                                            fifo_rdreq_pkt_rx[9],   // us_rd[3] AI4-1
                                            fifo_rdreq_pkt_rx[10],  // us_rd[2] AI3
                                            fifo_rdreq_pkt_rx[6],   // us_rd[1] AI2
                                            fifo_rdreq_pkt_rx[8]    // us_rd[0] AI1
                                        }                         = us_rd_en;

    assign                              us_rd_dout                = {
                                                                        fifo_q_pkt_rx[19*128+127 : 19*128],
                                                                        fifo_q_pkt_rx[12*128+127 : 12*128],
                                                                        fifo_q_pkt_rx[9*128+127 : 9*128],
                                                                        fifo_q_pkt_rx[10*128+127 : 10*128],
                                                                        fifo_q_pkt_rx[6*128+127 : 6*128],
                                                                        fifo_q_pkt_rx[8*128+127 : 8*128]
                                                                    };

    assign                              us_rd_empty               = {
                                                                        fifo_empty_pkt_rx[19],
                                                                        fifo_empty_pkt_rx[12],
                                                                        fifo_empty_pkt_rx[9],
                                                                        fifo_empty_pkt_rx[10],
                                                                        fifo_empty_pkt_rx[6],
                                                                        fifo_empty_pkt_rx[8]
                                                                    };
                                                                    
    //------------------------ assign ds fifos ---------------------//
                                                                    // KG-O-2, KG-O-1, AO2-2, AO2-1, AO1-2, AO1-1
                                                                    // [5]     [4]     [3]    [2]    [1]    [0]
    assign                              fifo_wrreq_pkt_tx[18:13]  = ds_burst_wr_en;

    assign                              fifo_data_pkt_tx[18*128+127 : 13*128]= ds_burst_dout;

    assign                              ds_burst_prog_full        = fifo_prog_full_pkt_tx[18:13];

    //------------------------ base module fifos -------------------//

    // ds
always@(*)begin
    if (!sw_srst_n_slr0) begin
        ds_rd_out = 'd0;
        ds_rd_empty = -1;
    end
    else case (base_mode_switch)
        8'h40: begin ds_rd_empty = fifo_empty_pkt_rx[11] ; ds_rd_out = fifo_q_pkt_rx[11*128+127 : 11*128]; end
        8'h41: begin ds_rd_empty = fifo_empty_pkt_rx[3] ; ds_rd_out = fifo_q_pkt_rx[3*128+127 : 3*128]; end
        8'h42: begin ds_rd_empty = fifo_empty_pkt_rx[2] ; ds_rd_out = fifo_q_pkt_rx[2*128+127 : 2*128]; end
        8'h43: begin ds_rd_empty = fifo_empty_pkt_rx[0] ; ds_rd_out = fifo_q_pkt_rx[0*128+127 : 0*128]; end
        8'h44: begin ds_rd_empty = fifo_empty_pkt_rx[1] ; ds_rd_out = fifo_q_pkt_rx[1*128+127 : 1*128]; end
        default: begin
            ds_rd_out = 'd0;
            ds_rd_empty = -1;
        end
    endcase
end

    assign                              fifo_rdreq_pkt_rx[11]     = (base_mode_switch == 8'h40) ? ds_rd_en : 'd0;
    assign                              fifo_rdreq_pkt_rx[3]      = (base_mode_switch == 8'h41) ? ds_rd_en : 'd0;
    assign                              fifo_rdreq_pkt_rx[2]      = (base_mode_switch == 8'h42) ? ds_rd_en : 'd0;
    assign                              fifo_rdreq_pkt_rx[0]      = (base_mode_switch == 8'h43) ? ds_rd_en : 'd0;
    assign                              fifo_rdreq_pkt_rx[1]      = (base_mode_switch == 8'h44) ? ds_rd_en : 'd0;

    // us
    assign                              fifo_wrreq_pkt_tx[11]     = us_timming_flow_vld;
    assign                              fifo_wrreq_pkt_tx[3]      = us_timming_flow_vld;
    assign                              fifo_wrreq_pkt_tx[2]      = us_timming_flow_vld;
    assign                              fifo_wrreq_pkt_tx[0]      = us_timming_flow_vld;
    assign                              fifo_wrreq_pkt_tx[1]      = us_timming_flow_vld;
    
    assign                              fifo_data_pkt_tx[11*128+127 : 11*128]= us_timming_flow;
    assign                              fifo_data_pkt_tx[3*128+127 : 3*128]= us_timming_flow;
    assign                              fifo_data_pkt_tx[2*128+127 : 2*128]= us_timming_flow;
    assign                              fifo_data_pkt_tx[0*128+127 : 0*128]= us_timming_flow;
    assign                              fifo_data_pkt_tx[1*128+127 : 1*128]= us_timming_flow;

always@(*)begin
    if (!sw_srst_n_slr0) begin
        us_timming_flow_prog_full = -1;
    end
    else case (base_mode_switch)
        8'h40: begin us_timming_flow_prog_full = fifo_prog_full_pkt_tx[11]; end
        8'h41: begin us_timming_flow_prog_full = fifo_prog_full_pkt_tx[3]; end
        8'h42: begin us_timming_flow_prog_full = fifo_prog_full_pkt_tx[2]; end
        8'h43: begin us_timming_flow_prog_full = fifo_prog_full_pkt_tx[0]; end
        8'h44: begin us_timming_flow_prog_full = fifo_prog_full_pkt_tx[1]; end
        default: begin
            us_timming_flow_prog_full = -1;
        end
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// modules
//---------------------------------------------------------------------
clk_rst_wrapper  clk_rst_wrapper_inst (
//---------------------------------SLR 0--------------------------------//
    .SYSCLK1_SLR0_P                     (SYSCLK1_SLR0_P            ),
    .SYSCLK1_SLR0_N                     (SYSCLK1_SLR0_N            ),
    .SYSCLK_SLR0                        (SYSCLK_SLR0               ),
    // .clk50m_slr0                        (clk50m_slr0               ),
    // .clk100m_slr0                       (clk100m_slr0              ),
    .hw_arst_n_slr0                     (hw_arst_n_slr0            ),// global_clk100m
    .sw_arst_n_slr0                     (sw_arst_n_slr0            ),// global_clk100m
//---------------------------------SLR 1--------------------------------//
    .SYSCLK1_SLR1_P                     (SYSCLK1_SLR1_P            ),
    .SYSCLK1_SLR1_N                     (SYSCLK1_SLR1_N            ),
    .SYSCLK_SLR1                        (SYSCLK_SLR1               ),
    // .clk50m_slr1                        (clk50m_slr1               ),
    // .clk100m_slr1                       (clk100m_slr1              ),
    .hw_arst_n_slr1                     (hw_arst_n_slr1            ),// global_clk100m
    .sw_arst_n_slr1                     (sw_arst_n_slr1            ),// global_clk100m
//-----------------------------global--------------------------------//
    .global_clk100m                     (global_clk100m            ),
    .global_clk50m                      (global_clk50m             ) 
    );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// GPIO PWM
//---------------------------------------------------------------------
gpio_wrapper  gpio_wrapper_inst (
    .sys_clk_i                          (global_clk100m            ),
    .rst_n_i                            (sw_arst_n_slr0            ),

    .gpio_start_trigger_i               (gpio_start_trigger_i      ),
    .GPIO1V8                            (GPIO1V8                   ) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// gpio time manage
//---------------------------------------------------------------------
time_manage_wrapper time_manage_wrapper_inst(
    .sys_clk_i                          (global_clk100m            ),
    .rst_n_i                            (sw_arst_n_slr0            ),

    .gpio_start_trigger_i               (gpio_start_trigger_i      ),
    .time_period_0_25ms_o               (time_period_0_25ms        ),
    .time_period_25ms_pluse_o           (time_period_25ms_pluse    ) 
);
always@(posedge global_clk100m)begin
    sw_srst_n_slr0 <= sw_arst_n_slr0 && ~time_period_0_25ms;
end
always@(posedge global_clk100m)begin
    sw_srst_n_slr0_r1 <= sw_srst_n_slr0;
    sw_srst_n_slr1 <= sw_srst_n_slr0_r1;
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// SRIO Application Top Level Wrapper
//---------------------------------------------------------------------  
srio_multi_4x_app_wrapper #(
    .SRIO_CH_NUM                        (SRIO_4X_CH_NUM            ),
    .SRIO_GT_CLOCK_NUM                  (SRIO_4X_GT_CLOCK_NUM      ),
    .SRIO_ONCE_LENGTH                   (SRIO_ONCE_LENGTH          ),
    .SRIO_WR_DATA_WIDTH                 (SRIO_WR_DATA_WIDTH        ),
    .SRIO_RD_DATA_WIDTH                 (SRIO_RD_DATA_WIDTH        ),
    .SRIO_LINK_WIDTH                    (SRIO_4X_LINK_WIDTH        ) 
)
u_srio_app_4x (
    // Clock and Reset# Interface
    .srio_log_clk                       (srio_4x_log_clk           ),// output
    .srio_log_rst                       (srio_4x_log_rst           ),// output
    .srio_clk_lock                      (srio_4x_clk_lock          ),// output
    .srio_core_rst                      (srio_4x_core_rst          ),// input
    .fiber_sw_rst                       ({SRIO_4X_CH_NUM{fiber_sw_rst}}),// input
    .clk_50m                            (global_clk50m             ),// input
    .sys_reset_n                        (srio_4x_sys_reset_n       ),// input
        
    // GT Loopback Ctrl    
    .loopback_sel                       ({SRIO_4X_CH_NUM{loopback_sel}}),// input
        
    // SRIO ID  
    .source_id                          (source_id_4x              ),// output
    .dest_id                            ({SRIO_4X_CH_NUM{dest_id}} ),// input
    .device_id                          (device_id_4x              ),// output
    .device_id_set                      ({SRIO_4X_CH_NUM{device_id_set}}),// input
    .id_set_done                        (id_set_done_4x            ),// output
        
    // Status Signals
    .port_initialized                   (port_4x_initialized       ),// output
    .link_initialized                   (link_4x_initialized       ),// output
    .mode_1x                            (mode_4x_1x                ),// output
        
    // FIFO Interface for Packet Transmit
    .fifo_wrclk_pkt_tx                  ({SRIO_4X_CH_NUM{global_clk100m}}),// input
    .fifo_wrreq_pkt_tx                  (fifo_wrreq_pkt_tx_4x      ),// input
    .fifo_data_pkt_tx                   (fifo_data_pkt_tx_4x       ),// input
    .fifo_prog_full_pkt_tx              (fifo_prog_full_pkt_tx_4x  ),// output
        
    // FIFO Interface for Packet Receive
    .fifo_rdclk_pkt_rx                  ({SRIO_4X_CH_NUM{global_clk100m}}),// input
    .fifo_rdreq_pkt_rx                  (fifo_rdreq_pkt_rx_4x      ),// input
    .fifo_q_pkt_rx                      (fifo_q_pkt_rx_4x          ),// output
    .fifo_empty_pkt_rx                  (fifo_empty_pkt_rx_4x      ),// output
    .fifo_prog_empty_pkt_rx             (fifo_prog_empty_pkt_rx_4x ),// output
        
    // SRIO Interface
    .srio_refclkp                       (srio_refclkp_4x           ),// input
    .srio_refclkn                       (srio_refclkn_4x           ),// input
    .srio_rxp                           (srio_rxp_4x               ),// input
    .srio_rxn                           (srio_rxn_4x               ),// input
    .srio_txp                           (srio_txp_4x               ),// output
    .srio_txn                           (srio_txn_4x               ) // output
);

srio_multi_1x_app_wrapper #(
    .SRIO_CH_NUM                        (SRIO_1X_CH_NUM            ),
    .SRIO_GT_CLOCK_NUM                  (SRIO_1X_GT_CLOCK_NUM      ),
    .SRIO_ONCE_LENGTH                   (SRIO_ONCE_LENGTH          ),
    .SRIO_WR_DATA_WIDTH                 (SRIO_WR_DATA_WIDTH        ),
    .SRIO_RD_DATA_WIDTH                 (SRIO_RD_DATA_WIDTH        ),
    .SRIO_LINK_WIDTH                    (SRIO_1X_LINK_WIDTH        ) 
)
u_srio_app_1x(
    // Clock and Reset# Interface
    .srio_log_clk                       (srio_1x_log_clk           ),
    .srio_log_rst                       (srio_1x_log_rst           ),
    .srio_clk_lock                      (srio_1x_clk_lock          ),
    .srio_core_rst                      (srio_1x_core_rst          ),
    .fiber_sw_rst                       ({SRIO_1X_CH_NUM{fiber_sw_rst}}),
    .clk_50m                            (global_clk50m             ),
    .sys_reset_n                        (srio_1x_sys_reset_n       ),
        
    // GT Loopback Ctrl    
    .loopback_sel                       ({SRIO_1X_CH_NUM{loopback_sel}}),
        
    // SRIO ID  
    .source_id                          (source_id_1x              ),
    .dest_id                            ({SRIO_1X_CH_NUM{dest_id}} ),
    .device_id                          (device_id_1x              ),
    .device_id_set                      ({SRIO_1X_CH_NUM{device_id_set}}),
    .id_set_done                        (id_set_done_1x            ),
        
    // Status Signals
    .port_initialized                   (port_1x_initialized       ),
    .link_initialized                   (link_1x_initialized       ),
    .mode_1x                            (mode_1x_1x                ),
        
    // FIFO Interface for Packet Transmit
    .fifo_wrclk_pkt_tx                  ({SRIO_1X_CH_NUM{global_clk100m}}),
    .fifo_wrreq_pkt_tx                  (fifo_wrreq_pkt_tx_1x      ),
    .fifo_data_pkt_tx                   (fifo_data_pkt_tx_1x       ),
    .fifo_prog_full_pkt_tx              (fifo_prog_full_pkt_tx_1x  ),
        
    // FIFO Interface for Packet Receive
    .fifo_rdclk_pkt_rx                  ({SRIO_1X_CH_NUM{global_clk100m}}),
    .fifo_rdreq_pkt_rx                  (fifo_rdreq_pkt_rx_1x      ),
    .fifo_q_pkt_rx                      (fifo_q_pkt_rx_1x          ),
    .fifo_empty_pkt_rx                  (fifo_empty_pkt_rx_1x      ),
    .fifo_prog_empty_pkt_rx             (fifo_prog_empty_pkt_rx_1x ),
        
    // SRIO Interface
    .srio_refclkp                       (srio_refclkp_1x           ),
    .srio_refclkn                       (srio_refclkn_1x           ),
    .srio_rxp                           (srio_rxp_1x               ),
    .srio_rxn                           (srio_rxn_1x               ),
    .srio_txp                           (srio_txp_1x               ),
    .srio_txn                           (srio_txn_1x               ) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// 
//---------------------------------------------------------------------

msg_receive_wrapper#(
    .CHANNEL                            (US_CHANNEL                ) 
)
us_msg_receive_wrapper_inst(
    .sys_clk_i                          (global_clk100m            ),
    .rst_n_i                            (sw_srst_n_slr1            ),

    .rd_en_o                            (us_rd_en                  ),
    .rd_din_i                           (us_rd_dout                ),
    .rd_empty_i                         (us_rd_empty               ),

    .prased_src_id_r1                   (us_prased_src_id_r1       ),
    .prased_des_id_r1                   (us_prased_des_id_r1       ),
    .prased_data_type_r1                (us_prased_data_type_r1    ),
    .prased_data_channel_r1             (us_prased_data_channel_r1 ),
    .prased_data_field_len_r1           (us_prased_data_field_len_r1),

    .us_timming_valid_o                 (us_timming_valid          ),
    .us_timming_data_o                  (us_timming_data           ),

    .us_burst_valid_o                   (us_burst_valid            ),
    .us_burst_data_o                    (us_burst_data             ) 
);

us_timming_wrapper#(
    .US_CHANNEL                         (US_CHANNEL                ),
    .TOTAL_NUM                          (TOTAL_NUM                 ) 
)
us_timming_wrapper_inst(
    .sys_clk_i                          (global_clk100m            ),
    .rst_n_i                            (sw_srst_n_slr0            ),

    .prased_src_id_r1                   (us_prased_src_id_r1       ),
    .prased_des_id_r1                   (us_prased_des_id_r1       ),
    .prased_data_type_r1                (us_prased_data_type_r1    ),
    .prased_data_channel_r1             (us_prased_data_channel_r1 ),
    .prased_data_field_len_r1           (us_prased_data_field_len_r1),

    .us_timming_valid_i                 (us_timming_valid          ),
    .us_timming_data_i                  (us_timming_data           ),

    .us_burst_valid_i                   (us_burst_valid            ),
    .us_burst_data_i                    (us_burst_data             ),

    .us_timming_rd_en_i                 (us_timming_rd_en          ),
    .us_timming_dout_o                  (us_timming_dout           ),
    .us_timming_empty_o                 (us_timming_empty          ),
    .us_timming_cache_count_o           (us_timming_cache_count    ) 
);

us_data_forwarding#(
    .TOTAL_NUM                          (TOTAL_NUM                 ) 
)
us_data_forwarding_inst(
    .sys_clk_i                          (global_clk100m            ),
    .rst_n_i                            (sw_srst_n_slr0            ),
    .time25ms_pluse_i                   (time_period_25ms_pluse    ),

    .us_timming_rd_en_o                 (us_timming_rd_en          ),
    .us_timming_dout_i                  (us_timming_dout           ),
    .us_timming_empty_i                 (us_timming_empty          ),
    .us_timming_cache_count_i           (us_timming_cache_count    ),

    .us_timming_flow_vld_o              (us_timming_flow_vld       ),
    .us_timming_flow_o                  (us_timming_flow           ),
    .us_timming_flow_prog_full_i        (us_timming_flow_prog_full ) 
);

msg_receive_wrapper#(
    .CHANNEL                            (1                         ) 
)
ds_msg_receive_wrapper_inst(
    .sys_clk_i                          (global_clk100m            ),
    .rst_n_i                            (sw_srst_n_slr0            ),

    .rd_clk_o                           (ds_rd_clk                 ),
    .rd_en_o                            (ds_rd_en                  ),
    .rd_din_i                           (ds_rd_out                 ),
    .rd_empty_i                         (ds_rd_empty               ),

    .prased_src_id_r1                   (ds_prased_src_id_r1       ),
    .prased_des_id_r1                   (ds_prased_des_id_r1       ),
    .prased_data_type_r1                (ds_prased_data_type_r1    ),
    .prased_data_channel_r1             (ds_prased_data_channel_r1 ),
    .prased_data_field_len_r1           (ds_prased_data_field_len_r1),

    .ds_burst_valid_o                   (ds_burst_valid            ),
    .ds_burst_data_o                    (ds_burst_data             ) 
);

ds_data_forwarding#(
    .DS_CHANNEL                         (DS_CHANNEL                ) 
)
ds_data_forwarding_inst(
    .sys_clk_i                          (global_clk100m            ),
    .rst_n_i                            (sw_srst_n_slr0            ),
    .prased_src_id_r1                   (ds_prased_src_id_r1       ),
    .prased_des_id_r1                   (ds_prased_des_id_r1       ),
    .prased_data_type_r1                (ds_prased_data_type_r1    ),
    .prased_data_channel_r1             (ds_prased_data_channel_r1 ),
    .prased_data_field_len_r1           (ds_prased_data_field_len_r1),

    .ds_burst_valid_i                   (ds_burst_valid            ),
    .ds_burst_data_i                    (ds_burst_data             ),

    .ds_burst_wr_en_o                   (ds_burst_wr_en            ),
    .ds_burst_dout_o                    (ds_burst_dout             ),
    .ds_burst_prog_full_i               (ds_burst_prog_full        ) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
vio_ctrl vio_ctrl_inst(
    .clk                                (global_clk50m             ),// input wire clk
    .probe_out0                         (fiber_sw_rst              ),// output wire [0 : 0] probe_out0
    .probe_out1                         (loopback_sel              ),// output wire [0 : 0] probe_out1
    .probe_out2                         (dest_id                   ),// output wire [15 : 0] probe_out2
    .probe_out3                         (device_id_set             ),// output wire [15 : 0] probe_out3
    .probe_out4                         (gpio_start_trigger_i      ),// output wire [0 : 0] probe_out4
    .probe_out5                         (base_mode_switch          ) // output wire [7 : 0] probe_out5
    );

ila_top ila_top_inst (
    .clk                                (global_clk100m            ),// input wire clk

    .probe0                             (ds_rd_en                  ),// input wire [0:0]  probe0  
    .probe1                             (ds_rd_out                 ),// input wire [127:0]  probe1 
    .probe2                             (ds_rd_empty               ),// input wire [0:0]  probe2 
    .probe3                             (us_rd_en                  ),// input wire [0:0]  probe3 
    .probe4                             (us_timming_valid          ),// input wire [127:0]  probe4 
    .probe5                             (us_timming_rd_en          ) // input wire [0:0]  probe5
);


endmodule