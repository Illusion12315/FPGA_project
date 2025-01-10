`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             top.v
// Create Date:           2025/01/02 14:12:42
// Version:               V1.0
// PATH:                  srcs\top.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module top
(
//MIO
    inout  wire        [  14: 0]    DDR_addr            ,
    inout  wire        [   2: 0]    DDR_ba              ,
    inout  wire                     DDR_cas_n           ,
    inout  wire                     DDR_ck_n            ,
    inout  wire                     DDR_ck_p            ,
    inout  wire                     DDR_cke             ,
    inout  wire                     DDR_cs_n            ,
    inout  wire        [   3: 0]    DDR_dm              ,
    inout  wire        [  31: 0]    DDR_dq              ,
    inout  wire        [   3: 0]    DDR_dqs_n           ,
    inout  wire        [   3: 0]    DDR_dqs_p           ,
    inout  wire                     DDR_odt             ,
    inout  wire                     DDR_ras_n           ,
    inout  wire                     DDR_reset_n         ,
    inout  wire                     DDR_we_n            ,
    inout  wire                     FIXED_IO_ddr_vrn    ,
    inout  wire                     FIXED_IO_ddr_vrp    ,
    inout  wire        [  53: 0]    FIXED_IO_mio        ,
    inout  wire                     FIXED_IO_ps_clk     ,
    inout  wire                     FIXED_IO_ps_porb    ,
    inout  wire                     FIXED_IO_ps_srstb   ,
//RTC                                  
    inout  wire                     rtc_rstn_o          ,//JN807 GPIO13
    inout  wire                     rtc_scl_o           ,//JN807 GPIO9
    inout  wire                     rtc_sda_io          ,//JN807 GPIO21
//模拟电源掉电检测                                          
    input  wire                     vop_pos_pg_i        ,//JN807 GPIO29 正电源
    input  wire                     vop_neg_pg_i        ,//JN807 GPIO25 负电源
// 温控                                
    input  wire                     tmp275_alert_i      ,// GPIO65 温度告警
    // output                          o_tmp275_scl        ,// PS_MIO46 用GPIO模拟出IIC接口
    // inout                           io_tmp275_sda       ,// PS_MIO47 用GPIO模拟出IIC接口
//对外并机IO                           
    output wire                     o_fpga_m_s          ,// GPIO81 隔离芯片VE1
    inout  wire        [   1: 0]    io_fpga_trig        ,// GPIO78/GPIO74 隔离芯片VIA/VIB/VOC/VOD
//并机模拟信号控制开关                 
    output wire                     o_p_sw2_fpga        ,//JN807 GPIO93 并机信号输出控制
    output wire                     o_p_sw1_fpga        ,//JN807 GPIO89 并机信号输出控制
    output wire                     o_vmod_sw_fpga      ,//JN807 GPIO101 Vmod档位控制
    output wire                     o_vsense_sw_fpga    ,//JN807 GPIO97  Vsense档位控制
//单通道电流采集                       
    output wire                     o_en_sample         ,//JN807 GPIO133
    output wire        [   2: 0]    o_sel_sample        ,// GPIO129/GPIO141/GPIO137
//flash                                
    output wire                     o_flash_csn         ,// GPIO149
    output wire                     o_flash_sclk        ,// GPIO165
    inout  wire        [   3: 0]    io_flash_io         ,// GPIO161/GPIO145/GPIO157/GPIO153
//风扇故障                                                   
    input  wire        [   7: 0]    fault_pan_i         ,//GPIO2/GPIO14/GPIO10/GPIO22/GPIO18/GPIO30/GPIO178/GPIO182
//硬件过流保护反馈                     
    input  wire                     ocp_da_trig_i       ,//GPIO26   
//CANFD并机                            
    input  wire                     canfd_0_rx_i        ,//JN807 GPIO38
    output wire                     canfd_0_tx_o        ,//JN807 GPIO34
//CANFD屏幕                            
    input  wire                     canfd_1_rx_o        ,//JN807 GPIO46
    output wire                     canfd_1_tx_o        ,//JN807 GPIO42
//HMI通信                              
    input  wire                     uart_rtl_0_rxd_i    ,//GPIO70
    output wire                     uart_rtl_0_txd_o    ,//GPIO66
//整机对外通信接口                     
    input  wire                     uart_rtl_1_rxd_i    ,//JN807 GPIO62
    output wire                     uart_rtl_1_txd_o    ,//JN807 GPIO58
//SW                                   
    output wire                     o_fpga_sw           ,//GPIO86 DA环路输出开关
//CV_limit_FPGA//CV_LIM_SWTICH_Trig//CC_CV_FPGA//Vin_select_FPGA//CV_SP_SLOW_FPGA//CV_SP_MID_FPGA//CV_SP_FAST_FPGA
    output wire                     o_cv_limit          ,//JN807 GPIO82
    input  wire                     cv_limit_switch_i   ,//JN807 GPIO94 CV_LIM判断反馈
    output wire                     o_cv_cc             ,//JN807 GPIO90
    output wire                     o_vin_sel           ,//JN807 GPIO102
    output wire                     o_cv_sp_slow        ,//JN807 GPIO98
    output wire                     o_cv_sp_mid         ,//JN807 GPIO110
    output wire                     o_cv_sp_fast        ,//JN807 GPIO106
//debug led                             
    output wire                     o_debug_led         ,//GPIO130
//拨码                                  
    input  wire        [   3: 0]    dip_switch_i        ,//GPIO142/GPIO138/GPIO150/GPIO146
//外部拨码                              
    input  wire        [   2: 0]    out_dip_switch_i    ,//GPIO158/GPIO154/GPIO166
//ADC AD7606 电流电压采集
    input  wire                     i_ad7606_busy       ,//GPIO23
    output wire                     o_ad7606_rst        ,//GPIO19
    output wire                     o_ad7606_convst     ,//GPIO3
    output wire                     o_ad7606_csn        ,//GPIO11
    output wire                     o_ad7606_rdn        ,//GPIO15
    input  wire        [  15: 0]    i_ad7606_d          ,
//GPIO31/GPIO27/GPIO39/GPIO35/GPIO47/GPIO43/GPIO55/GPIO51/GPIO63/GPIO59/GPIO71/GPIO67/GPIO79/GPIO75/GPIO87/GPIO83
//DAC AD5689   OUTA: CELL_PROG_DA   OUTB: CV_Lim_DA
    output wire                     o_ad5689_ldacn      ,//GPIO95
    output wire                     o_ad5689_rstn       ,//GPIO91
    output wire                     o_ad5689_csn        ,//GPIO103
    output wire                     o_ad5689_sclk       ,//GPIO99
    input  wire                     i_ad5689_miso       ,//GPIO96
    output wire                     o_ad5689_mosi       ,//GPIO92
//ADC ADS131 散热器温度采集 
    output wire                     o_ads131_rstn       ,//JN807 GPIO111
    input  wire                     i_ads131_rdyn       ,//JN807 GPIO107
    output wire                     o_ads131_sclk       ,//JN807 GPIO120
    output wire                     o_ads131_csn        ,//JN807 GPIO123
    output wire                     o_ads131_mosi       ,//JN807 GPIO116
    input  wire                     i_ads131_miso       ,//JN807 GPIO127
//FAN_PWM                               
    output wire                     fan_pwm_o            //,//GPIO104
);

    wire                            clk_100m            ;// 系统主频是100mhz
    wire                            rstn_100m           ;
    wire                            clk_50m             ;
    wire                            rstn_50m            ;

    wire                            w_keyboard_intr     ;
    wire                            w_encoder_intr      ;
    wire                            w_gpib_intr         ;

    wire               [  31: 0]    m02_axi_araddr      ;
    wire               [   2: 0]    m02_axi_arprot      ;
    wire               [   0: 0]    m02_axi_arready     ;
    wire               [   0: 0]    m02_axi_arvalid     ;
    wire               [  31: 0]    m02_axi_awaddr      ;
    wire               [   2: 0]    m02_axi_awprot      ;
    wire               [   0: 0]    m02_axi_awready     ;
    wire               [   0: 0]    m02_axi_awvalid     ;
    wire               [   0: 0]    m02_axi_bready      ;
    wire               [   1: 0]    m02_axi_bresp       ;
    wire               [   0: 0]    m02_axi_bvalid      ;
    wire               [  31: 0]    m02_axi_rdata       ;
    wire               [   0: 0]    m02_axi_rready      ;
    wire               [   1: 0]    m02_axi_rresp       ;
    wire               [   0: 0]    m02_axi_rvalid      ;
    wire               [  31: 0]    m02_axi_wdata       ;
    wire               [   0: 0]    m02_axi_wready      ;
    wire               [   3: 0]    m02_axi_wstrb       ;
    wire               [   0: 0]    m02_axi_wvalid      ;

    wire               [  31: 0]    m03_axi_araddr      ;
    wire               [   2: 0]    m03_axi_arprot      ;
    wire               [   0: 0]    m03_axi_arready     ;
    wire               [   0: 0]    m03_axi_arvalid     ;
    wire               [  31: 0]    m03_axi_awaddr      ;
    wire               [   2: 0]    m03_axi_awprot      ;
    wire               [   0: 0]    m03_axi_awready     ;
    wire               [   0: 0]    m03_axi_awvalid     ;
    wire               [   0: 0]    m03_axi_bready      ;
    wire               [   1: 0]    m03_axi_bresp       ;
    wire               [   0: 0]    m03_axi_bvalid      ;
    wire               [  31: 0]    m03_axi_rdata       ;
    wire               [   0: 0]    m03_axi_rready      ;
    wire               [   1: 0]    m03_axi_rresp       ;
    wire               [   0: 0]    m03_axi_rvalid      ;
    wire               [  31: 0]    m03_axi_wdata       ;
    wire               [   0: 0]    m03_axi_wready      ;
    wire               [   3: 0]    m03_axi_wstrb       ;
    wire               [   0: 0]    m03_axi_wvalid      ;

    wire               [  31: 0]    m04_axi_araddr      ;
    wire               [   2: 0]    m04_axi_arprot      ;
    wire               [   0: 0]    m04_axi_arready     ;
    wire               [   0: 0]    m04_axi_arvalid     ;
    wire               [  31: 0]    m04_axi_awaddr      ;
    wire               [   2: 0]    m04_axi_awprot      ;
    wire               [   0: 0]    m04_axi_awready     ;
    wire               [   0: 0]    m04_axi_awvalid     ;
    wire               [   0: 0]    m04_axi_bready      ;
    wire               [   1: 0]    m04_axi_bresp       ;
    wire               [   0: 0]    m04_axi_bvalid      ;
    wire               [  31: 0]    m04_axi_rdata       ;
    wire               [   0: 0]    m04_axi_rready      ;
    wire               [   1: 0]    m04_axi_rresp       ;
    wire               [   0: 0]    m04_axi_rvalid      ;
    wire               [  31: 0]    m04_axi_wdata       ;
    wire               [   0: 0]    m04_axi_wready      ;
    wire               [   3: 0]    m04_axi_wstrb       ;
    wire               [   0: 0]    m04_axi_wvalid      ;
//电子负载
    wire               [  31: 0]    m05_axi_araddr      ;
    wire               [   2: 0]    m05_axi_arprot      ;
    wire               [   0: 0]    m05_axi_arready     ;
    wire               [   0: 0]    m05_axi_arvalid     ;
    wire               [  31: 0]    m05_axi_awaddr      ;
    wire               [   2: 0]    m05_axi_awprot      ;
    wire               [   0: 0]    m05_axi_awready     ;
    wire               [   0: 0]    m05_axi_awvalid     ;
    wire               [   0: 0]    m05_axi_bready      ;
    wire               [   1: 0]    m05_axi_bresp       ;
    wire               [   0: 0]    m05_axi_bvalid      ;
    wire               [  31: 0]    m05_axi_rdata       ;
    wire               [   0: 0]    m05_axi_rready      ;
    wire               [   1: 0]    m05_axi_rresp       ;
    wire               [   0: 0]    m05_axi_rvalid      ;
    wire               [  31: 0]    m05_axi_wdata       ;
    wire               [   0: 0]    m05_axi_wready      ;
    wire               [   3: 0]    m05_axi_wstrb       ;
    wire               [   0: 0]    m05_axi_wvalid      ;
//ADS131M08采集的温度Code码
    wire               [  31: 0]    ch0_temp            ;//0000
    wire               [  31: 0]    ch1_temp            ;//0001
    wire               [  31: 0]    ch2_temp            ;//0002
    wire               [  31: 0]    ch3_temp            ;//0003
    wire               [  31: 0]    ch4_temp            ;//0004
    wire               [  31: 0]    ch5_temp            ;//0005
    wire               [  31: 0]    ch6_temp            ;//0006
    wire               [  31: 0]    ch7_temp            ;//0007
										 
    wire               [   1: 0]    gpio_eload_tri_o    ;
    wire               [   2: 0]    GPIO_0_tri_io       ;//RTC用GPIO模拟CE/SCLK/IO,其中IO为inout
//ADC 采样值  二进制补码   +-
//ADC_code码
    wire                            adc_acq_valid       ;
    wire     signed    [  15: 0]    HI_sum              ;//I_SUM_H_AD----高档位8路板卡汇总电流4.521V
    wire     signed    [  15: 0]    LI_sum              ;//I_SUM_L_AD----低档位8路板卡汇总电流
    wire     signed    [  15: 0]    HI_board            ;//I_BOARD_H_AD----高档位板卡电流4.5V
    wire     signed    [  15: 0]    LI_board            ;//I_BOARD_L_AD----低档位板卡电流
    wire     signed    [  15: 0]    U_mod               ;//AD_Vmod----非sense端电压
    wire     signed    [  15: 0]    U_sense             ;//AD_Vsense----sense端电压
    wire     signed    [  15: 0]    I_sum_unit          ;//I_SUM_UNIT_AD----单板卡24模块汇总电流4.125V
    wire     signed    [  15: 0]    I_board_unit        ;//I_BOARD_UNIT_AD----单板卡单模块电流3.4375V
//DAC 输出 //控制MOS管的Vgs电压进而控制Ids (MOS管必须工作在线性区间)
//DAC_code码
    wire                            dac_cha_valid       ;
    wire               [  15: 0]    dac_cha_data        ;
    wire                            dac_chb_valid       ;
    wire               [  15: 0]    dac_chb_data        ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// assigns
//---------------------------------------------------------------------
//RTC ----  AXI_GPIO  ----  simulate IIC
    assign                          rtc_rstn_o         = GPIO_0_tri_io[0];
    assign                          rtc_scl_o          = GPIO_0_tri_io[1];
    assign                          rtc_sda_io         = GPIO_0_tri_io[2];
//-----------------------------------------------------------
// CAN总线前期为AXI_CAN调试,后期改为AXI_CANFD
//-----------------------------------------------------------

design_1_wrapper u_ps
(
    .CAN_INTERFACE_0_rx             (canfd_0_rx_i       ),//input  ---- AXI_CANFD //AXI_LITE_9
    .CAN_INTERFACE_0_tx             (canfd_0_tx_o       ),//output ---- AXI_CANFD //AXI_LITE_9
    .CAN_INTERFACE_1_rx             (canfd_1_rx_o       ),//input  ---- AXI_CANFD //AXI_LITE_10
    .CAN_INTERFACE_1_tx             (canfd_1_tx_o       ),//output ---- AXI_CANFD //AXI_LITE_10
    .uart_rx_0                      (uart_rtl_0_rxd_i   ),//input  ---- AXI_UART  //AXI_LITE_0
    .uart_tx_0                      (uart_rtl_0_txd_o   ),//output ---- AXI_UART  //AXI_LITE_0
    .uart_rx_1                      (uart_rtl_1_rxd_i   ),//input  ---- AXI_UART  //AXI_LITE_1
    .uart_tx_1                      (uart_rtl_1_txd_o   ),//output ---- AXI_UART  //AXI_LITE_1
	
    .GPIO_0_tri_io                  (GPIO_0_tri_io      ),//inout   ---- AXI_GPIO  //AXI_LITE_11
	
    .clk_100m                       (clk_100m           ),//AXI_LITE_0/1/2/3/4/9/10/11
    .rstn_100m                      (rstn_100m          ),//AXI_LITE_0/1/2/3/4/9/10/11
    .clk_50m                        (clk_50m            ),//AXI_LITE_5/6/7/8
    .rstn_50m                       (rstn_50m           ),//AXI_LITE_5/6/7/8
	
    .DDR_addr                       (DDR_addr           ),
    .DDR_ba                         (DDR_ba             ),
    .DDR_cas_n                      (DDR_cas_n          ),
    .DDR_ck_n                       (DDR_ck_n           ),
    .DDR_ck_p                       (DDR_ck_p           ),
    .DDR_cke                        (DDR_cke            ),
    .DDR_cs_n                       (DDR_cs_n           ),
    .DDR_dm                         (DDR_dm             ),
    .DDR_dq                         (DDR_dq             ),
    .DDR_dqs_n                      (DDR_dqs_n          ),
    .DDR_dqs_p                      (DDR_dqs_p          ),
    .DDR_odt                        (DDR_odt            ),
    .DDR_ras_n                      (DDR_ras_n          ),
    .DDR_reset_n                    (DDR_reset_n        ),
    .DDR_we_n                       (DDR_we_n           ),
    .FIXED_IO_ddr_vrn               (FIXED_IO_ddr_vrn   ),
    .FIXED_IO_ddr_vrp               (FIXED_IO_ddr_vrp   ),
    .FIXED_IO_mio                   (FIXED_IO_mio       ),
    .FIXED_IO_ps_clk                (FIXED_IO_ps_clk    ),
    .FIXED_IO_ps_porb               (FIXED_IO_ps_porb   ),
    .FIXED_IO_ps_srstb              (FIXED_IO_ps_srstb  ),
	
	//keyboard spi and fan pwm falt 	
    .M02_AXI_araddr                 (m02_axi_araddr     ),//AXI_LITE_2
    .M02_AXI_arprot                 (m02_axi_arprot     ),//AXI_LITE_2
    .M02_AXI_arready                (m02_axi_arready    ),//AXI_LITE_2
    .M02_AXI_arvalid                (m02_axi_arvalid    ),//AXI_LITE_2
    .M02_AXI_awaddr                 (m02_axi_awaddr     ),//AXI_LITE_2
    .M02_AXI_awprot                 (m02_axi_awprot     ),//AXI_LITE_2
    .M02_AXI_awready                (m02_axi_awready    ),//AXI_LITE_2
    .M02_AXI_awvalid                (m02_axi_awvalid    ),//AXI_LITE_2
    .M02_AXI_bready                 (m02_axi_bready     ),//AXI_LITE_2
    .M02_AXI_bresp                  (m02_axi_bresp      ),//AXI_LITE_2
    .M02_AXI_bvalid                 (m02_axi_bvalid     ),//AXI_LITE_2
    .M02_AXI_rdata                  (m02_axi_rdata      ),//AXI_LITE_2
    .M02_AXI_rready                 (m02_axi_rready     ),//AXI_LITE_2
    .M02_AXI_rresp                  (m02_axi_rresp      ),//AXI_LITE_2
    .M02_AXI_rvalid                 (m02_axi_rvalid     ),//AXI_LITE_2
    .M02_AXI_wdata                  (m02_axi_wdata      ),//AXI_LITE_2
    .M02_AXI_wready                 (m02_axi_wready     ),//AXI_LITE_2
    .M02_AXI_wstrb                  (m02_axi_wstrb      ),//AXI_LITE_2
    .M02_AXI_wvalid                 (m02_axi_wvalid     ),//AXI_LITE_2
	//reserve
    .M03_AXI_araddr                 (m03_axi_araddr     ),//AXI_LITE_3
    .M03_AXI_arprot                 (m03_axi_arprot     ),//AXI_LITE_3
    .M03_AXI_arready                (m03_axi_arready    ),//AXI_LITE_3
    .M03_AXI_arvalid                (m03_axi_arvalid    ),//AXI_LITE_3
    .M03_AXI_awaddr                 (m03_axi_awaddr     ),//AXI_LITE_3
    .M03_AXI_awprot                 (m03_axi_awprot     ),//AXI_LITE_3
    .M03_AXI_awready                (m03_axi_awready    ),//AXI_LITE_3
    .M03_AXI_awvalid                (m03_axi_awvalid    ),//AXI_LITE_3
    .M03_AXI_bready                 (m03_axi_bready     ),//AXI_LITE_3
    .M03_AXI_bresp                  (m03_axi_bresp      ),//AXI_LITE_3
    .M03_AXI_bvalid                 (m03_axi_bvalid     ),//AXI_LITE_3
    .M03_AXI_rdata                  (m03_axi_rdata      ),//AXI_LITE_3
    .M03_AXI_rready                 (m03_axi_rready     ),//AXI_LITE_3
    .M03_AXI_rresp                  (m03_axi_rresp      ),//AXI_LITE_3
    .M03_AXI_rvalid                 (m03_axi_rvalid     ),//AXI_LITE_3
    .M03_AXI_wdata                  (m03_axi_wdata      ),//AXI_LITE_3
    .M03_AXI_wready                 (m03_axi_wready     ),//AXI_LITE_3
    .M03_AXI_wstrb                  (m03_axi_wstrb      ),//AXI_LITE_3
    .M03_AXI_wvalid                 (m03_axi_wvalid     ),//AXI_LITE_3
	//temperature
    .M04_AXI_araddr                 (m04_axi_araddr     ),//AXI_LITE_4
    .M04_AXI_arprot                 (m04_axi_arprot     ),//AXI_LITE_4
    .M04_AXI_arready                (m04_axi_arready    ),//AXI_LITE_4
    .M04_AXI_arvalid                (m04_axi_arvalid    ),//AXI_LITE_4
    .M04_AXI_awaddr                 (m04_axi_awaddr     ),//AXI_LITE_4
    .M04_AXI_awprot                 (m04_axi_awprot     ),//AXI_LITE_4
    .M04_AXI_awready                (m04_axi_awready    ),//AXI_LITE_4
    .M04_AXI_awvalid                (m04_axi_awvalid    ),//AXI_LITE_4
    .M04_AXI_bready                 (m04_axi_bready     ),//AXI_LITE_4
    .M04_AXI_bresp                  (m04_axi_bresp      ),//AXI_LITE_4
    .M04_AXI_bvalid                 (m04_axi_bvalid     ),//AXI_LITE_4
    .M04_AXI_rdata                  (m04_axi_rdata      ),//AXI_LITE_4
    .M04_AXI_rready                 (m04_axi_rready     ),//AXI_LITE_4
    .M04_AXI_rresp                  (m04_axi_rresp      ),//AXI_LITE_4
    .M04_AXI_rvalid                 (m04_axi_rvalid     ),//AXI_LITE_4
    .M04_AXI_wdata                  (m04_axi_wdata      ),//AXI_LITE_4
    .M04_AXI_wready                 (m04_axi_wready     ),//AXI_LITE_4
    .M04_AXI_wstrb                  (m04_axi_wstrb      ),//AXI_LITE_4
    .M04_AXI_wvalid                 (m04_axi_wvalid     ),//AXI_LITE_4
	
    .key_int                        (1'b0/* w_keyboard_intr */),//input [0:0] ---- EMIO GPIO
    .In0                            (1'b0/* w_encoder_intr */),//input [0:0] ---- IRQ0
    .In3                            (1'b0/* w_gpib_intr */),//input [0:0] ---- IRQ3
	//电子负载触发
    .GPIO_eload_tri_o               (gpio_eload_tri_o   ),//output [1:0] ---- AXI_GPIO //AXI_LITE_6
    .gpio_user_key_tri_i            (4'b0/*gpio_user_key_tri_i*/),//input [3:0] ---- AXI_GPIO //AXI_LITE_7
    .gpio_led_beep_tri_o            (/* gpio_led_beep_tri_o */),//output [1:0] ---- AXI_GPIO //AXI_LITE_8	
    //电子负载
    .M05_AXI_araddr                 (m05_axi_araddr     ),//AXI_LITE_5
    .M05_AXI_arprot                 (m05_axi_arprot     ),//AXI_LITE_5
    .M05_AXI_arready                (m05_axi_arready    ),//AXI_LITE_5
    .M05_AXI_arvalid                (m05_axi_arvalid    ),//AXI_LITE_5
    .M05_AXI_awaddr                 (m05_axi_awaddr     ),//AXI_LITE_5
    .M05_AXI_awprot                 (m05_axi_awprot     ),//AXI_LITE_5
    .M05_AXI_awready                (m05_axi_awready    ),//AXI_LITE_5
    .M05_AXI_awvalid                (m05_axi_awvalid    ),//AXI_LITE_5
    .M05_AXI_bready                 (m05_axi_bready     ),//AXI_LITE_5
    .M05_AXI_bresp                  (m05_axi_bresp      ),//AXI_LITE_5
    .M05_AXI_bvalid                 (m05_axi_bvalid     ),//AXI_LITE_5
    .M05_AXI_rdata                  (m05_axi_rdata      ),//AXI_LITE_5
    .M05_AXI_rready                 (m05_axi_rready     ),//AXI_LITE_5
    .M05_AXI_rresp                  (m05_axi_rresp      ),//AXI_LITE_5
    .M05_AXI_rvalid                 (m05_axi_rvalid     ),//AXI_LITE_5
    .M05_AXI_wdata                  (m05_axi_wdata      ),//AXI_LITE_5
    .M05_AXI_wready                 (m05_axi_wready     ),//AXI_LITE_5
    .M05_AXI_wstrb                  (m05_axi_wstrb      ),//AXI_LITE_5
    .M05_AXI_wvalid                 (m05_axi_wvalid     ) //AXI_LITE_5
);

//fan pwm and key spi 
key_fan_ctrl_wrapper #(
    .C_S_AXI_DATA_WIDTH             (32                 ),
    .C_S_AXI_ADDR_WIDTH             (12                 ) 
) u_key_fan_ctrl_wrapper (
    .S_AXI_ACLK                     (clk_100m           ),
    .S_AXI_ARESETN                  (rstn_100m          ),
	
    .S_AXI_AWADDR                   (m02_axi_awaddr     ),
    .S_AXI_AWPROT                   (m02_axi_awprot     ),
    .S_AXI_AWVALID                  (m02_axi_awvalid    ),
    .S_AXI_AWREADY                  (m02_axi_awready    ),
    .S_AXI_WDATA                    (m02_axi_wdata      ),
    .S_AXI_WSTRB                    (m02_axi_wstrb      ),
    .S_AXI_WVALID                   (m02_axi_wvalid     ),
    .S_AXI_WREADY                   (m02_axi_wready     ),
    .S_AXI_BRESP                    (m02_axi_bresp      ),
    .S_AXI_BVALID                   (m02_axi_bvalid     ),
    .S_AXI_BREADY                   (m02_axi_bready     ),
    .S_AXI_ARADDR                   (m02_axi_araddr     ),
    .S_AXI_ARPROT                   (m02_axi_arprot     ),
    .S_AXI_ARVALID                  (m02_axi_arvalid    ),
    .S_AXI_ARREADY                  (m02_axi_arready    ),
    .S_AXI_RDATA                    (m02_axi_rdata      ),
    .S_AXI_RRESP                    (m02_axi_rresp      ),
    .S_AXI_RVALID                   (m02_axi_rvalid     ),
    .S_AXI_RREADY                   (m02_axi_rready     ),

	//风扇pwm输出，故障输入信号
    .poc_pwm1_o                     (fan_pwm_o          ),//poc_pwm1
    .poc_pwm2_o                     (                   ),///*poc_pwm2*/
    .pic_pwm1_i                     (fault_pan_i[0]     ),//pic_pwm1		   
    .pic_pwm2_i                     (fault_pan_i[1]     ),//1'b1/*pic_pwm2*/	
    .pic_pwm3_i                     (fault_pan_i[2]     ),//1'b1/*pic_pwm3*/	
    .pic_pwm4_i                     (fault_pan_i[3]     ),//1'b1/*pic_pwm4*/	
    .pic_pwm5_i                     (fault_pan_i[4]     ),//1'b1/*pic_pwm5*/	
    .pic_pwm6_i                     (fault_pan_i[5]     ),//1'b1/*pic_pwm6*/	
    .pic_pwm7_i                     (fault_pan_i[6]     ),//1'b1/*pic_pwm7*/	
    .pic_pwm8_i                     (fault_pan_i[7]     ),//1'b1/*pic_pwm8*/	

	//按键板驱动信号
    .spi_ss                         (                   ),//o_spi_ss		   
    .spi_sck                        (                   ),//o_spi_sck		   
    .spi_dout                       (                   ),//o_spi_dout		   
    .spi_din                        (                   ),//i_spi_din		   
    .key_rst                        (                   ),//o_key_rst		   
    .key_int                        (                   ),//i_key_int		   
    .o_key_intr                     (                   ) //w_keyboard_intr   
);

temperature_wrapper#(
    .C_S_AXI_DATA_WIDTH             (32                 ),
    .C_S_AXI_ADDR_WIDTH             (12                 ) 
)
u_temperature_wrapper(
//ADC ADS131 散热器温度采集 
    .ch0_temp                       (ch0_temp           ),// input slv_reg000 ch0_temp [32-1:0]
    .ch1_temp                       (ch1_temp           ),// input slv_reg001 ch1_temp [32-1:0]
    .ch2_temp                       (ch2_temp           ),// input slv_reg002 ch2_temp [32-1:0]
    .ch3_temp                       (ch3_temp           ),// input slv_reg003 ch3_temp [32-1:0]
    .ch4_temp                       (ch4_temp           ),// input slv_reg004 ch4_temp [32-1:0]
    .ch5_temp                       (ch5_temp           ),// input slv_reg005 ch5_temp [32-1:0]
    .ch6_temp                       (ch6_temp           ),// input slv_reg006 ch6_temp [32-1:0]
    .ch7_temp                       (ch7_temp           ),// input slv_reg007 ch7_temp [32-1:0]
// User ports starts
    .vop_pos_pg_i                   (vop_pos_pg_i       ),// input slv_reg009 vop_pos_pg_i [ 1-1:0]
    .vop_neg_pg_i                   (vop_neg_pg_i       ),// input slv_reg009 vop_neg_pg_i [ 1-1:0]
    .tmp275_alert_i                 (tmp275_alert_i     ),// input slv_reg009 tmp275_alert_i [ 1-1:0]
    .ocp_da_trig_i                  (ocp_da_trig_i      ),// input slv_reg009 ocp_da_trig_i [ 1-1:0]
    .cv_limit_switch_i              (cv_limit_switch_i  ),// input slv_reg009 cv_limit_switch_i [ 1-1:0]
    .out_dip_switch_i               (out_dip_switch_i   ),// input slv_reg009 out_dip_switch_i [ 3-1:0]
    .dip_switch_i                   (dip_switch_i       ),// input slv_reg009 dip_switch_i [ 4-1:0]
    .fault_pan_i                    (fault_pan_i        ),// input slv_reg009 fault_pan_i [ 8-1:0]
// User ports ends
    .S_AXI_ACLK                     (clk_100m           ),
    .S_AXI_ARESETN                  (rstn_100m          ),
    .S_AXI_AWADDR                   (m02_axi_awaddr     ),
    .S_AXI_AWPROT                   (m02_axi_awprot     ),
    .S_AXI_AWVALID                  (m02_axi_awvalid    ),
    .S_AXI_AWREADY                  (m02_axi_awready    ),
    .S_AXI_WDATA                    (m02_axi_wdata      ),
    .S_AXI_WSTRB                    (m02_axi_wstrb      ),
    .S_AXI_WVALID                   (m02_axi_wvalid     ),
    .S_AXI_WREADY                   (m02_axi_wready     ),
    .S_AXI_BRESP                    (m02_axi_bresp      ),
    .S_AXI_BVALID                   (m02_axi_bvalid     ),
    .S_AXI_BREADY                   (m02_axi_bready     ),
    .S_AXI_ARADDR                   (m02_axi_araddr     ),
    .S_AXI_ARPROT                   (m02_axi_arprot     ),
    .S_AXI_ARVALID                  (m02_axi_arvalid    ),
    .S_AXI_ARREADY                  (m02_axi_arready    ),
    .S_AXI_RDATA                    (m02_axi_rdata      ),
    .S_AXI_RRESP                    (m02_axi_rresp      ),
    .S_AXI_RVALID                   (m02_axi_rvalid     ),
    .S_AXI_RREADY                   (m02_axi_rready     ) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// ADC采样
//---------------------------------------------------------------------
// 温度采样
ADS131M08_ctrl u_ADS131M08_ctrl
(
    .i_clk                          (clk_100m           ),
    .i_rst                          (~rstn_100m         ),
    //output
    .o_ch0_data                     (ch0_temp           ),//w_reg0000in
    .o_ch1_data                     (ch1_temp           ),//w_reg0001in
    .o_ch2_data                     (ch2_temp           ),//w_reg0002in
    .o_ch3_data                     (ch3_temp           ),//w_reg0003in
    .o_ch4_data                     (ch4_temp           ),//w_reg0004in
    .o_ch5_data                     (ch5_temp           ),//w_reg0005in
    .o_ch6_data                     (ch6_temp           ),//w_reg0006in
    .o_ch7_data                     (ch7_temp           ),//w_reg0007in
    .o_crc_data                     (                   ),//
    .o_resp_data                    (                   ),//
    //IC
    .o_ic_rstn                      (o_ads131_rstn      ),//
    .i_ic_drdy                      (i_ads131_rdyn      ),//
    .o_ic_sclk                      (o_ads131_sclk      ),
    .o_ic_cs                        (o_ads131_csn       ),
    .o_ic_mosi                      (o_ads131_mosi      ),
    .i_ic_miso                      (i_ads131_miso      ),
    .o_ic_dir                       (                   ) 
);
// ADC电压采样
//-----------------------------------------------------------------------
// ADC
// AD7606 八通道
// SPI接口
// ADI
//-----------------------------------------------------------------------
AD7606_ctrl u_AD7606_ctrl
(
    .i_clk                          (clk_100m           ),//100M
    .i_rst                          (~rstn_100m         ),//
    
    .o_done                         (adc_acq_valid      ),//
    .o_adcdata                      ({I_board_unit,I_sum_unit,U_sense,U_mod,LI_board,HI_board,LI_sum,HI_sum}),//                     
    
    .o_ic_reset                     (o_ad7606_rst       ),//reset
    .o_ic_cs                        (o_ad7606_csn       ),///cs
    .o_ic_sclk                      (o_ad7606_rdn       ),//rd
    .o_ic_conv                      (o_ad7606_convst    ),
    .i_ic_busy                      (i_ad7606_busy      ),
    .i_ic_miso                      (i_ad7606_d         ) 
);
// DAC输出
 //-----------------------------------------------------------------------
// DAC
// AD5689 双通道
// SPI接口
// ADI
//-----------------------------------------------------------------------
AD5689_ctrl u_AD5689_ctrl
(
    .i_clk                          (clk_100m           ),//input          
    .i_rst                          (~rstn_100m         ),//input          
													 
    .i_cha_set                      (dac_cha_valid      ),//input        
    .i_cha_data                     (dac_cha_data       ),//input [15:0] 
    .i_chb_set                      (dac_chb_valid      ),//input        
    .i_chb_data                     (dac_chb_data       ),//input [15:0] 
    .i_cmd_set                      (0                  ),//input        
    .i_cmd_data                     (0                  ),//input [19:0] 
    .i_cmd_type                     (0                  ),//input [ 3:0] 
													    
    .o_ic_resetn                    (o_ad5689_rstn      ),//output      
    .o_ic_ldac                      (o_ad5689_ldacn     ),//output      
    .o_ic_pdl                       (                   ),//output      
    .o_ic_sclk                      (o_ad5689_sclk      ),//output      
    .o_ic_cs                        (o_ad5689_csn       ),//output      
    .o_ic_mosi                      (o_ad5689_mosi      ),//output      
    .i_ic_miso                      (i_ad5689_miso      ),//input       
    .o_ic_dir                       (                   ) //output      
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 电子负载控制逻辑主体
//---------------------------------------------------------------------









endmodule


`default_nettype wire
