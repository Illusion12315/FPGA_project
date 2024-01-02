`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/23 22:33:05
// Design Name: 
// Module Name: uart_tb
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



module uart_tx_logic_o_tb;

// Parameters
localparam                              DATA_BIT = 8               ;

//Ports
reg                                     sys_clk_i                  ;
reg                                     rst_n_i                    ;
reg                    [  31:0]         clk_fre                    ;
reg                    [  31:0]         uart_bps                   ;
reg                    [   1:0]         uart_parity_bit            ;
reg                    [   1:0]         uart_stop_bit              ;
reg                    [DATA_BIT-1:0]   tx_data_i                  ;
reg                                     tx_data_flag_i             ;
wire                                    tx_busy_o                  ;
wire                                    tx_o                       ;

initial begin
    sys_clk_i = 0;
    rst_n_i = 0;
    #100
    rst_n_i = 1;
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if (!rst_n_i) begin
        tx_data_flag_i<='d0;
        tx_data_i<='d0;
    end
    else if (!tx_busy_o) begin
        tx_data_flag_i<='d1;
        tx_data_i<=tx_data_i+'d1;
    end
    else
        tx_data_flag_i<='d0;
end

uart_tx_logic_o # (
    .DATA_BIT                          (DATA_BIT                  ) 
)
uart_tx_logic_o_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),

    .clk_fre                           (100_000_000               ),
    .uart_bps                          (115200                    ),
    .uart_parity_bit                   (1                         ),
    .uart_stop_bit                     (1                         ),

    .tx_data_i                         (tx_data_i                 ),
    .tx_data_flag_i                    (tx_data_flag_i            ),
    .tx_busy_o                         (tx_busy_o                 ),
    .tx_o                              (tx_o                      ) 
);

always #5  sys_clk_i = ! sys_clk_i ;

endmodule