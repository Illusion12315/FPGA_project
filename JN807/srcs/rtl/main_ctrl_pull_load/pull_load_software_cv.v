`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             pull_load_software_cv.v
// Create Date:           2025/01/08 08:36:55
// Version:               V1.0
// PATH:                  srcs\rtl\main_ctrl_pull_load\pull_load_software_cv.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module pull_load_software_cv #(
    parameter                       SIMULATION         = 0     ,
    parameter                       CALCULATE_WIDTH    = 24    ,
    parameter                       RF_MAX_LIMIT       = 30_000_000,//��������½�б�����ƣ���λ1mA/ms
    parameter                       PRECHARGE_I        = 30    ,//MOSԤ������(mA)
    parameter                       AXI_REG_WIDTH      = 24    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,

    input  wire        [CALCULATE_WIDTH-1: 0]Von_i      ,//������ѹmV

    input  wire                     on_i                ,
    input  wire                     global_1us_flag_i   ,
    input  wire signed [AXI_REG_WIDTH-1: 0]target_i     ,//Ŀ��ֵmV
    input  wire signed [AXI_REG_WIDTH-1: 0]initI_i      ,//��ʼ����ֵmA
    input  wire signed [AXI_REG_WIDTH-1: 0]limitI_i     ,//���Ƶ���mA
    input  wire        [AXI_REG_WIDTH-1: 0]CV_slew_i    ,//CVģʽ��ѹ�仯б��(1mV/ms)
    input  wire        [AXI_REG_WIDTH-1: 0]CV_slew_period_i,//CVģʽ��ѹ�仯б��(1mV/ms)
    input  wire        [AXI_REG_WIDTH-1: 0]SR_slew_i    ,//��������б�ʵ�λ1mA/ms ��Ҫ����
    input  wire        [AXI_REG_WIDTH-1: 0]SF_slew_i    ,//�����½�б�ʵ�λ1mA/ms ��Ҫ���� 
    input  wire        [AXI_REG_WIDTH+20-1: 0]SR_slew_period_i,//��������б�ʵ�λ1mA/10ns(every period) slew_i����100_000
    input  wire        [AXI_REG_WIDTH+20-1: 0]SF_slew_period_i,//�����½�б�ʵ�λ1mA/10ns(every period) slew_i����100_000

    input  wire                     Short_flag_i        ,//��·���� (STA/DYN)
    input  wire        [AXI_REG_WIDTH-1: 0]I_short_i    ,//��·ʱ���ص���    

    input  wire signed [  15: 0]    k_i                 ,
    input  wire signed [  15: 0]    b_i                 ,
    input  wire signed [  15: 0]    KP_i                ,//����ϵ��*2^16
    input  wire signed [  15: 0]    KI_i                ,//����ϵ��*2^16
    input  wire signed [  15: 0]    KD_i                ,//΢��ϵ��*2^16
    input  wire        [CALCULATE_WIDTH-1: 0]U_abs_i    ,//mV
    input  wire        [CALCULATE_WIDTH-1: 0]I_abs_i    ,//mV
    
    output wire                     pull_on_doing_o     ,//���浱ǰ���ڽ��е����������

    output reg                      dac_data_valid_o    ,
    output reg         [  15: 0]    dac_data_o          ,
    output reg         [  15: 0]    dac_data_limit_o     
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// declarations
//---------------------------------------------------------------------
    localparam                      TIME_1MS           = 1000  ;
    wire                            time_1ms_flag       ;
    reg                             time_1ms_flag_r1    ;
    reg                             on_r1               ;

    wire               [AXI_REG_WIDTH-1: 0]cv_target    ;
    wire               [AXI_REG_WIDTH-1: 0]pid_calucate_outI  ;
    wire               [AXI_REG_WIDTH-1: 0]cv_limit     ;
    reg                [AXI_REG_WIDTH-1: 0]cv_target_temp  ;
    reg                [AXI_REG_WIDTH+20-1: 0]cv_target_ext  ;
    reg                [AXI_REG_WIDTH-1: 0]cv_limit_temp  ;
    reg                [AXI_REG_WIDTH+20-1: 0]cv_limit_ext  ;
    reg                [AXI_REG_WIDTH-1: 0]targetI      ;//Ŀ�����
    reg                [AXI_REG_WIDTH-1: 0]target_ctrl_temp  ;
    reg                [AXI_REG_WIDTH+20-1: 0]target_ctrl_ext  ;
    wire               [AXI_REG_WIDTH-1: 0]target_ctrl  ;
    wire               [AXI_REG_WIDTH-1: 0]target_ctrl_cali  ;
    wire               [AXI_REG_WIDTH-1: 0]cv_limit_cali  ;
    
    reg                [   9: 0]    cnt_us              ;

    reg                             short_state_add=0   ;
    reg                             on_state_add=0      ;
    
    reg                [AXI_REG_WIDTH-1: 0]initU_cache  ;//��ʼ��ѹֵmV
    reg                [AXI_REG_WIDTH-1: 0]initI_cache  ;//��ʼ��ѹֵmA
    reg                [AXI_REG_WIDTH-1: 0]pid_initI    ;//
// ********************************************************************************** // 
//---------------------------------------------------------------------
// main logic
//---------------------------------------------------------------------
generate
    if (SIMULATION) begin
    assign                          time_1ms_flag      = (cnt_us == 10);
    end
    else begin
    assign                          time_1ms_flag      = (cnt_us == TIME_1MS - 1);
    end
endgenerate

always@(posedge sys_clk_i)begin
    time_1ms_flag_r1 <= time_1ms_flag;
    on_r1 <= on_i;
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        cnt_us <= 'd0;
    end
    else if (on_i || on_state_add) begin
        if (time_1ms_flag)
            cnt_us <= 'd0;
        else if (global_1us_flag_i)
            cnt_us <= cnt_us + 'd1;
        else
            cnt_us <= cnt_us;
    end
    else begin
        cnt_us <= 'd0;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        short_state_add <= 'd0;
    end
    else if (on_i) begin
        if (Short_flag_i) begin
            short_state_add <= 'd1;
        end
        else if (short_state_add && (cv_target == target_i)) begin
            short_state_add <= 'd0;
        end
    end
    else begin
        short_state_add <= 'd0;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        on_state_add <= 'd0;
    end
    else if (on_i) begin
        on_state_add <= 'd1;
    end
    else if (on_state_add && (cv_limit == initI_cache)) begin
        on_state_add <= 'd0;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// ����б�ʺ��߼����
//---------------------------------------------------------------------
//����on֮ǰ�ĳ�ʼ��ѹ
always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        initU_cache <= 'd0;
        initI_cache <= 'd0;
    end
    else if (~on_i && ~on_state_add) begin
        initU_cache <= U_abs_i;
        initI_cache <= initI_i;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        cv_target_temp <= 'd0;
        cv_target_ext  <= 'd0;
    end
    else if (on_i) begin
        if (Short_flag_i) begin                                     //shortʱ��LIMIT���ƣ���ֵ����ֵ
            cv_target_temp <= initU_cache;
            cv_target_ext  <= {initU_cache, 20'b0};
        end
        else if (short_state_add) begin                             //short�ͷ�֮�ʻָ���ֵ
            if (U_abs_i < Von_i && target_i > Von_i) begin          //�ر�short��V_set����ΪVin+0.011V,ͨ��CV��·�����ͷŵ�����
                cv_target_temp <= initU_cache + 11;
                cv_target_ext  <= {initU_cache + 11, 20'b0};
            end
            else begin                                              //ʹ��Vin������Von���,�ٴӵ�ǰV_set����б�ʻָ���Vset��
            
                if (time_1ms_flag && (cv_target_temp > (target_i + CV_slew_i)))
                    cv_target_temp <= cv_target_temp - CV_slew_i;
                else if (time_1ms_flag && ((cv_target_temp + CV_slew_i) < target_i))
                    cv_target_temp <= cv_target_temp + CV_slew_i;
                else if(time_1ms_flag)
                    cv_target_temp <= target_i;
                else
                    cv_target_temp <= cv_target_temp;
    
                if (time_1ms_flag_r1)
                    cv_target_ext <= {cv_target_temp ,20'b0} ;
                else if (cv_target_ext > ({target_i ,20'b0} + CV_slew_period_i))
                    cv_target_ext <= cv_target_ext - CV_slew_period_i;
                else if ((cv_target_ext + CV_slew_period_i) < {target_i ,20'b0})
                    cv_target_ext <= cv_target_ext + CV_slew_period_i;
                else
                    cv_target_ext <= {target_i ,20'b0};

            end
        end
        else begin                                                  //on��״̬�£�����б�ʿ���
            
            if (time_1ms_flag && (cv_target_temp > (target_i + CV_slew_i)))
                cv_target_temp <= cv_target_temp - CV_slew_i;
            else if (time_1ms_flag && ((cv_target_temp + CV_slew_i) < target_i))
                cv_target_temp <= cv_target_temp + CV_slew_i;
            else if(time_1ms_flag)
                cv_target_temp <= target_i;
            else
                cv_target_temp <= cv_target_temp;

            if (time_1ms_flag_r1)
                cv_target_ext <= {cv_target_temp ,20'b0} ;
            else if (cv_target_ext > ({target_i ,20'b0} + CV_slew_period_i))
                cv_target_ext <= cv_target_ext - CV_slew_period_i;
            else if ((cv_target_ext + CV_slew_period_i) < {target_i ,20'b0})
                cv_target_ext <= cv_target_ext + CV_slew_period_i;
            else
                cv_target_ext <= {target_i ,20'b0};

        end
    end
    else if (on_state_add) begin                                    //on�ͷ�ʱ����LIMIT����
        cv_target_temp <= cv_target_temp;
        cv_target_ext  <= cv_target_ext;
    end
    else begin                                                      //off״̬�£��ָ���ֵ
        cv_target_temp <= U_abs_i;
        cv_target_ext  <= {U_abs_i, 20'b0};
    end
end

    assign                          cv_target          = cv_target_ext[AXI_REG_WIDTH+20-1:20];

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        cv_limit_temp <= 'd0;
        cv_limit_ext  <= 'd0;
    end
    else if (on_i) begin                                            //����ʱΪ����ֵ
        cv_limit_temp <= limitI_i;
        cv_limit_ext  <= {limitI_i, 20'b0};
    end
    else if (!on_i && on_r1) begin                                  //�ػ�˲�䣬�Ȱ�limit���ص�ǰ�����ֵ
        cv_limit_temp <= targetI;
        cv_limit_ext  <= {targetI, 20'b0};
    end
    else if (on_state_add) begin                                    //�ػ�������б���½�
        
        if (time_1ms_flag && (cv_limit_temp > (initI_cache + SF_slew_i)))
            cv_limit_temp <= cv_limit_temp - SF_slew_i;
        else if (time_1ms_flag && ((cv_limit_temp + SR_slew_i) < initI_cache))
            cv_limit_temp <= cv_limit_temp + SR_slew_i;
        else if(time_1ms_flag)
            cv_limit_temp <= initI_cache;
        else
            cv_limit_temp <= cv_limit_temp;

        if (time_1ms_flag_r1)
            cv_limit_ext <= {cv_limit_temp ,20'b0} ;
        else if (cv_limit_ext > ({initI_cache ,20'b0} + SF_slew_period_i))
            cv_limit_ext <= cv_limit_ext - SF_slew_period_i;
        else if ((cv_limit_ext + SR_slew_period_i) < {initI_cache ,20'b0})
            cv_limit_ext <= cv_limit_ext + SR_slew_period_i;
        else
            cv_limit_ext <= {initI_cache ,20'b0};

    end
    else begin                                                      //��ȫ�رպ󣬻ص���ֵ
        cv_limit_temp <= limitI_i;
        cv_limit_ext  <= {limitI_i, 20'b0};
    end
end

    assign                          cv_limit           = cv_limit_ext[AXI_REG_WIDTH+20-1:20];

// ********************************************************************************** // 
//---------------------------------------------------------------------
// ��ѹ��
//---------------------------------------------------------------------
always@(posedge sys_clk_i)begin
    if (Short_flag_i || short_state_add) begin                      //shortʱ��ĳɵ�ǰ����ֵ
        pid_initI <= I_abs_i;
    end
    else begin
        pid_initI <= initI_cache;
    end
end

PID_ctrl U_CH_PID_ctrl
(
    .i_clk                          (sys_clk_i          ),//input          
    .i_rst                          (~rst_n_i || ~on_state_add),//input          
												     		 
    .i_gap                          ('d1                ),//input          
    .i_target                       (cv_target          ),//input  [23:0]  
    .i_limitI                       (cv_limit           ),//input  [23:0] 
    .i_initI                        (pid_initI          ),//input  [23:0] shortʱ��ĳɵ�ǰ����ֵ
    .i_x                            (U_abs_i            ),//input  [23:0]  
    .i_P                            (KP_i               ),//input  [15:0]  
    .i_I                            (KI_i               ),//input  [15:0]  
    .i_D                            (KD_i               ),//input  [15:0]  
 
    .o_vld                          (                   ),//output         
    .o_y                            (pid_calucate_outI  ) //output [23:0]  
);

always@(posedge sys_clk_i)begin
    if (pid_calucate_outI > cv_limit || (~on_i && on_state_add)) begin
        targetI <= cv_limit;
    end
    else begin
        targetI <= pid_calucate_outI;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        target_ctrl_temp <= 'd0;
        target_ctrl_ext  <= 'd0;
    end
    else if (on_i) begin
        if (Short_flag_i) begin                                     //��·ģʽ�£������б��������·����Ԥ��ֵ
            
            if (time_1ms_flag && (target_ctrl_temp > (I_short_i + RF_MAX_LIMIT)))
                target_ctrl_temp <= target_ctrl_temp - RF_MAX_LIMIT;
            else if (time_1ms_flag && ((target_ctrl_temp + RF_MAX_LIMIT) < I_short_i))
                target_ctrl_temp <= target_ctrl_temp + RF_MAX_LIMIT;
            else if(time_1ms_flag)
                target_ctrl_temp <= I_short_i;
            else
                target_ctrl_temp <= target_ctrl_temp;

            if (time_1ms_flag_r1)
                target_ctrl_ext <= {target_ctrl_temp ,20'b0} ;
            else if (target_ctrl_ext > ({I_short_i ,20'b0} + (RF_MAX_LIMIT / 100_000)))
                target_ctrl_ext <= target_ctrl_ext - (RF_MAX_LIMIT / 100_000);
            else if ((target_ctrl_ext + (RF_MAX_LIMIT / 100_000)) < {I_short_i ,20'b0})
                target_ctrl_ext <= target_ctrl_ext + (RF_MAX_LIMIT / 100_000);
            else
                target_ctrl_ext <= {I_short_i ,20'b0};

        end
        else begin                                                  //����ģʽ�£��ɵ�ѹ��·����
            target_ctrl_temp <= targetI;
            target_ctrl_ext  <= {targetI, 20'b0};
        end
    end
    else begin                                                      //����ģʽ�£��ɵ�ѹ��·����
        target_ctrl_temp <= targetI;
        target_ctrl_ext  <= {targetI, 20'b0};
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// cali
//---------------------------------------------------------------------
    assign                          target_ctrl        = target_ctrl_ext[AXI_REG_WIDTH+20-1:20];

cali_k_mult_x_add_b#(
    .X_WIDTH                        (24                 ),
    .K_WIDTH                        (16                 ),
    .B_WIDTH                        (16                 ) 
)
u_target_ctrl_cali(
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            (target_ctrl        ),
    .k_i                            (k_i                ),
    .b_i                            (b_i                ),
    .right_shift_i                  ('d16               ),
    .y_o                            (target_ctrl_cali   ) 
);

cali_k_mult_x_add_b#(
    .X_WIDTH                        (24                 ),
    .K_WIDTH                        (16                 ),
    .B_WIDTH                        (16                 ) 
)
u_limit_i(
    .sys_clk_i                      (sys_clk_i          ),
    .x_i                            (cv_limit           ),
    .k_i                            (k_i                ),
    .b_i                            (b_i                ),
    .right_shift_i                  ('d16               ),
    .y_o                            (cv_limit_cali      ) 
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// output
//---------------------------------------------------------------------
always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        dac_data_valid_o <= 'd0;
        dac_data_o       <= 'd0;
        dac_data_limit_o <= 'd0;
    end
    else if (on_i || on_state_add) begin
        dac_data_valid_o <= 'd1;

        if ((target_ctrl_cali[AXI_REG_WIDTH-1:16] == 0) || (target_ctrl_cali[AXI_REG_WIDTH-1:16] == -1))
            dac_data_o <= target_ctrl_cali[15:0];
        else
            dac_data_o <= 'd0;

        if ((cv_limit_cali[AXI_REG_WIDTH-1:16] == 0) || (cv_limit_cali[AXI_REG_WIDTH-1:16] == -1))
            dac_data_limit_o <= cv_limit_cali[15:0];
        else
            dac_data_limit_o <= -1;
    end
    else begin
        dac_data_valid_o <= 'd0;
        dac_data_o       <= 'd0;
        dac_data_limit_o <= 'd0;
    end
end

    assign                          pull_on_doing_o    = on_i & on_state_add;





endmodule


`default_nettype wire
