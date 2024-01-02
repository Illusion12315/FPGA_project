`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/04 11:45:31
// Design Name: 
// Module Name: ad_sim
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



module ad7606_ctrl_logic_tb;

  // Parameters

  //Ports
reg                                     sys_clk_i                  ;
reg                                     rst_n_i                    ;
reg                                     start_flag_i               ;
wire                                    reset_o                    ;
wire                                    convsta_o                  ;
wire                                    convstb_o                  ;
reg                                     busy_i                     ;
reg                                     AD7606_FRSTDATA_1V8        ;
wire                                    cs_o                       ;
wire                                    rd_o                       ;
reg                    [  15:0]         ad_data_i                  ;
wire                                    data_flag_o                ;
wire                   [  15:0]         ch1_data                   ;
wire                   [  15:0]         ch2_data                   ;
wire                   [  15:0]         ch3_data                   ;
wire                   [  15:0]         ch4_data                   ;
wire                   [  15:0]         ch5_data                   ;
wire                   [  15:0]         ch6_data                   ;
wire                   [  15:0]         ch7_data                   ;
wire                   [  15:0]         ch8_data                   ;

initial begin
  sys_clk_i = 0;
  rst_n_i = 0;
  start_flag_i = 0;
  ad_data_i = 'd18;
  busy_i = 0;
  #50
  rst_n_i = 1;
  #200
  start_flag_i = 1;
  #50
  busy_i = 1;
  #300
  busy_i = 0;
end

  ad7606_ctrl_logic  ad7606_ctrl_logic_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    .start_flag_i                      (start_flag_i              ),
    .reset_o                           (reset_o                   ),
    .convsta_o                         (convsta_o                 ),
    .convstb_o                         (convstb_o                 ),
    .busy_i                            (busy_i                    ),
    .AD7606_FRSTDATA_1V8               (AD7606_FRSTDATA_1V8       ),
    .cs_o                              (cs_o                      ),
    .rd_o                              (rd_o                      ),
    .ad_data_i                         (ad_data_i                 ),
    .data_flag_o                       (data_flag_o               ),
    .ch1_data                          (ch1_data                  ),
    .ch2_data                          (ch2_data                  ),
    .ch3_data                          (ch3_data                  ),
    .ch4_data                          (ch4_data                  ),
    .ch5_data                          (ch5_data                  ),
    .ch6_data                          (ch6_data                  ),
    .ch7_data                          (ch7_data                  ),
    .ch8_data                          (ch8_data                  ) 
  );

always #5  sys_clk_i = ! sys_clk_i ;

endmodule