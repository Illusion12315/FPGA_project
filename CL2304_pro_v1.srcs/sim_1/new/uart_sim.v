`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/23 22:11:50
// Design Name: 
// Module Name: uart_sim
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

// module cl2304_uart_warpper_tb;

//   // Parameters
// localparam                              UART_NUM = 6               ;
//   //Ports
// reg                                     pcie_axi_clk               ;
// reg                                     clk_100m                   ;
// reg                                     sys_reset_n                ;

// reg                    [UART_NUM-1:0]   uart_tx_wren_start         ;
// reg                    [UART_NUM-1:0]   uart_tx_wren_end           ;
// reg                    [UART_NUM*8-1:0] uart_tx_data               ;

// reg                    [UART_NUM*16-1:0]uart_bps                   ;
// reg                    [UART_NUM*4-1:0] uart_data_bit              ;
// reg                    [UART_NUM*2-1:0] uart_stop_bit              ;
// reg                    [UART_NUM*2-1:0] uart_parity_bit            ;

// wire                   [UART_NUM-1:0]   tx_o                       ;
// reg                    [UART_NUM-1:0]   rx_i                       ;
// integer i;

// initial begin
//     sys_reset_n = 0;
//     pcie_axi_clk=0;
//     clk_100m=0;
//     for(i=0;i<UART_NUM;i=i+1)begin
//     uart_bps[i] = 'h01b2;
//     uart_data_bit[i] = 8;
//     uart_stop_bit[i] = 1;
//     uart_parity_bit[i] = 1;
//     end
//     #100
//     sys_reset_n = 1;
//     #100
//     uart_tx_wren_start[0] = 1;
//     uart_tx_data[7:0] = 1;
//     #5
//     uart_tx_wren_start[0] = 0;
//     uart_tx_data[7:0] = 2;
//     #5
//     uart_tx_data[7:0] = 3;
//         #5
//     uart_tx_data[7:0] = 4;
//         #5
//     uart_tx_data[7:0] = 5;
//         #5
//     uart_tx_data[7:0] = 6;
//     #5
//     uart_tx_wren_end[0] = 1;
//     uart_tx_data[7:0] = 7;
//         #5
//             uart_tx_wren_end[0] = 0;
// end

//   cl2304_uart_warpper   #(
//     .UART_NUM                          (UART_NUM                  ) 
//   )cl2304_uart_warpper_inst(
//     .pcie_axi_clk                      (pcie_axi_clk              ),
//     .clk_100m                          (clk_100m                  ),
//     .sys_reset_n                       (sys_reset_n               ),
  
//     .uart_tx_wren_start                (uart_tx_wren_start        ),
//     .uart_tx_wren_end                  (uart_tx_wren_end          ),
//     .uart_tx_data                      (uart_tx_data              ),
  
//     .uart_bps                          (uart_bps                  ),
//     .uart_stop_bit                     (uart_stop_bit             ),
//     .uart_parity_bit                   (uart_parity_bit           ),
  
//     .tx_o                              (tx_o                      ),
//     .rx_i                              (tx_o                      ) 
//   );

// always #2.5  pcie_axi_clk = ! pcie_axi_clk ;
// always #5  clk_100m = ! clk_100m ;
// endmodule


module uart_warpper_tb;

// Parameters
localparam                              DATA_BIT = 8               ;

//Ports
reg                                     sys_clk_i                  ;
reg                                     rst_n_i                    ;
reg                    [  31:0]         clk_fre                    ;
reg                    [  31:0]         uart_bps                   ;
reg                    [   1:0]         uart_parity_bit            ;
reg                    [   1:0]         uart_stop_bit              ;
reg                                     fifo_uart_tx_clk           ;
reg                                     fifo_uart_tx_wren          ;
reg                    [   7:0]         fifo_uart_tx_data          ;
wire                                    fifo_uart_tx_prog_full     ;
reg                                     fifo_uart_rx_clk           ;
reg                                     fifo_uart_rx_rden          ;
wire                   [   7:0]         fifo_uart_rx_data          ;
wire                                    fifo_uart_rx_empty         ;
wire                                    tx_o                       ;
reg                                     rx_i                       ;
reg                                     clk_200m                   ;

initial begin
  sys_clk_i=0;
  rst_n_i=0;
  clk_fre=100_000_000;
  uart_bps=115200;
  uart_parity_bit=2;
  uart_stop_bit=1;
  clk_200m=0;
  #100
  rst_n_i=1;
end

always@(posedge clk_200m or negedge rst_n_i)begin
  if (!rst_n_i) begin
    fifo_uart_tx_wren<='d0;
  end
  else if (!fifo_uart_tx_prog_full) begin
    fifo_uart_tx_wren<='d1;
  end
  else
    fifo_uart_tx_wren<='d0;
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
  if (!rst_n_i) begin
    fifo_uart_tx_data<='d0;
  end
  else if (fifo_uart_tx_wren) begin
    fifo_uart_tx_data<=fifo_uart_tx_data+'d1;
  end

end

uart_warpper # (
    .DATA_BIT                          (DATA_BIT                  ) 
)
uart_warpper_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),

    .clk_fre                           (clk_fre                   ),

    .uart_bps                          (uart_bps                  ),
    .uart_parity_bit                   (uart_parity_bit           ),
    .uart_stop_bit                     (uart_stop_bit             ),

    .fifo_uart_tx_clk                  (clk_200m                  ),
    .fifo_uart_tx_wren                 (fifo_uart_tx_wren         ),
    .fifo_uart_tx_data                 (fifo_uart_tx_data         ),
    .fifo_uart_tx_prog_full            (fifo_uart_tx_prog_full    ),

    .fifo_uart_rx_clk                  (clk_200m                  ),
    .fifo_uart_rx_rden                 (!fifo_uart_rx_empty         ),
    .fifo_uart_rx_data                 (fifo_uart_rx_data         ),
    .fifo_uart_rx_empty                (fifo_uart_rx_empty        ),
    .tx_o                              (tx_o                      ),
    .rx_i                              (tx_o                      ) 
);

always #5  sys_clk_i = ! sys_clk_i ;
always #2.5 clk_200m = ! clk_200m;
endmodule