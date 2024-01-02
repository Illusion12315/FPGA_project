
module blk2711_tx_warpper (
    input                               sys_clk_i                  ,
    input                               rst_n_i                    ,
    
    output reg         [  15:0]         send_data_num              ,
    //TX FIFO写
    output                              fifo_us_wrclk              ,
    output                              fifo_us_wrreq              ,
    output             [  15:0]         fifo_us_data               ,
    input                               fifo_us_prog_full          ,

    input                               tx_send_en_i               ,
    input                               data_mod_i                 ,//模式选择，0为原始模式，1为压缩模式
    
    input                               pw_rst_done                ,
    input                               frame_start_flag            
);
//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
wire                                    valid_prim                 ;
wire                                    valid_compress             ;
wire                   [  15:0]         wr_data0                   ;
wire                   [  15:0]         wr_data1                   ;
wire                                    pw_rst_done_r2             ;
wire                   [  15:0]         M_NUM                      ;
//---------------------------------------------------------------------
// regs
//---------------------------------------------------------------------
reg                                     tx_prim_mod_start          ;
reg                                     tx_compress_mod_start      ;
reg                                     fifo_us_wrreq_r = 'd0      ;
//---------------------------------------------------------------------
// 打两拍
//---------------------------------------------------------------------
beat_it_twice sync1 (sys_clk_i,pw_rst_done,pw_rst_done_r2);
//---------------------------------------------------------------------
// assign
//---------------------------------------------------------------------
assign fifo_us_wrclk = sys_clk_i;
assign fifo_us_wrreq = fifo_us_wrreq_r;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// TX
//---------------------------------------------------------------------
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if (!rst_n_i) begin
        send_data_num<='d8908;
    end
    else if (frame_start_flag) begin
        if (data_mod_i) begin
            send_data_num <= M_NUM;
        end
        else
            send_data_num <= 'd8908;
    end
    else
        send_data_num <= send_data_num;
end

//tx send mod
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        tx_prim_mod_start <= 'd0;
        tx_compress_mod_start <= 'd0;
    end
    else if (tx_send_en_i) begin
        if (data_mod_i) begin
            tx_compress_mod_start <= 'd1;
            tx_prim_mod_start <= 'd0;
        end
        else begin
            tx_compress_mod_start <= 'd0;
            tx_prim_mod_start <= 'd1;
        end
    end
    else begin
        tx_prim_mod_start <= 'd0;
        tx_compress_mod_start <= 'd0;
    end
end

always@(*)begin
    if (pw_rst_done_r2 && !fifo_us_prog_full
        && (valid_prim | valid_compress) )begin
        fifo_us_wrreq_r<=1'd1;
    end
    else
        fifo_us_wrreq_r<='d0;
end

assign fifo_us_data = (data_mod_i)?wr_data1:wr_data0;


tx_send_prim_mod  tx_send_prim_mod_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    .tx_prim_mod_start                 (tx_prim_mod_start         ),
    .valid                             (valid_prim                ),
    .fifo_us_prog_full                 (fifo_us_prog_full         ),
    .fifo_us_data                      (wr_data0                  ) 
);

tx_send_compress_mod tx_send_compress_mod_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),
    .tx_compress_mod_start             (tx_compress_mod_start     ),
    .valid                             (valid_compress            ),
    .M_NUM                             (M_NUM                     ),
    .fifo_us_prog_full                 (fifo_us_prog_full         ),
    .fifo_us_data                      (wr_data1                  ) 
);

endmodule


module beat_it_twice (
    input                               sys_clk_i                  ,
    input                               signal_i                   ,
    output                              signal_o                    
);
reg                                     signal_r1=0,signal_r2=0    ;

assign signal_o = signal_r2;
always @(posedge sys_clk_i) begin
    signal_r1 <= signal_i;
    signal_r2 <= signal_r1;
end
endmodule
// beat_it_twice sync1 (sys_clk_i,signal_i,signal_o);