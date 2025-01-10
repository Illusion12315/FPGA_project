`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             key_fan_ctrl_wrapper.v
// Create Date:           2025/01/02 14:37:16
// Version:               V1.0
// PATH:                  srcs\rtl\key_fan_ctrl_wrapper\key_fan_ctrl_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module key_fan_ctrl_wrapper #(
    parameter                       C_S_AXI_DATA_WIDTH = 32    ,
    parameter                       C_S_AXI_ADDR_WIDTH = 12     
) (
    // Users to add ports here
    output wire                     poc_pwm1_o          ,
    output wire                     poc_pwm2_o          ,

    input  wire                     pic_pwm1_i          ,
    input  wire                     pic_pwm2_i          ,
    input  wire                     pic_pwm3_i          ,
    input  wire                     pic_pwm4_i          ,
    input  wire                     pic_pwm5_i          ,
    input  wire                     pic_pwm6_i          ,
    input  wire                     pic_pwm7_i          ,
    input  wire                     pic_pwm8_i          ,
    //spi keyboard
    output wire                     spi_dout            ,
    input  wire                     spi_din             ,
    output wire                     spi_ss              ,
    output wire                     spi_sck             ,
    output wire                     key_rst             ,
		
    input  wire                     key_int             ,
    output wire                     o_key_intr          ,
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

    wire                            avs_write           ;
    wire                            avs_read            ;
    wire               [ 2-1: 0]    avs_address         ;
    wire                            pwm1_ch_en          ;
    wire                            pwm2_ch_en          ;
    wire                            pwm3_ch_en          ;
    wire                            pwm4_ch_en          ;
    wire                            pwm5_ch_en          ;
    wire               [32-1: 0]    avs_writedata       ;
    wire                            start               ;
    wire                            read_data_flag      ;
    wire                            write_data_flag     ;
    wire                            mlb                 ;
    wire               [ 2-1: 0]    cdiv                ;
    wire               [ 8-1: 0]    keyboard_cmd        ;
    wire               [ 8-1: 0]    keyboard_txd        ;
    wire                            read_status         ;

    wire                            done                ;
    wire               [   7: 0]    rdata               ;

    wire               [   1: 0]    avs_address1        ;
    wire                            avs_write1          ;
    wire               [  31: 0]    avs_writedata1      ;
    wire                            avs_read1           ;
    wire               [  31: 0]    avs_readdata1       ;
    wire               [  31: 0]    pwm1_total_num      ;
    wire               [  31: 0]    pwm1_high_num       ;
    wire                            pwm1_total_read     ;
    wire                            pwm1_high_read      ;

    wire               [   1: 0]    avs_address2        ;
    wire                            avs_write2          ;
    wire               [  31: 0]    avs_writedata2      ;
    wire                            avs_read2           ;
    wire               [  31: 0]    avs_readdata2       ;
    wire               [  31: 0]    pwm2_total_num      ;
    wire               [  31: 0]    pwm2_high_num       ;
    wire                            pwm2_total_read     ;
    wire                            pwm2_high_read      ;

key_and_fan_reg_map_cfg u_key_and_fan_reg_map_cfg(
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
    .pwm5_ch_en                     (pwm5_ch_en         ),// output slv_reg000 pwm5_ch_en [ 1-1:0]
    .pwm4_ch_en                     (pwm4_ch_en         ),// output slv_reg000 pwm4_ch_en [ 1-1:0]
    .pwm3_ch_en                     (pwm3_ch_en         ),// output slv_reg000 pwm3_ch_en [ 1-1:0]
    .pwm2_ch_en                     (pwm2_ch_en         ),// output slv_reg000 pwm2_ch_en [ 1-1:0]
    .pwm1_ch_en                     (pwm1_ch_en         ),// output slv_reg000 pwm1_ch_en [ 1-1:0]
    .avs_address                    (avs_address        ),// output slv_reg000 avs_address [ 2-1:0]
    .avs_read                       (avs_read           ),// output slv_reg000 avs_read [ 1-1:0]
    .avs_write                      (avs_write          ),// output slv_reg000 avs_write [ 1-1:0]
    .avs_writedata                  (avs_writedata      ),// output slv_reg001 avs_writedata [32-1:0]
    .cdiv                           (cdiv               ),// output slv_reg002 cdiv [ 2-1:0]
    .mlb                            (mlb                ),// output slv_reg002 mlb [ 1-1:0]
    .write_data_flag                (write_data_flag    ),// output slv_reg002 write_data_flag [ 1-1:0]
    .read_data_flag                 (read_data_flag     ),// output slv_reg002 read_data_flag [ 1-1:0]
    .key_rst                        (key_rst            ),// output slv_reg002 key_rst [ 1-1:0]
    .start                          (start              ),// output slv_reg002 start [ 1-1:0]
    .rd_reg002                      (1                  ),// input slv_reg002 rd_reg002 [ 4-1:0]
    .keyboard_cmd                   (keyboard_cmd       ),// output slv_reg003 keyboard_cmd [ 8-1:0]
    .rd_reg003                      (0                  ),// input slv_reg003 rd_reg003 [ 8-1:0]
    .keyboard_txd                   (keyboard_txd       ),// output slv_reg004 keyboard_txd [ 8-1:0]
    .rd_reg004                      (2                  ),// input slv_reg004 rd_reg004 [ 8-1:0]
    .rdata                          (rdata              ),// input slv_reg005 rdata [32-1:0]
    .read_status                    (read_status        ),// output slv_reg006 read_status [ 1-1:0]
    .done                           (done               ),// input slv_reg006 done [ 1-1:0]
    .pwm1_total_num                 (pwm1_total_num     ),// input slv_reg007 pwm1_total_num [32-1:0]
    .pwm1_high_num                  (pwm1_high_num      ),// input slv_reg008 pwm1_high_num [32-1:0]
    .pwm2_total_num                 (pwm2_total_num     ),// input slv_reg009 pwm2_total_num [32-1:0]
    .pwm2_high_num                  (pwm2_high_num      ),// input slv_reg00a pwm2_high_num [32-1:0]
    .pwm3_total_num                 (                   ),// input slv_reg00b pwm3_total_num [32-1:0]
    .pwm3_high_num                  (                   ),// input slv_reg00c pwm3_high_num [32-1:0]
    .pwm4_total_num                 (                   ),// input slv_reg00d pwm4_total_num [32-1:0]
    .pwm4_high_num                  (                   ),// input slv_reg00e pwm4_high_num [32-1:0]
    .pwm5_total_num                 (                   ),// input slv_reg00f pwm5_total_num [32-1:0]
    .pwm5_high_num                  (                   ),// input slv_reg010 pwm5_high_num [32-1:0]
    .pic_pwm8                       (pic_pwm8_i         ),// input slv_reg011 pic_pwm8 [ 1-1:0]
    .pic_pwm7                       (pic_pwm7_i         ),// input slv_reg011 pic_pwm7 [ 1-1:0]
    .pic_pwm6                       (pic_pwm6_i         ),// input slv_reg011 pic_pwm6 [ 1-1:0]
    .pic_pwm5                       (pic_pwm5_i         ),// input slv_reg011 pic_pwm5 [ 1-1:0]
    .pic_pwm4                       (pic_pwm4_i         ),// input slv_reg011 pic_pwm4 [ 1-1:0]
    .pic_pwm3                       (pic_pwm3_i         ),// input slv_reg011 pic_pwm3 [ 1-1:0]
    .pic_pwm2                       (pic_pwm2_i         ),// input slv_reg011 pic_pwm2 [ 1-1:0]
    .pic_pwm1                       (pic_pwm1_i         ) // input slv_reg011 pic_pwm1 [ 1-1:0]
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
// fan control
//---------------------------------------------------------------------
    assign                          avs_address1       = pwm1_ch_en? avs_address : 2'b0;
    assign                          avs_write1         = pwm1_ch_en? avs_write : 0;
    assign                          avs_writedata1     = pwm1_ch_en? avs_writedata : 32'b0;
    assign                          avs_read1          = pwm1_ch_en? avs_read : 0;

    assign                          avs_address2       = pwm2_ch_en? avs_address : 2'b0;
    assign                          avs_write2         = pwm2_ch_en? avs_write : 0;
    assign                          avs_writedata2     = pwm2_ch_en? avs_writedata : 32'b0;
    assign                          avs_read2          = pwm2_ch_en? avs_read : 0;

    assign                          pwm1_total_read    = (ram_rd_addr[C_S_AXI_ADDR_WIDTH-1:2] == 5'h7);
    assign                          pwm1_high_read     = (ram_rd_addr[C_S_AXI_ADDR_WIDTH-1:2] == 5'h8);
	
    assign                          pwm2_total_read    = (ram_rd_addr[C_S_AXI_ADDR_WIDTH-1:2] == 5'h9);
    assign                          pwm2_high_read     = (ram_rd_addr[C_S_AXI_ADDR_WIDTH-1:2] == 5'ha);

fan_pwm u_fan_pwm1(
    .csi_clk                        (S_AXI_ACLK         ),
    .csi_reset                      (~S_AXI_ARESETN     ),
    .avs_address                    (avs_address1       ),
    .avs_read                       (avs_read1          ),
    .avs_readdata                   (avs_readdata1      ),
    .avs_write                      (avs_write1         ),
    .avs_writedata                  (avs_writedata1     ),
    .cpu_total_read_valid           (pwm1_total_read    ),
    .cpu_high_read_valid            (pwm1_high_read     ),
    .poc_pwm_total_num              (pwm1_total_num     ),
    .poc_pwm_high_num               (pwm1_high_num      ),
    .pwm_in                         (pic_pwm1_i         ),
    .coe_pwm_out                    (poc_pwm1_o         ) 
);

fan_pwm u_fan_pwm2(
    .csi_clk                        (S_AXI_ACLK         ),
    .csi_reset                      (~S_AXI_ARESETN     ),
    .avs_address                    (avs_address2       ),
    .avs_read                       (avs_read2          ),
    .avs_readdata                   (avs_readdata2      ),
    .avs_write                      (avs_write2         ),
    .avs_writedata                  (avs_writedata2     ),
    .cpu_total_read_valid           (pwm2_total_read    ),
    .cpu_high_read_valid            (pwm2_high_read     ),
    .poc_pwm_total_num              (pwm2_total_num     ),
    .poc_pwm_high_num               (pwm2_high_num      ),
    .pwm_in                         (pic_pwm2_i         ),
    .coe_pwm_out                    (poc_pwm2_o         ) 
);

spi_master_keyboard u_spi_master_keyboard (
    .clk                            (S_AXI_ACLK         ),
    .rstb                           (S_AXI_ARESETN      ),
        
    .mlb                            (mlb                ),
    .start                          (start              ),
    .keyboard_cmd                   (keyboard_cmd       ),
    .keyboard_txd                   (keyboard_txd       ),
    .cdiv                           (cdiv               ),
    .write_data_flag                (write_data_flag    ),
    .read_data_flag                 (read_data_flag     ),
    .read_status                    (read_status        ),
    .done                           (done               ),
    .rdata                          (rdata              ),
        
    .ss                             (spi_ss             ),
    .sck                            (spi_sck            ),
    .dout                           (spi_dout           ),
    .din                            (spi_din            ),
        
    .inout_sel                      (                   ) 
);

    assign                          o_key_intr         = key_int;


endmodule


`default_nettype wire
