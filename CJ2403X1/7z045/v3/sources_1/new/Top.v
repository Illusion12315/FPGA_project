`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: chen xiong zhi
// 
// Create Date: 2024/06/04 17:15:57
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
`define  sim_data
module Top    # (    
        parameter       SRIO_CH_NUM             =   1,  
        parameter       SRIO_ONCE_LENGTH        =   8,
        parameter       SRIO_WR_DATA_WIDTH      =   128, 
        parameter       SRIO_RD_DATA_WIDTH      =   128,
        parameter       SRIO_LINK_WIDTH         =   4                           // 1- X1; 2 - X2; 4 - X4; 8 - X8   
    )(
    input  wire                         SYSCLK_Z7_PL               ,// from ad9516

    input  wire                         SYSCLK                     ,// from ctystal oscillator
    // ad9516
    output wire                         AD9516_1_RESET_B           ,
    output wire                         AD9516_1_PD_B              ,// power down

    output wire                         AD9516_1_SCLK              ,
    output wire                         AD9516_1_SDIO              ,
    input  wire                         AD9516_1_SDO               ,
    output wire                         AD9516_1_CS                ,

    input  wire                         AD9516_1_STATUS            ,
    output wire                         AD9516_1_REFSEL            ,

    output wire                         AD9516_2_RESET_B           ,
    output wire                         AD9516_2_PD_B              ,

    output wire                         AD9516_2_SCLK              ,
    output wire                         AD9516_2_SDIO              ,
    input  wire                         AD9516_2_SDO               ,
    output wire                         AD9516_2_CS                ,

    input  wire                         AD9516_2_STATUS            ,
    output wire                         AD9516_2_REFSEL            ,
    // reset
    input  wire                         RESET_N_3V3                ,

    // ddr3
    input  wire                         Z7_PL_DDR3_CLK_P           ,
    input  wire                         Z7_PL_DDR3_CLK_N           ,

    // srio
//    input  wire                         SRIO_REFCLK13_P            ,
//    input  wire                         SRIO_REFCLK13_N            ,
    
            // SRIO Interface
    input                                   srio_refclkp_bp         ,                // 156.25MHz differential clock
    input                                   srio_refclkn_bp         ,                // 156.25MHz differential clock
    input       [SRIO_LINK_WIDTH-1:0]       srio_rxp_bp             ,                // Serial Receive Data +
    input       [SRIO_LINK_WIDTH-1:0]       srio_rxn_bp             ,                // Serial Receive Data -
    output      [SRIO_LINK_WIDTH-1:0]       srio_txp_bp             ,                // Serial Transmit Data +
    output      [SRIO_LINK_WIDTH-1:0]       srio_txn_bp             ,              // Serial Transmit Data -

    // gpio
    output wire  [15:0]                   Z7_PL_GPIO                ,
//    output wire                         Z7_PL_GPIO1                ,
//    output wire                         Z7_PL_GPIO2                ,
//    output wire                         Z7_PL_GPIO3                ,
//    output wire                         Z7_PL_GPIO4                ,
//    output wire                         Z7_PL_GPIO5                ,
//    output wire                         Z7_PL_GPIO6                ,
//    output wire                         Z7_PL_GPIO7                ,
//    output wire                         Z7_PL_GPIO8                ,
//    output wire                         Z7_PL_GPIO9                ,
//    output wire                         Z7_PL_GPIO10               ,
//    output wire                         Z7_PL_GPIO11               ,
//    output wire                         Z7_PL_GPIO12               ,
//    output wire                         Z7_PL_GPIO13               ,
//    output wire                         Z7_PL_GPIO14               ,
//    output wire                         Z7_PL_GPIO15               ,

      output wire [5:0]                   Z7_KU115_GPIO             ,
//    output wire                         Z7_KU115_GPIO1             ,
//    output wire                         Z7_KU115_GPIO2             ,
//    output wire                         Z7_KU115_GPIO3             ,
//    output wire                         Z7_KU115_GPIO4             ,
//    output wire                         Z7_KU115_GPIO5             ,
//    output wire                         Z7_KU115_GPIO6             ,
    
    inout [14:0]                        DDR_0_addr                  ,
    inout [2: 0]                        DDR_0_ba                    ,
    inout                               DDR_0_cas_n                 ,
    inout                               DDR_0_ck_n                  ,
    inout                               DDR_0_ck_p                  ,
    inout                               DDR_0_cke                   ,
    inout                               DDR_0_cs_n                  ,
    inout [3: 0]                        DDR_0_dm                    ,
    inout [31:0]                        DDR_0_dq                    ,
    inout [3: 0]                        DDR_0_dqs_n                 ,
    inout [3: 0]                        DDR_0_dqs_p                 ,
    inout                               DDR_0_odt                   ,
    inout                               DDR_0_ras_n                 ,
    inout                               DDR_0_reset_n               ,
    inout                               DDR_0_we_n                  ,
//    output                              FCLK_CLK0_0                 ,
    inout                               FIXED_IO_0_ddr_vrn          ,
    inout                               FIXED_IO_0_ddr_vrp          ,
    inout [53:0]                        FIXED_IO_0_mio              ,
    inout                               FIXED_IO_0_ps_clk           ,
    inout                               FIXED_IO_0_ps_porb          , 
    inout                               FIXED_IO_0_ps_srstb         
    );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declaration
