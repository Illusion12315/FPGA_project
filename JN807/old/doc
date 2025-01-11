JN807电子负载FPGA接口定义说明_V1.0
（参考8kw电子负载）


数值转换说明：
设置：
Iset：恒电流输出目标值，32位，范围0-720000，/1000后为实际电流值0-720.000A
Vset：恒电压输出目标值，32位，范围0-1500000，/1000后为实际电压值0-1500.000V
Pset：恒功率输出目标值，32位，范围0-10000000，/1000后为实际功率值0-10000.000W
Rset：恒阻输出目标值，32位，范围0-100000000，/10000后为实际阻值0-10000.0000欧
Von：启动电压，16位，范围0-15000，/10后为实际电压值0-1500.0V
TOCP_Von_set：OCP测试的启动电压，32位，范围0-1500000，/1000后为实际电压值0-1500.0V
TOPP_Von_set：OPP测试的启动电压，32位，范围0-1500000，/1000后为实际电压值0-1500.0V
Voff：停止电压，16位，范围0-14990，/10后为实际电压值0-1499.0V
R/F_slew：电流斜率控制，16位，范围0-50000，/1000后为实际值0-50.000A/us
CV_slew：CV模式电压斜率控制，16位，范围0-50000，/1000后为实际值0-50.000V/us
T1/T2：动态持续时间，32位，单位us，范围25-30000000，即25us至30秒
I_lim：限流保护值，32位，范围0-720000，/1000后为实际电流值0-720.000A
P_lim：限功率保护值，32位，范围0-10000000，/1000后为实际功率值0-10000.000W
CV_lim：CV模式下限流值，32位，范围0-720000，/1000后为实际电流值0-720.000A


读取：
V（{0x312,0x311}）：电压测量值，32位，范围0-1500000，/1000后为实际电压值0-1500.000V
I（{0x314,0x313}）：电流测量值，32位，范围0-720000，/1000后为实际电流值0-720.000A
Idis：电流显示值，32位，范围0-720000，/1000后为实际电流值0-720.000A
Vpro：保护用电压值，32位，范围0-1500000，/1000后为实际电压值0-1500.000V
Ppro：保护用功率值，32位，范围0-10000000，/1000后为实际功率值0-10000.000W
Ia-f：单模块电流测量值，32位，范围0-120000，/1000后为实际电流值0-120.000A


FPGA与ARM之间存储空间分配说明（参数读写部分）
地址	内容	
0X000	保留	
0x001	Workmod： [CC(0x5a5a)、CV(0xa5a5)、CP(0x5a00)、CR(0x005a)]	
0x002	Func：[
STA(0x5a00)、---- Static
DYN(0xa500)、---- Dynamic
RIP(0x5a0F)、----
RE(0x5aE0)、---- 
FE(0x5aEF)、---- 
BAT_N(0x5aB0)、---- 
BAT_P(0x5aBF)、---- 
LIST(0x5aFF)、---- LIST 
TOCP(0x5A3C)、---- OCP Test
TOPP(0x5AC3)  ---- OPP Test
]	
0x003	SENSE功能选择，0x5a5a不使用SENSE功能；0xa5a5使能SENSE	
0x004	Model：机型，0xabcd
a：保留
b：功率等级，0-4kw；1-5kw；2-6kw；3-3kw；4-2KW；5-5.5KW；6-8KW；
c：电压等级，0-120V；1-150V；2-600V；3-1000V，4-1200V
d：电流等级，0-40A；1-100A；2-200A；3-400A；4-240；5-60；6-80；7-120；8-160；9-280；10-300；11-320；12-450；13-480；14-600；15-800A;
例如
0x0130：DLL50-1000；(40A)
0x0122：DLL50-600；(200A)	
0x005	Worktype：0x5a5a-单机；0xa5a5-多机	
0x006	M_S：0x5a5a-主机；0xa5a5-从机	
0x007	Clear_alarm：0x5a5a-清除保护告警状态，其它值无效。用户按确认键清除保护报警状态后，立刻将本字段重置为0x0	WO
0x008	RUN_flag：0xa5a5-停止；0x5a5a-运行
当“OUT”按键按下后，首先读取地址0x208中的Run_status；如果是0x5a5a，则下发停止命令；如果是0xa5a5，则下发运行命令；如果是其它值，则不作任何操作。
命令字下发后立刻将本字段重置为0x0	WO
0x009	Short：短路设置，0x5a5a-短路；0xa5a5-不短路	
0x00A	Von：启动电压	
0x00B	SR_slew：静态模式下，电流上升斜率（在ON/OFF过程中有效）（1~3000000）(单位1mA/ms)	
0x00C	SF_slew：静态模式下，电流下降斜率（在ON/OFF过程中有效）（1~3000000）(单位1mA/ms)	
		
