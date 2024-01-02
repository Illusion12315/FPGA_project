module tx_send_prim_mod (
    input                               sys_clk_i                  ,
    input                               rst_n_i                    ,

    input                               tx_prim_mod_start          ,
    output reg                          valid                      ,
    input                               fifo_us_prog_full          ,
    //TX FIFO写
    output             [  15:0]         fifo_us_data                
);
//---------------------------------------------------------------------
// regs
//---------------------------------------------------------------------
reg                                     fifo_us_wrreq_r = 'd0      ;
reg                    [  15:0]         fifo_us_data_r = 'd0       ;
reg                    [  31:0]         frame_cnt = 'd0            ;
reg                    [  31:0]         package_cnt = 'd0          ;
reg                    [  15:0]         row_cnt = 'd0              ;
reg                    [  15:0]         m_cnt = 'd0                ;
reg                    [  15:0]         m_data = 'd0               ;
reg                    [   3:0]         state = 'd0                ;
reg                    [  15:0]         verify_data = 'd0          ;
//---------------------------------------------------------------------
// localparam
//---------------------------------------------------------------------
//TX状态
localparam                              TX_IDLE = 0                ;
localparam                              TX_SYNC1 = 1               ;
localparam                              TX_SYNC2 = 2               ;
localparam                              TX_PACKEGE_H = 3           ;
localparam                              TX_PACKEGE_L = 4           ;
localparam                              TX_FRAME_H = 5             ;
localparam                              TX_FRAME_L = 6             ;
localparam                              TX_ROW = 7                 ;
localparam                              TX_IMAGE = 8               ;
localparam                              TX_VERIFY = 9              ;

assign fifo_us_data = fifo_us_data_r;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计数器
//---------------------------------------------------------------------
//像素计数器
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        m_cnt<='d0;
        m_data<='d0;
    end
    else if (m_cnt == 8900 - 1) begin
        m_cnt<='d0;
        m_data<=m_data;
    end
    else if (state == TX_IMAGE && !fifo_us_prog_full) begin
        m_cnt<=m_cnt+'d1;
        m_data<=m_data+'d1;
    end
    else begin
        m_cnt<=m_cnt;
        m_data<=m_data;
    end
end
//行计数器
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        row_cnt<='d0;
    else if (row_cnt == 8900 && state == TX_VERIFY) begin
        row_cnt<='d0;
    end
    else if (state == TX_VERIFY && !fifo_us_prog_full) begin
        row_cnt<=row_cnt+'d1;
    end
    else
        row_cnt<=row_cnt;
end
//包计数器
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        package_cnt<='d0;
    else if (state == TX_VERIFY && !fifo_us_prog_full) begin
        package_cnt<=package_cnt+'d1;
    end
    else
        package_cnt<=package_cnt;
end
//帧计数器
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        frame_cnt<='d0;
    else if (row_cnt == 8900 && state == TX_VERIFY && !fifo_us_prog_full) begin
        frame_cnt<=frame_cnt+'d1;
    end
    else
        frame_cnt<=frame_cnt;
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
        TX_IDLE:
            if(tx_prim_mod_start)
                state<=TX_SYNC1;
            else
                state<=state;
        TX_SYNC1:state<=TX_SYNC2;
        TX_SYNC2:state<=TX_PACKEGE_H;
        TX_PACKEGE_H:state<=TX_PACKEGE_L;
        TX_PACKEGE_L:state<=TX_FRAME_H;
        TX_FRAME_H:state<=TX_FRAME_L;
        TX_FRAME_L:state<=TX_ROW;
        TX_ROW:state<=TX_IMAGE;
        TX_IMAGE:
            if (m_cnt == 8900 - 1) begin
                state<=TX_VERIFY;
            end
            else
                state<=state;
        TX_VERIFY: state<=TX_IDLE;
        default:state<=state;
        endcase
    end
end

always@(*)begin
    case (state)
        TX_IDLE        : fifo_us_data_r <= 'h1234 ;
        TX_SYNC1       : fifo_us_data_r <= 'hEB90 ;
        TX_SYNC2       : fifo_us_data_r <= 'hEB90 ;
        TX_PACKEGE_H   : fifo_us_data_r <= package_cnt[31:16] ;
        TX_PACKEGE_L   : fifo_us_data_r <= package_cnt[15:0] ;
        TX_FRAME_H     : fifo_us_data_r <= frame_cnt[31:16] ;
        TX_FRAME_L     : fifo_us_data_r <= frame_cnt[15:0] ;
        TX_ROW         : fifo_us_data_r <= row_cnt ;
        TX_IMAGE       : fifo_us_data_r <= m_data ;
        TX_VERIFY      : fifo_us_data_r <= verify_data ;
        default: fifo_us_data_r <= 'h1234;
    endcase
end

//valid
always@(*)begin
    case (state)
        TX_SYNC1       :valid <= 1'b1;
        TX_SYNC2       :valid <= 1'b1;
        TX_PACKEGE_H   :valid <= 1'b1;
        TX_PACKEGE_L   :valid <= 1'b1;
        TX_FRAME_H     :valid <= 1'b1;
        TX_FRAME_L     :valid <= 1'b1;
        TX_ROW         :valid <= 1'b1;
        TX_IMAGE       :valid <= 1'b1;
        TX_VERIFY      :valid <= 1'b1;
        default: valid<='d0;
    endcase
end

//校验位
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        verify_data<='d0;
    else if (!fifo_us_prog_full) begin
        case (state)
        TX_IDLE        : verify_data <= 'd0 ;
        TX_SYNC1       : verify_data <= verify_data + fifo_us_data_r ;
        TX_SYNC2       : verify_data <= verify_data + fifo_us_data_r ;
        TX_PACKEGE_H   : verify_data <= verify_data + fifo_us_data_r ;
        TX_PACKEGE_L   : verify_data <= verify_data + fifo_us_data_r ;
        TX_FRAME_H     : verify_data <= verify_data + fifo_us_data_r ;
        TX_FRAME_L     : verify_data <= verify_data + fifo_us_data_r ;
        TX_ROW         : verify_data <= verify_data + fifo_us_data_r ;
        TX_IMAGE       : verify_data <= verify_data + fifo_us_data_r ;
        TX_VERIFY      : verify_data <= 'd0 ;
        default: verify_data <= 'd0 ;
        endcase
    end

end
endmodule