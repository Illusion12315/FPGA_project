`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/14 21:21:17
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




module uart_warpper_tb;

// Parameters
localparam                              DATA_BIT = 0               ;

//Ports
reg                                     sys_clk_i                  ;
reg                                     rst_n_i                    ;
reg                    [  15:0]         baud_cnt_max               ;
reg                    [   1:0]         uart_parity_bit            ;
reg                    [   1:0]         uart_stop_bit              ;
reg                                     fifo_uart_tx_clk           ;
reg                                     fifo_uart_tx_wren          ;
reg                                     fifo_uart_tx_wren_r1       ;
reg                    [   7:0]         fifo_uart_tx_data          ;
wire                                    fifo_uart_tx_prog_full     ;
reg                                     uart_tx_wren_start         ;
reg                                     uart_tx_wren_end           ;
reg                                     fifo_uart_rx_clk           ;
reg                                     fifo_uart_rx_rden          ;
wire                   [   7:0]         fifo_uart_rx_data          ;
wire                                    fifo_uart_rx_empty         ;
wire                                    tx_o                       ;
reg [15:0]cnt;

always@(posedge fifo_uart_tx_clk)begin
    fifo_uart_tx_wren_r1<=fifo_uart_tx_wren;
end

always@(posedge fifo_uart_tx_clk or negedge rst_n_i)begin
    if (!rst_n_i) begin
        cnt<='d0;
    end
    else
        cnt<=cnt+'d1;
end

always@(*)begin
    case (cnt)
        100: begin
            fifo_uart_tx_wren = 1;
        end
        101:begin
            fifo_uart_tx_wren = 1;
            fifo_uart_tx_data = 'heb;
            uart_tx_wren_end = 1;
            uart_tx_wren_start = 1;
        end
        102:begin
            fifo_uart_tx_wren = 0;
            fifo_uart_tx_data = 'h90;
            uart_tx_wren_end = 1;
            uart_tx_wren_start = 1;
        end
        103:begin
            
        end
        104:begin
            
        end
        default: begin
            uart_tx_wren_end = 0;
            uart_tx_wren_start = 0;
            fifo_uart_tx_wren = 0;
            fifo_uart_tx_data = 0;
        end
    endcase
end

initial begin
    sys_clk_i = 0;
    rst_n_i = 0;
    fifo_uart_tx_clk = 0;
    uart_tx_wren_end = 0;
    uart_tx_wren_start = 0;
    fifo_uart_tx_wren = 0;
    fifo_uart_tx_data = 0;
    #100
    rst_n_i = 1;
    // //////////////////////////////////////
    // #400
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'heb;
    // uart_tx_wren_end = 0;
    // uart_tx_wren_start = 1;
    // #2000
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h90;
    // uart_tx_wren_start = 0;
    // #200
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h12;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h34;
    // #100
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h56;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h07;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'hd9;
    // uart_tx_wren_end = 1;
    // //////////////////////////////////////
    // //////////////////////////////////////
    // #400
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'heb;
    // uart_tx_wren_end = 0;
    // uart_tx_wren_start = 1;
    // #2000
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h90;
    // uart_tx_wren_start = 0;
    // #200
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h12;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h34;
    // #100
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h56;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h07;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'hd9;
    // uart_tx_wren_end = 1;
    // //////////////////////////////////////
    // //////////////////////////////////////
    // #400
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'heb;
    // uart_tx_wren_end = 0;
    // uart_tx_wren_start = 1;
    // #2000
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h90;
    // uart_tx_wren_start = 0;
    // #200
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h12;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h34;
    // #100
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h56;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h07;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'hd9;
    // uart_tx_wren_end = 1;
    // //////////////////////////////////////
    // //////////////////////////////////////
    // #400
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'heb;
    // uart_tx_wren_end = 0;
    // uart_tx_wren_start = 1;
    // #2000
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h90;
    // uart_tx_wren_start = 0;
    // #200
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h12;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h34;
    // #100
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h56;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h07;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'hd9;
    // uart_tx_wren_end = 1;
    // //////////////////////////////////////
    // //////////////////////////////////////
    // #400
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'heb;
    // uart_tx_wren_end = 0;
    // uart_tx_wren_start = 1;
    // #2000
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h90;
    // uart_tx_wren_start = 0;
    // #200
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h12;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h34;
    // #100
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h56;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'h07;
    // #20
    // fifo_uart_tx_wren = 1;
    // #4
    // fifo_uart_tx_wren = 0;
    // fifo_uart_tx_data = 'hd9;
    // uart_tx_wren_end = 1;
    // //////////////////////////////////////
end

uart_warpper # (
    .DATA_BIT                          (8                         ) 
)
uart_warpper_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    .baud_cnt_max                      ('d200                     ),
    .uart_parity_bit                   ('d1                       ),
    .uart_stop_bit                     ('d1                       ),

    .fifo_uart_tx_clk                  (fifo_uart_tx_clk          ),
    .fifo_uart_tx_wren                 (fifo_uart_tx_wren         ),
    .fifo_uart_tx_wren_r1              (fifo_uart_tx_wren_r1      ),
    .fifo_uart_tx_data                 (fifo_uart_tx_data         ),
    .fifo_uart_tx_prog_full            (fifo_uart_tx_prog_full    ),

    .uart_tx_wren_start                (uart_tx_wren_start        ),
    .uart_tx_wren_end                  (uart_tx_wren_end          ),

    .fifo_uart_rx_clk                  (sys_clk_i                 ),
    .fifo_uart_rx_rden                 (~fifo_uart_rx_empty       ),
    .fifo_uart_rx_data                 (fifo_uart_rx_data         ),
    .fifo_uart_rx_empty                (fifo_uart_rx_empty        ),

    .tx_o                              (tx_o                      ),
    .rx_i                              (tx_o                      ) 
);

always #5  sys_clk_i = ! sys_clk_i ;
always #2  fifo_uart_tx_clk = ! fifo_uart_tx_clk ;


endmodule