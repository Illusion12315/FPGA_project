`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/16 09:59:17
// Design Name: 
// Module Name: top_sim
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


module top_sim(

    );

reg                                     pcie_axi_clk               ;
reg                                     clk_50m                    ;
reg                                     sys_reset_n                ;
wire                                    GNSS_RXD_1V8               ;
reg                                     pps_uart_tx_wren_start     ;
reg                                     pps_uart_tx_wren_end       ;
reg                    [   7:0]         pps_uart_tx_data           ;

initial begin
    pcie_axi_clk=0;
    clk_50m=0;
    sys_reset_n=0;
    pps_uart_tx_wren_start = 0;
    pps_uart_tx_wren_end = 0;
    pps_uart_tx_data=1;
    #50
    sys_reset_n = 1;
    #200
    pps_uart_tx_wren_start = 1;
    pps_uart_tx_data =2;
    #4
    pps_uart_tx_data = 3;
    pps_uart_tx_wren_start = 0;
    #4
    pps_uart_tx_data = 4;
    #4
    pps_uart_tx_data = 5;
    #4
    pps_uart_tx_data = 6;
    #4
    pps_uart_tx_data = 7;
    pps_uart_tx_wren_end = 1;
    #4
    pps_uart_tx_wren_end =0;
end


cl2304_uart_warpper   #(
    .UART_NUM                          (1                         ) 
) cl2304_uart_warpper_pps(
    .pcie_axi_clk                      (pcie_axi_clk              ),
    .clk_50m                           (clk_50m                   ),
    .sys_reset_n                       (sys_reset_n               ),

    .uart_tx_wren_start                (pps_uart_tx_wren_start    ),
    .uart_tx_wren_end                  (pps_uart_tx_wren_end      ),
    .uart_tx_data                      (pps_uart_tx_data          ),
    .fifo_uart_tx_prog_full            (                          ),
    
    .uart_bps                          ('h01b2                    ),//波特率
    //    波特率     1200      2400	      4800	    9600       19200      38400	        57600      115200   230400	  460800	921600
    //    设值      0xa2c2    0x5160	     0x28B0	   0x1458      0x0a2c     0x0516	   0x0364      0x01b2   0xD9      0x6C	    0x36	  
    .uart_data_bit                     (8                         ),//数据位
    .uart_stop_bit                     (2                         ),//校验位：0，1，2，3分别代表无校验，奇校验，偶校验，无校验
    .uart_parity_bit                   (2                         ),//停止位：0，1，2，3分别代表1，1.5，2，1的停止位

    .fifo_uart_rx_empty                (                          ),
    .uart_rx_data                      (                          ),

    .tx_o                              (GNSS_RXD_1V8              ),
    .rx_i                              (GNSS_RXD_1V8              ) 
);

always #2 pcie_axi_clk = ~pcie_axi_clk;
always #10 clk_50m = ~clk_50m;
endmodule
