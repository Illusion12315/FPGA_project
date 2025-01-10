`timescale 1ns / 1ps
//****************************************VSCODE PLUG-IN**********************************//
//----------------------------------------------------------------------------------------
// IDE :                   VSCODE plug-in 
// VSCODE plug-in version: Verilog-Hdl-Format-2.8.20240817
// VSCODE plug-in author : Jiang Percy
//----------------------------------------------------------------------------------------
//****************************************Copyright (c)***********************************//
// Copyright(C)            Xiaoxin2ciyuan
// All rights reserved     
// File name:              e_load_wrapper_tb.v
// Last modified Date:     2025/01/08 15:20:43
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Chen Ambition
// Created date:           2025/01/08 15:20:43
// Version:                V1.0
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module    e_load_wrapper_tb();
    parameter                       C_S_AXI_DATA_WIDTH = 32    ;
    parameter                       C_S_AXI_ADDR_WIDTH = 12    ;
    reg                             sys_clk_i           ;
    reg                             rst_n_i             ;
    reg                             adc_acq_valid_i     ;
    reg      signed    [  15: 0]    I_SUM_H_AD          ;
    reg      signed    [  15: 0]    I_SUM_L_AD          ;
    reg      signed    [  15: 0]    I_BOARD_H_AD        ;
    reg      signed    [  15: 0]    I_BOARD_L_AD        ;
    reg      signed    [  15: 0]    AD_Vmod             ;
    reg      signed    [  15: 0]    AD_Vsense           ;
    reg      signed    [  15: 0]    I_SUM_UNIT_AD       ;
    reg      signed    [  15: 0]    I_BOARD_UNIT_AD     ;
    wire                            dac_ch1_en_o        ;
    wire               [  15: 0]    dac_ch1_data_o      ;
    wire                            dac_ch2_en_o        ;
    wire               [  15: 0]    dac_ch2_data_o      ;
    wire               [C_S_AXI_ADDR_WIDTH-1: 0]S_AXI_AWADDR  ;
    wire               [   2: 0]    S_AXI_AWPROT        ;
    wire                            S_AXI_AWVALID       ;
    wire                            S_AXI_AWREADY       ;
    wire               [C_S_AXI_DATA_WIDTH-1: 0]S_AXI_WDATA  ;
    wire               [(C_S_AXI_DATA_WIDTH/8)-1: 0]S_AXI_WSTRB  ;
    wire                            S_AXI_WVALID        ;
    wire                            S_AXI_WREADY        ;
    wire               [   1: 0]    S_AXI_BRESP         ;
    wire                            S_AXI_BVALID        ;
    wire                            S_AXI_BREADY        ;
    wire               [C_S_AXI_ADDR_WIDTH-1: 0]S_AXI_ARADDR  ;
    wire               [   2: 0]    S_AXI_ARPROT        ;
    wire                            S_AXI_ARVALID       ;
    wire                            S_AXI_ARREADY       ;
    wire               [C_S_AXI_DATA_WIDTH-1: 0]S_AXI_RDATA  ;
    wire               [   1: 0]    S_AXI_RRESP         ;
    wire                            S_AXI_RVALID        ;
    wire                            S_AXI_RREADY        ;

    reg                             single_write_burst_start_pluse_i  ;
    reg                [C_S_AXI_ADDR_WIDTH-1: 0]single_write_burst_addr_i  ;
    reg                [C_S_AXI_DATA_WIDTH-1: 0]single_write_burst_data_i  ;
    reg                             single_write_burst_data_valid_i  ;
    wire                            single_write_burst_data_ready_o  ;
    wire                            single_write_burst_data_done_o  ;
    reg                             single_read_burst_start_pluse_i  ;
    reg                [C_S_AXI_ADDR_WIDTH-1: 0]single_read_burst_addr_i  ;
    wire               [C_S_AXI_DATA_WIDTH-1: 0]single_read_burst_data_o  ;
    wire                            single_read_burst_data_valid_o  ;
    wire                            single_read_burst_data_done_o  ;


    initial
        begin
            #2
            rst_n_i = 0   ;
            sys_clk_i = 0     ;
            single_write_burst_start_pluse_i  = 0;
            single_write_burst_addr_i  = 0;
            single_write_burst_data_i  = 0;
            single_write_burst_data_valid_i  = 0;
            single_read_burst_start_pluse_i  = 0;
            single_read_burst_addr_i  = 0;
            adc_acq_valid_i = 0;
            AD_Vmod   = 540;
            AD_Vsense = (540);                                      //2A
            I_SUM_H_AD    = 0;
            I_BOARD_H_AD  = 0;
            I_SUM_L_AD  = 0;
            I_BOARD_L_AD= 0;
            #10
            rst_n_i = 1   ;
            #100
            write_regs(32'h007,  32'h0);                            //清楚告警
            AD_Vmod   = 'hFDE4;
            AD_Vsense = 'hFDE4;                                      //2A
            I_SUM_H_AD    = 0;
            I_BOARD_H_AD  = 0;
            I_SUM_L_AD  = 0;
            I_BOARD_L_AD= 0;
            #1000
            AD_Vmod   = 540;
            AD_Vsense = (540);                                      //2A
            I_SUM_H_AD    = 0;
            I_BOARD_H_AD  = 0;
            I_SUM_L_AD  = 0;
            I_BOARD_L_AD= 0;
            write_regs(32'h007,  32'h5a5a);                            //清楚告警
            static_cc_test();
            write_regs(32'h001,  16'h005a);                         //CP
            write_regs(32'h002,  16'h5a00);                         //static
            write_regs(32'h017,  16'd10000);                        // Rset 5000m
            write_regs(32'h00B,  16'd1000);                         // sr
            write_regs(32'h00C,  16'd1000);                         // sf
            write_regs(32'h007,  32'h0);                            //清楚告警
            #1000
            write_regs(32'h008,  32'h5a5a);

            #3000_000
            write_regs(32'h008,  32'ha5a5);
        end

task static_cp_test;
    begin
        write_regs(32'h001,  16'h5a00);                         //CP
        write_regs(32'h002,  16'h5a00);                         //static
        write_regs(32'h015,  16'd50000);                        // Pset 50000Mw
        write_regs(32'h00B,  16'd1000);                         // sr
        write_regs(32'h00C,  16'd1000);                         // sf
        write_regs(32'h007,  32'h0);                            //清楚告警
        #1000
        write_regs(32'h008,  32'h5a5a);
        #3000_000
        write_regs(32'h008,  32'ha5a5);
    end
endtask

task static_cc_test;
    begin
        write_regs(32'h001,  16'h5a5a);                             //CC
        write_regs(32'h002,  16'h5a00);                             //static
        write_regs(32'h011,  16'd2000);                             // iset 2A 
        write_regs(32'h00B,  16'd1000);                             // sr
        write_regs(32'h00C,  16'd1000);                             // sf
        write_regs(32'h007,  32'h0);                                //清楚告警
        #1000
        write_regs(32'h008,  32'h5a5a);
        #3000_000
        write_regs(32'h008,  32'ha5a5);
    end
endtask

                                                          
        always begin
            #50
            @(posedge sys_clk_i)
                adc_acq_valid_i = 1'b1;
            @(posedge sys_clk_i)
                adc_acq_valid_i = 1'b0;
        end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// ADC输入
//---------------------------------------------------------------------
always@(posedge sys_clk_i)begin
    I_SUM_UNIT_AD   <= I_SUM_H_AD;
    I_BOARD_UNIT_AD <= I_BOARD_H_AD;
    // I_SUM_L_AD      <= I_SUM_H_AD;
    // I_BOARD_L_AD    <= I_BOARD_H_AD;
end

// always@(posedge sys_clk_i or negedge rst_n_i)begin
//     if (!rst_n_i) begin
//         I_SUM_H_AD      <= 'd0;
//         I_BOARD_H_AD    <= 'd0;
//     end
//     else begin
//         I_SUM_H_AD      <= 3440;
//         I_BOARD_H_AD    <= 3440;
//     end
// end









    parameter                       CLK_FREQ           = 100   ;//Mhz                       
    always # ( 1000/CLK_FREQ/2 ) sys_clk_i = ~sys_clk_i ;
                                                           
                                                           
e_load_wrapper#(
    .SIMULATION                     (0                  ),
    .C_S_AXI_DATA_WIDTH             (C_S_AXI_DATA_WIDTH ),
    .C_S_AXI_ADDR_WIDTH             (C_S_AXI_ADDR_WIDTH ) 
)
 u_e_load_wrapper(
    .sys_clk_i                      (sys_clk_i          ),// 100MHz
    .rst_n_i                        (rst_n_i            ),
    // ADC signal
    .adc_acq_valid_i                (adc_acq_valid_i    ),
    .I_SUM_H_AD                     (I_SUM_H_AD         ),// I_SUM_H_AD----高档位8路板卡汇总电流4.521V
    .I_SUM_L_AD                     (I_SUM_L_AD         ),// I_SUM_L_AD----低档位8路板卡汇总电流
    .I_BOARD_H_AD                   (I_BOARD_H_AD       ),// I_BOARD_H_AD----高档位板卡电流4.5V
    .I_BOARD_L_AD                   (I_BOARD_L_AD       ),// I_BOARD_L_AD----低档位板卡电流
    .AD_Vmod                        (AD_Vmod            ),// AD_Vmod----非sense端电压
    .AD_Vsense                      (AD_Vsense          ),// AD_Vsense----sense端电压
    .I_SUM_UNIT_AD                  (I_SUM_UNIT_AD      ),// I_SUM_UNIT_AD----单板卡24模块汇总电流4.125V
    .I_BOARD_UNIT_AD                (I_BOARD_UNIT_AD    ),// I_BOARD_UNIT_AD----单板卡单模块电流3.4375V
    // DAC signal
    .dac_ch1_en_o                   (dac_ch1_en_o       ),
    .dac_ch1_data_o                 (dac_ch1_data_o     ),
    .dac_ch2_en_o                   (dac_ch2_en_o       ),
    .dac_ch2_data_o                 (dac_ch2_data_o     ),
	// User ports ends
    .S_AXI_AWADDR                   (S_AXI_AWADDR       ),
    .S_AXI_AWPROT                   (S_AXI_AWPROT       ),
    .S_AXI_AWVALID                  (S_AXI_AWVALID      ),
    .S_AXI_AWREADY                  (S_AXI_AWREADY      ),
    .S_AXI_WDATA                    (S_AXI_WDATA        ),
    .S_AXI_WSTRB                    (S_AXI_WSTRB        ),
    .S_AXI_WVALID                   (S_AXI_WVALID       ),
    .S_AXI_WREADY                   (S_AXI_WREADY       ),
    .S_AXI_BRESP                    (S_AXI_BRESP        ),
    .S_AXI_BVALID                   (S_AXI_BVALID       ),
    .S_AXI_BREADY                   (S_AXI_BREADY       ),
    .S_AXI_ARADDR                   (S_AXI_ARADDR       ),
    .S_AXI_ARPROT                   (S_AXI_ARPROT       ),
    .S_AXI_ARVALID                  (S_AXI_ARVALID      ),
    .S_AXI_ARREADY                  (S_AXI_ARREADY      ),
    .S_AXI_RDATA                    (S_AXI_RDATA        ),
    .S_AXI_RRESP                    (S_AXI_RRESP        ),
    .S_AXI_RVALID                   (S_AXI_RVALID       ),
    .S_AXI_RREADY                   (S_AXI_RREADY       ) 
);

m_axi_lite2single_burst_interface#(
    .C_M_AXI_ADDR_WIDTH             (C_S_AXI_ADDR_WIDTH ),
    .C_M_AXI_DATA_WIDTH             (C_S_AXI_DATA_WIDTH ) 
)
u_m_axi_lite2single_burst_interface(
//-------------------------customrize---------------------------//
    .single_write_burst_start_pluse_i(single_write_burst_start_pluse_i),
    .single_write_burst_addr_i      (single_write_burst_addr_i),// The AXI address is a concatenation of the target base address + active offset range
    .single_write_burst_data_i      (single_write_burst_data_i),
    .single_write_burst_data_valid_i(single_write_burst_data_valid_i),
    .single_write_burst_data_ready_o(single_write_burst_data_ready_o),
    .single_write_burst_data_done_o (single_write_burst_data_done_o),
    .single_read_burst_start_pluse_i(single_read_burst_start_pluse_i),
    .single_read_burst_addr_i       (single_read_burst_addr_i),// The AXI address is a concatenation of the target base address + active offset range
    .single_read_burst_data_o       (single_read_burst_data_o),
    .single_read_burst_data_valid_o (single_read_burst_data_valid_o),
    .single_read_burst_data_done_o  (single_read_burst_data_done_o),
//--------------------------------------------------------------//
//----------------------AXI Lite interface-----------------------//
//--------------------------------------------------------------//
//----------------------m AXI MM interface---------------------//
    .M_AXI_ACLK                     (sys_clk_i          ),// Global Clock Signal.
    .M_AXI_ARESETN                  (rst_n_i            ),// Global Reset Singal. This Signal is Active Low
// aw channel(write address)
    .M_AXI_AWADDR                   (S_AXI_AWADDR       ),// Master Interface Write Address
    .M_AXI_AWVALID                  (S_AXI_AWVALID      ),// Write address valid. This signal indicates that the channel is signaling valid write address and control information.
    .M_AXI_AWREADY                  (S_AXI_AWREADY      ),// Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals
// w channel(write data)
    .M_AXI_WDATA                    (S_AXI_WDATA        ),// Master Interface Write Data.
    .M_AXI_WSTRB                    (S_AXI_WSTRB        ),// Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
    .M_AXI_WVALID                   (S_AXI_WVALID       ),// Write valid. This signal indicates that valid write data and strobes are available
    .M_AXI_WREADY                   (S_AXI_WREADY       ),// Write ready. This signal indicates that the slave can accept the write data.
// b channel
    .M_AXI_BVALID                   (S_AXI_BVALID       ),// Write response valid. This signal indicates that the channel is signaling a valid write response.
    .M_AXI_BREADY                   (S_AXI_BREADY       ),// Response ready. This signal indicates that the master can accept a write response.
// ar channel(read address)
    .M_AXI_ARADDR                   (S_AXI_ARADDR       ),// Read address. This signal indicates the initial address of a read burst transaction.
    .M_AXI_ARVALID                  (S_AXI_ARVALID      ),// Write address valid. This signal indicates that the channel is signaling valid read address and control information
    .M_AXI_ARREADY                  (S_AXI_ARREADY      ),// Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals
// r channel(read data)
    .M_AXI_RDATA                    (S_AXI_RDATA        ),// Master Read Data
    .M_AXI_RVALID                   (S_AXI_RVALID       ),// Read valid. This signal indicates that the channel is signaling the required read data.
    .M_AXI_RREADY                   (S_AXI_RREADY       ) // Read ready. This signal indicates that the master can accept the read data and response information.
);
// ********************************************************************************** // 
//---------------------------------------------------------------------
// tasks
//---------------------------------------------------------------------
task write_regs;
    input              [  31: 0]    addr                ;
    input              [  31: 0]    data                ;
    begin
        single_write_burst_addr_i = addr << 2;
        single_write_burst_data_i = data;
        @ (posedge sys_clk_i) begin
            #1 single_write_burst_start_pluse_i = 1'b1;
        end
        @ (posedge sys_clk_i) begin
            #1 single_write_burst_data_valid_i = 1'b1;
        end
        @ (posedge sys_clk_i) begin
            #1 single_write_burst_start_pluse_i = 1'b0;
        end
        @ (posedge sys_clk_i) begin
            #1 single_write_burst_data_valid_i = 1'b0;
        end
            
        #50
        $display("write regs successfully!!");
    end
endtask

endmodule
