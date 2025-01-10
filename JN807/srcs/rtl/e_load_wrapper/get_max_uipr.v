`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             get_max_uipr.v
// Create Date:           2025/01/08 16:49:25
// Version:               V1.0
// PATH:                  srcs\rtl\e_load_wrapper\get_max_uipr.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module get_max_uipr (
    input  wire                     sys_clk_i           ,

    input  wire        [  15: 0]    Model_i             ,
    output reg         [  31: 0]    U_max_o             ,
    output reg         [  31: 0]    I_max_o             ,
    output reg         [  31: 0]    P_max_o             ,
    output wire        [  31: 0]    R_max_o              
);


always@(posedge sys_clk_i)begin
    case (Model_i[3:0])
        4'd0   : I_max_o <= 24'd40000  ;
        4'd1   : I_max_o <= 24'd100000 ;
        4'd2   : I_max_o <= 24'd200000 ;
        4'd3   : I_max_o <= 24'd400000 ;
        4'd4   : I_max_o <= 24'd240000 ;
        4'd5   : I_max_o <= 24'd60000  ;
        4'd6   : I_max_o <= 24'd80000  ;
        4'd7   : I_max_o <= 24'd120000 ;
        4'd8   : I_max_o <= 24'd160000 ;
        4'd9   : I_max_o <= 24'd280000 ;
        4'd10  : I_max_o <= 24'd300000 ;
        4'd11  : I_max_o <= 24'd320000 ;
        4'd12  : I_max_o <= 24'd450000 ;
        4'd13  : I_max_o <= 24'd480000 ;
        4'd14  : I_max_o <= 24'd600000 ;
        4'd15  : I_max_o <= 24'd800000 ;
        default: I_max_o <= 24'd40000  ;
    endcase
end

always@(posedge sys_clk_i)begin
    case (Model_i[7:4])
        4'd0   : U_max_o <= 24'd120000  ;
        4'd1   : U_max_o <= 24'd150000  ;
        4'd2   : U_max_o <= 24'd600000  ;
        4'd3   : U_max_o <= 24'd1000000 ;
        4'd4   : U_max_o <= 24'd1200000 ;
        default: U_max_o <= 24'd120000  ;
    endcase
end

always@(posedge sys_clk_i)begin
    case (Model_i[11:8])
        4'd0   : P_max_o <= 32'd4000000  ;
        4'd1   : P_max_o <= 32'd5000000  ;
        4'd2   : P_max_o <= 32'd6000000  ;
        4'd3   : P_max_o <= 32'd3000000  ;
        4'd4   : P_max_o <= 32'd2000000  ;
        4'd5   : P_max_o <= 32'd5500000  ;
        4'd6   : P_max_o <= 32'd8000000  ;
        default: P_max_o <= 24'd120000   ;
    endcase
end

    assign                          R_max_o            = -1;



endmodule


`default_nettype wire