//---------------------------------------------------------------------
    wire                                clk_100m                   ;
    wire                                clk_50m                    ;
    wire                                hw_arst_n                  ;// clk50m
    wire                                sw_arst_n                  ;// clk50m
    wire                                ad9516_1_rst_n             ;// clk50m
    wire                                ad9516_2_rst_n             ;// clk50m

    wire                                Z7_PL_DDR3_CLK             ;
    wire                                SRIO_REFCLK13              ;
    
    wire [31:0]                         w_ps2ps_gpio                ;
    wire                                vio_ps_read                 ;


    wire [127:0]                      M_AXIS_MM2S_0_tdata         ;
    wire [15 :0]                      M_AXIS_MM2S_0_tkeep         ;
    wire                              M_AXIS_MM2S_0_tlast         ;
    wire                              M_AXIS_MM2S_0_tready        ;
    wire                              M_AXIS_MM2S_0_tvalid        ;
    
    wire[31:0]                        S_AXIS_S2MM_0_tdata         ;
    wire[3 :0]                        S_AXIS_S2MM_0_tkeep         ;
    wire                              S_AXIS_S2MM_0_tlast         ;
    wire                              S_AXIS_S2MM_0_tready        ;
    wire                              S_AXIS_S2MM_0_tvalid        ;
    wire [31:0]                       vio_trans_lens              ;
    
    wire  [0: 0]                          RESETN                  ;
    wire                                  FCLK_CLK0_0             ;
//-----------------SRIO
//  srio_app_wrapper
    wire                                    srio_log_clk;
    wire                                    srio_log_rst;
    wire                                    srio_clk_lock;
    // SRIO ID   
    wire        [15:0]                      source_id               ;  
    wire        [15:0]                      dest_id                 ;   
    wire        [15:0]                      device_id               ;
    wire        [15:0]                      device_id_set           ;
    wire                                    id_set_done             ;
    // Status Signals
    wire                                    port_initialized        ;
    wire                                    link_initialized        ;
    wire                                    mode_1x                 ;
    // FIFO Interface for Packet Transmit
    wire        [SRIO_CH_NUM-1:0]           fifo_wrreq_pkt_tx       ;
    wire        [SRIO_CH_NUM*SRIO_WR_DATA_WIDTH-1:0]    fifo_data_pkt_tx;
    wire        [SRIO_CH_NUM-1:0]           fifo_prog_full_pkt_tx   ;        
    // FIFO Interface for Packet Receive
    wire        [SRIO_CH_NUM-1:0]           fifo_rdreq_pkt_rx           ;
    wire        [SRIO_CH_NUM*SRIO_RD_DATA_WIDTH-1:0]    fifo_q_pkt_rx   ;
    wire        [SRIO_CH_NUM-1:0]           fifo_empty_pkt_rx           ; 
    wire        [SRIO_CH_NUM-1:0]           fifo_prog_empty_pkt_rx      ;     
    
    wire                                    sw_reset_n;
    wire                                    fiber_sw_rst;
    wire                                    loopback_sel;               // "0" 不回环;"1"内回环;
    wire                                    wr_test_clk                 ;
    wire                                    rd_test_clk                 ;
    wire        [SRIO_CH_NUM-1:0]           wr_data_en                  ;
    wire        [SRIO_CH_NUM-1:0]           rd_data_en                  ;
