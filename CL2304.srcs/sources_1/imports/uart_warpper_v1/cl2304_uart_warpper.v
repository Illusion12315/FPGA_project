module cl2304_uart_warpper #(
    parameter                           UART_NUM = 6                
) (
    input                               pcie_axi_clk               ,
    input                               clk_100m                   ,
    input                               sys_reset_n                ,

    input              [UART_NUM-1:0]   uart_tx_wren_start         ,
    input              [UART_NUM-1:0]   uart_tx_wren_end           ,
    input              [UART_NUM*8-1:0] uart_tx_data               ,
    output             [UART_NUM-1:0]   fifo_uart_tx_prog_full     ,
    
    input              [UART_NUM*16-1:0]uart_bps                   ,//波特率
    //    波特率     1200      2400	      4800	    9600       19200      38400	        57600      115200   230400	  460800	921600
    //    设值      0xa2c2    0x5160     0x28B0   0x1458     0x0a2c    0x0516	   0x0364      0x01b2   0xD9      0x6C	    0x36	  
    input              [UART_NUM*4-1:0] uart_data_bit              ,//数据位
    input              [UART_NUM*2-1:0] uart_stop_bit              ,//停止位：0，1，2，3分别代表1，1.5，2，1的停止位
    input              [UART_NUM*2-1:0] uart_parity_bit            ,//校验位：0，1，2，3分别代表无校验，奇校验，偶校验，无校验
    
    output             [UART_NUM*8-1:0] uart_rx_data               ,

    output             [UART_NUM-1:0]   tx_o                       ,
    input              [UART_NUM-1:0]   rx_i                        
);

wire                   [UART_NUM-1:0]   fifo_uart_rx_empty         ;

reg                    [UART_NUM*32-1:0]BPS_32b,BPS_32b_r1         ;
reg                    [UART_NUM*2-1:0] uart_stop_bit_r1,uart_stop_bit_r2;
reg                    [UART_NUM*2-1:0] uart_parity_bit_r1,uart_parity_bit_r2;

always@(posedge clk_100m)begin
    uart_stop_bit_r1<=uart_stop_bit;
    uart_stop_bit_r2<=uart_stop_bit_r1;
end
always@(posedge clk_100m)begin
    uart_parity_bit_r1<=uart_parity_bit;
    uart_parity_bit_r2<=uart_parity_bit_r1;
end
always@(posedge clk_100m)begin
    BPS_32b<=uart_bps;
end

reg                    [UART_NUM-1:0]   uart_tx_wren               ;
reg                    [UART_NUM*8-1:0] uart_tx_data_r1            ;

always @(posedge pcie_axi_clk) begin
    uart_tx_data_r1<=uart_tx_data;
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// uart_warpper
//---------------------------------------------------------------------
generate
    begin
        genvar i;
        for(i=0;i<UART_NUM;i=i+1)
            begin:uart
                always@(posedge clk_100m)begin
                    case (BPS_32b[16*i+15:16*i])
                        'ha2c2 : BPS_32b_r1[32*i+31:32*i] <= 1200;
                        'h5160 : BPS_32b_r1[32*i+31:32*i] <= 2400;
                        'h28B0 : BPS_32b_r1[32*i+31:32*i] <= 4800;
                        'h1458 : BPS_32b_r1[32*i+31:32*i] <= 9600;
                        'h0a2c : BPS_32b_r1[32*i+31:32*i] <= 19200;
                        'h0516 : BPS_32b_r1[32*i+31:32*i] <= 38400;
                        'h0364 : BPS_32b_r1[32*i+31:32*i] <= 57600;
                        'h01b2 : BPS_32b_r1[32*i+31:32*i] <= 115200;
                        'hD9 : BPS_32b_r1[32*i+31:32*i] <= 230400;
                        'h6C : BPS_32b_r1[32*i+31:32*i] <= 460800;
                        'h36 : BPS_32b_r1[32*i+31:32*i] <= 921600;
                        default: BPS_32b_r1[32*i+31:32*i] <= 9600;
                    endcase
                end

                always@(posedge pcie_axi_clk or negedge sys_reset_n)begin
                    if(!sys_reset_n)
                        uart_tx_wren[i]<='d0;
                    else if (uart_tx_wren_end[i]) begin
                        uart_tx_wren[i]<='d0;
                    end
                    else if (uart_tx_wren_start[i]) begin
                        uart_tx_wren[i]<='d1;
                    end
                    else
                        uart_tx_wren[i]<=uart_tx_wren[i];
                end

                uart_warpper # (
                    .DATA_BIT                          (8                         ) 
                  )
                  uart_warpper_inst (
                    .sys_clk_i                         (clk_100m                  ),
                    .rst_n_i                           (sys_reset_n               ),
                    .clk_fre                           (100_000_000               ),

                    .uart_bps                          (BPS_32b_r1[32*i+31:32*i]  ),
                    .uart_parity_bit                   (uart_stop_bit_r2[2*i+1:2*i]),
                    .uart_stop_bit                     (uart_parity_bit_r2[2*i+1:2*i]),

                    .fifo_uart_tx_clk                  (pcie_axi_clk              ),
                    .fifo_uart_tx_wren                 (uart_tx_wren[i]           ),
                    .fifo_uart_tx_data                 (uart_tx_data_r1[8*i+7:8*i]),
                    .fifo_uart_tx_prog_full            (fifo_uart_tx_prog_full[i] ),

                    .fifo_uart_rx_clk                  (pcie_axi_clk              ),
                    .fifo_uart_rx_rden                 (!fifo_uart_rx_empty[i]    ),
                    .fifo_uart_rx_data                 (uart_rx_data[8*i+7:8*i]   ),
                    .fifo_uart_rx_empty                (fifo_uart_rx_empty[i]     ),

                    .tx_o                              (tx_o[i]                   ),
                    .rx_i                              (rx_i[i]                   ) 
                  );
            end
    end
endgenerate
endmodule