//////////////////////////////////////////////////////////////////////////////////
// Company              : Wuhan Jingneng Electronics Co., LTD
// Engineer             : Wangyanqing
//                        Senior Engineer
// Create Date          : 8:22 2024/9/9
// Module Name          : PID_ctrl
// Description          : PID算法
// ---- y[n] = P * E[n] + I * SUM (E[n]) + D * (E[n] - E[n-1])
// Additional Comments  : 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
//////////////////////////////////////////////////////////////////////////////////
                                 
module PID_ctrl 
(
input                                   i_clk          ,// 
input                                   i_rst          ,// 
		    
input                                   i_gap          ,//1us
input       signed      [23:0]          i_target       ,//目标值
input       signed      [23:0]          i_limitI       ,//限制I//
input       signed      [23:0]          i_initI        ,//初始电流值mA
input       signed      [23:0]          i_x            ,//当前采样值
input       signed      [15:0]          i_P            ,//比例系数*2^15
input       signed      [15:0]          i_I            ,//积分系数*2^15
input       signed      [15:0]          i_D            ,//微分系数*2^15
                                
output                                  o_vld          ,//输出有效
output      signed      [23:0]          o_y             //输出控制值
);
reg     signed  [23:0]                  s_diff        =0 ;
reg     signed  [23:0]                  s_diff_1dly   =0 ;
reg     signed  [39:0]                  s_sum_diff    =0 ;
reg     signed  [23:0]                  s_diff_diff   =0 ;
									    
reg                                     s_gap_1dly    =0 ;
									    
wire    signed  [39:0]                  w_kp_diff        ;
wire    signed  [55:0]                  w_ki_diff        ;
wire    signed  [39:0]                  w_kd_diff        ;
									    
reg     signed  [55:0]                  s_p_i         =0 ;  
reg     signed  [55:0]                  s_p_i_d       =0 ;  
									    
									    
reg     signed  [23:0]                  s_out_temp    =0 ;  

wire            [39:0]                  w_limitI_amp     ;
wire            [63:0]                  w_limitI_amp_divI ;
reg             [23:0]                  s_divior   =1 ;
wire            [39:0]                  w_limitI_value ;

