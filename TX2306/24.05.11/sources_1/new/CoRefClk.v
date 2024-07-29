`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/20 21:08:34
// Design Name: 
// Module Name: ADclk
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


module CoRefClk(
//--debug signal

output      [7:0]         vio_up_gear,
output      [7:0]         vio_down_gear,

//output   wire             vio_ber_rst_in            ,
output   wire   [27:0]    vio_address_data_in             ,//վ��ַ
output   wire   [ 7:0]    vio_tx_data1_in                 ,//���п�������
output   wire             vio_tx_data1_valid_in           ,//���п�������ʹ��
output   wire   [ 7:0]    vio_tx_data2_in                 ,//����ҵ������
output   wire             vio_tx_data2_valid_in           ,//����ҵ������ʹ��
output   wire             vio_tx_data_select,

//output   wire             vio_clk                           ,  
//output   wire             vio_wrta                          ,
//output   wire             vio_data                          ,
 

   input           adc_dco_a ,
   input           adc_dco_b ,
   
   output          adc_clk100m,
   output          adc_clk_b,
   output          clk200m,
   
   output          ad_clk81m92,
   output          ad_clk163m84,
   output          hp_clk,
   output          ad_rst_n,
   output          vio_rstn,
   output wire     rstn

    );
 wire adc_clk_a;
// wire adc_clk_q;
 
 wire adc_clk_Q;
 
   IBUF #(
        .IBUF_LOW_PWR("TRUE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        .IOSTANDARD("DEFAULT")  // Specify the input I/O standard
     ) IBUF_CLKA (
        .O(adc_clk_a),     // Buffer output
        .I(adc_dco_a)      // Buffer input (connect directly to top-level port)
     );
   
     IBUF #(
         .IBUF_LOW_PWR("TRUE"),  // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
         .IOSTANDARD("DEFAULT")  // Specify the input I/O standard
      ) IBUF_CLKB (
         .O(adc_clk_Q),     // Buffer output
         .I(adc_dco_b)      // Buffer input (connect directly to top-level port)
      ); 
 
// BUFG BUFG_inst (
//      .O(adc_clk_b), // 1-bit output: Clock output
//      .I(adc_clk_Q)  // 1-bit input: Clock input
//   );

wire lockedQ;

  clk_100MQ clk_100MQ_inst
   (
    // Clock out ports
    .clk_out1(adc_clk_b),     // output clk_out1
    // Status and control signals
    .reset(1'b0), // input reset
    .locked(lockedQ),       // output locked
   // Clock in ports
    .clk_in1(adc_clk_Q));      // input clk_in1      
 //-------------------generate81.92MHz and 163.84MHz clk
 wire   locked;
 wire   locked1;
 wire   locked2;
 wire   ad_clk128m;
// wire   vio_rstn;
 
 assign ad_rst_n = locked2 && locked;
 assign rstn     = locked;
// assign ad_rst_n = locked2 && vio_rstn;
 
  clk_ad100m clk_ad100m_inst
  (
   // Clock out ports
   .clk_out1(adc_clk100m),     // output clk_out1
   .clk_out2(hp_clk),     // output clk_out1
   // Status and control signals
   .reset(1'b0), // input reset
   .locked(locked),       // output locked
  // Clock in ports
   .clk_in1(adc_clk_a));      // input clk_in1
 
 
 
 
  clk_100to128 clk_100to128_ADinst
  (
   // Clock out ports
   .clk_out1(ad_clk128m),     // output clk_out1
   .clk_out2(clk200m),     // output clk_out1
   // Status and control signals
   .reset(!locked), // input reset
   .locked(locked1),       // output locked
  // Clock in ports
   .clk_in1(adc_clk100m));      // input clk_in1    
   
  clk_da clk_da_inst
      (
       // Clock out ports
       .clk_out1(ad_clk81m92),     // output clk_out1
       .clk_out2(ad_clk163m84),     // output clk_out2
       // Status and control signals
       .reset(!locked1), // input reset
       .locked(locked2),       // output locked
      // Clock in ports
       .clk_in1(ad_clk128m));      // input clk_in1
      reg [6:0] test_cnt;
       reg [6:0] test_cnt1;
       
       always @(posedge adc_clk100m or negedge locked)begin
           if (locked ==1'b0)begin
               test_cnt <= 7'd0;
           end
           else begin 
               test_cnt <= test_cnt + 1'b1;
           end 
       end 
       

       
//       ila_test ila_test_inst (
//           .clk(adc_clk100m), // input wire clk
       
       
//           .probe0(test_cnt) // input wire [6:0] probe0
//       );
       

// vio_ad vio_ad_inst (
//      .clk(adc_clk100m),                // input wire clk
//      .probe_out0(vio_rstn),  // output wire [0 : 0] probe_out0
//      .probe_out1(sub_value)  // output wire [13 : 0] probe_out1
//    );   
    
//vio_ad vio_ad_inst (
//  .clk(ad_clk163m84),                  // input wire clk
//  .probe_out0(vio_rstn),    // output wire [0 : 0] probe_out0

//  .probe_out1(vio_down_gear),    // output wire [7 : 0] probe_out5
//  .probe_out2(vio_address_data_in  ),    // output wire [27 : 0] probe_out7
//  .probe_out3(vio_tx_data1_in      ),    // output wire [7 : 0] probe_out8
//  .probe_out4(vio_tx_data1_valid_in),    // output wire [0 : 0] probe_out9
//  .probe_out5(vio_tx_data2_in      ),  // output wire [7 : 0] probe_out10
//  .probe_out6(vio_tx_data2_valid_in) , // output wire [0 : 0] probe_out11
//  .probe_out7(vio_tx_data_select),  // output wire [0 : 0] probe_out11
//  .probe_out8(vio_up_gear)  // output wire [0 : 0] probe_out11
//);       
       

endmodule
