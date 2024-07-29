`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Chen Xiong Zhi
// Engineer: 
// 
// Create Date: 2024/06/17 11:12:52
// Design Name: 
// Module Name: Top
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
//`default_nettype none


module Top #(
    parameter                           SRIO_CH_NUM               = 1     ,  
    parameter                           SRIO_ONCE_LENGTH          = 8     ,
    parameter                           SRIO_WR_DATA_WIDTH        = 128   , 
    parameter                           SRIO_RD_DATA_WIDTH        = 128   ,
    parameter                           SRIO_LINK_WIDTH           = 1     ,              // 1- X1; 2 - X2; 4 - X4; 8 - X8   
    
    parameter                           ADC_NUM                   = 3     ,
    parameter                           SENSOR_NUM                = 18    
) (
    input  wire                         SYSCLK                     ,// from ctystal oscillator

    input  wire                         SYSCLK_P                   ,// from lvds ctystal oscillator
    input  wire                         SYSCLK_N                   ,

    input  wire                         K7_REFCLK_P                ,// from vpx
    input  wire                         K7_REFCLK_N                ,

    // input  wire                         K7_I2C_0_SCL               ,
    // inout  wire                         K7_I2C_0_SDA               ,
    // input  wire                         K7_I2C_1_SCL               ,
    // inout  wire                         K7_I2C_1_SDA               ,

    // input  wire                         K7_I2C_TEMP_SCL            ,
    // inout  wire                         K7_I2C_TEMP_SDA            ,
    // output wire                         K7_I2C_TEMP_ALERT          ,

    // ad7656
    input  wire                         adc_trigger_gpio           ,
    
    output wire                         ADC1_CS_FPGA               ,
    output wire                         ADC1_CONVST_FPGA           ,
    output wire                         ADC1_RESET_FPGA            ,
    output wire                         ADC1_RD_FPGA               ,
    output wire                         WR_1_FPGA                  ,
    input  wire                         ADC1_BUSY_FPGA             ,
    inout  wire        [  15: 0]        ADC1_DB                    ,

    output wire                         ADC2_CS_FPGA               ,
    output wire                         ADC2_CONVST_FPGA           ,
    output wire                         ADC2_RESET_FPGA            ,
    output wire                         ADC2_RD_FPGA               ,
    output wire                         WR_2_FPGA                  ,
    input  wire                         ADC2_BUSY_FPGA             ,
    inout  wire        [  15: 0]        ADC2_DB                    ,
    
    output wire                         ADC3_CS_FPGA               ,
    output wire                         ADC3_CONVST_FPGA           ,
    output wire                         ADC3_RESET_FPGA            ,
    output wire                         ADC3_RD_FPGA               ,
    output wire                         WR_3_FPGA                  ,
    input  wire                         ADC3_BUSY_FPGA             ,
    inout  wire        [  15: 0]        ADC3_DB                    ,
    
//    output wire                         ADC4_CS_FPGA               ,
//    output wire                         ADC4_CONVST_FPGA           ,
//    output wire                         ADC4_RESET_FPGA            ,
//    output wire                         ADC4_RD_FPGA               ,
//    output wire                         WR_4_FPGA                  ,
//    input  wire                         ADC4_BUSY_FPGA             ,
//    inout  wire        [  15: 0]        ADC4_DB                    ,

    // GPIO
    // input  wire                         K7_GPIO_0                  ,
    // input  wire                         K7_GPIO_1                  ,
    // input  wire                         K7_GPIO_2                  ,
    // input  wire                         K7_GPIO_3                   

    // SRIO Interface
    input  wire                         srio_refclkp_bp            ,// 156.25MHz differential clock
    input  wire                         srio_refclkn_bp            ,// 156.25MHz differential clock
    input  wire        [SRIO_LINK_WIDTH-1: 0]srio_rxp_bp           ,// Serial Receive Data +
    input  wire        [SRIO_LINK_WIDTH-1: 0]srio_rxn_bp           ,// Serial Receive Data -
    output wire        [SRIO_LINK_WIDTH-1: 0]srio_txp_bp           ,// Serial Transmit Data +
    output wire        [SRIO_LINK_WIDTH-1: 0]srio_txn_bp           ,// Serial Transmit Data -
    
    input  wire                         FPGA_GAP                   ,
    input  wire                         FPGA_GA4                   ,
    input  wire                         FPGA_GA3                   ,
    input  wire                         FPGA_GA2                   ,
    input  wire                         FPGA_GA1                   ,
    input  wire                         FPGA_GA0                    
    
    );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    wire                                sw_arst_n                  ;
    wire                                hw_arst_n                  ;
    wire                                clk_50m                    ;
    wire                                clk_100m                   ;
    wire                                vpx_clk_100m               ;
    wire                                vpx_clk_100m_locked        ;
    wire                                sys_clk_100m               ;

    reg                                 sw_srst_n_r1,sw_srst_n     ;
    reg                                 hw_srst_n_r1,hw_srst_n     ;
    
    //adc开始采集相关变量
    wire                                adc_trigger_vio            ;
    wire                                adc_trigger_sel            ;
    wire                                adc_start_trigger          ;
