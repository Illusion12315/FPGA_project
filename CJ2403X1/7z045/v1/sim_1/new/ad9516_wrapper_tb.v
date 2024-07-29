
module ad9516_warpper_tb;

  // Parameters

  //Ports
    reg                                 sys_clk_i                  ;
    reg                                 hw_arst_n                  ;
    reg                                 ad9516_1_rst_n             ;
    wire                                AD9516_1_RESET_B           ;
    wire                                AD9516_1_PD_B              ;
    wire                                AD9516_1_SCLK              ;
    wire                                AD9516_1_SDIO              ;
    reg                                 AD9516_1_SDO               ;
    wire                                AD9516_1_CS                ;
    reg                                 AD9516_1_STATUS            ;
    wire                                AD9516_1_REFSEL            ;
    reg                                 ad9516_2_rst_n             ;
    wire                                AD9516_2_RESET_B           ;
    wire                                AD9516_2_PD_B              ;
    wire                                AD9516_2_SCLK              ;
    wire                                AD9516_2_SDIO              ;
    reg                                 AD9516_2_SDO               ;
    wire                                AD9516_2_CS                ;
    reg                                 AD9516_2_STATUS            ;
    wire                                AD9516_2_REFSEL            ;

    initial begin
        sys_clk_i = 0;
        hw_arst_n = 0;
        ad9516_1_rst_n = 0;
        ad9516_2_rst_n = 0;
        #100
        hw_arst_n = 1;
        #100
        ad9516_1_rst_n = 1;
        #50000
        ad9516_2_rst_n = 1;
    end

  ad9516_warpper  ad9516_warpper_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .hw_arst_n                          (hw_arst_n                 ),
    .ad9516_1_rst_n                     (ad9516_1_rst_n            ),
    .AD9516_1_RESET_B                   (AD9516_1_RESET_B          ),
    .AD9516_1_PD_B                      (AD9516_1_PD_B             ),
    .AD9516_1_SCLK                      (AD9516_1_SCLK             ),
    .AD9516_1_SDIO                      (AD9516_1_SDIO             ),
    .AD9516_1_SDO                       (AD9516_1_SDO              ),
    .AD9516_1_CS                        (AD9516_1_CS               ),
    .AD9516_1_STATUS                    (AD9516_1_STATUS           ),
    .AD9516_1_REFSEL                    (AD9516_1_REFSEL           ),
    .ad9516_2_rst_n                     (ad9516_2_rst_n            ),
    .AD9516_2_RESET_B                   (AD9516_2_RESET_B          ),
    .AD9516_2_PD_B                      (AD9516_2_PD_B             ),
    .AD9516_2_SCLK                      (AD9516_2_SCLK             ),
    .AD9516_2_SDIO                      (AD9516_2_SDIO             ),
    .AD9516_2_SDO                       (AD9516_2_SDO              ),
    .AD9516_2_CS                        (AD9516_2_CS               ),
    .AD9516_2_STATUS                    (AD9516_2_STATUS           ),
    .AD9516_2_REFSEL                    (AD9516_2_REFSEL           ) 
  );

always #5  sys_clk_i = ! sys_clk_i ;

endmodule