`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               JingNeng
// Engineer:              Chen Xiong Zhi
// 
// File name:             filtering_wrapper.v
// Create Date:           2025/01/07 15:48:08
// Version:               V1.0
// PATH:                  srcs\rtl\filtering_wrapper\filtering_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
`default_nettype none


module filtering_wrapper #(
    parameter                       MEAN_FILTER_LENGTH = 4     ,
    parameter                       DATA_WIDTH         = 33    
) (
    input  wire                     sys_clk_i           ,
    input  wire                     rst_n_i             ,
    //У׼��Ľ������
    input  wire                     adc_cali_valid_i    ,
    input  wire signed [DATA_WIDTH-1: 0]U_cali_i        ,//��ѹ��У׼���ֵ
    input  wire signed [DATA_WIDTH-1: 0]I_cali_i        ,//������У׼���ֵ
    
    //�˲������
    output wire                     adc_cali_mean_valid_o,
    output wire signed [DATA_WIDTH-1: 0]U_cali_mean_o   ,//��ѹ,�˲����ֵ
    output wire signed [DATA_WIDTH-1: 0]I_cali_mean_o   ,//����,�˲����ֵ
    output wire signed [DATA_WIDTH-1: 0]U_cali_mean_abs_o,//��ѹ,�˲���ľ���ֵ
    output wire signed [DATA_WIDTH-1: 0]I_cali_mean_abs_o //����,�˲���ľ���ֵ
);

    assign                          U_cali_mean_abs_o  = signed2unsigned(U_cali_mean_o);
    assign                          I_cali_mean_abs_o  = signed2unsigned(I_cali_mean_o);

mean_filtering#(
    .MEAN_FILTER_LENGTH             (MEAN_FILTER_LENGTH ),
    .S_AXI_DATA_WIDTH               (DATA_WIDTH         ) 
)
u_U_cali_mean_filtering(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .s_axi_data_tvalid_i            (adc_cali_valid_i   ),// ����˿�
    .s_axi_data_tdata_i             (U_cali_i           ),
    .m_axi_data_tvalid_o            (adc_cali_mean_valid_o),// ����˿�
    .m_axi_data_tdata_o             (U_cali_mean_o      ) 
);

mean_filtering#(
    .MEAN_FILTER_LENGTH             (MEAN_FILTER_LENGTH ),
    .S_AXI_DATA_WIDTH               (DATA_WIDTH         ) 
)
u_I_cali_mean_filtering(
    .sys_clk_i                      (sys_clk_i          ),
    .rst_n_i                        (rst_n_i            ),
    .s_axi_data_tvalid_i            (adc_cali_valid_i   ),// ����˿�
    .s_axi_data_tdata_i             (I_cali_i           ),
    .m_axi_data_tvalid_o            (adc_cali_mean_valid_o),// ����˿�
    .m_axi_data_tdata_o             (I_cali_mean_o      ) 
);


// ********************************************************************************** // 
//---------------------------------------------------------------------
// function
//---------------------------------------------------------------------
function [DATA_WIDTH-1: 0] signed2unsigned;
    input              [DATA_WIDTH-1: 0]signed_in       ;
    signed2unsigned    = (signed_in[DATA_WIDTH-1]) ? ~(signed_in - 1) : signed_in;
endfunction


endmodule


`default_nettype wire