0x00F	Von_Latch：0xa5a5-Latch OFF；0x5a5a-Latch ON	
0x010(16)	Voff：停止电压，仅在Von Latch是OFF状态时有效	
0x011(17)	Iset_L(单位1mA)	
0x012(18)	Iset_H(单位1mA)	
0x013(19)	Vset_L(单位1mV)	
0x014(20)	Vset_H(单位1mV)	
0x015(21)	Pset_L	
0x016(22)	Pset_H	
0x017(23)	Rset_L	
0x018(24)	Rset_H	
0x019(25)	Iset1_L	
0x01A(26)	Iset1_H	
0x01B(27)	Iset2_L	
0x01C(28)	Iset2_H	
0x01D(29)	Vset1_L	
0x01E(30)	Vset1_H	
0x01F(31)	Vset2_L	
0x020(32)	Vset2_H	
0x021(33)	Pset1_L	
0x022(34)	Pset1_H	
0x023(35)	Pset2_L	
0x024(36)	Pset2_H	
0x025(37)	Rset1_L	
0x026(38)	Rset1_H	
0x027(39)	Rset2_L	
0x028(40)	Rset2_H	
		
0x02D(45)	DR_slew：动态模式下，电流上升斜率(1mA/us) （1~3000000）(单位1mA/ms)	
0x02E(46)	DF_slew：动态模式下，电流下降斜率(1mA/us) （1~3000000）(单位1mA/ms)	
0x02F(47)	Vrange：电压测量档位，0x5a5a-高档；0xa5a5-低档	
0x030(48)	CVspeed：CV模式速度调节，默认0x0003-慢速
软件CV：0x0001-快速；0x0002-中速；0x0003-慢速
硬件CV：0x0001-快速；0x0002-中速（实际慢速）；0x0003-慢速	
0x031(49)	CV_slew：CV模式电压变化斜率(单位1mV/ms)	
		
0x033(51)	用于设置CR(I=U/R)模式下的控制电压U的滤波时间：
参数值：滤波时间
N：2^N*5us
0：5us
1：10us
2：20us
3：40us
4：80us
5：160us
6：320us
7：640us
8：1280us
其他：无效	
0x040(64)	num_paral：并机数，默认1台	
		
电子负载限压、限流、限功率等保护参数设置(limit = Max + offset)	
0x041(65)	I_lim_L：限流保护值(OCP)----OCP发生条件	
0x042(66)	I_lim_H：限流保护值	
0x043(67)	V_lim_L：限压保护值(OVP) ----OVP发生条件	
0x044(68)	V_lim_H：限压保护值	
0x045(69)	P_lim_L：限功率保护值(OPP) ----OPP发生条件	
0x046(70)	P_lim_H：限功率保护值	
0x047(71)	CV_lim_L：CP/CR/CV模式下限流值(limitI)-----当电流需求值大于该值就限制在该值	
0x048(72)	CV_lim_H：CP/CR/CV模式下限流值(limitI)-----不要让电流输出大于该值	
0x049(73)	Pro_time：保护时间设置
1-立即保护；10-1mS；20-2mS……150-15mS
拉载电流超过I_lim持续达Pro_time时间，将产生OCP报警，并停止拉载。
拉载功率超过P_lim持续达Pro_time时间，将产生OPP报警，并停止拉载。	
		
电压电流校准参数设置 : 
测量校准参数，16位整数，0—65535（以下所有相同）	
0x051(81)	VH_k：电压mod高档校准（默认值:39219）	
0x052(82)	VH_a： （默认值: 0）	
0x053(83)	VsH_k：电压sense采样高档校准（默认值: 0X ）	
0x054(84)	VsH_a：  （默认值: 0X ）	
0x055(85)	I1_k：I_Board_H高档校准（默认值: 57870）	
0x056(86)	I1_a： （默认值: 0）	
0x057(87)	I2_k：I_Board_L低档校准（默认值: 5787）	
0x058(88)	I2_a： （默认值: 0）	
0x059(89)	VL_k：电压采样低档校准（默认值: 3565）	
0x05A(90)	VL_a： （默认值: 0）	
0x05B(91)	VsL_k：电压sense采样低档校准（默认值: 0X ）	
0x05C(92)	VsL_a： （默认值: 0X ）	
0x05D(93)	It1_k：总电流高档I_SUM_Total_H校准（默认值: 55298）	
0x05E(94)	It1_a：（默认值: 0）	
0x05F(95)	It2_k：总电流低档I_SUM_Total_L校准（默认值: 5530）	
0x060(96)	It2_a： （默认值: 0）	
		
0x061(97)	CC_k：CC/CP/CR模式输出校准（默认值: 14764）	
0x062(98)	CC_a：（默认值: 1365）	
0x063(99)	CVH_k：CV模式高档校准（默认值: 0X ）	
0x064(100)	CVH_a：（默认值: 0X ）	
0x065(101)	CVL_k：CV模式低档校准（默认值: 0X ）	
0x066(102)	CVL_a：（默认值: 0X ）	
0x067(103)	CVHs_k：CV模式sense高档校准（默认值: 0X ）	
0x068(104)	CVHs_a：（默认值: 0X ）	
0x069(105)	CVLs_k：CV模式sense低档校准（默认值: 0X ）	
0x06A(106)	CVLs_a：（默认值: 0X ）	
		
