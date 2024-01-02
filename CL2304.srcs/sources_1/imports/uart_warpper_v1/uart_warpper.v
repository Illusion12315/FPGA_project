module uart_warpper #(
    parameter                           DATA_BIT = 8                //数据位：5，6，7，8位
) (
    input                               sys_clk_i                  ,
    input                               rst_n_i                    ,

    input              [  31:0]         clk_fre                    ,//系统时钟频率
    input              [  31:0]         uart_bps                   ,//波特率:115200
    input              [   1:0]         uart_parity_bit            ,//校验位：0，1，2，3分别代表无校验，奇校验，偶校验，无校验
    input              [   1:0]         uart_stop_bit              ,//停止位：0，1，2，3分别代表1，1.5，2，1的停止位

    input                               fifo_uart_tx_clk           ,//tx_fifo
    input                               fifo_uart_tx_wren          ,//tx_fifo
    input              [   7:0]         fifo_uart_tx_data          ,//tx_fifo
    output                              fifo_uart_tx_prog_full     ,//tx_fifo

    input                               fifo_uart_rx_clk           ,//rx_fifo
    input                               fifo_uart_rx_rden          ,//rx_fifo
    output             [   7:0]         fifo_uart_rx_data          ,//rx_fifo
    output                              fifo_uart_rx_empty         ,//rx_fifo

    output                              tx_o                       ,
    input                               rx_i                        
);
reg                                     tx_data_flag               ;
wire                   [   7:0]         tx_data                    ;
wire                                    tx_busy                    ;
wire                                    tx_empty                   ;

wire                                    rx_data_flag               ;
wire                   [   7:0]         rx_data                    ;
wire                                    rx_prog_full               ;

always@(posedge sys_clk_i or negedge rst_n_i)begin
  if (!rst_n_i) begin
    tx_data_flag<='d0;
  end
  else if (!tx_empty && !tx_busy) begin
    tx_data_flag<='d1;
  end
  else
    tx_data_flag<='d0;
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// uart_tx
//---------------------------------------------------------------------
uart_tx_logic_o # (
    .DATA_BIT                          (DATA_BIT                  ) 
  )
  uart_tx_logic_o_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),

    .clk_fre                           (clk_fre                   ),//系统时钟频率
    .uart_bps                          (uart_bps                  ),//波特率
    .uart_parity_bit                   (uart_parity_bit           ),//校验位：0，1，2，3分别代表无校验，奇校验，偶校验，无校验
    .uart_stop_bit                     (uart_stop_bit             ),//停止位：0，1，2，3分别代表1，1.5，2，1的停止位

    .tx_data_i                         (tx_data                   ),
    .tx_data_flag_i                    (tx_data_flag              ),
    .tx_busy_o                         (tx_busy                   ),

    .tx_o                              (tx_o                      ) 
  );

fifo_uart_tx fifo_uart_tx_inst (
    .rst                               (!rst_n_i                  ),// input wire rst
    .wr_clk                            (fifo_uart_tx_clk          ),// input wire wr_clk
    .wr_en                             (fifo_uart_tx_wren         ),// input wire wr_en
    .din                               (fifo_uart_tx_data         ),// input wire [7 : 0] din
    .prog_full                         (fifo_uart_tx_prog_full    ),// output wire prog_full
    .full                              (                          ),// output wire full

    .rd_clk                            (sys_clk_i                 ),// input wire rd_clk
    .rd_en                             (tx_data_flag              ),// input wire rd_en
    .dout                              (tx_data                   ),// output wire [7 : 0] dout
    .empty                             (tx_empty                  ) // output wire empty
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// Uart_rx
//---------------------------------------------------------------------
uart_rx_logic_i # (
    .DATA_BIT                          (DATA_BIT                  ) 
  )
  uart_rx_logic_i_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),

    .clk_fre                           (clk_fre                   ),//系统时钟频率
    .uart_bps                          (uart_bps                  ),//波特率
    .uart_parity_bit                   (uart_parity_bit           ),//校验位：0，1，2，3分别代表无校验，奇校验，偶校验，无校验
    .uart_stop_bit                     (uart_stop_bit             ),//停止位：0，1，2，3分别代表1，1.5，2，1的停止位

    .rx_i                              (rx_i                      ),

    .rx_data_flag_o                    (rx_data_flag              ),
    .rx_data_o                         (rx_data                   ) 
  );

fifo_uart_rx fifo_uart_rx_inst (
    .rst                               (!rst_n_i                  ),// input wire rst
    .wr_clk                            (sys_clk_i                 ),// input wire wr_clk
    .wr_en                             (!rx_prog_full && rx_data_flag),// input wire wr_en
    .din                               (rx_data                   ),// input wire [7 : 0] din
    .prog_full                         (rx_prog_full              ),// output wire prog_full
    .full                              (                          ),// output wire full

    .rd_clk                            (fifo_uart_rx_clk          ),// input wire rd_clk
    .rd_en                             (fifo_uart_rx_rden         ),// input wire rd_en
    .dout                              (fifo_uart_rx_data         ),// output wire [7 : 0] dout
    .empty                             (fifo_uart_rx_empty        ) // output wire empty
);
endmodule