`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             adc_Volt_Curr_Cali_wrapper.v
// Create Date:           2025/01/07 08:34:15
// Version:               V1.0
// PATH:                  srcs\rtl\adc_Volt_Curr_Cali_wrapper\adc_Volt_Curr_Cali_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module adc_Volt_Curr_Cali_wrapper #(
    parameter                       CALCULATE_WIDTH    = 24    ,//计算精度
    parameter                       CALI_WIDTH         = 16    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,
    // ADC signal
    input  wire                     adc_acq_valid_i     ,
    input  wire signed [  15: 0]    I_SUM_H_AD          ,//I_SUM_H_AD----高档位8路板卡汇总电流4.521V
    input  wire signed [  15: 0]    I_SUM_L_AD          ,//I_SUM_L_AD----低档位8路板卡汇总电流
    input  wire signed [  15: 0]    I_BOARD_H_AD        ,//I_BOARD_H_AD----高档位板卡电流4.5V
    input  wire signed [  15: 0]    I_BOARD_L_AD        ,//I_BOARD_L_AD----低档位板卡电流
    input  wire signed [  15: 0]    AD_Vmod             ,//AD_Vmod----非sense端电压
    input  wire signed [  15: 0]    AD_Vsense           ,//AD_Vsense----sense端电压
    input  wire signed [  15: 0]    I_SUM_UNIT_AD       ,//I_SUM_UNIT_AD----单板卡24模块汇总电流4.125V
    input  wire signed [  15: 0]    I_BOARD_UNIT_AD     ,//I_BOARD_UNIT_AD----单板卡单模块电流3.4375V
    // 电压电流选择参数控制
    input  wire                     SENSE_ON_i          ,
    input  wire                     U_gear_H_ON_i       ,
    input  wire                     I_sum_ON_i          ,
    input  wire                     I_gear_H_ON_i       ,
    // cali系数
    input  wire signed [CALI_WIDTH-1: 0]VH_k            ,//VH_k：电压mod高档校准（默认值:39219）
    input  wire signed [CALI_WIDTH-1: 0]VH_a            ,
    input  wire signed [CALI_WIDTH-1: 0]VsH_k           ,//VsH_k：电压sense采样高档校准（默认值: 0X ）
    input  wire signed [CALI_WIDTH-1: 0]VsH_a           ,
    input  wire signed [CALI_WIDTH-1: 0]I1_k            ,//I_Board_H高档校准（默认值: 57870）
    input  wire signed [CALI_WIDTH-1: 0]I1_a            ,
    input  wire signed [CALI_WIDTH-1: 0]I2_k            ,//I_Board_L低档校准（默认值: 5787）
    input  wire signed [CALI_WIDTH-1: 0]I2_a            ,
    input  wire signed [CALI_WIDTH-1: 0]VL_k            ,//VL_k：电压采样低档校准（默认值: 3565）
    input  wire signed [CALI_WIDTH-1: 0]VL_a            ,
    input  wire signed [CALI_WIDTH-1: 0]VsL_k           ,//VsL_k：电压sense采样低档校准（默认值: 0X ）
    input  wire signed [CALI_WIDTH-1: 0]VsL_a           ,
    input  wire signed [CALI_WIDTH-1: 0]It1_k           ,//It1_k：总电流高档I_SUM_Total_H校准（默认值: 55298）
    input  wire signed [CALI_WIDTH-1: 0]It1_a           ,
    input  wire signed [CALI_WIDTH-1: 0]It2_k           ,//It2_k：总电流低档I_SUM_Total_L校准（默认值: 5530）
    input  wire signed [CALI_WIDTH-1: 0]It2_a           ,

    input  wire signed [CALI_WIDTH-1: 0]CVH_k           ,//CV模式高档校准（默认值: 0X ）
    input  wire signed [CALI_WIDTH-1: 0]CVH_a           ,
    input  wire signed [CALI_WIDTH-1: 0]CVL_k           ,//CV模式低档校准（默认值: 0X ）
    input  wire signed [CALI_WIDTH-1: 0]CVL_a           ,
    input  wire signed [CALI_WIDTH-1: 0]CVHs_k          ,//CV模式sense高档校准（默认值: 0X ）
    input  wire signed [CALI_WIDTH-1: 0]CVHs_a          ,
    input  wire signed [CALI_WIDTH-1: 0]CVLs_k          ,//CV模式sense低档校准（默认值: 0X ）
    input  wire signed [CALI_WIDTH-1: 0]CVLs_a          ,

    output reg  signed [CALI_WIDTH-1: 0]CV_k            ,//CV模式K
    output reg  signed [CALI_WIDTH-1: 0]CV_a            ,//CV模式A
    //校准后的结果输出
    output wire                     adc_cali_valid_o    ,
    output wire signed [CALCULATE_WIDTH-1: 0]U_cali_o   ,//电压，校准后的值
    output reg  signed [CALCULATE_WIDTH-1: 0]I_cali_o   ,//电流，校准后的值

    output wire signed [CALCULATE_WIDTH-1: 0]Umod_cali_o,//端口电压，校准后的值
    output wire signed [CALCULATE_WIDTH-1: 0]Usense_cali_o,//Sense电流，校准后的值
    output wire signed [CALCULATE_WIDTH-1: 0]I_board_L_cali_o,//borad 低档电流，校准后的值
    output wire signed [CALCULATE_WIDTH-1: 0]I_board_H_cali_o,//board 高档电流，校准后的值
    output wire signed [CALCULATE_WIDTH-1: 0]I_sum_L_cali_o,//sum 低档电流，校准后的值
    output wire signed [CALCULATE_WIDTH-1: 0]I_sum_H_cali_o,//sum 高档电流，校准后的值
    output wire signed [CALCULATE_WIDTH-1: 0]I_sum_unit_cali_o,//sum_unit电流，校准后的值
    output wire signed [CALCULATE_WIDTH-1: 0]I_board_unit_cali_o,//board_unit电流，校准后的值

    output wire        [CALCULATE_WIDTH-1: 0]U_cali_abs_o,//电压，校准后的绝对值
    output wire        [CALCULATE_WIDTH-1: 0]I_cali_abs_o //电流，校准后的绝对值
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// cali_k_mult_x_add_b
//---------------------------------------------------------------------
    localparam                      CALI_CH            = 6     ;

    reg      signed    [  15: 0]    U_cali_code         ;
    reg      signed    [  15: 0]    U_k_cali_code       ;
    reg      signed    [  15: 0]    U_b_cali_code       ;

    reg                             adc_acq_valid_r1    ;
    reg                             adc_acq_valid_r2    ;
    reg                             adc_acq_valid_r3    ;
    reg                             adc_acq_valid_r4    ;
    reg                             adc_acq_valid_r5    ;

    assign                          U_cali_o           = (SENSE_ON_i)? Usense_cali_o : Umod_cali_o;
    assign                          U_cali_abs_o       = signed2unsigned(U_cali_o);
    assign                          I_cali_abs_o       = signed2unsigned(I_cali_o);

    assign                          adc_cali_valid_o   = adc_acq_valid_r5;// 由运算延迟决定，与cali_o数据匹配

    assign                          I_sum_unit_cali_o  = {{(CALCULATE_WIDTH-16){I_SUM_UNIT_AD[15]}},I_SUM_UNIT_AD};//sum_unit电流，校准后的值
    assign                          I_board_unit_cali_o= {{(CALCULATE_WIDTH-16){I_BOARD_UNIT_AD[15]}},I_BOARD_UNIT_AD};//board_unit电流，校准后的值

always@(posedge sys_clk_i)begin
    adc_acq_valid_r1 <= adc_acq_valid_i;
    adc_acq_valid_r2 <= adc_acq_valid_r1;
    adc_acq_valid_r3 <= adc_acq_valid_r2;
    adc_acq_valid_r4 <= adc_acq_valid_r3;
    adc_acq_valid_r5 <= adc_acq_valid_r4;
end
      
always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        U_cali_code   <= 'd0;
        U_k_cali_code <= 'd0;
        U_b_cali_code <= 'd0;

        CV_k <= 'd0;
        CV_a <= 'd0;
    end
    else case ({SENSE_ON_i, U_gear_H_ON_i})
        2'b00: begin                                                //sense off, gear Low
            U_cali_code   <= AD_Vmod;
            U_k_cali_code <= VL_k;
            U_b_cali_code <= VL_a;

            CV_k <= CVL_k;
            CV_a <= CVL_a;
        end
        2'b01: begin                                                //sense off, gear High
            U_cali_code   <= AD_Vmod;
            U_k_cali_code <= VH_k;
            U_b_cali_code <= VH_a;

            CV_k <= CVH_k;
            CV_a <= CVH_a;
        end
        2'b10: begin                                                //sense on, gear Low
            U_cali_code   <= AD_Vsense;
            U_k_cali_code <= VsL_k;
            U_b_cali_code <= VsL_a;

            CV_k <= CVLs_k;
            CV_a <= CVLs_a;
        end
        2'b11: begin                                                //sense on, gear High
            U_cali_code   <= AD_Vsense;
            U_k_cali_code <= VsH_k;
            U_b_cali_code <= VsH_a;

            CV_k <= CVHs_k;
            CV_a <= CVHs_a;
        end
        default: begin
            U_cali_code   <= AD_Vmod;
            U_k_cali_code <= VL_k;
            U_b_cali_code <= VL_a;

            CV_k <= CVL_k;
            CV_a <= CVL_a;
        end
    endcase
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        I_cali_o <= 'd0;
    end
    else case ({I_sum_ON_i, I_gear_H_ON_i})
        2'b00: begin                                                //SUM off, gear Low
            I_cali_o <= I_board_L_cali_o;
        end
        2'b01: begin                                                //SUM off, gear High
            I_cali_o <= I_board_H_cali_o;
        end
        2'b10: begin                                                //SUM on, gear Low
            I_cali_o <= I_sum_L_cali_o;
        end
        2'b11: begin                                                //SUM on, gear High
            I_cali_o <= I_sum_H_cali_o;
        end
        default: begin
            I_cali_o <= I_board_L_cali_o;
        end
    endcase
end

cali_k_mult_x_add_b u_Umod_cali(
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            (AD_Vmod            ),
    .k_i                            (U_k_cali_code      ),
    .b_i                            (U_b_cali_code      ),
    .right_shift_i                  ('d10               ),//缩小倍数2**N
    .y_o                            (Umod_cali_o        ) 
);

cali_k_mult_x_add_b u_Usense_cali(
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            (AD_Vsense          ),
    .k_i                            (U_k_cali_code      ),
    .b_i                            (U_b_cali_code      ),
    .right_shift_i                  ('d10               ),//缩小倍数2**N
    .y_o                            (Usense_cali_o      ) 
);

cali_k_mult_x_add_b u_I_board_L_cali(                               //SUM off, gear Low
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            (I_BOARD_L_AD       ),
    .k_i                            (I2_k               ),
    .b_i                            (I2_a               ),
    .right_shift_i                  ('d13               ),//缩小倍数2**N
    .y_o                            (I_board_L_cali_o   ) 
);

cali_k_mult_x_add_b u_I_board_H_cali(                               //SUM off, gear High
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            (I_BOARD_H_AD       ),
    .k_i                            (I1_k               ),
    .b_i                            (I1_a               ),
    .right_shift_i                  ('d13               ),//缩小倍数2**N
    .y_o                            (I_board_H_cali_o   ) 
);

cali_k_mult_x_add_b u_I_sum_L_cali(                                 //SUM on, gear Low
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            (I_SUM_L_AD         ),
    .k_i                            (It2_k              ),
    .b_i                            (It2_a              ),
    .right_shift_i                  ('d13               ),//缩小倍数2**N
    .y_o                            (I_sum_L_cali_o     ) 
);

cali_k_mult_x_add_b u_I_sum_H_cali(                                 //SUM on, gear High
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            (I_SUM_H_AD         ),
    .k_i                            (It1_k              ),
    .b_i                            (It1_a              ),
    .right_shift_i                  ('d13               ),//缩小倍数2**N
    .y_o                            (I_sum_H_cali_o     ) 
);
//保留
// cali_k_mult_x_add_b u_I_board_unit_cali(                         
//     .sys_clk_i                      (sys_clk_i          ),
//     .x_i                            (I_SUM_L_AD         ),
//     .k_i                            (                   ),
//     .b_i                            (                   ),
//     .right_shift_i                  ('d15               ),//缩小倍数2**N
//     .y_o                            (I_board_unit_cali_o) 
// );
//保留
// cali_k_mult_x_add_b u_I_sum_unit_cali(                     
//     .sys_clk_i                      (sys_clk_i          ),
//     .x_i                            (I_SUM_H_AD         ),
//     .k_i                            (                   ),
//     .b_i                            (                   ),
//     .right_shift_i                  ('d15               ),//缩小倍数2**N
//     .y_o                            (I_sum_unit_cali_o  ) 
// );

// ********************************************************************************** // 
//---------------------------------------------------------------------
// functions
//---------------------------------------------------------------------
function [CALCULATE_WIDTH-1: 0] signed2unsigned;
    input              [CALCULATE_WIDTH-1: 0]signed_in  ;
    signed2unsigned    = (signed_in[CALCULATE_WIDTH-1]) ? ~(signed_in - 1) : signed_in;
endfunction



endmodule


`default_nettype wire