//    wire                                gpio_start_trigger_i       ;
    wire                                time_period_0_10ms         ;
    wire                                time_period_25ms_pluse     ;
    wire                                adc_acq_start_pluse        ;

    wire                                internal_sw_srst_n         ;
    
    wire               [SENSOR_NUM-1: 0]wr_en                      ;
    wire               [SENSOR_NUM*16-1: 0]wr_dout                 ;

    wire               [SENSOR_NUM-1: 0]rd_en                      ;
    wire               [SENSOR_NUM*8-1: 0]rd_dout                  ;
    wire               [SENSOR_NUM*16-1: 0]rd_data_count           ;
    wire               [SENSOR_NUM-1: 0]empty                      ;

//  srio_app_wrapper
    wire                                srio_log_clk               ;
    wire                                srio_log_rst               ;
    wire                                srio_clk_lock              ;
    wire                                srio_core_rst              ;
    // SRIO ID   
    wire               [  15: 0]        source_id                  ;
    wire               [  15: 0]        dest_id                    ;
    wire               [  15: 0]        device_id                  ;
    wire               [  15: 0]        device_id_set              ;
    wire                                id_set_done                ;
    // Status Signals
    wire                                port_initialized           ;
    wire                                link_initialized           ;
    wire                                mode_1x                    ;
    // FIFO Interface for Packet Transmit
    wire               [SRIO_CH_NUM-1: 0]fifo_wrreq_pkt_tx         ;
    wire               [SRIO_CH_NUM*SRIO_WR_DATA_WIDTH-1: 0]fifo_data_pkt_tx  ;
    wire               [SRIO_CH_NUM-1: 0]fifo_prog_full_pkt_tx     ;
    // FIFO Interface for Packet Receive
    wire               [SRIO_CH_NUM-1: 0]fifo_rdreq_pkt_rx       ='d0;
    wire               [SRIO_CH_NUM*SRIO_RD_DATA_WIDTH-1: 0]fifo_q_pkt_rx  ;
    wire               [SRIO_CH_NUM-1: 0]fifo_empty_pkt_rx         ;
    wire               [SRIO_CH_NUM-1: 0]fifo_prog_empty_pkt_rx    ;
    
    wire                                fiber_sw_rst               ;
    wire                                loopback_sel               ;// "0" 不回环;"1"内回环;
    wire                                sim_data_en                ;//模拟造数使能
    wire               [   5: 0]        CARD_ID                    ;
    wire               [   5: 0]        CARD_NUM                   ;
    reg                [   7: 0]        MSG_ID                     ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// logic
//---------------------------------------------------------------------
    assign                              CARD_ID                   = {
                                                                        FPGA_GAP,
                                                                        FPGA_GA4,
                                                                        FPGA_GA3,
                                                                        FPGA_GA2,
                                                                        FPGA_GA1,
                                                                        FPGA_GA0
                                                                    };

    assign                              CARD_NUM                  = ~CARD_ID;

