`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 19:25:15
// Design Name: 
// Module Name: megnetic_freq_wrapper
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


module megnetic_freq_wrapper(
    input               clk_100m,
    input               log_rst_n,
    input               megnetic_freq_en,
    input   [4:0]       megnetic_clk,
    output  [79:0]      megnetic_freq
    );
    


generate
    genvar i;
    begin : megnetic
        for(i = 0; i<5; i=i+1)begin : ch
            Perio_Freq Perio_Freq_inst(
                .i_clk                      (clk_100m) ,
                .i_rstn                     (log_rst_n) ,
                .i_work_en                  (megnetic_freq_en),
                .i_test_clk                 (megnetic_clk[i]),
                
                .o_test_clk                 (megnetic_freq[16*i+15:16*i])
            );
        
        end
    end
endgenerate    


    
endmodule