软件CV慢速、中速、快速三档的PI控制参数设置	
0x06B(107)	s_k：软件CV慢速档PI控制的比例参数（默认值: 800）	
0x06C(108)	s_a：软件CV慢速档PI控制的积分参数（默认值: 5）	
0x06D(109)	m_k：软件CV中速档PI控制的比例参数（默认值: 1500）	
0x06E(110)	m_a：软件CV中速档PI控制的积分参数（默认值: 100）	
0x06F(111)	f_k：软件CV快速档PI控制的比例参数（默认值: 200）	
0x070(112)	f_a：软件CV快速档PI控制的积分参数（默认值: 5）	
0x071(113)	CV_mode：软件CV、硬件CV选择，默认0，软件CV
0：软件CV
1：硬件CV	
		
动态模式的T1/T2时间设置(所有模式共用该参数)	
0x080	T1_L_cc
动态CC过程1持续时间，低位，单位us	
0x081	T1_H_cc
动态CC过程1持续时间，高位，单位us	
0x082	T2_L_cc
动态CC过程2持续时间，低位，单位us	
0x083	T2_H_cc
动态CC过程2持续时间，高位，单位us	
0x084	T1_L_cv
动态CV过程1持续时间，低位，单位ms	
0x085	T1_H_cv
动态CV过程1持续时间，高位，单位ms	
0x086	T2_L_cv
动态CV过程2持续时间，低位，单位ms	
0x087	T2_H_cv
动态CV过程2持续时间，高位，单位ms	
0x088	T1_L_cp
动态CP过程1持续时间，低位，单位ms	
0x089	T1_H_cp
动态CP过程1持续时间，高位，单位ms	
0x08a	T2_L_cp
动态CP过程2持续时间，低位，单位ms	
0x08b	T2_H_cp
动态CP过程2持续时间，高位，单位ms	
0x08c	T1_L_cr
动态CR过程1持续时间，低位，单位ms	
0x08d	T1_H_cr
动态CR过程1持续时间，高位，单位ms	
0x08e	T2_L_cr
动态CR过程2持续时间，低位，单位ms	
0x08f	T2_H_cr
动态CR过程2持续时间，高位，单位ms	
		
动态测试的触发模式	
0x090	动态测试的触发模式选择Dyn_trig_mode，默认连续触发模式0x5a5a
0x5a5a：连续触发模式
在目标值A和B之间不停切换，目标值A的持续时间为T1，目标值B的持续时间为T2。
0xa5a5：脉冲触发模式
默认工作在目标值A，触发一次，切换到目标值B并持续时间T2，然后恢复到目标值A，忽略T1的设置。
0x5aa5：翻转触发模式
默认工作在目标值A，触发一次，切换到目标值B，触发一次，切换到目标值A，如此反复触发翻转，忽略T1/T2的设置。	
0x091	动态测试的触发源选择Dyn_trig_source，默认0x0000
0x0000，无触发（针对连续触发模式）
0x0001，手动触发
0x0002，总线触发
0x0003，外部触发	
0x092	动态测试的触发产生Dyn_trig_gen，默认0x0000
MCU通过写FPGA的此寄存器来告知FPGA产生了一次触发。MCU接受到触发信号后，通过写0x092为0xa5a5，2us后复位为0x0000，来告知FPGA产生了一次触发，FPGA按照规则完成相应的触发模式。	
		
电池放电测试模式，电池放电保护测试模式的参数设置	
0x0B1	BT_STOP:电池测试放电停止条件
0x0000电压截止；0x5a5a时间截止；0xa5a5容量截止	
0x0B2	保留	
0x0B3	VB_stop_L:放电截止电压，mV	
0x0B4	VB_stop_H	
0x0B5	TB_stop_L:放电截止时间, S	
0x0B6	TB_stop_H	
0x0B7	CB_stop_L:放电截止容量，mAh	
0x0B8	CB_stop_H	
0x0B9	VB_pro_L: 电池放电保护测试截止电压，mV	
0x0BA	VB_pro_H	
		