// ********************************************************************************** // 
assign      wr_test_clk         =   FCLK_CLK0_0;
assign      rd_test_clk         =   FCLK_CLK0_0;

assign      Z7_PL_GPIO      =   w_ps2ps_gpio[15:0];
assign      Z7_KU115_GPIO   =   w_ps2ps_gpio[21:16];
//---------------------------------------------------------------------
// clk and rst
//---------------------------------------------------------------------
clk_rst_warpper  clk_rst_warpper_inst (
    .SYSCLK                             (SYSCLK                    ),
    .clk_100m                           (clk_100m                  ),
    .clk_50m                            (clk_50m                   ),
    .hw_arst_n                          (hw_arst_n                 ),
    .sw_arst_n                          (sw_arst_n                 ),
    .ad9516_1_rst_n                     (ad9516_1_rst_n            ),
    .ad9516_2_rst_n                     (ad9516_2_rst_n            ),
    /********axi_ctrl*******************/
    .Z7_PL_GPIO                         (w_ps2ps_gpio               ),
    .vio_ps_read                        (vio_ps_read                ),
    .vio_trans_lens                     (vio_trans_lens             ),
     /***********srio_ctrl******************/
    .fiber_sw_rst                       (),
    .loopback_sel                       (),               // "0" 不回环;"1"内回环;
    .wr_data_en                         (),
    .rd_data_en                         (),
    .dest_id                            (),
    .device_id_set                      ()  
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// ad9516 config
//---------------------------------------------------------------------
ad9516_warpper  ad9516_warpper_inst (
    .sys_clk_i                          (clk_50m                   ),
    .hw_arst_n                          (hw_arst_n                 ),

    .ad9516_1_rst_n                     (ad9516_1_rst_n            ),
    .AD9516_1_RESET_B                   (AD9516_1_RESET_B          ),
    .AD9516_1_PD_B                      (AD9516_1_PD_B             ),
    .AD9516_1_SCLK                      (AD9516_1_SCLK             ),
    .AD9516_1_SDIO                      (AD9516_1_SDIO             ),
    .AD9516_1_SDO                       (AD9516_1_SDO              ),
    .AD9516_1_CS                        (AD9516_1_CS               ),
    .AD9516_1_STATUS                    (AD9516_1_STATUS           ),
    .AD9516_1_REFSEL                    (AD9516_1_REFSEL           ),

    .ad9516_2_rst_n                     (ad9516_2_rst_n            ),
    .AD9516_2_RESET_B                   (AD9516_2_RESET_B          ),
    .AD9516_2_PD_B                      (AD9516_2_PD_B             ),
    .AD9516_2_SCLK                      (AD9516_2_SCLK             ),
    .AD9516_2_SDIO                      (AD9516_2_SDIO             ),
    .AD9516_2_SDO                       (AD9516_2_SDO              ),
    .AD9516_2_CS                        (AD9516_2_CS               ),
    .AD9516_2_STATUS                    (AD9516_2_STATUS           ),
    .AD9516_2_REFSEL                    (AD9516_2_REFSEL           ) 
  );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// SRIO Application Top Level Wrapper
//---------------------------------------------------------------------
srio_4x_app_wrapper
    # (
        .SRIO_ONCE_LENGTH               (SRIO_ONCE_LENGTH),
        .SRIO_WR_DATA_WIDTH             (SRIO_WR_DATA_WIDTH),
        .SRIO_RD_DATA_WIDTH             (SRIO_RD_DATA_WIDTH),
        .SRIO_LINK_WIDTH                (SRIO_LINK_WIDTH)
    )
    u_srio_app
    (
        // Clock and Reset# Interface
        .srio_log_clk                   (srio_log_clk),
        .srio_log_rst                   (srio_log_rst),
        .srio_clk_lock                  (srio_clk_lock),
        .srio_core_rst                  (~hw_arst_n),
        .sys_reset_n                    (sw_arst_n),
        .fiber_sw_rst                   (fiber_sw_rst),
        .clk_50m                        (clk_50m),
        
        // GT loopback Ctrl    
        .loopback_sel                   (loopback_sel),
        
        // SRIO ID  
        .source_id                      (source_id),
        .dest_id                        (dest_id),
        .device_id                      (device_id),
        .device_id_set                  (device_id_set),
        .id_set_done                    (id_set_done),
        
        // Status Signals
        .port_initialized               (port_initialized),
        .link_initialized               (link_initialized),
        .mode_1x                        (mode_1x),
        
        // FIFO Interface for Packet Transmit
        .fifo_wrclk_pkt_tx              ({SRIO_CH_NUM{wr_test_clk}}),
        .fifo_wrreq_pkt_tx              (fifo_wrreq_pkt_tx),
        .fifo_data_pkt_tx               (fifo_data_pkt_tx),
        .fifo_prog_full_pkt_tx          (fifo_prog_full_pkt_tx),
        
        // FIFO Interface for Packet Receive
        .fifo_rdclk_pkt_rx              ({SRIO_CH_NUM{rd_test_clk}}),
        .fifo_rdreq_pkt_rx              (fifo_rdreq_pkt_rx),
        .fifo_q_pkt_rx                  (fifo_q_pkt_rx),
        .fifo_empty_pkt_rx              (fifo_empty_pkt_rx),
        .fifo_prog_empty_pkt_rx         (fifo_prog_empty_pkt_rx),
        
        // SRIO Interface
        .srio_refclkp                   (srio_refclkp_bp),
        .srio_refclkn                   (srio_refclkn_bp),
        .srio_rxp                       (srio_rxp_bp),
        .srio_rxn                       (srio_rxn_bp),
        .srio_txp                       (srio_txp_bp),
        .srio_txn                       (srio_txn_bp)
    );


