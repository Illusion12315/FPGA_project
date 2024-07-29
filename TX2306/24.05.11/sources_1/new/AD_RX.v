`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/20 18:14:47
// Design Name: 
// Module Name: AD_RX
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


module AD_RX(
    //demod in for rx     
//    input           adc_dco_a ,
//    input           adc_dco_b ,
   input  [13:0]    sub_value,

    input  [13:0]   adc_d_a   ,
    input  [13:0]   adc_d_b   ,
    input           adc_or_a  ,
    input           adc_or_b  ,
    
    
    input wire          adc_clk100m,
    input wire          adc_clk_b,
    input wire          ad_clk163m84,
    input wire          ad_clk81m92,
    input wire          ad_rst_n,
    
    output wire [13:0]   ad_data_i,
    output wire [13:0]   ad_data_q,
    output  wire         ad_data_valid
    );
    
//    wire           adc_clk100m;
//    wire           adc_clk_b;
//    wire           ad_clk81m92;
//    wire           ad_clk163m84;
//    wire           ad_rst_n;  
    
    wire [13:0]    adc_data_a;
    wire [13:0]    adc_data_b;
    
    
// ADclk ADclk_inst(
//       .adc_dco_a           (adc_dco_a),
//       .adc_dco_b           (adc_dco_b),
       
//       .adc_clk100m         (adc_clk100m),
//       .adc_clk_b           (adc_clk_b),
       
//       .ad_clk81m92         (ad_clk81m92),
//       .ad_clk163m84        (ad_clk163m84),
//       .ad_rst_n            (ad_rst_n)
//     );
     
AD_data AD_data_inst(
        .adc_clk100m        (adc_clk100m),
        .adc_clk_b          (adc_clk_b),
     
        .adc_d_a            (adc_d_a ),
        .adc_d_b            (adc_d_b ),
        .adc_or_a           (adc_or_a),
        .adc_or_b           (adc_or_b),
         
        .adc_data_a         (adc_data_a),
        .adc_data_b         (adc_data_b)
         
         );
 AD_SyncData AD_SyncData_inst(
            .sub_value              (sub_value),
            .ad_rst_n               (ad_rst_n),
            
            .adc_clk100m            (adc_clk100m),
            .adc_clk_b              (adc_clk_b  ),
            .adc_data_a             (adc_data_a ),
            .adc_data_b             (adc_data_b ),
            
            .ad_data_i          (ad_data_i),
            .ad_data_q          (ad_data_q),
            .ad_data_valid      (ad_data_valid)
   );
   


  
endmodule
