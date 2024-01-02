`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         ACQNOVA
// Engineer:       Long Lian
// 
// Create Date: 2022/03/11 09:23:24
// Design Name: 
// Module Name: pcie_wrapper
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


module pcie_wrapper
    # (
    parameter                           UART_CHANNEL            =   2,
    parameter                           PCIE_CHANNEL            =   4,
    parameter                           REG_NUM                 =   50,
    parameter                           AXI_ADDR_WIDTH          =   32,
    parameter                           AXI_DATA_WIDTH          =   32,
    parameter                           WR_DATA_WIDTH           =   256,
    parameter                           RD_DATA_WIDTH           =   256,
    parameter                           PCIE_DATA_WIDTH         =   256,
    parameter                           BLK2711_CHANNEL         =   4,
    parameter                           PCIE_LINK_WIDTH         =   8 // 1- X1; 2 - X2; 4 - X4; 8 - X8
    )

    (
        // Clock and Reset# Interface
    output                              pcie_axi_clk               ,

        // Software Reset#
    output                              sw_reset_n                 ,// Software Reset#  
        
        // PCIE Ctrl Status Signals
    output                              pcie_lnk_up                ,
    input                               upstream_valid             ,// 上行数据链路有效标志，上位机读取
    input                               downstream_valid           ,// 下行数据链路有效标志，上位机读取
    input              [  31:0]         upstream_valid_ch          ,// 上行采集通道DDR缓存数据准备有效标志，上位机读取，共可标志32通道
    input              [  31:0]         downstream_valid_ch        ,// 下行回放通道DDR缓存空间准备有效标志，上位机读取，共可标志32通道
    output             [  31:0]         downstream_flag            ,// 下行回放数据通道标志，上位机下发

        // Data Path Select
    output                              record_en                  ,
    output                              play_en                    ,
        
        // Data Path Ctrl
    output             [  31:0]         record_num                 ,
    output             [  31:0]         play_num                   ,

        // DMA Transfer Length
    output             [  31:0]         dma_xfer_len               ,

        // Status Signals
    input              [  15:0]         measured_temp              ,
    input              [  15:0]         measured_vcc               ,
    input                               phy_init_done              ,
        //pps_time
    input              [  31:0]         pps_time                   ,
        //pwm
    output             [  15:0]         duty_cycle1                ,
    output             [  15:0]         duty_cycle2                ,
        //BLK2711
    output             [BLK2711_CHANNEL-1:0]hf_lb_en                   ,
    output             [BLK2711_CHANNEL*16-1:0]send_k_num                 ,
    output             [BLK2711_CHANNEL-1:0]tx_send_en                 ,
    output             [BLK2711_CHANNEL-1:0]data_mod                   ,
    output             [BLK2711_CHANNEL-1:0]loop_mod                   ,
        //uart0~5
    output             [UART_CHANNEL-1:0]fifo_uart_tx_wren          ,
    output             [UART_CHANNEL-1:0]uart_tx_wren_start         ,
    output             [UART_CHANNEL-1:0]uart_tx_wren_end           ,
    output             [UART_CHANNEL*8-1:0]uart_tx_data               ,
    input              [UART_CHANNEL-1:0]fifo_uart_tx_prog_full     ,
    
    output             [UART_CHANNEL*16-1:0]uart_bps                   ,//uart波特率
    output             [UART_CHANNEL*4-1:0]uart_data_bit              ,//数据位
    output             [UART_CHANNEL*2-1:0]uart_stop_bit              ,//停止位
    output             [UART_CHANNEL*2-1:0]uart_parity_bit            ,//校验位
    
    output             [UART_CHANNEL-1:0]fifo_uart_rx_rden          ,
    input              [UART_CHANNEL-1:0]fifo_uart_rx_empty         ,
    input              [UART_CHANNEL*8-1:0]uart_rx_data               ,
    //pps_uart
    output                              pps_fifo_uart_tx_wren      ,
    output             [   7:0]         pps_uart_tx_data           ,
    output                              pps_uart_tx_wren_start     ,
    output                              pps_uart_tx_wren_end       ,
    input                               pps_uart_tx_prog_full      ,

    output             [  15:0]         pps_uart_bps               ,//uart波特率
    output             [   7:0]         pps_uart_data_bit          ,//数据位
    output             [   1:0]         pps_uart_stop_bit          ,//停止位
    output             [   1:0]         pps_uart_parity_bit        ,//校验位

    output                              pps_fifo_uart_rx_rden      ,
    input                               pps_fifo_uart_rx_empty     ,
    input              [   7:0]         pps_uart_rx_data           ,
            //ad7606
    output                              ad7606_start_signal        ,
    output             [   2:0]         os                         ,
    input              [  15:0]         ch1_data                   ,
    input              [  15:0]         ch2_data                   ,
    input              [  15:0]         ch3_data                   ,
    input              [  15:0]         ch4_data                   ,
    input              [  15:0]         ch5_data                   ,
    input              [  15:0]         ch6_data                   ,
    input              [  15:0]         ch7_data                   ,
    input              [  15:0]         ch8_data                   ,
        //---------------------------------------------------------------------   
        // FIFO Interface for PCIE Upstream
    input              [PCIE_CHANNEL-1:0]fifo_wrclk_pcie_us         ,// fifo write clock
    input              [PCIE_CHANNEL-1:0]fifo_wrreq_pcie_us         ,// fifo write request
    input              [PCIE_CHANNEL*WR_DATA_WIDTH-1:0]fifo_data_pcie_us          ,// fifo write data
    output             [PCIE_CHANNEL-1:0]fifo_prog_full_pcie_us     ,// fifo program full

        //---------------------------------------------------------------------   
        // FIFO Interface for PCIE Downstream
    input              [PCIE_CHANNEL-1:0]fifo_rdclk_pcie_ds         ,// fifo read clock
    input              [PCIE_CHANNEL-1:0]fifo_rdreq_pcie_ds         ,// fifo read request
    output             [PCIE_CHANNEL*RD_DATA_WIDTH-1:0]fifo_q_pcie_ds             ,// fifo read data
    output             [PCIE_CHANNEL-1:0]fifo_empty_pcie_ds         ,// fifo empty           
                       
        //---------------------------------------------------------------------                    
        // PCIE Interface
    input                               pcie_ref_p                 ,
    input                               pcie_ref_n                 ,
    input                               sys_rst_n                  ,
                      
    output             [PCIE_LINK_WIDTH - 1 : 0]pci_exp_txp                ,
    output             [PCIE_LINK_WIDTH - 1 : 0]pci_exp_txn                ,
    input              [PCIE_LINK_WIDTH - 1 : 0]pci_exp_rxp                ,
    input              [PCIE_LINK_WIDTH - 1 : 0]pci_exp_rxn                 
    );


//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
    wire                                    sys_clk;
    wire                                    sys_clk_gt;
    wire                                    sys_rst_n_c;
    wire                                    hw_reset_n;
    // RAM Interface       
    wire                                    ram_wren;                   // Write Enab
    wire        [AXI_ADDR_WIDTH-1:0]        ram_waddr;                  // Write Addr
    wire        [AXI_DATA_WIDTH-1:0]        ram_wdata;                  // Write Data
    wire                                    ram_rden;                   // Read Enabl
    wire        [AXI_ADDR_WIDTH-1:0]        ram_raddr;                  // Read Addre
    wire        [AXI_DATA_WIDTH-1:0]        ram_rdata;                  // Read Data 
    //-- AXI Global
    wire                                    axi_aclk;
    wire                                    axi_aresetn;
    wire                                    user_lnk_up;
    wire                                    usr_irq_ack;

    //-- AXI Master Write Address Channel
    wire        [AXI_ADDR_WIDTH-1:0]        m_axil_awaddr;
    wire        [2:0]                       m_axil_awprot;
    wire                                    m_axil_awvalid;
    wire                                    m_axil_awready;
    //-- AXI Master Write Data Channel
    wire        [AXI_DATA_WIDTH-1:0]        m_axil_wdata;
    wire        [3:0]                       m_axil_wstrb;
    wire                                    m_axil_wvalid;
    wire                                    m_axil_wready;
    //-- AXI Master Write Response Channel
    wire                                    m_axil_bvalid;
    wire        [1:0]                       m_axil_bresp;
    wire                                    m_axil_bready;
    
    //-- AXI Master Read Address Channel                   
    wire        [AXI_ADDR_WIDTH-1:0]        m_axil_araddr;
    wire        [2:0]                       m_axil_arprot;
    wire                                    m_axil_arvalid;
    wire                                    m_axil_arready;
    //-- AXI Master Read Data Channel
    wire        [AXI_DATA_WIDTH-1:0]        m_axil_rdata;
    wire        [1:0]                       m_axil_rresp;
    wire                                    m_axil_rvalid;
    wire                                    m_axil_rready;
   
    // AXI ST interface to user
    wire        [PCIE_DATA_WIDTH-1:0]       s_axis_c2h_tdata    [PCIE_CHANNEL-1:0];
    wire        [PCIE_CHANNEL-1:0]          s_axis_c2h_tlast;
    wire        [PCIE_CHANNEL-1:0]          s_axis_c2h_tvalid;
    wire        [PCIE_CHANNEL-1:0]          s_axis_c2h_tready;
    wire        [PCIE_DATA_WIDTH/8-1:0]     s_axis_c2h_tkeep    [PCIE_CHANNEL-1:0];
    
    wire        [PCIE_DATA_WIDTH-1:0]       m_axis_h2c_tdata    [PCIE_CHANNEL-1:0];
    wire        [PCIE_CHANNEL-1:0]          m_axis_h2c_tlast;
    wire        [PCIE_CHANNEL-1:0]          m_axis_h2c_tvalid;
    wire        [PCIE_CHANNEL-1:0]          m_axis_h2c_tready;
    wire        [PCIE_DATA_WIDTH/8-1:0]     m_axis_h2c_tkeep    [PCIE_CHANNEL-1:0];    

    // FIFO Interface for PCIE Upstream
    wire        [PCIE_CHANNEL-1:0]          fifo_empty_pcie_us;
    // FIFO Interface for PCIE Downstream
    wire        [PCIE_CHANNEL-1:0]          fifo_wrreq_pcie_ds;
    wire        [PCIE_CHANNEL-1:0]          fifo_prog_full_pcie_ds;


//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
    // Link Status Signals
    reg                                     pcie_lnk_up_r       =   1'b0;
    reg                                     pcie_lnk_up_r2      =   1'b0;
    reg                                     hw_rst_n_r          =   1'b0;
    reg         [31:0]                      hw_rst_cnt          =   32'd0;
    // User Interface - Initiator Request Port
    reg                                     us_tlast_r      [PCIE_CHANNEL-1:0];
    reg         [31:0]                      us_data_cnt     [PCIE_CHANNEL-1:0];
    reg         [31:0]                      dma_once_len        =   32'd0;


// ********************************************************************************** // 
//---------------------------------------------------------------------
// I/O Connections assignments
//---------------------------------------------------------------------       
assign          pcie_axi_clk            =   axi_aclk;
assign          pcie_lnk_up             =   pcie_lnk_up_r2;
assign          hw_reset_n              =   hw_rst_n_r;


always@(posedge pcie_axi_clk)
    begin
        pcie_lnk_up_r   <=  user_lnk_up;
        pcie_lnk_up_r2  <=  pcie_lnk_up_r;     
    end
    
//  PCIE初始化硬件复位
always@(posedge pcie_axi_clk or negedge pcie_lnk_up_r2)
    begin
        if(!pcie_lnk_up_r2) begin   
            hw_rst_n_r  <=  1'b0;            
            hw_rst_cnt  <=  32'd0;
        end else if(hw_rst_cnt >= 32'd250_000_000) begin          
            hw_rst_n_r  <=  1'b1;     
            hw_rst_cnt  <=  hw_rst_cnt;
        end else begin        
            hw_rst_n_r  <=  1'b0;       
            hw_rst_cnt  <=  hw_rst_cnt + 1'b1;
        end        
    end    
    
// DMA Transfer Length
always@(posedge pcie_axi_clk)
    begin
        if(PCIE_DATA_WIDTH == 128)begin
            dma_once_len   <=  dma_xfer_len >> 4;
        end else if(PCIE_DATA_WIDTH == 256)begin
            dma_once_len   <=  dma_xfer_len >> 5;
        end else begin
            dma_once_len   <=  dma_once_len;
        end
    end
    
    
//---------------------------------------------------------------------  
// Buffer
//---------------------------------------------------------------------   
// Ref Clock Buffer
IBUFDS_GTE2
    refclk_ibuf
    (
        .O          (sys_clk), 
        .ODIV2      (), 
        .CEB        (1'b0), 
        .I          (pcie_ref_p), 
        .IB         (pcie_ref_n)
    ); 

// Reset Buffer    
IBUF 
    sys_rst_n_ibuf 
    (
        .O          (sys_rst_n_c), 
        .I          (sys_rst_n)
    );


// ********************************************************************************** // 
//--------------------------------------------------------------------- 
// PCIE Registers Ctrl
//---------------------------------------------------------------------
reg_file # (
    .REG_NUM                           (REG_NUM                   ),
    .UART_CHANNEL                      (UART_CHANNEL              ),
    .AXI_ADDR_WIDTH                    (AXI_ADDR_WIDTH            ),
    .BLK2711_CHANNEL                   (BLK2711_CHANNEL           ),
    .AXI_DATA_WIDTH                    (AXI_DATA_WIDTH            ) 
    )
    
    u_reg_file
    (
        // System Clock and Reset#
    .log_clk                           (pcie_axi_clk              ),
    .log_rst_n                         (hw_reset_n                ),
        
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
        //pps_time
    .pps_time                          (pps_time                  ),
        //pwm
    .duty_cycle1                       (duty_cycle1               ),
    .duty_cycle2                       (duty_cycle2               ),
        //2711
    .hf_lb_en                          (hf_lb_en                  ),
    .send_k_num                        (send_k_num                ),
    .tx_send_en                        (tx_send_en                ),
    .data_mod                          (data_mod                  ),
    .loop_mod                          (loop_mod                  ),

        //uart
    .fifo_uart_tx_wren                 (fifo_uart_tx_wren         ),
    .uart_tx_wren_start                (uart_tx_wren_start        ),
    .uart_tx_wren_end                  (uart_tx_wren_end          ),
    .uart_tx_data                      (uart_tx_data              ),

    .uart_bps                          (uart_bps                  ),//波特率
    .uart_data_bit                     (uart_data_bit             ),//数据位
    .uart_stop_bit                     (uart_stop_bit             ),//停止位
    .uart_parity_bit                   (uart_parity_bit           ),//校验位

    .fifo_uart_rx_rden                 (fifo_uart_rx_rden         ),
    .fifo_uart_rx_empty                (fifo_uart_rx_empty        ),
    .uart_rx_data                      (uart_rx_data              ),
    
        //pps_uart
    .pps_fifo_uart_tx_wren             (pps_fifo_uart_tx_wren     ),
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
        // Status Signals
    .measured_temp                     (measured_temp             ),
    .measured_vcc                      (measured_vcc              ),
    .phy_init_done                     (phy_init_done             ),
                
        // RAM Interface
    .ram_wren                          (ram_wren                  ),
    .ram_waddr                         (ram_waddr                 ),
    .ram_wdata                         (ram_wdata                 ),
    .ram_rden                          (ram_rden                  ),
    .ram_raddr                         (ram_raddr                 ),
    .ram_rdata                         (ram_rdata                 ) 
    );


// ********************************************************************************** // 
//--------------------------------------------------------------------- 
// AXI LITE RAM Ctrl
//---------------------------------------------------------------------
axil_ram_ctrl
//    # (
//        .AXI_ADDR_WIDTH                 (AXI_ADDR_WIDTH),    
//        .AXI_DATA_WIDTH                 (AXI_DATA_WIDTH)                   
//    )
    
    u_axil_ram_ctrl
    (
        // System Clock and Reset#
        .axi_clk                        (pcie_axi_clk),
        .log_rst_n                      (hw_reset_n),

        // LITE Interface   
        // AXI-LITE-MM   bar0
        //-- AXI Master Write Address Channel  
        .m_axil_awaddr                  (m_axil_awaddr),      
        .m_axil_awprot                  (m_axil_awprot),          
        .m_axil_awvalid                 (m_axil_awvalid),               
        .m_axil_awready                 (m_axil_awready),              
        //-- AXI Master Write Data Channel
        .m_axil_wdata                   (m_axil_wdata),    
        .m_axil_wstrb                   (m_axil_wstrb),             
        .m_axil_wvalid                  (m_axil_wvalid),               
        .m_axil_wready                  (m_axil_wready),               
        //-- AXI Master Write Response Channel
        .m_axil_bvalid                  (m_axil_bvalid),    
        .m_axil_bresp                   (m_axil_bresp),          
        .m_axil_bready                  (m_axil_bready),                
        //-- AXI Master Read Address Channel
        .m_axil_araddr                  (m_axil_araddr),    
        .m_axil_arprot                  (m_axil_arprot),           
        .m_axil_arvalid                 (m_axil_arvalid),              
        .m_axil_arready                 (m_axil_arready),               
        //-- AXI Master Read Data Channel
        .m_axil_rdata                   (m_axil_rdata),
        .m_axil_rresp                   (m_axil_rresp),                 
        .m_axil_rvalid                  (m_axil_rvalid),                
        .m_axil_rready                  (m_axil_rready),     

        // RAM Interface
        .ram_wren                       (ram_wren),
        .ram_waddr                      (ram_waddr),
        .ram_wdata                      (ram_wdata),
        .ram_rden                       (ram_rden),
        .ram_raddr                      (ram_raddr),
        .ram_rdata                      (ram_rdata)                
    );


generate
    begin : pcie_ctrl
        genvar  i;
        for (i = 0; i <= PCIE_CHANNEL - 1; i = i + 1)
            begin:ch
                // ********************************************************************************** // 
                //--------------------------------------------------------------------- 
                // PCIE Upstream Ctrl
                //---------------------------------------------------------------------
                fifo_pcie_us
                    u_pcie_us
                    (
                        .rst                (!sw_reset_n),                  // input wire rst
                        .wr_clk             (fifo_wrclk_pcie_us[i]),        // input wire wr_clk
                        .rd_clk             (pcie_axi_clk),                 // input wire rd_clk
                        .din                (fifo_data_pcie_us[WR_DATA_WIDTH*i +: WR_DATA_WIDTH]),   // input wire [255 : 0] din
                        .wr_en              (fifo_wrreq_pcie_us[i]),        // input wire wr_en
                        .rd_en              (s_axis_c2h_tvalid[i]),         // input wire rd_en
                        .dout               (s_axis_c2h_tdata[i]),          // output wire [255 : 0] dout
                        .full               (),                             // output wire full
                        .empty              (fifo_empty_pcie_us[i]),        // output wire empty
                        .prog_full          (fifo_prog_full_pcie_us[i])     // output wire prog_full
                    );
                
//                ila_pcie_debug ila_pcie_debug_inst (
//                    .clk                               (pcie_axi_clk              ),// input wire clk

//                    .probe0                            (s_axis_c2h_tvalid[i]      ),// input wire [0:0]  probe0  
//                    .probe1                            (s_axis_c2h_tdata[i]       ),// input wire [255:0]  probe1 
//                    .probe2                            (fifo_empty_pcie_us[i]     ) // input wire [0:0]  probe2
//                );

                assign      s_axis_c2h_tvalid[i]    =   pcie_lnk_up && !fifo_empty_pcie_us[i] && s_axis_c2h_tready[i];
                assign      s_axis_c2h_tlast[i]     =   us_tlast_r[i];
                assign      s_axis_c2h_tkeep[i]     =   (PCIE_DATA_WIDTH == 256) ? {32{s_axis_c2h_tvalid[i]}} : {16{s_axis_c2h_tvalid[i]}};
                
                always@(posedge pcie_axi_clk or negedge sw_reset_n)
                    begin
                        if(!sw_reset_n)begin
                            us_tlast_r[i]   <= 1'b0;
                            us_data_cnt[i]  <= 32'h0;
                        end else begin
                            if(s_axis_c2h_tvalid[i])begin
                                if(us_data_cnt[i] == dma_once_len - 1)begin
                                    us_tlast_r[i]   <= 1'b0;
                                    us_data_cnt[i]  <= 32'h0;
                                end else if(us_data_cnt[i] == dma_once_len - 2)begin
                                    us_tlast_r[i]   <= 1'b1;
                                    us_data_cnt[i]  <= us_data_cnt[i] + 32'd1;
                                end else begin
                                    us_tlast_r[i]   <= 1'b0;
                                    us_data_cnt[i]  <= us_data_cnt[i] + 32'd1;
                                end
                            end else begin
                                us_tlast_r[i]   <= 1'b0;
                                us_data_cnt[i]  <= us_data_cnt[i];
                            end  
                        end
                    end


                // ********************************************************************************** // 
                //--------------------------------------------------------------------- 
                // PCIE Downstream Ctrl
                //---------------------------------------------------------------------
                assign      m_axis_h2c_tready[i]    =   !fifo_prog_full_pcie_ds[i];
                assign      fifo_wrreq_pcie_ds[i]   =   m_axis_h2c_tvalid[i] && m_axis_h2c_tready[i];

                fifo_pcie_ds
                    u_pcie_ds
                    (
                        .rst                (!sw_reset_n),                  // input wire rst
                        .wr_clk             (pcie_axi_clk),                 // input wire wr_clk
                        .rd_clk             (fifo_rdclk_pcie_ds[i]),        // input wire rd_clk
                        .din                (m_axis_h2c_tdata[i]),          // input wire [255 : 0] din
                        .wr_en              (fifo_wrreq_pcie_ds[i]),        // input wire wr_en
                        .rd_en              (fifo_rdreq_pcie_ds[i]),        // input wire rd_en
                        .dout               (fifo_q_pcie_ds[RD_DATA_WIDTH*i +: RD_DATA_WIDTH]),  // output wire [255 : 0] dout
                        .full               (),                             // output wire full
                        .empty              (fifo_empty_pcie_ds[i]),        // output wire empty
                        .prog_full          (fifo_prog_full_pcie_ds[i])     // output wire prog_full
                    );                
            end
    end
endgenerate    


// ********************************************************************************** // 
//--------------------------------------------------------------------- 
// Core Top Level Wrapper
//---------------------------------------------------------------------
xdma_0 
    xdma_ip
    (
        // PCI Express (pci_exp) Interface 
        .sys_clk                        (sys_clk),                      // input wire sys_clk
//        .sys_clk_gt                     (sys_clk_gt),                   // input wire sys_clk_gt
        .sys_rst_n                      (sys_rst_n_c),                  // input wire sys_rst_n

        .pci_exp_txp                    (pci_exp_txp),                  // output wire [7 : 0] pci_exp_txp
        .pci_exp_txn                    (pci_exp_txn),                  // output wire [7 : 0] pci_exp_txn
        .pci_exp_rxp                    (pci_exp_rxp),                  // input wire [7 : 0] pci_exp_rxp
        .pci_exp_rxn                    (pci_exp_rxn),                  // input wire [7 : 0] pci_exp_rxn
        
        //-- AXI Global
        .axi_aclk                       (axi_aclk),                     // output wire axi_aclk
        .axi_aresetn                    (axi_aresetn),                  // output wire axi_aresetn
        .user_lnk_up                    (user_lnk_up),                  // output wire user_lnk_up        
        .usr_irq_req                    (1'b0),                         // input wire [0 : 0] usr_irq_req
        .usr_irq_ack                    (usr_irq_ack),                  // output wire [0 : 0] usr_irq_ack
        
        // LITE Interface   
        // AXI-LITE-MM   bar0
        //-- AXI Master Write Address Channel  
        .m_axil_awaddr                  (m_axil_awaddr),                // output wire [31 : 0] m_axil_awaddr
        .m_axil_awprot                  (m_axil_awprot),                // output wire [2 : 0] m_axil_awprot
        .m_axil_awvalid                 (m_axil_awvalid),               // output wire m_axil_awvalid
        .m_axil_awready                 (m_axil_awready),               // input wire m_axil_awready
        //-- AXI Master Write Data Channel
        .m_axil_wdata                   (m_axil_wdata),                 // output wire [31 : 0] m_axil_wdata
        .m_axil_wstrb                   (m_axil_wstrb),                 // output wire [3 : 0] m_axil_wstrb
        .m_axil_wvalid                  (m_axil_wvalid),                // output wire m_axil_wvalid
        .m_axil_wready                  (m_axil_wready),                // input wire m_axil_wready
        //-- AXI Master Write Response Channel
        .m_axil_bvalid                  (m_axil_bvalid),                // input wire m_axil_bvalid
        .m_axil_bresp                   (m_axil_bresp),                 // input wire [1 : 0] m_axil_bresp
        .m_axil_bready                  (m_axil_bready),                // output wire m_axil_bready
        //-- AXI Master Read Address Channel
        .m_axil_araddr                  (m_axil_araddr),                // output wire [31 : 0] m_axil_araddr
        .m_axil_arprot                  (m_axil_arprot),                // output wire [2 : 0] m_axil_arprot
        .m_axil_arvalid                 (m_axil_arvalid),               // output wire m_axil_arvalid
        .m_axil_arready                 (m_axil_arready),               // input wire m_axil_arready
        //-- AXI Master Read Data Channel
        .m_axil_rdata                   (m_axil_rdata),                 // input wire [31 : 0] m_axil_rdata
        .m_axil_rresp                   (m_axil_rresp),                 // input wire [1 : 0] m_axil_rresp
        .m_axil_rvalid                  (m_axil_rvalid),                // input wire m_axil_rvalid
        .m_axil_rready                  (m_axil_rready),                // output wire m_axil_rready
        
        // AXI streaming ports
        // upstream data
        //ch0
        .s_axis_c2h_tdata_0             (s_axis_c2h_tdata[0]),          // input wire [255 : 0] s_axis_c2h_tdata_0
        .s_axis_c2h_tlast_0             (s_axis_c2h_tlast[0]),          // input wire s_axis_c2h_tlast_0
        .s_axis_c2h_tvalid_0            (s_axis_c2h_tvalid[0]),         // input wire s_axis_c2h_tvalid_0
        .s_axis_c2h_tready_0            (s_axis_c2h_tready[0]),         // output wire s_axis_c2h_tready_0
        .s_axis_c2h_tkeep_0             (s_axis_c2h_tkeep[0]),          // input wire [31 : 0] s_axis_c2h_tkeep_0

        // downstream data
        //ch0
        .m_axis_h2c_tdata_0             (m_axis_h2c_tdata[0]),          // output wire [255 : 0] m_axis_h2c_tdata_0
        .m_axis_h2c_tlast_0             (m_axis_h2c_tlast[0]),          // output wire m_axis_h2c_tlast_0
        .m_axis_h2c_tvalid_0            (m_axis_h2c_tvalid[0]),         // output wire m_axis_h2c_tvalid_0
        .m_axis_h2c_tready_0            (m_axis_h2c_tready[0]),         // input wire m_axis_h2c_tready_0
        .m_axis_h2c_tkeep_0             (m_axis_h2c_tkeep[0]),          // output wire [31 : 0] m_axis_h2c_tkeep_0
        
        // upstream data
        //ch1
        .s_axis_c2h_tdata_1             (s_axis_c2h_tdata[1]),          // input wire [255 : 0] s_axis_c2h_tdata_1
        .s_axis_c2h_tlast_1             (s_axis_c2h_tlast[1]),          // input wire s_axis_c2h_tlast_1
        .s_axis_c2h_tvalid_1            (s_axis_c2h_tvalid[1]),         // input wire s_axis_c2h_tvalid_1
        .s_axis_c2h_tready_1            (s_axis_c2h_tready[1]),         // output wire s_axis_c2h_tready_1
        .s_axis_c2h_tkeep_1             (s_axis_c2h_tkeep[1]),          // input wire [31 : 0] s_axis_c2h_tkeep_1

        // downstream data
        //ch1
        .m_axis_h2c_tdata_1             (m_axis_h2c_tdata[1]),          // output wire [255 : 0] m_axis_h2c_tdata_1
        .m_axis_h2c_tlast_1             (m_axis_h2c_tlast[1]),          // output wire m_axis_h2c_tlast_1
        .m_axis_h2c_tvalid_1            (m_axis_h2c_tvalid[1]),         // output wire m_axis_h2c_tvalid_1
        .m_axis_h2c_tready_1            (m_axis_h2c_tready[1]),         // input wire m_axis_h2c_tready_1
        .m_axis_h2c_tkeep_1             (m_axis_h2c_tkeep[1]),          // output wire [31 : 0] m_axis_h2c_tkeep_1
        
        // upstream data
        //ch2
        .s_axis_c2h_tdata_2             (s_axis_c2h_tdata[2]),          // input wire [255 : 0] s_axis_c2h_tdata_2
        .s_axis_c2h_tlast_2             (s_axis_c2h_tlast[2]),          // input wire s_axis_c2h_tlast_2
        .s_axis_c2h_tvalid_2            (s_axis_c2h_tvalid[2]),         // input wire s_axis_c2h_tvalid_2
        .s_axis_c2h_tready_2            (s_axis_c2h_tready[2]),         // output wire s_axis_c2h_tready_2
        .s_axis_c2h_tkeep_2             (s_axis_c2h_tkeep[2]),          // input wire [31 : 0] s_axis_c2h_tkeep_2

        // downstream data
        //ch2
        .m_axis_h2c_tdata_2             (m_axis_h2c_tdata[2]),          // output wire [255 : 0] m_axis_h2c_tdata_2
        .m_axis_h2c_tlast_2             (m_axis_h2c_tlast[2]),          // output wire m_axis_h2c_tlast_2
        .m_axis_h2c_tvalid_2            (m_axis_h2c_tvalid[2]),         // output wire m_axis_h2c_tvalid_2
        .m_axis_h2c_tready_2            (m_axis_h2c_tready[2]),         // input wire m_axis_h2c_tready_2
        .m_axis_h2c_tkeep_2             (m_axis_h2c_tkeep[2]),          // output wire [31 : 0] m_axis_h2c_tkeep_2
        
        // upstream data
        //ch3
        .s_axis_c2h_tdata_3             (s_axis_c2h_tdata[3]),          // input wire [255 : 0] s_axis_c2h_tdata_3
        .s_axis_c2h_tlast_3             (s_axis_c2h_tlast[3]),          // input wire s_axis_c2h_tlast_3
        .s_axis_c2h_tvalid_3            (s_axis_c2h_tvalid[3]),         // input wire s_axis_c2h_tvalid_3
        .s_axis_c2h_tready_3            (s_axis_c2h_tready[3]),         // output wire s_axis_c2h_tready_3
        .s_axis_c2h_tkeep_3             (s_axis_c2h_tkeep[3]),          // input wire [31 : 0] s_axis_c2h_tkeep_3

        // downstream data
        //ch3
        .m_axis_h2c_tdata_3             (m_axis_h2c_tdata[3]),          // output wire [255 : 0] m_axis_h2c_tdata_3
        .m_axis_h2c_tlast_3             (m_axis_h2c_tlast[3]),          // output wire m_axis_h2c_tlast_3
        .m_axis_h2c_tvalid_3            (m_axis_h2c_tvalid[3]),         // output wire m_axis_h2c_tvalid_3
        .m_axis_h2c_tready_3            (m_axis_h2c_tready[3]),         // input wire m_axis_h2c_tready_3
        .m_axis_h2c_tkeep_3             (m_axis_h2c_tkeep[3])           // output wire [31 : 0] m_axis_h2c_tkeep_3        
    );


// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//--------------------------------------------------------------------- 
//ila_pcie_axil
//    u_ila_pcie_axil
//    (
//        .clk            (pcie_axi_clk),             // input wire clk
//        .probe0         (m_axil_awaddr),            // input wire [31:0]  probe0  
//        .probe1         (m_axil_awvalid),           // input wire [0:0]  probe1 
//        .probe2         (m_axil_awready),           // input wire [0:0]  probe2 
//        .probe3         (m_axil_wdata),             // input wire [31:0]  probe3 
//        .probe4         (m_axil_wvalid),            // input wire [0:0]  probe4 
//        .probe5         (m_axil_wready),            // input wire [0:0]  probe5 
//        .probe6         (m_axil_bvalid),            // input wire [0:0]  probe6 
//        .probe7         (m_axil_bready),            // input wire [0:0]  probe7 
//        .probe8         (m_axil_araddr),            // input wire [31:0]  probe8  
//        .probe9         (m_axil_arvalid),           // input wire [0:0]  probe9 
//        .probe10        (m_axil_arready),           // input wire [0:0]  probe10 
//        .probe11        (m_axil_rdata),             // input wire [31:0]  probe11 
//        .probe12        (m_axil_rvalid),            // input wire [0:0]  probe12 
//        .probe13        (m_axil_rready)             // input wire [0:0]  probe13 
//    );     

        
endmodule
