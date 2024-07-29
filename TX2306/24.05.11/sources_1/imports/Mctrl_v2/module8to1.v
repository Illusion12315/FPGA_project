`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/14 21:38:43
// Design Name: 
// Module Name: module8to1
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


module module8to1(
    input   wire            clk163m84,
    input   wire            clk20m,
    input   wire            rst_n,
    input   wire            rstn,
    
    input   wire  [7:0]     i_data_in,
    input   wire            i_data_vald,
    
    output  wire            o_data8to1,
    output  wire            o_data8to1_valid
    );

parameter       IDLE  =  4'd0,
                 START  = 4'd1,
                 WAIT   = 4'd2;


  
wire           neg_data_vald;
wire           xpm_read_flag;

wire            fifo_full;
wire            fifo_empty;
wire            fifo_wr_en;
wire            fifo_rd_en;
wire            fifo_dout;
wire [7:0]      fifo_in;


reg [7:0]       i_data_in_r,i_data_in_rr;
reg             i_data_vald_r,i_data_vald_rr;
reg             r_rd_en;
reg [3:0]       r_dcnt;
reg [3:0]       r_neg_dcnt;
reg             r_neg_valid;
reg [3:0]       r_scnt;

reg [3:0]       r_state;




assign neg_data_vald = !i_data_vald_r && i_data_vald_rr;

always @(posedge clk163m84)begin
    i_data_in_r     <= i_data_in;
    i_data_in_rr    <= i_data_in_r;
end 

always @(posedge clk163m84)begin
    i_data_vald_r <= i_data_vald;
    i_data_vald_rr <= i_data_vald_r;
end 

always @(posedge clk163m84 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        r_neg_dcnt <= 4'd0;
        r_neg_valid <= 1'b0;
        
        r_scnt <= 4'd0;
        
    end 
    else case(r_scnt)
    4'd0:begin
        r_neg_dcnt <= 4'd0;
        r_neg_valid <= 1'b0;
        
        if(neg_data_vald==1'b1)begin
            r_scnt <= 4'd1;
        end 
        else begin
            r_scnt <= 4'd0;
        end 
    end 
    4'd1:begin
        if(r_neg_dcnt == 4'd12)begin
            r_neg_dcnt <= 4'd0;
            r_neg_valid <= 1'b0;
            
            r_scnt      <= 4'd0;
        end 
        else begin
          r_neg_dcnt <= r_neg_dcnt + 1'b1;
          r_neg_valid <= 1'b1;
          
          r_scnt      <= r_scnt;
        end 
    end 
    default:begin
        r_neg_dcnt <= 4'd0;
        r_neg_valid <= 1'b0;
        
        r_scnt <= 4'd0;
    end 
    endcase
end 



xpm_cdc_single #(
  .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
  .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
  .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
  .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
)
xpm_cdc_single_inst (
  .dest_out(xpm_read_flag), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                       // registered.

  .dest_clk(clk20m), // 1-bit input: Clock signal for the destination clock domain.
  .src_clk(clk163m84),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
  .src_in(r_neg_valid)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
//  .src_in(xor_data_vald)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
); 
    
//-------------------------------------------------------------
assign fifo_wr_en = !fifo_full && i_data_vald_rr;
assign fifo_rd_en = r_rd_en;
//assign fifo_in ={i_data_in_rr[0],i_data_in_rr[1],i_data_in_rr[2],i_data_in_rr[3],i_data_in_rr[4],i_data_in_rr[5],i_data_in_rr[6],i_data_in_rr[7]};
assign fifo_in =i_data_in_rr;
fifo_8to1 fifo_8to1_inst (
  .rst(!rst_n),                    // input wire rst
  .wr_clk(clk163m84),              // input wire wr_clk
  .rd_clk(clk20m),              // input wire rd_clk
  .din(fifo_in),                    // input wire [7 : 0] din
  .wr_en(fifo_wr_en),                // input wire wr_en
  .rd_en(fifo_rd_en),                // input wire rd_en
  .dout(fifo_dout),                  // output wire [0 : 0] dout
  .full(fifo_full),                  // output wire full
  .empty(),                // output wire empty
  .almost_empty(fifo_empty)  // output wire almost_empty
);

//ila_8to1 ila_8to1_inst (
//	.clk(clk20m), // input wire clk


//	.probe0(o_data8to1), // input wire [0:0]  probe0  
//	.probe1(o_data8to1_valid), // input wire [0:0]  probe1 
//	.probe2(fifo_rd_en), // input wire [0:0]  probe2 
//	.probe3(fifo_empty), // input wire [0:0]  probe3 
//	.probe4(r_state), // input wire [3:0]  probe4 
//	.probe5(r_dcnt), // input wire [3:0]  probe5 
//	.probe6(r_rd_en), // input wire [0:0]  probe6 
//	.probe7(xpm_read_flag)// input wire [0:0]  probe7 
////	.probe8(probe8), // input wire [3:0]  probe8 
////	.probe9(probe9), // input wire [0:0]  probe9 
////	.probe10(probe10), // input wire [3:0]  probe10 
////	.probe11(probe11), // input wire [3:0]  probe11 
////	.probe12(probe12) // input wire [0:0]  probe12
//);

always @(posedge clk20m or negedge rstn)begin
    if(rstn == 1'b0)begin
        r_state <= 4'd0;
        r_dcnt  <= 4'd0;
        r_rd_en <= 1'b0;
    end 
    else case(r_state)
        IDLE:begin
            r_rd_en <= 1'b0;
            r_dcnt  <= 4'd0;
            
            if(xpm_read_flag==1'b1)begin
                r_state <= START;
            end     
            else begin
                r_state <= IDLE;
            end 
        end 
        START:begin
            r_dcnt  <= 4'd0;
            if(fifo_empty==1'b1)begin
                r_rd_en <= 1'b0;
                
                r_state  <= WAIT;
            end 
            else begin
                r_rd_en <= 1'b1;
                
                r_state <= START;
            end 
        end 
    WAIT:begin
        if(r_dcnt  == 4'd7)begin
            r_dcnt  <= 4'd0;
            
            r_state <= IDLE;
        end 
        else begin
            r_dcnt <= r_dcnt + 1'b1;
            
            r_state <= r_state;
        end 
    end 
    default:begin
        r_state <= 4'd0;
        r_dcnt  <= 4'd0;
        r_rd_en <= 1'b0;
    end 
    endcase
end 
    
//assign o_data8to1 = fifo_dout;
assign o_data8to1 = fifo_dout;
assign o_data8to1_valid = fifo_rd_en;



endmodule