//---------------------------------------------------------------------

//---------------------------------------------------------------------
IBUFDS #(
    .DIFF_TERM                          ("FALSE"                   ),// Differential Termination
    .IBUF_LOW_PWR                       ("TRUE"                    ),// Low power="TRUE", Highest performance="FALSE" 
    .IOSTANDARD                         ("DEFAULT"                 ) // Specify the input I/O standard
) IBUFDS_ddr3 (
    .O                                  (Z7_PL_DDR3_CLK            ),// Buffer output
    .I                                  (Z7_PL_DDR3_CLK_P          ),// Diff_p buffer input (connect directly to top-level port)
    .IB                                 (Z7_PL_DDR3_CLK_N          ) // Diff_n buffer input (connect directly to top-level port)
);

//IBUFDS_GTE2 #(
//    .CLKCM_CFG                          ("TRUE"                    ),// Refer to Transceiver User Guide
//    .CLKRCV_TRST                        ("TRUE"                    ),// Refer to Transceiver User Guide
//    .CLKSWING_CFG                       (2'b11                     ) // Refer to Transceiver User Guide
//) IBUFDS_GTE2_pcie (
//    .O                                  (SRIO_REFCLK13             ),// 1-bit output: Refer to Transceiver User Guide
//    .ODIV2                              (                          ),// 1-bit output: Refer to Transceiver User Guide
//    .CEB                                (1'b0                      ),// 1-bit input: Refer to Transceiver User Guide
//    .I                                  (SRIO_REFCLK13_P           ),// 1-bit input: Refer to Transceiver User Guide
//    .IB                                 (SRIO_REFCLK13_N           ) // 1-bit input: Refer to Transceiver User Guide
//);

axi_dma_data axi_dma_data_inst(
  .PL_CLK                               (FCLK_CLK0_0    ),
  .RESETn                               (RESETN         ),
  
  /************USER Interface**********************/
  // FIFO Interface for Packet Transmit
  .fifo_wrreq_pkt_tx                        (fifo_wrreq_pkt_tx    ),             // fifo write request
  .fifo_data_pkt_tx                         (fifo_data_pkt_tx     ),              // fifo write data
  .fifo_prog_full_pkt_tx                    (fifo_prog_full_pkt_tx),         // fifo program full
        
  // FIFO Interface for Packet Receive
  .fifo_rdreq_pkt_rx                        (fifo_rdreq_pkt_rx     ),             // fifo read request
  .fifo_q_pkt_rx                            (fifo_q_pkt_rx         ),                 // fifo write data
  .fifo_empty_pkt_rx                        (fifo_empty_pkt_rx     ),             // fifo empty
  .fifo_prog_empty_pkt_rx                   (fifo_prog_empty_pkt_rx),        // fifo program empty
  
  
  /***********AXI_Stream**************************/
  .M_AXIS_MM2S_0_tdata                  (M_AXIS_MM2S_0_tdata ),
  .M_AXIS_MM2S_0_tkeep                  (M_AXIS_MM2S_0_tkeep ),
  .M_AXIS_MM2S_0_tlast                  (M_AXIS_MM2S_0_tlast ),
  .M_AXIS_MM2S_0_tready                 (M_AXIS_MM2S_0_tready),
  .M_AXIS_MM2S_0_tvalid                 (M_AXIS_MM2S_0_tvalid),

  .S_AXIS_S2MM_0_tdata                  (S_AXIS_S2MM_0_tdata  ),
  .S_AXIS_S2MM_0_tkeep                  (S_AXIS_S2MM_0_tkeep  ),
  .S_AXIS_S2MM_0_tlast                  (S_AXIS_S2MM_0_tlast  ),
  .S_AXIS_S2MM_0_tready                 (S_AXIS_S2MM_0_tready ),
  .S_AXIS_S2MM_0_tvalid                 (S_AXIS_S2MM_0_tvalid ) 
    
    );

