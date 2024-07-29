`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         ACQNOVA
// Engineer:       Long Lian
// 
// Create Date: 2023/04/16 23:45:55
// Design Name: 
// Module Name: ddr3_2g_4ch_ctrl
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


module ddr3_2g_4ch_ctrl
    # (
        parameter       DDR_CHANNEL             =   4,  
        parameter       WR_DATA_WIDTH           =   256, 
        parameter       RD_DATA_WIDTH           =   256, 
        parameter       DDR_DATA_WIDTH          =   512
    )
    
    (
        // Clock and Reset# Interface       
        input                                   ddr3_ui_clk,                // This UI clock must be quarter of the DRAM clock     
        input                                   ddr3_log_reset_n,           // DDR3 Logic Reset, Active low
        
        // DDR3 SDRAM Controller Calibration Status
        input                                   phy_init_done,              // PHY asserts dfi_init_complete when calibration is finished
        
        // DMA Transfer Length
        input       [31:0]                      dma_xfer_len,               // DMA Transfer Length
        output      [DDR_CHANNEL-1:0]           ddr3_data_rdy,              // indicate that DMA Transmit Data Quantity >= dma_xfer_len       
        output      [DDR_CHANNEL*32-1:0]        ddr3_data_usedw,

        //---------------------------------------------------------------------   
        // FIFO Interface for DDR3 SDRAM Upstream
        input       [DDR_CHANNEL-1:0]           fifo_wrclk_ddr3_us,         // fifo write clock
        input       [DDR_CHANNEL-1:0]           fifo_wrreq_ddr3_us,         // fifo write request
        input       [DDR_CHANNEL*WR_DATA_WIDTH-1:0]     fifo_data_ddr3_us,  // fifo write data
        output      [DDR_CHANNEL-1:0]           fifo_prog_full_ddr3_us,     // fifo program full     
                
        // DDR3 SDRAM User Interface for Xilinx
        // Address/Command        
        output                                  app_en,                    // This is the active-High strobe for the app_addr[] and app_cmd[2:0] inputs
        output      [2:0]                       app_cmd,                   // This input selects the command for the current request
        output      [27:0]                      app_addr,                  // This input indicates the address for the current request
        input                                   app_rdy,                   // This output indicates that the UI is ready to accept commands
        
        // Write Data FIFO
        output                                  app_wdf_wren,              // This is the active-High strobe for app_wdf_data[]
        output      [DDR_DATA_WIDTH-1:0]        app_wdf_data,              // This provides the data for write commands
        output      [DDR_DATA_WIDTH/8-1:0]      app_wdf_mask,              // This provides the mask for app_wdf_data[]
        output                                  app_wdf_end,               // This active-High input indicates that the current clock cycle is the last cycle of input data on app_wdf_data[]
        input                                   app_wdf_rdy,               // This output indicates that the write data FIFO is ready to receive data
        
        // Read Data FIFO
        input                                   app_rd_data_valid,         // This active-High output indicates that app_rd_data[] is valid
        input       [DDR_DATA_WIDTH-1:0]        app_rd_data,               // This provides the output data from read commands
        input                                   app_rd_data_end,           // This active-High output indicates that the current clock cycle is the last cycle of outputdata on app_rd_data[]
        
        //---------------------------------------------------------------------   
        // FIFO Interface for DDR3 SDRAM Downstream
        input       [DDR_CHANNEL-1:0]           fifo_rdclk_ddr3_ds,         // fifo read clock
        input       [DDR_CHANNEL-1:0]           fifo_rdreq_ddr3_ds,         // fifo read request
        output      [DDR_CHANNEL*RD_DATA_WIDTH-1:0]     fifo_q_ddr3_ds,     // fifo read data
        output      [DDR_CHANNEL-1:0]           fifo_empty_ddr3_ds          // fifo empty        
    );


//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
    wire                                    sys_rst_n;
    wire        [DDR_CHANNEL*28-1:0]        ddr3_fifo_usedw;
    // FIFO Interface for DDR3 SDRAM Upstream
    wire        [DDR_CHANNEL-1:0]           fifo_rdreq_ddr3_us;
    wire        [DDR_CHANNEL*DDR_DATA_WIDTH-1:0]    fifo_q_ddr3_us;
    wire        [DDR_CHANNEL-1:0]           fifo_prog_empty_ddr3_us;
    // FIFO Interface for DDR3 SDRAM Downstream
    wire        [DDR_CHANNEL-1:0]           fifo_wrreq_ddr3_ds;
    wire        [DDR_CHANNEL*DDR_DATA_WIDTH-1:0]    fifo_data_ddr3_ds;
    wire        [DDR_CHANNEL-1:0]           fifo_prog_full_ddr3_ds;
    wire        [9:0]                       fifo_wrusedw_ddr3_ds        [DDR_CHANNEL-1:0];


//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
    reg                                     ddr3_log_reset_n_r      =   1'b0;
    reg                                     ddr3_log_reset_n_r2     =   1'b0;
    reg         [31:0]                      dma_xfer_len_r          =   32'd0;
    reg         [31:0]                      dma_xfer_len_r2         =   32'd0;
    reg         [DDR_CHANNEL-1:0]           ddr3_data_rdy_r         =   {DDR_CHANNEL{1'b0}};
    reg         [31:0]                      ddr3_data_usedw_r           [DDR_CHANNEL-1:0];


// ********************************************************************************** // 
//---------------------------------------------------------------------
// I/O Connections assignments
//---------------------------------------------------------------------   
assign          sys_rst_n   =   ddr3_log_reset_n_r2;


always@(posedge ddr3_ui_clk)
    begin
        ddr3_log_reset_n_r  <=  ddr3_log_reset_n;
        ddr3_log_reset_n_r2 <=  ddr3_log_reset_n_r;
    end
    

// ********************************************************************************** // 
//---------------------------------------------------------------------
// DMA Transfer Length 
//---------------------------------------------------------------------
always@(posedge ddr3_ui_clk)
    begin
        dma_xfer_len_r  <=  dma_xfer_len;
        if(dma_xfer_len_r == 0)begin
            dma_xfer_len_r2 <=  32'h0000_4000;      //  16MB         32'h0010_0000 >> 6  
        end else begin
            dma_xfer_len_r2 <=  dma_xfer_len_r >> 6;
        end
    end


// ********************************************************************************** // 
//---------------------------------------------------------------------
// DDR3 SDRAM Upstream and Downstream Buffer
//---------------------------------------------------------------------
generate
    begin : ddr3_ctrl
        genvar  i;
        for (i = 0; i <= DDR_CHANNEL - 1; i = i + 1)
            begin : ch
                // DDR3 Data Quantity 
                assign  ddr3_data_usedw[32*i +: 32] =   ddr3_data_usedw_r[i];
                
                always@(posedge ddr3_ui_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            ddr3_data_usedw_r[i]    <=  32'd0;
                        end else begin
                            ddr3_data_usedw_r[i]    <=  ddr3_fifo_usedw[28*i +: 28] + fifo_wrusedw_ddr3_ds[i];
                        end
                    end
                
                assign  ddr3_data_rdy[i]    =   ddr3_data_rdy_r[i];
                always@(posedge ddr3_ui_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            ddr3_data_rdy_r[i]  <=  1'b0;
                        end else if(ddr3_data_usedw_r[i] >= dma_xfer_len_r2) begin
                            ddr3_data_rdy_r[i]  <=  1'b1;
                        end else begin
                            ddr3_data_rdy_r[i]  <=  1'b0;
                        end
                    end
            
                //  DDR us
                fifo_ddr_us 
                    ddr3_us_inst 
                    (
                        .rst                    (!sys_rst_n),                       // input wire rst
                        .wr_clk                 (fifo_wrclk_ddr3_us[i]),            // input wire wr_clk
                        .rd_clk                 (ddr3_ui_clk),                      // input wire rd_clk
                        .din                    (fifo_data_ddr3_us[WR_DATA_WIDTH*i +: WR_DATA_WIDTH]),       // input wire [255 : 0] din
                        .wr_en                  (fifo_wrreq_ddr3_us[i]),            // input wire wr_en
                        .rd_en                  (fifo_rdreq_ddr3_us[i]),            // input wire rd_en
                        .dout                   (fifo_q_ddr3_us[DDR_DATA_WIDTH*i +: DDR_DATA_WIDTH]),        // output wire [511 : 0] dout
                        .full                   (),                                 // output wire full
                        .empty                  (),       // output wire empty
                        .prog_full              (fifo_prog_full_ddr3_us[i]),        // output wire prog_full
                        .prog_empty             (fifo_prog_empty_ddr3_us[i])        // output wire prog_empty
                    );

                //  DDR ds
                fifo_ddr_ds 
                    ddr3_ds_inst 
                    (
                        .rst                     (!sys_rst_n),                      // input wire rst
                        .wr_clk                  (ddr3_ui_clk),                     // input wire wr_clk
                        .rd_clk                  (fifo_rdclk_ddr3_ds[i]),           // input wire rd_clk
                        .din                     (fifo_data_ddr3_ds[DDR_DATA_WIDTH*i +: DDR_DATA_WIDTH]),    // input wire [511 : 0] din
                        .wr_en                   (fifo_wrreq_ddr3_ds[i]),           // input wire wr_en
                        .rd_en                   (fifo_rdreq_ddr3_ds[i]),           // input wire rd_en
                        .dout                    (fifo_q_ddr3_ds[RD_DATA_WIDTH*i +: RD_DATA_WIDTH]),         // output wire [255 : 0] dout
                        .full                    (),                                // output wire full
                        .empty                   (fifo_empty_ddr3_ds[i]),           // output wire empty
                        .wr_data_count           (fifo_wrusedw_ddr3_ds[i]),         // output wire [9 : 0] wr_data_count
                        .prog_full               (fifo_prog_full_ddr3_ds[i])        // output wire prog_full
                    );
            end
    end
endgenerate    


// ********************************************************************************** // 
//---------------------------------------------------------------------
// Instantiate the module
//---------------------------------------------------------------------
ddr3_2g_4ch_fsm 
//    # (
//        .DDR_CHANNEL                    (DDR_CHANNEL),
//        .DDR_DATA_WIDTH                 (DDR_DATA_WIDTH)           
//    )
    
    ddr3_fifo_fsm_inst 
    (
        // Logic Clock and Reset#
        .log_clk                        (ddr3_ui_clk), 
        .log_rst_n                      (sys_rst_n), 
        
        // DDR3 SDRAM Controller Calibration Status
        .phy_init_done                  (phy_init_done), 
        
        // DDR3 Data Quantity 
        .ddr3_fifo_usedw                (ddr3_fifo_usedw),     
    
        //---------------------------------------------------------------------
        // FIFO Interface for DDR3 SDRAM Upstream
        .fifo_rdreq_ddr3_us             (fifo_rdreq_ddr3_us), 
        .fifo_q_ddr3_us                 (fifo_q_ddr3_us), 
        .fifo_prog_empty_ddr3_us        (fifo_prog_empty_ddr3_us),    
            
        //---------------------------------------------------------------------
        // DDR3 SDRAM User Interface for Xilinx
        // Address/Command         
        .app_en                         (app_en), 
        .app_cmd                        (app_cmd), 
        .app_addr                       (app_addr), 
        .app_rdy                        (app_rdy),
        // Write Data FIFO 
        .app_wdf_wren                   (app_wdf_wren), 
        .app_wdf_data                   (app_wdf_data), 
        .app_wdf_mask                   (app_wdf_mask), 
        .app_wdf_end                    (app_wdf_end), 
        .app_wdf_rdy                    (app_wdf_rdy), 
        // Read Data FIFO
        .app_rd_data_valid              (app_rd_data_valid), 
        .app_rd_data                    (app_rd_data), 
        .app_rd_data_end                (app_rd_data_end),
    
        //---------------------------------------------------------------------        
        // FIFO Interface for DDR3 SDRAM Downstream          
        .fifo_wrreq_ddr3_ds             (fifo_wrreq_ddr3_ds), 
        .fifo_data_ddr3_ds              (fifo_data_ddr3_ds), 
        .fifo_prog_full_ddr3_ds         (fifo_prog_full_ddr3_ds)             
    );


// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//---------------------------------------------------------------------       
    
    
endmodule
