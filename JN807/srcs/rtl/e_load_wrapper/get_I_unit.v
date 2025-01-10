`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             get_I_unit.v
// Create Date:           2025/01/10 13:47:14
// Version:               V1.0
// PATH:                  srcs\rtl\e_load_wrapper\get_I_unit.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module get_I_unit #(
    parameter                       CALCULATE_WIDTH    = 24    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,
    input  wire                     global_1us_flag_i   ,
    // ADC signal
    input  wire                     adc_valid_i         ,
    input  wire signed [CALCULATE_WIDTH-1: 0]I_sum_unit_i,//sum_unit电流，校准后的值
    input  wire signed [CALCULATE_WIDTH-1: 0]I_board_unit_i,//board_unit电流，校准后的值

    output reg         [  31: 0]    SUM_UNIT_0          ,
    output reg         [  31: 0]    SUM_UNIT_1          ,
    output reg         [  31: 0]    SUM_UNIT_2          ,
    output reg         [  31: 0]    SUM_UNIT_3          ,
    output reg         [  31: 0]    SUM_UNIT_4          ,
    output reg         [  31: 0]    SUM_UNIT_5          ,
    output reg         [  31: 0]    SUM_UNIT_6          ,
    output reg         [  31: 0]    SUM_UNIT_7          ,
    output reg         [  31: 0]    BOARD_UNIT_0        ,
    output reg         [  31: 0]    BOARD_UNIT_1        ,
    output reg         [  31: 0]    BOARD_UNIT_2        ,
    output reg         [  31: 0]    BOARD_UNIT_3        ,
    output reg         [  31: 0]    BOARD_UNIT_4        ,
    output reg         [  31: 0]    BOARD_UNIT_5        ,
    output reg         [  31: 0]    BOARD_UNIT_6        ,
    output reg         [  31: 0]    BOARD_UNIT_7        ,

    output reg                      en_sample_o         ,
    output reg         [   2: 0]    sel_sample_o         
);
    localparam                      GAP_MS_NUM         = 100   ;//100MS变一次
    localparam                      TIME_1MS           = 1000  ;

    wire                            time_1ms_flag       ;
    wire                            ch_num_change_flag  ;
    wire                            vld_sample          ;
    reg                [   9: 0]    cnt_us              ;
    reg                [   9: 0]    cnt_ms              ;
    reg                [   2: 0]    ch_num              ;

    assign                          vld_sample         = (cnt_ms == GAP_MS_NUM/2 - 1);
    assign                          ch_num_change_flag = (cnt_ms == GAP_MS_NUM - 1);
    assign                          time_1ms_flag      = (cnt_us == TIME_1MS - 1) ? 1'b1 : 1'b0;

always@(posedge sys_clk_i)begin
    if (!rst_n_i)
        cnt_us <= 'd0;
    else if (time_1ms_flag)
        cnt_us <= 'd0;
    else if (global_1us_flag_i)
        cnt_us <= cnt_us + 'd1;
    else
        cnt_us <= cnt_us;
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i)
        cnt_ms <= 'd0;
    else if (ch_num_change_flag)
        cnt_ms <= 'd0;
    else if (time_1ms_flag)
        cnt_ms <= cnt_ms + 'd1;
    else
        cnt_ms <= cnt_ms;
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        ch_num <= 'd0;
    end
    else if (ch_num_change_flag) begin
        ch_num <= ch_num + 'd1;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        en_sample_o  <= 'd1;
        sel_sample_o <= 'd0;
    end
    else begin
        en_sample_o  <= 'd0;
        sel_sample_o <= ch_num;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        SUM_UNIT_0   <= 'd0;
        SUM_UNIT_1   <= 'd0;
        SUM_UNIT_2   <= 'd0;
        SUM_UNIT_3   <= 'd0;
        SUM_UNIT_4   <= 'd0;
        SUM_UNIT_5   <= 'd0;
        SUM_UNIT_6   <= 'd0;
        SUM_UNIT_7   <= 'd0;
        BOARD_UNIT_0 <= 'd0;
        BOARD_UNIT_1 <= 'd0;
        BOARD_UNIT_2 <= 'd0;
        BOARD_UNIT_3 <= 'd0;
        BOARD_UNIT_4 <= 'd0;
        BOARD_UNIT_5 <= 'd0;
        BOARD_UNIT_6 <= 'd0;
        BOARD_UNIT_7 <= 'd0;
    end
    else case (ch_num)
        0: begin
            SUM_UNIT_0    <= vld_sample ? I_sum_unit_i : SUM_UNIT_0 ;
            BOARD_UNIT_0  <= vld_sample ? I_board_unit_i : BOARD_UNIT_0 ;
        end
        1: begin
            SUM_UNIT_1    <= vld_sample ? I_sum_unit_i : SUM_UNIT_1 ;
            BOARD_UNIT_1  <= vld_sample ? I_board_unit_i : BOARD_UNIT_1 ;
        end
        2: begin
            SUM_UNIT_2    <= vld_sample ? I_sum_unit_i : SUM_UNIT_2 ;
            BOARD_UNIT_2  <= vld_sample ? I_board_unit_i : BOARD_UNIT_2 ;
        end
        3: begin
            SUM_UNIT_3    <= vld_sample ? I_sum_unit_i : SUM_UNIT_3 ;
            BOARD_UNIT_3  <= vld_sample ? I_board_unit_i : BOARD_UNIT_3 ;
        end
        4: begin
            SUM_UNIT_4    <= vld_sample ? I_sum_unit_i : SUM_UNIT_4 ;
            BOARD_UNIT_4  <= vld_sample ? I_board_unit_i : BOARD_UNIT_4 ;
        end
        5: begin
            SUM_UNIT_5    <= vld_sample ? I_sum_unit_i : SUM_UNIT_5 ;
            BOARD_UNIT_5  <= vld_sample ? I_board_unit_i : BOARD_UNIT_5 ;
        end
        6: begin
            SUM_UNIT_6    <= vld_sample ? I_sum_unit_i : SUM_UNIT_6 ;
            BOARD_UNIT_6  <= vld_sample ? I_board_unit_i : BOARD_UNIT_6 ;
        end
        7: begin
            SUM_UNIT_7    <= vld_sample ? I_sum_unit_i : SUM_UNIT_7 ;
            BOARD_UNIT_7  <= vld_sample ? I_board_unit_i : BOARD_UNIT_7 ;
        end
        default: begin
            
        end
    endcase
end



endmodule


`default_nettype wire
