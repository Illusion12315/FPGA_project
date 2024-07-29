`timescale 1ns / 1ps
module sx_medium_speed (
    input                               sys_clk_i                  ,//clk163m84
    input                               rst_n_i                    ,//rst_n_i
    
    input              [   7:0]         yw_data                    ,
    input                               yw_data_valid              ,

    input                               info_start_flag_i          ,//lvds_rx_data模块引出的开始信号
    input              [   7:0]         info_type_i                ,//帧头第一字节
    // input              [  15:0]         info_fram_leng             ,
    input              [  15:0]         channel_mang_i             ,//信道控制信息
    //-------------------------读通道-------------------------------
    input                               uplink_40ms                ,//40ms脉冲信号输入
    input              [  31:0]         ctrl_timeslot              ,//三种时隙，暂用VIO控制
    input              [  31:0]         busi_timeslot              ,//三种时隙，暂用VIO控制
    input              [  31:0]         circuit_timeslot           ,//三种时隙，暂用VIO控制

    input              [  15:0]         tx_data1_length_out        ,//固定控制数据请求
    input                               tx_data1_ask_out           ,//固定控制数据请求
    output             [   7:0]         tx_data1_in                ,//固定控制数据请求
    output                              tx_data1_valid_in          ,//固定控制数据请求

    input              [  15:0]         tx_data2_length_out        ,//ctrl busi circuit
    input                               tx_data2_ask_out           ,//ctrl busi circuit
    output             [   7:0]         tx_data2_in                ,//ctrl busi circuit
    output                              tx_data2_valid_in          ,//ctrl busi circuit

    output             [  15: 0]        ctrl_data_count            ,
    output             [  15: 0]        busi_data_count            ,
    output             [  15: 0]        circuit_data_count         ,
    
    output             [   7:0]         up_gear                     //档位
);
wire                   [   3:0]         info_Low                   ;
wire                   [   2:0]         frame_type                 ;
wire                                    yw_data_valid_nedege       ;
wire                   [  15:0]         data_count[3:0]            ;

reg                    [  15:0]         tx_data1_length_out_r,tx_data1_length_out_r2;
reg                                     tx_data1_ask_out_r,tx_data1_ask_out_r2;
reg                    [  15:0]         tx_data2_length_out_r,tx_data2_length_out_r2;
reg                                     tx_data2_ask_out_r,tx_data2_ask_out_r2;
reg                                     yw_data_valid_r1,yw_data_valid_r2;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// sync_and_assign
//---------------------------------------------------------------------
assign info_Low = info_type_i[3:0];
assign up_gear = channel_mang_i[10:3];                              //
assign frame_type = channel_mang_i[2:0];
assign yw_data_valid_nedege = ~yw_data_valid_r1 & yw_data_valid_r2;

assign ctrl_data_count = data_count[1];
assign busi_data_count = data_count[2];
assign circuit_data_count = data_count[3];

always @(posedge sys_clk_i)begin
    tx_data1_length_out_r     <= tx_data1_length_out;
    tx_data1_length_out_r2    <= tx_data1_length_out_r;
    tx_data1_ask_out_r        <= tx_data1_ask_out;
    tx_data1_ask_out_r2       <= tx_data1_ask_out_r;
end

always @(posedge sys_clk_i)begin
    tx_data2_length_out_r     <= tx_data2_length_out;
    tx_data2_length_out_r2    <= tx_data2_length_out_r;
    tx_data2_ask_out_r        <= tx_data2_ask_out;
    tx_data2_ask_out_r2       <= tx_data2_ask_out_r;
end

always @(posedge sys_clk_i)begin
    yw_data_valid_r1 <= yw_data_valid;
    yw_data_valid_r2 <= yw_data_valid_r1;
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计算长度
//---------------------------------------------------------------------
reg [15:0] length_cnt;
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        length_cnt<='d0;
    else if (yw_data_valid_nedege) begin
        length_cnt<='d0;
    end
    else if (yw_data_valid) begin
        length_cnt<=length_cnt+'d1;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 转成四路写入FIFO
//---------------------------------------------------------------------
reg                                     GD_ctrl_sdl_wren           ;//固定控制SDL写使能
reg                    [   7:0]         GD_ctrl_sdl_data           ;//固定控制SDL写数据

reg                                     ctrl_sdl_wren              ;//控制SDL写使能
reg                    [   7:0]         ctrl_sdl_data              ;//控制SDL写数据

reg                                     yw_sdl_wren                ;//业务SDL写使能
reg                    [   7:0]         yw_sdl_data                ;//业务SDL写数据

reg                                     DL_wren                    ;//电路写使能
reg                    [   7:0]         DL_data                    ;//电路写数据

always @(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        GD_ctrl_sdl_wren<='d0;
        GD_ctrl_sdl_data<='d0;
        ctrl_sdl_wren<='d0;
        ctrl_sdl_data<='d0;
        yw_sdl_wren<='d0;
        yw_sdl_data<='d0;
        DL_wren<='d0;
        DL_data<='d0;
    end
    else if (~info_start_flag_i) begin
        if (info_Low == 4'hB) begin
            case (frame_type)
                3'd1:begin
                    GD_ctrl_sdl_wren<=yw_data_valid;
                    GD_ctrl_sdl_data<=yw_data;
                    //其他置0
                    ctrl_sdl_wren<='d0;
                    ctrl_sdl_data<='d0;
                    yw_sdl_wren<='d0;
                    yw_sdl_data<='d0;
                    DL_wren<='d0;
                    DL_data<='d0;
                end
                3'd2:begin
                    ctrl_sdl_wren<=yw_data_valid;
                    ctrl_sdl_data<=yw_data;
                    //其他置0
                    GD_ctrl_sdl_wren<='d0;
                    GD_ctrl_sdl_data<='d0;
                    yw_sdl_wren<='d0;
                    yw_sdl_data<='d0;
                    DL_wren<='d0;
                    DL_data<='d0;
                end
                3'd3:begin
                    yw_sdl_wren<=yw_data_valid;
                    yw_sdl_data<=yw_data;
                    //其他置0
                    GD_ctrl_sdl_wren<='d0;
                    GD_ctrl_sdl_data<='d0;
                    ctrl_sdl_wren<='d0;
                    ctrl_sdl_data<='d0;
                    DL_wren<='d0;
                    DL_data<='d0;
                end
                default:begin
                    GD_ctrl_sdl_wren<='d0;
                    GD_ctrl_sdl_data<='d0;
                    ctrl_sdl_wren<='d0;
                    ctrl_sdl_data<='d0;
                    yw_sdl_wren<='d0;
                    yw_sdl_data<='d0;
                    DL_wren<='d0;
                    DL_data<='d0;
                end
            endcase
        end
        else if (info_Low == 4'hD) begin
            DL_wren<=yw_data_valid;
            DL_data<=yw_data;
            //其他置0
            GD_ctrl_sdl_wren<='d0;
            GD_ctrl_sdl_data<='d0;
            ctrl_sdl_wren<='d0;
            ctrl_sdl_data<='d0;
            yw_sdl_wren<='d0;
            yw_sdl_data<='d0;
        end
        else begin
            GD_ctrl_sdl_wren<='d0;
            GD_ctrl_sdl_data<='d0;
            ctrl_sdl_wren   <='d0;
            ctrl_sdl_data   <='d0;
            yw_sdl_wren     <='d0;
            yw_sdl_data     <='d0;
            DL_wren         <='d0;
            DL_data         <='d0;
        end
    end
    else begin
        GD_ctrl_sdl_wren<=GD_ctrl_sdl_wren;
        GD_ctrl_sdl_data<=GD_ctrl_sdl_data;
        ctrl_sdl_wren   <=ctrl_sdl_wren   ;
        ctrl_sdl_data   <=ctrl_sdl_data   ;
        yw_sdl_wren     <=yw_sdl_wren     ;
        yw_sdl_data     <=yw_sdl_data     ;
        DL_wren         <=DL_wren         ;
        DL_data         <=DL_data         ;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 转成四路将长度写入FIFO(所有数据写完之后)
//---------------------------------------------------------------------
reg                                     GD_ctrl_sdl_length_wren    ;
reg                    [  15:0]         GD_ctrl_sdl_length_data    ;

reg                                     ctrl_sdl_length_wren       ;
reg                    [  15:0]         ctrl_sdl_length_data       ;

reg                                     yw_sdl_length_wren         ;
reg                    [  15:0]         yw_sdl_length_data         ;

reg                                     DL_length_wren             ;
reg                    [  15:0]         DL_length_data             ;

always @(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        GD_ctrl_sdl_length_wren<='d0;
        GD_ctrl_sdl_length_data<='d0;
        ctrl_sdl_length_wren   <='d0;
        ctrl_sdl_length_data   <='d0;
        yw_sdl_length_wren     <='d0;
        yw_sdl_length_data     <='d0;
        DL_length_wren         <='d0;
        DL_length_data         <='d0;
    end
    else if (yw_data_valid_nedege) begin
        if (info_Low == 4'hB) begin
            case (frame_type)
                3'd1:begin
                    GD_ctrl_sdl_length_wren<='d1;
                    GD_ctrl_sdl_length_data<=length_cnt;
                    //其他置0
                    ctrl_sdl_length_wren   <='d0;
                    ctrl_sdl_length_data   <='d0;
                    yw_sdl_length_wren     <='d0;
                    yw_sdl_length_data     <='d0;
                    DL_length_wren         <='d0;
                    DL_length_data         <='d0;
                end
                3'd2:begin
                    ctrl_sdl_length_wren   <='d1;
                    ctrl_sdl_length_data   <=length_cnt;
                    //其他置0
                    GD_ctrl_sdl_length_wren<='d0;
                    GD_ctrl_sdl_length_data<='d0;
                    yw_sdl_length_wren     <='d0;
                    yw_sdl_length_data     <='d0;
                    DL_length_wren         <='d0;
                    DL_length_data         <='d0;
                end
                3'd3:begin
                    yw_sdl_length_wren     <='d1;
                    yw_sdl_length_data     <=length_cnt;
                    //其他置0
                    GD_ctrl_sdl_length_wren<='d0;
                    GD_ctrl_sdl_length_data<='d0;
                    ctrl_sdl_length_wren   <='d0;
                    ctrl_sdl_length_data   <='d0;
                    DL_length_wren         <='d0;
                    DL_length_data         <='d0;
                end
                default:begin
                    GD_ctrl_sdl_length_wren<='d0;
                    GD_ctrl_sdl_length_data<='d0;
                    ctrl_sdl_length_wren   <='d0;
                    ctrl_sdl_length_data   <='d0;
                    yw_sdl_length_wren     <='d0;
                    yw_sdl_length_data     <='d0;
                    DL_length_wren         <='d0;
                    DL_length_data         <='d0;
                end
            endcase
        end
        else if (info_Low == 4'hD) begin
            DL_length_wren         <='d1;
            DL_length_data         <=length_cnt;
            //其他置0
            GD_ctrl_sdl_length_wren<='d0;
            GD_ctrl_sdl_length_data<='d0;
            ctrl_sdl_length_wren   <='d0;
            ctrl_sdl_length_data   <='d0;
            yw_sdl_length_wren     <='d0;
            yw_sdl_length_data     <='d0;
        end
        else begin
            GD_ctrl_sdl_length_wren<='d0;
            GD_ctrl_sdl_length_data<='d0;
            ctrl_sdl_length_wren   <='d0;
            ctrl_sdl_length_data   <='d0;
            yw_sdl_length_wren     <='d0;
            yw_sdl_length_data     <='d0;
            DL_length_wren         <='d0;
            DL_length_data         <='d0;
        end
    end
    else begin
        GD_ctrl_sdl_length_wren<='d0;                               //GD_ctrl_sdl_length_wren;
        GD_ctrl_sdl_length_data<='d0;                               //GD_ctrl_sdl_length_data;
        ctrl_sdl_length_wren   <='d0;                               //ctrl_sdl_length_wren   ;
        ctrl_sdl_length_data   <='d0;                               //ctrl_sdl_length_data   ;
        yw_sdl_length_wren     <='d0;                               //yw_sdl_length_wren     ;
        yw_sdl_length_data     <='d0;                               //yw_sdl_length_data     ;
        DL_length_wren         <='d0;                               //DL_length_wren         ;
        DL_length_data         <='d0;                               //DL_length_data         ;
    end
end
//---------------------------------------------------------------------
// length_fifo
//---------------------------------------------------------------------
//---------------------------------------------------------------------
// 转成四路将长度和数据写入FIFO
//---------------------------------------------------------------------
localparam                              IDLE = 0                   ;
localparam                              READ_DATA = 1              ;
localparam                              READ_NEXT_LENTH = 2        ;
//data_fifo
wire                   [   3:0]         wr_en                      ;
wire                   [   7:0]         wr_data[3:0]               ;
wire                   [   3:0]         wr_prog_full               ;
wire                   [   3:0]         rd_en                      ;
wire                   [   7:0]         rd_data[3:0]               ;
wire                   [   3:0]         rd_empty                   ;
//length_fifo
wire                   [   3:0]         wr_length_en               ;
wire                   [  15:0]         wr_length_data[3:0]        ;
wire                   [   3:0]         wr_length_prog_full        ;
wire                   [   3:0]         rd_length_empty            ;
//send_fifo
wire                   [   3:0]         send_fifo_prog_full        ;
wire                   [   3:0]         send_fifo_rd_en            ;
wire                   [  31:0]         send_fifo_rd_data          ;
wire                   [   3:0]         send_fifo_empty            ;

//
reg                    [   1:0]         state[3:0]                 ;

reg                    [  15:0]         rd_data_cnt[3:0]           ;
wire                   [  15:0]         rd_data_length[3:0]        ;


assign {wr_en[0],wr_en[1],wr_en[2],wr_en[3]} = {GD_ctrl_sdl_wren,ctrl_sdl_wren,yw_sdl_wren,DL_wren};
assign {wr_data[0],wr_data[1],wr_data[2],wr_data[3]} = {GD_ctrl_sdl_data,ctrl_sdl_data,yw_sdl_data,DL_data};

assign {wr_length_en[0],wr_length_en[1],wr_length_en[2],wr_length_en[3]} = 
            {GD_ctrl_sdl_length_wren,ctrl_sdl_length_wren,yw_sdl_length_wren,DL_length_wren};

assign {wr_length_data[0],wr_length_data[1],wr_length_data[2],wr_length_data[3]}
            = {GD_ctrl_sdl_length_data,ctrl_sdl_length_data,yw_sdl_length_data,DL_length_data};

generate
    begin
        genvar i;
        for(i=0;i<4;i=i+1)
            begin:sdl
                // 该FIFO深度是32768！！！！！
                fifo_65536x8b data_fifo_32768x8b (                  
                    .clk                               (sys_clk_i                 ),// input wire clk
                    .srst                              (!rst_n_i                  ),// input wire srst

                    .wr_en                             (wr_en[i]&~wr_prog_full[i] ),// input wire wr_en
                    .din                               (wr_data[i]                ),// input wire [7 : 0] din
                    .prog_full                         (wr_prog_full[i]           ),// output wire prog_full
                    .data_count                        (data_count[i]             ),// output wire [15 : 0] data_count
                    .full                              (                          ),// output wire full

                    .rd_en                             (rd_en[i]                  ),// input wire rd_en
                    .dout                              (rd_data[i]                ),// output wire [7 : 0] dout
                    .empty                             (rd_empty[i]               ) // output wire empty
                );
                // 该FIFO深度是128！！！！！
                fifo_64x16b length_fifo_128x16b (                   
                    .clk                               (sys_clk_i                 ),// input wire clk
                    .srst                              (!rst_n_i                  ),// input wire srst

                    .wr_en                             (wr_length_en[i]&~wr_length_prog_full[i]),// input wire wr_en
                    .din                               (wr_length_data[i]         ),// input wire [15 : 0] din
                    .prog_full                         (wr_length_prog_full[i]    ),// output wire prog_full
                    .full                              (                          ),// output wire full

                    .rd_en                             (state[i]==READ_NEXT_LENTH&~rd_length_empty[i]),// input wire rd_en
                    .dout                              (rd_data_length[i]         ),// output wire [15 : 0] dout
                    .empty                             (rd_length_empty[i]        ) // output wire empty
                );
                // ********************************************************************************** // 
                //---------------------------------------------------------------------
                // 写入取一SDL存入后级FIFO
                //---------------------------------------------------------------------
                always@(posedge sys_clk_i or negedge rst_n_i)begin
                    if(!rst_n_i)
                        state[i]<=IDLE;
                    else case (state[i])
                        IDLE:
                            if (send_fifo_empty[i]&&rd_data_length[i] != 'd0&&!rd_length_empty[i])
                                state[i]<=READ_DATA;
                        READ_DATA: 
                            if (rd_data_cnt[i] == rd_data_length[i] - 'd1)
                                state[i]<=READ_NEXT_LENTH;
                        READ_NEXT_LENTH: state[i]<=IDLE;
                        default: state[i]<=IDLE;
                    endcase
                end
                
                assign rd_en[i] = (state[i] == READ_DATA && ~rd_empty[i])? 'd1:'d0;

                always@(posedge sys_clk_i or negedge rst_n_i)begin
                    if(!rst_n_i)
                        rd_data_cnt[i]<='d0;
                    else if (rd_data_cnt[i] == rd_data_length[i] - 'd1) begin
                        rd_data_cnt[i]<='d0;
                    end
                    else if (rd_en[i]) begin
                        rd_data_cnt[i]<=rd_data_cnt[i]+'d1;
                    end
                end

                fifo_2048x8b send_fifo (
                    .clk                               (sys_clk_i                 ),// input wire clk
                    .srst                              (!rst_n_i                  ),// input wire srst

                    .wr_en                             (rd_en[i]                  ),// input wire wr_en
                    .din                               (rd_data[i]                ),// input wire [7 : 0] din
                    .prog_full                         (send_fifo_prog_full[i]    ),// output wire prog_full
                    .full                              (                          ),// output wire full

                    .rd_en                             (send_fifo_rd_en[i]        ),// input wire rd_en
                    .dout                              (send_fifo_rd_data[7+8*i:8*i]),// output wire [7 : 0] dout
                    .empty                             (send_fifo_empty[i]        ) // output wire empty
                );
            end
    end
endgenerate
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 例化
//---------------------------------------------------------------------
sx_send  sx_send_inst (
    .sys_clk_i                         (sys_clk_i                 ),
    .rst_n_i                           (rst_n_i                   ),

    .ctrl_timeslot                     (ctrl_timeslot             ),
    .busi_timeslot                     (busi_timeslot             ),
    .circuit_timeslot                  (circuit_timeslot          ),
    .uplink_40ms                       (uplink_40ms               ),
    .up_gear                           (up_gear                   ),//不能轻易变，需等待FIFO数全部被取完才能变

    .tx_data1_length_out               (tx_data1_length_out_r2    ),
    .tx_data1_ask_out                  (tx_data1_ask_out_r2       ),
    .tx_data1_in                       (tx_data1_in               ),
    .tx_data1_valid_in                 (tx_data1_valid_in         ),

    .tx_data2_length_out               (tx_data2_length_out_r2    ),
    .tx_data2_ask_out                  (tx_data2_ask_out_r2       ),
    .tx_data2_in                       (tx_data2_in               ),
    .tx_data2_valid_in                 (tx_data2_valid_in         ),

    .send_fifo_rd_en                   (send_fifo_rd_en           ),
    .send_fifo_rd_data                 (send_fifo_rd_data         ),
    .send_fifo_empty                   (send_fifo_empty           ) 
  );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
ila_sx_data_debug ila_sx_data_debug_inst (
    .clk                               (sys_clk_i                 ),// input wire clk

    .probe0                            (info_start_flag_i         ),// input wire [0:0]  probe0  
    .probe1                            (info_type_i               ),// input wire [7:0]  probe1 
    .probe2                            (channel_mang_i            ),// input wire [15:0]  probe2
    .probe3                            (yw_data_valid             ),// input wire [0:0]  probe3 
    .probe4                            (yw_data                   ),// input wire [7:0]  probe4 
    .probe5                            (wr_en                     ),// input wire [3:0]  probe5 
    .probe6                            ({wr_data[3],wr_data[2],wr_data[1],wr_data[0]}),// input wire [31:0]  probe6 
    .probe7                            (wr_prog_full              ),// input wire [3:0]  probe7   
    .probe8                            (rd_en                     ),// input wire [3:0]  probe8   
    .probe9                            ({rd_data[3],rd_data[2],rd_data[1],rd_data[0]}),// input wire [31:0]  probe9 
    .probe10                           (rd_empty                  ),// input wire [3:0]  probe10 
    .probe11                           (wr_length_en              ),// input wire [3:0]  probe11 
    .probe12                           ({wr_length_data[3],wr_length_data[2],wr_length_data[1],wr_length_data[0]}),// input wire [63:0]  probe12 
    .probe13                           (wr_length_prog_full       ),// input wire [3:0]  probe13  
    .probe14                           (rd_length_empty           ),// input wire [3:0]  probe14  
    .probe15                           (send_fifo_prog_full       ),// input wire [3:0]  probe15  
    .probe16                           (send_fifo_rd_en           ),// input wire [3:0]  probe16  
    .probe17                           (send_fifo_rd_data         ),// input wire [31:0]  probe17 
    .probe18                           (send_fifo_empty           ),// input wire [3:0]  probe18  
    .probe19                           ({state[3],state[2],state[1],state[0]}) // input wire [7:0]  probe19
);
endmodule