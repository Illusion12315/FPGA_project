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
    parameter                       PRECHARGE_TIME     = 38    ,//38MS预充电时间

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
    //CC拉载                             
    output reg                      pull_on_o           ,
    output reg                      pull_precharge_en_o ,
    output reg         [  31: 0]    pull_target_o       ,
    output reg         [  31: 0]    pull_initI_o        ,
    output reg         [  31: 0]    pull_limitI_o       ,
    output reg         [AXI_REG_WIDTH-1: 0]pull_Rslew_o ,
    output reg         [AXI_REG_WIDTH-1: 0]pull_Fslew_o ,
    input  wire                     pull_on_doing_i     ,

    input  wire        [CALCULATE_WIDTH-1: 0]U_i        ,//mV    
    input  wire        [CALCULATE_WIDTH-1: 0]I_i        ,//mV    
    input  wire        [CALCULATE_WIDTH-1: 0]U_abs_i    ,//mV    
    input  wire        [CALCULATE_WIDTH-1: 0]I_abs_i    ,//mV    

    input  wire        [   1: 0]    i_BAT_err            //电池错误 b0:I反向 b1:U反向
);

    localparam                      TIME_1US           = 100   ;

    reg                [   7: 0]    cnt_ns='d0          ;

    reg                             T1_stage_valid      ;
    reg                [  15: 0]    dyn_cnt_us          ;
    reg                [  23: 0]    pull_precharge_cnt  ;
    wire                            pull_precharge_cnt_done  ;
    reg                             first_precharge_en  ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 计数器
//---------------------------------------------------------------------
generate
    if (SIMULATION) begin
    assign                          global_1us_flag_o  = (cnt_ns == 10 - 1);
    assign                          pull_precharge_cnt_done= (pull_precharge_cnt == 2 - 1);//1ms
    end
    else begin
    assign                          global_1us_flag_o  = (cnt_ns == TIME_1US - 1);
    assign                          pull_precharge_cnt_done= (pull_precharge_cnt == PRECHARGE_TIME - 1);//1ms
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

            case (Workmod_i)
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

            case (Workmod_i)
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
        FUNC_LIST: begin
            
        end
        FUNC_TOCP: begin
            
        end
        FUNC_TOPP: begin
            
        end
        default: begin

        end
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 拉载控制
//---------------------------------------------------------------------
always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        pull_on_o           <= 'd0;                                 //回到初值
        pull_precharge_en_o <= 'd0;
        pull_precharge_cnt  <= 'd0;
        first_precharge_en  <= 'd1;
    end
    else case (Func_i)
        FUNC_STA,
        FUNC_DYN: begin
            case (Workmod_i)
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
        default: begin
            
        end
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 动态
//---------------------------------------------------------------------
always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        T1_stage_valid <= 1'd1;
        dyn_cnt_us     <= 'd0;
    end
    else case (Func_i)
        FUNC_DYN: begin
            case (Workmod_i)
                WORKMOD_CC,WORKMOD_CV,WORKMOD_CP,WORKMOD_CR: begin
                    if (RUN_flag_ON_i && global_1us_flag_o) begin
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

















endmodule


`default_nettype wire
