`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     ACQNOVA
// Engineer:    Long Lian
// 
// Create Date: 2020/06/15 16:41:13
// Design Name: 
// Module Name: srio_multi_4x_app_wrapper
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


module srio_multi_4x_app_wrapper
    # (
        parameter       SRIO_CH_NUM             =   8,
        parameter       SRIO_GT_CLOCK_NUM       =   8,
        parameter       SRIO_ONCE_LENGTH        =   8,
        parameter       SRIO_WR_DATA_WIDTH      =   128, 
        parameter       SRIO_RD_DATA_WIDTH      =   128,
        parameter       SRIO_LINK_WIDTH         =   4                           // 1- X1; 2 - X2; 4 - X4; 8 - X8   
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
    wire        [SRIO_GT_CLOCK_NUM-1:0]         log_clk_out   ;                 // LOG interface clock

    
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


// ********************************************************************************** // 
//---------------------------------------------------------------------
// Input Register
//---------------------------------------------------------------------


generate
    begin
        genvar	i;
        for (i = 0; i < SRIO_CH_NUM; i = i + 1)
        begin:gen_srio_4x
            always@(posedge clk_50m)begin
                srio_core_rst_r1[i] <= srio_core_rst[i];
                srio_core_rst_r2[i] <= ~ srio_core_rst_r1[i];
            end
            
            srio_4x_app_wrapper
                # (
                    .SRIO_ONCE_LENGTH               (SRIO_ONCE_LENGTH),
                    .SRIO_WR_DATA_WIDTH             (SRIO_WR_DATA_WIDTH),
                    .SRIO_RD_DATA_WIDTH             (SRIO_RD_DATA_WIDTH),
                    .SRIO_LINK_WIDTH                (SRIO_LINK_WIDTH)
                )
                u_srio_4x
                (
                    // Clock and Reset# Interface
                    .srio_log_clk                   (log_clk_out[i]),
                    .srio_log_rst                   (srio_log_rst[i]),
                    .srio_clk_lock                  (srio_clk_lock[i]),
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
                    .srio_refclkp                   (srio_refclkp   [i]),
                    .srio_refclkn                   (srio_refclkn   [i]),
                    .srio_rxp                       (srio_rxp[SRIO_LINK_WIDTH*i +: SRIO_LINK_WIDTH]),
                    .srio_rxn                       (srio_rxn[SRIO_LINK_WIDTH*i +: SRIO_LINK_WIDTH]),
                    .srio_txp                       (srio_txp[SRIO_LINK_WIDTH*i +: SRIO_LINK_WIDTH]),
                    .srio_txn                       (srio_txn[SRIO_LINK_WIDTH*i +: SRIO_LINK_WIDTH])
                );
        end
    end
endgenerate


// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//--------------------------------------------------------------------- 


endmodule
