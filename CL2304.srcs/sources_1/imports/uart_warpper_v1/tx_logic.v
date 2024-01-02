module uart_tx_logic_o
#(
    parameter                           DATA_BIT = 8                //数据位8位
)
(
    input                               sys_clk_i                  ,//时钟
    input                               rst_n_i                    ,//复位

    input              [  31:0]         clk_fre                    ,//系统时钟频率
    input              [  31:0]         uart_bps                   ,//波特率
    input              [   1:0]         uart_parity_bit            ,//校验位：0，1，2，3分别代表无校验，奇校验，偶校验，无校验
    input              [   1:0]         uart_stop_bit              ,//停止位：0，1，2，3分别代表1，1.5，2，1的停止位

    input              [DATA_BIT-1:0]   tx_data_i                  ,//8bit数据
    input                               tx_data_flag_i             ,//数据标志
    output                              tx_busy_o                  ,//繁忙
    output reg                          tx_o                        //tx单bit输出
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// regs
//---------------------------------------------------------------------
reg                    [   3:0]         bit_cnt                    ;
reg                                     bit_flag                   ;
reg                    [  15:0]         baud_cnt                   ;
reg                    [DATA_BIT-1:0]   tx_data_r                  ;
reg                    [   2:0]         next_state                 ;
reg                    [   2:0]         cur_state                  ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// localparam
//---------------------------------------------------------------------
localparam                              IDLE = 'd0                 ;
localparam                              START = 'd1                ;
localparam                              DATA = 'd2                 ;
localparam                              PARITY = 'd3               ;
localparam                              STOP = 'd4                 ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// assign
//---------------------------------------------------------------------
assign tx_busy_o = ~(next_state == IDLE);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// logic
//---------------------------------------------------------------------
//baud_cnt
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        baud_cnt<=0;
    else if(baud_cnt==clk_fre/uart_bps)
        baud_cnt<=0;
    else case (next_state)
        START,DATA,PARITY,STOP: baud_cnt<=baud_cnt+'d1;
        default: baud_cnt<='d0;
    endcase
end
//bit_flag
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        bit_flag<=0;
    else if(baud_cnt==clk_fre/uart_bps)
        bit_flag<=1;
    else
        bit_flag<=0;
end
//bit计数器
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        bit_cnt<=0;
    else case (cur_state)
        DATA:
            if (bit_cnt == DATA_BIT-1 && bit_flag) begin
                bit_cnt<='d0;
            end
            else if (bit_flag) begin
                bit_cnt<=bit_cnt+'d1;
            end
            else
                bit_cnt<=bit_cnt;
        STOP:
            if (bit_flag) begin
                bit_cnt<=bit_cnt+'d1;
            end
            else
                bit_cnt<=bit_cnt;
        default: bit_cnt<='d0;
    endcase
end
//第一段,状态跳转,时序逻辑
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        cur_state<=IDLE;
    else
        cur_state<=next_state;
end
//第二段,跳转条件,组合逻辑
always@(*)begin
    case(cur_state)
        IDLE   :
            if (tx_data_flag_i) begin
                next_state<=START;
            end
            else
                next_state<=IDLE;
        START  :
            if (bit_flag) begin
                next_state<=DATA;
            end
            else
                next_state<=next_state;
        DATA   :
            if (bit_flag && bit_cnt == DATA_BIT-1 && (uart_parity_bit == 1 || uart_parity_bit == 2)) begin
                next_state<=PARITY;
            end
            else if (bit_flag && bit_cnt == DATA_BIT-1 && (uart_parity_bit == 0 || uart_parity_bit == 3)) begin
                next_state<=STOP;
            end
            else
                next_state<=next_state;
        PARITY :
            if (bit_flag) begin
                next_state<=STOP;
            end
            else
                next_state<=next_state;
        STOP   :
            case (uart_stop_bit)
                1:
                    if (bit_cnt == 'd1 && baud_cnt == clk_fre/uart_bps/2) begin
                        next_state<=IDLE;
                    end
                    else
                        next_state<=next_state;
                default:
                    if (bit_flag && bit_cnt == uart_stop_bit-1) begin
                        next_state<=IDLE;
                    end
                    else
                        next_state<=next_state;
            endcase
        default:next_state<=IDLE;
    endcase
end
//缓存待发送数据
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        tx_data_r<='d0;
    else if (tx_data_flag_i) begin
        tx_data_r<=tx_data_i;
    end
end
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        tx_o<=1;
    else case (next_state)
        START: tx_o<='d0;
        DATA: tx_o<=tx_data_r[bit_cnt];
        PARITY:
            if (uart_parity_bit == 1) begin
                tx_o<= ~^tx_data_r;                                 //奇校验
            end
            else
                tx_o<= ^tx_data_r;                                  //偶校验
        STOP: tx_o<='d1;
        default: tx_o<='d1;
    endcase
end
endmodule