`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/19 13:36:32
// Design Name: 
// Module Name: spi_top
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


module spi_top(
    //global clock
    input       clock, //163.84M
    input       rst_n,
    
   // spi interfaec
    input      spi_cs,
    input      spi_sclk,
    input      spi_mosi,
    output     spi_miso,
    
    //user interface
   output [31:0]     down_freq,
   output [31:0]     up_freq,
   output [31:0]     up_step_freq,
   output [31:0]     down_step_freq,
   output [31:0]     kq_demodule_sig,
   output [31:0]     kq_module_sig,
   output [31:0]     demod_bias_init_value,
   output [31:0]     mod_bias_init_value,
   output [46:0]     init_tod_in,
   output [31:0]     satel_ground_delay,
   output [27:0]     address_data,
   output [31:0]    ls_sync_shixi0, 
   output [31:0]    ls_sync_shixi1, 
   output [31:0]    ls_sync_shixi2, 
   output [31:0]    ls_sync_shixi3, 
   output [31:0]    ls_sync_shixi4, 
   output [31:0]    ls_sync_shixi5, 
   output [31:0]    ls_sync_shixi6, 
   output [31:0]    ls_sync_shixi7, 
   output [31:0]    ls_sync_shixi8, 
   output [31:0]    ls_sync_shixi9, 
   output [31:0]    ls_sync_shixi10,
   output [31:0]    ls_sync_shixi11,
   output [31:0]    ls_sync_shixi12,
   output [31:0]    ls_sync_shixi13,
   output [31:0]    ls_sync_shixi14,
   output [31:0]    ls_sync_shixi15,
   output [31:0]    ls_yw_shixi0 ,   
   output [31:0]    ls_yw_shixi1 ,   
   output [31:0]    ls_yw_shixi2 ,   
   output [31:0]    ls_yw_shixi3 ,   
   output [31:0]    ls_yw_shixi4 ,   
   output [31:0]    ls_yw_shixi5 ,   
   output [31:0]    ls_yw_shixi6 ,   
   output [31:0]    ls_yw_shixi7 ,   
   output [31:0]    ls_ctr_shixi0,   
   output [31:0]    ls_ctr_shixi1,   
   output [31:0]    ls_ctr_shixi2,   
   output [31:0]    ls_ctr_shixi3,   
   output [31:0]    ls_ctr_shixi4,   
   output [31:0]    ls_ctr_shixi5,   
   output [31:0]    ls_ctr_shixi6,   
   output [31:0]    ls_ctr_shixi7,   
   output [31:0]    ms_sync_shixi,   
   output [31:0]    ms_gdctr_shixi,  
   output [31:0]    ms_ctroryw_shixi,
   output [31:0]    soft_rstn ,   
   output [31:0]    kd_module_reg,
   output [31:0]    kd_satel_ground_delay_reg,
   output [31:0]    kd_coar_sync_reg,
   output [31:0]    kd_fine_sync_reg

    
    );
    
//wire      spi_cs;
//wire      spi_sclk;
//wire      spi_mosi;
//wire      spi_miso  ; 

 wire    spi_cs_r3;
 wire    spi_sck_r3;
 wire    spi_mosi_r3;
  
 
// wire  clk163m8;
// wire  clk100m;
// wire  locked;
 
// wire   finish;
 
  wire             txd_flag;
  wire            rxd_flag;
  wire [63:0]      rxd_data;
    
    
//  clk_pll clk_pll_inst
//   (
//    // Clock out ports
//    .clk_out1(clk163m8),     // output clk_out1
//    .clk_out2(clk100m),     // output clk_out2
//    // Status and control signals
//    .reset(1'b0), // input reset
//    .locked(locked),       // output locked
//   // Clock in ports
//    .clk_in1(clock));      // input clk_in1 
    
//sim_spi sim_spi_inst(                   //3-wire spi     addr 13bit   data 8bit
//    .clk                    (clk100m),
//    .rst_n                  (locked),

//   .sclk                    (spi_sclk),
//   .mosi                    (spi_mosi),
//   .csb                     (spi_cs),


//   .finish                  (finish)

//);    
 wire      spi_wr_en;
 wire       spi_rd_en;   

spi_ctrl spi_ctrl_inst(
    .clk                (clock),
    .rst_n              (rst_n),
    
    //spi interface
    .spi_cs             (spi_cs),//chip select enable,default：L
    .spi_sck            (spi_sclk), //Data transfer clock
    .spi_mosi           (spi_mosi),//Master output and slaver input
    
    .rxd_flag           (rxd_flag),
    .txd_flag           (txd_flag),
    
    .spi_cs_r3          (spi_cs_r3  ),
    .spi_sck_r3         (spi_sck_r3 ),
    .spi_mosi_r3        (spi_mosi_r3),
    
    .spi_wr_en_r          (spi_wr_en),
    .spi_rd_en_r          (spi_rd_en)
    );
    

    

    spi_receiver u_spi_receiver(
        //global clock
       .clk             (clock),
        .rst_n          (rst_n),
        
        //spi interface
        .spi_wr_en      (spi_wr_en),
        .spi_cs          (spi_cs_r3),//chip select enable,default：L
        .spi_sck         (spi_sck_r3), //Data transfer clock
        .spi_mosi        (spi_mosi_r3),//Master output and slaver input
      //output          spi_miso,//Master input and slaver output
      //inout          spi_miso,//三线制用inout
       
       //user interface
       .rxd_flag        (rxd_flag),
       .rxd_data        (rxd_data)
        );
    
    
    spi_transfer u_spi_transfer(
        //global clock
        .clk        (clock),
        .rst_n      (rst_n),
        
        //spi interface
        .spi_rd_en  (spi_rd_en),
        .spi_cs     (spi_cs_r3),//Chip select enable,default:1
        .spi_sck    (spi_sck_r3),//Data transfer clock
        //input     spi_miso,//Master output and slave input
        .spi_miso   (spi_miso),//Master input and slave  output
        
        //user interface
        .txd_en     ( rxd_flag),//transfer enable
        .txd_data   (rxd_data),//transfer data
        
        .txd_flag   (txd_flag)//transfer complete signal
        );
        
  spi_reg spi_reg_inst(
    .clk                (clock),
    .rst_n              (rst_n),
    
       //user interface
   .rxd_flag            (rxd_flag),
   .rxd_data            (rxd_data),
   
   . down_freq            (down_freq            ),
   . up_freq              (up_freq              ),
   . up_step_freq         (up_step_freq         ),
   . down_step_freq       (down_step_freq       ),
   . kq_demodule_sig      (kq_demodule_sig      ),
   . kq_module_sig        (kq_module_sig        ),
   . demod_bias_init_value(demod_bias_init_value),
   . mod_bias_init_value  (mod_bias_init_value  ),
   . init_tod_in          (init_tod_in          ),
   . satel_ground_delay   (satel_ground_delay   ),
   . address_data         ( address_data  ),
   .ls_sync_shixi0        (ls_sync_shixi0 ), 
   .ls_sync_shixi1        (ls_sync_shixi1 ), 
   .ls_sync_shixi2        (ls_sync_shixi2 ), 
   .ls_sync_shixi3        (ls_sync_shixi3 ), 
   .ls_sync_shixi4        (ls_sync_shixi4 ), 
   .ls_sync_shixi5        (ls_sync_shixi5 ), 
   .ls_sync_shixi6        (ls_sync_shixi6 ), 
   .ls_sync_shixi7        (ls_sync_shixi7 ), 
   .ls_sync_shixi8        (ls_sync_shixi8 ), 
   .ls_sync_shixi9        (ls_sync_shixi9 ), 
   .ls_sync_shixi10       (ls_sync_shixi10),
   .ls_sync_shixi11       (ls_sync_shixi11),
   .ls_sync_shixi12       (ls_sync_shixi12),
   .ls_sync_shixi13       (ls_sync_shixi13),
   .ls_sync_shixi14       (ls_sync_shixi14),
   .ls_sync_shixi15       (ls_sync_shixi15),
   .ls_yw_shixi0          (ls_yw_shixi0  ),   
   .ls_yw_shixi1          (ls_yw_shixi1  ),   
   .ls_yw_shixi2          (ls_yw_shixi2  ),   
   .ls_yw_shixi3          (ls_yw_shixi3  ),   
   .ls_yw_shixi4          (ls_yw_shixi4  ),   
   .ls_yw_shixi5          (ls_yw_shixi5  ),   
   .ls_yw_shixi6          (ls_yw_shixi6  ),   
   .ls_yw_shixi7          (ls_yw_shixi7  ),   
   .ls_ctr_shixi0         (ls_ctr_shixi0 ),   
   .ls_ctr_shixi1         (ls_ctr_shixi1 ),   
   .ls_ctr_shixi2         (ls_ctr_shixi2 ),   
   .ls_ctr_shixi3         (ls_ctr_shixi3 ),   
   .ls_ctr_shixi4         (ls_ctr_shixi4 ),   
   .ls_ctr_shixi5         (ls_ctr_shixi5 ),   
   .ls_ctr_shixi6         (ls_ctr_shixi6 ),   
   .ls_ctr_shixi7         (ls_ctr_shixi7 ),   
   .ms_sync_shixi         (ms_sync_shixi   ),   
   .ms_gdctr_shixi        (ms_gdctr_shixi  ),  
   .ms_ctroryw_shixi      (ms_ctroryw_shixi),
   .soft_rstn             (soft_rstn       ),   
   .kd_module_reg         (kd_module_reg   ),
   .kd_satel_ground_delay_reg(kd_satel_ground_delay_reg),
   .kd_coar_sync_reg      (kd_coar_sync_reg),
   .kd_fine_sync_reg      (kd_fine_sync_reg)
    );
endmodule
