`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/25 10:50:29
// Design Name: 
// Module Name: sim_data_crc
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


module sim_data_crc(
  input                     AXI_CLk                 ,  
  input                     AXI_RSTN                ,  

  input [63:0]              M_AXIS_MM2S_0_tdata     ,
  input [7 :0]              M_AXIS_MM2S_0_tkeep     ,
  input                     M_AXIS_MM2S_0_tlast     ,
  output                    M_AXIS_MM2S_0_tready    ,
  input                     M_AXIS_MM2S_0_tvalid    ,
  
  output[63:0]              o_user_dout             ,
  output                    o_user_dout_valid
);

/***************reg***************/
//reg                    ro_M_AXIS_MM2S_0_tready  ;
reg [63 :0]            r_fifo_dout          ;
reg                    r_fifo_dout_valid    ;
//reg                    r_fifo_valid         ;
reg [63:0]             r_test_data64           ;
reg [31:0]             r_error_cnt           ;
reg                    r_rd_valid_1d =0        ;
/**************wire****************/
wire                   w_fifo_full             ;
wire                   w_fifo_empty            ;
wire                   w_fifo_valid            ;
wire                   w_fifo_rd_en            ;
wire [63:0]            w_fifo_dout             ;
wire                   w_negedge_pos           ;


//wire [63:0]            w_test_data64           ;

/***************assign***************/

assign  M_AXIS_MM2S_0_tready = !w_fifo_full;
assign  w_fifo_rd_en         = !w_fifo_empty ;

assign   o_user_dout         = w_fifo_dout   ;
assign   o_user_dout_valid   = w_fifo_valid  ;

assign   w_negedge_pos = !w_fifo_valid && r_rd_valid_1d;

//assign   w_test_data64    = {r_test_data32+1, r_test_data32} ;

/***************component***************/

fifo_generator_0 fifo_generator_0_inst (
  .clk      (AXI_CLk),      // input wire clk
  .srst     (!AXI_RSTN),    // input wire srst
  .din      (M_AXIS_MM2S_0_tdata),      // input wire [63 : 0] din
  .wr_en    (M_AXIS_MM2S_0_tvalid),  // input wire wr_en
  .rd_en    (w_fifo_rd_en),  // input wire rd_en
  .dout     (w_fifo_dout),    // output wire [63 : 0] dout
  .full     (w_fifo_full),    // output wire full
  .empty    (w_fifo_empty),  // output wire empty
  .valid    (w_fifo_valid)  // output wire valid
);
/***************always***************/




/********************CRC********************/
always @(posedge AXI_CLk,negedge AXI_RSTN)
begin
    if(!AXI_RSTN)begin
        r_fifo_dout <= 'd0;
    end else if(r_fifo_dout == 'd1310720)begin
        r_fifo_dout <='d0;
    end else if(w_fifo_valid)begin
        r_fifo_dout <=w_fifo_dout;
    end else begin
        r_fifo_dout <= r_fifo_dout;
    end 
end 

always @(posedge AXI_CLk)
begin
    r_rd_valid_1d <= w_fifo_valid;
end 

always @(posedge AXI_CLk,negedge AXI_RSTN)
begin
    if(!AXI_RSTN)
        r_test_data64 <= 'd0;
    else if(r_test_data64=='d1310720)
       r_test_data64 <= 'd0;
    else if(w_fifo_valid)
        r_test_data64 <= r_test_data64 + 1;
    else 
        r_test_data64 <=r_test_data64;
end 

always @(posedge AXI_CLk,negedge AXI_RSTN)
begin
    if(!AXI_RSTN)
        r_error_cnt <= 'd0;
    else if(w_fifo_valid)
        if(r_test_data64 != r_fifo_dout)
            r_error_cnt <= r_error_cnt +1;
        else
            r_error_cnt <= 'd0;
    else 
        r_error_cnt <= r_error_cnt;
end  

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
                if(down_time_cnt == 199_999_999)
                    begin                        
                        down_data_v_MB   <= down_data_v_cnt >> 17;      // 速率单位： MB/s     
                        down_data_v_cnt  <= 0;
                        down_time_cnt    <= 0;
                    end
                else
                    begin
                        down_data_v_MB   <= down_data_v_MB;
                        down_time_cnt    <= down_time_cnt + 1'b1;
                        if(w_fifo_valid)
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


ila_crc ila_crc_inst (
	.clk       (AXI_CLk), // input wire clk


	.probe0    (r_test_data64), // input wire [63:0]  probe0  
	.probe1    (w_fifo_dout), // input wire [63:0]  probe1 
	.probe2    (down_time_cnt), // input wire [31:0]  probe2 
	.probe3    (r_error_cnt), // input wire [31:0]  probe3 
	.probe4    (w_fifo_valid), // input wire [0:0]  probe4 
	.probe5    (M_AXIS_MM2S_0_tlast), // input wire [0:0]  probe5 
	.probe6    (M_AXIS_MM2S_0_tready), // input wire [0:0]  probe6
	.probe7    (down_data_v_MB), // input wire [15:0]  probe7 
	.probe8    (down_data_v_cnt),// input wire [31:0]  probe8 
	.probe9    (r_fifo_dout) // input wire [31:0]  probe9
);


endmodule