OCP测试模式的参数设置	
0x0C0	TOCP_Von_set_L
OCP测试的启动电压值的低位	
0x0C1	TOCP_Von_set_H
OCP测试的启动电压值的高位	
0x0C2	TOCP_Istart_set_L
OCP测试的初始电流值的低位	
0x0C3	TOCP_Istartl_set_H
OCP测试的初始电流值的高位	
0x0C4	TOCP_Icut_set_L
OCP测试的截止电流值的低位	
0x0C5	TOCP_Icut_set_H
OCP测试的截止电流值的高位	
0x0C6	TOCP_Istep_set
OCP测试的步进电流值	
0x0C7	TOCP_Tstep_set
OCP测试的步进时间值(单位us)	
0x0C8	TOCP_Vcut_set_L
OCP测试的保护电压值的低位	
0x0C9	TOCP_Vcut_set_H
OCP测试的保护电压值的高位	
0x0CA	TOCP_Imin_set_L
OCP测试的过电流最小值的低位	
0x0CB	TOCP_Imin_set_H
OCP测试的过电流最小值的高位	
0x0CC	TOCP_Imax_set_L
OCP测试的过电流最大值的低位	
0x0CD	TOCP_Imax_set_H
OCP测试的过电流最大值的高位	
		
0x0CE	TOCP_I [15:0]
OCP测试的当前目标值的低位，只读	
0x0CF	TOCP_I [31:16]
OCP测试的当前目标值的高位，只读	
		
OPP测试模式的参数设置	
0x0D0	TOPP_Von_set_L
OPP测试的启动电压值的低位	
0x0D1	TOPP_Von_set_H
OPP测试的启动电压值的高位	
0x0D2	TOPP_Pstart_set_L
OPP测试的初始功率值的低位	
0x0D3	TOPP_Pstart_set_H
OPP测试的初始功率值的高位	
0x0D4	TOPP_Pcut_set_L
OPP测试的截止功率值的低位	
0x0D5	TOPP_Pcut_set_H
OPP测试的截止功率值的高位	
0x0D6	TOPP_Pstep_set
OPP测试的步进功率值	
0x0D7	TOPP_Tstep_set
OPP测试的步进时间值	
0x0D8	TOPP_Vcut_set_L
OPP测试的保护电压值的低位	
0x0D9	TOPP_Vcut_set_H
OPP测试的保护电压值的高位	
0x0DA	TOPP_Pmin_set_L
OPP测试的过功率最小值的低位	
0x0DB	TOPP_Pmin_set_H
OPP测试的过功率最小值的高位	
0x0DC	TOPP_Pmax_set_L
OPP测试的过功率最大值的低位	
0x0DD	TOPP_Pmax_set_H
OPP测试的过功率最大值的高位	
		
0x0DE	TOPP_P [15:0]
OPP测试的当前目标值的低位，只读	
0x0DF	TOPP_P [31:16]
OPP测试的当前目标值的高位，只读	
序列编辑模式的参数设置	
0x0F1	Stepnum，1-1000，总步数	
0x0F2	Count，0-65535，总循环次数，0为无限循环	
0x0F3	Step，1-1000，步数序列号，从1开始，0存以上两个参数	
0x0F4	Mode，工作模式 [CC(0x5a5a)、CV(0xa5a5)、CP(0x5a00)、CR(0x005a)]	
0x0F5	Value_L:拉载值，定义参见静态模式	
0x0F6	Value_H	
0x0F7	Tstep_L:单步执行时间，us	
0x0F8	Tstep_H	
0x0F9	Repeat: 单步循环次数，1-65535	
0x0FA	Goto：小循环跳转目的地，1-999,无效0xFFFF	
0x0FB	Loops: 小循环次数，1-65535	
0x0FC	Save_step，平时0x0000，保存写一次0x5a5a	
		
		
以下为参数读取区域（只读）	
0x200	Fault_status：告警及故障状态，每0.5秒查询一次，内容如下:
暂时使用了低12位，从高到低依次为：
（VOP,TOPP_stop，TOCP_stop，BAT,SENSE,INV，TEMP_alarm, OVP, OCP, OCP_Imax, OPP, OPP_Pmax），其意义依次为电源欠压（VOP_POS\VOP_NEG）、OPP测试停止通知、OCP测试停止通知、电池测试停止通知、sense连接错误保护（固定为0）、反压告警、过温保护、过压告警、过流保护、最大电流超范围保护、过功率保护、最大功率超范围保护。
根据代码和故障的对应关系，在屏幕显示保护告警信息，同时锁定屏幕和按键，只有通过按下确定按钮才能清除告警信息，解除锁定。	
0x201	Workmod： [CC(0x5a5a)、CV(0xa5a5)、CP(0x5a00)、CR(0x005a)]	
0x202	Func：
[STA(0x5a00) --- 静态CC/CV/CP/CR模式
DYN(0xa500) --- 动态CC/CV/CP/CR模式
RIP(0x5aFF) ---序列编辑模式
RE(0x5aE0) --- 保留
FE(0x5aEF) --- 保留
BAT_N(0x5aB0) --- 电池放电测试
BAT_P(0x5aBF)] --- 电池放电保护测试
TOCP(0x5A3C)] --- OCP测试
TOPP(0x5AC3)] --- OPP测试	
0x203	SENSE功能选择，0x5a5a不使用SENSE功能；0xa5a5使能SENSE	
0x204	Model：机型，0xabcd
a：保留
b：功率等级，0-4kw；1-5kw；2-6kw；3-3kw；4-2KW；5-5.5KW；6-8KW；
c：电压等级，0-120V；1-150V；2-600V；3-1000V，4-1200V
d：电流等级，0-40A；1-100A；2-200A；3-400A；4-240；5-60；6-80；7-120；8-160；9-280；10-300；11-320；12-36012-450；13-480；14-600；15-800A;
例如
0x0130：DLL50-1000；(40A)
0x0122：DLL50-600；(200A)	
0x205	Worktype：0x5a5a-单机；0xa5a5-多机	
0x206	M_S：0x5a5a-主机；0xa5a5-从机	
0x207	Clear_alarm：0x5a5a-清除保护告警状态，其它值无效	
0x208	Run_status，每0.5秒查询一次。OUT键按下时立即查询。
0x0000：正处于系统自检状态
0xA5A5：正常停止状态
0x5A5A：正常工作状态
0xFxxx：处于保护停止输出状态，其低12位含义与0x200相同。	
0x209	Short：短路设置，0x5a5a-短路；0xa5a5-不短路	
0x20A	Von：启动电压	
0x20B	SR_slew：静态模式下，电流上升斜率(单位1mA/ms)	
0x20C	SF_slew：静态模式下，电流下降斜率(单位1mA/ms)	
0x20D	Display：波形显示开关，0x5a5a-不显示波形；0xa5a5-显示波形	
0x20E	T_scale：波形显示时间刻度，1-60000，每个像素点表示的时间（us）	
0x20F	Von Latch：0xa5a5-Latch OFF；0x5a5a-Latch ON	
0x210	Voff：停止电压，仅在Von Latch是OFF状态时有效	
0x211	Iset_L	
0x212	Iset_H	
0x213	Vset_L	
0x214	Vset_H	
0x215	Pset_L	
0x216	Pset_H	
0x217	Rset_L	
0x218	Rset_H	
0x219	Iset1_L	
0x21A	Iset1_H	
0x21B	Iset2_L	
0x21C	Iset2_H	
0x21D	Vset1_L	
0x21E	Vset1_H	
0x21F	Vset2_L	
0x220	Vset2_H	
0x221	Pset1_L	
0x222	Pset1_H	
0x223	Pset2_L	
0x224	Pset2_H	
0x225	Rset1_L	
0x226	Rset1_H	
0x227	Rset2_L	
0x228	Rset2_H	
		
