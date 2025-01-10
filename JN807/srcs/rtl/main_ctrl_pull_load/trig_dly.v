//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// ģ��: trig_dly
// ����: ��ģ�����ڸ������ź������ӳ١�
// ����:
// - DLY_CKNUM: �ӳٵ�ʱ����������Ĭ��ֵΪ 'D100000��
module trig_dly #
(
    parameter  DLY_CKNUM  =  'D100000
)
(
    // ϵͳ�ź�
    input                                   i_clk      ,
    // �����ź�
    input                                   i_trig     ,
    // ����ź�
    output  reg                             o_trig       =0 
);

// ����: clogb2
// ����: ��������ֵ����2Ϊ�׵Ķ�����������ȡ����
// ����:
// - value: ��Ҫ������2Ϊ�׵Ķ���ֵ��
// ����: ����õ�����2Ϊ�׵Ķ���ֵ��
function integer clogb2;
  input [31:0] value;
  reg   [31:0] my_val;
  begin
    my_val = value - 1;
    for (clogb2 = 0; my_val > 0; clogb2 = clogb2 + 1)
      my_val = my_val >> 1;
  end
endfunction

// �ֲ���������
localparam
    CNT_WIDTH = clogb2(DLY_CKNUM);

// �ź�����
reg             [CNT_WIDTH:0]           s_cnt_dly =0     ;
wire                                    w_done_cntdly        ;
wire                                    w_outen              ;

// ��ֵ���
assign  w_done_cntdly = s_cnt_dly >= DLY_CKNUM + 1 ? 1'b1 : 1'b0 ;
assign  w_outen       = s_cnt_dly == DLY_CKNUM  ? 1'b1 : 1'b0 ;

// ʼ�տ飺�������߼�
always @ (posedge i_clk)
begin
    casex({i_trig,w_done_cntdly})
        2'b1x   : s_cnt_dly <= 'h0 ;  // �������źŵ�����������ʱ�����ü�����
        2'b00   : s_cnt_dly <= s_cnt_dly + 'h1 ;  // ��û�д����ź��Ҽ���δ���ʱ������������
        default : s_cnt_dly <= s_cnt_dly ;  // ��������±��ּ���������
    endcase
end

// ʼ�տ飺����߼�
always @ (posedge i_clk)
begin
    o_trig <= w_outen ;  // ���������ﵽ�趨ֵʱ����������ź�
end

endmodule
