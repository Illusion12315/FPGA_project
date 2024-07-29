`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/06 11:27:23
// Design Name: 
// Module Name: clk_rst_wrapper
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

module clk_rst_wrapper
    # (
    parameter                           CHANNEL_NUM            =   2 
    )
    (
    //sysclk
    input                               SYSCLK100_P                ,
    input                               SYSCLK100_N                ,
    
    //AD9516
    output                              CS                         ,
    output                              SCLK                       ,
    output                              SDIO                       ,
    input                               SDO                        ,
    output                              REFSEL                     ,
    output                              RESET_B                    ,
        
    //ddr3_clk
    input                               ddr3_ui_clk                ,
    input                               phy_init_done              ,
    //pcie_clk
    input                               pcie_axi_clk               ,
    input                               pcie_lnk_up                ,
    
    //2711_clk
    input                               LVDS_1_2711_P              ,
    input                               LVDS_1_2711_N              ,
    
    input                               LVDS_2_2711_P              ,
    input                               LVDS_2_2711_N              ,
    
    output                              POWER_ON                   ,//电源使能    
       
    //
    output             [CHANNEL_NUM-1:0]GTX_CLK                    ,
    input              [CHANNEL_NUM-1:0]RX_CLK                     ,

    output             [CHANNEL_NUM*5-1:0]OE                         ,
    // Clock and Reset
    output             [CHANNEL_NUM-1:0]rx_100m                    ,
    output             [CHANNEL_NUM-1:0]rx_200m                    ,
    output             [CHANNEL_NUM-1:0]rx_reset_n                 ,
    //
    output                              clk_50m                    ,
    output                              clk_100m                   ,
    output                              hw_reset_n                 ,
    output                              sys_reset_n                ,
    input                               sw_reset_n                  
    //
    );
//---------------------------------------------------------------------
// wires 
//---------------------------------------------------------------------
// Clock and Reset
wire                                    locked                     ;
wire                                    vio_rst_n                  ;
wire                   [CHANNEL_NUM-1:0]rxclk_locked               ;
//freq_calc
wire                                    clk_2711_1                 ;
wire                                    clk_2711_2                 ;
wire                   [  19:0]         freq_2711_clk1             ;
      
wire                   [  19:0]         freq_ddr3_ui_clk           ;
wire                   [  19:0]         freq_pcie_axi_clk          ;
    
//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
reg                                     hw_reset_n_r      =   1'b0 ;
reg                    [  31:0]         hw_rst_cnt        =   32'd0;
reg                                     sys_rst_n_r       =   1'b0 ;
reg                                     sw_reset_n_r      =   1'b0 ;
reg                                     sw_reset_n_r2     =   1'b0 ;
reg                                     phy_init_done_r   =   1'b0 ;
reg                                     phy_init_done_r2  =   1'b0 ;
reg                                     pcie_lnk_up_r     =   1'b0 ;
reg                                     pcie_lnk_up_r2    =   1'b0 ;
    
reg                    [CHANNEL_NUM-1:0]rxclk_locked_r    =   {CHANNEL_NUM{1'b0}};
reg                    [CHANNEL_NUM-1:0]rxclk_locked_r2   =   {CHANNEL_NUM{1'b0}};
    
reg                                     pw_on_r     = 'd0          ;
reg                    [  31:0]         rst_cnt     = 'd0          ;

//---------------------------------------------------------------------  
// Parameter
//---------------------------------------------------------------------  
localparam                              time_1ms            =   32'd49_999;
localparam                              time_1s             =   32'd49_999_999;

localparam                              time_10ms           = 32'd1_000_000;
 
// ********************************************************************************** // 
//---------------------------------------------------------------------
// Assign
//---------------------------------------------------------------------       
assign      hw_reset_n              =   hw_reset_n_r;
//assign      sys_reset_n             =   hw_reset_n_r && vio_rst_n;      
assign      sys_reset_n             =   sys_rst_n_r;

assign      POWER_ON                =   pw_on_r;
//---------------------------------------------------------------------
// clk_2711
//---------------------------------------------------------------------  
IBUFDS #(
    .DIFF_TERM                         ("FALSE"                   ),// Differential Termination
    .IBUF_LOW_PWR                      ("TRUE"                    ),// Low power="TRUE", Highest performance="FALSE" 
    .IOSTANDARD                        ("DEFAULT"                 ) // Specify the input I/O standard
    ) IBUFDS_inst_0 (
    .O                                 (clk_2711_1                ),// Buffer output
    .I                                 (LVDS_1_2711_P             ),// Diff_p buffer input (connect directly to top-level port)
    .IB                                (LVDS_1_2711_N             ) // Diff_n buffer input (connect directly to top-level port)
    );

IBUFDS #(
    .DIFF_TERM                         ("FALSE"                   ),// Differential Termination
    .IBUF_LOW_PWR                      ("TRUE"                    ),// Low power="TRUE", Highest performance="FALSE" 
    .IOSTANDARD                        ("DEFAULT"                 ) // Specify the input I/O standard
    ) IBUFDS_inst_1 (
    .O                                 (clk_2711_2                ),// Buffer output
    .I                                 (LVDS_2_2711_P             ),// Diff_p buffer input (connect directly to top-level port)
    .IB                                (LVDS_2_2711_N             ) // Diff_n buffer input (connect directly to top-level port)
    );
//---------------------------------------------------------------------
// PLL
//---------------------------------------------------------------------  
  PLL u_PLL
   (
    // Clock out ports
    .clk_100m                          (clk_100m                  ),// output clk_out1
    .clk_50m                           (clk_50m                   ),// output clk_out2
    // Status and control signals
    .reset                             (1'b0                      ),// input reset
    .locked                            (locked                    ),// output locked
   // Clock in ports
    .clk_in1_p                         (SYSCLK100_P               ),// input clk_in1_p
    .clk_in1_n                         (SYSCLK100_N               ) // input clk_in1_n
    );

//---------------------------------------------------------------------  
always@(posedge clk_50m)
    begin
        phy_init_done_r  <=  phy_init_done;
        phy_init_done_r2 <=  phy_init_done_r;
    end
always@(posedge clk_50m)
    begin
        pcie_lnk_up_r  <=  pcie_lnk_up;
        pcie_lnk_up_r2 <=  pcie_lnk_up_r;
    end
    
//---------------------------------------------------------------------  
//  FPGA硬件复位 
//---------------------------------------------------------------------  
always@(posedge clk_50m or negedge locked) begin
    if(!locked)begin
        hw_reset_n_r    <=  1'b0;
        hw_rst_cnt      <=  32'd0;
    end
    else if(hw_rst_cnt >= time_1s) begin
        hw_reset_n_r    <=  1'b1;
        hw_rst_cnt      <=  hw_rst_cnt;
    end
    else begin
        hw_reset_n_r    <=  1'b0;
        hw_rst_cnt      <=  hw_rst_cnt + 1'b1;
    end
end

//---------------------------------------------------------------------    
//  FPGA系统复位
//--------------------------------------------------------------------- 
always@(posedge clk_50m)
    begin
        sw_reset_n_r  <=  sw_reset_n;
        sw_reset_n_r2 <=  sw_reset_n_r;
    end
   
always@(posedge clk_50m or negedge hw_reset_n)
    begin
        if(!hw_reset_n) begin
            sys_rst_n_r <=  1'b0;
        end else begin
            sys_rst_n_r <=  sw_reset_n_r2 && vio_rst_n;
        end
    end
    
//---------------------------------------------------------------------
// AD9516
//---------------------------------------------------------------------
//调用AD9516模块
ad9516_spi_warpper  ad9516_spi_warpper_inst (
    .sys_clk_i                         (clk_50m                   ),
    .rst_n_i                           (locked                    ),

    .CS                                (CS                        ),
    .SCLK                              (SCLK                      ),
    .SDIO                              (SDIO                      ),
    .SDO                               (SDO                       ),

    .REFSEL                            (REFSEL                    ),
    .RESET_B                           (RESET_B                   ),

    .spi_write_start                   (locked                    ) 
);


//---------------------------------------------------------------------  
// freq_calc  
//--------------------------------------------------------------------- 
freq_calc
    u_freq_calc
    (
    .clk_50m                           (clk_50m                   ),
    .calc_clk                          (clk_2711_1                ),
    .rst_n                             (hw_reset_n                ),
    .freq_cnt                          (freq_2711_clk1            ) //  [19:0]
    );
         
 freq_calc
    u_freq_calc_1
    (
    .clk_50m                           (clk_50m                   ),
    .calc_clk                          (ddr3_ui_clk               ),
    .rst_n                             (hw_reset_n                ),
    .freq_cnt                          (freq_ddr3_ui_clk          ) //  [19:0]
    );

 freq_calc
    u_freq_calc_2
    (
    .clk_50m                           (clk_50m                   ),
    .calc_clk                          (pcie_axi_clk              ),
    .rst_n                             (hw_reset_n                ),
    .freq_cnt                          (freq_pcie_axi_clk         ) //  [19:0]
    );
    
//---------------------------------------------------------------------
// 初始化
//--------------------------------------------------------------------- 
    always@(posedge clk_100m or negedge hw_reset_n)begin
        if(!hw_reset_n)begin
            pw_on_r     <= 'd0;
            rst_cnt     <= 'd0;
        end
        else if(rst_cnt >= time_10ms)begin
            rst_cnt     <= rst_cnt;
        end
        else begin
            rst_cnt     <= rst_cnt + 'd1;
            case(rst_cnt)
                32'd200:begin
                    pw_on_r     <= 'd1;
                end
                default:begin
                    pw_on_r     <= pw_on_r;
                end
            endcase
        end
    end

generate
    begin : blk2711_clk_rst
        genvar  i;
        for (i = 0; i <= CHANNEL_NUM - 1; i = i + 1)
            begin : blk2711_clk_rst
                bk2711_clk_rst u_blk2711_clk_rst
                (
    .clk_100m                          (clk_100m                  ),
    .rx_100m                           (rx_100m[i]                ),
    .rx_200m                           (rx_200m[i]                ),
    .rxclk_locked                      (rxclk_locked[i]           ),
    .OE                                (OE[5*i+4:5*i]             ),
    .GTX_CLK                           (GTX_CLK[i]                ),
    .RX_CLK                            (RX_CLK[i]                 ),
    .rx_reset_n                        (rx_reset_n[i]             ) 
                );
      end
    end
endgenerate

always@(posedge clk_50m)
    begin
        rxclk_locked_r  <=  rxclk_locked;
        rxclk_locked_r2 <=  rxclk_locked_r;
    end
//---------------------------------------------------------------------  
// Debug 
//--------------------------------------------------------------------- 
vio_clk_rst vio_clk_rst (
    .clk                               (clk_50m                   ),// input wire clk
    .probe_in0                         (freq_2711_clk1            ),// input wire [19 : 0] probe_in0
    .probe_in1                         (freq_ddr3_ui_clk          ),// input wire [19 : 0] probe_in0
    .probe_in2                         (freq_pcie_axi_clk         ),// input wire [19 : 0] probe_in0
    .probe_in3                         (rxclk_locked_r2           ),// input wire [3 : 0] probe_in0
    .probe_in4                         (pcie_lnk_up_r2            ),// input wire [0 : 0] probe_in0
    .probe_in5                         (phy_init_done_r2          ),// input wire [0 : 0] probe_in0

    .probe_out0                        (vio_rst_n                 ) // output wire [0 : 0] probe_out0
);
endmodule
