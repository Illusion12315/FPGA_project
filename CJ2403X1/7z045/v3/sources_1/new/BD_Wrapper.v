`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 15:09:38
// Design Name: 
// Module Name: BD_Wrapper
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


module BD_Wrapper(
    output                              RESETN                      ,
    output                              FCLK_CLK0_0                 , 
        
    output    [31:0]                    o_gpio_en                   ,
    input                               i_ps_read_test              ,

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
    inout                               FIXED_IO_0_ddr_vrn          ,
    inout                               FIXED_IO_0_ddr_vrp          ,
    inout [53:0]                        FIXED_IO_0_mio              ,
    inout                               FIXED_IO_0_ps_clk           ,
    inout                               FIXED_IO_0_ps_porb          , 
    inout                               FIXED_IO_0_ps_srstb         ,
    
    output [127:0]                      M_AXIS_MM2S_0_tdata         ,
    output [15 :0]                      M_AXIS_MM2S_0_tkeep         ,
    output                              M_AXIS_MM2S_0_tlast         ,
    input                               M_AXIS_MM2S_0_tready        ,
    output                              M_AXIS_MM2S_0_tvalid        ,
    
    input [31:0]                        S_AXIS_S2MM_0_tdata         ,
    input [3 :0]                        S_AXIS_S2MM_0_tkeep         ,
    input                               S_AXIS_S2MM_0_tlast         ,
    output                              S_AXIS_S2MM_0_tready        ,
    input                               S_AXIS_S2MM_0_tvalid        
   
    
    );
    
//  wire  [0: 0]                          RESETN                      ;
  wire  [31:0]                          S_AXI_RDATA_ext_0           ;
  wire  [31:0]                          S_AXI_WDATA_ext_0           ;
  wire  [31:0]                          axi_araddr_0                ;
  wire  [31:0]                          axi_awaddr_0                ;
  wire                                  slv_reg_rden_0              ;
  wire                                  slv_reg_wren_0              ;
//  wire                                  FCLK_CLK0_0                 ;
 
 
 design_1_wrapper design_1_wrapper_inst
   (
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
    .FCLK_CLK0_0                    (FCLK_CLK0_0          ),
    .FIXED_IO_0_ddr_vrn             (FIXED_IO_0_ddr_vrn   ),
    .FIXED_IO_0_ddr_vrp             (FIXED_IO_0_ddr_vrp   ),
    .FIXED_IO_0_mio                 (FIXED_IO_0_mio       ),
    .FIXED_IO_0_ps_clk              (FIXED_IO_0_ps_clk    ),
    .FIXED_IO_0_ps_porb             (FIXED_IO_0_ps_porb   ),
    .FIXED_IO_0_ps_srstb            (FIXED_IO_0_ps_srstb  ),
    .RESETN                         (RESETN               ),
    .S_AXI_RDATA_ext_0              (S_AXI_RDATA_ext_0    ),
    .S_AXI_WDATA_ext_0              (S_AXI_WDATA_ext_0    ),
    .axi_araddr_0                   (axi_araddr_0         ),
    .axi_awaddr_0                   (axi_awaddr_0         ),
    .slv_reg_rden_0                 (slv_reg_rden_0       ),
    .slv_reg_wren_0                 (slv_reg_wren_0       ),
    
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
    
    
    
  
    axi_param_ctrl axi_param_0(
         .axiclk                     ( FCLK_CLK0_0 ),
         .rst_n                      ( RESETN ),
         // axi interfac
         .S_AXI_WDATA_ext            ( S_AXI_WDATA_ext_0 ),
         .axi_araddr                 ( axi_araddr_0 ),
         .axi_awaddr                 ( axi_awaddr_0 ),
         .S_AXI_RDATA_ext            ( S_AXI_RDATA_ext_0 ),
         .slv_reg_rden               ( slv_reg_rden_0 ),
         .slv_reg_wren               ( slv_reg_wren_0 ),
         // parameter interface
         // hp ports
         .o_hp_sw_rst_n              ( ),
         
         .o_SyncPulse               (),
         .o_GPIO_en                 (o_gpio_en),
         .o_DMA_len                 (),

         .i_S_AXIS_tlast            (i_ps_read_test)
   

    );  
endmodule