0x22D	DR_slew：动态模式下，电流上升斜率(单位1mA/ms)	
0x22E	DF_slew：动态模式下，电流下降斜率(单位1mA/ms)	
0x22F	Vrange：电压测量档位，0x5a5a-高档；0xa5a5-低档	
0x230	CVspeed：CV模式速度调节，默认0x0003-慢速
0x0000-最快速；0x0001-快速；0x0002-慢速；0x0003-最慢速
软件CV：0x0001-快速；0x0002-中速；0x0003-慢速
硬件CV：0x0001-快速；0x0002-中速（实际慢速）；0x0003-慢速	
0x231	CV_slew：CV模式电压变化斜率(单位1mV/ms)	
0x233	用于设置CR(I=U/R)模式下的控制电压U的滤波时间：
参数值：滤波时间
N：2^N*5us
0：5us
1：10us
2：20us
3：40us
4：80us
5：160us
6：320us
7：640us
8：128us
其他：无效	
		
电子负载的限压、限流、限功率等保护参数设置	
0x241	I_lim_L：限流保护值	
0x242	I_lim_H：限流保护值	
0x243	V_lim_L：限压保护值	
0x244	V_lim_H：限压保护值	
0x245	P_lim_L：限功率保护值	
0x246	P_lim_H：限功率保护值	
0x247	CV_lim_L：CV模式下限流值	
0x248	CV_lim_H：CV模式下限流值	
0x249	Pro_time：保护时间设置
1-立即保护；10-1mS；20-2mS……150-15mS	
		
电压电流校准参数设置	
0x251	VH_k：测量校准参数，16位整数，0—65535（以下所有相同）	
0x252	VH_a ：电压高档校准	
0x253	VsH_k：电压sense采样高档校准	
0x254	VsH_a	
0x255	I1_k： I_Board_H高档校准	
0x256	I1_a	
0x257	I2_k： I_Board_L低档校准	
0x258	I2_a	
0x259	VL_k：电压采样低档校准	
0x25A	VL_a	
0x25B	VsL_k：电压sense采样低档校准	
0x25C	VsL_a	
0x25D	It1_k：总电流高档I_SUM_Total_H校准	
0x25E	It1_a	
0x25F	It2_k：总电流低档I_SUM_Total_L校准	
0x260	It2_a	
0x261	CC_k：输出校准参数	
0x262	CC_a：CC/CP/CR模式校准	
0x263	CVH_k：CV模式高档校准	
0x264	CVH_a	
0x265	CVL_k：CV模式低档校准	
0x266	CVL_a	
0x267	CVHs_k：CV模式sense高档校准	
0x268	CVHs_a	
0x269	CVLs_k：CV模式sense低档校准	
0x26A	CVLs_a	
		