always@(posedge sys_clk_100m)begin
    case (CARD_NUM[4:0])
        1 : MSG_ID <= 8'h00;                                        // PZ
        8 : MSG_ID <= 8'h1B;                                        // KG-O-1
        9 : MSG_ID <= 8'h1C;                                        // KG-O-2
        10: MSG_ID <= 8'h1D;                                        // KG-I
        11: MSG_ID <= 8'h10;                                        // ZX-1
        12: MSG_ID <= 8'h12;                                        // AI-1
        13: MSG_ID <= 8'h13;                                        // AI-2
        14: MSG_ID <= 8'h14;                                        // AI-3
        15: MSG_ID <= 8'h15;                                        // AI-4-1
        16: MSG_ID <= 8'h16;                                        // AI-4-2
        17: MSG_ID <= 8'h11;                                        // ZX-2
        18: MSG_ID <= 8'h17;                                        // AO-1-1 electricity
        19: MSG_ID <= 8'h18;                                        // AO-1-2
        20: MSG_ID <= 8'h19;                                        // AO-2-1 voltage
        21: MSG_ID <= 8'h1A;                                        // AO-2-2
        default: MSG_ID <= 8'h00;
    endcase
end

    assign                              internal_sw_srst_n        = sw_srst_n & ~time_period_0_10ms;

always@(posedge sys_clk_100m or negedge hw_arst_n)begin
    if (!hw_arst_n) begin
        hw_srst_n_r1 <= 'd0;
        hw_srst_n <= 'd0;
    end
    else begin
        hw_srst_n_r1 <= hw_arst_n;
        hw_srst_n <= hw_srst_n_r1;
    end
end

always@(posedge sys_clk_100m or negedge sw_arst_n)begin
    if (!sw_arst_n) begin
        sw_srst_n_r1 <= 'd0;
        sw_srst_n <= 'd0;
    end
    else begin
        sw_srst_n_r1 <= sw_arst_n;
        sw_srst_n <= sw_srst_n_r1;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// clock
//---------------------------------------------------------------------
clk_rst_wrapper  clk_rst_wrapper_inst (
    .SYSCLK                             (SYSCLK                    ),

    .SYSCLK_P                           (SYSCLK_P                  ),
    .SYSCLK_N                           (SYSCLK_N                  ),

    .K7_REFCLK_P                        (K7_REFCLK_P               ),
    .K7_REFCLK_N                        (K7_REFCLK_N               ),
    .vpx_clk_100m                       (vpx_clk_100m              ),
    .vpx_clk_100m_locked                (vpx_clk_100m_locked       ),

    .clk_50m                            (clk_50m                   ),
    .clk_100m                           (clk_100m                  ),
    .sw_arst_n                          (sw_arst_n                 ),
    .hw_arst_n                          (hw_arst_n                 ) 
);

clk_sel u_clk_sel(
    .clk_0_i                            (clk_100m                  ),
    .clk_1_i                            (vpx_clk_100m              ),

    .arst_n_i                           (hw_arst_n                 ),

    .sel_i                              (vpx_clk_100m_locked       ),// 1 choose clk1. 0 choose clk 0

    .clk_sel_o                          (sys_clk_100m              ) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// ad7656
//---------------------------------------------------------------------

time_manage_wrapper#(
    .ADC_ACQ_PERIOD                     (100_000_000 / 1000        ),// 1Kbps . 4us
    .time_10ms                          (100_000_000 / 100         ),
    .time_25ms                          (100_000_000 / 40          ) 
)
u_time_manage_wrapper(
    .sys_clk_i                          (sys_clk_100m              ),
    .rst_n_i                            (sw_srst_n                 ),

    .adc_trigger_gpio                   (adc_trigger_gpio          ),
    .adc_trigger_vio                    (adc_trigger_vio           ),
    .adc_trigger_sel                    (adc_trigger_sel           ),

    .time_period_0_10ms_o               (time_period_0_10ms        ),
    .time_period_25ms_pluse_o           (time_period_25ms_pluse    ),
    .adc_acq_start_pluse_o              (adc_acq_start_pluse       ) 
);

