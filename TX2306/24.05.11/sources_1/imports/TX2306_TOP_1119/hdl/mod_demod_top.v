`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2023 15:34:22 
// Design Name: 
// Module Name: demod_new_top
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

module mod_demod_top(
    clk_100_p          ,
    clk_100_n          ,
	
    adc_dco_a        ,
    adc_dco_b        ,
    adc_d_a          ,
    adc_d_b          ,
    adc_or_a         ,
    adc_or_b         ,

    dac_clk_a        ,
    dac_clk_b        ,
    dac_dat_i        ,
    dac_dat_q        ,
    dac_wrta         ,
    dac_wrtb         ,
    
    clk_to_pins_p    ,
    clk_to_pins_n    ,
    dat_out_p        ,
    dat_out_n        ,
    dat_vld_o        ,

    clk_in_p         ,
    clk_in_n         ,
    dat_in_p         ,
    dat_in_n         ,
    dat_vld_in       ,
      //---------------hp spi
     sclk_spi_hp,
     cs_spi_hp,
     sdo_spi_hp    ,
	 
    BCTRL_RX_CLK    ,
    BCTRL_RX_DATA   ,
    BCTRL_RX_EN         ,
    
    BCTRL_TX_CLK    ,
    BCTRL_TX_DATA   ,
    BCTRL_TX_EN
);
//-----------------------------------input--------------------------------------// 
    input                               clk_100_p                  ;
    input                               clk_100_n                  ;
//lvds in  for tx	—�?�lvds only bit0 is used
    input                               clk_in_p                   ;
    input                               clk_in_n                   ;
    input              [   3:0]         dat_in_p                   ;
    input              [   3:0]         dat_in_n                   ;
    input                               dat_vld_in                 ;
//demod in for rx
    input                               adc_dco_a                  ;
    input                               adc_dco_b                  ;
    input              [  13:0]         adc_d_a                    ;
    input              [  13:0]         adc_d_b                    ;
    input                               adc_or_a                   ;
    input                               adc_or_b                   ;
//----------------------------------output--------------------------------------//
//mod out  for tx
    output                              dac_clk_a                  ;
    output                              dac_clk_b                  ;
    output             [  11:0]         dac_dat_i                  ;
    output             [  11:0]         dac_dat_q                  ;
    output                              dac_wrta                   ;
    output                              dac_wrtb                   ;
//lvds out  for rx	—�?�lvds only bit0 is used
    output                              clk_to_pins_p              ;
    output                              clk_to_pins_n              ;
    output             [   3:0]         dat_out_p                  ;
    output             [   3:0]         dat_out_n                  ;
    output                              dat_vld_o                  ;

//-------hp spi
    output                              sclk_spi_hp                ;
    output                              cs_spi_hp                  ;
    output                              sdo_spi_hp                 ;
	
	
    input                               BCTRL_RX_CLK               ;
    input                               BCTRL_RX_DATA              ;
    input                               BCTRL_RX_EN                ;

    output                              BCTRL_TX_CLK               ;
    output                              BCTRL_TX_DATA              ;
    output                              BCTRL_TX_EN                ;

//---------------------------------reg&wire-------------------------------------//
//wire                      da_clk_100m;
//wire                      da_clk81m92;
//wire                      da_clk163m84;
//wire                      da_rst_n;
wire                                    sys_clk100m                ;
wire                                    sys_clk20m                 ;
wire                                    sys_rstn                   ;

 
 clk_rst_wrapper clk_rst_wrapper_inst(
    .clk_100_p                         (clk_100_p                 ),
    .clk_100_n                         (clk_100_n                 ),
   
    .sys_clk100m                       (sys_clk100m               ),
    .sys_clk20m                        (sys_clk20m                ),
    .sys_rstn                          (sys_rstn                  ) 
   
//   .da_clk_100m         (da_clk_100m ),
//   .da_clk81m92        (da_clk81m92 ),
//   .da_clk163m84       (da_clk163m84),
//   .da_rst_n            (da_rst_n)
   );

kq_mod_demod_top u_kq_mod_demod_top(
    .sys_clk100m                       (sys_clk100m               ),
    .sys_clk20m                        (sys_clk20m                ),
    .sys_rstn                          (sys_rstn                  ),
//       .da_clk163m84             (da_clk163m84      ),
//       .da_clk_100m              (da_clk_100m),
//       .da_rst_n                 (da_rst_n        ),
       //.rst_n                  (rst_lvds ),
       //lvds in  for tx         
    .clk_in_p                          (clk_in_p                  ),
    .clk_in_n                          (clk_in_n                  ),
    .dat_in_p                          (dat_in_p                  ),
    .dat_in_n                          (dat_in_n                  ),
    .dat_vld_in                        (dat_vld_in                ),
       //demod in for rx
    .adc_dco_a                         (adc_dco_a                 ),
    .adc_dco_b                         (adc_dco_b                 ),
    .adc_d_a                           (adc_d_a                   ),
    .adc_d_b                           (adc_d_b                   ),
    .adc_or_a                          (adc_or_a                  ),
    .adc_or_b                          (adc_or_b                  ),
       //mod out  for tx
    .dac_clk_a                         (dac_clk_a                 ),
    .dac_clk_b                         (dac_clk_b                 ),
    .dac_dat_i_rr                      (dac_dat_i                 ),
    .dac_dat_q_rr                      (dac_dat_q                 ),
    .dac_wrta                          (dac_wrta                  ),
    .dac_wrtb                          (dac_wrtb                  ),
       //lvds out  for rx
    .clk_to_pins_p                     (clk_to_pins_p             ),
    .clk_to_pins_n                     (clk_to_pins_n             ),
    .dat_out_p                         (dat_out_p                 ),
    .dat_out_n                         (dat_out_n                 ),
    .dat_vld_o                         (dat_vld_o                 ),
  //------hp spi    
    .sclk_spi_hp                       (sclk_spi_hp               ),
    .cs_spi_hp                         (cs_spi_hp                 ),
    .sdo_spi_hp                        (sdo_spi_hp                ),

    .BCTRL_RX_CLK                      (BCTRL_RX_CLK              ),
    .BCTRL_RX_DATA                     (BCTRL_RX_DATA             ),
    .BCTRL_RX_EN                       (BCTRL_RX_EN               ),
  
    .BCTRL_TX_CLK                      (BCTRL_TX_CLK              ),
    .BCTRL_TX_DATA                     (BCTRL_TX_DATA             ),
    .BCTRL_TX_EN                       (BCTRL_TX_EN               ) 
);


endmodule

