module pps_warpper (
    input                               sys_clk_i                  ,
    input                               rst_n_i                    ,
    input                               GNSS_PPS_1V8               ,
    input              [   1:0]         UART_RXD_RS422             ,

    output reg         [  31:0]         cnt2                       ,

    output                              UART_TXD_RS422_0           ,
    output                              UART_TXD_RS422_1            
);
wire                                    pps_start_flag             ;
wire                                    uart0_start_flag           ;
wire                                    uart1_start_flag           ;

reg                                     pps_r1=0,pps_r2=0,pps_r3=0 ;
reg                                     uart0_pps_r1=0,uart0_pps_r2=0,uart0_pps_r3=0;
reg                                     uart1_pps_r1=0,uart1_pps_r2=0,uart1_pps_r3=0;

assign UART_TXD_RS422_0 = pps_r3;
assign UART_TXD_RS422_1 = pps_r3;

assign pps_start_flag = pps_r2&~pps_r3;
assign uart0_start_flag = uart0_pps_r2&~uart0_pps_r3;
assign uart1_start_flag = uart1_pps_r2&~uart1_pps_r3;

always@(posedge sys_clk_i)begin
    pps_r1<=GNSS_PPS_1V8;
    pps_r2<=pps_r1;
    pps_r3<=pps_r2;
end

always@(posedge sys_clk_i)begin
    uart0_pps_r1<=UART_RXD_RS422[0];
    uart0_pps_r2<=uart0_pps_r1;
    uart0_pps_r3<=uart0_pps_r2;
end

always@(posedge sys_clk_i)begin
    uart1_pps_r1<=UART_RXD_RS422[1];
    uart1_pps_r2<=uart1_pps_r1;
    uart1_pps_r3<=uart1_pps_r2;
end

reg                    [  31:0]         cnt1                       ;
reg                                     cnt_en                     ;

always@(*)begin
    if (pps_start_flag) begin
        cnt_en<='d0;
    end
    else if (uart0_start_flag||uart1_start_flag) begin
        cnt_en<='d1;
    end
    else
        cnt_en<=cnt_en;
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        cnt2<='d0;
        cnt1<='d0;
    end
    else if (pps_start_flag) begin
        cnt2<=cnt1;
        cnt1<='d0;
    end
    else if (cnt_en) begin
        cnt1<=cnt1+'d1;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
ila_pps_debug ila_pps_debug_inst (
    .clk                               (sys_clk_i                 ),// input wire clk

    .probe0                            (pps_r3                    ),// input wire [0:0]  probe0  
    .probe1                            (uart0_start_flag          ),// input wire [0:0]  probe1 
    .probe2                            (cnt_en                    ),// input wire [0:0]  probe2 
    .probe3                            (cnt1                      ) // input wire [31:0]  probe3
);
endmodule