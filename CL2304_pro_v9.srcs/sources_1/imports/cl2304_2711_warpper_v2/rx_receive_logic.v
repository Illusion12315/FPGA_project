module rx_receive_logic (
    input                               sys_clk_i                  ,
    input                               rst_n_i                    ,

    input                               data_mod_i                 ,

    input                               fifo_prog_full_ddr3_us     ,
    //debug
    input              [  15:0]         TX_Data                    ,
    input              [  15:0]         RX_Data                    ,
    input                               fifo_us_wrreq              ,
    input              [  15:0]         fifo_us_data               ,
    input                               fifo_us_prog_full          ,
    input                               frame_start_flag           ,
    input                               LOOP_EN                    ,

    output                              LED_R                      ,//led灯红
    output                              LED_G                      ,//led灯绿

    output                              fifo_ds_rdclk              ,
    output                              fifo_ds_rdreq_r            ,
    output reg                          fifo_ds_rdreq_o            ,
    input              [  15:0]         fifo_ds_q                  ,
    input                               fifo_ds_empty               

);
reg                    [   4:0]         rd_state = 'd0             ;
reg                    [  15:0]         state_cnt = 'd0            ;
reg                    [  15:0]         rd_m_cnt = 'd8908          ;
reg                    [  15:0]         veriy_cnt                  ;
reg                    [  15:0]         data_v_MB = 'd0            ;
reg                    [  31:0]         data_v_cnt = 'd0, time_cnt = 'd0;
reg                    [   7:0]         error_rd_cnt = 'd0         ;

localparam                              RD_IDLE        = 5'h0      ;
localparam                              RD_HEADER      = 5'h1      ;
localparam                              RD_DATA        = 5'h2      ;
localparam                              RD_TAIL        = 5'h3      ;

assign LED_G = (rd_state == RD_DATA)?'d1:'d0;
assign LED_R = (error_rd_cnt != 'd0)?'d1:'d0;
assign fifo_ds_rdclk = sys_clk_i;

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        rd_state        <= 'd0;
        state_cnt       <= 'd0;
    end
    else begin
        case(rd_state)
            RD_IDLE:begin
                state_cnt       <= 'd0;
                if(!fifo_ds_empty)begin
                    rd_state    <= RD_HEADER;
                end
            end
            
            RD_HEADER:begin                                         //0xFDF7
                if(fifo_ds_rdreq_o)begin
                    rd_state    <= RD_DATA;
                end
                else begin
                    rd_state    <= rd_state;
                end
            end

            RD_DATA:begin
                if(state_cnt == rd_m_cnt- 'd1 )begin
                    state_cnt   <= 'd0;
                    rd_state    <= RD_TAIL;
                end
                else if(fifo_ds_rdreq_r)begin
                    state_cnt   <= state_cnt + 1;
                    rd_state    <= rd_state;
                end
                else begin
                    state_cnt   <= state_cnt;
                    rd_state    <= rd_state;
                end
            end
 
            RD_TAIL: begin                                          //0xF7FD
                if(fifo_ds_rdreq_r)begin
                    rd_state    <= RD_HEADER;
                end
                else begin
                    rd_state    <= rd_state;
                end
            end
            
            default:begin
                rd_state    <= RD_IDLE;
                state_cnt   <= 'd0;
            end
        endcase
    end
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        rd_m_cnt<='d8908;
    else if (data_mod_i) begin
        if (state_cnt == 1 && fifo_ds_q != 16'heb90) begin
            rd_m_cnt<='d1028;
        end
        else
        if (state_cnt == 1 && fifo_ds_q == 16'heb90) begin
            rd_m_cnt<='d8900;
        end
        else
            rd_m_cnt<=rd_m_cnt;
    end
    else
        rd_m_cnt<='d8908;
end


always@(*)begin
    if (rd_state == RD_HEADER) begin
        if (fifo_ds_q == 16'hFDF7 && fifo_ds_rdreq_r) begin
            fifo_ds_rdreq_o<='d1;
        end
        else
            fifo_ds_rdreq_o<='d0;
    end
    else
        fifo_ds_rdreq_o<=fifo_ds_rdreq_r;
end

assign fifo_ds_rdreq_r = !fifo_ds_empty && !fifo_prog_full_ddr3_us;

// always@(posedge sys_clk_i) begin
//     if((rd_state == RD_HEADER)|| (rd_state == RD_DATA)) begin
//         fifo_ds_rdreq_r <= !fifo_ds_empty && !fifo_prog_full_ddr3_us;
//     end
//     else begin
//         fifo_ds_rdreq_r <= 'b0;
//     end
// end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        veriy_cnt<='d0;
    else if (rd_state == RD_TAIL) begin
        veriy_cnt<='d0;
    end
    else if (rd_state == RD_DATA && state_cnt < rd_m_cnt && !fifo_ds_empty) begin
        veriy_cnt<=veriy_cnt+fifo_ds_q;
    end
    else
        veriy_cnt<=veriy_cnt;
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        error_rd_cnt<='d0;
    else if (rd_state == RD_DATA && veriy_cnt != fifo_ds_q && state_cnt == rd_m_cnt-1) begin
        error_rd_cnt<=error_rd_cnt+'d1;
    end
    else
        error_rd_cnt<=error_rd_cnt;
end

always@(posedge sys_clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        data_v_MB   <=  'd0;
        data_v_cnt  <=  'd0;
        time_cnt    <=  'd0;
    end
    else begin
        if(time_cnt == 'd99_999_999)begin
            data_v_MB   <=  data_v_cnt >> 19;                       // 速率单位： MB/s   
            data_v_cnt  <=  'd0;
            time_cnt    <=  'd0;
        end
        else begin
            data_v_MB   <=  data_v_MB;
            time_cnt    <=  time_cnt + 1'd1;
            if(fifo_ds_rdreq_r)begin
                data_v_cnt    <=  data_v_cnt + 1'd1;
            end
            else begin
                data_v_cnt    <=  data_v_cnt;
            end
        end
    end
end
//---------------------------------------------------------------------
//debug
//---------------------------------------------------------------------   
ila_debug u_ila_debug
    (
    .clk                               (sys_clk_i                 ),// input wire clk
    .probe0                            (fifo_ds_rdreq_o           ),// input wire [0:0]  probe0  
    .probe1                            (fifo_us_wrreq             ),// input wire [0:0]  probe1 
    .probe2                            (fifo_us_data              ),// input wire [15:0]  probe2 
    .probe3                            (fifo_us_prog_full         ),// input wire [0:0]  probe3 
    .probe4                            (fifo_ds_rdreq_r           ),// input wire [0:0]  probe4 
    .probe5                            (fifo_ds_q                 ),// input wire [15:0]  probe5 
    .probe6                            (fifo_ds_empty             ),// input wire [0:0]  probe6 
    .probe7                            (veriy_cnt                 ),// input wire [15:0]  probe7 
    .probe8                            (error_rd_cnt              ),// input wire [7:0]  probe8 
    .probe9                            ({LOOP_EN,data_mod_i,data_v_MB[13:0]}),// input wire [15:0]  probe9 
    .probe10                           (rd_state                  ),// input wire [4:0]  probe9 
    .probe11                           (state_cnt                 ),// input wire [15:0]  probe9 
    .probe12                           (TX_Data                   ) 
    );
endmodule