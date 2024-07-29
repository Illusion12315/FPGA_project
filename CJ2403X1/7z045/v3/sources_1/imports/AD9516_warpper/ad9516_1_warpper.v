`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             ad9516_1_warpper
// Create Date:           2024/06/07 16:32:52
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\7z045\cfg_7z045_top\cfg_7z045_top.srcs\sources_1\imports\AD9516_warpper\ad9516_1_warpper.v
// Descriptions:          
// 
// ********************************************************************************** // 

// `default_nettype none
module ad9516_1_warpper (
    input  wire                         sys_clk_i                  ,
    input  wire                         rst_n_i                    ,

    output wire                         CS                         ,
    output wire                         SCLK                       ,
    output wire                         SDIO                       ,
    input  wire                         SDO                        ,

    output wire                         write_busy_o               ,
    input  wire                         spi_write_start_i           //����spiģ�鿪ʼ�ź�    

);
    wire                                spi_busy                   ;
    wire                                spi_1byte_write_start      ;
    wire               [  15: 0]        ctrl_data                  ;
    wire               [   7: 0]        write_data                 ;

    wire                                spi_write_start_flag       ;

signle_pluse  signle_pluse_inst (
    .clk                                (sys_clk_i                 ),
    .signal_in                          (spi_write_start_i         ),
    .pluse_out                          (spi_write_start_flag      ) 
);

ad9516_1_spi_ctrl  ad9516_1_spi_ctrl_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),

    .spi_write_start_i                  (spi_write_start_flag      ),
    .spi_busy_i                         (spi_busy                  ),
    .spi_1byte_write_start_o            (spi_1byte_write_start     ),
    .ctrl_data_o                        (ctrl_data                 ),
    .write_busy_o                       (write_busy_o              ),
    .write_data_o                       (write_data                ) 
);

spi_logic  spi_logic_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),

    .SCLK_O                             (SCLK                      ),//SPIʱ��
    .CS_O                               (CS                        ),//SPIƬѡ
    .MOSI_O                             (SDIO                      ),//SPI�����ͣ��ӽ���
    .MISO_I                             (SDO                       ),//SPI�ӷ��ͣ�������

    .start_flag_i                       (spi_1byte_write_start     ),//��ʼ�ź�
    .control_data_i                     (ctrl_data                 ),//����λ�Ĵ���ֵ��16λ
    .write_data_i                       (write_data                ),//�Ĵ���ֵ��8λ
    .read_data_o                        (                          ),//�����ļĴ���ֵ��8λ
    .spi_busy_o                         (spi_busy                  ) //ϵͳ��æ�ź�    
);

endmodule