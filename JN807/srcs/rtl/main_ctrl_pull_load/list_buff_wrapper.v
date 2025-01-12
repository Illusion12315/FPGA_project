`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             list_buff_wrapper.v
// Create Date:           2025/01/08 14:48:56
// Version:               V1.0
// PATH:                  srcs\rtl\main_ctrl_pull_load\list_buff_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module list_buff_wrapper (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,

    input  wire        [  15: 0]    Step_i              ,//�������кţ���1��ʼ��0��������������
    input  wire        [  15: 0]    Mode_i              ,//����ģʽ [CC(0x5a5a)��CV(0xa5a5)��CP(0x5a00)��CR(0x005a)]
    input  wire        [  31: 0]    Value_i             ,//����ֵ
    input  wire        [  31: 0]    Tstep_i             ,//uS//����ִ��ʱ��
    input  wire        [  15: 0]    Repeat_i            ,
    input  wire        [  15: 0]    Goto_i              ,//Сѭ����תĿ�ĵ�,1-999
    input  wire        [  15: 0]    Loops_i             ,//Сѭ������,1-65535

    input  wire                     Save_step_ON_i      ,//�������
    
    input  wire        [   9: 0]    list_buff_rd_addr_i ,//�������кţ���1��ʼ��0��������������
    output reg         [  15: 0]    cur_Mode_o          ,//����ģʽ [CC(0x5a5a)��CV(0xa5a5)��CP(0x5a00)��CR(0x005a)]
    output reg         [  31: 0]    cur_Value_o         ,//����ֵ
    output reg         [  31: 0]    cur_Tstep_o         ,//uS//����ִ��ʱ��
    output reg         [  15: 0]    cur_Repeat_o        ,
    output reg         [  15: 0]    cur_Goto_o          ,//Сѭ����תĿ�ĵ�,1-999
    output reg         [  15: 0]    cur_Loops_o          //Сѭ������,1-65535
);
    localparam                      RAM_SIZE           = 1024  ;
    reg                [ 127: 0]    ram_cache       [0:RAM_SIZE-1]  ;
    integer                         i                   ;

initial begin
    for (i = 0; i<RAM_SIZE; i=i+1) begin
        ram_cache[i] = 'd0;
    end
end

always@(posedge sys_clk_i)begin
    if (Save_step_ON_i) begin
        ram_cache[Step_i] <= {Mode_i, Value_i, Tstep_i, Repeat_i, Goto_i, Loops_i};
    end
end

always@(*)begin
    {cur_Mode_o, cur_Value_o, cur_Tstep_o, cur_Repeat_o, cur_Goto_o, cur_Loops_o} <= ram_cache[list_buff_rd_addr_i];
end






endmodule


`default_nettype wire