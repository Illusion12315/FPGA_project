`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/26 17:34:15
// Design Name: 
// Module Name: sim_data_fifo
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


module sim_data_fifo(

  input [31:0]              P_TRANS_LENS        ,
//  input                     data_cap_en         ,      
  input                     AXI_CLk              ,  
  input                     AXI_RSTN             ,  
  
  output [63:0]             S_AXIS_0_tdata      ,
  output [7 :0]             S_AXIS_0_tkeep      ,
  output                    S_AXIS_0_tlast      ,
  input                     S_AXIS_0_tready     ,
  output                    S_AXIS_0_tvalid     
    );
/***************wire***************/    
wire                        w_fifo_full     ;
wire                        w_fifo_rd_en    ;
wire                        w_fifo_empty    ;
wire [63:0]                 w_fifo_dout     ;
//wire                        w_fifo_valid    ;
wire [63:0]                 w_fifo_din      ;
/***************reg***************/  
reg [63:0]                  r_fifo_in       ;
reg                         r_fifo_wr_en    ;
reg                         r_data_last     ;
reg [31:0]                  r_rd_cnt        ;
//reg                         r_rd_flag       ;


/***************assign***************/  
assign  S_AXIS_0_tdata = w_fifo_dout        ;
assign  S_AXIS_0_tvalid= w_fifo_rd_en       ;
assign  S_AXIS_0_tkeep = 'hff               ;
assign  S_AXIS_0_tlast = r_data_last        ;

//assign  w_fifo_din = {r_fifo_in+1, r_fifo_in} ;

//assign w_fifo_rd_en = !w_fifo_empty && S_AXIS_0_tready && r_rd_flag;
assign w_fifo_rd_en = !w_fifo_empty && S_AXIS_0_tready ;
/***************component***************/

fifo_sim_gen fifo_sim_gen_inst (
  .clk      (AXI_CLk),      // input wire clk
  .srst     (!AXI_RSTN),    // input wire srst
  .din      (r_fifo_in),      // input wire [63 : 0] din
  .wr_en    (r_fifo_wr_en),  // input wire wr_en
  .rd_en    (w_fifo_rd_en),  // input wire rd_en
  .dout     (w_fifo_dout),    // output wire [63 : 0] dout
  .full     (w_fifo_full),    // output wire full
  .empty    (w_fifo_empty) // output wire empty
//  .valid    (w_fifo_valid)  // output wire valid
);

//fifo_sim_gen your_instance_name (
//  .clk(clk),      // input wire clk
//  .srst(srst),    // input wire srst
//  .din(din),      // input wire [63 : 0] din
//  .wr_en(wr_en),  // input wire wr_en
//  .rd_en(rd_en),  // input wire rd_en
//  .dout(dout),    // output wire [63 : 0] dout
//  .full(full),    // output wire full
//  .empty(empty),  // output wire empty
//  .valid(valid)  // output wire valid
//);

/*********************always*************/
always @(posedge AXI_CLk,negedge AXI_RSTN)
begin
    if(!AXI_RSTN)
       r_fifo_in <= 'd0;
    else if(r_fifo_in == P_TRANS_LENS)
       r_fifo_in <= 'd0;
    else if( !w_fifo_full)
       r_fifo_in <= r_fifo_in+1;
    else 
       r_fifo_in <=r_fifo_in;
end 

always @(posedge AXI_CLk,negedge AXI_RSTN)
begin
    if(!AXI_RSTN)
       r_fifo_wr_en <= 'd0;
    else if(r_fifo_in== P_TRANS_LENS)
       r_fifo_wr_en <= 'd0;
    else if( !w_fifo_full)
       r_fifo_wr_en <= 'd1;
    else 
       r_fifo_wr_en <=r_fifo_wr_en;
end

always @(posedge AXI_CLk,negedge AXI_RSTN)
begin
    if(!AXI_RSTN)
        r_rd_cnt <= 'd0;
    else if(r_rd_cnt == P_TRANS_LENS-1)
        r_rd_cnt <='d0;
    else if( w_fifo_rd_en)
        r_rd_cnt <= r_rd_cnt +1;
     else
        r_rd_cnt <= r_rd_cnt;
end 

//always @(posedge AXI_CLk,negedge AXI_RSTN)
//begin
//    if(!AXI_RSTN)
//        r_rd_flag <='d1;
//    else if(r_rd_cnt == P_TRANS_LENS-1)
//         r_rd_flag <='d0;
//    else 
//         r_rd_flag <='d1;
//end 

always @(posedge AXI_CLk,negedge AXI_RSTN)
begin
    if(!AXI_RSTN)
        r_data_last <='d0;
    else if(r_rd_cnt == P_TRANS_LENS-2)
        r_data_last <='d1;
    else 
        r_data_last <='d0;
end 


/*********************************************************/
/*********************Rate****************************/
    reg         [15:0]                      down_data_v_MB;
    reg         [31:0]                      down_data_v_cnt;
    reg         [31:0]                      down_time_cnt;
    
always@(posedge AXI_CLk or negedge AXI_RSTN)
    begin
        if(!AXI_RSTN)
            begin
                down_data_v_MB   <= 0;
                down_data_v_cnt  <= 0;
                down_time_cnt    <= 0;
            end
        else
            begin
                if(down_time_cnt == 999_999)
                    begin                        
                        down_data_v_MB   <= down_data_v_cnt >> 17;      // 速率单位： MB/s     
                        down_data_v_cnt  <= 0;
                        down_time_cnt    <= 0;
                    end
                else
                    begin
                        down_data_v_MB   <= down_data_v_MB;
                        down_time_cnt    <= down_time_cnt + 1'b1;
                        if(S_AXIS_0_tvalid)
                            begin
                                down_data_v_cnt    <= down_data_v_cnt + 1'b1;
                            end
                        else
                            begin
                                down_data_v_cnt    <= down_data_v_cnt;
                            end
                    end
            end
    end


 ila_test ila_test_inst (
	.clk       (AXI_CLk        ), // input wire clk


	.probe0    (S_AXIS_0_tdata ), // input wire [63:0]  probe0  
	.probe1    (S_AXIS_0_tkeep ), // input wire [7:0]  probe1 
	.probe2    (S_AXIS_0_tlast ), // input wire [0:0]  probe2 
	.probe3    (S_AXIS_0_tready), // input wire [0:0]  probe3 
	.probe4    (S_AXIS_0_tvalid), // input wire [0:0]  probe4 
	.probe5    (down_data_v_MB ),// input wire [15:0]  probe5 
	.probe6    (down_data_v_cnt), // input wire [2:0]  probe6
	.probe7    (down_time_cnt  ), // input wire [2:0]  probe6
	.probe8    (P_TRANS_LENS  ), // input wire [2:0]  probe6
	.probe9    (r_fifo_in     ), // input wire [2:0]  probe6
	.probe10   (r_fifo_wr_en  ) // input wire [2:0]  probe6
);


    
endmodule
