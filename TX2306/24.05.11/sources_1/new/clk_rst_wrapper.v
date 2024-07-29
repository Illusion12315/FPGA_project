`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/20 18:53:57
// Design Name: 
// Module Name: clk_rst_wrapper
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


module clk_rst_wrapper(
    input           clk_100_p   ,
    input           clk_100_n   ,
    
    output          sys_clk100m,
    output          sys_clk20m,
    output          sys_rstn
    
//    output          da_clk_100m,
//    output          da_clk81m92,
//    output          da_clk163m84,
//    output          da_rst_n
    );
    

wire        clk_buf100m;
wire        clk128m;
wire       locked;
wire       clk_144m;
wire       clk_100m;

assign sys_rstn = locked;

 
 clk_100Mto144M U_clk_100Mto144M
    (
        // Clock out ports
        .clk_out1(clk_144m),     // output clk_out1
        .clk_out2(sys_clk100m),     // output clk_out2
        .clk_out3(sys_clk20m),     // output clk_out2
        // Status and control signals
        .resetn(1'b1), // input resetn
        .locked(locked),       // output locked
        // Clock in ports
        .clk_in1_p(clk_100_p),      // input clk_in1_p
        .clk_in1_n(clk_100_n)       // input clk_in1_n
    ); 

endmodule
