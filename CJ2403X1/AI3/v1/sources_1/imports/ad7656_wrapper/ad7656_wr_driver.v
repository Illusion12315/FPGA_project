`timescale 1ns / 1ps

module ad7656_wr_driver (
    input  wire                         sys_clk_i                  ,// clk100m
    input  wire                         rst_n_i                    ,
    // ��ʼ��־
    input  wire                         wr_flag_i                  ,// �������ź�
    input  wire        [   7: 0]        wr_data_i                  ,
    output wire                         bus_busy_o                 ,

    output reg                          wr_n_o                     ,
    output reg                          cs_n_o                     ,

    output wire        [  15: 0]        DB_o                        
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                          IDLE                      = 0     ;
    localparam                          WRITE                     = 1     ;

    reg                [   0: 0]        next_state                 ;
    reg                [   0: 0]        cur_state                  ;
    reg                [   1: 0]        period_cnt                 ;

    reg                [   7: 0]        data_out                   ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// logic
//---------------------------------------------------------------------
// ��һ��,״̬��ת,ʱ���߼�
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        cur_state <= IDLE;
    else
        cur_state <= next_state;
end

// �ڶ���,��ת����,����߼�
always@(*)begin
    case(cur_state)
        IDLE:
            if(wr_flag_i)
                next_state <= WRITE;
            else
                next_state <= IDLE;
        WRITE:
            if(period_cnt == 'd3)
                next_state <= IDLE;
            else
                next_state <= WRITE;
        default:next_state <= IDLE;
    endcase
end

always@(posedge sys_clk_i)begin
    case (cur_state)
        WRITE: period_cnt <= period_cnt + 'd1;
        default: period_cnt <= 'd0;
    endcase
end

always@(posedge sys_clk_i)begin
    case (cur_state)
        WRITE: cs_n_o <= 'd0;
        default: cs_n_o <= 'd1;
    endcase
end

always@(posedge sys_clk_i)begin
    case (cur_state)
        WRITE:
            case (period_cnt)
                1,2: wr_n_o <= 'd0;
                default: wr_n_o <= 'd1;
            endcase
        default: wr_n_o <= 'd1;
    endcase
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        data_out <= 'd0;
    else if(wr_flag_i)
        data_out <= wr_data_i;
end

    assign                              DB_o                      = {data_out,8'hff};

    assign                              bus_busy_o                = (cur_state == WRITE);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------



endmodule