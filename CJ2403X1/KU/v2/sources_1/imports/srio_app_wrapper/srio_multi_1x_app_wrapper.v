`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     ACQNOVA
// Engineer:    Long Lian
// 
// Create Date: 2020/06/15 16:41:13
// Design Name: 
// Module Name: srio_multi_1x_app_wrapper
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


module srio_multi_1x_app_wrapper
    # (
        parameter       SRIO_CH_NUM             =   12,
        parameter       SRIO_GT_CLOCK_NUM       =   3,
        parameter       SRIO_ONCE_LENGTH        =   8,
        parameter       SRIO_WR_DATA_WIDTH      =   128, 
        parameter       SRIO_RD_DATA_WIDTH      =   128,
        parameter       SRIO_LINK_WIDTH         =   1                           // 1- X1; 2 - X2; 4 - X4; 8 - X8   
    )
    
    (
        // Clock and Reset# Interface
        output                                  srio_log_clk,                   // Clock for Logical Layer, Rising Edge
        output      [SRIO_CH_NUM-1:0]           srio_log_rst,                   // Reset for Logical Layer, High Active
        output      [SRIO_CH_NUM-1:0]           srio_clk_lock,                  // Indicates the clocks are valid
        input       [SRIO_CH_NUM-1:0]           srio_core_rst,                  // SRIO Core global reset signal
        input       [SRIO_CH_NUM-1:0]           fiber_sw_rst,
        input                                   clk_50m,
        input       [SRIO_CH_NUM-1:0]           sys_reset_n,                    // System Reset, Low Active
        
        // GT Loopback Ctrl    
        input       [SRIO_CH_NUM-1:0]           loopback_sel,                   // "0" 不回环;"1"内回环;
        
        // SRIO ID  
        output      [SRIO_CH_NUM*16-1:0]        source_id,
        input       [SRIO_CH_NUM*16-1:0]        dest_id,
        output      [SRIO_CH_NUM*16-1:0]        device_id,
        input       [SRIO_CH_NUM*16-1:0]        device_id_set,
        output      [SRIO_CH_NUM-1:0]           id_set_done,  
        
        // Status Signals
        output      [SRIO_CH_NUM-1:0]           port_initialized,               // Link has locked to receive stream
        output      [SRIO_CH_NUM-1:0]           link_initialized,               // The core is fully trained and can now transmit data
        output      [SRIO_CH_NUM-1:0]           mode_1x,                        // For a 2x or 4x core, signal indicates that the core has trained down to one lane

        // FIFO Interface for Packet Transmit
        input       [SRIO_CH_NUM-1:0]           fifo_wrclk_pkt_tx,              // Write Clock
        input       [SRIO_CH_NUM-1:0]           fifo_wrreq_pkt_tx,              // fifo write request
        input       [SRIO_CH_NUM*SRIO_WR_DATA_WIDTH-1:0]    fifo_data_pkt_tx,   // fifo write data
        output      [SRIO_CH_NUM-1:0]           fifo_prog_full_pkt_tx,          // fifo program full
        
        // FIFO Interface for Packet Receive
        input       [SRIO_CH_NUM-1:0]           fifo_rdclk_pkt_rx,              // Read Clock
        input       [SRIO_CH_NUM-1:0]           fifo_rdreq_pkt_rx,              // fifo read request
        output      [SRIO_CH_NUM*SRIO_RD_DATA_WIDTH-1:0]    fifo_q_pkt_rx,      // fifo write data
        output      [SRIO_CH_NUM-1:0]           fifo_empty_pkt_rx,              // fifo empty
        output      [SRIO_CH_NUM-1:0]           fifo_prog_empty_pkt_rx,         // fifo program empty
        
        // SRIO Interface
        input       [SRIO_GT_CLOCK_NUM-1:0]     srio_refclkp,                   // 125MHz differential clock
        input       [SRIO_GT_CLOCK_NUM-1:0]     srio_refclkn,                   // 125MHz differential clock
        input       [SRIO_CH_NUM*SRIO_LINK_WIDTH-1:0]   srio_rxp,               // Serial Receive Data +
        input       [SRIO_CH_NUM*SRIO_LINK_WIDTH-1:0]   srio_rxn,               // Serial Receive Data -
        output      [SRIO_CH_NUM*SRIO_LINK_WIDTH-1:0]   srio_txp,               // Serial Transmit Data +
        output      [SRIO_CH_NUM*SRIO_LINK_WIDTH-1:0]   srio_txn                // Serial Transmit Data -      
    );


//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
    wire        [SRIO_GT_CLOCK_NUM-1:0]     log_clk_out   ;                 // LOG interface clock
    wire        [SRIO_GT_CLOCK_NUM-1:0]     phy_clk_out   ;                 // PHY interface clock
    wire        [SRIO_GT_CLOCK_NUM-1:0]     gt_clk_out    ;
    wire        [SRIO_GT_CLOCK_NUM-1:0]     gt_pcs_clk_out;                 // GT fabric interface clock
    wire        [SRIO_GT_CLOCK_NUM-1:0]     drpclk_out    ;
    wire        [SRIO_GT_CLOCK_NUM-1:0]     refclk_out    ;
    wire        [SRIO_GT_CLOCK_NUM-1:0]     clk_lock  ;
    wire        [SRIO_GT_CLOCK_NUM-1:0]     freerun_clk_out  ;
    wire        [SRIO_GT_CLOCK_NUM-1:0]     gtpowergood_in  ;
    wire        [SRIO_CH_NUM-1:0]           log_clk_in    ;                 // LOG interface clock
    wire        [SRIO_CH_NUM-1:0]           phy_clk_in    ;                 // PHY interface clock
    wire        [SRIO_CH_NUM-1:0]           gt_clk_in     ;
    wire        [SRIO_CH_NUM-1:0]           gt_pcs_clk_in ;                 // GT fabric interface clock
    wire        [SRIO_CH_NUM-1:0]           drpclk_in     ;
    wire        [SRIO_CH_NUM-1:0]           refclk_in     ;
    wire        [SRIO_CH_NUM-1:0]           clk_lock_in   ;
    wire        [SRIO_CH_NUM-1:0]           clk_lock_out   ;
    wire        [SRIO_CH_NUM-1:0]           freerun_clk_in ;
    wire        [SRIO_CH_NUM-1:0]           log_rst_out    ;
    wire        [SRIO_CH_NUM-1:0]           phy_rst_out    ;
    wire        [SRIO_CH_NUM-1:0]           buf_rst_out    ;
    wire        [SRIO_CH_NUM-1:0]           cfg_rst_out    ;
    wire        [SRIO_CH_NUM-1:0]           gt_pcs_rst_out ;
    wire        [SRIO_CH_NUM-1:0]           gtpowergood_out ;
    wire        [SRIO_CH_NUM-1:0]           txoutclk_out ;
    
    
//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
(*ASYNC_REG = "true"*)
    reg                [SRIO_CH_NUM-1: 0]srio_core_rst_r1          ;
(*ASYNC_REG = "true"*)
    reg                [SRIO_CH_NUM-1: 0]srio_core_rst_r2          ;

//---------------------------------------------------------------------  
// Parameter
//---------------------------------------------------------------------  

    
// ********************************************************************************** // 
//---------------------------------------------------------------------
// I/O Connections assignments
//---------------------------------------------------------------------
assign      srio_log_clk        =   log_clk_out[0];
assign      srio_log_rst        =   log_rst_out;
assign      srio_clk_lock       =   clk_lock_out;


// ********************************************************************************** // 
//---------------------------------------------------------------------
// Input Register
//---------------------------------------------------------------------


//----------------------------------------------------------------------------//
// SRIO_CLK Instantiaton --------------------
generate
    begin
        genvar	i;
        for (i = 0; i < SRIO_GT_CLOCK_NUM; i = i + 1)
        begin:gen_srio_clk
            always@(posedge clk_50m)begin
                srio_core_rst_r1[i] <= srio_core_rst[i];
                srio_core_rst_r2[i] <= ~ srio_core_rst_r1[i];
            end

            srio_gen2_x1_srio_clk
                u_srio_clk
                (
                    // Clock in ports
                    .sys_clkp                       (srio_refclkp[i] ),// input to the clock module
                    .sys_clkn                       (srio_refclkn[i] ),// input to the clock module
                    
                    // Status and control signals
                    .sys_rst                        (srio_core_rst_r2[0]),// input to the clock module
                    .mode_1x                        (mode_1x[4*i]),// input to the clock module
                    
                    .gt_txpmaresetdone              (),// input to the clock module 
                    .txoutclk                       (txoutclk_out[4*i]       ), // GT Clock
                    .gtpowergood_out                (gtpowergood_in[i] ), // GT Clock
                    .freerun_clk                    (freerun_clk_out[i]   ), // GT freerun clock 
                    
                    // Clock out ports
                    .log_clk                        (log_clk_out[i]     ),// output from clock module
                    .phy_clk                        (phy_clk_out[i]     ),// output from clock module
                    .gt_clk                         (gt_clk_out[i]      ),// output from clock module
                    .gt_pcs_clk                     (gt_pcs_clk_out[i]  ),// output from clock module
                    .refclk                         (refclk_out[i]      ),// output from clock module
//                    .drpclk                         (drpclk_out[i]      ),// output from clock module
                    
                    // Status and control signals
                    .clk_lock                       (clk_lock[i]    ) // output from clock module
                );
                
            assign      log_clk_in    [4*i +: 4]    =   {4{log_clk_out   [i]}};
            assign      phy_clk_in    [4*i +: 4]    =   {4{phy_clk_out   [i]}};
            assign      gt_clk_in     [4*i +: 4]    =   {4{gt_clk_out    [i]}};
            assign      gt_pcs_clk_in [4*i +: 4]    =   {4{gt_pcs_clk_out[i]}};
//            assign      drpclk_in     [4*i +: 4]    =   {4{drpclk_out    [i]}};
            assign      refclk_in     [4*i +: 4]    =   {4{refclk_out    [i]}};
            assign      clk_lock_in   [4*i +: 4]    =   {4{clk_lock      [i]}};
            assign      freerun_clk_in[4*i +: 4]    =   {4{freerun_clk_out      [i]}};
            assign      gtpowergood_in[i]           =   |gtpowergood_out[4*i +: 4];

        end
    end
endgenerate
// End of SRIO_CLK instantiation ------------
//----------------------------------------------------------------------------//


generate
    begin
        genvar	i;
        for (i = 0; i < SRIO_CH_NUM; i = i + 1)
        begin:gen_srio_1x
            srio_1x_wrapper
                # (
                    .SRIO_ONCE_LENGTH               (SRIO_ONCE_LENGTH),
                    .SRIO_WR_DATA_WIDTH             (SRIO_WR_DATA_WIDTH),
                    .SRIO_RD_DATA_WIDTH             (SRIO_RD_DATA_WIDTH),
                    .SRIO_LINK_WIDTH                (SRIO_LINK_WIDTH)
                )
                u_srio_1x
                (
                    // Clock and Reset# Interface
                    .log_clk_in                     (log_clk_in             [i]  ),
                    .phy_clk_in                     (phy_clk_in             [i]  ),
                    .gt_clk_in                      (gt_clk_in              [i]  ),
                    .gt_pcs_clk_in                  (gt_pcs_clk_in          [i]  ),   
//                    .drpclk_in                      (drpclk_in              [i]  ),
                    .refclk_in                      (refclk_in              [i]  ),
                    .clk_lock_in                    (clk_lock_in            [i]  ),
//                    .gt0_qpll_clk_in                (gt_qpll_clk_in         [i]  ),
//                    .gt0_qpll_out_refclk_in         (gt_qpll_out_refclk_in  [i]  ),
                    .freerun_clk                    (freerun_clk_in  [i]  ),
                    .txoutclk                       (txoutclk_out  [i]  ),
                    .clk_lock_out                   (clk_lock_out  [i]  ),
                    .log_rst_out                    (log_rst_out[i]        ),
                    .phy_rst_out                    (phy_rst_out[i]        ),
                    .buf_rst_out                    (buf_rst_out[i]        ),
                    .cfg_rst_out                    (cfg_rst_out[i]        ),
                    .gt_pcs_rst_out                 (gt_pcs_rst_out[i]     ),
                    .gtpowergood_out                (gtpowergood_out[i]     ),
                    .srio_core_rst                  (srio_core_rst_r2[i]),
                    .fiber_sw_rst                   (fiber_sw_rst[i]),
                    .clk_50m                        (clk_50m),
                    .sys_reset_n                    (sys_reset_n[i]),
                    
                     // GT Loopback Ctrl    
                    .loopback_sel                   (loopback_sel[i]),
            
                    // SRIO ID  
                    .source_id                      (source_id[16*i +: 16]      ),
                    .dest_id                        (dest_id[16*i +: 16]        ),
                    .device_id                      (device_id[16*i +: 16]),
                    .device_id_set                  (device_id_set[16*i +: 16]),
                    .id_set_done                    (id_set_done[i]),
                            
                    // Status Signals
                    .port_initialized               (port_initialized[i]),
                    .link_initialized               (link_initialized[i]),
                    .mode_1x                        (mode_1x[i]),
                    
                    // FIFO Interface for Packet Transmit
                    .fifo_wrclk_pkt_tx              (fifo_wrclk_pkt_tx[i]),
                    .fifo_wrreq_pkt_tx              (fifo_wrreq_pkt_tx[i]),
                    .fifo_data_pkt_tx               (fifo_data_pkt_tx[SRIO_WR_DATA_WIDTH*i +: SRIO_WR_DATA_WIDTH]),
                    .fifo_prog_full_pkt_tx          (fifo_prog_full_pkt_tx[i]),
                    
                    // FIFO Interface for Packet Receive
                    .fifo_rdclk_pkt_rx              (fifo_rdclk_pkt_rx[i]),
                    .fifo_rdreq_pkt_rx              (fifo_rdreq_pkt_rx[i]),
                    .fifo_q_pkt_rx                  (fifo_q_pkt_rx[SRIO_RD_DATA_WIDTH*i +: SRIO_RD_DATA_WIDTH]),
                    .fifo_empty_pkt_rx              (fifo_empty_pkt_rx[i]),
                    .fifo_prog_empty_pkt_rx         (fifo_prog_empty_pkt_rx[i]),
                    
                    // SRIO Interface
                    .srio_rxp                       (srio_rxp[i]),
                    .srio_rxn                       (srio_rxn[i]),
                    .srio_txp                       (srio_txp[i]),
                    .srio_txn                       (srio_txn[i])
                );
        end
    end
endgenerate


// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//--------------------------------------------------------------------- 


endmodule