软件CV慢速、中速、快速三档的PI控制参数设置	
0x26B	s_k：软件CV慢速档PI控制的比例参数	
0x26C	s_a：软件CV慢速档PI控制的积分参数	
0x26D	m_k：软件CV中速档PI控制的比例参数	
0x26E	m_a：软件CV中速档PI控制的积分参数	
0x26F	f_k：软件CV快速档PI控制的比例参数	
0x270	f_a：软件CV快速档PI控制的积分参数	
0x271	CV_mode：软件CV、硬件CV选择，默认0，软件CV
0：软件CV
1：硬件CV	
		
动态模式的T1/T2时间设置	
0x280	T1_L_cc	
0x281	T1_H_cc	
0x282	T2_L_cc	
0x283	T2_H_cc	
0x284	T1_L_cv	
0x285	T1_H_cv	
0x286	T2_L_cv	
0x287	T2_H_cv	
0x288	T1_L_cp	
0x289	T1_H_cp	
0x28a	T2_L_cp	
0x28b	T2_H_cp	
0x28c	T1_L_cr	
0x28d	T1_H_cr	
0x28e	T2_L_cr	
0x28f	T2_H_cr	
		
动态测试的触发模式	
0x290	动态测试的触发模式选择Dyn_trig_mode，默认连续触发模式0x5a5a
0x5a5a：连续触发模式
在目标值A和B之间不停切换，目标值A的持续时间为T1，目标值B的持续时间为T2。
0xa5a5：脉冲触发模式
默认工作在目标值A，触发一次，切换到目标值B并持续时间T2，然后恢复到目标值A，忽略T1的设置。
0x5aa5：翻转触发模式
默认工作在目标值A，触发一次，切换到目标值B，触发一次，切换到目标值A，如此反复触发翻转，忽略T1/T2的设置。	
0x291	动态测试的触发源选择Dyn_trig_source，默认0x0000
0x0000，无触发（针对连续触发模式）
0x0001，手动触发
0x0002，总线触发
0x0003，外部触发	
0x292	动态测试的触发产生Dyn_trig_gen，默认0x0000
MCU通过写FPGA的此寄存器来告知FPGA产生了一次触发。MCU接受到触发信号后，通过写0x092为0xa5a5，2us后复位为0x0000，来告知FPGA产生了一次触发，FPGA按照规则完成相应的触发模式。	
		
电池放电测试模式，电池放电保护测试模式的参数设置	
0x2B1	BT_STOP:电池测试放电停止条件
0x0000电压截止；0x5a5a时间截止；0xa5a5容量截止	
0x2B2	保留	
0x2B3	VB_stop_L:放电截止电压，mV	
0x2B4	VB_stop_H	
0x2B5	TB_stop_L:放电截止时间, S	
0x2B6	TB_stop_H	
0x2B7	CB_stop_L:放电截止容量，mAh	
0x2B8	CB_stop_H	
0x2B9	VB_pro_L: 电池放电保护测试截止电压，mV	
0x2BA	VB_stop_H	
		
OCP测试模式的参数设置	
0x2C0	TOCP_Von_set_L
OCP测试的启动电压值的低位	
0x2C1	TOCP_Von_set_H
OCP测试的启动电压值的高位	
0x2C2	TOCP_Istart_set_L
OCP测试的初始电流值的低位	
0x2C3	TOCP_Istart_set_H
OCP测试的初始电流值的高位	
0x2C4	TOCP_Icut_set_L
OCP测试的截止电流值的低位	
0x2C5	TOCP_Icut_set_H
OCP测试的截止电流值的高位	
0x2C6	TOCP_Istep_set
OCP测试的步进电流值	
0x2C7	TOCP_Tstep_set
OCP测试的步进时间值	
0x2C8	TOCP_Vcut_set_L
OCP测试的保护电压值的低位	
0x2C9	TOCP_Vcut_set_H
OCP测试的保护电压值的高位	
0x2CA	TOCP_Imin_set_L
OCP测试的过电流最小值的低位	
0x2CB	TOCP_Imin_set_H
OCP测试的过电流最小值的高位	
0x2CC	TOCP_Imax_set_L
OCP测试的过电流最大值的低位	
0x2CD	TOCP_Imax_set_H
OCP测试的过电流最大值的高位	
0x2CF	TOCP_result
0：OCP ready
1：OCP测试结束，测试设备未发生OCP
2：OCP测试结束，欠OCP
4：OCP测试结束，过OCP
8：OCP测试通过	
		
