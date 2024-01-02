module uart_rx_logic_i #(
    parameter                           DATA_BIT = 8                //����λ��5��6��7��8λ
) (
    input                               sys_clk_i                  ,
    input                               rst_n_i                    ,

    input              [  31:0]         clk_fre                    ,//ϵͳʱ��Ƶ��
    input              [  31:0]         uart_bps                   ,//������
    input              [   1:0]         uart_parity_bit            ,//У��λ��0��1��2��3�ֱ������У�飬��У�飬żУ�飬��У��
    input              [   1:0]         uart_stop_bit              ,//ֹͣλ��0��1��2��3�ֱ����1��1.5��2��1��ֹͣλ

    input                               rx_i                       ,
    output reg                          rx_data_flag_o             ,
    output reg         [DATA_BIT-1:0]   rx_data_o                   
);
wire                                    start_negedge              ;
wire                                    verify_sim_odd             ;
wire                                    verify_sim_even            ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// regs
//---------------------------------------------------------------------
reg                                     rx_flag                    ;
reg                    [DATA_BIT-1:0]   rx_data                    ;
reg                    [   3:0]         bit_cnt                    ;
reg                    [  15:0]         baud_cnt                   ;
reg                                     bit_flag                   ;
reg                                     work_en                    ;
reg                    [   3:0]         bit_num                    ;
reg                                     verify_bit                 ;
reg                    [   3:0]         error_cnt                  ;
(*ASYNC_REG = "TRUE"*)
reg                                     rx_r1,rx_r2,rx_r3          ;

// ********************************************************************************** // 
//---------------------------------------------------------------------
// logic
//---------------------------------------------------------------------
//bit_num
always@(posedge sys_clk_i)begin
    if (uart_parity_bit == 1 || uart_parity_bit == 2) begin
        if (uart_stop_bit == 1|| uart_stop_bit == 2) begin
            bit_num<=1'b1+DATA_BIT+1'b1+2'd2;
        end
        else
            bit_num<=1'b1+DATA_BIT+1'b1+1'b1;
    end
    else begin
        if (uart_stop_bit == 1|| uart_stop_bit == 2) begin
            bit_num<=1'b1+DATA_BIT+1'b1+1'b1;
        end
        else
            bit_num<=1'b1+DATA_BIT+1'b1;
    end
end
//�½��ز�����ʼ�ź�
assign start_negedge = ~rx_r2&rx_r3;
//��3��
always@(posedge sys_clk_i)begin
    rx_r1<=rx_i;
    rx_r2<=rx_r1;
    rx_r3<=rx_r2;
end
//rx����ʹ��
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        work_en<='d0;
    else if (start_negedge) begin
        work_en<='d1;
    end
    else if (uart_parity_bit == 1 || uart_parity_bit == 2) begin
        if (bit_cnt == 1'b1+DATA_BIT+1'b1 && bit_flag =='d1) begin
            work_en<='d0;
        end
    end
    else begin
        if (bit_cnt == 1'b1+DATA_BIT && bit_flag =='d1) begin
            work_en<='d0;
        end
    end
end
//������
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        baud_cnt<='d0;
    else if (baud_cnt == clk_fre/uart_bps-1 || work_en == 'd0) begin
        baud_cnt<='d0;
    end
    else if (work_en) begin
        baud_cnt<=baud_cnt+'d1;
    end
    else
        baud_cnt<=baud_cnt;
end
//�ɼ���־
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        bit_flag<='d0;
    else if (baud_cnt == clk_fre/uart_bps/2 - 1) begin
        bit_flag<='d1;
    end
    else
        bit_flag<='d0;
end
//bit������
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        bit_cnt<='d0;
    else if (uart_parity_bit == 1 || uart_parity_bit == 2) begin
        if (bit_cnt == 1'b1+DATA_BIT+1'b1 && bit_flag =='d1) begin
            bit_cnt<='d0;
        end
        else if (bit_flag) begin
            bit_cnt<=bit_cnt+'d1;
        end
    end
    else begin
        if (bit_cnt == 1'b1+DATA_BIT && bit_flag =='d1) begin
            bit_cnt<='d0;
        end
        else if (bit_flag) begin
            bit_cnt<=bit_cnt+'d1;
        end
    end
end
//����8bit����
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        rx_data<='d0;
    else if (bit_cnt >= 'd1 && bit_cnt <= DATA_BIT && bit_flag == 'd1) begin
        rx_data<={rx_r3,rx_data[DATA_BIT-1:1]};
    end
end
//żУ��
assign verify_sim_even = ^rx_data ;
//��У��
assign verify_sim_odd = ~^rx_data ;
//��ȡУ��λ
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        verify_bit<='d0;
    else if (uart_parity_bit == 1 || uart_parity_bit == 2) begin
        if (bit_cnt == 1'b1+DATA_BIT && bit_flag == 'd1) begin
            verify_bit<=rx_r3;
        end
    end
end
//�������
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        error_cnt<='d0;
    else if (uart_parity_bit == 1) begin
        if (bit_cnt == 1'b1+DATA_BIT+1'b1 && bit_flag && (verify_sim_odd != verify_bit)) begin
            error_cnt<=error_cnt+'d1;
        end
    end
    else if (uart_parity_bit == 2) begin
        if (bit_cnt == 1'b1+DATA_BIT+1'b1 && bit_flag && (verify_sim_even != verify_bit)) begin
            error_cnt<=error_cnt+'d1;
        end
    end
    else
        error_cnt<=error_cnt;
end
//rx_flag
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        rx_flag<='d0;
    else if (uart_parity_bit == 1 || uart_parity_bit == 2) begin
        if (bit_cnt == 1'b1+DATA_BIT+1'b1 && bit_flag =='d1) begin
            rx_flag<='d1;
        end
        else
            rx_flag<='d0;
    end
    else begin
        if (bit_cnt == 1'b1+DATA_BIT && bit_flag =='d1) begin
            rx_flag<='d1;
        end
        else
            rx_flag<='d0;
    end
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        rx_data_o<='d0;
    else if (rx_flag) begin
        rx_data_o<=rx_data;
    end
end

always@(posedge sys_clk_i)begin
    rx_data_flag_o<=rx_flag;
end
endmodule