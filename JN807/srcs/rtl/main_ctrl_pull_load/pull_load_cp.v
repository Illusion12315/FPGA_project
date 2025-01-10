`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             pull_load_cp.v
// Create Date:           2025/01/07 18:01:09
// Version:               V1.0
// PATH:                  srcs\rtl\main_ctrl_pull_load\pull_load_cp.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module pull_load_cp #(
    parameter                       SIMULATION         = 0     ,
    parameter                       CALCULATE_WIDTH    = 24    ,
    parameter                       RF_MAX_LIMIT       = 30_000_000,//��������½�б�����ƣ���λ1mA/ms
    parameter                       PRECHARGE_I        = 30    ,//MOSԤ������(mA)
    parameter                       AXI_REG_WIDTH      = 24    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,

    input  wire                     on_i                ,
    input  wire                     global_1us_flag_i   ,
    input  wire signed [AXI_REG_WIDTH-1: 0]target_i     ,//Ŀ��ֵmW
    input  wire signed [AXI_REG_WIDTH-1: 0]initI_i      ,//��ʼ����ֵmA
    input  wire signed [AXI_REG_WIDTH-1: 0]limitI_i     ,//���Ƶ���mA
    input  wire        [AXI_REG_WIDTH-1: 0]SR_slew_i    ,//��������б�ʵ�λ1mA/ms ��Ҫ����
    input  wire        [AXI_REG_WIDTH-1: 0]SF_slew_i    ,//�����½�б�ʵ�λ1mA/ms ��Ҫ���� 
    input  wire        [AXI_REG_WIDTH+20-1: 0]SR_slew_period_i,//��������б�ʵ�λ1mA/10ns(every period) slew_i����100_000
    input  wire        [AXI_REG_WIDTH+20-1: 0]SF_slew_period_i,//�����½�б�ʵ�λ1mA/10ns(every period) slew_i����100_000
    input  wire                     precharge_en_i      ,//Ԥ��ʹ��
    input  wire                     Short_flag_i        ,//��·���� (STA/DYN)
    input  wire        [AXI_REG_WIDTH-1: 0]I_short_i    ,//��·ʱ���ص���    

    input  wire signed [  15: 0]    k_i                 ,
    input  wire signed [  15: 0]    b_i                 ,
    input  wire        [CALCULATE_WIDTH-1: 0]U_abs_i    ,//mV
    
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

    reg                [AXI_REG_WIDTH-1: 0]target_ctrl_temp  ;
    reg                [AXI_REG_WIDTH+20-1: 0]target_ctrl_ext  ;
    wire               [AXI_REG_WIDTH-1: 0]target_ctrl  ;
    wire               [AXI_REG_WIDTH-1: 0]target_ctrl_cali  ;
    wire               [AXI_REG_WIDTH-1: 0]limit_cali   ;

    reg                [   9: 0]    cnt_us              ;

    reg                             short_state_add=0   ;
    reg                             on_state_add=0      ;

    reg                [AXI_REG_WIDTH-1: 0]target_current  ;
    wire               [AXI_REG_WIDTH+24-1: 0]target_mult1000  ;
    wire               [AXI_REG_WIDTH-1: 0]P_div_U      ;
    wire               [AXI_REG_WIDTH+CALCULATE_WIDTH+24-1: 0]P_div_U_temp  ;

    reg                [AXI_REG_WIDTH-1: 0]initI_cache  ;//��ʼ��ѹֵmA
// ********************************************************************************** // 
//---------------------------------------------------------------------
// ��Ŀ��ֵת��ΪĿ�����ֵ
//---------------------------------------------------------------------
    assign                          target_mult1000[AXI_REG_WIDTH+24-1:34]= 0;

mult_u24_u10 u_target_mult1000 (
    .CLK                            (sys_clk_i          ),// input wire CLK
    .A                              (signed2unsigned(target_i)),// input wire [23 : 0] A
    .B                              (10'd1000           ),// input wire [9 : 0] B
    .P                              (target_mult1000[33:0]) // output wire [33 : 0] P
);

div_s48_s24 u_target_current (
    .aclk                           (sys_clk_i          ),// input wire aclk
    .s_axis_divisor_tvalid          (1'd1               ),// input wire s_axis_divisor_tvalid
    .s_axis_divisor_tdata           ((U_abs_i == 0) ? 24'b1 : U_abs_i),// input wire [23 : 0] s_axis_divisor_tdata
    .s_axis_dividend_tvalid         (1'd1               ),// input wire s_axis_dividend_tvalid
    .s_axis_dividend_tdata          (target_mult1000    ),// input wire [47 : 0] s_axis_dividend_tdata
    .m_axis_dout_tvalid             (                   ),// output wire m_axis_dout_tvalid
    .m_axis_dout_tdata              (P_div_U_temp       ) // output wire [71 : 0] m_axis_dout_tdata
);

    assign                          P_div_U            = P_div_U_temp[AXI_REG_WIDTH+CALCULATE_WIDTH+24-1:24];//ȡ��

always@(posedge sys_clk_i)begin
    if (P_div_U > limitI_i) begin
        target_current <= limitI_i;
    end
    else begin
        target_current <= P_div_U;
    end
end
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
        else if (short_state_add && (target_ctrl == target_current)) begin
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
    else if (on_state_add && (target_ctrl == initI_cache)) begin
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
        initI_cache <= 'd0;
    end
    else if (~on_i && ~on_state_add) begin
        initI_cache <= initI_i;
    end
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i) begin
        target_ctrl_temp <= 'd0;
        target_ctrl_ext  <= 'd0;
    end
    else if (on_i) begin
        if (precharge_en_i) begin                                   //Ԥ���
            if (target_current > PRECHARGE_I) begin                 //Ŀ��ֵ����Ԥ������Ԥ��ֵ

                if (time_1ms_flag && (target_ctrl_temp > (PRECHARGE_I + SF_slew_i)))
                    target_ctrl_temp <= target_ctrl_temp - SF_slew_i;
                else if (time_1ms_flag && ((target_ctrl_temp + SR_slew_i) < PRECHARGE_I))
                    target_ctrl_temp <= target_ctrl_temp + SR_slew_i;
                else if(time_1ms_flag)
                    target_ctrl_temp <= PRECHARGE_I;
                else
                    target_ctrl_temp <= target_ctrl_temp;

                if (time_1ms_flag_r1)
                    target_ctrl_ext <= {target_ctrl_temp ,20'b0} ;
                else if (target_ctrl_ext > ({PRECHARGE_I ,20'b0} + SF_slew_period_i))
                    target_ctrl_ext <= target_ctrl_ext - SF_slew_period_i;
                else if ((target_ctrl_ext + SR_slew_period_i) < {PRECHARGE_I ,20'b0})
                    target_ctrl_ext <= target_ctrl_ext + SR_slew_period_i;
                else
                    target_ctrl_ext <= {PRECHARGE_I ,20'b0};

            end
            else begin                                              //Ŀ��ֵС�ڵ���Ԥ������Ԥ��ֵ

                if (time_1ms_flag && (target_ctrl_temp > (target_current + SF_slew_i)))
                    target_ctrl_temp <= target_ctrl_temp - SF_slew_i;
                else if (time_1ms_flag && ((target_ctrl_temp + SR_slew_i) < target_current))
                    target_ctrl_temp <= target_ctrl_temp + SR_slew_i;
                else if(time_1ms_flag)
                    target_ctrl_temp <= target_current;
                else
                    target_ctrl_temp <= target_ctrl_temp;

                if (time_1ms_flag_r1)
                    target_ctrl_ext <= {target_ctrl_temp ,20'b0} ;
                else if (target_ctrl_ext > ({target_current ,20'b0} + SF_slew_period_i))
                    target_ctrl_ext <= target_ctrl_ext - SF_slew_period_i;
                else if ((target_ctrl_ext + SR_slew_period_i) < {target_current ,20'b0})
                    target_ctrl_ext <= target_ctrl_ext + SR_slew_period_i;
                else
                    target_ctrl_ext <= {target_current ,20'b0};
                
            end
        end
        else if (Short_flag_i) begin                                //��·ģʽ�£������б��������·����Ԥ��ֵ
            
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
        else if (short_state_add) begin                             //��·ģʽ�ͷź󣬸��ݵ�ǰб�ʻָ����趨ֵ
            
            if (time_1ms_flag && (target_ctrl_temp > (target_current + SF_slew_i)))
                target_ctrl_temp <= target_ctrl_temp - SF_slew_i;
            else if (time_1ms_flag && ((target_ctrl_temp + SR_slew_i) < target_current))
                target_ctrl_temp <= target_ctrl_temp + SR_slew_i;
            else if(time_1ms_flag)
                target_ctrl_temp <= target_current;
            else
                target_ctrl_temp <= target_ctrl_temp;

            if (time_1ms_flag_r1)
                target_ctrl_ext <= {target_ctrl_temp ,20'b0} ;
            else if (target_ctrl_ext > ({target_current ,20'b0} + SF_slew_period_i))
                target_ctrl_ext <= target_ctrl_ext - SF_slew_period_i;
            else if ((target_ctrl_ext + SR_slew_period_i) < {target_current ,20'b0})
                target_ctrl_ext <= target_ctrl_ext + SR_slew_period_i;
            else
                target_ctrl_ext <= {target_current ,20'b0};

        end
        else begin                                                  //�Ƕ�·����Ԥ���״̬������б�ʵ�Ŀ��ֵ
            
            if (time_1ms_flag && (target_ctrl_temp > (target_current + SF_slew_i)))
                target_ctrl_temp <= target_ctrl_temp - SF_slew_i;
            else if (time_1ms_flag && ((target_ctrl_temp + SR_slew_i) < target_current))
                target_ctrl_temp <= target_ctrl_temp + SR_slew_i;
            else if(time_1ms_flag)
                target_ctrl_temp <= target_current;
            else
                target_ctrl_temp <= target_ctrl_temp;

            if (time_1ms_flag_r1)
                target_ctrl_ext <= {target_ctrl_temp ,20'b0} ;
            else if (target_ctrl_ext > ({target_current ,20'b0} + SF_slew_period_i))
                target_ctrl_ext <= target_ctrl_ext - SF_slew_period_i;
            else if ((target_ctrl_ext + SR_slew_period_i) < {target_current ,20'b0})
                target_ctrl_ext <= target_ctrl_ext + SR_slew_period_i;
            else
                target_ctrl_ext <= {target_current ,20'b0};

        end
    end
    else if (on_state_add) begin                                    //on�ͷź󣬰���б�ʻص�����ʼֵ

        if (time_1ms_flag && (target_ctrl_temp > (initI_cache + SF_slew_i)))
            target_ctrl_temp <= target_ctrl_temp - SF_slew_i;
        else if (time_1ms_flag && ((target_ctrl_temp + SR_slew_i) < initI_cache))
            target_ctrl_temp <= target_ctrl_temp + SR_slew_i;
        else if(time_1ms_flag)
            target_ctrl_temp <= initI_cache;
        else
            target_ctrl_temp <= target_ctrl_temp;

        if (time_1ms_flag_r1)
            target_ctrl_ext <= {target_ctrl_temp ,20'b0} ;
        else if (target_ctrl_ext > ({initI_cache ,20'b0} + SF_slew_period_i))
            target_ctrl_ext <= target_ctrl_ext - SF_slew_period_i;
        else if ((target_ctrl_ext + SR_slew_period_i) < {initI_cache ,20'b0})
            target_ctrl_ext <= target_ctrl_ext + SR_slew_period_i;
        else
            target_ctrl_ext <= {initI_cache ,20'b0};
        
    end
    else begin
        
        target_ctrl_temp <= initI_cache;
        target_ctrl_ext  <= {initI_cache ,20'b0};
        
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
    .x_i                            (limitI_i           ),
    .k_i                            (k_i                ),
    .b_i                            (b_i                ),
    .right_shift_i                  ('d16               ),
    .y_o                            (limit_cali         ) 
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

        if ((limit_cali[AXI_REG_WIDTH-1:16] == 0) || (limit_cali[AXI_REG_WIDTH-1:16] == -1))
            dac_data_limit_o <= limit_cali[15:0];
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

// ********************************************************************************** // 
//---------------------------------------------------------------------
// functions
//---------------------------------------------------------------------
function [AXI_REG_WIDTH-1: 0] signed2unsigned;
    input              [AXI_REG_WIDTH-1: 0]signed_in    ;
    signed2unsigned    = (signed_in[AXI_REG_WIDTH-1]) ? ~(signed_in - 1) : signed_in;
endfunction

endmodule


`default_nettype wire