OPP测试模式的参数设置	
0x2D0	TOPP_Von_set_L
OPP测试的启动电压值的低位	
0x2D1	TOPP_Von_set_H
OPP测试的启动电压值的高位	
0x2D2	TOPP_Pstart_set_L
OPP测试的初始功率值的低位	
0x2D3	TOPP_Pstart_set_H
OPP测试的初始功率值的高位	
0x2D4	TOPP_Pcut_set_L
OPP测试的截止功率值的低位	
0x2D5	TOPP_Pcut_set_H
OPP测试的截止功率值的高位	
0x2D6	TOPP_Pstep_set
OPP测试的步进功率值	
0x2D7	TOPP_Tstep_set
OPP测试的步进时间值	
0x2D8	TOPP_Vcut_set_L
OPP测试的保护电压值的低位	
0x2D9	TOPP_Vcut_set_H
OPP测试的保护电压值的高位	
0x2DA	TOPP_Pmin_set_L
OCP测试的过功率最小值的低位	
0x2DB	TOPP_Pmin_set_H
OPP测试的过功率最小值的高位	
0x2DC	TOPP_Pmax_set_L
OPP测试的过功率最大值的低位	
0x2DD	TOPP_Pmax_set_H
OPP测试的过功率最大值的高位	
0x2DF	TOPP_result
OPP测试结果
0：OPP ready
1：OPP测试结束，测试设备未发生OPP
2：OPP测试结束，欠OPP
4：OPP测试结束，过OPP
8：OPP测试通过	
		
序列编辑模式的参数设置	
0x2F1	Stepnum，1-1000，总步数	
0x2F2	Count，0-65535，总循环次数，0为无限循环	
0x2F3		
0x2F4	Mode，工作模式	
0x2F5	Value_L:拉载值，定义参见静态模式	
0x2F6	Value_H	
0x2F7	Tstep_L:单步执行时间，us	
0x2F8	Tstep_H	
0x2F9	Repeat: 单步循环次数，1-65535	
0x2FA	Goto：小循环跳转目的地，1-999	
0x2FB	Loops: 小循环次数，1-65535	
0x2FC	Repeat_now，当前单步循环数	
0x2FD	Count_now，当前总循环数	
0x2FE	Step_now，当前step数	
0x2FF	Loops_now: 当前小循环数	
		
采样电流显示值	
0x301	I_Board_L低档电流显示值，低位	
0x302	I_Board_L低档电流显示值，高位	
0x303	I_Board_H高档电流显示值，低位	
0x304	I_Board_H高档电流显示值，高位	
0x305	总电流低档I_SUM_Total_L采样电流显示值，低位	
0x306	总电流低档I_SUM_Total_L采样电流显示值，高位	
0x307	总电流高档I_SUM_Total_H采样电流显示值，低位	
0x308	总电流高档I_SUM_Total_H采样电流显示值，高位	
0x309	I_Board_unit采样电流显示值，低位	
0x30A	I_Board_unit采样电流显示值，高位	
0x30B	I_Sum_unit采样电流显示值，低位	
0x30C	I_Sum_unit采样电流显示值，高位	
		
0x30E	实时功率值	
0x30F	实时电阻值	
		
电压电流显示值	
0x311	V_L：电压测量值，低位（包括高低档，有无sensesense端或非sense端，8*4096次AD采样电压的平均值，其值有正有负）	
0x312	V_H：电压测量值，高位（主界面和校准页面显示，有正负sense端或非sense端，8*4096次AD采样电压的平均值，其值有正有负）	
0x313	I_L：电流测量值，低位（包括两种采样方式8*4096次AD采样电流的平均值，其值有正有负）	
0x314	I_H：电流测量值，高位（主界面和校准页面显示，有正负8*4096次AD采样电流的平均值，其值有正有负）	
		
电池放电测试模式，电池放电保护测试模式的测试信息	
0x3B1	Vopen_L：电池开路电压，低位mV	
0x3B2	Vopen_H：电池开路电压，高位mV	
0x3B3	Ri_L：电池内阻测量值，低位mΩ	
0x3B4	Ri_H：电池内阻测量值，高位mΩ	
0x3B5	TB_L：电池放电时间，低位S	
0x3B6	TB_H：电池放电时间，高位S	
0x3B7	Cap1_L：电池容量，低位mAh	
0x3B8	Cap1_H：电池容量，高位mAh	
0x3B9	Cap2_L：电池容量，低位mWh	
0x3BA	Cap2_H：电池容量，高位mWh	
0x3BB	Tpro_L：保护时间，低位uS	
0x3BC	Tpro_H：保护时间，高位uS	
		
温度采集	
0x3C1	temperature_0	
0x3C2	temperature_1	
0x3C3	temperature_2	
0x3C4	temperature_3	
0x3C5	temperature_4	
0x3C6	temperature_5	
0x3C7	temperature_6	
0x3C8	temperature_7	
	
0x3D0		
模块电流值	
0x3D1	SUM_UNIT_0	
0x3D2	SUM_UNIT_1	
0x3D3	SUM_UNIT_2	
0x3D4	SUM_UNIT_3	
0x3D5	SUM_UNIT_4	
0x3D6	SUM_UNIT_5	
0x3D7	SUM_UNIT_6	
0x3D8	SUM_UNIT_7	
		