ad7656_wrapper#(
    .ADC_NUM                            (ADC_NUM                   ),
    .SENSOR_NUM                         (SENSOR_NUM                ) 
)
u_ad7656_wrapper(
    .sys_clk_i                          (sys_clk_100m              ),
    .rst_n_i                            (internal_sw_srst_n        ),
    .start_flag_i                       (adc_acq_start_pluse       ),

    .ADC1_CS_FPGA                       (ADC1_CS_FPGA              ),
    .ADC1_CONVST_FPGA                   (ADC1_CONVST_FPGA          ),
    .ADC1_RESET_FPGA                    (ADC1_RESET_FPGA           ),
    .ADC1_RD_FPGA                       (ADC1_RD_FPGA              ),
    .WR_1_FPGA                          (WR_1_FPGA                 ),
    .ADC1_BUSY_FPGA                     (ADC1_BUSY_FPGA            ),
    .ADC1_DB                            (ADC1_DB                   ),

    .ADC2_CS_FPGA                       (ADC2_CS_FPGA              ),
    .ADC2_CONVST_FPGA                   (ADC2_CONVST_FPGA          ),
    .ADC2_RESET_FPGA                    (ADC2_RESET_FPGA           ),
    .ADC2_RD_FPGA                       (ADC2_RD_FPGA              ),
    .WR_2_FPGA                          (WR_2_FPGA                 ),
    .ADC2_BUSY_FPGA                     (ADC2_BUSY_FPGA            ),
    .ADC2_DB                            (ADC2_DB                   ),

    .ADC3_CS_FPGA                       (ADC3_CS_FPGA              ),
    .ADC3_CONVST_FPGA                   (ADC3_CONVST_FPGA          ),
    .ADC3_RESET_FPGA                    (ADC3_RESET_FPGA           ),
    .ADC3_RD_FPGA                       (ADC3_RD_FPGA              ),
    .WR_3_FPGA                          (WR_3_FPGA                 ),
    .ADC3_BUSY_FPGA                     (ADC3_BUSY_FPGA            ),
    .ADC3_DB                            (ADC3_DB                   ),

//    .ADC4_CS_FPGA                       (ADC4_CS_FPGA              ),
//    .ADC4_CONVST_FPGA                   (ADC4_CONVST_FPGA          ),
//    .ADC4_RESET_FPGA                    (ADC4_RESET_FPGA           ),
//    .ADC4_RD_FPGA                       (ADC4_RD_FPGA              ),
//    .WR_4_FPGA                          (WR_4_FPGA                 ),
//    .ADC4_BUSY_FPGA                     (ADC4_BUSY_FPGA            ),
//    .ADC4_DB                            (ADC4_DB                   ),

    .wr_en_o                            (wr_en                     ),
    .wr_dout_o                          (wr_dout                   ) 
);

cache_wrapper#(
    .SENSOR_NUM                         (SENSOR_NUM                ) 
)
u_cache_wrapper(
    .sys_clk_i                          (sys_clk_100m              ),
    .rst_n_i                            (internal_sw_srst_n        ),

    .adc_acq_start_pluse_i              (adc_acq_start_pluse       ),
    .sim_data_en_i                      (sim_data_en               ),
    .wr_en_i                            (wr_en                     ),// from ad 7656
    .wr_dout_i                          (wr_dout                   ),// from ad 7656

    .rd_en_i                            (rd_en                     ),
    .rd_dout_o                          (rd_dout                   ),
    .empty_o                            (empty                     ),
    .rd_data_count_o                    (rd_data_count             ) 
);

