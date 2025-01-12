`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             main_ctrl_pull_load.v
// Create Date:           2025/01/07 16:08:30
// Version:               V1.0
// PATH:                  srcs\rtl\main_ctrl_pull_load\main_ctrl_pull_load.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module main_ctrl_pull_load #(
    parameter                       SIMULATION         = 0     ,
    parameter                       CALCULATE_WIDTH    = 24    ,
    parameter                       AXI_REG_WIDTH      = 24    , 
    parameter                       PRECHARGE_TIME     = 38_000,//38MS预充电时间

    parameter                       WORKMOD_CC         = 16'h5a5a,
    parameter                       WORKMOD_CV         = 16'ha5a5,
    parameter                       WORKMOD_CP         = 16'h5a00,
    parameter                       WORKMOD_CR         = 16'h005a,
    
    parameter                       FUNC_STA           = 16'h5a00,
    parameter                       FUNC_DYN           = 16'ha500,
    parameter                       FUNC_LIST          = 16'h5aFF,
    parameter                       FUNC_TOCP          = 16'h5a3C,
    parameter                       FUNC_TOPP          = 16'h5AC3
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,

    input  wire                     RUN_flag_ON_i       ,
    input  wire                     Von_Latch_ON_i      ,
    input  wire        [  15: 0]    Workmod_i           ,
    input  wire        [  15: 0]    Func_i              ,
    output wire                     global_1us_flag_o   ,
    output reg         [  15: 0]    current_workmod_o   ,

    input  wire        [  15: 0]    Von_i               ,//启动电压
    input  wire        [  15: 0]    Voff_i              ,//截至电压
    input  wire        [  31: 0]    Iset_i              ,
    input  wire        [  31: 0]    Vset_i              ,
    input  wire        [  31: 0]    Pset_i              ,
    input  wire        [  31: 0]    Rset_i              ,
    input  wire        [  31: 0]    Iset1_i             ,
    input  wire        [  31: 0]    Iset2_i             ,
    input  wire        [  31: 0]    Vset1_i             ,
    input  wire        [  31: 0]    Vset2_i             ,
    input  wire        [  31: 0]    Pset1_i             ,
    input  wire        [  31: 0]    Pset2_i             ,
    input  wire        [  31: 0]    Rset1_i             ,
    input  wire        [  31: 0]    Rset2_i             ,
    input  wire        [AXI_REG_WIDTH-1: 0]SR_slew_i    ,//电流上升斜率单位1mA/ms 需要保护
    input  wire        [AXI_REG_WIDTH-1: 0]SF_slew_i    ,//电流下降斜率单位1mA/ms 需要保护 
    input  wire        [AXI_REG_WIDTH-1: 0]DR_slew_i    ,//电流上升斜率单位1mA/ms 需要保护
    input  wire        [AXI_REG_WIDTH-1: 0]DF_slew_i    ,//电流下降斜率单位1mA/ms 需要保护 
    input  wire        [  31: 0]    I_limit_i           ,
    input  wire        [  31: 0]    V_limit_i           ,
    input  wire        [  31: 0]    P_limit_i           ,
    input  wire        [  31: 0]    CV_limit_i          ,
    input  wire        [  31: 0]    Pro_time_i          ,
    input  wire        [  31: 0]    T1_i                ,
    input  wire        [  31: 0]    T2_i                ,
    //拉载                             
    output reg                      pull_on_o           ,
    output reg                      pull_precharge_en_o ,
    output reg         [  31: 0]    pull_target_o       ,
    output reg         [  31: 0]    pull_initI_o        ,
    output reg         [  31: 0]    pull_limitI_o       ,
    output reg         [AXI_REG_WIDTH-1: 0]pull_Rslew_o ,
    output reg         [AXI_REG_WIDTH-1: 0]pull_Fslew_o ,
    input  wire                     pull_on_doing_i     ,
    //DYN
    input  wire        [  15: 0]    Dyn_trig_mode_i     ,
    input  wire        [  15: 0]    Dyn_trig_source_i   ,
    input  wire        [  15: 0]    Dyn_trig_gen_i      ,
    //list参数
    input  wire        [  15: 0]    Step_i              ,//步数序列号，从1开始，0存以上两个参数
    input  wire        [  15: 0]    Mode_i              ,//工作模式 [CC(0x5a5a)、CV(0xa5a5)、CP(0x5a00)、CR(0x005a)]
    input  wire        [  31: 0]    Value_i             ,//拉载值
    input  wire        [  31: 0]    Tstep_i             ,//uS//单步执行时间
    input  wire        [  15: 0]    Repeat_i            ,
    input  wire        [  15: 0]    Goto_i              ,//小循环跳转目的地,1-999
    input  wire        [  15: 0]    Loops_i             ,//小循环次数,1-65535

    input  wire                     Save_step_ON_i      ,//锁存参数
    //TOCP
    input  wire        [  31: 0]    TOCP_Von_set_i      ,//OCP测试的启动电压值
    input  wire        [  31: 0]    TOCP_Istart_set_i   ,//OCP测试的初始电流值
    input  wire        [  31: 0]    TOCP_Icut_set_i     ,//OCP测试的截止电流值
    input  wire        [  31: 0]    TOCP_Istep_set_i    ,//OCP测试的步进电流值	
    input  wire        [  31: 0]    TOCP_Tstep_set_i    ,//OCP测试的步进时间值us
    input  wire        [  31: 0]    TOCP_Vcut_set_i     ,//OCP测试的保护电压值
    input  wire        [  31: 0]    TOCP_Imin_set_i     ,//OCP测试的过电流最小值
    input  wire        [  31: 0]    TOCP_Imax_set_i     ,//OCP测试的过电流最大值

    output reg                      TOCP_pass_o         ,
    output reg                      TOCP_done_o         ,
    output reg         [   3: 0]    TOCP_status_o       ,
    output reg         [  31: 0]    TOCP_current_target_o,
    //TOPP
    input  wire        [  31: 0]    TOPP_Von_set_i      ,//OCP测试的启动电压值
    input  wire        [  31: 0]    TOPP_Pstart_set_i   ,//OCP测试的初始功率值
    input  wire        [  31: 0]    TOPP_Pcut_set_i     ,//OCP测试的截止功率值
    input  wire        [  31: 0]    TOPP_Pstep_set_i    ,//OCP测试的步进功率值	
    input  wire        [  31: 0]    TOPP_Tstep_set_i    ,//OCP测试的步进时间值us
    input  wire        [  31: 0]    TOPP_Vcut_set_i     ,//OCP测试的保护电压值
    input  wire        [  31: 0]    TOPP_Pmin_set_i     ,//OCP测试的过功率最小值
    input  wire        [  31: 0]    TOPP_Pmax_set_i     ,//OCP测试的过功率最大值

    output reg                      TOPP_pass_o         ,
    output reg                      TOPP_done_o         ,
    output reg         [   3: 0]    TOPP_status_o       ,
    output reg         [  31: 0]    TOPP_current_target_o,
    //实时参数
    input  wire        [CALCULATE_WIDTH-1: 0]U_i        ,//mV    
    input  wire        [CALCULATE_WIDTH-1: 0]I_i        ,//mV    
    input  wire        [CALCULATE_WIDTH-1: 0]U_abs_i    ,//mV    
    input  wire        [CALCULATE_WIDTH-1: 0]I_abs_i    ,//mV    

    input  wire        [   1: 0]    i_BAT_err            //电池错误 b0:I反向 b1:U反向
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                      TIME_1US           = 100   ;
    //全局变量
    wire                            pull_precharge_cnt_done  ;
    wire                            RUN_flag_ON_pulse   ;
    reg                [   7: 0]    cnt_ns='d0          ;
    reg                [  23: 0]    pull_precharge_cnt  ;
    reg                             first_precharge_en  ;
    reg                             RUN_flag_ON_r1      ;
    //动态
    reg                             T1_stage_valid      ;
    reg                [  15: 0]    dyn_cnt_us          ;
    //list参数
    reg                [   9: 0]    list_buff_rd_addr   ;//步数计数器
    wire               [  15: 0]    Stepnum             ;//1-1000，总步数
    wire               [  15: 0]    Count               ;//总循环次数，0为无限循环
    wire               [  15: 0]    cur_Mode_list       ;//工作模式 [CC(0x5a5a)、CV(0xa5a5)、CP(0x5a00)、CR(0x005a)]
    wire               [  31: 0]    cur_Value_list      ;//拉载值
    wire               [  31: 0]    cur_Tstep           ;//uS//单步执行时间
    wire               [  15: 0]    cur_Repeat          ;
    wire               [  15: 0]    cur_Goto            ;//小循环跳转目的地,1-999
    wire               [  15: 0]    cur_Loops           ;//小循环次数,1-65535

    reg                [  15: 0]    Repeat_cache        ;
    reg                [  15: 0]    Loops_cache         ;
    reg                [  15: 0]    Goto_cache          ;

    reg                [  15: 0]    Stepnum_cnt         ;//步数计数器
    reg                [  15: 0]    Count_cnt           ;//总循环次数计数器
    reg                [  31: 0]    Tstep_cnt           ;//us计数器
    reg                [  15: 0]    Repeat_cnt          ;//单步循环次数计数器
    reg                [  15: 0]    Loops_cnt           ;//小循环次数,1-65535，跳一次+1

    wire                            Stepnum_done        ;//步数计数完成
    wire                            Count_done          ;//总循环完成
    wire                            Tstep_done          ;//us计数器
    wire                            Repeat_done         ;//单步循环完成
    wire                            loops_done          ;//小循环完成
    //
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 打拍
//---------------------------------------------------------------------
    assign                          RUN_flag_ON_pulse  = ~RUN_flag_ON_i & RUN_flag_ON_r1;

always@(posedge sys_clk_i)begin
    RUN_flag_ON_r1 <= RUN_flag_ON_i;
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计数器
//---------------------------------------------------------------------
generate
    if (SIMULATION) begin
    assign                          global_1us_flag_o  = (cnt_ns == 10 - 1);
    end
    else begin
    assign                          global_1us_flag_o  = (cnt_ns == TIME_1US - 1);
    end
endgenerate

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        cnt_ns <= 'd0;
    end
    else if (global_1us_flag_o) begin
        cnt_ns <= 'd0;
    end
    else begin
        cnt_ns <= cnt_ns + 1'b1;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 当前工作模式
//---------------------------------------------------------------------
always@(posedge sys_clk_i)begin
    case (Func_i)
        FUNC_LIST: current_workmod_o <= cur_Mode_list;
        FUNC_TOCP: current_workmod_o <= WORKMOD_CC;                 //TOCP本质是动态CC
        FUNC_TOPP: current_workmod_o <= WORKMOD_CP;                 //TOCP本质是动态CP
        default: current_workmod_o <= Workmod_i;
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 参数
//--------------------------------------------------------------------
always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        pull_target_o       <= 1'd1;
        pull_initI_o        <= 1'd1;                                //初始电流值mA
        pull_limitI_o       <= 1'd1;                                //限制电流mA
        pull_Rslew_o        <= 1'd1;                                //电流上升斜率单位1mA/ms 需要保护
        pull_Fslew_o        <= 1'd1;                                //电流下降斜率单位1mA/ms 需要保护
    end
    else case (Func_i)
        FUNC_STA: begin
            pull_Rslew_o <= SR_slew_i;                              //电流上升斜率单位1mA/ms 需要保护
            pull_Fslew_o <= SF_slew_i;                              //电流下降斜率单位1mA/ms 需要保护

            case (current_workmod_o)
                WORKMOD_CC: begin                                   //静态CC
                    pull_target_o <= Iset_i;
                    pull_initI_o <= I_abs_i;                        //初始电流值mA
                    pull_limitI_o <= 1000_000;                      //限制电流mA
                end
                WORKMOD_CV: begin                                   //静态CV
                    pull_target_o <= Vset_i;
                    pull_initI_o <= I_abs_i;                        //初始电流值mA
                    pull_limitI_o <= CV_limit_i;                    //限制电流mA
                end
                WORKMOD_CP: begin                                   //静态CP
                    pull_target_o <= Pset_i;
                    pull_initI_o <= I_abs_i;                        //初始电流值mA
                    pull_limitI_o <= 1000_000;                      //限制电流mA
                end
                WORKMOD_CR: begin                                   //静态CR
                    pull_target_o <= Rset_i;
                    pull_initI_o <= I_abs_i;                        //初始电流值mA
                    pull_limitI_o <= 1000_000;                      //限制电流mA
                end
                default: begin
                    
                end
            endcase
        end
        FUNC_DYN: begin
            pull_Rslew_o <= DR_slew_i;                              //电流上升斜率单位1mA/ms 需要保护
            pull_Fslew_o <= DF_slew_i;                              //电流下降斜率单位1mA/ms 需要保护

            case (current_workmod_o)
                WORKMOD_CC: begin                                   //动态CC
                    pull_target_o <= (T1_stage_valid) ? Iset1_i : Iset2_i;
                    pull_initI_o <= I_abs_i;                        //初始电流值mA
                    pull_limitI_o <= 1000_000;                      //限制电流mA
                end
                WORKMOD_CV: begin                                   //动态CV
                    pull_target_o <= (T1_stage_valid) ? Vset1_i : Vset2_i;
                    pull_initI_o <= I_abs_i;                        //初始电流值mA
                    pull_limitI_o <= CV_limit_i;                    //限制电流mA
                end
                WORKMOD_CP: begin                                   //动态CP
                    pull_target_o <= (T1_stage_valid) ? Pset1_i : Pset2_i;
                    pull_initI_o <= I_abs_i;                        //初始电流值mA
                    pull_limitI_o <= 1000_000;                      //限制电流mA
                end
                WORKMOD_CR: begin                                   //动态CR               
                    pull_target_o <= (T1_stage_valid) ? Rset1_i : Rset2_i;
                    pull_initI_o <= I_abs_i;                        //初始电流值mA
                    pull_limitI_o <= 1000_000;                      //限制电流mA
                end
                default:begin
                    
                end
            endcase
        end
        FUNC_LIST: begin                                            // LIST模式
            case (current_workmod_o)
                WORKMOD_CC,
                WORKMOD_CP,
                WORKMOD_CR: begin
                    pull_target_o <= cur_Value_list;
                    pull_initI_o <= I_abs_i;                        //初始电流值mA
                    pull_limitI_o <= 1000_000;                      //限制电流mA
                end
                WORKMOD_CV: begin
                    pull_target_o <= cur_Value_list;
                    pull_initI_o <= I_abs_i;                        //初始电流值mA
                    pull_limitI_o <= CV_limit_i;                    //限制电流mA
                end
                default: begin
                    
                end
            endcase
        end
        FUNC_TOCP: begin
            pull_target_o <= TOCP_current_target_o;
            pull_initI_o <= I_abs_i;                                //初始电流值mA
            pull_limitI_o <= 1000_000;                              //限制电流mA
        end
        FUNC_TOPP: begin
            pull_target_o <= TOPP_current_target_o;
            pull_initI_o <= I_abs_i;                                //初始电流值mA
            pull_limitI_o <= 1000_000;                              //限制电流mA
        end
        default: begin

        end
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 拉载控制
//---------------------------------------------------------------------
generate
    if (SIMULATION) begin
    assign                          pull_precharge_cnt_done= (pull_precharge_cnt == 10 - 1);//10us
    end
    else begin
    assign                          pull_precharge_cnt_done= (pull_precharge_cnt == PRECHARGE_TIME - 1);//1ms
    end
endgenerate

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        pull_on_o           <= 'd0;                                 //回到初值
        pull_precharge_en_o <= 'd0;
        pull_precharge_cnt  <= 'd0;
        first_precharge_en  <= 'd1;
    end
    else case (Func_i)
        FUNC_STA,
        FUNC_DYN,
        FUNC_LIST: begin
            case (current_workmod_o)
                WORKMOD_CC,
                WORKMOD_CP,
                WORKMOD_CR: begin                                   //动态静态CC,CP,CR一样的拉载控制逻辑
                    if (RUN_flag_ON_i) begin

                        if (first_precharge_en) begin
                            if (U_i < Von_i) begin
                                pull_on_o           <= 'd0;         //on的时候，先等电压满足条件，然后启动预充电
                                pull_precharge_en_o <= 'd0;
                                pull_precharge_cnt  <= 'd0;
                                first_precharge_en  <= 'd1;
                            end
                            else begin
                                pull_on_o           <= 'd1;
                                if (pull_precharge_cnt_done) begin
                                    pull_precharge_en_o <= 'd0;
                                    pull_precharge_cnt  <= 'd0;
                                    first_precharge_en  <= 'd0;
                                end
                                else if (global_1us_flag_o) begin
                                    pull_precharge_en_o <= 'd1;
                                    pull_precharge_cnt  <= pull_precharge_cnt + 'd1;
                                    first_precharge_en  <= 'd1;
                                end
                                else begin
                                    pull_precharge_en_o <= 'd1;
                                    pull_precharge_cnt  <= pull_precharge_cnt;
                                    first_precharge_en  <= 'd1;
                                end
                            end
                        end
                        else begin
                            if (Von_Latch_ON_i) begin
                                pull_on_o           <= 'd1;         //latch on一直拉载
                                pull_precharge_en_o <= 'd0;
                                pull_precharge_cnt  <= 'd0;
                                first_precharge_en  <= 'd0;
                            end
                            else begin
                                if (U_i < Voff_i) begin
                                    pull_on_o           <= 'd1;     //拉低，返回预充电状态
                                    pull_precharge_en_o <= 'd1;
                                    pull_precharge_cnt  <= 'd0;
                                    first_precharge_en  <= 'd0;
                                end
                                else if (U_i > Von_i) begin
                                    pull_on_o           <= 'd1;     //拉载到目标值
                                    pull_precharge_en_o <= 'd0;
                                    pull_precharge_cnt  <= 'd0;
                                    first_precharge_en  <= 'd0;
                                end
                            end
                        end

                    end
                    else begin
                        pull_on_o           <= 'd0;                 //关机回到初值
                        pull_precharge_en_o <= 'd0;
                        pull_precharge_cnt  <= 'd0;
                        first_precharge_en  <= 'd1;
                    end
                end
                WORKMOD_CV: begin                                   //动态静态CV一样的拉载控制逻辑
                    pull_on_o <= RUN_flag_ON_i;
                    pull_precharge_en_o <= 'd0;                     //CV模式下不需要预充电,无视
                    pull_precharge_cnt  <= 'd0;
                    first_precharge_en  <= 'd1;
                end
                default: begin
                        pull_on_o           <= 'd0;                 //关机回到初值
                        pull_precharge_en_o <= 'd0;
                        pull_precharge_cnt  <= 'd0;
                        first_precharge_en  <= 'd1;
                    end
            endcase
        end
        FUNC_TOCP: begin
            if (RUN_flag_ON_i) begin

                if (first_precharge_en) begin
                    if (U_i < TOCP_Von_set_i) begin
                        pull_on_o           <= 'd0;                 //on的时候，先等电压满足条件，然后启动预充电
                        pull_precharge_en_o <= 'd0;
                        pull_precharge_cnt  <= 'd0;
                        first_precharge_en  <= 'd1;
                    end
                    else begin
                        pull_on_o           <= 'd1;
                        if (pull_precharge_cnt_done) begin
                            pull_precharge_en_o <= 'd0;
                            pull_precharge_cnt  <= 'd0;
                            first_precharge_en  <= 'd0;
                        end
                        else if (global_1us_flag_o) begin
                            pull_precharge_en_o <= 'd1;
                            pull_precharge_cnt  <= pull_precharge_cnt + 'd1;
                            first_precharge_en  <= 'd1;
                        end
                        else begin
                            pull_precharge_en_o <= 'd1;
                            pull_precharge_cnt  <= pull_precharge_cnt;
                            first_precharge_en  <= 'd1;
                        end
                    end
                end
                else begin
                    pull_on_o           <= 'd1;                     //TOCP不管latch on/off，一直当on一直拉载
                    pull_precharge_en_o <= 'd0;
                    pull_precharge_cnt  <= 'd0;
                    first_precharge_en  <= 'd0;
                end

            end
            else begin
                pull_on_o           <= 'd0;                         //关机回到初值
                pull_precharge_en_o <= 'd0;
                pull_precharge_cnt  <= 'd0;
                first_precharge_en  <= 'd1;
            end
        end
        default: begin
            
        end
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 动态
//---------------------------------------------------------------------
    localparam                      CONTINUOUS_TRIG    = 16'h5a5a;
    localparam                      PULSE_TRIG         = 16'ha5a5;
    localparam                      FLIP_TRIG          = 16'h5aa5;

    reg                [   7: 0]    Dyn_trig_gen_cnt  ='d0;
    reg                             Dyn_trig_gen_ON   ='d0;

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        Dyn_trig_gen_cnt <= 'd0;
        Dyn_trig_gen_ON  <= 'd0;
    end
    else if (Dyn_trig_gen_cnt >= 'd1) begin
        if (Dyn_trig_gen_cnt == 'd3 && global_1us_flag_o) begin
            Dyn_trig_gen_cnt <= 'd0;                                //持续2us
            Dyn_trig_gen_ON  <= 'd0;
        end
        else if (global_1us_flag_o) begin
            Dyn_trig_gen_cnt <= Dyn_trig_gen_cnt + 'd1;
            Dyn_trig_gen_ON  <= 'd1;
        end
        else begin
            Dyn_trig_gen_cnt <= Dyn_trig_gen_cnt;
            Dyn_trig_gen_ON  <= Dyn_trig_gen_ON;
        end
    end
    else if (Dyn_trig_gen_i == 16'ha5a5) begin
        Dyn_trig_gen_cnt <= 'd1;
        Dyn_trig_gen_ON  <= 'd0;
    end
    else begin
        Dyn_trig_gen_cnt <= 'd0;
        Dyn_trig_gen_ON  <= 'd0;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        T1_stage_valid <= 1'd1;
        dyn_cnt_us     <= 'd0;
    end
    else case (Func_i)
        FUNC_DYN: begin                                             //动态模式
            case (Dyn_trig_mode_i)
                CONTINUOUS_TRIG: begin
                    if (RUN_flag_ON_i && global_1us_flag_o && ~first_precharge_en) begin
                        if (T1_stage_valid && (dyn_cnt_us == T1_i - 1)) begin
                            dyn_cnt_us <= 'd0;
                            T1_stage_valid <= 'd0;
                        end
                        else if (~T1_stage_valid && (dyn_cnt_us == T2_i - 1)) begin
                            dyn_cnt_us <= 'd0;
                            T1_stage_valid <= 'd1;
                        end
                        else begin
                            dyn_cnt_us <= dyn_cnt_us + 'd1;
                            T1_stage_valid <= T1_stage_valid;
                        end
                    end
                    else begin
                        T1_stage_valid <= 1'd1;
                        dyn_cnt_us     <= 1'd0;
                    end
                end
                PULSE_TRIG: begin
                    if (RUN_flag_ON_i && global_1us_flag_o && ~first_precharge_en) begin
                        if (T1_stage_valid && Dyn_trig_gen_ON) begin
                            dyn_cnt_us <= 'd0;
                            T1_stage_valid <= 'd0;                  //脉冲模式下，触发后才变成T2
                        end
                        else if (~T1_stage_valid && (dyn_cnt_us == T2_i - 1)) begin
                            dyn_cnt_us <= 'd0;
                            T1_stage_valid <= 'd1;
                        end
                        else begin
                            dyn_cnt_us <= dyn_cnt_us + 'd1;
                            T1_stage_valid <= T1_stage_valid;
                        end
                    end
                    else begin
                        T1_stage_valid <= 1'd1;
                        dyn_cnt_us     <= 1'd0;
                    end
                end
                FLIP_TRIG: begin
                    if (RUN_flag_ON_i && global_1us_flag_o && ~first_precharge_en) begin
                        if (T1_stage_valid && Dyn_trig_gen_ON) begin
                            dyn_cnt_us <= 'd0;
                            T1_stage_valid <= 'd0;                  //连续触发模式下，触发后才变成T2
                        end
                        else if (~T1_stage_valid && Dyn_trig_gen_ON) begin
                            dyn_cnt_us <= 'd0;
                            T1_stage_valid <= 'd1;                  //连续触发模式下，触发后才变成T1
                        end
                        else begin
                            dyn_cnt_us <= 'd0;
                            T1_stage_valid <= T1_stage_valid;
                        end
                    end
                    else begin
                        T1_stage_valid <= 1'd1;
                        dyn_cnt_us     <= 1'd0;
                    end
                end
                default: begin
                    T1_stage_valid <= 1'd1;
                    dyn_cnt_us     <= 1'd0;
                end
            endcase
        end
        default: begin
            T1_stage_valid <= 1'd1;
            dyn_cnt_us     <= 1'd0;
        end
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// BATTERY TEST
//---------------------------------------------------------------------



// ********************************************************************************** // 
//---------------------------------------------------------------------
// TOCP
//---------------------------------------------------------------------
    wire                            TOCP_Tstep_done     ;
    reg                [  31: 0]    pull_tocp_target    ;
    reg                [  31: 0]    tocp_us_cnt         ;

    assign                          TOCP_Tstep_done    = (tocp_us_cnt == TOCP_Tstep_set_i - 1);

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        pull_tocp_target <= 'd0;
        tocp_us_cnt      <= 'd0;
    end
    else case (Func_i)
        FUNC_TOCP: begin
            if (RUN_flag_ON_i && ~first_precharge_en) begin
                if ((pull_tocp_target >= TOCP_Icut_set_i) && TOCP_Tstep_done) begin
                    pull_tocp_target <= TOCP_Icut_set_i;
                    tocp_us_cnt      <= 'd0;
                end
                else if (TOCP_Tstep_done) begin
                    pull_tocp_target <= pull_tocp_target + TOCP_Istep_set_i;
                    tocp_us_cnt      <= 'd0;
                end
                else begin
                    pull_tocp_target <= pull_tocp_target;
                    tocp_us_cnt      <= tocp_us_cnt + 'd1;
                end
            end
            else begin
                pull_tocp_target <= TOCP_Istart_set_i;
                tocp_us_cnt      <= 'd0;
            end
        end
        default: begin
            
        end
    endcase
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        TOCP_pass_o           <= 'd0;
        TOCP_done_o           <= 'd0;
        TOCP_status_o         <= 'd0;
        TOCP_current_target_o <= 'd0;
    end
    else case (Func_i)
        FUNC_TOCP: begin                                            //TOCP
            if (RUN_flag_ON_i && ~first_precharge_en) begin
                if (U_i >= TOCP_Vcut_set_i) begin
                    TOCP_pass_o           <= 'd0;
                    TOCP_done_o           <= 'd0;
                    TOCP_status_o         <= 'd1;
                    TOCP_current_target_o <= 'd0;
                end
                else if ((U_i < TOCP_Vcut_set_i) && (I_i >= TOCP_Imin_set_i) && (I_i <= TOCP_Imax_set_i)) begin
                    TOCP_pass_o           <= 'd1;                   //触发OCP且电流在范围内
                    TOCP_done_o           <= 'd1;
                    TOCP_status_o         <= 'd8;
                    TOCP_current_target_o <= pull_tocp_target;
                end
                else if ((U_i < TOCP_Vcut_set_i) && (I_i < TOCP_Imin_set_i)) begin
                    TOCP_pass_o           <= 'd0;                   //触发OCP且电流小于最小值
                    TOCP_done_o           <= 'd1;
                    TOCP_status_o         <= 'd2;
                    TOCP_current_target_o <= pull_tocp_target;
                end
                else if ((U_i < TOCP_Vcut_set_i) && (I_i > TOCP_Imax_set_i)) begin
                    TOCP_pass_o           <= 'd0;                   //触发OCP且电流大于最大值
                    TOCP_done_o           <= 'd1;
                    TOCP_status_o         <= 'd4;
                    TOCP_current_target_o <= pull_tocp_target;
                end
                else begin
                    
                end
            end
            else begin
                TOCP_pass_o           <= 'd0;
                TOCP_done_o           <= 'd0;
                TOCP_status_o         <= 'd0;
                TOCP_current_target_o <= 'd0;
            end
        end
        default: begin
            TOCP_pass_o           <= 'd0;
            TOCP_done_o           <= 'd0;
            TOCP_status_o         <= 'd0;
            TOCP_current_target_o <= 'd0;
        end
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// TOPP
//---------------------------------------------------------------------

    wire                            TOPP_Tstep_done     ;
    reg                [  31: 0]    pull_topp_target    ;
    reg                [  31: 0]    topp_us_cnt         ;

    assign                          TOPP_Tstep_done    = (topp_us_cnt == TOPP_Tstep_set_i - 1);

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        pull_topp_target <= 'd0;
        topp_us_cnt      <= 'd0;
    end
    else case (Func_i)
        FUNC_TOCP: begin                                            //TOPP
            if (RUN_flag_ON_i && ~first_precharge_en) begin
                if ((pull_topp_target >= TOPP_Pcut_set_i) && TOPP_Tstep_done) begin
                    pull_topp_target <= TOPP_Pcut_set_i;
                    topp_us_cnt      <= 'd0;
                end
                else if (TOPP_Tstep_done) begin
                    pull_topp_target <= pull_topp_target + TOPP_Pstep_set_i;
                    topp_us_cnt      <= 'd0;
                end
                else begin
                    pull_topp_target <= pull_topp_target;
                    topp_us_cnt      <= topp_us_cnt + 'd1;
                end
            end
            else begin
                pull_topp_target <= TOPP_Pstart_set_i;
                topp_us_cnt      <= 'd0;
            end
        end
        default: begin
            
        end
    endcase
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        TOPP_pass_o           <= 'd0;
        TOPP_done_o           <= 'd0;
        TOPP_status_o         <= 'd0;
        TOPP_current_target_o <= 'd0;
    end
    else case (Func_i)
        FUNC_TOCP: begin
            if (RUN_flag_ON_i && ~first_precharge_en) begin
                if (U_i >= TOPP_Vcut_set_i) begin
                    TOPP_pass_o           <= 'd0;
                    TOPP_done_o           <= 'd0;
                    TOPP_status_o         <= 'd1;
                    TOPP_current_target_o <= 'd0;
                end
                else if ((U_i < TOPP_Vcut_set_i) && (I_i >= TOPP_Pmin_set_i) && (I_i <= TOPP_Pmax_set_i)) begin
                    TOPP_pass_o           <= 'd1;                   //触发OCP且电流在范围内
                    TOPP_done_o           <= 'd1;
                    TOPP_status_o         <= 'd8;
                    TOPP_current_target_o <= pull_topp_target;
                end
                else if ((U_i < TOPP_Vcut_set_i) && (I_i < TOPP_Pmin_set_i)) begin
                    TOPP_pass_o           <= 'd0;                   //触发OPP且功率小于最小值
                    TOPP_done_o           <= 'd1;
                    TOPP_status_o         <= 'd2;
                    TOPP_current_target_o <= pull_topp_target;
                end
                else if ((U_i < TOPP_Vcut_set_i) && (I_i > TOPP_Pmax_set_i)) begin
                    TOPP_pass_o           <= 'd0;                   //触发OPP且功率大于最大值
                    TOPP_done_o           <= 'd1;
                    TOPP_status_o         <= 'd4;
                    TOPP_current_target_o <= pull_topp_target;
                end
                else begin
                    
                end
            end
            else begin
                TOPP_pass_o           <= 'd0;
                TOPP_done_o           <= 'd0;
                TOPP_status_o         <= 'd0;
                TOPP_current_target_o <= 'd0;
            end
        end
        default: begin
            TOPP_pass_o           <= 'd0;
            TOPP_done_o           <= 'd0;
            TOPP_status_o         <= 'd0;
            TOPP_current_target_o <= 'd0;
        end
    endcase
end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// LIST模式
//---------------------------------------------------------------------

    assign                          Stepnum_done       = (Stepnum_cnt >= Stepnum);//当前地址大于总地址
    assign                          Count_done         = (Count == 0) ? 1'b0 : (Count_cnt  == Count - 1);//0的话无线循环
    assign                          Tstep_done         = (Tstep_cnt  == cur_Tstep - 1);//us计数器
    assign                          Repeat_done        = (Repeat_cnt == Repeat_cache - 1);//单步循环完成
    assign                          loops_done         = (Loops_cnt  == Loops_cache - 1);//小循环完成

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        Repeat_cache <= 'd0;
        Loops_cache  <= 'd0;
        Goto_cache   <= 'd0;
    end
    else if (RUN_flag_ON_pulse) begin
        Repeat_cache <= cur_Repeat;                                 //缓存
        Loops_cache  <= cur_Loops;
        Goto_cache   <= cur_Goto;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        list_buff_rd_addr <= 'd1;
        Count_cnt         <= 'd0;
        Stepnum_cnt       <= 'd1;
        Repeat_cnt        <= 'd0;                                   //单步循环次数计数器
        Loops_cnt         <= 'd0;                                   //小循环次数,1-65535，跳一次+1
        Tstep_cnt         <= 'd0;
    end
    else case (Func_i)
        FUNC_LIST: begin                                            //list模式
            if (RUN_flag_ON_i && ~first_precharge_en) begin
                if (Count_done && Stepnum_done && Repeat_done && loops_done && Tstep_done) begin
                    list_buff_rd_addr <= 'd1;                       //总循环结束//列表最后一个step//单步循环完成//小循环完成//时间完成
                    Count_cnt           <= 'd0;
                    Stepnum_cnt         <= 'd1;
                    Repeat_cnt          <= 'd0;                     //单步循环次数计数器
                    Loops_cnt           <= 'd0;                     //小循环次数,1-65535，跳一次+1
                    Tstep_cnt           <= 'd0;
                end
                else if (Stepnum_done && Repeat_done && loops_done && Tstep_done) begin
                    list_buff_rd_addr <= 'd1;                       //总循环未结束//列表最后一个step//单步循环完成//小循环完成//时间完成
                    Count_cnt           <= Count_cnt + 'd1;
                    Stepnum_cnt         <= 'd1;
                    Repeat_cnt          <= 'd0;                     //单步循环次数计数器
                    Loops_cnt           <= 'd0;                     //小循环次数,1-65535，跳一次+1
                    Tstep_cnt           <= 'd0;
                end
                else if (Repeat_done && loops_done && Tstep_done) begin
                    list_buff_rd_addr <= list_buff_rd_addr + 'd1;   //总循环未结束//列表非最后一个step//单步循环完成//小循环完成//时间完成
                    Count_cnt         <= Count_cnt;
                    Stepnum_cnt       <= Stepnum_cnt + 'd1;
                    Repeat_cnt        <= 'd0;                       //单步循环次数计数器
                    Loops_cnt         <= 'd0;                       //小循环次数,1-65535，跳一次+1
                    Tstep_cnt         <= 'd0;
                end
                else if (loops_done && Tstep_done) begin
                    list_buff_rd_addr <= Stepnum_cnt;               //总循环未结束//列表非一个step//单步循环没完成//小循环完成//时间完成
                    Count_cnt         <= Count_cnt;
                    Stepnum_cnt       <= Stepnum_cnt;
                    Repeat_cnt        <= Repeat_cnt + 'd1;          //单步循环次数计数器
                    Loops_cnt         <= 'd0;                       //小循环次数,1-65535，跳一次+1
                    Tstep_cnt         <= 'd0;
                end
                else if (Tstep_done) begin
                    list_buff_rd_addr <= Goto_cache;                //总循环未结束//列表非一个step//单步循环没完成//小循环没完成//时间完成
                    Count_cnt         <= Count_cnt;
                    Stepnum_cnt       <= Stepnum_cnt;
                    Repeat_cnt        <= Repeat_cnt;                //单步循环次数计数器
                    Loops_cnt         <= Loops_cnt + 'd1;           //小循环次数,1-65535，跳一次+1
                    Tstep_cnt         <= 'd0;
                end
                else begin
                    list_buff_rd_addr <= list_buff_rd_addr;         //总循环未结束//列表非一个step//单步循环没完成//小循环没完成//时间没完成
                    Count_cnt         <= Count_cnt;
                    Stepnum_cnt       <= Stepnum_cnt;
                    Repeat_cnt        <= Repeat_cnt;                //单步循环次数计数器
                    Loops_cnt         <= Loops_cnt;                 //小循环次数,1-65535，跳一次+1
                    Tstep_cnt         <= (global_1us_flag_o) ? (Tstep_cnt + 'd1) : Tstep_cnt;
                end
            end
        end
        default: begin
            
        end
    endcase
end

list_buff_wrapper u_list_buff_wrapper(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),

    .Step_i                         (Step_i             ),// 步数序列号，从1开始，0存以上两个参数
    .Mode_i                         (Mode_i             ),// 工作模式 [CC(0x5a5a)、CV(0xa5a5)、CP(0x5a00)、CR(0x005a)]
    .Value_i                        (Value_i            ),// 拉载值
    .Tstep_i                        (Tstep_i            ),// uS//单步执行时间
    .Repeat_i                       (Repeat_i           ),
    .Goto_i                         (Goto_i             ),// 小循环跳转目的地,1-999
    .Loops_i                        (Loops_i            ),// 小循环次数,1-65535
    .Save_step_ON_i                 (Save_step_ON_i     ),// 锁存参数
    .list_buff_rd_addr_i            (list_buff_rd_addr  ),// 步数序列号，从1开始，0存以上两个参数

    .cur_Mode_o                     (cur_Mode_list      ),// 工作模式 [CC(0x5a5a)、CV(0xa5a5)、CP(0x5a00)、CR(0x005a)]
    .cur_Value_o                    (cur_Value_list     ),// 拉载值
    .cur_Tstep_o                    (cur_Tstep          ),// uS//单步执行时间
    .cur_Repeat_o                   (cur_Repeat         ),
    .cur_Goto_o                     (cur_Goto           ),// 小循环跳转目的地,1-999
    .cur_Loops_o                    (cur_Loops          ) // 小循环次数,1-65535
);

endmodule


`default_nettype wire
