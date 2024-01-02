module tx_send_compress_mod #(
    parameter                           MAX_N = 1024                
)(
    input                               sys_clk_i                  ,
    input                               rst_n_i                    ,

    input                               tx_compress_mod_start      ,
    input                               fifo_us_prog_full          ,
    output reg                          valid                      ,
    output             [  15:0]         M_NUM                      ,
    //TX FIFO写
    output             [  15:0]         fifo_us_data                
);
//---------------------------------------------------------------------
// regs
//---------------------------------------------------------------------
reg                    [  15:0]         fifo_us_data_r = 'd0       ;
reg                    [  31:0]         package_cnt = 'd0          ;
reg                    [  15:0]         m_cnt = 'd0                ;
reg                    [  15:0]         m_data = 'd0               ;
reg                    [   3:0]         state = 'd0                ;
reg                    [  15:0]         verify_data = 'd0          ;
reg                    [  15:0]         M                          ;
//---------------------------------------------------------------------
// localparam
//---------------------------------------------------------------------
assign M_NUM = M + 'd4;
assign fifo_us_data = fifo_us_data_r;
//TX状态
localparam                              TX_IDLE      = 0           ;
localparam                              TX_SYNC      = 1           ;
localparam                              TX_PACKEGE_H = 2           ;
localparam                              TX_PACKEGE_L = 3           ;
localparam                              TX_IMAGE     = 4           ;
localparam                              TX_VERIFY    = 5           ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计数器
//---------------------------------------------------------------------
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        M<='d8900;
    else if (package_cnt == 'd0) begin
        M<='d8900;
    end
    else
        M<='d1024;
end
//像素计数器
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        m_cnt<='d0;
        m_data<='d0;
    end
    else if (m_cnt == M - 1)begin
        m_cnt<='d0;
        m_data<=m_data;
    end
    else if (state == TX_IMAGE && !fifo_us_prog_full)begin
        m_cnt<=m_cnt+'d1;
        m_data<=m_data+'d1;
    end
    else begin
        m_cnt<=m_cnt;
        m_data<=m_data;
    end
end
//包计数器
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        package_cnt<='d0;
    else if (state == TX_VERIFY && package_cnt == MAX_N && !fifo_us_prog_full) begin
        package_cnt<='d0;
    end
    else if (state == TX_VERIFY) begin
        package_cnt<=package_cnt+'d1;
    end
    else
        package_cnt<=package_cnt;
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 状态机
//---------------------------------------------------------------------
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        state<='d0;
    else if (!fifo_us_prog_full) begin
        case (state)
        TX_IDLE      :
            if (tx_compress_mod_start)
                state<=TX_SYNC;
            else
                state<=state;
        TX_SYNC      : state <= TX_PACKEGE_H;
        TX_PACKEGE_H : state <= TX_PACKEGE_L;
        TX_PACKEGE_L : state <= TX_IMAGE;
        TX_IMAGE     :
            if (m_cnt == M - 1)
                state<=TX_VERIFY;
            else
                state<=state;
        TX_VERIFY    : state<=TX_IDLE;
        default:state<=state;
        endcase
    end
end

always@(*)begin
    case (state)
        TX_IDLE        : fifo_us_data_r <= 'h1234 ;
        TX_SYNC        : fifo_us_data_r <= 'hEB90 ;
        TX_PACKEGE_H   : fifo_us_data_r <= package_cnt[31:16] ;
        TX_PACKEGE_L   : fifo_us_data_r <= package_cnt[15:0] ;
        TX_IMAGE       : fifo_us_data_r <= m_data ;
        TX_VERIFY      : fifo_us_data_r <= verify_data ;
        default: fifo_us_data_r <= 'hc5bc;
    endcase
end

//校验位
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        verify_data<='d0;
    else if (!fifo_us_prog_full) begin
        case (state)
        TX_IDLE        : verify_data <= 'd0 ;
        TX_SYNC        : verify_data <= verify_data + fifo_us_data_r ;
        TX_PACKEGE_H   : verify_data <= verify_data + fifo_us_data_r ;
        TX_PACKEGE_L   : verify_data <= verify_data + fifo_us_data_r ;
        TX_IMAGE       : verify_data <= verify_data + fifo_us_data_r ;
        TX_VERIFY      : verify_data <= 'd0 ;
        default: verify_data <= 'd0 ;
        endcase
    end
end

always@(*)begin
    case (state)
        TX_SYNC,TX_PACKEGE_H,TX_PACKEGE_L,TX_IMAGE,TX_VERIFY: valid<='d1;
        default: valid<='d0;
    endcase
end
endmodule