0x3E1	BOARD_UNIT_0	
0x3E2	BOARD_UNIT_1	
0x3E3	BOARD_UNIT_2	
0x3E4	BOARD_UNIT_3	
0x3E5	BOARD_UNIT_4	
0x3E6	BOARD_UNIT_5	
0x3E7	BOARD_UNIT_6	
0x3E8	BOARD_UNIT_7	
		
FPGA版本信息	
0X3FD	版本1：两个ASCII码字符	
0X3FE	版本2：两个ASCII码字符	
0X3FF	版本号：
Bit[31:24]: 51
Bit[23:16]:大版本号1
Bit[15:8]: 小版本号01
Bit[7:0]：辅助版本号（ASCII码，字母）A	

 

日期	版本	文档更新记录
20190306	1.0	初始版本
以《5KW电子负载FPGA接口定义说明文档》为蓝本做了如下修改：
	增加0x040 num_paral用于并机数设置
	增加0x071（0x271）CV_mode，用于硬件CV/软件CV选择切换
	增加0x06B~0x070（0x26B~0x270）s_k/s_a、m_k/m_a、f_k/f_a，用于软件CV慢速、中速、快速三档PI控制的参数设置
	修改0x030 CVspeed CV调节速度的档位定义
	修改采样电流的校准寄存器
1.	修改0x055~0x056（0x255~0x256）I1_k、I1_a用于单层采样电流I_SUM_A的校准
2.	修改0x057~0x058（0x257~0x258）I2_k、I2_a用于单层采样电流I_SUM_B的校准
3.	修改0x05D~0x05E（0x25D~0x25E）It1_k、It1_a用于总采样电流低档I_SUM_Total_L的校准
4.	增加0x05F~0x060（0x25F~0x260）It2_k、It2_a用于总采样电流高档I_SUM_Total_H的校准
	修改采样电流的显示寄存器0x301~0x30C
1.	0x301~0x302用于单层采样电流I_SUM_A的显示
2.	0x303~0x304用于单层采样电流I_SUM_B的显示
3.	0x305~0x306用于单层采样电流低档I_SUM_Total_L的显示
4.	0x307~0x308用于单层采样电流高档I_SUM_Total_H的显示
	修改电压电流功率显示寄存器0x311~0x31A
20190417	1.0		删除动态模式过程1/2的持续时间设置寄存器0x029~0x02C，0x229~0x22C
	增加寄存器，动态CC/CV/CP/CR四个模式的时间设置用不同的寄存器控制
1.	增加动态CC模式过程1/2的持续时间设置寄存器0x080~0x083,0x280~0x283
2.	增加动态CV模式过程1/2的持续时间设置寄存器0x084~0x087,0x284~0x287
3.	增加动态CP模式过程1/2的持续时间设置寄存器0x088~0x08B,0x288~0x28B
4.	增加动态CR模式过程1/2的持续时间设置寄存器0x08C~0x08F,0x28C~0x28F
20190505	1.0		增加动态测试触发模式的控制寄存器
1.	动态测试的触发模式选择寄存器Dyn_trig_mode，默认0x5a5a
0x090/0x290
2.	动态测试的触发源寄存器dyn_trig_source，默认0x0000
0x091/0x291
3.	动态测试的触发产生dyn_trig_gen，默认0x0000
0x092/0x292
20190510	1.0		增加OCP/OPP测试的控制寄存器
1.	OCP测试参数0x0C0~0CD/0x2C0~0x2CD
2.	0x002/0x202 增加OCP测试功能16’h5A3C
3.	0x002/0x202 增加OPP测试功能16’h5AC3
20190516	1.0		增加OPP测试的控制寄存器
1.	OPP测试参数0x0D0~0DD/0x2D0~0x2DD
2.	OCP/OPP测试结果0x2CF/0x2DF
3.	更新告警及故障状态0x200，增加OPP/OCP告警状态
20190614	1.0		增加OCP/OPP测试的结果显示寄存器
0x0CE/0x0CF用于显示OCP/OPP测试中的当前目标值
20190919	1.0		增加CR控制电压的滤波时间寄存器
0x033/0x233用于设置CR(I=U/R)模式控制电压U的滤波时间
20200616	1.0		支持450A机型
20240914	1.0		JN807
	1.1		增加0X03C1~0X03C8温度采集code码；
	增加0X03D1~0X03D8 SUM_UNIT；
	增加0X03E1~0X03E8 BOARD_UNIT；
	I_Board_L低档校准和I_Board_H低档校准参数交换地址；
	I_Sum_L低档校准和I_Sum_H低档校准参数交换地址；
20241118	1.2		修改版本号寄存器
20241126	1.3		修改List模式和RIP模式寄存器值

 
 
