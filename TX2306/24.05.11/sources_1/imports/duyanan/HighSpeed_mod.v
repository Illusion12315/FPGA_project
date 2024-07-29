`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/18 18:50:28
// Design Name: 
// Module Name: HighSpeed_mod
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


module HighSpeed_mod(
    input       wire            i_clk163m84,
    input       wire            i_clk100m,
    input       wire            i_rst_n,
    input       wire            i_rstn,
    
    input       wire  [7:0]      i_hspeed_in,
    input       wire             i_hspeed_valid,
    
    output      wire  [7:0]      o_hs_data,
    output      wire             o_hs_data_valid
    
    );
 parameter  H_IDLE  = 4'd0;
 parameter  H_START = 4'd1;
 parameter  H_WAIT  = 4'd2;
 
 reg [3:0]  h_state;
 
 
 wire         fifo_wr_en;
 wire         fifo_empty;
 wire         fifo_full;
 wire         fifo_rd_en;
 wire [7:0]   fifo_out;
 
 wire         nege_valid_flag;
 wire         xpm_read_flag;
    
 reg [7:0]     i_hspeed_in_r,i_hspeed_in_rr;
 reg           i_hspeed_valid_r,i_hspeed_valid_rr;
 reg           rd_en;
 reg [3:0]     delay_cnt;
 
 reg           nege_flag_fast;
 reg  [2:0]    nege_flag_slow_r;
 
 reg  [2:0]    s_cnt;
 reg  [2:0]    delay_flag_cnt;
 reg           delay_flag;
 
//always @(posedge i_clk163m84 or negedge i_rst_n)begin
//    if(i_rst_n ==1'b0)begin
//        nege_flag_fast <= 1'b0;
//    end 
//    else 
//        nege_flag_fast <= nege_valid_flag ? (~nege_flag_fast):nege_flag_fast;
//end 
 
 
// always @(posedge i_clk100m or negedge i_rstn)begin
//    if(i_rstn ==1'b0)begin
//        nege_flag_slow_r <= 3'd0;
//    end 
//    else begin
//        nege_flag_slow_r <= {nege_flag_slow_r[1:0],nege_flag_fast};
//    end 
// end 
 
// assign xpm_read_flag = nege_flag_slow_r[2] ^nege_flag_slow_r[1];

always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(i_rst_n ==1'b0)begin
        s_cnt          <= 3'd0;
        
        delay_flag_cnt <= 3'd0;
        delay_flag     <= 1'b0;
    end 
    else case(s_cnt)
        3'd0:begin
            delay_flag_cnt <= 3'd0;
            delay_flag     <= 1'b0;
            
            if(nege_valid_flag==1'b1)begin
                s_cnt  <= 3'd1;
            end 
            else begin
                s_cnt  <= 3'd0;
            end 
        end 
        3'd1:begin
            if(delay_flag_cnt == 3'd7)begin
                delay_flag_cnt <= 3'd0;
                delay_flag     <= 1'b0;
                s_cnt           <= 3'd0;
            end 
            else begin
                delay_flag_cnt <= delay_flag_cnt + 1'b1;
                delay_flag     <= 1'b1;
                
                s_cnt  <= 3'd1;
            end 
            
        end 
        default:begin
            s_cnt          <= 3'd0;
        
            delay_flag_cnt <= 3'd0;
            delay_flag     <= 1'b0;
        end 
    
    endcase
        
end 
 
 
xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_valid_single_inst (
      .dest_out(xpm_read_flag), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(i_clk100m), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(i_clk163m84),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(delay_flag)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );
 
 always @(posedge i_clk163m84)begin
    i_hspeed_in_r <= i_hspeed_in;
    i_hspeed_in_rr <= i_hspeed_in_r;
 end    

always @(posedge i_clk163m84)begin
    i_hspeed_valid_r <= i_hspeed_valid;
    i_hspeed_valid_rr <= i_hspeed_valid_r;
end 

assign nege_valid_flag = !i_hspeed_valid_r && i_hspeed_valid_rr;
  

assign   fifo_wr_en = !fifo_full && i_hspeed_valid_rr;
assign   fifo_rd_en = rd_en;

//ila_hs_wr ila_hs_wr_inst (
//	.clk(i_clk163m84), // input wire clk


//	.probe0(i_hspeed_in_rr), // input wire [7:0]  probe0  
//	.probe1(i_hspeed_valid_rr), // input wire [0:0]  probe1 
//	.probe2(fifo_full), // input wire [0:0]  probe2 
//	.probe3(fifo_wr_en), // input wire [0:0]  probe3 
//	.probe4(nege_valid_flag) // input wire [0:0]  probe4
//);

fifo_tx_data fifo_tx_data_inst (
  .rst(!i_rst_n),                      // input wire rst
  .wr_clk(i_clk163m84),                // input wire wr_clk
  .rd_clk(i_clk100m),                // input wire rd_clk
  .din(i_hspeed_in_rr),                      // input wire [7 : 0] din
  .wr_en(fifo_wr_en),                  // input wire wr_en
  .rd_en(fifo_rd_en),                  // input wire rd_en
  .dout(fifo_out),                    // output wire [7 : 0] dout
  .full(fifo_full),                    // output wire full
  .almost_empty(fifo_empty),      // output wire almost_full
  .empty(),                  // output wire empty
  .rd_data_count(),  // output wire [12 : 0] rd_data_count
  .wr_data_count()  // output wire [12 : 0] wr_data_count
);

always @(posedge i_clk100m or negedge i_rstn)begin
    if(i_rstn==1'b0)begin
        h_state  <= H_IDLE;
        
        delay_cnt <= 4'd0;
        rd_en    <= 1'b0;
    end 
    else case(h_state)
        H_IDLE:begin
             delay_cnt <= 4'd0;
            if(xpm_read_flag==1'b1)begin
                h_state <= H_START;
            end 
            else begin
                h_state <= H_IDLE;
            end 
        end 
        H_START:begin
             delay_cnt <= 4'd0;
             if(fifo_empty==1'b1)begin
                rd_en <= 1'b0;
                
                h_state <= H_WAIT;
             end 
             else begin
                rd_en <= 1'b1;
                
                h_state <= h_state;
             end 
        end 
        H_WAIT:begin
            if( delay_cnt == 4'd5)begin
                delay_cnt <= 4'd0;
                
                h_state <= H_IDLE;
            end 
           else begin
                delay_cnt <= delay_cnt + 1'b1;
                
                h_state <= h_state;
           end 
        end 
        default:begin
            h_state <= H_IDLE;
        end 
    endcase
end 

assign o_hs_data_valid = fifo_rd_en;
assign o_hs_data       = fifo_out;

// ila_hs_data ila_hs_data_inst (
//	.clk(i_clk100m), // input wire clk


//	.probe0(o_hs_data), // input wire [7:0]  probe0  
//	.probe1(o_hs_data_valid), // input wire [0:0]  probe1 
//	.probe2(h_state), // input wire [3:0]  probe2 
//	.probe3(xpm_read_flag), // input wire [0:0]  probe3 
//	.probe4(rd_en), // input wire [0:0]  probe4 
//	.probe5(fifo_empty) // input wire [0:0]  probe5
//);

//---------------------
//reg [15:0]  wr_cnt;

//always @(posedge i_clk163m84 or negedge i_rstn)begin
//    if(i_rstn == 1'b0)begin
//        wr_cnt <= 16'd0;
//    end 
//    else if(
//end 

    
endmodule
