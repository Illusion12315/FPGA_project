//////////////////////////////////////////////////////////////////////////////////
// Company              : Wuhan Jingneng Electronics Co., LTD
// Engineer             : Wangyanqing
//                        Senior Engineer
// Create Date          : 10:19 2024/9/18
// Module Name          : Main_ctrl_Pull_load
// Description          : 
// ---- 
// Additional Comments  : 
// ---- 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
//////////////////////////////////////////////////////////////////////////////////
                                 
module Main_ctrl_Pull_load #
(
parameter  _PRECHARGE_T  = 40  ,//MOS预充电时间(mS)
parameter  _PRECHARGE_I  = 50  ,//MOS预充电电流(mA)
parameter  _1US_CKNUM    = 100 
)
(
input                                   i_clk                ,// 
input                                   i_rst                ,// 
//common
input                                   i_on                 ,//停止
input                                   i_off                ,//运行
output                                  o_doing              ,//
input                                   i_hardCV_ON          ,//
//work_mode_function
input                                   i_workmode_CC        ,
input                                   i_workmode_CP        ,
input                                   i_workmode_CR        ,
input                                   i_workmode_CV        ,
input                                   i_func_STA           ,
input                                   i_func_DYN           ,
input                                   i_func_RIP           ,
input                                   i_func_RE            ,
input                                   i_func_FE            ,
input                                   i_func_BAT_N         ,
input                                   i_func_BAT_P         ,
input                                   i_func_LIST          ,
input                                   i_func_TOCP          ,
input                                   i_func_TOPP          ,
// input                                   i_flag_Short         ,//短路测试 (STA/DYN)
// input           [31:0]                  i_I_short            ,//短路时拉载电流
input                                   i_worktype_Single    ,//单机
input                                   i_ms_Master          ,//主机
//Von
input                                   i_Von_Latch_ON       ,//Latch ON
input 									i_Von_Latch_OFF		 ,//Latch OFF
input           [31:0]                  i_start_Volt         ,//启动电压
input           [31:0]                  i_stop_Volt          ,//停止电压
//max
input           [31:0]                  i_maxI_limit         ,//测试件最大电流限制
input           [31:0]                  i_maxU_limit         ,//测试件最大电压限制
input           [31:0]                  i_maxP_limit         ,//测试件最大功率限制
//limit
input           [31:0]                  i_setI_limit         ,//被测件最大电流限制
input           [31:0]                  i_setU_limit         ,//被测件最大电压限制
input           [31:0]                  i_setP_limit         ,//被测件最大功率限制
input           [31:0]                  i_setI_limit_CV      ,//被测件CV时最大电流限制
input           [15:0]                  i_T_pro              ,//保护时长设置
//real-time 
input                                   i_vld_rt             ,//5us采样更新
input           [31:0]                  i_U_rt               ,//实时采样电压
input           [31:0]                  i_I_rt               ,//实时采样电流
input           [31:0]                  i_P_rt               ,//实时采样功率
input           [31:0]                  i_R_rt               ,//实时采样电阻
//STA
input           [23:0]                  i_slew_CR_STA        ,//reg000B 静态模式下,电流上升斜率
input           [23:0]                  i_slew_CF_STA        ,//reg000C 静态模式下,电流下降斜率
input           [31:0]                  i_Iset_STA           ,//reg0011/reg0012
input           [31:0]                  i_Uset_STA           ,//reg0013/reg0014
input           [31:0]                  i_Pset_STA           ,//reg0015/reg0016
input           [31:0]                  i_Rset_STA           ,//reg0017/reg0018
//DYN
input                                   i_trigmode_DYN_C     ,//连续触发
input                                   i_trigmode_DYN_P     ,//脉冲触发
input                                   i_trigmode_DYN_T     ,//翻转触发
input                                   i_trigsource_DYN_N   ,//无触发(针对连续触发模式)
input                                   i_trigsource_DYN_M   ,//手动触发
input                                   i_trigsource_DYN_B   ,//总线触发
input                                   i_trigsource_DYN_O   ,//外部触发
input                                   i_triggen_DYN        ,//触发(针对手动触发)
input           [23:0]                  i_slew_CR_DYN        ,//reg002D 动态模式下,电流上升斜率(1mA/us)
input           [23:0]                  i_slew_CF_DYN        ,//reg002E 动态模式下,电流下降斜率(1mA/us)
input           [31:0]                  i_I1set_DYN          ,//reg0019/reg001A
input           [31:0]                  i_I2set_DYN          ,//reg001B/reg001C
input           [31:0]                  i_U1set_DYN          ,//reg001D/reg001E
input           [31:0]                  i_U2set_DYN          ,//reg001F/reg0020
input           [31:0]                  i_P1set_DYN          ,//reg0021/reg0022
input           [31:0]                  i_P2set_DYN          ,//reg0023/reg0024
input           [31:0]                  i_R1set_DYN          ,//reg0025/reg0026
input           [31:0]                  i_R2set_DYN          ,//reg0027/reg0028
input           [31:0]                  i_T1set_CC_DYN       ,//mS//reg0080/reg0081
input           [31:0]                  i_T2set_CC_DYN       ,//mS//reg0082/reg0083
input           [31:0]                  i_T1set_CV_DYN       ,//mS//reg0084/reg0085
input           [31:0]                  i_T2set_CV_DYN       ,//mS//reg0086/reg0087
input           [31:0]                  i_T1set_CP_DYN       ,//mS//reg0088/reg0089
input           [31:0]                  i_T2set_CP_DYN       ,//mS//reg008A/reg008B
input           [31:0]                  i_T1set_CR_DYN       ,//mS//reg008C/reg008D
input           [31:0]                  i_T2set_CR_DYN       ,//mS//reg008E/reg008F
//BAT
input                                   i_BT_Stop_U          ,//电压截止
input                                   i_BT_Stop_T          ,//时间截止
input                                   i_BT_Stop_C          ,//容量截止
input           [31:0]                  i_offV_BT_Stop       ,//mV//reg00B3/reg00B4 放电截止电压
input           [31:0]                  i_offT_BT_Stop       ,//S//reg00B5/reg00B6 放电截止时间
input           [31:0]                  i_offC_BT_Stop       ,//mAh//reg00B7/reg00B8 放电截止容量
input           [31:0]                  i_proV_BT_Stop       ,//mV//reg00B9/reg00BA 电池放电保护测试截止电压
output  reg                             o_cpl_BATT        =0 ,//电池放电完成
//TOCP
input           [31:0]                  i_start_Volt_TOCP    ,//mV//reg00C0/reg00C1 OCP测试的启动电压值
input           [31:0]                  i_start_Curr_TOCP    ,//mA//reg00C2/reg00C3 OCP测试的初始电流值
input           [31:0]                  i_stop_Curr_TOCP     ,//mA//reg00C4/reg00C5 OCP测试的截止电流值
input           [31:0]                  i_step_Curr_TOCP     ,//mA//reg00C6 OCP测试的步进电流值
input           [31:0]                  i_step_Time_TOCP     ,//S//reg00C7 OCP测试的步进时间值
input           [31:0]                  i_pro_Volt_TOCP      ,//mV//reg00C8/reg00C9 OCP测试的保护电压值
input           [31:0]                  i_over_Curr_MIN_TOCP ,//mA//reg00CA/reg00CB OCP测试的过电流最小值
input           [31:0]                  i_over_Curr_MAX_TOCP ,//mA//reg00CC/reg00CD OCP测试的过电流最大值
output  reg                             o_pass_TOCP       =0 ,//
output  reg                             o_fail_TOCP       =0 ,//
output  reg     [15:0]                  o_status_TOCP     =0 ,//
output  reg                             o_cpl_TOCP        =0 ,//
output  reg     [31:0]                  o_curTarget_TOCP  =0 ,//mA//reg00CE/reg00CF OCP测试的当前目标值(RO)
//TOPP
input           [31:0]                  i_start_Volt_TOPP    ,//mV//reg00D0/reg00D1 OPP测试的启动电压值
input           [31:0]                  i_start_Power_TOPP   ,//mW//reg00D2/reg00D3 OPP测试的初始功率值
input           [31:0]                  i_stop_Power_TOPP    ,//mW//reg00D4/reg00D5 OPP测试的截止功率值
input           [31:0]                  i_step_Power_TOPP    ,//mW//reg00D6 OPP测试的步进功率值
input           [31:0]                  i_step_Time_TOPP     ,//S//reg00D7 OPP测试的步进时间值
input           [31:0]                  i_pro_Volt_TOPP      ,//mV//reg00D8/reg00D9 OPP测试的保护电压值
input           [31:0]                  i_over_Power_MIN_TOPP,//mW//reg00DA/reg00DB OPP测试的过功率最小值
input           [31:0]                  i_over_Power_MAX_TOPP,//mW//reg00DC/reg00DD OPP测试的过功率最大值
output  reg                             o_pass_TOPP       =0 ,//
output  reg                             o_fail_TOPP       =0 ,//
output  reg     [15:0]                  o_status_TOPP     =0 ,//
output  reg                             o_cpl_TOPP        =0 ,//
output  reg     [31:0]                  o_curTarget_TOPP  =0 ,//mW//reg00DE/reg00DF OPP测试的当前目标值(RO)
//List
    input              [  15: 0]    i_total_stepnum_list,//总的步数
    input              [  15: 0]    i_total_loopnum_list,//总的循环数//0:无限循环
    input                           i_workmode_CC_list  ,//CC静态工作模式
    input                           i_workmode_CP_list  ,//CP静态工作模式
    input                           i_workmode_CR_list  ,//CR静态工作模式
    input                           i_workmode_CV_list  ,//CV静态工作模式
    input              [  31: 0]    i_target_list       ,//拉载值//mA/mW/ohm/mV
    input              [  31: 0]    i_runtime_list      ,//单步执行时间//uS
    input              [  15: 0]    i_repeat_list       ,//单步循环次数//1-65535
    input              [  15: 0]    i_goto_list         ,//小循环跳转目的地//1-999//无效0xFFFF
    input              [  15: 0]    i_loop_list         ,//小循环次数//1-65535
    output             [  15: 0]    o_cnt_repeat_list   ,//单步重复计数(1-65535)
    output             [  15: 0]    o_cnt_total_loop_list,//总循环计数(1-1000)
    output reg         [  15: 0]    o_curstepnum_list =0,//当前执行编号//1-1000
    output             [  15: 0]    o_cnt_loop_list     ,//小循环计数(1-65535)
    output reg                      o_cpl_list        =0,//list列表执行结束
//DAC控制
output  reg                             o_outa_enb        =0 ,//
output  reg     [15:0]                  o_outa_data       =0 ,//CELL_PROG_DA
output  reg                             o_outb_enb        =0 ,//
output  reg     [15:0]                  o_outb_data       =0 ,//CV_limit_DA
//output
output  reg                             o_workmode_CC_rt  =0 ,//实时工作模式
output  reg                             o_workmode_CP_rt  =0 ,//实时工作模式
output  reg                             o_workmode_CR_rt  =0 ,//实时工作模式
output  reg                             o_workmode_CV_rt  =0 ,//实时工作模式
output  reg                             o_flag_1us        =0 ,//I_slew
output  reg                             o_flag_1ms        =0 ,//
output  reg                             o_flag_1s         =0 ,//BAT
output  reg     [23:0]                  o_SR_slew         =0 ,//电流上升沿mA/1us
output  reg     [23:0]                  o_SF_slew         =0 ,//电流下降沿mA/1us
output  reg                             o_enb_slew        =0 ,//电流需要上升沿和下降沿使能
output  reg                             o_enb_precharge   =0 ,//预充
//
output  reg     [23:0]                  o_initI_pull         =0 ,//
input           [23:0]                  i_curI_CC            ,//
input           [23:0]                  i_curI_CP            ,//
input           [23:0]                  i_curI_CR            ,//
input           [23:0]                  i_curI_CV            ,//
//CC拉载                                                     
output  reg                             o_CC_on           =0 ,//打开
output  reg                             o_CC_off          =0 ,//关闭
output  reg     [23:0]                  o_CC_target       =0 ,//目标值mA
input                                   i_CC_cpl             ,
input                                   i_CC_ctrlen          ,//
input           [15:0]                  i_CC_ctrl            ,//
input           [15:0]                  i_CC_limit_ctrl      ,//
//CP拉载                                                     
output  reg                             o_CP_on           =0 ,//打开
output  reg                             o_CP_off          =0 ,//关闭
output  reg     [31:0]                  o_CP_target       =0 ,//目标值mA
input                                   i_CP_cpl             ,
input                                   i_CP_ctrlen          ,//
input           [15:0]                  i_CP_ctrl            ,//
input           [15:0]                  i_CP_limit_ctrl      ,//
//CR拉载                                                     
output  reg                             o_CR_on           =0 ,//打开
output  reg                             o_CR_off          =0 ,//关闭
output  reg     [31:0]                  o_CR_target       =0 ,//目标值mA
input                                   i_CR_cpl             ,
input                                   i_CR_ctrlen          ,//
input           [15:0]                  i_CR_ctrl            ,//
input           [15:0]                  i_CR_limit_ctrl      ,//
//CV拉载                                                     
output  reg                             o_CV_on           =0 ,//打开
output  reg                             o_CV_off          =0 ,//关闭
output  reg     [23:0]                  o_CV_target       =0 ,//目标值mA
input                                   i_CV_cpl             ,
input                                   i_CV_ctrlen          ,//
input           [15:0]                  i_CV_ctrl            ,//
input           [15:0]                  i_CV_limit_ctrl      ,//
//BAT电池放电
output  reg                             o_BAT_on          =0 ,//打开
output  reg                             o_BAT_off         =0 ,//关闭
input           [31:0]                  i_BAT_cap            ,//放电容量mAh  
input           [31:0]                  i_BAT_time           ,//放电时间S
input           [23:0]                  i_BAT_U              ,//放电电压mV
input           [23:0]                  i_BAT_I              ,//放电电流mA
input           [31:0]                  i_BAT_R              ,//放电电阻ohm*10-4
input           [1:0]                   i_BAT_err             //电池错误 b0:I反向 b1:U反向
);
//
reg                                     s_hardCV_1r      =0  ;//
reg                                     s_hardCV_2r      =0  ;//

reg             [7 : 0]                 s_cnt_ns         =0 ;
reg             [9 : 0]                 s_cnt_us         =0 ;
reg             [9 : 0]                 s_cnt_ms         =0 ;
reg             [5 : 0]                 s_cnt_s          =0 ;
wire                                    w_done_cntns        ;
wire                                    w_done_cntus        ;
wire                                    w_done_cntms        ;
wire                                    w_done_cnts         ;

reg             [11:0]                   Curfunc          =0 ;
reg             [11:0]                   Oldfunc          =0 ;
wire                                    w_funcchange        ;

reg             [3:0]                   s_workmode_temp  =0 ;

assign  w_done_cntns = s_cnt_ns >= _1US_CKNUM-1  ? 1'b1 : 1'b0 ;
assign  w_done_cntus = s_cnt_us >= 1000-1 ? 1'b1 : 1'b0 ;
assign  w_done_cntms = s_cnt_ms >= 1000-1 ? 1'b1 : 1'b0 ;
assign  w_done_cnts  = s_cnt_s  >= 60-1   ? 1'b1 : 1'b0 ;

assign  w_funcchange = |(Curfunc ^ Oldfunc) ;//功能变化
always @ (posedge i_clk)
begin
    Curfunc <= {i_on,i_off,i_func_FE,i_func_RE,i_func_RIP,i_func_BAT_P,i_func_BAT_N,i_func_TOPP,i_func_TOCP,i_func_LIST,i_func_DYN,i_func_STA};
	Oldfunc <= Curfunc ;
end

always @ (posedge i_clk)
begin
    casex ({w_funcchange,w_done_cntns})
	2'b1x   : s_cnt_ns  <=  'd0            ;
	2'b01   : s_cnt_ns  <=  'd0            ;
	2'b00   : s_cnt_ns  <=  s_cnt_ns + 'd1 ;
	default : s_cnt_ns  <=  s_cnt_ns       ;
	endcase
end
always @ (posedge i_clk)
begin
    casex ({w_funcchange,w_done_cntns,w_done_cntus})
	3'b1xx  : s_cnt_us  <=  'd0            ;
	3'b011  : s_cnt_us  <=  'd0            ;
	3'b010  : s_cnt_us  <=  s_cnt_us + 'd1 ;
	default : s_cnt_us  <=  s_cnt_us       ;
	endcase
end
always @ (posedge i_clk)
begin
    casex ({w_funcchange,w_done_cntns,w_done_cntus,w_done_cntms})
	4'b1xxx : s_cnt_ms  <=  'd0            ;	
	4'b0111 : s_cnt_ms  <=  'd0            ;
	4'b0110 : s_cnt_ms  <=  s_cnt_ms + 'd1 ;
	default : s_cnt_ms  <=  s_cnt_ms       ;
	endcase
end
always @ (posedge i_clk)
begin
    casex ({w_funcchange,w_done_cntns,w_done_cntus,w_done_cntms,w_done_cnts})
	5'b1xxxx : s_cnt_s  <=  'd0            ;
	5'b01111 : s_cnt_s  <=  'd0            ;
	5'b01110 : s_cnt_s  <=  s_cnt_s + 'd1  ;
	default  : s_cnt_s  <=  s_cnt_s        ;
	endcase
end

