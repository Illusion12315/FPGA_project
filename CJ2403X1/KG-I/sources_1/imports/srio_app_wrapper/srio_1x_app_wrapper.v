`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     ACQNOVA
// Engineer:    Long Lian
// 
// Create Date: 2020/11/25 14:22:24
// Design Name: 
// Module Name: srio_1x_app_wrapper
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


module srio_1x_app_wrapper
    # (
        parameter       SIM_TRAIN               =   0,                          // If set, initialization counters are reduced from hw values
        parameter       SRIO_ONCE_LENGTH        =   8,
        parameter       SRIO_WR_DATA_WIDTH      =   128, 
        parameter       SRIO_RD_DATA_WIDTH      =   128,
        parameter       SRIO_LINK_WIDTH         =   1                           // 1- X1; 2 - X2; 4 - X4; 8 - X8   
    )
    
    (
        // Clock and Reset# Interface
        output                                  srio_log_clk,                   // Clock for Logical Layer, Rising Edge
        output                                  srio_log_rst,                   // Reset for Logical Layer, High Active
        output                                  srio_clk_lock,                  // Indicates the clocks are valid
        input                                   srio_core_rst,                  // SRIO Core global reset signal
        input                                   fiber_sw_rst,                   // High Active
        input                                   clk_50m,
        input                                   sys_reset_n,                    // System Reset, Low Active

        // GT loopback Ctrl    
        input                                   loopback_sel,                   // "0" 不回环;"1"内回环;
        
        // SRIO ID  
        output      [15:0]                      source_id,
        output      [15:0]                      device_id,
        input       [15:0]                      dest_id,
        input       [15:0]                      device_id_set,
        output                                  id_set_done,  
        
        // Status Signals
        output                                  port_initialized,              // Link has locked to receive stream
        output                                  link_initialized,              // The core is fully trained and can now transmit data
        output                                  mode_1x,                       // For a 2x or 4x core, signal indicates that the core has trained down to one lane

        // FIFO Interface for Packet Transmit
        input                                   fifo_wrclk_pkt_tx,             // Write Clock
        input                                   fifo_wrreq_pkt_tx,             // fifo write request
        input       [SRIO_WR_DATA_WIDTH-1:0]    fifo_data_pkt_tx,              // fifo write data
        output                                  fifo_prog_full_pkt_tx,         // fifo program full
        
        // FIFO Interface for Packet Receive
        input                                   fifo_rdclk_pkt_rx,             // Read Clock
        input                                   fifo_rdreq_pkt_rx,             // fifo read request
        output      [SRIO_RD_DATA_WIDTH-1:0]    fifo_q_pkt_rx,                 // fifo write data
        output                                  fifo_empty_pkt_rx,             // fifo empty
        output                                  fifo_prog_empty_pkt_rx,        // fifo program empty
        
        // SRIO Interface
        input                                   srio_refclkp,                  // 125MHz differential clock
        input                                   srio_refclkn,                  // 125MHz differential clock
        input       [SRIO_LINK_WIDTH-1:0]       srio_rxp,                      // Serial Receive Data +
        input       [SRIO_LINK_WIDTH-1:0]       srio_rxn,                      // Serial Receive Data -
        output      [SRIO_LINK_WIDTH-1:0]       srio_txp,                      // Serial Transmit Data +
        output      [SRIO_LINK_WIDTH-1:0]       srio_txn                       // Serial Transmit Data -      
    );


//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
    wire                                    srio_rst;
    wire                                    sys_rst_n;
    wire                                    loopback_rst;
    wire        [2:0]                       loopback_in;
    wire                                    sim_train_en;
    wire                                    phy_rcvd_link_reset;
    // User Interface - Target Request Port
    wire                                    m_axis_treq_tvalid;
    wire                                    m_axis_treq_tlast;
    wire        [7:0]                       m_axis_treq_tkeep;
    wire                                    m_axis_treq_tready;
    wire        [31:0]                      m_axis_treq_tuser;
    wire        [63:0]                      m_axis_treq_tdata;    
    // User Interface - Target Response Port
    wire                                    s_axis_tresp_tvalid;
    wire                                    s_axis_tresp_tlast;
    wire        [7:0]                       s_axis_tresp_tkeep;
    wire                                    s_axis_tresp_tready;
    wire        [31:0]                      s_axis_tresp_tuser;
    wire        [63:0]                      s_axis_tresp_tdata;
    // User Interface - Initiator Request Port
    wire                                    s_axis_ireq_tvalid;
    wire                                    s_axis_ireq_tlast;
    wire        [7:0]                       s_axis_ireq_tkeep;
    wire                                    s_axis_ireq_tready;
    wire        [31:0]                      s_axis_ireq_tuser;
    wire        [63:0]                      s_axis_ireq_tdata;
    // User Interface - Initiator Response Port
    wire                                    m_axis_iresp_tvalid;
    wire                                    m_axis_iresp_tlast;
    wire        [7:0]                       m_axis_iresp_tkeep;
    wire                                    m_axis_iresp_tready;
    wire        [31:0]                      m_axis_iresp_tuser;
    wire        [63:0]                      m_axis_iresp_tdata;

    // Maintenance Port Interface
    wire                                    s_axi_maintr_awvalid;
    wire                                    s_axi_maintr_awready;
    wire        [31:0]                      s_axi_maintr_awaddr;
    wire                                    s_axi_maintr_wvalid;
    wire                                    s_axi_maintr_wready;
    wire        [31:0]                      s_axi_maintr_wdata;
    wire                                    s_axi_maintr_bvalid;
    wire                                    s_axi_maintr_bready;
    wire        [1:0]                       s_axi_maintr_bresp;
    wire                                    s_axi_maintr_arvalid;
    wire                                    s_axi_maintr_arready;
    wire        [31:0]                      s_axi_maintr_araddr;
    wire                                    s_axi_maintr_rvalid;
    wire                                    s_axi_maintr_rready;
    wire        [31:0]                      s_axi_maintr_rdata;
    wire        [1:0]                       s_axi_maintr_rresp;
    
    // FIFO Interface for Packet Receive
    wire                                    fifo_wrreq_pkt_rx;
    wire        [63:0]                      fifo_data_pkt_rx;
    wire                                    fifo_prog_full_pkt_rx;
    // FIFO Interface for Packet Transmit 
    wire                                    fifo_rdreq_pkt_tx;
    wire        [63:0]                      fifo_q_pkt_tx;
    wire                                    fifo_empty_pkt_tx;            
    wire                                    fifo_prog_empty_pkt_tx; 


//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
    reg                                     srio_core_rst_r             =   1'b1;
    reg                                     fiber_sw_rst_r              =   1'b0;
    reg                                     fiber_sw_rst_r2             =   1'b0;
    reg                                     sys_reset_n_r               =   1'b0;
    reg                                     sys_reset_n_r2              =   1'b0;
    

//---------------------------------------------------------------------  
// Parameter
//---------------------------------------------------------------------  

    
// ********************************************************************************** // 
//---------------------------------------------------------------------
// I/O Connections assignments
//---------------------------------------------------------------------
assign      srio_rst            =   srio_core_rst_r;
assign      sys_rst_n           =   sys_reset_n_r2;
assign      sim_train_en        =   SIM_TRAIN ? 1'b1 : 1'b0;


// ********************************************************************************** // 
//---------------------------------------------------------------------
// Input Register
//---------------------------------------------------------------------
always@(posedge clk_50m)
    begin
        fiber_sw_rst_r  <=  fiber_sw_rst;
        fiber_sw_rst_r2 <=  fiber_sw_rst_r;
    end
always@(posedge clk_50m)
    begin
        srio_core_rst_r <=  srio_core_rst || loopback_rst || fiber_sw_rst_r2;
    end
    
always@(posedge srio_log_clk)
    begin
        sys_reset_n_r   <=  sys_reset_n;
        sys_reset_n_r2  <=  sys_reset_n_r;
    end

//  loopback_ctrl_mod
loopback_ctrl_mod
    u_loopback
    (
        // Clock and Reset# Interface
        .clk_50m                        (clk_50m),
        
        // GT Loopback Ctrl
        .loopback_sel                   (loopback_sel),
        .loopback_rst                   (loopback_rst),
        .loopback_in                    (loopback_in)
    );

// SRIO APP FSM
srio_app_fsm
    u_srio_fsm
    (
        // Clock and Reset# Interface
        .log_clk                        (srio_log_clk),
        .log_rst                        (srio_log_rst),
        
        // Control
        .srio_tx_en                     (1'b1),
        .srio_rx_en                     (1'b1),
        .srio_once_len                  (SRIO_ONCE_LENGTH),
        
        // Status Signals
        .port_initialized               (port_initialized),
        .link_initialized               (link_initialized),
        .mode_1x                        (mode_1x),
        
        // SRIO ID  
        .source_id                      (source_id),
        .dest_id                        (dest_id),
        .device_id                      (device_id),
        .device_id_set                  (device_id_set),
        .id_set_done                    (id_set_done),
        
        // User Interface - Target Request Port
        .m_axis_treq_tvalid             (m_axis_treq_tvalid),
        .m_axis_treq_tlast              (m_axis_treq_tlast),
        .m_axis_treq_tkeep              (m_axis_treq_tkeep),
        .m_axis_treq_tready             (m_axis_treq_tready),
        .m_axis_treq_tuser              (m_axis_treq_tuser),
        .m_axis_treq_tdata              (m_axis_treq_tdata),    
        // User Interface - Target Response Port
        .s_axis_tresp_tvalid            (s_axis_tresp_tvalid),    
        .s_axis_tresp_tlast             (s_axis_tresp_tlast),
        .s_axis_tresp_tkeep             (s_axis_tresp_tkeep),
        .s_axis_tresp_tready            (s_axis_tresp_tready),
        .s_axis_tresp_tuser             (s_axis_tresp_tuser),
        .s_axis_tresp_tdata             (s_axis_tresp_tdata),
        // User Interface - Initiator Request Port
        .s_axis_ireq_tvalid             (s_axis_ireq_tvalid),
        .s_axis_ireq_tlast              (s_axis_ireq_tlast),
        .s_axis_ireq_tkeep              (s_axis_ireq_tkeep),
        .s_axis_ireq_tready             (s_axis_ireq_tready),
        .s_axis_ireq_tuser              (s_axis_ireq_tuser),
        .s_axis_ireq_tdata              (s_axis_ireq_tdata),
        // User Interface - Initiator Response Port
        .m_axis_iresp_tvalid            (m_axis_iresp_tvalid),
        .m_axis_iresp_tlast             (m_axis_iresp_tlast),
        .m_axis_iresp_tkeep             (m_axis_iresp_tkeep),
        .m_axis_iresp_tready            (m_axis_iresp_tready),
        .m_axis_iresp_tuser             (m_axis_iresp_tuser),
        .m_axis_iresp_tdata             (m_axis_iresp_tdata),
        
        // Maintenance Port Interface
        .s_axi_maintr_awvalid           (s_axi_maintr_awvalid),
        .s_axi_maintr_awready           (s_axi_maintr_awready),
        .s_axi_maintr_awaddr            (s_axi_maintr_awaddr ),
        .s_axi_maintr_wvalid            (s_axi_maintr_wvalid ),
        .s_axi_maintr_wready            (s_axi_maintr_wready ),
        .s_axi_maintr_wdata             (s_axi_maintr_wdata  ),
        .s_axi_maintr_bvalid            (s_axi_maintr_bvalid ),
        .s_axi_maintr_bready            (s_axi_maintr_bready ),
        .s_axi_maintr_bresp             (s_axi_maintr_bresp  ),
        .s_axi_maintr_arvalid           (s_axi_maintr_arvalid),
        .s_axi_maintr_arready           (s_axi_maintr_arready),
        .s_axi_maintr_araddr            (s_axi_maintr_araddr ),
        .s_axi_maintr_rvalid            (s_axi_maintr_rvalid ),
        .s_axi_maintr_rready            (s_axi_maintr_rready ),
        .s_axi_maintr_rdata             (s_axi_maintr_rdata  ),
        .s_axi_maintr_rresp             (s_axi_maintr_rresp  ),
        
        // FIFO Interface for Packet Receive
        .fifo_wrreq_pkt_rx              (fifo_wrreq_pkt_rx),
        .fifo_data_pkt_rx               (fifo_data_pkt_rx),
        .fifo_prog_full_pkt_rx          (fifo_prog_full_pkt_rx),
        
        // FIFO Interface for Packet Transmit 
        .fifo_rdreq_pkt_tx              (fifo_rdreq_pkt_tx),
        .fifo_q_pkt_tx                  (fifo_q_pkt_tx),
        .fifo_empty_pkt_tx              (fifo_empty_pkt_tx),            
        .fifo_prog_empty_pkt_tx         (fifo_prog_empty_pkt_tx)
    );

// SRIO Upstream Buffer
fifo_srio_us 
    u_srio_us
    (
        .rst            (~sys_rst_n),                   // input wire rst
        .wr_clk         (fifo_wrclk_pkt_tx),            // input wire wr_clk
        .rd_clk         (srio_log_clk),                 // input wire rd_clk
        .din            (fifo_data_pkt_tx),             // input wire [127 : 0] din
        .wr_en          (fifo_wrreq_pkt_tx),            // input wire wr_en
        .rd_en          (fifo_rdreq_pkt_tx),            // input wire rd_en
        .dout           (fifo_q_pkt_tx),                // output wire [63 : 0] dout
        .full           ( ),                            // output wire full
        .empty          (fifo_empty_pkt_tx),            // output wire empty
        .prog_full      (fifo_prog_full_pkt_tx),        // output wire prog_full
        .prog_empty     (fifo_prog_empty_pkt_tx)        // output wire prog_empty
    );

// SRIO Downstream Buffer
fifo_srio_ds 
    u_srio_ds
    (
        .rst            (srio_log_rst),                 // input wire rst
        .wr_clk         (srio_log_clk),                 // input wire wr_clk
        .rd_clk         (fifo_rdclk_pkt_rx),            // input wire rd_clk
        .din            (fifo_data_pkt_rx),             // input wire [63 : 0] din
        .wr_en          (fifo_wrreq_pkt_rx),            // input wire wr_en
        .rd_en          (fifo_rdreq_pkt_rx),            // input wire rd_en
        .dout           (fifo_q_pkt_rx),                // output wire [127 : 0] dout
        .full           ( ),                            // output wire full
        .empty          (fifo_empty_pkt_rx),            // output wire empty
        .prog_full      (fifo_prog_full_pkt_rx),        // output wire prog_full
        .prog_empty     (fifo_prog_empty_pkt_rx)        // output wire prog_empty
    );

// SRIO Gen2 Endpoint Solution
srio_gen2_x1
    u_srio_ip
    (
        // Clocks and Resets
        .sys_clkp                       (srio_refclkp),
        .sys_clkn                       (srio_refclkn),
        .sys_rst                        (srio_rst),
        
        // all clocks as output
        .log_clk_out                    (srio_log_clk),
        .phy_clk_out                    (),
        .gt_clk_out                     (),
        .gt_pcs_clk_out                 (),
        .drpclk_out                     (),
        .refclk_out                     (),            
        .clk_lock_out                   (srio_clk_lock),
        
        // all resets as output
        .cfg_rst_out                    (),
        .log_rst_out                    (srio_log_rst),
        .buf_rst_out                    (),
        .phy_rst_out                    (),
        .gt_pcs_rst_out                 (),
        
        // QPLL outputs
        .gt0_qpll_clk_out               (),
        .gt0_qpll_out_refclk_out        (),
        
        // Serial IO Interface
        .srio_rxn0                      (srio_rxn[0]),               
        .srio_rxp0                      (srio_rxp[0]),               
//        .srio_rxn1                      (srio_rxn[1]),               
//        .srio_rxp1                      (srio_rxp[1]), 
//        .srio_rxn2                      (srio_rxn[2]),               
//        .srio_rxp2                      (srio_rxp[2]), 
//        .srio_rxn3                      (srio_rxn[3]),               
//        .srio_rxp3                      (srio_rxp[3]), 
        
        .srio_txn0                      (srio_txn[0]),               
        .srio_txp0                      (srio_txp[0]),
//        .srio_txn1                      (srio_txn[1]),               
//        .srio_txp1                      (srio_txp[1]),
//        .srio_txn2                      (srio_txn[2]),               
//        .srio_txp2                      (srio_txp[2]),
//        .srio_txn3                      (srio_txn[3]),               
//        .srio_txp3                      (srio_txp[3]),    
        
        // LOG User I/O Interface
        .s_axis_ireq_tvalid             (s_axis_ireq_tvalid),             
        .s_axis_ireq_tready             (s_axis_ireq_tready),             
        .s_axis_ireq_tlast              (s_axis_ireq_tlast),              
        .s_axis_ireq_tdata              (s_axis_ireq_tdata),              
        .s_axis_ireq_tkeep              (s_axis_ireq_tkeep),              
        .s_axis_ireq_tuser              (s_axis_ireq_tuser),              
        
        .m_axis_iresp_tvalid            (m_axis_iresp_tvalid),            
        .m_axis_iresp_tready            (m_axis_iresp_tready),            
        .m_axis_iresp_tlast             (m_axis_iresp_tlast),             
        .m_axis_iresp_tdata             (m_axis_iresp_tdata),             
        .m_axis_iresp_tkeep             (m_axis_iresp_tkeep),             
        .m_axis_iresp_tuser             (m_axis_iresp_tuser),             
        
        .m_axis_treq_tvalid             (m_axis_treq_tvalid),             
        .m_axis_treq_tready             (m_axis_treq_tready),             
        .m_axis_treq_tlast              (m_axis_treq_tlast),              
        .m_axis_treq_tdata              (m_axis_treq_tdata),              
        .m_axis_treq_tkeep              (m_axis_treq_tkeep),              
        .m_axis_treq_tuser              (m_axis_treq_tuser),              
        
        .s_axis_tresp_tvalid            (s_axis_tresp_tvalid),            
        .s_axis_tresp_tready            (s_axis_tresp_tready),            
        .s_axis_tresp_tlast             (s_axis_tresp_tlast),             
        .s_axis_tresp_tdata             (s_axis_tresp_tdata),             
        .s_axis_tresp_tkeep             (s_axis_tresp_tkeep),             
        .s_axis_tresp_tuser             (s_axis_tresp_tuser),  
        
        .s_axi_maintr_rst               (1'b0),
        
        // Maintenance Port Interface
        .s_axi_maintr_awvalid           (s_axi_maintr_awvalid),
        .s_axi_maintr_awready           (s_axi_maintr_awready),
        .s_axi_maintr_awaddr            (s_axi_maintr_awaddr),
        .s_axi_maintr_wvalid            (s_axi_maintr_wvalid),
        .s_axi_maintr_wready            (s_axi_maintr_wready),
        .s_axi_maintr_wdata             (s_axi_maintr_wdata),
        .s_axi_maintr_bvalid            (s_axi_maintr_bvalid),
        .s_axi_maintr_bready            (s_axi_maintr_bready),
        .s_axi_maintr_bresp             (s_axi_maintr_bresp),

        .s_axi_maintr_arvalid           (s_axi_maintr_arvalid),
        .s_axi_maintr_arready           (s_axi_maintr_arready),
        .s_axi_maintr_araddr            (s_axi_maintr_araddr),
        .s_axi_maintr_rvalid            (s_axi_maintr_rvalid),
        .s_axi_maintr_rready            (s_axi_maintr_rready),
        .s_axi_maintr_rdata             (s_axi_maintr_rdata),
        .s_axi_maintr_rresp             (s_axi_maintr_rresp),
        
//        .s_axi_maintr_awvalid           (1'b0),
//        .s_axi_maintr_awready           (),
//        .s_axi_maintr_awaddr            (32'h00000000),
//        .s_axi_maintr_wvalid            (1'b0),
//        .s_axi_maintr_wready            (),
//        .s_axi_maintr_wdata             (32'h00000000),
//        .s_axi_maintr_bvalid            (),
//        .s_axi_maintr_bready            (1'b0),
//        .s_axi_maintr_bresp             (),
        
//        .s_axi_maintr_arvalid           (1'b0),
//        .s_axi_maintr_arready           (),
//        .s_axi_maintr_araddr            (32'h00000000),
//        .s_axi_maintr_rvalid            (),
//        .s_axi_maintr_rready            (1'b0),
//        .s_axi_maintr_rdata             (),
//        .s_axi_maintr_rresp             (),    

        // PHY control signals
        .sim_train_en                   (sim_train_en),
        .force_reinit                   (1'b0),
        .phy_mce                        (1'b0),
        .phy_link_reset                 (1'b0),
        
        // core debug signals
        .phy_rcvd_mce                   (), 
        .phy_rcvd_link_reset            (phy_rcvd_link_reset),   
        .phy_debug                      (),
        .gtrx_disperr_or                (),
        .gtrx_notintable_or             (),
        
        // side band signals
        .port_error                     (),
        .port_timeout                   (),
        .srio_host                      (),
        
        // LOG Informational signals
        .port_decode_error              (),
        .deviceid                       (device_id),
        
        .idle2_selected                 (),
        .phy_lcl_master_enable_out      (),
        .buf_lcl_response_only_out      (),
        .buf_lcl_tx_flow_control_out    (),
        .buf_lcl_phy_buf_stat_out       (),
        .phy_lcl_phy_next_fm_out        (),
        .phy_lcl_phy_last_ack_out       (),
        .phy_lcl_phy_rewind_out         (),
        .phy_lcl_phy_rcvd_buf_stat_out  (),
        .phy_lcl_maint_only_out         (),
        
        .gt_drpdo_out                   (),
        .gt_drprdy_out                  (),
        .gt_drpaddr_in                  ({SRIO_LINK_WIDTH{9'd0}}),
        .gt_drpdi_in                    ({SRIO_LINK_WIDTH{16'd0}}),
        .gt_drpen_in                    ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_drpwe_in                    ({SRIO_LINK_WIDTH{1'b0}}),
    
        .gt_txpmareset_in               ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_rxpmareset_in               ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_txpcsreset_in               ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_rxpcsreset_in               ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_eyescanreset_in             ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_eyescantrigger_in           ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_eyescandataerror_out        (),

        .gt_loopback_in                 ({SRIO_LINK_WIDTH{loopback_in}}),
        .gt_rxpolarity_in               ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_txpolarity_in               ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_rxlpmen_in                  ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_txprecursor_in              ({SRIO_LINK_WIDTH{5'b00000}}),
        .gt_txpostcursor_in             ({SRIO_LINK_WIDTH{5'b00000}}),
        .gt0_txdiffctrl_in              (4'b1010),
//        .gt1_txdiffctrl_in              (4'b1010),
//        .gt2_txdiffctrl_in              (4'b1010),
//        .gt3_txdiffctrl_in              (4'b1010),
        .gt_txprbsforceerr_in           ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_txprbssel_in                ({SRIO_LINK_WIDTH{3'b000}}),
        .gt_rxprbssel_in                ({SRIO_LINK_WIDTH{3'b000}}),
        .gt_rxprbserr_out               (),
        .gt_rxprbscntreset_in           ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_rxcdrhold_in                ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_rxdfelpmreset_in            ({SRIO_LINK_WIDTH{1'b0}}),
        .gt_rxcommadet_out              (),
        .gt_dmonitorout_out             (),
        .gt_rxresetdone_out             (),
        .gt_txresetdone_out             (),
        .gt_rxbufstatus_out             (),
        .gt_txbufstatus_out             (),
        .gt_txinhibit_in                ({SRIO_LINK_WIDTH{1'b0}}),
        
        // PHY Informational signals
        .port_initialized               (port_initialized),        
        .link_initialized               (link_initialized),        
        .idle_selected                  (),              
        .mode_1x                        (mode_1x)                           
    );


// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//--------------------------------------------------------------------- 
ila_srio_app 
    u_ila_srio_app 
    (
        .clk        (srio_log_clk),             // input wire clk
        .probe0     (s_axis_ireq_tvalid),       // input wire [0:0]  probe0 
        .probe1     (s_axis_ireq_tlast),        // input wire [0:0]  probe1
        .probe2     (s_axis_ireq_tkeep),        // input wire [7:0]  probe2
        .probe3     (s_axis_ireq_tready),       // input wire [0:0]  probe3
        .probe4     (s_axis_ireq_tuser),        // input wire [31:0]  probe4
        .probe5     (s_axis_ireq_tdata),        // input wire [63:0]  probe5
        .probe6     (m_axis_treq_tvalid),       // input wire [0:0]  probe6 
        .probe7     (m_axis_treq_tlast),        // input wire [0:0]  probe7
        .probe8     (m_axis_treq_tkeep),        // input wire [7:0]  probe8
        .probe9     (m_axis_treq_tready),       // input wire [0:0]  probe9
        .probe10    (m_axis_treq_tuser),        // input wire [31:0]  probe10 
        .probe11    (m_axis_treq_tdata),        // input wire [63:0]  probe11
        .probe12    (port_initialized),         // input wire [0:0]  probe12
        .probe13    (link_initialized),         // input wire [0:0]  probe13 
        .probe14    (mode_1x),                  // input wire [0:0]  probe14
        .probe15    (device_id),                // input wire [15:0]  probe15  
        .probe16    (source_id),                // input wire [15:0]  probe16  
        .probe17    (id_set_done)               // input wire [0:0]  probe17  
    );


endmodule