msg_transmit_wrapper#(
    .SENSOR_CHANNEL                     (SENSOR_NUM                ) 
)
u_msg_transmit_wrapper(
    .sys_clk_i                          (sys_clk_100m              ),
    .rst_n_i                            (internal_sw_srst_n        ),

    .timming_start_pluse_i              (time_period_25ms_pluse    ),

    .rd_en_o                            (rd_en                     ),// from cache
    .din_i                              (rd_dout                   ),// from cache
    .data_count_i                       (rd_data_count             ),// from cache
    .empty_i                            (empty                     ),// from cache

    .us_wr_clk_o                        (                          ),// to srio
    .us_wr_en_o                         (fifo_wrreq_pkt_tx         ),// to srio
    .us_wr_dout_o                       (fifo_data_pkt_tx          ),// to srio
    .us_prog_full_i                     (fifo_prog_full_pkt_tx     ),// to srio
    
    .MSG_ID                             (MSG_ID                    ) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// SRIO Application Top Level Wrapper
//---------------------------------------------------------------------  
srio_1x_app_wrapper # (
    .SRIO_ONCE_LENGTH                   (SRIO_ONCE_LENGTH          ),
    .SRIO_WR_DATA_WIDTH                 (SRIO_WR_DATA_WIDTH        ),
    .SRIO_RD_DATA_WIDTH                 (SRIO_RD_DATA_WIDTH        ),
    .SRIO_LINK_WIDTH                    (SRIO_LINK_WIDTH           ) 
)
u_srio_app (
    // Clock and Reset# Interface
    .srio_log_clk                       (srio_log_clk              ),
    .srio_log_rst                       (srio_log_rst              ),
    .srio_clk_lock                      (srio_clk_lock             ),
    .srio_core_rst                      (~hw_arst_n                ),
    .sys_reset_n                        (sw_arst_n                 ),
    .fiber_sw_rst                       (fiber_sw_rst              ),
    .clk_50m                            (clk_50m                   ),
        
    // GT loopback Ctrl    
    .loopback_sel                       (loopback_sel              ),
        
    // SRIO ID  
    .source_id                          (source_id                 ),
    .dest_id                            (dest_id                   ),
    .device_id                          (device_id                 ),
    .device_id_set                      (device_id_set             ),
    .id_set_done                        (id_set_done               ),
        
    // Status Signals
    .port_initialized                   (port_initialized          ),
    .link_initialized                   (link_initialized          ),
    .mode_1x                            (mode_1x                   ),
        
    // FIFO Interface for Packet Transmit
    .fifo_wrclk_pkt_tx                  ({SRIO_CH_NUM{sys_clk_100m}}),
    .fifo_wrreq_pkt_tx                  (fifo_wrreq_pkt_tx         ),
    .fifo_data_pkt_tx                   (fifo_data_pkt_tx          ),
    .fifo_prog_full_pkt_tx              (fifo_prog_full_pkt_tx     ),
        
    // FIFO Interface for Packet Receive
    .fifo_rdclk_pkt_rx                  ({SRIO_CH_NUM{sys_clk_100m}}),
    .fifo_rdreq_pkt_rx                  (fifo_rdreq_pkt_rx         ),
    .fifo_q_pkt_rx                      (fifo_q_pkt_rx             ),
    .fifo_empty_pkt_rx                  (fifo_empty_pkt_rx         ),
    .fifo_prog_empty_pkt_rx             (fifo_prog_empty_pkt_rx    ),
        
    // SRIO Interface
    .srio_refclkp                       (srio_refclkp_bp           ),
    .srio_refclkn                       (srio_refclkn_bp           ),
    .srio_rxp                           (srio_rxp_bp               ),
    .srio_rxn                           (srio_rxn_bp               ),
    .srio_txp                           (srio_txp_bp               ),
    .srio_txn                           (srio_txn_bp               ) 
    );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
vio_srio_ctrl vio_srio_ctrl_inst(
    .clk                                (clk_50m                   ),// input wire clk
    .probe_out0                         (fiber_sw_rst              ),// output wire [0 : 0] probe_out0
    .probe_out1                         (loopback_sel              ),// output wire [0 : 0] probe_out1
    .probe_out2                         (dest_id                   ),// output wire [15 : 0] probe_out2
    .probe_out3                         (device_id_set             ),// output wire [15 : 0] probe_out3
    .probe_out4                         (adc_trigger_vio           ),// output wire [0 : 0] probe_out4
    .probe_out5                         (sim_data_en               ),// output wire [0 : 0] probe_out5
    .probe_out6                         (adc_trigger_sel           ) // output wire [0 : 0] probe_out6   
    );

endmodule
