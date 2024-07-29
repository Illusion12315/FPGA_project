`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/20 18:20:23
// Design Name: 
// Module Name: DA_TX
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


module DA_TX(
    //mod out  for tx
    input           clk163m84,
    input           clk100m,
    input           rst_n,

    output          dac_clk_a ,
    output          dac_clk_b ,
    output [11:0]   dac_dat_i ,
    output [11:0]   dac_dat_q ,
    output          dac_wrta  ,
    output          dac_wrtb  
    );
DA_DDS_test DA_DDS_test_inst(
            .clk163m84          (clk163m84),
            .clk100m            (clk100m  ),
            .rst_n              (rst_n    ),
            
            .dac_clk_a          (dac_clk_a),
            .dac_clk_b          (dac_clk_b),
            .dac_dat_i          (dac_dat_i),
            .dac_dat_q          (dac_dat_q),
            .dac_wrta           (dac_wrta ),
            .dac_wrtb           (dac_wrtb )
        ); 
    
endmodule
