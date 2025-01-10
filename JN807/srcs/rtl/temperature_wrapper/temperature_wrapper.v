`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             temperature_wrapper.v
// Create Date:           2025/01/03 15:23:19
// Version:               V1.0
// PATH:                  rtl\temperature_wrapper\temperature_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module temperature_wrapper #(
    parameter                       C_S_AXI_DATA_WIDTH = 32    ,
    parameter                       C_S_AXI_ADDR_WIDTH = 12    
) (
    //ADC ADS131 散热器温度采集 
    input  wire        [32-1: 0]    ch0_temp            ,//input slv_reg000 ch0_temp [32-1:0]
    input  wire        [32-1: 0]    ch1_temp            ,//input slv_reg001 ch1_temp [32-1:0]
    input  wire        [32-1: 0]    ch2_temp            ,//input slv_reg002 ch2_temp [32-1:0]
    input  wire        [32-1: 0]    ch3_temp            ,//input slv_reg003 ch3_temp [32-1:0]
    input  wire        [32-1: 0]    ch4_temp            ,//input slv_reg004 ch4_temp [32-1:0]
    input  wire        [32-1: 0]    ch5_temp            ,//input slv_reg005 ch5_temp [32-1:0]
    input  wire        [32-1: 0]    ch6_temp            ,//input slv_reg006 ch6_temp [32-1:0]
    input  wire        [32-1: 0]    ch7_temp            ,//input slv_reg007 ch7_temp [32-1:0]
    // User ports starts
    input  wire                     vop_pos_pg_i        ,//input slv_reg009 i_vop_pos_pg [ 1-1:0]
    input  wire                     vop_neg_pg_i        ,//input slv_reg009 i_vop_neg_pg [ 1-1:0]
    input  wire                     tmp275_alert_i      ,//input slv_reg009 i_tmp275_alert [ 1-1:0]
    input  wire                     ocp_da_trig_i       ,//input slv_reg009 i_ocp_da_trig [ 1-1:0]
    input  wire                     cv_limit_switch_i   ,//input slv_reg009 i_cv_limit_switch [ 1-1:0]
    input  wire        [   2: 0]    out_dip_switch_i    ,//input slv_reg009 i_out_dip_switch [ 3-1:0]
    input  wire        [   3: 0]    dip_switch_i        ,//input slv_reg009 i_dip_switch [ 4-1:0]
    input  wire        [   7: 0]    fault_pan_i         ,//input slv_reg009 i_fault_pan [ 8-1:0]
	// User ports ends
    input  wire                     S_AXI_ACLK          ,
    input  wire                     S_AXI_ARESETN       ,
    input  wire        [C_S_AXI_ADDR_WIDTH-1: 0]S_AXI_AWADDR,
    input  wire        [   2: 0]    S_AXI_AWPROT        ,
    input  wire                     S_AXI_AWVALID       ,
    output wire                     S_AXI_AWREADY       ,
    input  wire        [C_S_AXI_DATA_WIDTH-1: 0]S_AXI_WDATA,
    input  wire        [(C_S_AXI_DATA_WIDTH/8)-1: 0]S_AXI_WSTRB,
    input  wire                     S_AXI_WVALID        ,
    output wire                     S_AXI_WREADY        ,
    output wire        [   1: 0]    S_AXI_BRESP         ,
    output wire                     S_AXI_BVALID        ,
    input  wire                     S_AXI_BREADY        ,
    input  wire        [C_S_AXI_ADDR_WIDTH-1: 0]S_AXI_ARADDR,
    input  wire        [   2: 0]    S_AXI_ARPROT        ,
    input  wire                     S_AXI_ARVALID       ,
    output wire                     S_AXI_ARREADY       ,
    output wire        [C_S_AXI_DATA_WIDTH-1: 0]S_AXI_RDATA,
    output wire        [   1: 0]    S_AXI_RRESP         ,
    output wire                     S_AXI_RVALID        ,
    input  wire                     S_AXI_RREADY         
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------

    wire                            ram_wr_en           ;
    wire               [C_S_AXI_ADDR_WIDTH-1: 0]ram_wr_addr  ;
    wire               [(C_S_AXI_DATA_WIDTH/8)-1: 0]ram_wr_wstrb  ;
    wire               [C_S_AXI_DATA_WIDTH-1: 0]ram_wr_data  ;
    wire                            ram_rd_en           ;
    wire               [C_S_AXI_ADDR_WIDTH-1: 0]ram_rd_addr  ;
    wire               [C_S_AXI_DATA_WIDTH-1: 0]ram_rd_data  ;

temperature_reg_map_cfg u_temperature_reg_map_cfg(
    //System
    .sys_clk_i                      (S_AXI_ACLK         ),
    .rst_n_i                        (S_AXI_ARESETN      ),
    //Ram interface
    .ram_wr_en_i                    (ram_wr_en          ),
    .ram_wr_addr_i                  (ram_wr_addr        ),
    .ram_wr_data_i                  (ram_wr_data        ),
    .ram_rd_en_i                    (ram_rd_en          ),
    .ram_rd_addr_i                  (ram_rd_addr        ),
    .ram_rd_data_o                  (ram_rd_data        ),
    //reg map
    .ch0_temp                       (ch0_temp           ),// input slv_reg000 ch0_temp [32-1:0]
    .ch1_temp                       (ch1_temp           ),// input slv_reg001 ch1_temp [32-1:0]
    .ch2_temp                       (ch2_temp           ),// input slv_reg002 ch2_temp [32-1:0]
    .ch3_temp                       (ch3_temp           ),// input slv_reg003 ch3_temp [32-1:0]
    .ch4_temp                       (ch4_temp           ),// input slv_reg004 ch4_temp [32-1:0]
    .ch5_temp                       (ch5_temp           ),// input slv_reg005 ch5_temp [32-1:0]
    .ch6_temp                       (ch6_temp           ),// input slv_reg006 ch6_temp [32-1:0]
    .ch7_temp                       (ch7_temp           ),// input slv_reg007 ch7_temp [32-1:0]
    .i_vop_pos_pg                   (vop_pos_pg_i       ),// input slv_reg009 i_vop_pos_pg [ 1-1:0]
    .i_vop_neg_pg                   (vop_neg_pg_i       ),// input slv_reg009 i_vop_neg_pg [ 1-1:0]
    .i_tmp275_alert                 (tmp275_alert_i     ),// input slv_reg009 i_tmp275_alert [ 1-1:0]
    .i_ocp_da_trig                  (ocp_da_trig_i      ),// input slv_reg009 i_ocp_da_trig [ 1-1:0]
    .i_cv_limit_switch              (cv_limit_switch_i  ),// input slv_reg009 i_cv_limit_switch [ 1-1:0]
    .i_out_dip_switch               (out_dip_switch_i   ),// input slv_reg009 i_out_dip_switch [ 3-1:0]
    .i_dip_switch                   (dip_switch_i       ),// input slv_reg009 i_dip_switch [ 4-1:0]
    .i_fault_pan                    (fault_pan_i        ) // input slv_reg009 i_fault_pan [ 8-1:0]
);


s_axi_lite2ram_interface#(
    .C_S_AXI_DATA_WIDTH             (C_S_AXI_DATA_WIDTH ),
    .C_S_AXI_ADDR_WIDTH             (C_S_AXI_ADDR_WIDTH ) 
)
u_s_axi_lite2ram_interface(
//-------------------------customrize---------------------------//
    .ram_wr_en_o                    (ram_wr_en          ),// output ram write enable
    .ram_wr_addr_o                  (ram_wr_addr        ),// output ram write address
    .ram_wr_wstrb_o                 (ram_wr_wstrb       ),// output ram write strobe
    .ram_wr_data_o                  (ram_wr_data        ),// output ram write data
    .ram_rd_en_o                    (ram_rd_en          ),// output ram read enable
    .ram_rd_addr_o                  (ram_rd_addr        ),// output ram read address
    .ram_rd_data_i                  (ram_rd_data        ),// input ram read data
//-----------------------axi lite interface---------------------//
    .S_AXI_ACLK                     (S_AXI_ACLK         ),// Global Clock Signal
    .S_AXI_ARESETN                  (S_AXI_ARESETN      ),// Global Reset Signal. This Signal is Active LOW
    .S_AXI_AWADDR                   (S_AXI_AWADDR       ),// Write address (issued by master, acceped by Slave)
    .S_AXI_AWPROT                   (S_AXI_AWPROT       ),// Write channel Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
    .S_AXI_AWVALID                  (S_AXI_AWVALID      ),// Write address valid. This signal indicates that the master signaling valid write address and control information.
    .S_AXI_AWREADY                  (S_AXI_AWREADY      ),// Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    .S_AXI_WDATA                    (S_AXI_WDATA        ),// Write data (issued by master, acceped by Slave)
    .S_AXI_WSTRB                    (S_AXI_WSTRB        ),// Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
    .S_AXI_WVALID                   (S_AXI_WVALID       ),// Write valid. This signal indicates that valid write  data and strobes are available.
    .S_AXI_WREADY                   (S_AXI_WREADY       ),// Write ready. This signal indicates that the slave  can accept the write data.
    .S_AXI_BRESP                    (S_AXI_BRESP        ),// Write response. This signal indicates the status of the write transaction.
    .S_AXI_BVALID                   (S_AXI_BVALID       ),// Write response valid. This signal indicates that the channel is signaling a valid write response.
    .S_AXI_BREADY                   (S_AXI_BREADY       ),// Response ready. This signal indicates that the master can accept a write response.
    .S_AXI_ARADDR                   (S_AXI_ARADDR       ),// Read address (issued by master, acceped by Slave)
    .S_AXI_ARPROT                   (S_AXI_ARPROT       ),// Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
    .S_AXI_ARVALID                  (S_AXI_ARVALID      ),// Read address valid. This signal indicates that the channel is signaling valid read address and control information.
    .S_AXI_ARREADY                  (S_AXI_ARREADY      ),// Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    .S_AXI_RDATA                    (S_AXI_RDATA        ),// Read data (issued by slave)
    .S_AXI_RRESP                    (S_AXI_RRESP        ),// Read response. This signal indicates the status of the read transfer.
    .S_AXI_RVALID                   (S_AXI_RVALID       ),// Read valid. This signal indicates that the channel is signaling the required read data.
    .S_AXI_RREADY                   (S_AXI_RREADY       ) // Read ready. This signal indicates that the master can accept the read data and response information.
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// ADS131M08
//---------------------------------------------------------------------





endmodule


`default_nettype wire
