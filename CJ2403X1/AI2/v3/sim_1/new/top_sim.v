`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/01 09:53:26
// Design Name: 
// Module Name: top_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module    msg_transmit_wrapper_tb();
    parameter                           SENSOR_NUM                = 22    ;


    reg                                 sys_clk_100m               ;
    reg                                 rst_n_i                    ;
    wire                                sw_srst_n                  ;
    wire                                hw_srst_n                  ;
    reg                                 gpio_start_trigger_i       ;

    wire                                time_period_0_10ms         ;
    wire                                time_period_25ms_pluse     ;
    wire                                adc_acq_start_pluse        ;
    wire                                vibration_acq_start_pluse  ;

    wire                                internal_sw_srst_n         ;
    
    wire               [SENSOR_NUM-1: 0]wr_en                      ;
    wire               [SENSOR_NUM*16-1: 0]wr_dout                 ;

    wire               [SENSOR_NUM-1: 0]rd_en                      ;
    wire               [SENSOR_NUM*8-1: 0]rd_dout                  ;
    wire               [SENSOR_NUM*16-1: 0]rd_data_count           ;
    wire               [SENSOR_NUM-1: 0]empty                      ;

    reg                [   9: 0]        TURBINE_START              ;
    integer                             i                          ;


    initial
        begin
            #2
            rst_n_i = 0   ;
            sys_clk_100m = 0     ;
            gpio_start_trigger_i = 0;
            TURBINE_START = 0;
            #10
            rst_n_i = 1   ;
            #50
            gpio_start_trigger_i = 1;
            @(posedge sys_clk_100m)
                gpio_start_trigger_i = 1;
            #100
            TURBINE_START = 0;
            #1000
            TURBINE_START = -1;
            #1020
            TURBINE_START = 0;
        end
                                                           
    parameter                           CLK_FREQ                  = 100   ;//Mhz       
    
    
    assign                              sw_srst_n                 = rst_n_i;
    assign                              hw_srst_n                 = rst_n_i;

    always # ( 1000/CLK_FREQ/2 ) sys_clk_100m = ~sys_clk_100m ;
                           
    assign                              internal_sw_srst_n        = sw_srst_n & ~time_period_0_10ms;
                                                           
    reg                [   7: 0]        sim_data                 ='d0;

always@(posedge sys_clk_100m or negedge sw_srst_n)begin
    if (!sw_srst_n) begin
        sim_data <= 'd0;
    end
    else if (|rd_en) begin
        sim_data <= sim_data + 'd1;
    end
end


time_manage_wrapper#(
    .TURBINE_ACQ_PERIOD                 (100_000_000 / 204_800     ),// 204.8kbps
    .ADC_ACQ_PERIOD                     (100_000_000 / 1000        ),// 1Kbps . 4us
    .time_10ms                          (100_000_000 / 1_000_000   ),
    .time_25ms                          (100_000_000 / 40          ) 
)
u_time_manage_wrapper(
    .sys_clk_i                          (sys_clk_100m              ),
    .rst_n_i                            (sw_srst_n                 ),

    .gpio_start_trigger_i               (gpio_start_trigger_i      ),

    .time_period_0_10ms_o               (time_period_0_10ms        ),
    .time_period_25ms_pluse_o           (time_period_25ms_pluse    ),
    .adc_acq_start_pluse_o              (adc_acq_start_pluse       ),
    .vibration_acq_start_pluse_o        (vibration_acq_start_pluse ) 
);

ad7656_wrapper#(
    .ADC_NUM                            (2                         ),
    .SENSOR_NUM                         (SENSOR_NUM                ) 
)
u_ad7656_wrapper(
    .sys_clk_i                          (sys_clk_100m              ),
    .rst_n_i                            (internal_sw_srst_n        ),
    .start_flag_i                       (adc_acq_start_pluse       ),
    .vibration_start_flag_i             (vibration_acq_start_pluse ),

    .ADC1_CS_FPGA                       (ADC1_CS_FPGA              ),
    .ADC1_CONVST_FPGA                   (ADC1_CONVST_FPGA          ),
    .ADC1_RESET_FPGA                    (ADC1_RESET_FPGA           ),
    .ADC1_RD_FPGA                       (ADC1_RD_FPGA              ),
    .WR_1_FPGA                          (WR_1_FPGA                 ),
    .ADC1_BUSY_FPGA                     (ADC1_BUSY_FPGA            ),
    .ADC1_DB                            (ADC1_DB                   ),

    .ADC2_CS_FPGA                       (ADC2_CS_FPGA              ),
    .ADC2_CONVST_FPGA                   (ADC2_CONVST_FPGA          ),
    .ADC2_RESET_FPGA                    (ADC2_RESET_FPGA           ),
    .ADC2_RD_FPGA                       (ADC2_RD_FPGA              ),
    .WR_2_FPGA                          (WR_2_FPGA                 ),
    .ADC2_BUSY_FPGA                     (ADC2_BUSY_FPGA            ),
    .ADC2_DB                            (ADC2_DB                   ),

    // .ADC3_CS_FPGA                       (ADC3_CS_FPGA              ),
    // .ADC3_CONVST_FPGA                   (ADC3_CONVST_FPGA          ),
    // .ADC3_RESET_FPGA                    (ADC3_RESET_FPGA           ),
    // .ADC3_RD_FPGA                       (ADC3_RD_FPGA              ),
    // .WR_3_FPGA                          (WR_3_FPGA                 ),
    // .ADC3_BUSY_FPGA                     (ADC3_BUSY_FPGA            ),
    // .ADC3_DB                            (ADC3_DB                   ),

    // .ADC4_CS_FPGA                       (ADC4_CS_FPGA              ),
    // .ADC4_CONVST_FPGA                   (ADC4_CONVST_FPGA          ),
    // .ADC4_RESET_FPGA                    (ADC4_RESET_FPGA           ),
    // .ADC4_RD_FPGA                       (ADC4_RD_FPGA              ),
    // .WR_4_FPGA                          (WR_4_FPGA                 ),
    // .ADC4_BUSY_FPGA                     (ADC4_BUSY_FPGA            ),
    // .ADC4_DB                            (ADC4_DB                   ),

    .wr_en_o                            (wr_en[11:0]               ),
    .wr_dout_o                          (wr_dout[11*16+15 : 0*16]  ) 
);

turbine_wrapper#(
    .TURBINE_NUM                        (10                        ) 
)
u_turbine_wrapper(
    .sys_clk_i                          (sys_clk_100m              ),
    .rst_n_i                            (internal_sw_srst_n        ),

    .turbine_acq_start_pluse_i          (time_period_25ms_pluse    ),
    .TURBINE_START                      (TURBINE_START             ),
    .wr_en_o                            (wr_en[21:12]              ),
    .wr_din_o                           (wr_dout[21*16+15 : 12*16] ) 
);

cache_wrapper#(
    .SENSOR_NUM                         (SENSOR_NUM                ) 
)
u_cache_wrapper(
    .sys_clk_i                          (sys_clk_100m              ),
    .rst_n_i                            (internal_sw_srst_n        ),

    .adc_acq_start_pluse_i              (adc_acq_start_pluse       ),
    .vibration_acq_start_pluse_i        (vibration_acq_start_pluse ),
    .sim_data_en_i                      (sim_data_en               ),
    .wr_en_i                            (wr_en                     ),// from ad 7656 or gpio
    .wr_dout_i                          (wr_dout                   ),// from ad 7656

    .rd_en_i                            (rd_en                     ),
    .rd_dout_o                          (rd_dout                   ),
    .empty_o                            (empty                     ),
    .rd_data_count_o                    (rd_data_count             ) 
);

msg_transmit_wrapper#(
    .SENSOR_CHANNEL                     (SENSOR_NUM                ) 
)
u_msg_transmit_wrapper(
    .sys_clk_i                          (sys_clk_100m              ),
    .rst_n_i                            (internal_sw_srst_n        ),

    .timming_start_pluse_i              (time_period_25ms_pluse    ),

    .MSG_ID                             (MSG_ID                    ),
    .rd_en_o                            (rd_en                     ),// from cache
    .din_i                              (rd_dout                   ),// from cache
    .data_count_i                       (  {SENSOR_NUM{16'd100}}                ),// from cache
    .empty_i                            (empty                     ),// from cache

    .us_wr_clk_o                        (                          ),// to srio
    .us_wr_en_o                         (fifo_wrreq_pkt_tx         ),// to srio
    .us_wr_dout_o                       (fifo_data_pkt_tx          ),// to srio
    .us_prog_full_i                     (fifo_prog_full_pkt_tx     ) // to srio
);


endmodule