//
//b0:i_workmode_CC b1:i_workmode_CP b2:i_workmode_CR b3:i_workmode_CV b4:1'b0 b5:i_trigmode_DYN_C b6:i_trigmode_DYN_P b7:i_trigmode_DYN_T
reg             [7:0]                   CurWorkMode     =0 ;
reg             [7:0]                   OldWorkMode     =0 ;
wire                                    w_modechange       ;

assign  w_modechange = |(CurWorkMode ^ OldWorkMode) ;//工作类型变化//针对静态/动态/List
always @ (posedge i_clk)
begin
    CurWorkMode <= {i_trigmode_DYN_T,i_trigmode_DYN_P,i_trigmode_DYN_C,1'b0,i_workmode_CV,i_workmode_CR,i_workmode_CP,i_workmode_CC};
	OldWorkMode <= CurWorkMode ;
end

reg                                     s_pullout_enb     =0 ;//拉载使能
reg                                     s_pullout_enb_add =0 ;//
reg             [15:0]                  s_cnt_pullout_add =0 ;//
wire                                    w_done_pullout_add   ;//
													      
reg             [31:0]                  s_cnt_protime_i   =0 ;//时钟计数
reg             [31:0]                  s_cnt_protime_v   =0 ;//时钟计数
reg             [31:0]                  s_cnt_protime_p   =0 ;//时钟计数
reg             [31:0]                  s_cknum_prot      =0 ;//保护时间换算成时钟数
wire                                    w_done_cntprotime_i  ;
wire                                    w_done_cntprotime_v  ;
wire                                    w_done_cntprotime_p  ;
														 
reg             [7 : 0]                 s_cnt_ns_DYN      =0 ;
reg             [9 : 0]                 s_cnt_us_DYN      =0 ;
wire                                    w_done_ns_DYN        ;
wire                                    w_done_us_DYN        ;
reg             [31:0]                  s_cnt_t1us        =0 ;
reg             [31:0]                  s_cnt_t2us        =0 ;
reg             [31:0]                  s_T1set_DYN       =1 ;
reg             [31:0]                  s_T2set_DYN       =1 ;
wire                                    w_done_cntt1us       ;
wire                                    w_done_cntt2us       ;
reg                                     s_T1_stage        =1 ;
//list                                                             
reg             [15:0]                  s_cnt_total_loop_list  =1 ;//总循环计数(1-1000)
reg             [31:0]                  s_cnt_runtime_list     =1 ;//单步运行时间计数(1clk=10ns)
reg             [15:0]                  s_cnt_repeat_list      =1 ;//单步重复计数(1-65535)
reg             [15:0]                  s_cnt_loop_list        =1 ;//小循环计数(1-65535)
wire                                    w_done_total_loop_list    ;
wire                                    w_done_runus_list         ;
wire                                    w_done_repeat_list        ;
wire                                    w_done_loop_list          ;
																   
reg                                     s_rdbuff_enb               =0 ;
reg                                     s_rdbuff_enb_1dly          =0 ;
reg             [15:0]                  s_latch_total_stepnum_list =0 ;
reg             [15:0]                  s_latch_total_loopnum_list =0 ;
reg                                     s_latch_workmode_CC_list   =0 ;
reg                                     s_latch_workmode_CP_list   =0 ;
reg                                     s_latch_workmode_CR_list   =0 ;
reg                                     s_latch_workmode_CV_list   =0 ;
reg             [31:0]                  s_latch_target_list        =0 ;//拉载值
reg             [31:0]                  s_latch_runtime_list       =0 ;//uS//单步执行时间
wire            [31:0]                  w_latch_runtime_list          ;//10nS//单步执行时间
reg             [15:0]                  s_latch_repeat_list        =0 ;//单步循环次数,1-65535
reg             [15:0]                  s_latch_goto_list          =0 ;//小循环跳转目的地,1-999,无效0xFFFF
reg             [15:0]                  s_latch_loop_list          =0 ;//小循环次数,1-65535
															 
reg             [7 : 0]                 s_cnt_ns_TOCPP       =0 ;
reg             [9 : 0]                 s_cnt_us_TOCPP       =0 ;
reg             [9 : 0]                 s_cnt_ms_TOCPP       =0 ;
wire                                    w_done_ns_TOCPP         ;
wire                                    w_done_us_TOCPP         ;
wire                                    w_done_ms_TOCPP         ;

reg             [31:0]                  s_cnt_steptime_TOCP  =0 ;
wire                                    w_done_steptime_TOCP    ;
reg                                     s_init_TOCP          =1 ;
reg             [31:0]                  s_cnt_steptime_TOPP  =0 ;
wire                                    w_done_steptime_TOPP    ;
reg                                     s_init_TOPP          =1 ;

reg                                     s_init_CC  =1 ;//CC拉载初始状态
reg                                     s_init_CP  =1 ;//CP拉载初始状态
reg                                     s_init_CR  =1 ;//CR拉载初始状态
reg                                     s_init_CV  =1 ;//CV拉载初始状态

reg                                     s_von_enb_pull   =0 ;//第一次拉载
reg             [9 : 0]                 s_cntmsprecharge =0 ;//预充时间计时
wire                                    w_done_precharge    ;//
//
//b0:i_workmode_CC_list b1:i_workmode_CP_list b2:i_workmode_CR_list b3:i_workmode_CV_list
reg             [3:0]                   CurWorkMode_list  =0 ;
reg             [3:0]                   OldWorkMode_list  =0 ;
wire                                    w_modechange_list    ;

assign  w_modechange_list = |(CurWorkMode_list ^ OldWorkMode_list) ;
always @ (posedge i_clk)
begin
    CurWorkMode_list <= {s_latch_workmode_CV_list,s_latch_workmode_CR_list,s_latch_workmode_CP_list,s_latch_workmode_CC_list};
	OldWorkMode_list <= CurWorkMode_list ;
end

//b0:i_workmode_CC b1:i_workmode_CP b2:i_workmode_CR b3:i_workmode_CV b4: b5: b6: b7:
reg             [7:0]                   CurWorkMode_bat  =0 ;
reg             [7:0]                   OldWorkMode_bat  =0 ;
wire                                    w_modechange_bat    ;

assign  w_modechange_bat = |(CurWorkMode_bat ^ OldWorkMode_bat) ;
always @ (posedge i_clk)
begin
    CurWorkMode_bat <= {i_BT_Stop_C,i_BT_Stop_T,i_BT_Stop_U,i_workmode_CV,i_workmode_CR,i_workmode_CP,i_workmode_CC};
	OldWorkMode_bat <= CurWorkMode_bat ;
end

//5us采样更新
wire                                    w_setI_over     ;//
wire                                    w_setU_over     ;//
wire                                    w_setP_over     ;//
wire                                    w_setI_over_CV  ;//

assign  w_setI_over    = i_I_rt > i_setI_limit    ? 1'b1 : 1'b0 ;
// assign  w_setU_over    = i_U_rt > i_setU_limit    ? 1'b1 : 1'b0 ;
assign  w_setU_over    = 1'b0 ;//unused
assign  w_setP_over    = i_P_rt > i_setP_limit    ? 1'b1 : 1'b0 ;
assign  w_setI_over_CV = i_I_rt > i_setI_limit_CV ? 1'b1 : 1'b0 ;

wire            [23:0]                  w_maxI_limit      ;
wire            [23:0]                  w_maxU_limit      ;
wire            [31:0]                  w_maxP_limit      ;
wire                                    w_maxI_limit_over ;
wire                                    w_maxU_limit_over ;
wire                                    w_maxP_limit_over ;

assign  w_maxI_limit_over = i_I_rt > w_maxI_limit ? 1'b1 : 1'b0 ;
assign  w_maxU_limit_over = i_U_rt > w_maxU_limit ? 1'b1 : 1'b0 ;
assign  w_maxP_limit_over = i_P_rt > w_maxP_limit ? 1'b1 : 1'b0 ;
X_1R03 #(.D_WIDTH(24)) U_maxI_1R03(.i_clk(i_clk),.i_xen(1),.i_X(i_maxI_limit),.o_X_1R03en(),.o_X_1R03(w_maxI_limit));
X_1R03 #(.D_WIDTH(24)) U_maxU_1R03(.i_clk(i_clk),.i_xen(1),.i_X(i_maxU_limit),.o_X_1R03en(),.o_X_1R03(w_maxU_limit));
X_1R03 #(.D_WIDTH(32)) U_maxP_1R03(.i_clk(i_clk),.i_xen(1),.i_X(i_maxP_limit),.o_X_1R03en(),.o_X_1R03(w_maxP_limit));


wire                                    w_I_over     ;
wire                                    w_U_over     ;
wire                                    w_P_over     ;
wire                                    w_I_over_CV  ;

assign  w_I_over    =  w_setI_over | w_maxI_limit_over ;
assign  w_U_over    =  w_setU_over | w_maxU_limit_over ;
assign  w_P_over    =  w_setP_over | w_maxP_limit_over ;
assign  w_I_over_CV =  w_setI_over_CV | w_maxI_limit_over ;



always @ (posedge i_clk)
begin
    if ((w_done_cntns == 1'b1))
	    o_flag_1us <= 1'b1 ;
	else
	    o_flag_1us <= 1'b0 ;	
	
	if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1))
	    o_flag_1ms <= 1'b1 ;
	else
	    o_flag_1ms <= 1'b0 ;
	
	if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (w_done_cntms == 1'b1))
	    o_flag_1s <= 1'b1 ;
	else
	    o_flag_1s <= 1'b0 ;
end



assign  w_done_pullout_add = s_cnt_pullout_add >= 'd65530 ? 1'b1 : 1'b0 ;
always @ (posedge i_clk)
begin
    if (s_pullout_enb == 1)
	    s_cnt_pullout_add <= 'h0 ;
	else if (w_done_pullout_add == 0)
	    s_cnt_pullout_add <= s_cnt_pullout_add + 'h1 ;
	else
	    s_cnt_pullout_add <= s_cnt_pullout_add  ;
		
	if (s_pullout_enb == 1)
	    s_pullout_enb_add <= 1 ;
	else if (w_done_pullout_add == 1)
	    s_pullout_enb_add <= 0 ;
	else
	    s_pullout_enb_add <= s_pullout_enb_add  ;		
end
assign  o_doing = s_pullout_enb || s_pullout_enb_add ;



always @ (posedge i_clk)
begin
    if ((i_rst == 1) || (i_off == 1'b1)) //PS_off//OCP/OVP/OPP
	    s_pullout_enb <= 1'b0 ;
	else if (i_on == 1'b1) //PS_on
	    s_pullout_enb <= 1'b1 ;
	else
	    s_pullout_enb <= s_pullout_enb ;
end

always @ (posedge i_clk)
begin
    if ((s_pullout_enb == 1'b0) || (w_funcchange == 1'b1))
	    begin
		    o_CC_on  <= 0 ; o_CP_on  <= 0 ; o_CR_on  <= 0 ; o_CV_on  <= 0 ; o_BAT_on  <= 0 ;
            o_CC_off <= 1 ; o_CP_off <= 1 ; o_CR_off <= 1 ; o_CV_off <= 1 ;	o_BAT_off <= 1 ;
			o_SR_slew   <= o_SR_slew ; o_SF_slew   <= o_SF_slew ; o_enb_slew <= 1 ; o_enb_precharge <= 1 ;
			o_CC_target <= 'h0 ; o_CP_target <= 'h0 ; o_CR_target <= 'd1000000000 ; o_CV_target <= 'h0 ;
			o_workmode_CC_rt <= 1'b0 ; o_workmode_CP_rt <= 1'b0 ; o_workmode_CR_rt <= 1'b0 ; o_workmode_CV_rt <= 1'b0 ;
			o_initI_pull <= 'h0 ;
	    end	
	else
	    begin	
	        case ( Curfunc )
	        10'b0000000001 : begin //STA
								o_SR_slew   <= i_slew_CR_STA ;
								o_SF_slew   <= i_slew_CF_STA ;
								
								if (w_modechange == 1'b1)
								    begin
									    o_CC_on  <= 0 ; o_CP_on  <= 0 ; o_CR_on  <= 0 ; o_CV_on  <= 0 ;
                                        o_CC_off <= 1 ; o_CP_off <= 1 ; o_CR_off <= 1 ; o_CV_off <= 1 ;
										o_enb_slew <= 1 ; o_enb_precharge <= o_enb_precharge ;
										o_CC_target <= 'h0 ; o_CP_target <= 'h0 ; o_CR_target <= 'd1000000000 ; o_CV_target <= 'h0 ;
										o_workmode_CC_rt <= 0 ; o_workmode_CP_rt <= 0 ; o_workmode_CR_rt <= 0 ; o_workmode_CV_rt <= 0 ;										
										o_initI_pull <= o_initI_pull ;
									end
								else 
								if ((CurWorkMode[0] == 1'b1) || ((CurWorkMode[3] == 1'b1) && (i_worktype_Single == 1'b0) && (i_ms_Master == 1'b0)))/* i_workmode_CC */
	        					    begin
	        							o_workmode_CC_rt <= 1 ; 
										o_enb_slew <= 1 ;

										if (s_init_CC == 1)
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										else if (s_von_enb_pull == 1) begin
											// if (s_cnt_us == 299)//用于仿真
											if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											//     begin o_enb_precharge <= 1 ;  end
											else
											    begin o_enb_precharge <= o_enb_precharge ;  end
											
											/* if ((o_enb_precharge == 0) && (i_CC_cpl == 1))
											    begin o_enb_slew <= 0 ; end
											else if (o_enb_precharge == 1)
											    begin o_enb_slew <= 1 ; end
											else
											    begin o_enb_slew <= o_enb_slew ; end */
										end
										else
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										
										if (s_init_CC == 1)
										    begin o_CC_on <= 1 ; o_CC_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CC_on <= 1 ; o_CC_off <= 0 ; 	
										end
										else
										    begin o_CC_on <= 0 ; o_CC_off <= 1 ; end
										
										o_CC_target <= i_Iset_STA ;
										o_initI_pull <= i_curI_CC  ; 
	        						end
	        					else if (CurWorkMode[1] == 1'b1)/* i_workmode_CP */
	        					    begin
										o_workmode_CP_rt <= 1 ; 
										o_enb_slew <= 1 ;
										
										if (s_init_CP == 1)
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										else if (s_von_enb_pull == 1) begin
											if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											//     begin o_enb_precharge <= 1 ;  end
											else
											    begin o_enb_precharge <= o_enb_precharge ;  end
											
											/* if ((o_enb_precharge == 0) && (i_CP_cpl == 1))
											    begin o_enb_slew <= 0 ; end
											else if (o_enb_precharge == 1)
											    begin o_enb_slew <= 1 ; end
											else
											    begin o_enb_slew <= o_enb_slew ; end */
										end
										else
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										
										if (s_init_CP == 1)
										    begin o_CP_on <= 1 ; o_CP_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CP_on <= 1 ; o_CP_off <= 0 ;
										end
										else
										    begin o_CP_on <= 0 ; o_CP_off <= 1 ; end
											
	        							o_CP_target <= i_Pset_STA ;
										o_initI_pull <= i_curI_CP  ; 
	        						end
	        					else if (CurWorkMode[2] == 1'b1)/* i_workmode_CR */
	        					    begin
										o_workmode_CR_rt <= 1 ; 
										// o_enb_slew <= 1 ;
										
										if (s_init_CR == 1)
										    begin o_enb_slew <= 1 ; /* o_enb_precharge <= 1 ; */ end
										else if (s_von_enb_pull == 1) begin
											if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											//     begin o_enb_precharge <= 1 ;  end
											else
											    begin o_enb_precharge <= o_enb_precharge ;  end
											
											if ((o_enb_precharge == 0) && (i_CR_cpl == 1))
											    begin o_enb_slew <= 0 ; end
											else if (o_enb_precharge == 1)
											    begin o_enb_slew <= 1 ; end
											else
											    begin o_enb_slew <= o_enb_slew ; end
										end
										else
										    begin o_enb_slew <= 1 ; /* o_enb_precharge <= 1 ; */ end
										
										if (s_init_CR == 1)
										    begin o_CR_on <= 1 ; o_CR_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CR_on <= 1 ; o_CR_off <= 0 ;
										end
										else
										    begin o_CR_on <= 0 ; o_CR_off <= 1 ; end
	        							
	        							o_CR_target <= i_Rset_STA ;
										o_initI_pull <= i_curI_CR  ; 
	        						end
	        					else if (CurWorkMode[3] == 1'b1)/* i_workmode_CV */
	        					    begin
										o_workmode_CV_rt <= 1 ; 
										o_enb_slew <= 1 ;
										
										if (s_init_CV == 1)
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										else if (s_von_enb_pull == 1) begin
											// if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											    // begin o_enb_precharge <= 1 ;  end
											// else
											    // begin o_enb_precharge <= o_enb_precharge ;  end
											
											/* if ((o_enb_precharge == 0) && (i_CV_cpl == 1))
											    begin o_enb_slew <= 0 ; end
											else if (o_enb_precharge == 1)
											    begin o_enb_slew <= 1 ; end
											else
											    begin o_enb_slew <= o_enb_slew ; end */
										end
										else
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										
										if (s_init_CV == 1)
										    begin o_CV_on <= 1 ; o_CV_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CV_on <= 1 ; o_CV_off <= 0 ; 
										end
										else
										    begin o_CV_on <= 0 ; o_CV_off <= 1 ; end
	        							
	        							o_CV_target <= i_Uset_STA ;
										o_initI_pull <= i_curI_CV  ; 
	        						end
	        					else
	        					    begin
									    o_CC_on  <= 0 ; o_CP_on  <= 0 ; o_CR_on  <= 0 ; o_CV_on  <= 0 ;
	        							o_CC_off <= 1 ; o_CP_off <= 1 ; o_CR_off <= 1 ; o_CV_off <= 1 ;
										o_SR_slew   <= o_SR_slew ; o_SF_slew   <= o_SF_slew ; o_enb_slew <= 1 ; o_enb_precharge <= 1 ;
			                            o_CC_target <= 'h0 ; o_CP_target <= 'h0 ; o_CR_target <= 'd1000000000 ; o_CV_target <= 'h0 ;
										o_workmode_CC_rt <= 0 ; o_workmode_CP_rt <= 0 ; o_workmode_CR_rt <= 0 ; o_workmode_CV_rt <= 0 ;
										o_initI_pull <= 'h0 ;
	        						end
	                        end
	        10'b0000000010 : begin //DYN
	                            o_SR_slew   <= i_slew_CR_DYN ;
								o_SF_slew   <= i_slew_CF_DYN ;
								
								if (w_modechange == 1'b1)
								    begin
									    o_CC_on  <= 0 ; o_CP_on  <= 0 ; o_CR_on  <= 0 ; o_CV_on  <= 0 ;
                                        o_CC_off <= 1 ; o_CP_off <= 1 ; o_CR_off <= 1 ; o_CV_off <= 1 ;
										o_enb_slew <= 1 ; o_enb_precharge <= o_enb_precharge ;
			                            o_CC_target <= 'h0 ; o_CP_target <= 'h0 ; o_CR_target <= 'd1000000000 ; o_CV_target <= 'h0 ;
										o_workmode_CC_rt <= 0 ; o_workmode_CP_rt <= 0 ; o_workmode_CR_rt <= 0 ; o_workmode_CV_rt <= 0 ;
										o_initI_pull <= o_initI_pull ;
									end
								else 
								if ((CurWorkMode[0] == 1'b1) || ((CurWorkMode[3] == 1'b1) && (i_worktype_Single == 1'b0) && (i_ms_Master == 1'b0)))/* i_workmode_CC */
	        					    begin
										o_workmode_CC_rt <= 1 ;
										o_enb_slew <= 1 ;
										
										if (s_init_CC == 1)
										    begin /* o_enb_precharge <= 1 ; */ end
										else if (s_von_enb_pull == 1) begin
											// if (s_cnt_us == 299)//用于仿真
											if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											//     begin o_enb_precharge <= 1 ;  end
											else
											    begin o_enb_precharge <= o_enb_precharge ;  end
										end
										else
										    begin /* o_enb_precharge <= 1 ; */ end
										
										if (s_init_CC == 1)
										    begin o_CC_on <= 1 ; o_CC_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CC_on <= 1 ; o_CC_off <= 0 ; 	
										end
										else
										    begin o_CC_on <= 0 ; o_CC_off <= 1 ; end
										
										if (s_T1_stage == 1'b1) 
										    o_CC_target <= i_I1set_DYN ;
										else 
										    o_CC_target <= i_I2set_DYN ;
										
										o_initI_pull <= i_curI_CC ;
	        						end
	        					else if (CurWorkMode[1] == 1'b1)/* i_workmode_CP */
	        					    begin
										o_workmode_CP_rt <= 1 ;
										o_enb_slew <= 1 ;
										
										if (s_init_CP == 1)
										    begin /* o_enb_precharge <= 1 ; */ end
										else if (s_von_enb_pull == 1) begin
											if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											//     begin o_enb_precharge <= 1 ;  end
											else
											    begin o_enb_precharge <= o_enb_precharge ;  end
										end
										else
										    begin /* o_enb_precharge <= 1 ; */ end
										
										if (s_init_CP == 1)
										    begin o_CP_on <= 1 ; o_CP_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CP_on <= 1 ; o_CP_off <= 0 ;
										end
										else
										    begin o_CP_on <= 0 ; o_CP_off <= 1 ; end
										
										if (s_T1_stage == 1'b1) 
										    o_CP_target <= i_P1set_DYN ;
										else 
										    o_CP_target <= i_P2set_DYN ;
											
										o_initI_pull <= i_curI_CP ;
	        						end
	        					else if (CurWorkMode[2] == 1'b1)/* i_workmode_CR */
	        					    begin	        						    
										o_workmode_CR_rt <= 1 ;
										o_enb_slew <= 1 ;
										
										if (s_init_CR == 1)
										    begin /* o_enb_precharge <= 1 ; */ end
										else if (s_von_enb_pull == 1) begin
											if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											//     begin o_enb_precharge <= 1 ;  end
											else
											    begin o_enb_precharge <= o_enb_precharge ;  end											
										end
										else
										    begin /* o_enb_precharge <= 1 ; */ end
										
										if (s_init_CR == 1)
										    begin o_CR_on <= 1 ; o_CR_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CR_on <= 1 ; o_CR_off <= 0 ; 
										end
										else
										    begin o_CR_on <= 0 ; o_CR_off <= 1 ; end
										
										if (s_T1_stage == 1'b1) 
										    o_CR_target <= i_R1set_DYN ;
										else 
										    o_CR_target <= i_R2set_DYN ;
											
										o_initI_pull <= i_curI_CR ;
	        						end
	        					else if (CurWorkMode[3] == 1'b1)/* i_workmode_CV */
	        					    begin	        						    
										o_workmode_CV_rt <= 1 ;
										o_enb_slew <= 1 ; 
										
										if (s_init_CV == 1)
										    begin /* o_enb_precharge <= 1 ; */ end
										else if (s_von_enb_pull == 1) begin
											// if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											    // begin o_enb_precharge <= 1 ;  end
											// else
											    // begin o_enb_precharge <= o_enb_precharge ;  end
										end
										else
										    begin /* o_enb_precharge <= 1 ; */ end
										
										if (s_init_CV == 1)
										    begin o_CV_on <= 1 ; o_CV_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CV_on <= 1 ; o_CV_off <= 0 ;
										end
										else
										    begin o_CV_on <= 0 ; o_CV_off <= 1 ; end
	        							
										if (s_T1_stage == 1'b1) 
										    o_CV_target <= i_U1set_DYN ;
										else 
										    o_CV_target <= i_U2set_DYN ;
											
										o_initI_pull <= i_curI_CV ;
	        						end
	        					else
	        					    begin
									    o_CC_on  <= 0 ; o_CP_on  <= 0 ; o_CR_on  <= 0 ; o_CV_on  <= 0 ;
	        							o_CC_off <= 1 ; o_CP_off <= 1 ; o_CR_off <= 1 ; o_CV_off <= 1 ;
										o_SR_slew   <= o_SR_slew ; o_SF_slew   <= o_SF_slew ; o_enb_slew <= 1 ; o_enb_precharge <= 1 ; 
			                            o_CC_target <= 'h0 ; o_CP_target <= 'h0 ; o_CR_target <= 'd1000000000 ; o_CV_target <= 'h0 ;
										o_workmode_CC_rt <= 0 ; o_workmode_CP_rt <= 0 ; o_workmode_CR_rt <= 0 ; o_workmode_CV_rt <= 0 ;
										o_initI_pull <= 'h0 ;
	        						end
	                        end
	        10'b0000000100 : begin //LIST
			                    o_SR_slew   <= i_slew_CR_STA ;
								o_SF_slew   <= i_slew_CF_STA ;
								
								if ((w_modechange_list == 1'b1) || (o_cpl_list == 1)) //列表执行完不拉载
								// if (o_cpl_list == 1) //列表执行完不拉载
								    begin
									    o_CC_on  <= 0 ; o_CP_on  <= 0 ; o_CR_on  <= 0 ; o_CV_on  <= 0 ;
                                        o_CC_off <= 1 ; o_CP_off <= 1 ; o_CR_off <= 1 ; o_CV_off <= 1 ;
										o_enb_slew <= 1 ; o_enb_precharge <= o_enb_precharge ; 
			                            o_CC_target <= 'h0 ; o_CP_target <= 'h0 ; o_CR_target <= 'd1000000000 ; o_CV_target <= 'h0 ;
										o_workmode_CC_rt <= 0 ; o_workmode_CP_rt <= 0 ; o_workmode_CR_rt <= 0 ; o_workmode_CV_rt <= 0 ;
										o_initI_pull <= o_initI_pull ;
									end
								else if ((CurWorkMode_list[0] == 1'b1) || ((CurWorkMode_list[3] == 1'b1) && (i_worktype_Single == 1'b0) && (i_ms_Master == 1'b0)))/* i_workmode_CC */
	        					    begin
	        							o_workmode_CC_rt <= 1 ; 
										o_enb_slew <= 1 ;
										
										if (s_init_CC == 1)
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										else if (s_von_enb_pull == 1) begin
											if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											//     begin o_enb_precharge <= 1 ;  end
											else
											    begin o_enb_precharge <= o_enb_precharge ;  end
											
											/* if ((o_enb_precharge == 0) && (i_CC_cpl == 1))
											    begin o_enb_slew <= 0 ; end
											else if (o_enb_precharge == 1)
											    begin o_enb_slew <= 1 ; end
											else
											    begin o_enb_slew <= o_enb_slew ; end */
										end
										else
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										
										if (s_init_CC == 1)
										    begin o_CC_on <= 1 ; o_CC_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CC_on <= 1 ; o_CC_off <= 0 ;
										end
										else
										    begin o_CC_on <= 0 ; o_CC_off <= 1 ; end
										
										o_CC_target <= s_latch_target_list ;
										o_initI_pull <= i_curI_CC ;
	        						end
	        					else if (CurWorkMode_list[1] == 1'b1)/* i_workmode_CP */
	        					    begin	        						    
										o_workmode_CP_rt <= 1 ; 
										o_enb_slew <= 1 ;
										
										if (s_init_CP == 1)
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										else if (s_von_enb_pull == 1) begin
											if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											//     begin o_enb_precharge <= 1 ;  end
											else
											    begin o_enb_precharge <= o_enb_precharge ;  end
											
											/* if ((o_enb_precharge == 0) && (i_CP_cpl == 1))
											    begin o_enb_slew <= 0 ; end
											else if (o_enb_precharge == 1)
											    begin o_enb_slew <= 1 ; end
											else
											    begin o_enb_slew <= o_enb_slew ; end */
										end
										else
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										
										if (s_init_CP == 1)
										    begin o_CP_on <= 1 ; o_CP_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CP_on <= 1 ; o_CP_off <= 0 ; 
										end
										else
										    begin o_CP_on <= 0 ; o_CP_off <= 1 ; end	
	        								
	        							o_CP_target <= s_latch_target_list ;
										o_initI_pull <= i_curI_CP ;
	        						end
	        					else if (CurWorkMode_list[2] == 1'b1)/* i_workmode_CR */
	        					    begin
										o_workmode_CR_rt <= 1 ; 
										// o_enb_slew <= 1 ;
																		
										if (s_init_CR == 1)
										    begin o_enb_slew <= 1 ; /* o_enb_precharge <= 1 ; */ end
										else if (s_von_enb_pull == 1) begin
											if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											//     begin o_enb_precharge <= 1 ;  end
											else
											    begin o_enb_precharge <= o_enb_precharge ;  end
											
											if ((o_enb_precharge == 0) && (i_CR_cpl == 1))
											    begin o_enb_slew <= 0 ; end
											else if (o_enb_precharge == 1)
											    begin o_enb_slew <= 1 ; end
											else
											    begin o_enb_slew <= o_enb_slew ; end
										end
										else
										    begin o_enb_slew <= 1 ; /* o_enb_precharge <= 1 ; */ end
										
										if (s_init_CR == 1)
										    begin o_CR_on <= 1 ; o_CR_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CR_on <= 1 ; o_CR_off <= 0 ;
										end
										else
										    begin o_CR_on <= 0 ; o_CR_off <= 1 ; end
	        								
	        							o_CR_target <= s_latch_target_list ;
										o_initI_pull <= i_curI_CR ;
	        						end
	        					else if (CurWorkMode_list[3] == 1'b1)/* i_workmode_CV */
	        					    begin	        						    
										o_workmode_CV_rt <= 1 ; 
										o_enb_slew <= 1 ;
					
										if (s_init_CV == 1)
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										else if (s_von_enb_pull == 1) begin
											// if (i_U_rt >= i_start_Volt)
										        begin o_enb_precharge <= 0 ;  end
											// else if (i_U_rt < i_stop_Volt)
											    // begin o_enb_precharge <= 1 ;  end
											// else
											    // begin o_enb_precharge <= o_enb_precharge ;  end
											
											/* if ((o_enb_precharge == 0) && (i_CV_cpl == 1))
											    begin o_enb_slew <= 0 ; end
											else if (o_enb_precharge == 1)
											    begin o_enb_slew <= 1 ; end
											else
											    begin o_enb_slew <= o_enb_slew ; end */
										end
										else
										    begin /* o_enb_slew <= 1 ;  o_enb_precharge <= 1 ; */end
										
										if (s_init_CV == 1)
										    begin o_CV_on <= 1 ; o_CV_off <= 0 ; end
										else if (s_von_enb_pull == 1) begin
											o_CV_on <= 1 ; o_CV_off <= 0 ;
										end
										else
										    begin o_CV_on <= 0 ; o_CV_off <= 1 ; end
	        								
	        							o_CV_target <= s_latch_target_list ;
										o_initI_pull <= i_curI_CV ;
	        						end
	        					else
	        					    begin
									    o_CC_on  <= 0 ; o_CP_on  <= 0 ; o_CR_on  <= 0 ; o_CV_on  <= 0 ;
	        							o_CC_off <= 1 ; o_CP_off <= 1 ; o_CR_off <= 1 ; o_CV_off <= 1 ;
										o_SR_slew   <= o_SR_slew ; o_SF_slew   <= o_SF_slew ; o_enb_slew <= 1 ; o_enb_precharge <= 1 ; 
			                            o_CC_target <= 'h0 ; o_CP_target <= 'h0 ; o_CR_target <= 'd1000000000 ; o_CV_target <= 'h0 ;
										o_workmode_CC_rt <= 0 ; o_workmode_CP_rt <= 0 ; o_workmode_CR_rt <= 0 ; o_workmode_CV_rt <= 0 ;
										o_initI_pull <= 'h0 ;
	        						end
	                        end
            10'b0000001000 : begin //TOCP
			                    o_SR_slew   <= i_slew_CR_STA ;
								o_SF_slew   <= i_slew_CF_STA ;
                                o_workmode_CC_rt <= 1 ;
                                o_enb_slew  <= 1 ;
								
								if (s_init_TOCP == 1)
								    begin o_enb_precharge <= 1 ; end
								else
								    begin o_enb_precharge <= 0 ; end
								
								if (s_init_TOCP == 1)
								    begin o_CC_on <= 1 ; o_CC_off <= 0 ; end
								// else if (i_U_rt >= i_start_Volt_TOCP)
								    // begin o_CC_on <= 1 ; o_CC_off <= 0 ; end
								else if ((i_U_rt < i_pro_Volt_TOCP)) // 触发ocp立刻停止
									begin o_CC_on <= 0 ; o_CC_off <= 1 ; end
								else
								    begin o_CC_on <= o_CC_on ; o_CC_off <= o_CC_off ; end								
								
								if (s_init_TOCP == 1)
								    o_CC_target <= i_start_Curr_TOCP ;
								else if ((i_U_rt < i_pro_Volt_TOCP))// 触发ocp保留当前值
								    o_CC_target <= o_CC_target ;
								else if ((w_done_steptime_TOCP == 1) && ((o_CC_target + i_step_Curr_TOCP) < i_stop_Curr_TOCP))
								    o_CC_target <= o_CC_target + i_step_Curr_TOCP ;
								else if (w_done_steptime_TOCP == 1)
								    o_CC_target <= i_stop_Curr_TOCP ;
								else
								    o_CC_target <= o_CC_target ;
									
								o_initI_pull <= i_curI_CC ;
	                        end
	        10'b0000010000 : begin //TOPP
			                    o_SR_slew   <= i_slew_CR_STA ;
								o_SF_slew   <= i_slew_CF_STA ;
								o_workmode_CP_rt <= 1 ;
								o_enb_slew  <= 1 ;
								
								if (s_init_TOPP == 1)
								    begin o_enb_precharge <= 1 ; end
								else
								    begin o_enb_precharge <= 0 ; end
									
								if (s_init_TOPP == 1)
								    begin o_CP_on <= 1 ; o_CP_off <= 0 ; end
								// else if (i_U_rt >= i_start_Volt_TOPP)
								    // begin o_CP_on <= 1 ; o_CP_off <= 0 ; end
								else if((i_U_rt < i_pro_Volt_TOPP))// opp立刻停止
									begin o_CP_on <= 0 ; o_CP_off <= 1 ; end
								else
								    begin o_CP_on <= o_CP_on ; o_CP_off <= o_CP_off ; end								
	        													
								if (s_init_TOPP == 1)
								    o_CP_target <= i_start_Power_TOPP ;
								else if ((i_U_rt < i_pro_Volt_TOPP))// opp立刻停止
									o_CP_target <= o_CP_target ;
								else if ((w_done_steptime_TOPP == 1) && ((o_CP_target + i_step_Power_TOPP) < i_stop_Power_TOPP))
								    o_CP_target <= o_CP_target + i_step_Power_TOPP ;
								else if (w_done_steptime_TOPP == 1)
								    o_CP_target <= i_stop_Power_TOPP ;
								else
								    o_CP_target <= o_CP_target ;
									
								o_initI_pull <= i_curI_CP ;
	                        end
	        10'b0000100000,10'b0001000000 : begin //BT
			                    o_SR_slew   <= i_slew_CR_STA ;
								o_SF_slew   <= i_slew_CF_STA ;
								
								if (w_modechange_bat == 1'b1)
								    begin
									    o_CC_on  <= 0 ; o_CP_on  <= 0 ; o_CR_on  <= 0 ; o_CV_on  <= 0 ; o_BAT_on  <= 0 ;
                                        o_CC_off <= 1 ; o_CP_off <= 1 ; o_CR_off <= 1 ; o_CV_off <= 1 ; o_BAT_off <= 1 ;
										o_enb_slew <= 1 ; o_enb_precharge <= o_enb_precharge ;
			                            o_CC_target <= 'h0 ; o_CP_target <= 'h0 ; o_CR_target <= 'd1000000000 ; o_CV_target <= 'h0 ;
										o_workmode_CC_rt <= 0 ; o_workmode_CP_rt <= 0 ; o_workmode_CR_rt <= 0 ; o_workmode_CV_rt <= 0 ;
										o_initI_pull <= o_initI_pull ;
									end
								else 
								if (CurWorkMode_bat[0] == 1'b1)/* i_workmode_CC */
	        					    begin
	        						    o_workmode_CC_rt <= 1 ;
										o_enb_slew <= 1 ;
										
										if (s_init_CC == 1)
								            begin /* o_enb_precharge <= 1 ; */ end
								        else
								            begin o_enb_precharge <= 0 ; end
 
										if (s_init_CC == 1)
										    begin o_CC_on <= 1 ; o_BAT_on  <= 0 ; o_CC_off <= 0 ; o_BAT_off  <= 1 ; end
										else if (i_U_rt < i_proV_BT_Stop) //电压保护截止
	        							    begin o_CC_on <= 0 ; o_BAT_on  <= 0 ; o_CC_off <= 1 ; o_BAT_off  <= 1 ; end
										else if ((CurWorkMode_bat[4] == 1) && (i_U_rt < i_offV_BT_Stop)) //电压截止
										    begin o_CC_on <= 0 ; o_BAT_on  <= 0 ; o_CC_off <= 1 ; o_BAT_off  <= 1 ; end
										else if ((CurWorkMode_bat[5] == 1) && (i_BAT_time >= i_offT_BT_Stop)) //时间截止
										    begin o_CC_on <= 0 ; o_BAT_on  <= 0 ; o_CC_off <= 1 ; o_BAT_off  <= 1 ; end
										else if ((CurWorkMode_bat[6] == 1) && (i_BAT_cap >= i_offC_BT_Stop)) //容量截止
										    begin o_CC_on <= 0 ; o_BAT_on  <= 0 ; o_CC_off <= 1 ; o_BAT_off  <= 1 ; end
										else
										    begin o_CC_on <= 1 ; o_BAT_on  <= 1 ; o_CC_off <= 0 ; o_BAT_off  <= 0 ;end
										
										o_CC_target <= i_Iset_STA ;
										o_initI_pull <= i_curI_CC ;
	        						end
	        					else if (CurWorkMode_bat[1] == 1'b1)/* i_workmode_CP */
	        					    begin
										o_workmode_CP_rt <= 1 ;
										o_enb_slew <= 1 ;
										
										if (s_init_CP == 1)
								            begin /* o_enb_precharge <= 1 ; */ end
								        else
								            begin o_enb_precharge <= 0 ; end
										
										if (s_init_CP == 1)
										    begin o_CP_on <= 1 ; o_BAT_on  <= 0 ; o_CP_off <= 0 ; o_BAT_off  <= 1 ; end
										else if (i_U_rt < i_proV_BT_Stop) //电压保护截止
	        							    begin o_CP_on <= 0 ; o_BAT_on  <= 0 ; o_CP_off <= 1 ; o_BAT_off  <= 1 ; end
										else if ((CurWorkMode_bat[4] == 1) && (i_U_rt < i_offV_BT_Stop)) //电压截止
										    begin o_CP_on <= 0 ; o_BAT_on  <= 0 ; o_CP_off <= 1 ; o_BAT_off  <= 1 ; end
										else if ((CurWorkMode_bat[5] == 1) && (i_BAT_time >= i_offT_BT_Stop)) //时间截止
										    begin o_CP_on <= 0 ; o_BAT_on  <= 0 ; o_CP_off <= 1 ; o_BAT_off  <= 1 ; end
										else if ((CurWorkMode_bat[6] == 1) && (i_BAT_cap >= i_offC_BT_Stop)) //容量截止
										    begin o_CP_on <= 0 ; o_BAT_on  <= 0 ; o_CP_off <= 1 ; o_BAT_off  <= 1 ; end
										else
										    begin o_CP_on <= 1 ; o_BAT_on  <= 1 ; o_CP_off <= 0 ; o_BAT_off  <= 0 ; end
																					        								
	        							o_CP_target <= i_Pset_STA ;
										o_initI_pull <= i_curI_CP ;
	        						end
	        					else if (CurWorkMode_bat[2] == 1'b1)/* i_workmode_CR */
	        					    begin	        						    
										o_workmode_CR_rt <= 1 ;
										o_enb_slew <= 1 ;
										
										if (s_init_CR == 1)
								            begin /* o_enb_precharge <= 1 ; */ end
								        else
								            begin o_enb_precharge <= 0 ; end					
										
										if (s_init_CR == 1)
										    begin o_CR_on <= 1 ; o_BAT_on  <= 0 ; o_CR_off <= 0 ; o_BAT_off  <= 1 ; end
										else if (i_U_rt < i_proV_BT_Stop) //电压保护截止
	        							    begin o_CR_on <= 0 ; o_BAT_on  <= 0 ; o_CR_off <= 1 ; o_BAT_off  <= 1 ; end
										else if ((CurWorkMode_bat[4] == 1) && (i_U_rt < i_offV_BT_Stop)) //电压截止
										    begin o_CR_on <= 0 ; o_BAT_on  <= 0 ; o_CR_off <= 1 ; o_BAT_off  <= 1 ; end
										else if ((CurWorkMode_bat[5] == 1) && (i_BAT_time >= i_offT_BT_Stop)) //时间截止
										    begin o_CR_on <= 0 ; o_BAT_on  <= 0 ; o_CR_off <= 1 ; o_BAT_off  <= 1 ; end
										else if ((CurWorkMode_bat[6] == 1) && (i_BAT_cap >= i_offC_BT_Stop)) //容量截止
										    begin o_CR_on <= 0 ; o_BAT_on  <= 0 ; o_CR_off <= 1 ; o_BAT_off  <= 1 ; end
										else
										    begin o_CR_on <= 1 ; o_BAT_on  <= 1 ; o_CR_off <= 0 ; o_BAT_off  <= 0 ; end
										
	        							o_CR_target <= i_Rset_STA ;
										o_initI_pull <= i_curI_CR ;
	        						end
	        					else
	        					    begin
									    o_CC_on  <= 0 ; o_CP_on  <= 0 ; o_CR_on  <= 0 ; o_CV_on  <= 0 ; o_BAT_on  <= 0 ;
	        							o_CC_off <= 1 ; o_CP_off <= 1 ; o_CR_off <= 1 ; o_CV_off <= 1 ; o_BAT_off <= 1 ;
										o_SR_slew   <= o_SR_slew ; o_SF_slew   <= o_SF_slew ; o_enb_slew <= 1 ; o_enb_precharge <= 1 ;
			                            o_CC_target <= 'h0 ; o_CP_target <= 'h0 ; o_CR_target <= 'd1000000000 ; o_CV_target <= 'h0 ;
										o_workmode_CC_rt <= 0 ; o_workmode_CP_rt <= 0 ; o_workmode_CR_rt <= 0 ; o_workmode_CV_rt <= 0 ;
										o_initI_pull <= 'h0 ;
	        						end
	                        end
	        default : begin
			        end
	        endcase
	    end	
end

//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
assign  w_done_cntt1us = s_cnt_t1us >= s_T1set_DYN ? 1'B1 : 1'B0 ;
assign  w_done_cntt2us = s_cnt_t2us >= s_T2set_DYN ? 1'B1 : 1'B0 ;
assign  w_done_ns_DYN = s_cnt_ns_DYN >= _1US_CKNUM-1 ? 1'B1 : 1'B0 ;
assign  w_done_us_DYN = s_cnt_us_DYN >= 1000-1 ? 1'B1 : 1'B0 ;

assign  w_done_precharge = s_cntmsprecharge >= _PRECHARGE_T ? 1'b1 : 1'b0 ;
//----------------------------------------------------------------------------
//将保护时长设置数转为时钟数
// s_cknum_prot = i_T_pro * 10000 
//----------------------------------------------------------------------------
always @ (posedge i_clk)
begin
    if (i_T_pro < 'd2)
	    s_cknum_prot <= 'd0 ;
	else 
	    s_cknum_prot <= {i_T_pro,13'b0} + {i_T_pro,10'b0} + {i_T_pro,9'b0} + {i_T_pro,8'b0} + {i_T_pro,4'b0}  ;
end


always @ (posedge i_clk)
begin
    if ((s_pullout_enb == 1'b0) || (w_funcchange == 1'b1))
	    begin
			s_cnt_ns_DYN  <= 'h0 ;//DYN
			s_cnt_us_DYN  <= 'h0 ;//DYN
			s_cnt_t1us    <= 'h0 ;//DYN
			s_cnt_t2us    <= 'h0 ;//DYN
			s_T1_stage    <= 1   ;//DYN
			s_init_CC <= 1 ; s_init_CP <= 1 ; s_init_CR <= 1 ; s_init_CV <= 1 ;
			s_init_TOCP   <= 1 ; s_init_TOPP   <= 1 ;//
			s_von_enb_pull <= 0 ; s_cntmsprecharge <= 'h0 ;
	    end	
	else
	    begin
			case ( Curfunc )
	        10'b0000000001 : begin //STA
								if (w_modechange == 1'b1)
								    begin
										s_init_CC <= 1 ; s_init_CP <= 1 ; s_init_CR <= 1 ; s_init_CV <= 1 ;
										s_von_enb_pull <= 0 ; s_cntmsprecharge <= 'h0 ;
									end
								else if ((CurWorkMode[0] == 1'b1) || ((CurWorkMode[3] == 1'b1) && (i_worktype_Single == 1'b0) && (i_ms_Master == 1'b0)))/* i_workmode_CC */
	        					    begin
	        						    if ((s_init_CC == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CC <= 0 ;
										else
										    s_init_CC <= s_init_CC ;
										
										// if ((w_done_cntns == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))//用于仿真
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										// if ((s_init_CC == 1) && (w_done_precharge == 1'b1))//用于仿真
										if (i_Von_Latch_ON) begin
											if ((s_init_CC == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CC == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end
										// if ((s_init_CC == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;
	        						end
	        					else if (CurWorkMode[1] == 1'b1)/* i_workmode_CP */
	        					    begin
	        						    if ((s_init_CP == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CP <= 0 ;
										else
										    s_init_CP <= s_init_CP ;
											
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										if (i_Von_Latch_ON) begin
											if ((s_init_CP == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CP == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end
										// if ((s_init_CP == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;
	        						end
	        					else if (CurWorkMode[2] == 1'b1)/* i_workmode_CR */
	        					    begin
	        						    if ((s_init_CR == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CR <= 0 ;
										else
										    s_init_CR <= s_init_CR ;
										
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										if (i_Von_Latch_ON) begin
											if ((s_init_CR == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CR == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end
										// if ((s_init_CR == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;
	        						end
	        					else if (CurWorkMode[3] == 1'b1)/* i_workmode_CV */
	        					    begin
	        						    if ((s_init_CV == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CV <= 0 ;
										else
										    s_init_CV <= s_init_CV ;
										
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										if (i_Von_Latch_ON) begin
											if ((s_init_CV == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CV == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end		
										// if ((s_init_CV == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;
	        						end
	        					else
	        					    begin
										s_init_CC <= 1 ; s_init_CP <= 1 ; s_init_CR <= 1 ; s_init_CV <= 1 ;
										s_von_enb_pull <= 0 ; s_cntmsprecharge <= 'h0 ;
	        						end
	                        end
	        10'b0000000010 : begin //DYN
	                            if (w_modechange == 1'b1)
								    begin
									    s_cnt_ns_DYN  <= 'h0 ; s_cnt_us_DYN  <= 'h0 ; s_cnt_t1us <= 'h0 ; s_cnt_t2us <= 'h0 ;s_T1_stage <= 1 ;
										s_init_CC <= 1 ; s_init_CP <= 1 ; s_init_CR <= 1 ; s_init_CV <= 1 ;
										s_von_enb_pull <= 0 ; s_cntmsprecharge <= 'h0 ;
									end
								else if ((CurWorkMode[0] == 1'b1) || ((CurWorkMode[3] == 1'b1) && (i_worktype_Single == 1'b0) && (i_ms_Master == 1'b0)))/* i_workmode_CC */
	        					    begin
	        						    s_T1set_DYN  <= i_T1set_CC_DYN ;
										s_T2set_DYN  <= i_T2set_CC_DYN ;
										
										if ((s_init_CC == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CC <= 0 ;
										else
										    s_init_CC <= s_init_CC ;
										
										// if ((w_done_cntns == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))// 用于仿真
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										// if ((s_init_CC == 1) && (w_done_precharge == 1'b1))//用于仿真
										if (i_Von_Latch_ON) begin
											if ((s_init_CC == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CC == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end	
										// if ((s_init_CC == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;
											
										if (CurWorkMode[6] == 1'b1) //脉冲触发/* i_trigmode_DYN_P */
										    begin
											    if (s_init_CC == 1)
												    s_T1_stage <= 1 ;
												else if ((s_T1_stage == 1) && (i_triggen_DYN == 1'b1)) //触发一次
												    s_T1_stage <= 0 ;
												else if ((s_T1_stage == 0) && (w_done_cntt2us == 1'b1))
												    s_T1_stage <= 1 ;
												else 
												    s_T1_stage <= s_T1_stage ;
															
												s_cnt_t1us <= s_cnt_t1us ;	
												if (s_init_CC == 1)
												    begin s_cnt_t2us <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin s_cnt_t2us <= 'h0 ; end
												else
												    begin
													    if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))
												            s_cnt_t2us <= s_cnt_t2us + 'h1 ;
														else
														    s_cnt_t2us <= s_cnt_t2us ;
													end
												
												if (s_init_CC == 1)
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else
												    begin
													    if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ;				
													end
											end
										else if (CurWorkMode[7] == 1'b1) //翻转触发/* i_trigmode_DYN_T */
										    begin
											    if (s_init_CC == 1)
												    s_T1_stage <= 1 ;
												else if ((i_triggen_DYN == 1'b1) && (s_T1_stage == 1)) //触发一次
												    s_T1_stage <= 0 ;
												else if ((i_triggen_DYN == 1'b1) && (s_T1_stage == 0)) //触发一次
												    s_T1_stage <= 1 ;
												else 
												    s_T1_stage <= s_T1_stage ;
													
												s_cnt_t1us <= s_cnt_t1us ;	
												s_cnt_t2us <= s_cnt_t2us ;
                                                s_cnt_ns_DYN <= 'h0 ;
                                                s_cnt_us_DYN <= 'h0 ;
											end
										else //连续触发
										    begin
											    if (s_init_CC == 1)
												    s_T1_stage <= 1 ;
												else if ((w_done_cntt1us == 1'b1) && (s_T1_stage == 1)) //
												    s_T1_stage <= 0 ;
												else if ((w_done_cntt2us == 1'b1) && (s_T1_stage == 0)) //
												    s_T1_stage <= 1 ;
												else
												    s_T1_stage <= s_T1_stage ;
													
												if (s_init_CC == 1)
												    begin 
													    s_cnt_t1us <= 'h0 ; 
														s_cnt_t2us <= 'h0 ; 
													end
												else if (s_T1_stage == 1)  //
												    begin 
													    if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))//单位改成us
												            s_cnt_t1us <= s_cnt_t1us + 'h1 ;
														else
														    s_cnt_t1us <= s_cnt_t1us ;
														
														s_cnt_t2us <= 'h0 ;
													end
												else
												    begin
													    s_cnt_t1us <= 'h0 ;
														
														if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))//单位改成us
												            s_cnt_t2us <= s_cnt_t2us + 'h1 ;
														else
														    s_cnt_t2us <= s_cnt_t2us ;
													end
												
												if (s_init_CC == 1)
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin 
													    if (w_done_cntt1us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if (w_done_cntt1us == 1'b1)
														    s_cnt_us_DYN <= 'h0 ; 
														else if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ; 
													end
												else
												    begin
													    if (w_done_cntt2us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if (w_done_cntt2us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ;				
													end
											end	
	        						end
	        					else if (CurWorkMode[1] == 1'b1)/* i_workmode_CP */
	        					    begin
	        						    s_T1set_DYN  <= i_T1set_CP_DYN ;
										s_T2set_DYN  <= i_T2set_CP_DYN ;
																				
										if ((s_init_CP == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CP <= 0 ;
										else
										    s_init_CP <= s_init_CP ;
										
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										if (i_Von_Latch_ON) begin
											if ((s_init_CP == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CP == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end	
										// if ((s_init_CP == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;
											
										if (CurWorkMode[6] == 1'b1) //脉冲触发/* i_trigmode_DYN_P */
										    begin
											    if (s_init_CP == 1)
												    s_T1_stage <= 1 ;
												else if ((s_T1_stage == 1) && (i_triggen_DYN == 1'b1)) //触发一次
												    s_T1_stage <= 0 ;
												else if ((s_T1_stage == 0) && (w_done_cntt2us == 1'b1))
												    s_T1_stage <= 1 ;
												else 
												    s_T1_stage <= s_T1_stage ;
															
												s_cnt_t1us <= s_cnt_t1us ;	
												if (s_init_CP == 1)
												    begin s_cnt_t2us <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin s_cnt_t2us <= 'h0 ; end
												else
												    begin
													    if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))
												            s_cnt_t2us <= s_cnt_t2us + 'h1 ;
														else
														    s_cnt_t2us <= s_cnt_t2us ;
													end
												
												if (s_init_CP == 1)
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else
												    begin
													    if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ;				
													end
											end
										else if (CurWorkMode[7] == 1'b1) //翻转触发/* i_trigmode_DYN_T */
										    begin
											    if (s_init_CP == 1)
												    s_T1_stage <= 1 ;
												else if ((i_triggen_DYN == 1'b1) && (s_T1_stage == 1)) //触发一次
												    s_T1_stage <= 0 ;
												else if ((i_triggen_DYN == 1'b1) && (s_T1_stage == 0)) //触发一次
												    s_T1_stage <= 1 ;
												else 
												    s_T1_stage <= s_T1_stage ;
													
												s_cnt_t1us <= s_cnt_t1us ;	
												s_cnt_t2us <= s_cnt_t2us ;
                                                s_cnt_ns_DYN <= 'h0 ;
                                                s_cnt_us_DYN <= 'h0 ;
											end
										else //连续触发
										    begin
											    if (s_init_CP == 1)
												    s_T1_stage <= 1 ;
												else if ((w_done_cntt1us == 1'b1) && (s_T1_stage == 1)) //
												    s_T1_stage <= 0 ;
												else if ((w_done_cntt2us == 1'b1) && (s_T1_stage == 0)) //
												    s_T1_stage <= 1 ;
												else
												    s_T1_stage <= s_T1_stage ;
													
												if (s_init_CP == 1)
												    begin 
													    s_cnt_t1us <= 'h0 ; 
														s_cnt_t2us <= 'h0 ; 
													end
												else if (s_T1_stage == 1)  //
												    begin 
													    if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))
												            s_cnt_t1us <= s_cnt_t1us + 'h1 ;
														else
														    s_cnt_t1us <= s_cnt_t1us ;
														
														s_cnt_t2us <= 'h0 ;
													end
												else
												    begin
													    s_cnt_t1us <= 'h0 ;
														
														if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))
												            s_cnt_t2us <= s_cnt_t2us + 'h1 ;
														else
														    s_cnt_t2us <= s_cnt_t2us ;
													end
												
												if (s_init_CP == 1)
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin 
													    if (w_done_cntt1us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if (w_done_cntt1us == 1'b1)
														    s_cnt_us_DYN <= 'h0 ; 
														else if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ; 
													end
												else
												    begin
													    if (w_done_cntt2us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if (w_done_cntt2us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ;				
													end
											end
	        						end
	        					else if (CurWorkMode[2] == 1'b1)/* i_workmode_CR */
	        					    begin
	        						    s_T1set_DYN  <= i_T1set_CR_DYN ;
										s_T2set_DYN  <= i_T2set_CR_DYN ;
																				
										if ((s_init_CR == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CR <= 0 ;
										else
										    s_init_CR <= s_init_CR ;
										
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										if (i_Von_Latch_ON) begin
											if ((s_init_CR == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CR == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end	
										// if ((s_init_CR == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;
																				
										if (CurWorkMode[6] == 1'b1) //脉冲触发/* i_trigmode_DYN_P */
										    begin
											    if (s_init_CR == 1)
												    s_T1_stage <= 1 ;
												else if ((s_T1_stage == 1) && (i_triggen_DYN == 1'b1)) //触发一次
												    s_T1_stage <= 0 ;
												else if ((s_T1_stage == 0) && (w_done_cntt2us == 1'b1))
												    s_T1_stage <= 1 ;
												else 
												    s_T1_stage <= s_T1_stage ;
															
												s_cnt_t1us <= s_cnt_t1us ;	
												if (s_init_CR == 1)
												    begin s_cnt_t2us <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin s_cnt_t2us <= 'h0 ; end
												else
												    begin
													    if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))
												            s_cnt_t2us <= s_cnt_t2us + 'h1 ;
														else
														    s_cnt_t2us <= s_cnt_t2us ;
													end
												
												if (s_init_CR == 1)
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else
												    begin
													    if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ;				
													end
											end
										else if (CurWorkMode[7] == 1'b1) //翻转触发/* i_trigmode_DYN_T */
										    begin
											    if (s_init_CR == 1)
												    s_T1_stage <= 1 ;
												else if ((i_triggen_DYN == 1'b1) && (s_T1_stage == 1)) //触发一次
												    s_T1_stage <= 0 ;
												else if ((i_triggen_DYN == 1'b1) && (s_T1_stage == 0)) //触发一次
												    s_T1_stage <= 1 ;
												else 
												    s_T1_stage <= s_T1_stage ;
													
												s_cnt_t1us <= s_cnt_t1us ;	
												s_cnt_t2us <= s_cnt_t2us ;
                                                s_cnt_ns_DYN <= 'h0 ;
                                                s_cnt_us_DYN <= 'h0 ;
											end
										else //连续触发
										    begin
											    if (s_init_CR == 1)
												    s_T1_stage <= 1 ;
												else if ((w_done_cntt1us == 1'b1) && (s_T1_stage == 1)) //
												    s_T1_stage <= 0 ;
												else if ((w_done_cntt2us == 1'b1) && (s_T1_stage == 0)) //
												    s_T1_stage <= 1 ;
												else
												    s_T1_stage <= s_T1_stage ;
													
												if (s_init_CR == 1)
												    begin 
													    s_cnt_t1us <= 'h0 ; 
														s_cnt_t2us <= 'h0 ; 
													end
												else if (s_T1_stage == 1)  //
												    begin 
													    if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))
												            s_cnt_t1us <= s_cnt_t1us + 'h1 ;
														else
														    s_cnt_t1us <= s_cnt_t1us ;
														
														s_cnt_t2us <= 'h0 ;
													end
												else
												    begin
													    s_cnt_t1us <= 'h0 ;
														
														if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))
												            s_cnt_t2us <= s_cnt_t2us + 'h1 ;
														else
														    s_cnt_t2us <= s_cnt_t2us ;
													end
												
												if (s_init_CR == 1)
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin 
													    if (w_done_cntt1us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if (w_done_cntt1us == 1'b1)
														    s_cnt_us_DYN <= 'h0 ; 
														else if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ; 
													end
												else
												    begin
													    if (w_done_cntt2us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if (w_done_cntt2us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ;				
													end
											end	
	        						end
	        					else if (CurWorkMode[3] == 1'b1)/* i_workmode_CV */
	        					    begin
	        						    s_T1set_DYN  <= i_T1set_CV_DYN ;
										s_T2set_DYN  <= i_T2set_CV_DYN ;
																				
										if ((s_init_CV == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CV <= 0 ;
										else
										    s_init_CV <= s_init_CV ;
										
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										if (i_Von_Latch_ON) begin
											if ((s_init_CV == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CV == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end	
										// if ((s_init_CV == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;

	        							if (CurWorkMode[6] == 1'b1) //脉冲触发/* i_trigmode_DYN_P */
										    begin
											    if (s_init_CV == 1)
												    s_T1_stage <= 1 ;
												else if ((s_T1_stage == 1) && (i_triggen_DYN == 1'b1)) //触发一次
												    s_T1_stage <= 0 ;
												else if ((s_T1_stage == 0) && (w_done_cntt2us == 1'b1))
												    s_T1_stage <= 1 ;
												else 
												    s_T1_stage <= s_T1_stage ;
															
												s_cnt_t1us <= s_cnt_t1us ;	
												if (s_init_CV == 1)
												    begin s_cnt_t2us <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin s_cnt_t2us <= 'h0 ; end
												else
												    begin
													    if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))
												            s_cnt_t2us <= s_cnt_t2us + 'h1 ;
														else
														    s_cnt_t2us <= s_cnt_t2us ;
													end
												
												if (s_init_CV == 1)
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else
												    begin
													    if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ;				
													end
											end
										else if (CurWorkMode[7] == 1'b1) //翻转触发/* i_trigmode_DYN_T */
										    begin
											    if (s_init_CV == 1)
												    s_T1_stage <= 1 ;
												else if ((i_triggen_DYN == 1'b1) && (s_T1_stage == 1)) //触发一次
												    s_T1_stage <= 0 ;
												else if ((i_triggen_DYN == 1'b1) && (s_T1_stage == 0)) //触发一次
												    s_T1_stage <= 1 ;
												else 
												    s_T1_stage <= s_T1_stage ;
													
												s_cnt_t1us <= s_cnt_t1us ;	
												s_cnt_t2us <= s_cnt_t2us ;
                                                s_cnt_ns_DYN <= 'h0 ;
                                                s_cnt_us_DYN <= 'h0 ;
											end
										else //连续触发
										    begin
											    if (s_init_CV == 1)
												    s_T1_stage <= 1 ;
												else if ((w_done_cntt1us == 1'b1) && (s_T1_stage == 1)) //
												    s_T1_stage <= 0 ;
												else if ((w_done_cntt2us == 1'b1) && (s_T1_stage == 0)) //
												    s_T1_stage <= 1 ;
												else
												    s_T1_stage <= s_T1_stage ;
													
												if (s_init_CV == 1)
												    begin 
													    s_cnt_t1us <= 'h0 ; 
														s_cnt_t2us <= 'h0 ; 
													end
												else if (s_T1_stage == 1)  //
												    begin 
													    if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))
												            s_cnt_t1us <= s_cnt_t1us + 'h1 ;
														else
														    s_cnt_t1us <= s_cnt_t1us ;
														
														s_cnt_t2us <= 'h0 ;
													end
												else
												    begin
													    s_cnt_t1us <= 'h0 ;
														
														if ((w_done_cntt2us == 0) && (w_done_ns_DYN == 1'b1))
												            s_cnt_t2us <= s_cnt_t2us + 'h1 ;
														else
														    s_cnt_t2us <= s_cnt_t2us ;
													end
												
												if (s_init_CV == 1)
												    begin s_cnt_ns_DYN <= 'h0 ; s_cnt_us_DYN <= 'h0 ; end
												else if (s_T1_stage == 1)  //
												    begin 
													    if (w_done_cntt1us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if (w_done_cntt1us == 1'b1)
														    s_cnt_us_DYN <= 'h0 ; 
														else if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ; 
													end
												else
												    begin
													    if (w_done_cntt2us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if (w_done_ns_DYN == 1'b1)
													        s_cnt_ns_DYN <= 'h0 ; 	
														else
														    s_cnt_ns_DYN <= s_cnt_ns_DYN + 'h1 ; 

                                                        if (w_done_cntt2us == 1'b1)
														    s_cnt_ns_DYN <= 'h0 ; 
														else if ((w_done_us_DYN == 1'b1) && (w_done_ns_DYN == 1'b1))
												            s_cnt_us_DYN <= 'h0 ; 	
												        else if (w_done_ns_DYN == 1'b1)
												            s_cnt_us_DYN <= s_cnt_us_DYN + 'h1 ;
 												        else
                                               	        	s_cnt_us_DYN <= s_cnt_us_DYN ;				
													end
											end
	        						end
	        					else
	        					    begin
                                        s_cnt_ns_DYN  <= 'h0 ; s_cnt_us_DYN  <= 'h0 ; s_cnt_t1us <= 'h0 ; s_cnt_t2us <= 'h0 ; s_T1_stage <= 1 ;
										s_init_CC <= 1 ; s_init_CP <= 1 ; s_init_CR <= 1 ; s_init_CV <= 1 ;
										s_von_enb_pull <= 0 ; s_cntmsprecharge <= 'h0 ;
	        						end
	                        end
	        10'b0000000100 : begin //LIST
                                if ((w_modechange_list == 1'b1) || (o_cpl_list == 1))
								    begin
										s_init_CC <= 1 ; s_init_CP <= 1 ; s_init_CR <= 1 ; s_init_CV <= 1 ;
										s_von_enb_pull <= 0 ; s_cntmsprecharge <= 'h0 ;
									end
								else if ((CurWorkMode_list[0] == 1'b1) || ((CurWorkMode_list[3] == 1'b1) && (i_worktype_Single == 1'b0) && (i_ms_Master == 1'b0)))/* i_workmode_CC */
	        					    begin
										if ((s_init_CC == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CC <= 0 ;
										else
										    s_init_CC <= s_init_CC ;
										
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										if (i_Von_Latch_ON) begin
											if ((s_init_CC == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CC == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end	
										// if ((s_init_CC == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;										
	        						end
	        					else if (CurWorkMode_list[1] == 1'b1)/* i_workmode_CP */
	        					    begin	        						    
										if ((s_init_CP == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CP <= 0 ;
										else
										    s_init_CP <= s_init_CP ;
										
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										if (i_Von_Latch_ON) begin
											if ((s_init_CP == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CP == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end	
										// if ((s_init_CP == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;										
	        						end
	        					else if (CurWorkMode_list[2] == 1'b1)/* i_workmode_CR */
	        					    begin	        						    
										if ((s_init_CR == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CR <= 0 ;
										else
										    s_init_CR <= s_init_CR ;
										
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										if (i_Von_Latch_ON) begin
											if ((s_init_CR == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CR == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end	
										// if ((s_init_CR == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;										
	        						end
	        					else if (CurWorkMode_list[3] == 1'b1)/* i_workmode_CV */
	        					    begin	        						    
										if ((s_init_CV == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										    s_init_CV <= 0 ;
										else
										    s_init_CV <= s_init_CV ;
										
										if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
										    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
										else
										    s_cntmsprecharge <= s_cntmsprecharge ;
										
										if (i_Von_Latch_ON) begin
											if ((s_init_CV == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1)) begin
												s_von_enb_pull <= 1 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else if (i_Von_Latch_OFF) begin
											if ((s_init_CV == 1)) begin
												if ((i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1) && (s_von_enb_pull == 0)) begin
													s_von_enb_pull <= 1 ;
												end
												else begin
													s_von_enb_pull <= 0 ;
												end
											end
											else if ((i_U_rt >= i_start_Volt) && (s_von_enb_pull == 0)) begin
												s_von_enb_pull <= 1 ;
											end
											else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1)) begin
												s_von_enb_pull <= 0 ;
											end
											else begin
												s_von_enb_pull <= s_von_enb_pull ;
											end
										end
										else begin
											s_von_enb_pull <= s_von_enb_pull ;
										end	
                                        // if ((s_init_CV == 1) && (i_U_rt >= i_start_Volt) && (w_done_precharge == 1'b1))
										//     s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										//     s_von_enb_pull <= 0 ;
										// else
										//     s_von_enb_pull <= s_von_enb_pull ;
	        						end
	        					else
	        					    begin
										s_init_CC <= 1 ; s_init_CP <= 1 ; s_init_CR <= 1 ; s_init_CV <= 1 ;
										s_von_enb_pull <= 0 ; s_cntmsprecharge <= 'h0 ;
	        						end
	                        end
            10'b0000001000 : begin //TOCP
			                    if ((s_init_TOCP == 1) && (i_U_rt >= i_start_Volt_TOCP) && (w_done_precharge == 1'b1))
								    s_init_TOCP <= 0 ;
								else
								    s_init_TOCP <= s_init_TOCP ;
																
								if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
								    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
								else
								    s_cntmsprecharge <= s_cntmsprecharge ;
								
								if ((s_init_TOCP == 1) && (i_U_rt >= i_start_Volt_TOCP) && (w_done_precharge == 1'b1))
								    s_von_enb_pull <= 1 ;
								// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
								    // s_von_enb_pull <= 0 ;
								else
								    s_von_enb_pull <= s_von_enb_pull ;
	                        end
	        10'b0000010000 : begin //TOPP
			                    if ((s_init_TOPP == 1) && (i_U_rt >= i_start_Volt_TOPP) && (w_done_precharge == 1'b1))
								    s_init_TOPP <= 0 ;
								else
								    s_init_TOPP <= s_init_TOPP ;
								
								if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
								    s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
								else
								    s_cntmsprecharge <= s_cntmsprecharge ;
									
								if ((s_init_TOPP == 1) && (i_U_rt >= i_start_Volt_TOPP) && (w_done_precharge == 1'b1))
								    s_von_enb_pull <= 1 ;
								// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
								    // s_von_enb_pull <= 0 ;
								else
								    s_von_enb_pull <= s_von_enb_pull ;
	                        end
	        10'b0000100000,10'b0001000000 : begin //BT
			                    if (w_modechange_bat == 1'b1)
								    begin
										s_init_CC <= 1 ; s_init_CP <= 1 ; s_init_CR <= 1 ; s_init_CV <= 1 ;
										s_von_enb_pull <= 0 ; s_cntmsprecharge <= 'h0 ;
									end
								else if (CurWorkMode_bat[0] == 1'b1)/* i_workmode_CC */
	        					    begin
										// if ((s_init_CC == 1) && (i_U_rt >= i_proV_BT_Stop) && (i_U_rt >= i_offV_BT_Stop) && (w_done_precharge == 1'b1))
										if ((s_init_CC == 1) && (i_U_rt >= i_proV_BT_Stop) && (w_done_precharge == 1'b1))
										    s_init_CC <= 0 ;
										else
										    s_init_CC <= s_init_CC ;
										
								        if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))//  仿真改为cntus
								            s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
								        else
								            s_cntmsprecharge <= s_cntmsprecharge ;
									
										if ((s_init_CC == 1) && (i_U_rt >= i_proV_BT_Stop) && (w_done_precharge == 1'b1))
										    s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										    // s_von_enb_pull <= 0 ;
										else
										    s_von_enb_pull <= s_von_enb_pull ;
									end
	        					else if (CurWorkMode_bat[1] == 1'b1)/* i_workmode_CP */
	        					    begin
										// if ((s_init_CP == 1) && (i_U_rt >= i_proV_BT_Stop) && (i_U_rt >= i_offV_BT_Stop) && (w_done_precharge == 1'b1))
										if ((s_init_CP == 1) && (i_U_rt >= i_proV_BT_Stop) && (w_done_precharge == 1'b1))
										    s_init_CP <= 0 ;
										else
										    s_init_CP <= s_init_CP ;
										
								        if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
								            s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
								        else
								            s_cntmsprecharge <= s_cntmsprecharge ;
									
										if ((s_init_CP == 1) && (i_U_rt >= i_proV_BT_Stop) && (w_done_precharge == 1'b1))
										    s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										    // s_von_enb_pull <= 0 ;
										else
										    s_von_enb_pull <= s_von_enb_pull ;
	        						end
	        					else if (CurWorkMode_bat[2] == 1'b1)/* i_workmode_CR */
	        					    begin
										// if ((s_init_CR == 1) && (i_U_rt >= i_proV_BT_Stop) && (i_U_rt >= i_offV_BT_Stop) && (w_done_precharge == 1'b1))
										if ((s_init_CR == 1) && (i_U_rt >= i_proV_BT_Stop) && (w_done_precharge == 1'b1))
										    s_init_CR <= 0 ;
										else
										    s_init_CR <= s_init_CR ;
										
								        if ((w_done_cntns == 1'b1) && (w_done_cntus == 1'b1) && (s_cntmsprecharge < _PRECHARGE_T))
								            s_cntmsprecharge <= s_cntmsprecharge + 'h1 ;
								        else
								            s_cntmsprecharge <= s_cntmsprecharge ;
									
										if ((s_init_CR == 1) && (i_U_rt >= i_proV_BT_Stop) && (w_done_precharge == 1'b1))
										    s_von_enb_pull <= 1 ;
										// else if ((i_U_rt < i_stop_Volt) && (s_von_enb_pull == 1) && (i_Von_Latch_ON == 1'b1))
										    // s_von_enb_pull <= 0 ;
										else
										    s_von_enb_pull <= s_von_enb_pull ;
	        						end
	        					else
	        					    begin
										s_init_CC <= 1 ; s_init_CP <= 1 ; s_init_CR <= 1 ; s_init_CV <= 1 ;
										s_von_enb_pull <= 0 ; s_cntmsprecharge <= 'h0 ;
	        						end
	                        end
	        default : begin			            
			        end
	        endcase
	    end
end

//----------------------------------------------------------------------
//  List
//----------------------------------------------------------------------
assign  w_done_total_loop_list = (s_latch_total_loopnum_list == 'h0) ? 1'b0 :
                                 (s_cnt_total_loop_list >= s_latch_total_loopnum_list) ? 1'b1 : 1'b0 ;
assign  w_done_runus_list  = s_cnt_runtime_list  >= w_latch_runtime_list ? 1'b1 : 1'b0 ;
assign  w_done_repeat_list = s_cnt_repeat_list >= s_latch_repeat_list  ? 1'b1 : 1'b0 ;
assign  w_done_loop_list   = s_cnt_loop_list   >= s_latch_loop_list    ? 1'b1 : 1'b0 ;
assign  o_cnt_repeat_list = s_cnt_repeat_list;
assign  o_cnt_total_loop_list = s_cnt_total_loop_list;
assign  o_cnt_loop_list = s_cnt_loop_list;

//runtime * 100
//将运行时间转为时钟数
assign  w_latch_runtime_list = {s_latch_runtime_list,6'b0} + {s_latch_runtime_list,5'b0} + {s_latch_runtime_list,2'b0} ;

always @ (posedge i_clk)
begin    
	s_rdbuff_enb_1dly <= s_rdbuff_enb ;//buff读数据对齐
	
	if ((s_pullout_enb == 1'b0) || (w_funcchange == 1'b1))
	    begin
		    o_curstepnum_list     <= 'h1  ;//buff地址从1开始
			s_rdbuff_enb          <= 1'b1 ;//buff读使能
            s_cnt_total_loop_list <= 'd1  ;//计数从1开始
            s_cnt_runtime_list    <= 'd1  ;//计数从1开始
            s_cnt_repeat_list     <= 'd1  ;//计数从1开始
            s_cnt_loop_list       <= 'd1  ;//计数从1开始
			o_cpl_list            <= 0    ;
	    end	
	else
	    begin
			case ( Curfunc )
	        // 10'b0000000001 : begin//STA								
	                        // end
	        // 10'b0000000010 : begin//DYN	                  
	                        // end
	        10'b0000000100 : begin //LIST			
			                    if (s_rdbuff_enb_1dly == 1'b1)
								    begin
									    s_latch_total_stepnum_list <= i_total_stepnum_list > 'h0 ? i_total_stepnum_list : 'h1 ;
										s_latch_total_loopnum_list <= i_total_loopnum_list ;
										s_latch_workmode_CC_list   <= i_workmode_CC_list   ;
										s_latch_workmode_CP_list   <= i_workmode_CP_list   ;
										s_latch_workmode_CR_list   <= i_workmode_CR_list   ;
										s_latch_workmode_CV_list   <= i_workmode_CV_list   ;
										s_latch_target_list        <= i_target_list        ;
										s_latch_runtime_list       <= i_runtime_list > 'h0 ? i_runtime_list : 'h1 ;
										s_latch_repeat_list        <= i_repeat_list  > 'h0 ? i_repeat_list  : 'h1 ;
										s_latch_goto_list          <= i_goto_list    > 'h0 ? i_goto_list    : 'h1 ;
										s_latch_loop_list          <= i_loop_list    > 'h0 ? i_loop_list    : 'h1 ;
									end
								else
                                    begin
									    s_latch_total_stepnum_list <= s_latch_total_stepnum_list ;
										s_latch_total_loopnum_list <= s_latch_total_loopnum_list ;
										s_latch_workmode_CC_list   <= s_latch_workmode_CC_list   ;
										s_latch_workmode_CP_list   <= s_latch_workmode_CP_list   ;
										s_latch_workmode_CR_list   <= s_latch_workmode_CR_list   ;
										s_latch_workmode_CV_list   <= s_latch_workmode_CV_list   ;
										s_latch_target_list        <= s_latch_target_list        ;
										s_latch_runtime_list       <= s_latch_runtime_list       ;
										s_latch_repeat_list        <= s_latch_repeat_list        ;
										s_latch_goto_list          <= s_latch_goto_list          ;
										s_latch_loop_list          <= s_latch_loop_list          ;
									end
								
								if (o_cpl_list == 1) //列表执行完成
								    begin
									    s_cnt_total_loop_list <= 'd1  ;//总循环计数回到初始值
										s_cnt_runtime_list    <= 'd1  ;//单步执行时间计数回到初始值
										s_cnt_repeat_list     <= 'd1  ;//单步循环计数回到初始值
										s_cnt_loop_list       <= 'd1  ;//小循环计数回到初始值
										o_curstepnum_list     <= 'h1  ;//buff地址回到初始值
										s_rdbuff_enb          <= 1'b0 ;//buff读使能回到初始值
								    end
								else if ((o_curstepnum_list >= s_latch_total_stepnum_list) && (w_done_total_loop_list == 1)) //列表最后一个step//总循环结束
								    begin
								        if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (s_latch_goto_list == 'hffff)) //单步循环结束//单步执行结束//无小循环
								            begin
											    s_cnt_total_loop_list <= 'd1  ;//总循环计数回到初始值
												s_cnt_runtime_list    <= 'd1  ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= 'd1  ;//单步循环计数回到初始值
												s_cnt_loop_list       <= 'd1  ;//小循环计数回到初始值
												o_curstepnum_list     <= 'h1  ;//buff地址回到初始值
											    s_rdbuff_enb          <= 1'b0 ;//buff读使能回到初始值
											end
								        else if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (w_done_loop_list == 1'b1)) //单步循环结束//单步执行结束//小循环结束
								            begin
											    s_cnt_total_loop_list <= 'd1  ;//总循环计数回到初始值
												s_cnt_runtime_list    <= 'd1  ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= 'd1  ;//单步循环计数回到初始值
												s_cnt_loop_list       <= 'd1  ;//小循环计数回到初始值												
												o_curstepnum_list     <= 'h1  ;//buff地址回到初始值
											    s_rdbuff_enb          <= 1'b0 ;//buff读使能回到初始值
											end
								        else if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (w_done_loop_list == 1'b0)) //单步循环结束//单步执行结束//小循环跳转
								            begin
											    s_cnt_total_loop_list <= s_cnt_total_loop_list ;//总循环计数保持
												s_cnt_runtime_list    <= 'd1                   ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= 'd1                   ;//单步循环计数回到初始值
												s_cnt_loop_list       <= s_cnt_loop_list + 'h1 ;//小循环计数+1
												o_curstepnum_list     <= s_latch_goto_list     ;//buff地址跳转到goto地址
												s_rdbuff_enb          <= 1'b1                  ;//buff读使能有效
											end
								        else if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b0)) //单步循环结束//单步执行没结束
											begin
											    s_cnt_total_loop_list <= s_cnt_total_loop_list ;//总循环计数保持
												s_cnt_runtime_list    <= s_cnt_runtime_list + 'h1 ;//单步执行时间计数+1
												s_cnt_repeat_list     <= s_cnt_repeat_list     ;//单步循环计数保持
												s_cnt_loop_list       <= s_cnt_loop_list       ;//小循环计数保持
								                o_curstepnum_list     <= o_curstepnum_list        ;//buff地址保持
												s_rdbuff_enb          <= 1'b0                  ;//buff读使能不有效
										    end
										else if ((w_done_repeat_list == 1'b0) && (w_done_runus_list == 1'b1)) //单步循环没结束//单步执行结束
											begin
											    s_cnt_total_loop_list <= s_cnt_total_loop_list ;//总循环计数保持
												s_cnt_runtime_list    <= 'd1                   ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= s_cnt_repeat_list + 'h1 ;//单步循环计数保持+1
												s_cnt_loop_list       <= s_cnt_loop_list       ;//小循环计数保持												
								                o_curstepnum_list     <= o_curstepnum_list        ;//buff地址保持
												s_rdbuff_enb          <= 1'b0                  ;//buff读使能不有效
										    end
										else //单步循环没结束//单步执行没结束
								            begin
								                s_cnt_total_loop_list <= s_cnt_total_loop_list ;//总循环计数保持
												s_cnt_runtime_list    <= s_cnt_runtime_list + 'h1 ;//单步执行时间计数+1												
												s_cnt_repeat_list     <= s_cnt_repeat_list     ;//单步循环计数保持
												s_cnt_loop_list       <= s_cnt_loop_list       ;//小循环计数保持
												o_curstepnum_list     <= o_curstepnum_list        ;//buff地址保持
												s_rdbuff_enb          <= 1'b0                  ;//buff读使能不有效
										    end
								    end
								else if ((o_curstepnum_list >= s_latch_total_stepnum_list) && (w_done_total_loop_list == 0)) //列表最后一个step//总循环没有结束
								    begin
								        if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (s_latch_goto_list == 'hffff)) //单步循环结束//单步执行结束//无小循环
								            begin
											    s_cnt_total_loop_list <= s_cnt_total_loop_list + 'h1 ;//总循环计数+1
												s_cnt_runtime_list    <= 'd1                         ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= 'd1                         ;//单步循环计数回到初始值
												s_cnt_loop_list       <= 'd1                         ;//小循环计数回到初始值
												o_curstepnum_list     <= 'h1                         ;//buff地址回到初始值
											    s_rdbuff_enb          <= 1'b1                        ;//buff读使能有效
											end
								        else if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (w_done_loop_list == 1'b1)) //单步循环结束//单步执行结束//小循环结束
								            begin
											    s_cnt_total_loop_list <= s_cnt_total_loop_list + 'h1 ;//总循环计数+1
												s_cnt_runtime_list    <= 'd1                         ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= 'd1                         ;//单步循环计数回到初始值
												s_cnt_loop_list       <= 'd1                         ;//小循环计数回到初始值
												o_curstepnum_list     <= 'h1                         ;//buff地址回到初始值
											    s_rdbuff_enb          <= 1'b1                        ;//buff读使能有效
											end
								        else if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (w_done_loop_list == 1'b0)) //单步循环结束//单步执行结束//小循环跳转
								            begin
											    s_cnt_total_loop_list <= s_cnt_total_loop_list ;//总循环计数保持
												s_cnt_runtime_list    <= 'd1                   ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= 'd1                   ;//单步循环计数回到初始值
												s_cnt_loop_list       <= s_cnt_loop_list + 'h1 ;//小循环计数+1
												o_curstepnum_list     <= s_latch_goto_list     ;//buff地址跳转到goto地址
												s_rdbuff_enb          <= 1'b1                  ;//buff读使能有效
											end
								        else if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b0)) //单步循环结束//单步执行没结束
											begin
											    s_cnt_total_loop_list <= s_cnt_total_loop_list ;//
												s_cnt_runtime_list    <= s_cnt_runtime_list + 'h1 ;//单步执行时间计数+1												
												s_cnt_repeat_list     <= s_cnt_repeat_list     ;//单步循环计数保持
												s_cnt_loop_list       <= s_cnt_loop_list       ;//小循环计数保持
								                o_curstepnum_list     <= o_curstepnum_list        ;//
												s_rdbuff_enb          <= 1'b0                  ;//
										    end
										else if ((w_done_repeat_list == 1'b0) && (w_done_runus_list == 1'b1)) //单步循环没结束//单步执行结束
											begin
											    s_cnt_total_loop_list <= s_cnt_total_loop_list ;//
												s_cnt_runtime_list    <= 'd1                   ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= s_cnt_repeat_list + 'h1 ;//单步循环计数保持+1
												s_cnt_loop_list       <= s_cnt_loop_list       ;//小循环计数保持			
								                o_curstepnum_list     <= o_curstepnum_list        ;//
												s_rdbuff_enb          <= 1'b0                  ;//
										    end
										else //单步循环没结束//单步执行没结束
										    begin
											    s_cnt_total_loop_list <= s_cnt_total_loop_list ;//
												s_cnt_runtime_list    <= s_cnt_runtime_list + 'h1 ;//单步执行时间计数+1												
												s_cnt_repeat_list     <= s_cnt_repeat_list     ;//单步循环计数保持
												s_cnt_loop_list       <= s_cnt_loop_list       ;//小循环计数保持
								                o_curstepnum_list     <= o_curstepnum_list         ;//
												s_rdbuff_enb          <= 1'b0                   ;//
											end
								    end								
								else  //列表不是最后一个step
								    begin
								        s_cnt_total_loop_list <= s_cnt_total_loop_list ;
																				
										if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (s_latch_goto_list == 'hffff)) //单步循环结束//单步执行结束//无小循环
								            begin
											    s_cnt_runtime_list    <= 'd1                  ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= 'd1                  ;//单步循环计数回到初始值
												s_cnt_loop_list       <= 'd1                  ;//小循环计数回到初始值
												o_curstepnum_list     <= o_curstepnum_list + 'h1 ;//buff地址+1
												s_rdbuff_enb          <= 1'b1                 ;//buff读使能有效
											end
								        else if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (w_done_loop_list == 1'b1)) //单步循环结束//单步执行结束//小循环结束
								            begin
											    s_cnt_runtime_list    <= 'd1                  ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= 'd1                  ;//单步循环计数回到初始值
												s_cnt_loop_list       <= 'd1                  ;//小循环计数回到初始值
												o_curstepnum_list     <= o_curstepnum_list + 'h1 ;//buff地址+1
												s_rdbuff_enb          <= 1'b1                 ;//buff读使能有效
											end
								        else if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (w_done_loop_list == 1'b0)) //单步循环结束//单步执行结束//小循环跳转
								            begin
											    s_cnt_runtime_list    <= 'd1                   ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= 'd1                   ;//单步循环计数回到初始值
												s_cnt_loop_list       <= s_cnt_loop_list + 'h1 ;//小循环计数+1
												o_curstepnum_list     <= s_latch_goto_list     ;//buff地址跳转到goto地址
												s_rdbuff_enb          <= 1'b1                  ;//
											end
								        else if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b0)) //单步循环结束//单步执行没结束
											begin											    
								                s_cnt_runtime_list    <= s_cnt_runtime_list + 'h1 ;//单步执行时间计数+1												
												s_cnt_repeat_list     <= s_cnt_repeat_list     ;//单步循环计数保持
												s_cnt_loop_list       <= s_cnt_loop_list       ;//小循环计数保持												
												o_curstepnum_list     <= o_curstepnum_list        ;//
												s_rdbuff_enb          <= 1'b0                  ;//
										    end
										else if ((w_done_repeat_list == 1'b0) && (w_done_runus_list == 1'b1)) //单步循环没结束//单步执行结束
											begin											    
								                s_cnt_runtime_list    <= 'd1                   ;//单步执行时间计数回到初始值
												s_cnt_repeat_list     <= s_cnt_repeat_list + 'h1 ;//单步循环计数保持+1
												s_cnt_loop_list       <= s_cnt_loop_list       ;//小循环计数保持	
												o_curstepnum_list     <= o_curstepnum_list        ;//
												s_rdbuff_enb          <= 1'b0                  ;//
										    end
										else //单步循环没结束//单步执行没结束
								            begin
								                s_cnt_runtime_list    <= s_cnt_runtime_list + 'h1 ;//单步执行时间计数+1
												s_cnt_repeat_list     <= s_cnt_repeat_list     ;//单步循环计数保持
												s_cnt_loop_list       <= s_cnt_loop_list       ;//小循环计数保持
												o_curstepnum_list     <= o_curstepnum_list        ;//
												s_rdbuff_enb          <= 1'b0                  ;//
										    end
								    end
									
								if ((o_curstepnum_list >= s_latch_total_stepnum_list) && (w_done_total_loop_list == 1)) //列表最后一个step//总循环结束
								    begin
										if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (s_latch_goto_list == 'hffff)) //单步循环结束//单步执行结束//无小循环
								            o_cpl_list <= 1 ;
								        else if ((w_done_repeat_list == 1'b1) && (w_done_runus_list == 1'b1) && (w_done_loop_list == 1'b1)) //单步循环结束//单步执行结束//小循环结束
								            o_cpl_list <= 1 ;
										else 
								            o_cpl_list <= 0 ;
								    end
								else
								    o_cpl_list <= o_cpl_list ;
	                        end
            // 10'b0000001000 : begin//TOCP
	                        // end
	        // 10'b0000010000 : begin//TOPP
	                        // end
	        // 10'b0000100000,10'b0001000000 : begin//BT
	                        // end
	        default : begin			
			        end
	        endcase
	    end
end

//----------------------------------------------------------------------
//  TOCP
//  TOPP
//----------------------------------------------------------------------
assign  w_done_ns_TOCPP = s_cnt_ns_TOCPP >= _1US_CKNUM-1 ? 1'b1 : 1'b0 ;
assign  w_done_us_TOCPP = s_cnt_us_TOCPP >= 1000-1 ? 1'b1 : 1'b0 ;
assign  w_done_ms_TOCPP = s_cnt_ms_TOCPP >= 1000-1 ? 1'b1 : 1'b0 ;
assign  w_done_steptime_TOCP = s_cnt_steptime_TOCP >= i_step_Time_TOCP ? 1'b1 : 1'b0 ;
assign  w_done_steptime_TOPP = s_cnt_steptime_TOPP >= i_step_Time_TOPP ? 1'b1 : 1'b0 ;

always @ (posedge i_clk)
begin
    if ((s_pullout_enb == 1'b0) || (w_funcchange == 1'b1))
	    begin			
			s_cnt_steptime_TOCP <= 'h0 ;//
			o_pass_TOCP <= 0 ; 
			o_fail_TOCP <= 0 ;
			o_status_TOCP <= 0 ;
			o_cpl_TOCP <= 0 ;
			
			s_cnt_steptime_TOPP <= 'h0 ;//
			o_pass_TOPP <= 0 ; 
			o_fail_TOPP <= 0 ;
			o_status_TOPP <= 0 ;
			o_cpl_TOPP <= 0 ;
			
			s_cnt_ns_TOCPP <= 'h0 ; s_cnt_us_TOCPP <= 'h0 ; s_cnt_ms_TOCPP <= 'h0 ;
	    end	
	else
	    begin
			case ( Curfunc )
	        // 10'b0000000001 : begin//STA								
	                        // end
	        // 10'b0000000010 : begin//DYN	                            
	                        // end
	        // 10'b0000000100 : begin//LIST                                
	                        // end
            10'b0000001000 : begin //TOCP
			                    if (s_init_TOCP == 1)
								    s_cnt_steptime_TOCP <= 'h0 ;
								else if (w_done_steptime_TOCP == 1)
								    s_cnt_steptime_TOCP <= 'h0 ;
								// else if ((w_done_ns_TOCPP == 1) && (w_done_us_TOCPP == 1) && (w_done_ms_TOCPP == 1))
								else if ((w_done_ns_TOCPP == 1))
								    s_cnt_steptime_TOCP <= s_cnt_steptime_TOCP + 'h1 ;
								else
								    s_cnt_steptime_TOCP <= s_cnt_steptime_TOCP ;
								
                                if (s_init_TOCP == 1)
								    s_cnt_ns_TOCPP <= 'h0 ;
								else if (w_done_ns_TOCPP == 1)
								    s_cnt_ns_TOCPP <= 'h0 ;
								else 
								    s_cnt_ns_TOCPP <= s_cnt_ns_TOCPP + 'h1 ;
								
								if (s_init_TOCP == 1)
								    s_cnt_us_TOCPP <= 'h0 ;
								else if ((w_done_ns_TOCPP == 1) && (w_done_us_TOCPP == 1))
								    s_cnt_us_TOCPP <= 'h0 ;
								else if (w_done_ns_TOCPP == 1)
								    s_cnt_us_TOCPP <= s_cnt_us_TOCPP + 'h1 ;
								else 
								    s_cnt_us_TOCPP <= s_cnt_us_TOCPP ;
								
								if (s_init_TOCP == 1)
								    s_cnt_ms_TOCPP <= 'h0 ;
								else if ((w_done_ns_TOCPP == 1) && (w_done_us_TOCPP == 1) && (w_done_ms_TOCPP == 1))
								    s_cnt_ms_TOCPP <= 'h0 ;
								else if ((w_done_ns_TOCPP == 1) && (w_done_us_TOCPP == 1))
								    s_cnt_ms_TOCPP <= s_cnt_ms_TOCPP + 'h1 ;
								else 
								    s_cnt_ms_TOCPP <= s_cnt_ms_TOCPP ;
								
								if (s_init_TOCP == 1)
									begin o_pass_TOCP <= 0 ; o_fail_TOCP <= 0 ; o_status_TOCP <= 0 ; o_curTarget_TOCP <= o_curTarget_TOCP ; end
								else if (i_U_rt >= i_pro_Volt_TOCP)
								    begin o_pass_TOCP <= 0 ; o_fail_TOCP <= 0 ; o_status_TOCP <= 1 ; o_curTarget_TOCP <= o_curTarget_TOCP ; end
								else if ((i_U_rt < i_pro_Volt_TOCP) && (i_I_rt < i_over_Curr_MAX_TOCP) && (i_I_rt >= i_over_Curr_MIN_TOCP)) //发生OCP且电流在范围内
								    begin o_pass_TOCP <= 1 ; o_fail_TOCP <= 0 ; o_status_TOCP <= 8 ; o_curTarget_TOCP <= o_CC_target ; end	
								else if ((i_U_rt < i_pro_Volt_TOCP) && (i_I_rt < i_over_Curr_MIN_TOCP))//发生OCP且电流不在范围内
								    begin o_pass_TOCP <= 0 ; o_fail_TOCP <= 1 ; o_status_TOCP <= 2 ; o_curTarget_TOCP <= o_CC_target ; end	
								else if ((i_U_rt < i_pro_Volt_TOCP) && (i_I_rt >= i_over_Curr_MAX_TOCP)) //发生OCP且电流不在范围内
								    begin o_pass_TOCP <= 0 ; o_fail_TOCP <= 1 ; o_status_TOCP <= 4 ; o_curTarget_TOCP <= o_CC_target ; end	
								else 
									begin o_pass_TOCP <= o_pass_TOCP ; o_fail_TOCP <= o_fail_TOCP ; o_status_TOCP <= o_status_TOCP ; o_curTarget_TOCP <= o_curTarget_TOCP ; end
								                               
								if (s_init_TOCP == 1)
								    o_cpl_TOCP <= 0 ;
								else if (((w_done_steptime_TOCP == 1) && (o_CC_target == i_stop_Curr_TOCP)) || (i_U_rt < i_pro_Volt_TOCP))
								    o_cpl_TOCP <= 1 ;// 或者触发ocp就立刻完成OCP操作
								else
								    o_cpl_TOCP <= o_cpl_TOCP ;
	                        end
	        10'b0000010000 : begin //TOPP
			                    if (s_init_TOPP == 1)
								    s_cnt_steptime_TOPP <= 'h0 ;
								else if (w_done_steptime_TOPP == 1)
								    s_cnt_steptime_TOPP <= 'h0 ;
								// else if ((w_done_ns_TOCPP == 1) && (w_done_us_TOCPP == 1) && (w_done_ms_TOCPP == 1))
								else if ((w_done_ns_TOCPP == 1))
								    s_cnt_steptime_TOPP <= s_cnt_steptime_TOPP + 'h1 ;
								else
								    s_cnt_steptime_TOPP <= s_cnt_steptime_TOPP ;
								
                                if (s_init_TOPP == 1)
								    s_cnt_ns_TOCPP <= 'h0 ;
								else if (w_done_ns_TOCPP == 1)
								    s_cnt_ns_TOCPP <= 'h0 ;
								else 
								    s_cnt_ns_TOCPP <= s_cnt_ns_TOCPP + 'h1 ;
								
								if (s_init_TOPP == 1)
								    s_cnt_us_TOCPP <= 'h0 ;
								else if ((w_done_ns_TOCPP == 1) && (w_done_us_TOCPP == 1))
								    s_cnt_us_TOCPP <= 'h0 ;
								else if (w_done_ns_TOCPP == 1)
								    s_cnt_us_TOCPP <= s_cnt_us_TOCPP + 'h1 ;
								else 
								    s_cnt_us_TOCPP <= s_cnt_us_TOCPP ;
								
								if (s_init_TOPP == 1)
								    s_cnt_ms_TOCPP <= 'h0 ;
								else if ((w_done_ns_TOCPP == 1) && (w_done_us_TOCPP == 1) && (w_done_ms_TOCPP == 1))
								    s_cnt_ms_TOCPP <= 'h0 ;
								else if ((w_done_ns_TOCPP == 1) && (w_done_us_TOCPP == 1))
								    s_cnt_ms_TOCPP <= s_cnt_ms_TOCPP + 'h1 ;
								else 
								    s_cnt_ms_TOCPP <= s_cnt_ms_TOCPP ;
								
								if (s_init_TOPP == 1)
									begin o_pass_TOPP <= 0 ; o_fail_TOPP <= 0 ; o_status_TOPP <= 0 ; o_curTarget_TOPP <= o_curTarget_TOPP ; end
								else if (i_U_rt >= i_pro_Volt_TOPP)
								    begin o_pass_TOPP <= 0 ; o_fail_TOPP <= 0 ; o_status_TOPP <= 1 ; o_curTarget_TOPP <= o_curTarget_TOPP ; end
								else if ((i_U_rt < i_pro_Volt_TOPP) && (i_P_rt < i_over_Power_MAX_TOPP) && (i_P_rt >= i_over_Power_MIN_TOPP)) //发生OPP且功率在范围内
								    begin o_pass_TOPP <= 1 ; o_fail_TOPP <= 0 ; o_status_TOPP <= 8 ; o_curTarget_TOPP <= o_CP_target ; end	
								else if ((i_U_rt < i_pro_Volt_TOPP) && (i_P_rt < i_over_Power_MIN_TOPP)) //发生OPP且功率不在范围内
								    begin o_pass_TOPP <= 0 ; o_fail_TOPP <= 1 ; o_status_TOPP <= 2 ; o_curTarget_TOPP <= o_CP_target ; end
								else if ((i_U_rt < i_pro_Volt_TOPP) && (i_P_rt >= i_over_Power_MAX_TOPP)) //发生OPP且功率不在范围内
								    begin o_pass_TOPP <= 0 ; o_fail_TOPP <= 1 ; o_status_TOPP <= 4 ; o_curTarget_TOPP <= o_CP_target ; end	
								else	
									begin o_pass_TOPP <= o_pass_TOPP ; o_fail_TOPP <= o_fail_TOPP ; o_status_TOPP <= o_status_TOPP ; o_curTarget_TOPP <= o_curTarget_TOPP ; end
								
								if (s_init_TOPP == 1)
								    o_cpl_TOPP <= 0 ;								
								else if (((w_done_steptime_TOPP == 1) && (o_CP_target == i_stop_Power_TOPP)) || (i_U_rt < i_pro_Volt_TOPP))
								    o_cpl_TOPP <= 1 ;// OPP立刻停止
								else
								    o_cpl_TOPP <= o_cpl_TOPP ;
	                        end
	        // 10'b0000100000,10'b0001000000 : begin//BT
	                        // end
	        default : begin
			        end
	        endcase
	    end
end

//----------------------------------------------------------------------
//  BATT
//----------------------------------------------------------------------

always @ (posedge i_clk)
begin
    if ((s_pullout_enb == 1'b0) || (w_funcchange == 1'b1))
	    begin
			o_cpl_BATT   <= 0 ;
	    end	
	else
	    begin
			case ( Curfunc )
	        // 10'b0000000001 : begin //STA
	                        // end
	        // 10'b0000000010 : begin //DYN
	                        // end
	        // 10'b0000000100 : begin //LIST
	                        // end
            // 10'b0000001000 : begin //TOCP
	                        // end
	        // 10'b0000010000 : begin //TOPP
	                        // end
	        10'b0000100000,10'b0001000000 : begin //BT
			                    if (w_modechange_bat == 1'b1)
								    begin
									    o_cpl_BATT <= 0 ;
									end
								else if (CurWorkMode_bat[0] == 1'b1)/* i_workmode_CC */
	        					    begin
                                        if (s_init_CC == 1)
										    o_cpl_BATT <= 0 ;
										else if (i_U_rt < i_proV_BT_Stop) //电压保护截止
	        							    o_cpl_BATT <= 1 ;
										else if ((CurWorkMode_bat[4] == 1) && (i_U_rt < i_offV_BT_Stop)) //电压截止
										    o_cpl_BATT <= 1 ;
										else if ((CurWorkMode_bat[5] == 1) && (i_BAT_time >= i_offT_BT_Stop)) //时间截止
										    o_cpl_BATT <= 1 ;
										else if ((CurWorkMode_bat[6] == 1) && (i_BAT_cap >= i_offC_BT_Stop)) //容量截止
										    o_cpl_BATT <= 1 ;
										else
                                            o_cpl_BATT <= o_cpl_BATT ;
									end
	        					else if (CurWorkMode_bat[1] == 1'b1)/* i_workmode_CP */
	        					    begin											
										if (s_init_CP == 1)
										    o_cpl_BATT <= 0 ;
										else if (i_U_rt < i_proV_BT_Stop) //电压保护截止
	        							    o_cpl_BATT <= 1 ;
										else if ((CurWorkMode_bat[4] == 1) && (i_U_rt < i_offV_BT_Stop)) //电压截止
										    o_cpl_BATT <= 1 ;
										else if ((CurWorkMode_bat[5] == 1) && (i_BAT_time >= i_offT_BT_Stop)) //时间截止
										    o_cpl_BATT <= 1 ;
										else if ((CurWorkMode_bat[6] == 1) && (i_BAT_cap >= i_offC_BT_Stop)) //容量截止
										    o_cpl_BATT <= 1 ;
										else
                                            o_cpl_BATT <= o_cpl_BATT ;
	        						end
	        					else if (CurWorkMode_bat[2] == 1'b1)/* i_workmode_CR */
	        					    begin											
										if (s_init_CR == 1)
										    o_cpl_BATT <= 0 ;
										else if (i_U_rt < i_proV_BT_Stop) //电压保护截止
	        							    o_cpl_BATT <= 1 ;
										else if ((CurWorkMode_bat[4] == 1) && (i_U_rt < i_offV_BT_Stop)) //电压截止
										    o_cpl_BATT <= 1 ;
										else if ((CurWorkMode_bat[5] == 1) && (i_BAT_time >= i_offT_BT_Stop)) //时间截止
										    o_cpl_BATT <= 1 ;
										else if ((CurWorkMode_bat[6] == 1) && (i_BAT_cap >= i_offC_BT_Stop)) //容量截止
										    o_cpl_BATT <= 1 ;
										else
                                            o_cpl_BATT <= o_cpl_BATT ;
	        						end
	        					else
	        					    begin
	        						end
	                        end
	        default : begin			            
			        end
	        endcase
	    end
end



//----------------------------------------------------------------------
//  output
//----------------------------------------------------------------------

//DAC控制
// output  reg                             o_outa_enb        =0 ,//
// output  reg     [15:0]                  o_outa_data       =0 ,//CELL_PROG_DA
// output  reg                             o_outb_enb        =0 ,//
// output  reg     [15:0]                  o_outb_data       =0 ,//CV_limit_DA

always @ (posedge i_clk)
begin
    if ((s_pullout_enb == 1'b0) || (w_funcchange == 1'b1))
	    begin
            s_hardCV_1r <= i_hardCV_ON ;//
            s_hardCV_2r <= s_hardCV_1r ;//
			
			if ((w_modechange == 1) && (s_hardCV_1r == 1) && (CurWorkMode[3] == 1))//模式切换到CV且硬件CV打开
			    begin
				    o_outa_enb   <= 1                 ;//
			        o_outa_data  <= {1'B1,{15{1'B1}}} ;//无符号MAX值
			        o_outb_enb   <= 1                 ;
			        o_outb_data  <= {1'B1,{15{1'B1}}} ;
				end
			else if ((w_modechange == 1) && (CurWorkMode[3] == 0))//模式切换到非CV
			    begin
				    o_outa_enb   <= 1                 ;//
			        o_outa_data  <= {1'B0,{15{1'B0}}} ;//无符号MAX值
			        o_outb_enb   <= 1                 ;
			        o_outb_data  <= {1'B1,{15{1'B1}}} ;
				end
			else if ((s_hardCV_1r == 1) && (s_hardCV_2r == 0) && (CurWorkMode[3] == 1))//CV模式下切换硬件CV
			    begin
				    o_outa_enb   <= 1                 ;//
			        o_outa_data  <= {1'B1,{15{1'B1}}} ;//无符号MAX值
			        o_outb_enb   <= 1                 ;
			        o_outb_data  <= {1'B1,{15{1'B1}}} ;
				end
			else if ((s_hardCV_1r == 0) && (s_hardCV_2r == 1) && (CurWorkMode[3] == 1))//CV模式下切换软件CV
			    begin
				    o_outa_enb   <= 1                 ;//
			        o_outa_data  <= {1'B0,{15{1'B0}}} ;//无符号MAX值
			        o_outb_enb   <= 1                 ;
			        o_outb_data  <= {1'B1,{15{1'B1}}} ;
				end
			else
			if (s_workmode_temp == 4'b0001) //CC
			    begin
			        o_outa_enb   <= o_outb_enb  ;//i_CC_ctrlen ;
			        o_outa_data  <= i_CC_ctrl   ;
			        o_outb_enb   <= i_CC_ctrlen ;
			        o_outb_data  <= i_CC_limit_ctrl ;
				end
			else if (s_workmode_temp == 4'b0010) //CP
			    begin
			        o_outa_enb   <= o_outb_enb  ;//i_CP_ctrlen ;
			        o_outa_data  <= i_CP_ctrl   ;
			        o_outb_enb   <= i_CP_ctrlen ;
			        o_outb_data  <= i_CP_limit_ctrl ;
				end
			else if (s_workmode_temp == 4'b0100) //CR
			    begin
			        o_outa_enb   <= o_outb_enb  ;//i_CR_ctrlen ;
			        o_outa_data  <= i_CR_ctrl   ;
			        o_outb_enb   <= i_CR_ctrlen ;
			        o_outb_data  <= i_CR_limit_ctrl ;
				end
			else if (s_workmode_temp == 4'b1000) //CV
			    begin
			        o_outa_enb   <= o_outb_enb  ;//i_CV_ctrlen ;
			        o_outa_data  <= i_CV_ctrl   ;
			        o_outb_enb   <= i_CV_ctrlen ;
			        o_outb_data  <= i_CV_limit_ctrl ;
				end
			else
			    begin
			        o_outa_enb   <= 0 ;// ;
			        o_outa_data  <= 0 ;
			        o_outb_enb   <= 0 ;
			        o_outb_data  <= 0 ;
				end
			s_workmode_temp <= s_workmode_temp ;
	    end	
	else
	    begin	
	        case ( Curfunc )
	        10'b0000000001 : begin //STA
								if (w_modechange == 1'b1)
								    begin
									    o_outa_enb   <= 0 ;
			                            o_outa_data  <= 0 ;
			                            o_outb_enb   <= 0 ;
			                            o_outb_data  <= 0 ;
										s_workmode_temp <= s_workmode_temp ;
									end
								else if ((CurWorkMode[0] == 1'b1) || ((CurWorkMode[3] == 1'b1) && (i_worktype_Single == 1'b0) && (i_ms_Master == 1'b0)))/* i_workmode_CC */
	        					    begin	        						    
	        							o_outa_enb   <= o_outb_enb  ;//i_CC_ctrlen ;
			                            o_outa_data  <= i_CC_ctrl   ;
			                            o_outb_enb   <= i_CC_ctrlen ;
			                            o_outb_data  <= i_CC_limit_ctrl ;
										s_workmode_temp <= 4'B0001 ;
	        						end
	        					else if (CurWorkMode[1] == 1'b1)/* i_workmode_CP */
	        					    begin
	        						    o_outa_enb   <= o_outb_enb  ;//i_CP_ctrlen ;
			                            o_outa_data  <= i_CP_ctrl   ;
			                            o_outb_enb   <= i_CP_ctrlen ;
			                            o_outb_data  <= i_CP_limit_ctrl ;
										s_workmode_temp <= 4'B0010 ;
	        						end
	        					else if (CurWorkMode[2] == 1'b1)/* i_workmode_CR */
	        					    begin
	        						    o_outa_enb   <= o_outb_enb  ;//i_CR_ctrlen ;
			                            o_outa_data  <= i_CR_ctrl   ;
			                            o_outb_enb   <= i_CR_ctrlen ;
			                            o_outb_data  <= i_CR_limit_ctrl ;
										s_workmode_temp <= 4'B0100 ;
	        						end
	        					else if (CurWorkMode[3] == 1'b1)/* i_workmode_CV */
	        					    begin
	        						    o_outa_enb   <= o_outb_enb  ;//i_CV_ctrlen ;
			                            o_outa_data  <= i_CV_ctrl   ;
			                            o_outb_enb   <= i_CV_ctrlen ;
			                            o_outb_data  <= i_CV_limit_ctrl ;
										s_workmode_temp <= 4'B1000 ;
	        						end
	        					else
	        					    begin
									    o_outa_enb   <= 0 ;
			                            o_outa_data  <= 0 ;
			                            o_outb_enb   <= 0 ;
			                            o_outb_data  <= 0 ;
										s_workmode_temp <= s_workmode_temp ;
	        						end
	                        end
	        10'b0000000010 : begin //DYN	                            
								if (w_modechange == 1'b1)
								    begin
									    o_outa_enb   <= 0 ;
			                            o_outa_data  <= 0 ;
			                            o_outb_enb   <= 0 ;
			                            o_outb_data  <= 0 ;
										s_workmode_temp <= s_workmode_temp ;
									end
								else if ((CurWorkMode[0] == 1'b1) || ((CurWorkMode[3] == 1'b1) && (i_worktype_Single == 1'b0) && (i_ms_Master == 1'b0)))/* i_workmode_CC */
	        					    begin
	        						    o_outa_enb   <= o_outb_enb  ;//i_CC_ctrlen ;
			                            o_outa_data  <= i_CC_ctrl   ;
			                            o_outb_enb   <= i_CC_ctrlen ;
			                            o_outb_data  <= i_CC_limit_ctrl ;
										s_workmode_temp <= 4'B0001 ;
	        						end
	        					else if (CurWorkMode[1] == 1'b1)/* i_workmode_CP */
	        					    begin
	        						    o_outa_enb   <= o_outb_enb  ;//i_CP_ctrlen ;
			                            o_outa_data  <= i_CP_ctrl   ;
			                            o_outb_enb   <= i_CP_ctrlen ;
			                            o_outb_data  <= i_CP_limit_ctrl ;
										s_workmode_temp <= 4'B0010 ;
	        						end
	        					else if (CurWorkMode[2] == 1'b1)/* i_workmode_CR */
	        					    begin
	        						    o_outa_enb   <= o_outb_enb  ;//i_CR_ctrlen ;
			                            o_outa_data  <= i_CR_ctrl   ;
			                            o_outb_enb   <= i_CR_ctrlen ;
			                            o_outb_data  <= i_CR_limit_ctrl ;
										s_workmode_temp <= 4'B0100 ;
	        						end
	        					else if (CurWorkMode[3] == 1'b1)/* i_workmode_CV */
	        					    begin
	        						    o_outa_enb   <= o_outb_enb  ;//i_CV_ctrlen ;
			                            o_outa_data  <= i_CV_ctrl   ;
			                            o_outb_enb   <= i_CV_ctrlen ;
			                            o_outb_data  <= i_CV_limit_ctrl ;
										s_workmode_temp <= 4'B1000 ;
	        						end
	        					else
	        					    begin
									    o_outa_enb   <= 0 ;
			                            o_outa_data  <= 0 ;
			                            o_outb_enb   <= 0 ;
			                            o_outb_data  <= 0 ;
										s_workmode_temp <= s_workmode_temp ;
	        						end
	                        end
	        10'b0000000100 : begin //LIST
			                    if (w_modechange_list == 1'b1)
								    begin
									    o_outa_enb   <= 0 ;
			                            o_outa_data  <= 0 ;
			                            o_outb_enb   <= 0 ;
			                            o_outb_data  <= 0 ;
										s_workmode_temp <= s_workmode_temp ;
									end
								else if ((CurWorkMode_list[0] == 1'b1) || ((CurWorkMode_list[3] == 1'b1) && (i_worktype_Single == 1'b0) && (i_ms_Master == 1'b0)))/* i_workmode_CC */
	        					    begin
	        							o_outa_enb   <= o_outb_enb  ;//i_CC_ctrlen ;
			                            o_outa_data  <= i_CC_ctrl   ;
			                            o_outb_enb   <= i_CC_ctrlen ;
			                            o_outb_data  <= i_CC_limit_ctrl ;
										s_workmode_temp <= 4'B0001 ;
	        						end
	        					else if (CurWorkMode_list[1] == 1'b1)/* i_workmode_CP */
	        					    begin	        						    
										o_outa_enb   <= o_outb_enb  ;//i_CP_ctrlen ;
			                            o_outa_data  <= i_CP_ctrl   ;
			                            o_outb_enb   <= i_CP_ctrlen ;
			                            o_outb_data  <= i_CP_limit_ctrl ;
										s_workmode_temp <= 4'B0010 ;
	        						end
	        					else if (CurWorkMode_list[2] == 1'b1)/* i_workmode_CR */
	        					    begin
										o_outa_enb   <= o_outb_enb  ;//i_CR_ctrlen ;
			                            o_outa_data  <= i_CR_ctrl   ;
			                            o_outb_enb   <= i_CR_ctrlen ;
			                            o_outb_data  <= i_CR_limit_ctrl ;
										s_workmode_temp <= 4'B0100 ;
	        						end
	        					else if (CurWorkMode_list[3] == 1'b1)/* i_workmode_CV */
	        					    begin	        						    
										o_outa_enb   <= o_outb_enb  ;//i_CV_ctrlen ;
			                            o_outa_data  <= i_CV_ctrl   ;
			                            o_outb_enb   <= i_CV_ctrlen ;
			                            o_outb_data  <= i_CV_limit_ctrl ;
										s_workmode_temp <= 4'B1000 ;
	        						end
	        					else
	        					    begin
									    o_outa_enb   <= 0 ;
			                            o_outa_data  <= 0 ;
			                            o_outb_enb   <= 0 ;
			                            o_outb_data  <= 0 ;
										s_workmode_temp <= s_workmode_temp ;
	        						end								
	                        end
            10'b0000001000 : begin //TOCP
			                    o_outa_enb   <= o_outb_enb  ;//i_CC_ctrlen ;
			                    o_outa_data  <= i_CC_ctrl   ;
			                    o_outb_enb   <= i_CC_ctrlen ;
			                    o_outb_data  <= i_CC_limit_ctrl ;
								s_workmode_temp <= 4'B0001 ;
	                        end
	        10'b0000010000 : begin //TOPP
			                    o_outa_enb   <= o_outb_enb  ;//i_CP_ctrlen ;
			                    o_outa_data  <= i_CP_ctrl   ;
			                    o_outb_enb   <= i_CP_ctrlen ;
			                    o_outb_data  <= i_CP_limit_ctrl ;
								s_workmode_temp <= 4'B0010 ;
	                        end
	        10'b0000100000,10'b0001000000 : begin //BT
			                    if (w_modechange_bat == 1'b1)
								    begin
									    o_outa_enb   <= 0 ;
			                            o_outa_data  <= 0 ;
			                            o_outb_enb   <= 0 ;
			                            o_outb_data  <= 0 ;
										s_workmode_temp <= s_workmode_temp ;
									end
								else if (CurWorkMode_bat[0] == 1'b1)/* i_workmode_CC */
	        					    begin
	        						    o_outa_enb   <= o_outb_enb  ;//i_CC_ctrlen ;
			                            o_outa_data  <= i_CC_ctrl   ;
			                            o_outb_enb   <= i_CC_ctrlen ;
			                            o_outb_data  <= i_CC_limit_ctrl ;
										s_workmode_temp <= 4'B0001 ;
	        						end
	        					else if (CurWorkMode_bat[1] == 1'b1)/* i_workmode_CP */
	        					    begin
										o_outa_enb   <= o_outb_enb  ;//i_CP_ctrlen ;
			                            o_outa_data  <= i_CP_ctrl   ;
			                            o_outb_enb   <= i_CP_ctrlen ;
			                            o_outb_data  <= i_CP_limit_ctrl ;
										s_workmode_temp <= 4'B0010 ;
	        						end
	        					else if (CurWorkMode_bat[2] == 1'b1)/* i_workmode_CR */
	        					    begin
										o_outa_enb   <= o_outb_enb  ;//i_CR_ctrlen ;
			                            o_outa_data  <= i_CR_ctrl   ;
			                            o_outb_enb   <= i_CR_ctrlen ;
			                            o_outb_data  <= i_CR_limit_ctrl ;
										s_workmode_temp <= 4'B0100 ;
	        						end
	        					else
	        					    begin
									    o_outa_enb   <= 0 ;
			                            o_outa_data  <= 0 ;
			                            o_outb_enb   <= 0 ;
			                            o_outb_data  <= 0 ;
										s_workmode_temp <= s_workmode_temp ;
	        						end
	                        end
	        default : begin
			        end
	        endcase
	    end	
end


//--------------------------------------------------------------------------------------
// ila_ctrl
//--------------------------------------------------------------------------------------
// wire                    w_ck_ctrl      ;
// wire    [31:0]          w_p0_ctrl      ;

// assign  w_ck_ctrl  = i_clk            ;
// assign  w_p0_ctrl  = {
// s_pullout_enb     , //BIT31
// Curfunc[7]        , //BIT30
// Curfunc[6]        , //BIT29
// Curfunc[5]        , //BIT28
// Curfunc[4]        , //BIT27
// Curfunc[3]        , //BIT26
// Curfunc[2]        , //BIT25
// Curfunc[1]        , //BIT24
// Curfunc[0]        , //BIT23
// CurWorkMode[3]    , //BIT22
// CurWorkMode[2]    , //BIT21
// CurWorkMode[1]    , //BIT20
// CurWorkMode[0]    , //BIT19
// s_init_CC         , //BIT18
// s_init_CP         , //BIT17
// s_init_CR         , //BIT16
// s_init_CV         , //BIT15
// o_workmode_CC_rt  , //BIT14
// o_workmode_CP_rt  , //BIT13
// o_workmode_CR_rt  , //BIT12
// o_workmode_CV_rt  , //BIT11
// w_maxU_limit_over , //BIT10
// w_maxP_limit_over , //BIT9
// w_maxI_limit_over , //BIT8
// w_setI_over       , //BIT7
// w_setU_over       , //BIT6
// w_setP_over       , //BIT5
// w_setI_over_CV    , //BIT4
// o_CV_on           , //BIT3
// o_CR_on           , //BIT2
// o_CP_on           , //BIT1
// o_CC_on             //BIT0
// };

// ila_ctrl U_ila_ctrl
// (
	 // .clk           ( w_ck_ctrl   ) // input wire clk
	// ,.probe0        ( w_p0_ctrl   ) // input wire [31:0]  probe0  
// ); 


// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug customized by cxz
//---------------------------------------------------------------------
// ila_main_ctrl u_ila_main_ctrl (
//     .clk                            (i_clk              ),// input wire clk


//     .probe0                         (s_init_CC          ),// input wire [0:0]  probe0  
//     .probe1                         ({s_init_TOPP,CurWorkMode_bat[6:0]}),// input wire [7:0]  probe1 
//     .probe2                         (o_cpl_BATT         ),// input wire [0:0]  probe2 
//     .probe3                         (o_CC_on            ),// input wire [0:0]  probe3 
//     .probe4                         (s_init_TOPP        ),// input wire [0:0]  probe4 
//     .probe5                         (CurWorkMode        ),// input wire [3:0]  probe5 
//     .probe6                         (i_on               ),// input wire [0:0]  probe6 
//     .probe7                         (o_doing            ),// input wire [0:0]  probe7
//     .probe8                         (w_done_precharge   ),// input wire [0:0]  probe8
//     .probe9                         (Curfunc            ) // input wire [11:0]  probe9
// );

// ila_main_ctrl u_ila_main_ctrl (
//     .clk                            (i_clk              ),// input wire clk


//     .probe0                         (o_CV_on            ),// input wire [0:0]  probe0  
//     .probe1                         (o_outa_data        ),// input wire [15:0]  probe1 
//     .probe2                         (o_outb_enb         ),// input wire [0:0]  probe2 
//     .probe3                         (o_outb_data        ) // input wire [15:0]  probe3
// );

// ila_pull_out U_pull_out
// (
//     .clk                            (i_clk      ) // input wire clk
//     ,.probe0        ( o_CV_target   )                               // input wire [23:0]  probe0  
//     ,.probe1        ( {o_CV_on,o_outa_enb,o_outb_enb,s_pullout_enb,w_funcchange,s_workmode_temp,CurWorkMode,o_flag_1us,w_modechange,s_hardCV_1r}  )// input wire [23:0]  probe1 
//     ,.probe2        ( {i_CV_ctrl[15:0],i_CV_limit_ctrl[15:0]}   )         // input wire [31:0]  probe2 
//     ,.probe3        ( {o_outa_data[15:0],o_outb_data[15:0]}   )    // input wire [31:0]  probe3 
// );


endmodule
