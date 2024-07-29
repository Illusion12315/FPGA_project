`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/20 21:23:52
// Design Name: 
// Module Name: AD_data
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


module AD_data(
   input                adc_clk100m,
   input                adc_clk_b,

   input  [13:0]       adc_d_a   ,
   input  [13:0]       adc_d_b   ,
   input               adc_or_a  ,
   input               adc_or_b  ,
    
   output [13:0]       adc_data_a,
   output [13:0]       adc_data_b
    
    );
    wire           adc_or_aa;
    wire           adc_or_bb;   
    
    
    IBUF #(
         .IBUF_LOW_PWR("TRUE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
         .IOSTANDARD("DEFAULT")  // Specify the input I/O standard
      ) IBUF_validA (
         .O(adc_or_aa),     // Buffer output
         .I(adc_or_a)      // Buffer input (connect directly to top-level port)
      );
    
      IBUF #(
          .IBUF_LOW_PWR("TRUE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
          .IOSTANDARD("DEFAULT")  // Specify the input I/O standard
       ) IBUF_validB (
          .O(adc_or_bb),     // Buffer output
          .I(adc_or_b)      // Buffer input (connect directly to top-level port)
       );
     
  generate 
     genvar i;
     for(i=0;i <14;i=i+1)
     begin
         IBUF #(
         .IBUF_LOW_PWR("TRUE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
         .IOSTANDARD("DEFAULT")  // Specify the input I/O standard
      ) IBUF_dataA (
         .O(adc_data_a[i]),     // Buffer output
         .I(adc_d_a[i])      // Buffer input (connect directly to top-level port)
      );
     end
  
  endgenerate 
  
   generate 
     genvar j;
     for(j=0;j <14;j=j+1)
     begin
         IBUF #(
         .IBUF_LOW_PWR("TRUE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
         .IOSTANDARD("DEFAULT")  // Specify the input I/O standard
      ) IBUF_dataB (
         .O(adc_data_b[j]),     // Buffer output
         .I(adc_d_b[j])      // Buffer input (connect directly to top-level port)
      );
     end
  
  endgenerate 
   
  
  
//  ila_ad ila_adA (
//      .clk(adc_clk100m), // input wire clk
  
  
//      .probe0(adc_data_a), // input wire [13:0]  probe0  
//      .probe1(adc_or_aa) // input wire [0:0]  probe1
//  );
   
//  ila_ad ila_adB (
//      .clk(adc_clk_b), // input wire clk
  
  
//      .probe0(adc_data_b), // input wire [13:0]  probe0  
//      .probe1(adc_or_bb) // input wire [0:0]  probe1
//  );  
endmodule
