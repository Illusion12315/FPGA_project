`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/08 09:25:23
// Design Name: 
// Module Name: Perio_Freq
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


module Perio_Freq(
    input                       i_clk       ,
    input                       i_rstn      ,
    input                       i_work_en   ,
    input                       i_test_clk  ,
    
    output  [15:0]              o_test_clk
    );
 
 /*******************parameter*********************/
 parameter                P_CLK   = 32'd100_000_000;
 parameter                P_IDLE  = 3'd0    ;
 parameter                P_START = 3'd1    ;
 parameter                P_CNT   = 3'd2    ;
    
 /*******************wire*************************/   
 wire                       pose_clk            ;
 wire   [63:0]              div_out             ;
 wire                       div_vaid            ;
 
 /*******************reg*************************/   
 reg                        i_rstn_r,i_rstn_r2;
 reg                        ri_test_clk_d1 =0 ;
 reg                        ri_test_clk_d2 =0 ;
 reg                        ri_work_en_d1  =0 ;
 reg                        ri_work_en_d2  =0 ;
 reg    [2 :0]              r_state           ;
 reg    [31:0]              r_cnt             ;
// reg    [31:0]              r_cnt_d1          ;
 reg    [15:0]              ro_freq           ;
 

 
 /*******************assign*************************/   
 assign pose_clk    = ~ri_test_clk_d2 && ri_test_clk_d1;
 assign o_test_clk   = ro_freq;
 
 /******************aways**************************/
 always @(posedge i_clk)
 begin
    i_rstn_r    <= i_rstn        ;
    i_rstn_r2   <= i_rstn_r    ;
 end 
 
 always @(posedge i_clk)
 begin
    ri_test_clk_d1 <= i_test_clk        ;
    ri_test_clk_d2 <= ri_test_clk_d1    ;
 end 
 
  always @(posedge i_clk)
 begin
    ri_work_en_d1 <= i_work_en        ;
    ri_work_en_d2 <= ri_work_en_d1    ;
 end 
 
 always @(posedge i_clk,negedge i_rstn_r2)begin
    if(!i_rstn_r2)begin
          r_state <= P_IDLE;  
          r_cnt   <= 'd0   ;
    end else case(r_state)
        P_IDLE :begin
            r_cnt <= 'd0;
            if(ri_work_en_d2)begin
                r_state <= P_START;
            end 
            else begin
                r_state <= r_state;
            end 
        end 
      
    
        P_START  :begin
            if(pose_clk)begin
                r_state <= P_CNT;
//                r_cnt   <= r_cnt +1;
            end
            else begin
                r_state <= r_state;
                r_cnt   <= r_cnt;
            end 
        end 
        P_CNT:begin
            if(pose_clk)begin
                r_state <= r_state;
                r_cnt   <= 'd0;
            end
           else if(ri_work_en_d2=='d0)begin
                r_state <= P_IDLE;
           end 
            else begin
                r_state <= r_state;
                r_cnt   <= r_cnt + 1;
            end 
        end 
        default: begin 
                r_state <= P_IDLE;
                r_cnt<= 'd0 ;end 
    endcase
 end 
 
// always @(posedge i_clk,negedge i_rstn_r2)begin
//    if(!i_rstn_r2)
//        r_cnt_d1 <= 'd0;
//    else 
//        r_cnt_d1 <=  r_cnt;
// end 
 

 
 div_gen_0 div_gen_0_inst (
  .aclk                     (i_clk),                                      // input wire aclk
  .s_axis_divisor_tvalid    (pose_clk),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata     (r_cnt),      // input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid   (pose_clk),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata    (P_CLK),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid       (div_vaid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata        (div_out)            // output wire [63 : 0] m_axis_dout_tdata
);

 always @(posedge i_clk,negedge i_rstn_r2)begin
    if(!i_rstn_r2)
        ro_freq <= 'd0;
    else if(div_vaid)
        ro_freq <= div_out[63:32];
    else 
        ro_freq <= ro_freq;
 end 
// ila_freq ila_freq_inst (
//	.clk(i_clk), // input wire clk


//	.probe0(o_test_clk), // input wire [63:0] probe0
//	.probe1(ri_test_clk_d1), // input wire [0:0]  probe1 
//	.probe2(ri_test_clk_d2), // input wire [0:0]  probe2 
//	.probe3(pose_clk), // input wire [0:0]  probe3 
//	.probe4(r_state), // input wire [2:0]  probe4 
//	.probe5(r_cnt), // input wire [31:0]  probe5
//	.probe6(ri_work_en_d2), // input wire [0:0]  probe5
//	.probe7(r_cnt_d1), // input wire [31:0]  probe5
//	.probe8(P_CLK) // input wire [31:0]  probe5
//);
endmodule
