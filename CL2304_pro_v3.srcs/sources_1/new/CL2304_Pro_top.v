`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: chenxiongzhi
// 
// Create Date: 2023/10/11 19:25:35
// Design Name: 
// Module Name: CL2304_Pro_top
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


module CL2304_Pro_top # (
    parameter                           CHANNEL_NUM             =   4,//通道数
    
    parameter                           UART_NUM                =   6,//uart数

    parameter                           DDR_CHANNEL             =   4,
    parameter                           WR_DATA_WIDTH           =   128,
    parameter                           RD_DATA_WIDTH           =   256,
    parameter                           DDR_DATA_WIDTH          =   512,
       
    parameter                           DATA_WIDTH              =   256,
    parameter                           PCIE_CHANNEL            =   4,
    parameter                           REG_NUM                 =   50,
    parameter                           PCIE_DATA_WIDTH         =   256,
    parameter                           PCIE_LINK_WIDTH         =   8 // 1- X1; 2 - X2; 4 - X4; 8 - X8    
    )(
    //系统时钟输入
    input                               SYSCLK100_P                ,
    input                               SYSCLK100_N                ,//系统时钟
    //---------------------pwm------------------------------
    output                              FPGA_PWM_1                 ,
    output                              FPGA_PWM_2                 ,
    //---------------------UART串口模块------------------------------
    output                              UART_PPS_OE                ,
    output                              UART_CON_OE                ,
    output             [UART_NUM-1:0]   UART_TXD_RS422             ,
    input              [UART_NUM-1:0]   UART_RXD_RS422             ,
    //---------------------PPS模块-----------------------------------
    input                               GNSS_ANTON_1V8             ,
    output                              GNSS_RSTN_1V8              ,
    output                              FORCE_ON_1V8               ,
    input                               GNSS_PPS_1V8               ,
    output                              GNSS_RXD_1V8               ,//芯片的RX，FPGA的TX
    input                               GNSS_TXD_1V8               ,//芯片的TX，FPGA的RX
    //---------------------AD9516时钟芯片模块-----------------------------------
    output                              REFSEL                     ,//9516参考时钟输入选择，根据原理图选择，置0
    output                              RESET_B                    ,//时钟芯片复位

    output                              CS                         ,//AD9516标准SPI通信接口
    output                              SCLK                       ,//AD9516标准SPI通信接口
    output                              SDIO                       ,//AD9516标准SPI通信接口
    input                               SDO                        ,//AD9516标准SPI通信接口
    //---------------------AD7606模数转化芯片模块---------------------------------
    output                              ADC_OE1_B                  ,//电平转化芯片使能，低有效
    output                              ADC_OE2_B                  ,//电平转化芯片使能，低有效
    output                              ADC_OE3_B                  ,//电平转化芯片使能，低有效

    output                              AD7606_RESET_1V8           ,//AD7606复位
    output                              AD7606_CONVSTA_1V8         ,//1~4通道使能
    output                              AD7606_CONVSTB_1V8         ,//5~6通道使能
    input                               AD7606_BUSY_1V8            ,//转化进行中信号
    input                               AD7606_FRSTDATA_1V8        ,//并行采样的第一个数指示信号

    output                              AD7606_CS_1V8              ,//片选
    output                              AD7606_RD_1V8              ,//SCLK
    input              [  15:0]         AD7606_DB_1V8              ,//16位宽的数据线
    output             [   2:0]         AD7606_OS_1V8              ,//采样率模式
    //---------------------DDR3芯片模块---------------------------------
       // DDR3 SDRAM Interface
    input                               ddr3_sys_clk_p             ,// 200MHz Differential System Clocks for DDR3 SDRAM Infrastructure
    input                               ddr3_sys_clk_n             ,// 200MHz Differential System Clocks for DDR3 SDRAM Infrastructure
    output             [   0:0]         ddr3_ck_p                  ,// Clock: CK and CK# are differential clock inputs
    output             [   0:0]         ddr3_ck_n                  ,// Clock: CK and CK# are differential clock inputs
    output                              ddr3_reset_n               ,// Reset
    output             [   0:0]         ddr3_cs_n                  ,// Chip select
    output             [   0:0]         ddr3_odt                   ,// On-die termination
    output             [   0:0]         ddr3_cke                   ,// Clock enable
    output                              ddr3_ras_n                 ,// Command inputs
    output                              ddr3_cas_n                 ,// Command inputs
    output                              ddr3_we_n                  ,// Command inputs
    output             [   2:0]         ddr3_ba                    ,// Bank address inputs
    output             [  14:0]         ddr3_addr                  ,// Address inputs
    inout              [  63:0]         ddr3_dq                    ,// Data input/output
    inout              [   7:0]         ddr3_dqs_p                 ,// Positive byte data strobe
    inout              [   7:0]         ddr3_dqs_n                 ,// Negedge byte data strobe
    output             [   7:0]         ddr3_dm                    ,// Input data mask    
    //---------------------blk2711芯片模块---------------------------------
        //2711
    input                               LVDS_1_2711_P              ,//参考时钟
    input                               LVDS_1_2711_N              ,
    
    input                               LVDS_2_2711_P              ,
    input                               LVDS_2_2711_N              ,//参考时钟
    
    //电源使能
    output                              POWER_ON                   ,//2711 2.5v 电源使能
    
    output             [CHANNEL_NUM*5-1:0]OE                         ,//2711 信号电压转换使能 
    //------------ 2711 CLK ------------//
    output             [CHANNEL_NUM-1:0]GTX_CLK                    ,//发送端时钟
    input              [CHANNEL_NUM-1:0]RX_CLK                     ,//接收端恢复时钟
    //------------ 2711 CTRL ------------//
    output             [CHANNEL_NUM-1:0]LOOP_EN                    ,//回环使能，高有效               
    output             [CHANNEL_NUM-1:0]ENABLE                     ,//器件使能，高有效               
    output             [CHANNEL_NUM-1:0]LCKREFN                    ,//接收端时钟锁定使能，高有效          
    output             [CHANNEL_NUM-1:0]PRBSEN                     ,//伪随机序列使能，高有效            
    //    output                      TESTEN,              //1'b0 测试模式使能，高有效              
    output             [CHANNEL_NUM-1:0]PRE                        ,//预加重，远距离传输时置1，对信号做补偿，高有效
    //------------ DATA & DATA_CTRL ------------//
    output             [CHANNEL_NUM-1:0]TKMSB                      ,//发送端 高8位K码标志    
    output             [CHANNEL_NUM-1:0]TKLSB                      ,//发送端 低8位K码标志
    input              [CHANNEL_NUM-1:0]RKMSB                      ,//接收端 高8位K码标志
    input              [CHANNEL_NUM-1:0]RKLSB                      ,//接收端 低8位K码标志
    
    output             [CHANNEL_NUM*16-1:0]TX_Data                    ,//发送数据
    input              [CHANNEL_NUM*16-1:0]RX_Data                    ,//接收数据

    output                              LED0_2711_1                ,
    output                              LED1_2711_1                ,

    output                              LED0_2711_2                ,
    output                              LED1_2711_2                ,

    output                              LED0_2711_3                ,
    output                              LED1_2711_3                ,

    output                              LED0_2711_4                ,
    output                              LED1_2711_4                ,
    //---------------------PCIE模块---------------------------------
        // PCIE Interface
    input                               sys_rst_n                  ,
    
    input                               pcie_ref_p                 ,
    input                               pcie_ref_n                 ,
    output             [PCIE_LINK_WIDTH-1:0]pci_exp_txp                ,
    output             [PCIE_LINK_WIDTH-1:0]pci_exp_txn                ,
    input              [PCIE_LINK_WIDTH-1:0]pci_exp_rxp                ,
    input              [PCIE_LINK_WIDTH-1:0]pci_exp_rxn                 
    );
//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------    
//  clock reset wrapper
wire                                    clk_50m                    ;
wire                                    clk_100m                   ;
wire                                    hw_reset_n                 ;
wire                                    sys_reset_n                ;

//  Data Interface
//    // TX AXI Interface 
//    wire        [CHANNEL_NUM*DATA_WIDTH-1:0]tx_data; 
//    wire        [CHANNEL_NUM-1:0]           tx_valid;
//    wire        [CHANNEL_NUM-1:0]           tx_ready; 
    // RX AXI Interface 
wire                   [CHANNEL_NUM*DATA_WIDTH-1:0]rx_data                    ;
wire                   [CHANNEL_NUM-1:0]rx_valid                   ;

//  data_aly_wrapper
    // Status Signals
wire                   [CHANNEL_NUM-1:0]record_full_flag           ;
wire                   [CHANNEL_NUM-1:0]play_empty_flag            ;
wire                   [CHANNEL_NUM*32-1:0]rx_aly_data_rate           ;
wire                   [CHANNEL_NUM*32-1:0]tx_aly_data_rate           ;
    // FIFO Interface for Analysis Transmit
wire                   [CHANNEL_NUM-1:0]fifo_wrreq_aly_tx          ;
wire                   [CHANNEL_NUM*DATA_WIDTH-1:0]fifo_data_aly_tx           ;
wire                   [CHANNEL_NUM-1:0]fifo_prog_full_aly_tx      ;
    // FIFO Interface for Analysis Receive
wire                   [CHANNEL_NUM-1:0]fifo_rdreq_aly_rx          ;
wire                   [CHANNEL_NUM*DATA_WIDTH-1:0]fifo_q_aly_rx              ;
wire                   [CHANNEL_NUM-1:0]fifo_empty_aly_rx          ;
    
//  ddr3_fifo_wrapper        
    //ddr fifo/others interface
wire                                    ddr3_core_reset_n          ;
wire                                    ddr3_ui_clk                ;
wire                                    ddr3_plllkdet              ;
wire                                    phy_init_done              ;
wire                   [DDR_CHANNEL-1:0]ddr3_data_rdy              ;
wire                   [DDR_CHANNEL*32-1:0]ddr3_data_usedw            ;

    // FIFO Interface for DDR3 SDRAM Upstream
wire                   [DDR_CHANNEL-1:0]fifo_wrreq_ddr3_us         ;
wire                   [DDR_CHANNEL*DATA_WIDTH-1:0]fifo_data_ddr3_us          ;
wire                   [DDR_CHANNEL-1:0]fifo_prog_full_ddr3_us     ;
    // FIFO Interface for DDR3 SDRAM Downstream
wire                   [DDR_CHANNEL-1:0]fifo_rdreq_ddr3_ds         ;
wire                   [DDR_CHANNEL*DATA_WIDTH-1:0]fifo_q_ddr3_ds             ;
wire                   [DDR_CHANNEL-1:0]fifo_empty_ddr3_ds         ;
    
//  data_xfer
    // Status Signals   
wire                   [CHANNEL_NUM-1:0]channel_valid              ;
    // Data Rate  
wire                   [CHANNEL_NUM*32-1:0]channel_rate               ;
    // Data Quantity                                            
wire                   [CHANNEL_NUM*32-1:0]quantity                   ;
    
//  pcie_wrapper
wire                                    pcie_axi_clk               ;
    // Software Reset Reg     
wire                                    sw_reset_n                 ;
    // Status Signals
wire                                    pcie_lnk_up                ;
wire                                    upstream_valid             ;// 上行数据链路有效标志，上位机读取                               
wire                                    downstream_valid           ;// 下行数据链路有效标志，上位机读取                               
wire                   [  31:0]         upstream_valid_ch          ;// 上行采集通道DDR缓存数据准备有效标志，上位机读取，共可标志32通道             
wire                   [  31:0]         downstream_valid_ch        ;// 下行回放通道DDR缓存空间准备有效标志，上位机读取，共可标志32通道             
wire                   [  31:0]         downstream_flag            ;// 下行回放数据通道标志，上位机下发                               
    // Data Path Select
wire                                    record_en                  ;
wire                                    play_en                    ;
    // Data Path Ctrl
wire                   [  31:0]         record_num                 ;
wire                   [  31:0]         play_num                   ;
    // DMA Transfer Length
wire                   [  31:0]         dma_xfer_len               ;
    // FIFO Interface for PCIE Upstream
wire                   [PCIE_CHANNEL-1:0]fifo_wrreq_pcie_us         ;
wire                   [PCIE_CHANNEL*DATA_WIDTH-1:0]fifo_data_pcie_us          ;
wire                   [PCIE_CHANNEL-1:0]fifo_prog_full_pcie_us     ;
    // FIFO Interface for PCIE Downstream
wire                   [PCIE_CHANNEL-1:0]fifo_rdreq_pcie_ds         ;
wire                   [PCIE_CHANNEL*DATA_WIDTH-1:0]fifo_q_pcie_ds             ;
wire                   [PCIE_CHANNEL-1:0]fifo_empty_pcie_ds         ;

//  xadc_wrapper
wire                   [  15:0]         measured_temp              ;
wire                   [  15:0]         measured_vccint            ;
wire                   [  15:0]         measured_vccaux            ;
wire                   [  15:0]         measured_vccbram           ;
wire                   [  15:0]         measured_aux0              ;
wire                   [  15:0]         measured_aux1              ;
wire                   [  15:0]         measured_aux2              ;
wire                   [  15:0]         measured_aux3              ;
wire                   [   7:0]         alm                        ;

//2711
wire                   [CHANNEL_NUM-1:0]rx_100m                    ;//接收端时钟复位
wire                   [CHANNEL_NUM-1:0]rx_200m                    ;
wire                   [CHANNEL_NUM-1:0]rx_reset_n                 ;
wire                   [CHANNEL_NUM-1:0]rxclk_locked               ;
                 
wire                   [CHANNEL_NUM-1:0]pw_rst_done                ;// 2711初始化完成标志
wire                   [CHANNEL_NUM*16-1:0]send_data_num              ;//连续发送数据个数  数据与K码交替发送

wire                   [CHANNEL_NUM-1:0]frame_start_flag           ;//即将开始发送数据标志                 
                 
wire                   [CHANNEL_NUM-1:0]fifo_us_wrclk              ;//发送端 写fifo接口    
wire                   [CHANNEL_NUM-1:0]fifo_us_wrreq              ;
wire                   [CHANNEL_NUM*16-1:0]fifo_us_data               ;
wire                   [CHANNEL_NUM-1:0]fifo_us_prog_full          ;

wire                   [CHANNEL_NUM-1:0]fifo_ds_rdclk              ;//接收端 读fifo接口
wire                   [CHANNEL_NUM-1:0]fifo_ds_rdreq              ;
wire                   [CHANNEL_NUM*16-1:0]fifo_ds_q                  ;
wire                   [CHANNEL_NUM-1:0]fifo_ds_empty              ;

//
wire                   [CHANNEL_NUM-1:0]vio_en                     ;// 测试程序发送使能，高有效 

wire                   [CHANNEL_NUM-1:0]data_mod                   ;
wire                   [CHANNEL_NUM-1:0]loop_mod                   ;
wire                   [CHANNEL_NUM-1:0]tx_send_en                 ;
wire                   [CHANNEL_NUM*16-1:0]send_k_num                 ;//连续发送K码个数 

//uart参数
wire                   [UART_NUM-1:0]   uart_tx_wren_start         ;
wire                   [UART_NUM-1:0]   uart_tx_wren_end           ;
wire                   [UART_NUM*8-1:0] uart_tx_data               ;
wire                   [UART_NUM-1:0]   fifo_uart_tx_prog_full     ;

wire                   [UART_NUM*16-1:0]uart_bps                   ;//波特率
wire                   [UART_NUM*4-1:0] uart_data_bit              ;//数据位
wire                   [UART_NUM*2-1:0] uart_stop_bit              ;//停止位
wire                   [UART_NUM*2-1:0] uart_parity_bit            ;//校验位

wire                   [UART_NUM-1:0]   fifo_uart_rx_rden          ;
wire                   [UART_NUM*8-1:0] fifo_uart_rx_empty         ;
wire                   [UART_NUM*8-1:0] uart_rx_data               ;

//pps
wire                   [   7:0]         pps_uart_tx_data           ;
wire                                    pps_uart_tx_wren_start     ;
wire                                    pps_uart_tx_wren_end       ;
wire                                    pps_uart_tx_prog_full      ;

wire                   [  15:0]         pps_uart_bps               ;//波特率
wire                   [   7:0]         pps_uart_data_bit          ;//数据位
wire                   [   1:0]         pps_uart_stop_bit          ;//停止位
wire                   [   1:0]         pps_uart_parity_bit        ;//校验位

wire                                    pps_fifo_uart_rx_rden      ;
wire                                    pps_fifo_uart_rx_empty     ;
wire                   [   7:0]         pps_uart_rx_data           ;

//ad7606
wire                                    ad7606_start_signal        ;
wire                   [   2:0]         os                         ;
wire                   [  15:0]         ch1_data                   ;
wire                   [  15:0]         ch2_data                   ;
wire                   [  15:0]         ch3_data                   ;
wire                   [  15:0]         ch4_data                   ;
wire                   [  15:0]         ch5_data                   ;
wire                   [  15:0]         ch6_data                   ;
wire                   [  15:0]         ch7_data                   ;
wire                   [  15:0]         ch8_data                   ;
wire                                    data_flag_o                ;

//pwm
wire                   [  15:0]         duty_cycle1                ;
wire                   [  15:0]         duty_cycle2                ;

//红绿灯
wire                   [CHANNEL_NUM-1:0]LED_R                      ;
wire                   [CHANNEL_NUM-1:0]LED_G                      ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// assgin
//---------------------------------------------------------------------     
assign UART_PPS_OE = 1'b1;
assign UART_CON_OE = 1'b1;
assign ADC_OE1_B = 1'b0;
assign ADC_OE2_B = 1'b0;
assign ADC_OE3_B = 1'b0;
assign GNSS_RSTN_1V8 = hw_reset_n;
assign AD7606_OS_1V8 = os;

assign LED_R[0] = LED0_2711_1;
assign LED_R[1] = LED0_2711_2;
assign LED_R[2] = LED0_2711_3;
assign LED_R[3] = LED0_2711_4;

assign LED_G[0] = LED1_2711_1;
assign LED_G[1] = LED1_2711_2;
assign LED_G[2] = LED1_2711_3;
assign LED_G[3] = LED1_2711_4;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// PWM
//---------------------------------------------------------------------
pwm  pwm_inst1 (
    .sys_clk_i                         (clk_50m                   ),
    .rst_n_i                           (sys_reset_n               ),
    .duty_cycle                        (duty_cycle1               ),
    .pwm_o                             (FPGA_PWM_1                ) 
  );
pwm  pwm_inst2 (
    .sys_clk_i                         (clk_50m                   ),
    .rst_n_i                           (sys_reset_n               ),
    .duty_cycle                        (duty_cycle2               ),
    .pwm_o                             (FPGA_PWM_2                ) 
  );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// clk_rst_wrapper
//---------------------------------------------------------------------  
clk_rst_wrapper # (
    .CHANNEL_NUM                       (CHANNEL_NUM               ) 
)
 u_clk_rst_wrapper
(
    //sysclk
    .SYSCLK100_P                       (SYSCLK100_P               ),
    .SYSCLK100_N                       (SYSCLK100_N               ),
    
    //ad9516
    .CS                                (CS                        ),
    .SCLK                              (SCLK                      ),
    .SDIO                              (SDIO                      ),
    .SDO                               (SDO                       ),
    .REFSEL                            (REFSEL                    ),
    .RESET_B                           (RESET_B                   ),
     
    //ddr3_clk
    .ddr3_ui_clk                       (ddr3_ui_clk               ),
    .phy_init_done                     (phy_init_done             ),
     //pcie_clk
    .pcie_axi_clk                      (pcie_axi_clk              ),
    .pcie_lnk_up                       (pcie_lnk_up               ),

    .OE                                (OE                        ),
    .POWER_ON                          (POWER_ON                  ),
    
    .LVDS_1_2711_P                     (LVDS_1_2711_P             ),
    .LVDS_1_2711_N                     (LVDS_1_2711_N             ),
    
    .LVDS_2_2711_P                     (LVDS_2_2711_P             ),
    .LVDS_2_2711_N                     (LVDS_2_2711_N             ),
  
    .GTX_CLK                           (GTX_CLK                   ),
    .RX_CLK                            (RX_CLK                    ),
  
    //
    .rx_100m                           (rx_100m                   ),
    .rx_200m                           (rx_200m                   ),
    .rx_reset_n                        (rx_reset_n                ),
    //
    .clk_50m                           (clk_50m                   ),
    .clk_100m                          (clk_100m                  ),
    .hw_reset_n                        (hw_reset_n                ),
    .sys_reset_n                       (sys_reset_n               ),
    .sw_reset_n                        (sw_reset_n                )
);


// ********************************************************************************** // 

// ********************************************************************************** // 
//---------------------------------------------------------------------
// Data Analysis Top Level
//---------------------------------------------------------------------  
data_aly_wrapper
    # (
    .CHANNEL_NUM                       (CHANNEL_NUM               ),
    .WR_DATA_WIDTH                     (WR_DATA_WIDTH             ),
    .RD_DATA_WIDTH                     (DATA_WIDTH                ) 
    )
    
    u_data_aly
    (
        // Clock and Reset# Interface
    .log_clk                           (ddr3_ui_clk               ),
    .log_rst_n                         (sys_reset_n               ),
        
        // Data Path Select
    .record_en                         (record_en                 ),
    .play_en                           (play_en                   ),
    .sim_data_en                       (vio_sim_data_en           ),

        // Data Path Ctrl
    .record_num                        (record_num                ),
    .play_num                          (play_num                  ),

        // Status Signals
    .record_full_flag                  (record_full_flag          ),
    .play_empty_flag                   (play_empty_flag           ),
    .rx_aly_data_rate                  (rx_aly_data_rate          ),
    .tx_aly_data_rate                  (tx_aly_data_rate          ),
        
        //---------------------------------------------------------------------
        //  Data Interface
        //---------------------------------------------------------------------            
//        // TX Interface 
//        .tx_data                        (tx_data), 
//        .tx_valid                       (tx_valid),
//        .tx_ready                       (tx_ready), 
        
        // RX Interface
    .rx_data                           (rx_data                   ),
    .rx_valid                          (rx_valid                  ),
    
        //---------------------------------------------------------------------
        //  Analysis interface
        //---------------------------------------------------------------------
        // FIFO Interface for Analysis Transmit
    .fifo_wrclk_aly_tx                 ({CHANNEL_NUM{ddr3_ui_clk}}),
    .fifo_wrreq_aly_tx                 (fifo_wrreq_aly_tx         ),
    .fifo_data_aly_tx                  (fifo_data_aly_tx          ),
    .fifo_prog_full_aly_tx             (fifo_prog_full_aly_tx     ),
        
        // FIFO Interface for Analysis Receive
    .fifo_rdclk_aly_rx                 ({CHANNEL_NUM{ddr3_ui_clk}}),
    .fifo_rdreq_aly_rx                 (fifo_rdreq_aly_rx         ),
    .fifo_q_aly_rx                     (fifo_q_aly_rx             ),
    .fifo_empty_aly_rx                 (fifo_empty_aly_rx         ) 
    );
    

// ********************************************************************************** // 
//---------------------------------------------------------------------
// DDR3 FIFO Wrapper Top Level
//---------------------------------------------------------------------
ddr3_fifo_wrapper
    # (
    .DDR_CHANNEL                       (DDR_CHANNEL               ),
    .WR_DATA_WIDTH                     (DATA_WIDTH                ),
    .RD_DATA_WIDTH                     (DATA_WIDTH                ) 
    )
    
    u_ddr3
    (
        // Clock and Reset# Interface
    .ddr3_core_reset_n                 (hw_reset_n                ),// DDR3 Core Reset#, Active low
    .ddr3_log_reset_n                  (sys_reset_n               ),// DDR3 Logic Reset, Active low
    .ddr3_ui_clk                       (ddr3_ui_clk               ),// This UI clock must be quarter of the DRAM clock
    .ddr3_plllkdet                     (ddr3_plllkdet             ),// This active-High PLL frequency lock signal indicates that the PLL frequency is within predetermined tolerance
        
        // DDR3 SDRAM Controller Calibration Status
    .phy_init_done                     (phy_init_done             ),// PHY asserts dfi_init_complete when calibration is finished
    .device_temp_i                     (measured_temp[15:4]       ),
        
        // DMA Transfer Length 
    .dma_xfer_len                      (dma_xfer_len              ),
    .ddr3_data_rdy                     (ddr3_data_rdy             ),
    .ddr3_data_usedw                   (ddr3_data_usedw           ),
        
        //---------------------------------------------------------------------
        // FIFO Interface for DDR3 SDRAM Upstream
    .fifo_wrclk_ddr3_us                ({DDR_CHANNEL{ddr3_ui_clk}}),// fifo write clock
    .fifo_wrreq_ddr3_us                (fifo_wrreq_ddr3_us        ),// fifo write request
    .fifo_data_ddr3_us                 (fifo_data_ddr3_us         ),// fifo write data
    .fifo_prog_full_ddr3_us            (fifo_prog_full_ddr3_us    ),// fifo program full 
            
        //---------------------------------------------------------------------
        // FIFO Interface for DDR3 SDRAM Downstream
    .fifo_rdclk_ddr3_ds                ({DDR_CHANNEL{ddr3_ui_clk}}),// fifo read clock
    .fifo_rdreq_ddr3_ds                (fifo_rdreq_ddr3_ds        ),// fifo read request
    .fifo_q_ddr3_ds                    (fifo_q_ddr3_ds            ),// fifo read data
    .fifo_empty_ddr3_ds                (fifo_empty_ddr3_ds        ),// fifo empty
        
        //---------------------------------------------------------------------
        // DDR3 SDRAM Interface
    .ddr3_sys_clk_p                    (ddr3_sys_clk_p            ),// 200MHz Differential System Clocks for DDR3 SDRAM Infrastructure
    .ddr3_sys_clk_n                    (ddr3_sys_clk_n            ),// 200MHz Differential System Clocks for DDR3 SDRAM Infrastructure        
    .ddr3_ck_p                         (ddr3_ck_p                 ),// Clock: CK and CK# are differential clock inputs
    .ddr3_ck_n                         (ddr3_ck_n                 ),// Clock: CK and CK# are differential clock inputs
    .ddr3_reset_n                      (ddr3_reset_n              ),// Reset
    .ddr3_cs_n                         (ddr3_cs_n                 ),// Chip select
    .ddr3_odt                          (ddr3_odt                  ),// On-die termination
    .ddr3_cke                          (ddr3_cke                  ),// Clock enable
    .ddr3_ras_n                        (ddr3_ras_n                ),// Command inputs
    .ddr3_cas_n                        (ddr3_cas_n                ),// Command inputs
    .ddr3_we_n                         (ddr3_we_n                 ),// Command inputs
    .ddr3_ba                           (ddr3_ba                   ),// Bank address inputs
    .ddr3_addr                         (ddr3_addr                 ),// Address inputs
    .ddr3_dq                           (ddr3_dq                   ),// Data input/output
    .ddr3_dqs_p                        (ddr3_dqs_p                ),// Positive byte data strobe
    .ddr3_dqs_n                        (ddr3_dqs_n                ),// Negedge byte data strobe
    .ddr3_dm                           (ddr3_dm                   ) // Input data mask        
    );

// ********************************************************************************** // 
// ********************************************************************************** // 
//---------------------------------------------------------------------
// Data Transfer Top Level
//---------------------------------------------------------------------  
data_xfer # (
    .CHANNEL_NUM                       (CHANNEL_NUM               ),
    .DATA_WIDTH                        (DATA_WIDTH                ) 
    )
    u_data_xfer
    (
        // System Clock and Reset#
    .log_clk                           (ddr3_ui_clk               ),
    .log_rst_n                         (sys_reset_n               ),
        
        // Data Path Select
    .record_en                         (record_en                 ),
    .play_en                           (play_en                   ),

        // Data Path Ctrl
    .record_num                        (record_num                ),
    .play_num                          (play_num                  ),
                
        // DMA Transfer Length 
    .dma_xfer_len                      (dma_xfer_len              ),
    .ddr3_data_rdy                     (ddr3_data_rdy             ),
    .ddr3_data_usedw                   (ddr3_data_usedw           ),

        // PCIE Ctrl Status Signals
    .pcie_lnk_up                       (pcie_lnk_up               ),
    .upstream_valid                    (upstream_valid            ),
    .downstream_valid                  (downstream_valid          ),
    .upstream_valid_ch                 (upstream_valid_ch         ),
    .downstream_valid_ch               (downstream_valid_ch       ),
    .downstream_flag                   (downstream_flag           ),
        
        // Status Signals
    .phy_init_done                     (phy_init_done             ),
    .channel_valid                     (channel_valid             ),
        
        // Data Rate    
    .channel_rate                      (channel_rate              ),
        
        // Data Quantity
    .quantity                          (quantity                  ),

        //---------------------------------------------------------------------
        //  Analysis interface
        //---------------------------------------------------------------------
        // FIFO Interface for Analysis Transmit
    .fifo_wrreq_aly_tx                 (fifo_wrreq_aly_tx         ),
    .fifo_data_aly_tx                  (fifo_data_aly_tx          ),
    .fifo_prog_full_aly_tx             (fifo_prog_full_aly_tx     ),
        
        // FIFO Interface for Analysis Receive
    .fifo_rdreq_aly_rx                 (fifo_rdreq_aly_rx         ),
    .fifo_q_aly_rx                     (fifo_q_aly_rx             ),
    .fifo_empty_aly_rx                 (fifo_empty_aly_rx         ),
                   
        //---------------------------------------------------------------------
        //  DDR3 Interface
        //---------------------------------------------------------------------
        // FIFO Interface for DDR3 SDRAM Upstream
    .fifo_wrreq_ddr3_us                (fifo_wrreq_ddr3_us        ),
    .fifo_data_ddr3_us                 (fifo_data_ddr3_us         ),
    .fifo_prog_full_ddr3_us            (fifo_prog_full_ddr3_us    ),

        // FIFO Interface for DDR3 SDRAM Downstream
    .fifo_rdreq_ddr3_ds                (fifo_rdreq_ddr3_ds        ),
    .fifo_q_ddr3_ds                    (fifo_q_ddr3_ds            ),
    .fifo_empty_ddr3_ds                (fifo_empty_ddr3_ds        ),
                                                                       
        //---------------------------------------------------------------------
        //  PCIE Interface
        //---------------------------------------------------------------------
        // FIFO Interface for PCIE Upstream
    .fifo_wrreq_pcie_us                (fifo_wrreq_pcie_us        ),
    .fifo_data_pcie_us                 (fifo_data_pcie_us         ),
    .fifo_prog_full_pcie_us            (fifo_prog_full_pcie_us    ),

        // FIFO Interface for PCIE Downstream
    .fifo_rdreq_pcie_ds                (fifo_rdreq_pcie_ds        ),
    .fifo_q_pcie_ds                    (fifo_q_pcie_ds            ),
    .fifo_empty_pcie_ds                (fifo_empty_pcie_ds        ) 
    );


// ********************************************************************************** // 
//---------------------------------------------------------------------
//  PCIE Top Level Wrapper
//---------------------------------------------------------------------  
pcie_wrapper # (
    .PCIE_CHANNEL                      (PCIE_CHANNEL              ),
    .REG_NUM                           (REG_NUM                   ),
    .WR_DATA_WIDTH                     (DATA_WIDTH                ),
    .RD_DATA_WIDTH                     (DATA_WIDTH                ),
    .PCIE_DATA_WIDTH                   (PCIE_DATA_WIDTH           ),
    .PCIE_LINK_WIDTH                   (PCIE_LINK_WIDTH           ) 
    )
    
    u_pcie
    (
        // Clock and Reset# Interface
    .pcie_axi_clk                      (pcie_axi_clk              ),

         // Software Reset#
    .sw_reset_n                        (sw_reset_n                ),
        
        // PCIE Ctrl Status Signals
    .pcie_lnk_up                       (pcie_lnk_up               ),
    .upstream_valid                    (upstream_valid            ),
    .downstream_valid                  (downstream_valid          ),
    .upstream_valid_ch                 (upstream_valid_ch         ),
    .downstream_valid_ch               (downstream_valid_ch       ),
    .downstream_flag                   (downstream_flag           ),
    
        // Data Path Select
    .record_en                         (record_en                 ),
    .play_en                           (play_en                   ),
        
        // Data Path Ctrl
    .record_num                        (record_num                ),
    .play_num                          (play_num                  ),
        
        // DMA Transfer Length
    .dma_xfer_len                      (dma_xfer_len              ),

        // Status Signals
    .measured_temp                     (measured_temp             ),
    .measured_vcc                      (measured_vccint           ),
    .phy_init_done                     (phy_init_done             ),
        
        //pwm
    .duty_cycle1                       (duty_cycle1               ),
    .duty_cycle2                       (duty_cycle2               ),

            //2711寄存器控制
    .send_k_num                        (send_k_num                ),
    .tx_send_en                        (tx_send_en                ),
    .data_mod                          (data_mod                  ),
    .loop_mod                          (loop_mod                  ),
            //uart寄存器控制
    .uart_tx_wren_start                (uart_tx_wren_start        ),
    .uart_tx_wren_end                  (uart_tx_wren_end          ),
    .uart_tx_data                      (uart_tx_data              ),
    .fifo_uart_tx_prog_full            (fifo_uart_tx_prog_full    ),

    .uart_bps                          (uart_bps                  ),//波特率
    .uart_data_bit                     (uart_data_bit             ),//数据位
    .uart_stop_bit                     (uart_stop_bit             ),//停止位
    .uart_parity_bit                   (uart_parity_bit           ),//校验位

    .fifo_uart_rx_rden                 (fifo_uart_rx_rden         ),
    .fifo_uart_rx_empty                (fifo_uart_rx_empty        ),
    .uart_rx_data                      (uart_rx_data              ),
    
        //pps_uart
    .pps_uart_tx_data                  (pps_uart_tx_data          ),
    .pps_uart_tx_wren_start            (pps_uart_tx_wren_start    ),
    .pps_uart_tx_wren_end              (pps_uart_tx_wren_end      ),
    .pps_uart_tx_prog_full             (pps_uart_tx_prog_full     ),

    .pps_uart_bps                      (pps_uart_bps              ),//波特率
    .pps_uart_data_bit                 (pps_uart_data_bit         ),//数据位
    .pps_uart_stop_bit                 (pps_uart_stop_bit         ),//停止位
    .pps_uart_parity_bit               (pps_uart_parity_bit       ),//校验位

    .pps_fifo_uart_rx_rden             (pps_fifo_uart_rx_rden     ),
    .pps_fifo_uart_rx_empty            (pps_fifo_uart_rx_empty    ),
    .pps_uart_rx_data                  (pps_uart_rx_data          ),

            //ad7606
    .ad7606_start_signal               (ad7606_start_signal       ),
    .os                                (os                        ),
    .ch1_data                          (ch1_data                  ),
    .ch2_data                          (ch2_data                  ),
    .ch3_data                          (ch3_data                  ),
    .ch4_data                          (ch4_data                  ),
    .ch5_data                          (ch5_data                  ),
    .ch6_data                          (ch6_data                  ),
    .ch7_data                          (ch7_data                  ),
    .ch8_data                          (ch8_data                  ),
        //---------------------------------------------------------------------   
        // FIFO Interface for PCIE Upstream
    .fifo_wrclk_pcie_us                ({PCIE_CHANNEL{ddr3_ui_clk}}),
    .fifo_wrreq_pcie_us                (fifo_wrreq_pcie_us        ),
    .fifo_data_pcie_us                 (fifo_data_pcie_us         ),
    .fifo_prog_full_pcie_us            (fifo_prog_full_pcie_us    ),
    
        //---------------------------------------------------------------------   
        // FIFO Interface for PCIE Downstream
    .fifo_rdclk_pcie_ds                ({PCIE_CHANNEL{ddr3_ui_clk}}),
    .fifo_rdreq_pcie_ds                (fifo_rdreq_pcie_ds        ),
    .fifo_q_pcie_ds                    (fifo_q_pcie_ds            ),
    .fifo_empty_pcie_ds                (fifo_empty_pcie_ds        ),
        
        //---------------------------------------------------------------------                    
        // PCIE Interface
    .pcie_ref_p                        (pcie_ref_p                ),
    .pcie_ref_n                        (pcie_ref_n                ),
    .sys_rst_n                         (sys_rst_n                 ),
                                    
    .pci_exp_txp                       (pci_exp_txp               ),
    .pci_exp_txn                       (pci_exp_txn               ),
    .pci_exp_rxp                       (pci_exp_rxp               ),
    .pci_exp_rxn                       (pci_exp_rxn               ) 
    );
// ********************************************************************************** // 
//--------------------------------------------------------------------- 
// xadc_wrapper
//---------------------------------------------------------------------
xadc_wrapper
    u_xadc
    (
    .DCLK                              (clk_50m                   ),// Clock input for DRP
    .RESET                             (!hw_reset_n               ),
    .VAUXP                             (3'b000                    ),
    .VAUXN                             (3'b000                    ),// Auxiliary analog channel inputs
    .VP                                (1'b0                      ),
    .VN                                (1'b0                      ),// Dedicated and Hardwired Analog Input Pair
    .MEASURED_TEMP                     (measured_temp             ),
    .MEASURED_VCCINT                   (measured_vccint           ),
    .MEASURED_VCCAUX                   (measured_vccaux           ),
    .MEASURED_VCCBRAM                  (measured_vccbram          ),
    .MEASURED_AUX0                     (measured_aux0             ),
    .MEASURED_AUX1                     (measured_aux1             ),
    .MEASURED_AUX2                     (measured_aux2             ),
    .MEASURED_AUX3                     (measured_aux3             ),
    .ALM                               (alm                       ),
    .CHANNEL                           (                          ),
    .OT                                (                          ),
    .XADC_EOC                          (                          ),
    .XADC_EOS                          (                          ) 
    );
    
// ********************************************************************************** // 
//---------------------------------------------------------------------
// blk2711_test_wrapper
//---------------------------------------------------------------------    
generate
    begin : wrapper
        genvar  i;
        for (i = 0; i <= CHANNEL_NUM - 1; i = i + 1)
            begin : blk2711
                //---------------------------------------------------------------------
                // blk2711_wrapper
                //---------------------------------------------------------------------  
                    cl2304_blk2711_warpper cl2304_blk2711_warpper_inst 
                    (
                        .clk_100m                          (clk_100m                  ),
                        .hw_rst_n                          (hw_reset_n                ),
                        .sys_rst_n                         (sys_reset_n               ),
                        .rx_100m                           (rx_100m   [i]             ),
                        .rx_200m                           (rx_200m   [i]             ),
                        .rx_reset_n                        (rx_reset_n[i]             ),
                      //红绿灯
                        .LED_R                             (LED_R[i]                  ),//接受到数据，绿灯亮
                        .LED_G                             (LED_G[i]                  ),//数据丢失，红灯亮
                      //寄存器协议控制
                        .tx_send_en_i                      (tx_send_en[i]              ),
                        .send_k_num                        (send_k_num[16*i+15:16*i]+1'b1),
                        .data_mod_i                        (data_mod[i]                ),
                        .loop_mod_i                        (loop_mod[i]                ),
                      //ddr3 fifo
                        .ddr3_ui_clk                       (ddr3_ui_clk               ),
                        .rx_data                           (rx_data[128*i+127:128*i]  ),
                        .rx_valid                          (rx_valid[i]               ),
                      //------------ 2711 CTRL ------------//
                        .LOOP_EN                           (LOOP_EN[i]                ),
                        .ENABLE                            (ENABLE [i]                ),
                        .LCKREFN                           (LCKREFN[i]                ),
                        .PRBSEN                            (PRBSEN [i]                ),
                        .TESTEN                            (                          ),
                        .PRE                               (PRE [i]                   ),
                      //------------ DATA & DATA_CTRL ------------//
                        .TKMSB                             (TKMSB[i]                  ),
                        .TKLSB                             (TKLSB[i]                  ),
                        .RKMSB                             (RKMSB[i]                  ),
                        .RKLSB                             (RKLSB[i]                  ),
    
                        .TX_Data                           (TX_Data[16*i+15:16*i]     ),
                        .RX_Data                           (RX_Data[16*i+15:16*i]     ) 
                    );
           end
    end
endgenerate
// ********************************************************************************** // 
//---------------------------------------------------------------------
// uart
//---------------------------------------------------------------------
cl2304_uart_warpper   #(
    .UART_NUM                          (UART_NUM                  ) 
) cl2304_uart_warpper_inst(
    .pcie_axi_clk                      (pcie_axi_clk              ),
    .clk_50m                           (clk_50m                   ),
    .sys_reset_n                       (sys_reset_n               ),

    .uart_tx_wren_start                (uart_tx_wren_start        ),
    .uart_tx_wren_end                  (uart_tx_wren_end          ),
    .uart_tx_data                      (uart_tx_data              ),
    .fifo_uart_tx_prog_full            (fifo_uart_tx_prog_full    ),
    
    .uart_bps                          (uart_bps                  ),//波特率
    //    波特率     1200      2400	      4800	    9600       19200      38400	        57600      115200   230400	  460800	921600
    //    设值      0xa2c2    0x5160	 0x28B0	   0x1458      0x0a2c     0x0516	   0x0364      0x01b2   0xD9      0x6C	    0x36	  
    .uart_data_bit                     (uart_data_bit             ),//数据位
    .uart_stop_bit                     (uart_stop_bit             ),//校验位：0，1，2，3分别代表无校验，奇校验，偶校验，无校验
    .uart_parity_bit                   (uart_parity_bit           ),//停止位：0，1，2，3分别代表1，1.5，2，1的停止位

    .fifo_uart_rx_rden                 (fifo_uart_rx_rden         ),
    .fifo_uart_rx_empty                (fifo_uart_rx_empty        ),
    .uart_rx_data                      (uart_rx_data              ),

    .tx_o                              (UART_TXD_RS422            ),
    .rx_i                              (UART_RXD_RS422            ) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// PPS_uart
//---------------------------------------------------------------------
cl2304_uart_warpper   #(
    .UART_NUM                          (1                         ) 
) cl2304_uart_warpper_pps(
    .pcie_axi_clk                      (pcie_axi_clk              ),
    .clk_50m                           (clk_50m                   ),
    .sys_reset_n                       (sys_reset_n               ),

    .uart_tx_wren_start                (pps_uart_tx_wren_start    ),
    .uart_tx_wren_end                  (pps_uart_tx_wren_end      ),
    .uart_tx_data                      (pps_uart_tx_data          ),
    .fifo_uart_tx_prog_full            (pps_uart_tx_prog_full     ),
    
    .uart_bps                          (pps_uart_bps              ),//波特率
    //    波特率     1200      2400	      4800	    9600       19200      38400	        57600      115200   230400	  460800	921600
    //    设值      0xa2c2    0x5160	 0x28B0	   0x1458      0x0a2c     0x0516	   0x0364      0x01b2   0xD9      0x6C	    0x36	  
    .uart_data_bit                     (pps_uart_data_bit         ),//数据位
    .uart_stop_bit                     (pps_uart_stop_bit         ),//校验位：0，1，2，3分别代表无校验，奇校验，偶校验，无校验
    .uart_parity_bit                   (pps_uart_parity_bit       ),//停止位：0，1，2，3分别代表1，1.5，2，1的停止位

    .fifo_uart_rx_rden                 (pps_fifo_uart_rx_rden     ),
    .fifo_uart_rx_empty                (pps_fifo_uart_rx_empty    ),
    .uart_rx_data                      (pps_uart_rx_data          ),

    .tx_o                              (GNSS_RXD_1V8              ),
    .rx_i                              (GNSS_TXD_1V8              ) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// ad7606
//---------------------------------------------------------------------
ad7606_ctrl_logic  ad7606_ctrl_logic_inst (
    .sys_clk_i                         (clk_50m                   ),
    .rst_n_i                           (sys_reset_n               ),

    .start_flag_i                      (ad7606_start_signal       ),

    .reset_o                           (AD7606_RESET_1V8          ),
    .convsta_o                         (AD7606_CONVSTA_1V8        ),
    .convstb_o                         (AD7606_CONVSTB_1V8        ),
    .busy_i                            (AD7606_BUSY_1V8           ),
    .AD7606_FRSTDATA_1V8               (AD7606_FRSTDATA_1V8       ),

    .cs_o                              (AD7606_CS_1V8             ),
    .rd_o                              (AD7606_RD_1V8             ),
    .ad_data_i                         (AD7606_DB_1V8             ),

    .data_flag_o                       (data_flag_o               ),

    .ch1_data                          (ch1_data                  ),
    .ch2_data                          (ch2_data                  ),
    .ch3_data                          (ch3_data                  ),
    .ch4_data                          (ch4_data                  ),
    .ch5_data                          (ch5_data                  ),
    .ch6_data                          (ch6_data                  ),
    .ch7_data                          (ch7_data                  ),
    .ch8_data                          (ch8_data                  ) 
  );
endmodule