assign  w_limitI_amp = {i_limitI,15'b0}; 

//检测被除数为0
always @ (posedge i_clk)
begin
    if (i_I == 'h0)
	    s_divior <= 'h1 ;
	else
	    s_divior <= i_I ;
end
//delay 66
div_u64_u32 U_div_limitI_
(
    .aclk                        ( i_clk     ), // input wire aclk
    .s_axis_divisor_tvalid       ( 1'b1      ), // input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata        ( {{8{s_divior[23]}},s_divior}  ), // input wire [31 : 0] s_axis_divisor_tdata 
    .s_axis_dividend_tvalid      ( 1'B1      ), // input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata       ( {{24{w_limitI_amp[39]}},w_limitI_amp}   ), // input wire [63 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid          (           ), // output wire m_axis_dout_tvalid
    .m_axis_dout_tdata           ( w_limitI_amp_divI   ) // output wire [95 : 0] m_axis_dout_tdata
);
assign  w_limitI_value = w_limitI_amp_divI[63:24] + w_limitI_amp_divI[23] ^ w_limitI_amp_divI[63] ;//四舍五入

wire            [39:0]                  w_initI_amp     ;
wire            [63:0]                  w_initI_amp_divI ;
reg             [23:0]                  s_initI_divior   =1 ;
wire            [39:0]                  w_initI_value ;

assign  w_initI_amp = {i_initI,15'b0}; 
//检测被除数为0
// always @ (posedge i_clk)
// begin
    // if (i_I == 'h0)
	    // s_initI_divior <= 'h1 ;
	// else
	    // s_initI_divior <= i_I ;
// end
//delay 66
div_u64_u32 U_div_initI_
(
    .aclk                        ( i_clk     ), // input wire aclk
    .s_axis_divisor_tvalid       ( 1'b1      ), // input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata        ( {{8{s_divior[23]}},s_divior}  ), // input wire [31 : 0] s_axis_divisor_tdata 
    .s_axis_dividend_tvalid      ( 1'B1      ), // input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata       ( {{24{w_initI_amp[39]}},w_initI_amp}   ), // input wire [63 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid          (           ), // output wire m_axis_dout_tvalid
    .m_axis_dout_tdata           ( w_initI_amp_divI   ) // output wire [95 : 0] m_axis_dout_tdata
);
assign  w_initI_value = w_initI_amp_divI[63:24] + w_initI_amp_divI[23] ^ w_initI_amp_divI[63] ;//四舍五入



always @ (posedge i_clk)
begin
    if (i_rst == 1'b1)
	    s_diff <= 'h0 ;
	else if (i_gap == 1'b1)
	    // s_diff <= i_target - i_x ;
	    s_diff <= i_x - i_target ;
	else
	    s_diff <= s_diff ;
end
always @ (posedge i_clk)
begin
    if (i_rst == 1'b1)
	    s_gap_1dly <= 'b0 ;
	else if (i_gap == 1'b1)
	    s_gap_1dly <= 'b1 ;
	else
	    s_gap_1dly <= 'b0 ;
end
always @ (posedge i_clk)
begin
    // if (i_gap == 1'b1)
	    s_diff_1dly <= s_diff ;
	// else
	    // s_diff_1dly <= s_diff_1dly ;
end
always @ (posedge i_clk)
begin
    if (i_rst == 1'b1)
	    // s_sum_diff <= 'h0 ;
	    s_sum_diff <= w_initI_value ;
	else if ((s_gap_1dly == 1'b1) && (w_limitI_value > (s_sum_diff + {{16{s_diff[23]}},s_diff})))
	    s_sum_diff <= s_sum_diff + {{16{s_diff[23]}},s_diff} ;
	else
	    s_sum_diff <= s_sum_diff ;
end
always @ (posedge i_clk)
begin
    if (s_gap_1dly == 1'b1)
	    s_diff_diff <= s_diff - s_diff_1dly ;
	else
	    s_diff_diff <= s_diff_diff ;
end

mult_s18_s24 U_KP (.CLK(i_clk),.A({2'b0,i_P}),.B(s_diff     ),.P(w_kp_diff));
mult_s18_s40 U_KI (.CLK(i_clk),.A({2'b0,i_I}),.B(s_sum_diff ),.P(w_ki_diff));
mult_s18_s24 U_KD (.CLK(i_clk),.A({2'b0,i_D}),.B(s_diff_diff),.P(w_kd_diff));


always @ (posedge i_clk)
begin
    s_p_i   <= {{16{w_kp_diff[39]}},w_kp_diff} + w_ki_diff ;
    s_p_i_d <= s_p_i + {{16{w_kd_diff[39]}},w_kd_diff}     ;
end

trig_dly #(.DLY_CKNUM (4)) U_dly_out
(
    .i_clk                      ( i_clk   ),
    .i_trig                     ( s_gap_1dly   ),
    .o_trig                     ( o_vld   )
);

assign  o_y = s_out_temp ;

//------------------------------------------------------------
// 有效位宽
//------------------------------------------------------------
always @ (posedge i_clk)
begin
    // s_out_temp <= s_p_i_d[63:47] == {17{1'b1}} ? s_p_i_d[47:16] + s_p_i_d[47] ^ s_p_i_d[15] :
	              // s_p_i_d[63:47] == {17{1'b0}} ? s_p_i_d[47:16] + s_p_i_d[47] ^ s_p_i_d[15] :
				  // s_p_i_d[63]    == 1'b1      ? 32'h80000000 : 32'h7fffffff 
	                 // ;
	s_out_temp <= s_p_i_d[55:38] == {18{1'b1}} ? s_p_i_d[38:15] + s_p_i_d[55] ^ s_p_i_d[14] :
	              s_p_i_d[55:38] == {18{1'b0}} ? s_p_i_d[38:15] + s_p_i_d[55] ^ s_p_i_d[14] :
				  s_p_i_d[55]    == 1'b1      ? {1'b1,{23{1'b0}}} : {1'b0,{23{1'b1}}} 
	                 ;
end

/* 
//----------------------------------------------------------------------------
//
//   ila_pid
//   
//----------------------------------------------------------------------------
wire                    w_ck_pid       ;
wire    [23:0]          w_p0_pid        ;
wire    [23:0]          w_p1_pid        ;
wire    [23:0]          w_p2_pid        ;
wire    [39:0]          w_p3_pid        ;
wire    [39:0]          w_p4_pid        ;
wire    [55:0]          w_p5_pid        ;
wire    [23:0]          w_p6_pid        ;
wire    [0:0]           w_p7_pid        ;
assign  w_ck_pid  = i_clk ;
assign  w_p0_pid  = i_target     ;
assign  w_p1_pid  = i_x     ;
assign  w_p2_pid  = s_diff     ;
assign  w_p3_pid  = s_sum_diff     ;
assign  w_p4_pid  = w_kp_diff     ;
assign  w_p5_pid  = w_ki_diff     ;
assign  w_p6_pid  = s_out_temp     ;
assign  w_p7_pid  = s_gap_1dly     ;
ila_pid U_ila_pid
(
	 .clk           ( w_ck_pid  ) // input wire clk
	,.probe0        ( w_p0_pid   ) // input wire [31:0]  probe0  
	,.probe1        ( w_p1_pid   ) // input wire [31:0]  probe1 
	,.probe2        ( w_p2_pid   ) // input wire [31:0]  probe2 
	,.probe3        ( w_p3_pid   ) // input wire [31:0]  probe3 
	,.probe4        ( w_p4_pid   ) // input wire [31:0]  probe4 
	,.probe5        ( w_p5_pid   ) // input wire [31:0]  probe5 
	,.probe6        ( w_p6_pid   ) // input wire [31:0]  probe6 
	,.probe7        ( w_p7_pid   ) // input wire [0:0]   probe7 
); 

 */

endmodule