BD_Wrapper BD_Wrapper_inst
   (
    .RESETN                         (RESETN     ),
    .FCLK_CLK0_0                    (FCLK_CLK0_0),
    .o_gpio_en                      (w_ps2ps_gpio),
    .i_ps_read_test                 (vio_ps_read),
    .DDR_0_addr                     (DDR_0_addr           ),
    .DDR_0_ba                       (DDR_0_ba             ),
    .DDR_0_cas_n                    (DDR_0_cas_n          ),
    .DDR_0_ck_n                     (DDR_0_ck_n           ),
    .DDR_0_ck_p                     (DDR_0_ck_p           ),
    .DDR_0_cke                      (DDR_0_cke            ),
    .DDR_0_cs_n                     (DDR_0_cs_n           ),
    .DDR_0_dm                       (DDR_0_dm             ),
    .DDR_0_dq                       (DDR_0_dq             ),
    .DDR_0_dqs_n                    (DDR_0_dqs_n          ),
    .DDR_0_dqs_p                    (DDR_0_dqs_p          ),
    .DDR_0_odt                      (DDR_0_odt            ),
    .DDR_0_ras_n                    (DDR_0_ras_n          ),
    .DDR_0_reset_n                  (DDR_0_reset_n        ),
    .DDR_0_we_n                     (DDR_0_we_n           ),
    .FIXED_IO_0_ddr_vrn             (FIXED_IO_0_ddr_vrn   ),
    .FIXED_IO_0_ddr_vrp             (FIXED_IO_0_ddr_vrp   ),
    .FIXED_IO_0_mio                 (FIXED_IO_0_mio       ),
    .FIXED_IO_0_ps_clk              (FIXED_IO_0_ps_clk    ),
    .FIXED_IO_0_ps_porb             (FIXED_IO_0_ps_porb   ),
    .FIXED_IO_0_ps_srstb            (FIXED_IO_0_ps_srstb  ),
    
    .M_AXIS_MM2S_0_tdata            (M_AXIS_MM2S_0_tdata  ),
    .M_AXIS_MM2S_0_tkeep            (M_AXIS_MM2S_0_tkeep  ),
    .M_AXIS_MM2S_0_tlast            (M_AXIS_MM2S_0_tlast  ),
    .M_AXIS_MM2S_0_tready           (M_AXIS_MM2S_0_tready ),
    .M_AXIS_MM2S_0_tvalid           (M_AXIS_MM2S_0_tvalid ),
   
    .S_AXIS_S2MM_0_tdata            (S_AXIS_S2MM_0_tdata  ),
    .S_AXIS_S2MM_0_tkeep            (S_AXIS_S2MM_0_tkeep  ),
    .S_AXIS_S2MM_0_tlast            (S_AXIS_S2MM_0_tlast  ),
    .S_AXIS_S2MM_0_tready           (S_AXIS_S2MM_0_tready ),
    .S_AXIS_S2MM_0_tvalid           (S_AXIS_S2MM_0_tvalid )
    );
    
