`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         ACQNOVA
// Engineer:       Long Lian
// 
// Create Date: 2022/10/13 19:14:09
// Design Name: 
// Module Name: ddr3_fifo_wrapper
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


module ddr3_fifo_wrapper
    # (
    parameter                           DDR_CHANNEL             =   4,
    parameter                           WR_DATA_WIDTH           =   256,
    parameter                           RD_DATA_WIDTH           =   256,
    parameter                           DDR_DATA_WIDTH          =   512 
    )

    (
        // Clock and Reset# Interface
    input                               ddr3_core_reset_n          ,// DDR3 Core Reset#, Active low
    input                               ddr3_log_reset_n           ,// DDR3 Logic Reset, Active low
    output                              ddr3_ui_clk                ,// This UI clock must be quarter of the DRAM clock
    output                              ddr3_plllkdet              ,// This active-High PLL frequency lock signal indicates that the PLL frequency is within predetermined tolerance
        
        // DDR3 SDRAM Controller Calibration Status
    output                              phy_init_done              ,// PHY asserts dfi_init_complete when calibration is finished
    input              [  11:0]         device_temp_i              ,
        
        // DMA Transfer Length
    input              [  31:0]         dma_xfer_len               ,// DMA Transfer Length
    output             [DDR_CHANNEL-1:0]ddr3_data_rdy              ,// indicate that DMA Transmit Data Quantity >= dma_xfer_len       
    output             [DDR_CHANNEL*32-1:0]ddr3_data_usedw            ,

        //---------------------------------------------------------------------   
        // FIFO Interface for DDR3 SDRAM Upstream
    input              [DDR_CHANNEL-1:0]fifo_wrclk_ddr3_us         ,// fifo write clock
    input              [DDR_CHANNEL-1:0]fifo_wrreq_ddr3_us         ,// fifo write request
    input              [DDR_CHANNEL*WR_DATA_WIDTH-1:0]fifo_data_ddr3_us          ,// fifo write data
    output             [DDR_CHANNEL-1:0]fifo_prog_full_ddr3_us     ,// fifo program full     

        //---------------------------------------------------------------------   
        // FIFO Interface for DDR3 SDRAM Downstream
    input              [DDR_CHANNEL-1:0]fifo_rdclk_ddr3_ds         ,// fifo read clock
    input              [DDR_CHANNEL-1:0]fifo_rdreq_ddr3_ds         ,// fifo read request
    output             [DDR_CHANNEL*RD_DATA_WIDTH-1:0]fifo_q_ddr3_ds             ,// fifo read data
    output             [DDR_CHANNEL-1:0]fifo_empty_ddr3_ds         ,// fifo empty     
        
        //---------------------------------------------------------------------                 
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
    output             [   7:0]         ddr3_dm                     // Input data mask             
    );
    

//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
wire                                    ui_clk_sync_rst            ;
    // DDR3 SDRAM User Interface 
    // Address/Command
wire                                    app_en                     ;// This is the active-High strobe for the app_addr[] and app_cmd[2:0] inputs
wire                   [   2:0]         app_cmd                    ;// This input selects the command for the current request
wire                   [  27:0]         app_addr                   ;// This input indicates the address for the current request
wire                                    app_rdy                    ;// This output indicates that the UI is ready to accept commands
    
    // Write Data FIFO
wire                                    app_wdf_wren               ;// This is the active-High strobe for app_wdf_data[]
wire                   [DDR_DATA_WIDTH-1:0]app_wdf_data               ;// This provides the data for write commands
wire                   [  63:0]         app_wdf_mask               ;// This provides the mask for app_wdf_data[]
wire                                    app_wdf_end                ;// This active-High input indicates that the current clock cycle is the last cycle of input data on app_wdf_data[]
wire                                    app_wdf_rdy                ;// This output indicates that the write data FIFO is ready to receive data
    
    // Read Data FIFO
wire                                    app_rd_data_valid          ;// This active-High output indicates that app_rd_data[] is valid
wire                   [DDR_DATA_WIDTH-1:0]app_rd_data                ;// This provides the output data from read commands
wire                                    app_rd_data_end            ;// This active-High output indicates that the current clock cycle is the last cycle of outputdata on app_rd_data[]
     

//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------


// ********************************************************************************** // 
//---------------------------------------------------------------------
// Assign
//---------------------------------------------------------------------   
assign          ddr3_plllkdet       =   !ui_clk_sync_rst;


// ********************************************************************************** // 
//---------------------------------------------------------------------
// DDR3 SDRAM FIFO CTRL Level
//---------------------------------------------------------------------
ddr3_2g_4ch_ctrl
    # (
    .DDR_CHANNEL                       (DDR_CHANNEL               ),
    .WR_DATA_WIDTH                     (WR_DATA_WIDTH             ),
    .RD_DATA_WIDTH                     (RD_DATA_WIDTH             ),
    .DDR_DATA_WIDTH                    (DDR_DATA_WIDTH            ) 
    )
    
    ddr3_ctrl
    (
        // System Clock and Reset# Interface
    .ddr3_ui_clk                       (ddr3_ui_clk               ),// This UI clock must be quarter of the DRAM clock
    .ddr3_log_reset_n                  (ddr3_log_reset_n          ),// DDR3 Logic Reset, Active low

        // DDR3 SDRAM Controller Calibration Status
    .phy_init_done                     (phy_init_done             ),// PHY asserts dfi_init_complete when calibration is finished
        
        // DMA Transfer Length
    .dma_xfer_len                      (dma_xfer_len              ),
    .ddr3_data_rdy                     (ddr3_data_rdy             ),
    .ddr3_data_usedw                   (ddr3_data_usedw           ),
        
        //---------------------------------------------------------------------
        // FIFO Interface for DDR3 SDRAM Upstream
    .fifo_wrclk_ddr3_us                (fifo_wrclk_ddr3_us        ),// fifo write clock
    .fifo_wrreq_ddr3_us                (fifo_wrreq_ddr3_us        ),// fifo write request
    .fifo_data_ddr3_us                 (fifo_data_ddr3_us         ),// fifo write data
    .fifo_prog_full_ddr3_us            (fifo_prog_full_ddr3_us    ),// fifo program full 

        // DDR3 SDRAM User Interface
        // Address/Command         
    .app_en                            (app_en                    ),
    .app_cmd                           (app_cmd                   ),
    .app_addr                          (app_addr                  ),
    .app_rdy                           (app_rdy                   ),
        // Write Data FIFO 
    .app_wdf_wren                      (app_wdf_wren              ),
    .app_wdf_data                      (app_wdf_data              ),
    .app_wdf_mask                      (app_wdf_mask              ),
    .app_wdf_end                       (app_wdf_end               ),
    .app_wdf_rdy                       (app_wdf_rdy               ),
        // Read Data FIFO
    .app_rd_data_valid                 (app_rd_data_valid         ),
    .app_rd_data                       (app_rd_data               ),
    .app_rd_data_end                   (app_rd_data_end           ),
                    
        //---------------------------------------------------------------------
        // FIFO Interface for DDR3 SDRAM Downstream
    .fifo_rdclk_ddr3_ds                (fifo_rdclk_ddr3_ds        ),// fifo read clock
    .fifo_rdreq_ddr3_ds                (fifo_rdreq_ddr3_ds        ),// fifo read request
    .fifo_q_ddr3_ds                    (fifo_q_ddr3_ds            ),// fifo read data
    .fifo_empty_ddr3_ds                (fifo_empty_ddr3_ds        ) // fifo empty
    );


// ********************************************************************************** // 
//---------------------------------------------------------------------
// DDR3 SDRAM Controller Top-level    
//---------------------------------------------------------------------
ddr3_sdram
    ddr3_ip
    (
        // Memory interface ports
    .ddr3_addr                         (ddr3_addr                 ),// output [14:0]        ddr3_addr
    .ddr3_ba                           (ddr3_ba                   ),// output [2:0]         ddr3_ba
    .ddr3_cas_n                        (ddr3_cas_n                ),// output               ddr3_cas_n
    .ddr3_ck_n                         (ddr3_ck_n                 ),// output [0:0]         ddr3_ck_n
    .ddr3_ck_p                         (ddr3_ck_p                 ),// output [0:0]         ddr3_ck_p
    .ddr3_cke                          (ddr3_cke                  ),// output [0:0]         ddr3_cke
    .ddr3_ras_n                        (ddr3_ras_n                ),// output               ddr3_ras_n
    .ddr3_reset_n                      (ddr3_reset_n              ),// output               ddr3_reset_n
    .ddr3_we_n                         (ddr3_we_n                 ),// output               ddr3_we_n
    .ddr3_dq                           (ddr3_dq                   ),// inout [63:0]         ddr3_dq
    .ddr3_dqs_n                        (ddr3_dqs_n                ),// inout [7:0]          ddr3_dqs_n
    .ddr3_dqs_p                        (ddr3_dqs_p                ),// inout [7:0]          ddr3_dqs_p
    .init_calib_complete               (phy_init_done             ),// output               init_calib_complete
        
    .ddr3_cs_n                         (ddr3_cs_n                 ),// output [0:0]         ddr3_cs_n
    .ddr3_dm                           (ddr3_dm                   ),// output [7:0]         ddr3_dm
    .ddr3_odt                          (ddr3_odt                  ),// output [0:0]         ddr3_odt
        // Application interface ports
    .app_addr                          ({1'b0, app_addr}          ),// input [28:0]         app_addr
    .app_cmd                           (app_cmd                   ),// input [2:0]          app_cmd
    .app_en                            (app_en                    ),// input                app_en
    .app_wdf_data                      (app_wdf_data              ),// input [511:0]        app_wdf_data
    .app_wdf_end                       (app_wdf_end               ),// input                app_wdf_end
    .app_wdf_wren                      (app_wdf_wren              ),// input                app_wdf_wren
    .app_rd_data                       (app_rd_data               ),// output [511:0]       app_rd_data
    .app_rd_data_end                   (app_rd_data_end           ),// output               app_rd_data_end
    .app_rd_data_valid                 (app_rd_data_valid         ),// output               app_rd_data_valid
    .app_rdy                           (app_rdy                   ),// output               app_rdy
    .app_wdf_rdy                       (app_wdf_rdy               ),// output               app_wdf_rdy
    .app_sr_req                        (1'b0                      ),// input                app_sr_req
    .app_ref_req                       (1'b0                      ),// input                app_ref_req
    .app_zq_req                        (1'b0                      ),// input                app_zq_req
    .app_sr_active                     (                          ),// output               app_sr_active
    .app_ref_ack                       (                          ),// output               app_ref_ack
    .app_zq_ack                        (                          ),// output               app_zq_ack
    .ui_clk                            (ddr3_ui_clk               ),// output               ui_clk
    .ui_clk_sync_rst                   (ui_clk_sync_rst           ),// output               ui_clk_sync_rst
    .app_wdf_mask                      (app_wdf_mask              ),// input [63:0]         app_wdf_mask
        // System Clock Ports
    .sys_clk_p                         (ddr3_sys_clk_p            ),// input                sys_clk_p
    .sys_clk_n                         (ddr3_sys_clk_n            ),// input                sys_clk_n
    .device_temp_i                     (device_temp_i             ),// input [11:0]         device_temp_i
    .sys_rst                           (ddr3_core_reset_n         ) // input                sys_rst
    );


// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//---------------------------------------------------------------------       
ila_ddr3_sta
    u_ila_ddr3_sta
    (
    .clk                               (ddr3_ui_clk               ),// input wire clk
    .probe0                            (phy_init_done             ),// input wire [0:0]  probe0 
    .probe1                            (ddr3_data_rdy             ),// input wire [3:0]  probe1
    .probe2                            (ddr3_data_usedw[32*0 +: 32]),// input wire [31:0]  probe2
    .probe3                            (ddr3_data_usedw[32*1 +: 32]),// input wire [31:0]  probe3
    .probe4                            (ddr3_data_usedw[32*2 +: 32]),// input wire [31:0]  probe4
    .probe5                            (ddr3_data_usedw[32*3 +: 32]) // input wire [31:0]  probe5
    );

    
endmodule
