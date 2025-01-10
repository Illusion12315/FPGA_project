//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// 模块: trig_dly
// 描述: 该模块用于给触发信号引入延迟。
// 参数:
// - DLY_CKNUM: 延迟的时钟周期数，默认值为 'D100000。
module trig_dly #
(
    parameter  DLY_CKNUM  =  'D100000
)
(
    // 系统信号
    input                                   i_clk      ,
    // 输入信号
    input                                   i_trig     ,
    // 输出信号
    output  reg                             o_trig       =0 
);

// 函数: clogb2
// 描述: 计算输入值的以2为底的对数，并向上取整。
// 输入:
// - value: 需要计算以2为底的对数值。
// 返回: 计算得到的以2为底的对数值。
function integer clogb2;
  input [31:0] value;
  reg   [31:0] my_val;
  begin
    my_val = value - 1;
    for (clogb2 = 0; my_val > 0; clogb2 = clogb2 + 1)
      my_val = my_val >> 1;
  end
endfunction

// 局部参数定义
localparam
    CNT_WIDTH = clogb2(DLY_CKNUM);

// 信号声明
reg             [CNT_WIDTH:0]           s_cnt_dly =0     ;
wire                                    w_done_cntdly        ;
wire                                    w_outen              ;

// 赋值语句
assign  w_done_cntdly = s_cnt_dly >= DLY_CKNUM + 1 ? 1'b1 : 1'b0 ;
assign  w_outen       = s_cnt_dly == DLY_CKNUM  ? 1'b1 : 1'b0 ;

// 始终块：计数器逻辑
always @ (posedge i_clk)
begin
    casex({i_trig,w_done_cntdly})
        2'b1x   : s_cnt_dly <= 'h0 ;  // 当触发信号到来或计数完成时，重置计数器
        2'b00   : s_cnt_dly <= s_cnt_dly + 'h1 ;  // 当没有触发信号且计数未完成时，递增计数器
        default : s_cnt_dly <= s_cnt_dly ;  // 其他情况下保持计数器不变
    endcase
end

// 始终块：输出逻辑
always @ (posedge i_clk)
begin
    o_trig <= w_outen ;  // 当计数器达到设定值时，输出触发信号
end

endmodule