/***************************************/
`ifdef sim_dma
//wire [31:0]  vio_trans_lens     ;
 //---------------------------------------------------------------------
// SRIO test data Wrapper Top Level
//---------------------------------------------------------------------
generate
    begin : srio_test
        genvar  i;
        for (i = 0; i <= SRIO_CH_NUM - 1; i = i + 1)
            begin : ch
                data_test_wrapper 
                    # (
                        .WR_DATA_WIDTH                  (SRIO_WR_DATA_WIDTH),    
                        .RD_DATA_WIDTH                  (SRIO_RD_DATA_WIDTH)        
                    )
                    u_test 
                    (
                        // Clock and Reset# Interface
                        .log_clk                        (srio_log_clk), 
                        .log_rst_n                      (sw_arst_n), 
                                
                        // Status Signals
                        .link_up                        (port_initialized && link_initialized),
                        
                        // Data Path Ctrl
                        .wr_data_en                     (wr_data_en[i]),
                        .rd_data_en                     (rd_data_en[i]), 
                        .channel_flag                   (i+1),
            
                        //---------------------------------------------------------------------
                        // FIFO Interface for Upstream
                        .fifo_wrclk_us                  (wr_test_clk),
                        .fifo_wrreq_us                  (fifo_wrreq_pkt_tx[i]),
                        .fifo_data_us                   (fifo_data_pkt_tx[SRIO_WR_DATA_WIDTH*i +: SRIO_WR_DATA_WIDTH]),
                        .fifo_prog_full_us              (fifo_prog_full_pkt_tx[i]),
                            
                        //---------------------------------------------------------------------
                        // FIFO Interface for Downstream
                        .fifo_rdclk_ds                  (rd_test_clk),
                        .fifo_rdreq_ds                  (fifo_rdreq_pkt_rx[i]),
                        .fifo_q_ds                      (fifo_q_pkt_rx[SRIO_RD_DATA_WIDTH*i +: SRIO_RD_DATA_WIDTH]),
                        .fifo_empty_ds                  (fifo_empty_pkt_rx[i])
                    );
            end
    end
endgenerate
reg  [31:0]  vio_trans_lens_1d  ;
reg  [31:0]  vio_trans_lens_2d  ;
always @(posedge FCLK_CLK0_0,negedge RESETN)
begin
    if(!RESETN)begin
        vio_trans_lens_1d <= 'd0;
        vio_trans_lens_2d <= 'd0;
    end else begin
        vio_trans_lens_1d <= vio_trans_lens;
        vio_trans_lens_2d <= vio_trans_lens_1d;
    end
end 
 sim_data_fifo sim_data_fifo_inst(
  .P_TRANS_LENS         (vio_trans_lens_2d),
//  .P_TRANS_LENS         (1310720),
//  .data_cap_en          (r_data_cap_en_2d ),
 
  .AXI_CLk              (FCLK_CLK0_0),  
  .AXI_RSTN             (RESETN),  
  
  .S_AXIS_0_tdata      (S_AXIS_S2MM_0_tdata ),
  .S_AXIS_0_tkeep      (S_AXIS_S2MM_0_tkeep ),
  .S_AXIS_0_tlast      (S_AXIS_S2MM_0_tlast ),
  .S_AXIS_0_tready     (S_AXIS_S2MM_0_tready),
  .S_AXIS_0_tvalid     (S_AXIS_S2MM_0_tvalid)
    );
    
  sim_data_crc sim_data_crc_inst(
  .AXI_CLk                 (FCLK_CLK0_0),  
  .AXI_RSTN                (RESETN      ),  

  .M_AXIS_MM2S_0_tdata     (M_AXIS_MM2S_0_tdata ),
  .M_AXIS_MM2S_0_tkeep     (M_AXIS_MM2S_0_tkeep ),
  .M_AXIS_MM2S_0_tlast     (M_AXIS_MM2S_0_tlast ),
  .M_AXIS_MM2S_0_tready    (M_AXIS_MM2S_0_tready),
  .M_AXIS_MM2S_0_tvalid    (M_AXIS_MM2S_0_tvalid),
  
  .o_user_dout             (),
  .o_user_dout_valid       ()
);
`endif


wire [19:0]     freq_cnt;
freq_calc freq_calc_inst
    (
    .clk_50m        (clk_50m), 
    .rst_n          (hw_arst_n), 
    .calc_clk       (SRIO_REFCLK13), 
    .freq_cnt       (freq_cnt)
    );
ila_freq ila_freq_inst (
	.clk(clk_50m), // input wire clk


	.probe0(freq_cnt) // input wire [0:0] probe0
);

endmodule
