`timescale 1ns / 1ps
module sx_send (
    input                               sys_clk_i                  ,//163.84M
    input                               rst_n_i                    ,

    input              [  31:0]         ctrl_timeslot              ,//三种时隙，暂用VIO控制
    input              [  31:0]         busi_timeslot              ,//三种时隙，暂用VIO控制
    input              [  31:0]         circuit_timeslot           ,//三种时隙，暂用VIO控制

    input                               uplink_40ms                ,//40ms脉冲信号输入
    input              [   7:0]         up_gear                    ,

    input              [  15:0]         tx_data2_length_out        ,//ctrl busi circuit
    input                               tx_data2_ask_out           ,//ctrl busi circuit
    output reg         [   7:0]         tx_data2_in                ,//ctrl busi circuit
    output reg                          tx_data2_valid_in          ,//ctrl busi circuit

    input              [  15:0]         tx_data1_length_out        ,//固定控制数据请求
    input                               tx_data1_ask_out           ,//固定控制数据请求
    output reg         [   7:0]         tx_data1_in                ,//固定控制数据请求
    output reg                          tx_data1_valid_in          ,//固定控制数据请求

    output reg         [   3:0]         send_fifo_rd_en            ,
    input              [  31:0]         send_fifo_rd_data          ,
    input              [   3:0]         send_fifo_empty             
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// according to uplink_40ms, produce 32 1.2ms pluse
//---------------------------------------------------------------------
localparam                              PERIOD_CNT = 196608 - 1    ;//196608 - 1 b    
wire                                    uplink_40ms_flag           ;
wire                                    uplink_1ms2_flag           ;

// wire                   [  31:0]         ctrl_timeslot              ;//VIO debug
// wire                   [  31:0]         busi_timeslot              ;//VIO debug
// wire                   [  31:0]         circuit_timeslot           ;//VIO debug

reg                                     uplink_40ms_r1,uplink_40ms_r2;
reg                    [  23:0]         pluse_period_cnt           ;
reg                    [   4:0]         pluse_cnt                  ;
reg                                     pluse_state                ;

assign uplink_1ms2_flag = (pluse_period_cnt == PERIOD_CNT-1)?'d1:'d0;//1.2ms flag
assign uplink_40ms_flag = uplink_40ms_r1 & ~uplink_40ms_r2;         //40ms flag

always@(posedge sys_clk_i)begin
    uplink_40ms_r1<=uplink_40ms;
    uplink_40ms_r2<=uplink_40ms_r1;
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        pluse_state<='d0;
    else case (pluse_state)
        'd0: if (uplink_40ms_flag) begin
            pluse_state<='d1;
        end
        'd1: if (pluse_period_cnt == PERIOD_CNT-1 && pluse_cnt == 'd31) begin
            pluse_state<='d0;
        end
        default: pluse_state<='d0;
    endcase
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        pluse_period_cnt<='d0;
    else if (pluse_period_cnt == PERIOD_CNT-1) begin
        pluse_period_cnt<='d0;
    end
    else if (pluse_state) begin
        pluse_period_cnt<=pluse_period_cnt+'d1;
    end
    else
        pluse_period_cnt<='d0;
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        pluse_cnt<='d0;
    else if (uplink_1ms2_flag) begin
        pluse_cnt<=pluse_cnt+'d1;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// length
//---------------------------------------------------------------------
reg                    [   9:0]         ask_length = 'd0           ;

always@(posedge sys_clk_i)begin
    case (up_gear)
        8'hCA: ask_length <= 'd10;
        8'hC7: ask_length <= 'd20;
        8'hC6: ask_length <= 'd40;
        8'hC5: ask_length <= 'd40;
        8'hC4: ask_length <= 'd80;
        8'hC3: ask_length <= 'd80;
        8'hC2: ask_length <= 'd160;
        8'hC1: ask_length <= 'd160;
        8'hC0: ask_length <= 'd320;
        default: ask_length <= 'd0;
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 状态机
//---------------------------------------------------------------------
localparam                              IDLE = 'd0                 ;
localparam                              CHOOSE = 'd1               ;
localparam                              READ_CTRL = 'd2            ;
localparam                              READ_BUSI = 'd3            ;
localparam                              READ_CIRCUIT = 'd4         ;
localparam                              READ_CTRL_BUAA = 'd5       ;
localparam                              READ_BUSI_BUAA = 'd6       ;
localparam                              READ_CIRCUIT_BUAA = 'd7    ;

reg                    [   2:0]         cur_state                  ;
reg                    [   2:0]         next_state                 ;

reg                    [  15:0]         rd_cnt                     ;

wire                   [   4:0]         pluse_cnt_sub_one          ;

assign pluse_cnt_sub_one = pluse_cnt - 'd1;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 控制通道,业务通道,电路通道:前三种情况，用时隙控制
//---------------------------------------------------------------------
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
        IDLE:
            if (uplink_1ms2_flag && tx_data2_ask_out)
                next_state<=CHOOSE;
            else
                next_state<=IDLE;
        CHOOSE:
            case ({ctrl_timeslot[pluse_cnt_sub_one],busi_timeslot[pluse_cnt_sub_one],circuit_timeslot[pluse_cnt_sub_one]})
                3'b100:
                    if (send_fifo_empty[1])                         //控制通道
                        next_state<=IDLE;
                    else
                        next_state<=READ_CTRL;
                3'b010:
                    if (send_fifo_empty[2])                         //业务通道
                        next_state<=IDLE;
                    else
                        next_state<=READ_BUSI;
                3'b001:
                    if (send_fifo_empty[3])                         //电路通道
                        next_state<=IDLE;
                    else
                        next_state<=READ_CIRCUIT;
                default:next_state<=IDLE;
            endcase
        //直接读那么多的数,空了就跳走
        READ_CTRL:
            if (rd_cnt >= ask_length + 3)
                next_state<=IDLE;
            else if (send_fifo_empty[1])
                next_state<=READ_CTRL_BUAA;
            else
                next_state<=READ_CTRL;
        READ_BUSI:
            if (rd_cnt >= ask_length + 3)
                next_state<=IDLE;
            else if (send_fifo_empty[2])
                next_state<=READ_BUSI_BUAA;
            else
                next_state<=READ_BUSI;
        READ_CIRCUIT:
            if (rd_cnt >= ask_length + 3)
                next_state<=IDLE;
            else if (send_fifo_empty[3])
                next_state<=READ_BUSI_BUAA;
            else
                next_state<=READ_CIRCUIT;
        //需要补AA
        READ_CTRL_BUAA:
            if (rd_cnt >= ask_length + 3)
                next_state<=IDLE;
            else
                next_state<=READ_CTRL_BUAA;
        READ_BUSI_BUAA:
            if (rd_cnt >= ask_length + 3)
                next_state<=IDLE;
            else
                next_state<=READ_BUSI_BUAA;
        READ_CIRCUIT_BUAA:
            if (rd_cnt >= ask_length + 3)
                next_state<=IDLE;
            else
                next_state<=READ_CIRCUIT_BUAA;
        default:next_state<=IDLE;
    endcase
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        rd_cnt<='d0;
    else if (rd_cnt >= ask_length + 3) begin
        rd_cnt<='d0;
    end
    else case (cur_state)
        READ_CTRL,READ_BUSI,READ_CIRCUIT,READ_CTRL_BUAA,
            READ_BUSI_BUAA,READ_CIRCUIT_BUAA:
                rd_cnt<=rd_cnt+'d1;
        default: rd_cnt<='d0;
    endcase
end

always@(*)begin
    case (cur_state)
        READ_CTRL:
            if (rd_cnt>1 && rd_cnt <= ask_length + 1)
                send_fifo_rd_en[1] <= ~send_fifo_empty[1];
            else
                send_fifo_rd_en[1] <= 'd0;
        default:send_fifo_rd_en[1] <= 'd0;
    endcase
end

always@(*)begin
    case (cur_state)
        READ_BUSI:
            if (rd_cnt>1 && rd_cnt <= ask_length + 1)
                send_fifo_rd_en[2] <= ~send_fifo_empty[2];
            else
                send_fifo_rd_en[2] <= 'd0;
        default:send_fifo_rd_en[2] <= 'd0;
    endcase
end

always@(*)begin
    case (cur_state)
        READ_CIRCUIT:
            if (rd_cnt>1 && rd_cnt <= ask_length + 1)
                send_fifo_rd_en[3] <= ~send_fifo_empty[3];
            else
                send_fifo_rd_en[3] <= 'd0;
        default:send_fifo_rd_en[3] <= 'd0;
    endcase
end
                
always@(*)begin
    case (cur_state)
        READ_CTRL,READ_BUSI,READ_CIRCUIT,READ_CTRL_BUAA,
            READ_BUSI_BUAA,READ_CIRCUIT_BUAA:
                tx_data2_valid_in<='d1;
        default: tx_data2_valid_in<='d0;
    endcase
end

always@(*)begin
    case (cur_state)
        READ_CTRL: begin
            if (send_fifo_empty[1])
                tx_data2_in<='hAA;                                  //防止最后一位错误
            else case (rd_cnt)
                'd0: tx_data2_in<='hFF;
                'd1: tx_data2_in<={3'd0,pluse_cnt_sub_one};
                ask_length + 2: tx_data2_in<='hAA;
                ask_length + 3: tx_data2_in<='h55;
                default: tx_data2_in <= send_fifo_rd_data[15:8];
            endcase
        end
        READ_BUSI: begin
            if (send_fifo_empty[2])
                tx_data2_in<='hAA;
            else case (rd_cnt)
                'd0: tx_data2_in<='hFF;
                'd1: tx_data2_in<={3'd0,pluse_cnt_sub_one};
                ask_length + 2: tx_data2_in<='hAA;
                ask_length + 3: tx_data2_in<='h55;
                default: tx_data2_in <= send_fifo_rd_data[23:16];
            endcase
        end
        READ_CIRCUIT: begin
            if (send_fifo_empty[3])
                tx_data2_in<='hAA;
            else case (rd_cnt)
                'd0: tx_data2_in<='hFF;
                'd1: tx_data2_in<={3'd0,pluse_cnt_sub_one};
                ask_length + 2: tx_data2_in<='hAA;
                ask_length + 3: tx_data2_in<='h55;
                default: tx_data2_in <= send_fifo_rd_data[31:24];
            endcase
        end
        READ_CTRL_BUAA,READ_BUSI_BUAA,READ_CIRCUIT_BUAA: begin
            case (rd_cnt)
                'd0: tx_data2_in<='hFF;
                'd1: tx_data2_in<={3'd0,pluse_cnt_sub_one};
                ask_length + 2: tx_data2_in<='hAA;
                ask_length + 3: tx_data2_in<='h55;
                default: tx_data2_in <= 'hAA;
            endcase
        end
        default: tx_data2_in<='d0;
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 固定控制后面一种情况，用ask1和Length1控制
//---------------------------------------------------------------------
localparam                              READ = 'd2                 ;
localparam                              READ_BUAA = 'd3            ;
reg                    [   2:0]         state                      ;
reg                    [  15:0]         rd_cnt_ch2                 ;
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        state<=IDLE;
    else case (state)
        IDLE:
            if (tx_data1_ask_out)                                   //uplink_1ms2_flag && 
                state<=CHOOSE;
        CHOOSE:
            if (send_fifo_empty[0])
                state<=IDLE;
            else
                state<=READ;
        READ:
            if (rd_cnt_ch2 == ask_length - 1)
                state<=IDLE;
            else if (send_fifo_empty[0])
                state<=READ_BUAA;
        READ_BUAA:
            if (rd_cnt_ch2 == ask_length - 1)
                state<=IDLE;
        default:state<=IDLE;
    endcase
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        rd_cnt_ch2<='d0;
    else case (state)
        READ,READ_BUAA: rd_cnt_ch2<=rd_cnt_ch2+'d1;
        default: rd_cnt_ch2<='d0;
    endcase
end

always@(*)begin
    case (state)
        READ: send_fifo_rd_en[0] <= ~send_fifo_empty[0];
        default: send_fifo_rd_en[0]<= 'd0;
    endcase
end

always@(*)begin
    case (state)
        READ,READ_BUAA: tx_data1_valid_in <= 'd1;
        default: tx_data1_valid_in<='d0;
    endcase
end

always@(*)begin
    case (state)
        READ:
            if (send_fifo_empty[0])
                tx_data1_in<='hAA;
            else
                tx_data1_in<=send_fifo_rd_data[7:0];
        READ_BUAA: tx_data1_in<='hAA;
        default: tx_data1_in<='d0;
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
ila_sx_send_debug ila_sx_send_debug_inst (
    .clk                               (sys_clk_i                 ),// input wire clk

    .probe0                            (uplink_40ms               ),// input wire [0:0]  probe0      
    .probe1                            (uplink_40ms_flag          ),// input wire [0:0]  probe1      
    .probe2                            (uplink_1ms2_flag          ),// input wire [0:0]  probe2      
    .probe3                            (pluse_cnt                 ),// input wire [4:0]  probe3      
    .probe4                            (next_state                ),// input wire [2:0]  probe4      
    .probe5                            (cur_state                 ),// input wire [2:0]  probe5      
    .probe6                            (rd_cnt                    ),// input wire [15:0]  probe6     
    .probe7                            (send_fifo_rd_en           ),// input wire [3:0]  probe7      
    .probe8                            (send_fifo_rd_data         ),// input wire [31:0]  probe8     
    .probe9                            (send_fifo_empty           ),// input wire [3:0]  probe9      
    .probe10                           (state                     ),// input wire [2:0]  probe10     
    .probe11                           (rd_cnt_ch2                ),// input wire [15:0]  probe11    
    .probe12                           (tx_data1_ask_out          ),// input wire [0:0]  probe12     
    .probe13                           (tx_data1_length_out       ),// input wire [15:0]  probe13    
    .probe14                           (tx_data1_valid_in         ),// input wire [0:0]  probe14     
    .probe15                           (tx_data1_in               ),// input wire [7:0]  probe15     
    .probe16                           (tx_data2_ask_out          ),// input wire [0:0]  probe16     
    .probe17                           (ask_length                ),// input wire [7:0]  probe17    
    .probe18                           (tx_data2_valid_in         ),// input wire [0:0]  probe18     
    .probe19                           (tx_data2_in               ) // input wire [7:0]  probe19      
);
endmodule