`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/28 22:00:10
// Design Name: 
// Module Name: data_module
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


module data_module0(
        input           clk163m84,
        input           clk100m,
    
        input           rst_n,
        input [7:0]     down_gear,
        
        input [7:0]     data_in,
        input           data_en,
        
        output reg[7:0]    data_out,
        output reg         data_valid
    );
wire    fifo_gear_full;
wire    fifo_gear_empty;
wire    fifo_gear_en;
wire    fifo_gear_rd;
wire [7:0]  fifo_gear_out;

wire [7:0]  o_hs_data;
wire        o_hs_data_valid;

wire        fifo_wr_en;
wire        fifo_rd_en;
wire        fifo_full;
wire        fifo_empty;
wire [7:0]  fifo_out;   
wire        fifo_rst;

wire        wr_ml_end;
wire        wr_hs_end;
wire        i_ml_rd_flag;
wire        i_hs_rd_flag;
wire        o_ml_rd_en;
wire        o_hs_rd_en;

reg         rstn_r,rstn_rr;
reg [7:0]   w_down_gear_r,w_down_gear_rr;
reg [7:0]   data_in_r,data_in_rr;
reg         data_en_r,data_en_rr;
reg [7:0]   ml_data_in;
reg         ml_data_valid;
reg  [7:0]  hs_data_in;
reg         hs_data_valid;

wire [7:0]   test_fifo_out;
wire         test_fifo_valid;

//----------------delay
always @(posedge clk163m84)begin
    rstn_r  <= rst_n;
    rstn_rr <= rstn_r;
end 
always @(posedge clk163m84)begin
    data_in_r   <= data_in;
    data_in_rr  <= data_in_r;
end 
always @(posedge clk163m84)begin
    data_en_r  <= data_en;
    data_en_rr <= data_en_r;
end 

always @(posedge clk163m84)begin
    w_down_gear_r <= down_gear;
    w_down_gear_rr <= w_down_gear_r;
end 


always @(posedge clk163m84 or negedge rstn_rr)begin
    if(rstn_rr == 1'b0)begin
        ml_data_in        <=8'd0;
        ml_data_valid     <=1'b0;
        hs_data_in        <=8'd0;
        hs_data_valid     <=1'b0;
    end 
    else case(w_down_gear_rr)
        8'h42: begin
              ml_data_in        <=8'd0;
              ml_data_valid     <=1'b0;
              hs_data_in        <=data_in_rr;
              hs_data_valid     <=data_en_rr;
        end 
        8'h43:begin
             ml_data_in        <=8'd0;
             ml_data_valid     <=1'b0;
             hs_data_in        <=data_in_rr;
             hs_data_valid     <=data_en_rr;   
        end 
        8'h52,8'h51,8'h4F,8'h4E,8'h4D,8'h4C,8'h4B,8'h4A,8'h49:begin
             ml_data_in        <=data_in_rr;
             ml_data_valid     <=data_en_rr;
             hs_data_in        <=8'd0;
             hs_data_valid     <=1'b0;   
        
        end     
        default:begin
            ml_data_in        <=8'd0;
            ml_data_valid     <=1'b0;
            hs_data_in        <=8'd0;
            hs_data_valid     <=1'b0;
        end     
    endcase
end 


//--------------------------------------
assign fifo_gear_en = !fifo_gear_full;
assign fifo_gear_rd = !fifo_gear_empty;

fifo_gear fifo_gear_inst (
//  .rst(!rstn_rr),        // input wire rst
   .rst(fifo_rst),        // input wire rst
  .wr_clk(clk163m84),  // input wire wr_clk
  .rd_clk(clk100m),  // input wire rd_clk
  .din(down_gear),        // input wire [7 : 0] din
  .wr_en(fifo_gear_en),    // input wire wr_en
  .rd_en(fifo_gear_rd),    // input wire rd_en
  .dout(fifo_gear_out),      // output wire [7 : 0] dout
  .full(fifo_gear_full),      // output wire full
  .empty(fifo_gear_empty)    // output wire empty
);

//-------------------------------------------------


write_deal write_deal_inst(
     .clk163m84             (clk163m84),
     .rst_n                 (rstn_rr),
     .w_down_gear_r             (w_down_gear_r),
     .w_down_gear_rr            (w_down_gear_rr),
     
     .data_valid            (ml_data_valid),
     .data_in               (ml_data_in),
     .fifo_full            (fifo_full),
     
     .wr_ml_end             (wr_ml_end),
     .wr_hs_end             (wr_hs_end),
     .fifo_rst              (fifo_rst)

    );
    
  xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_ml_rd_flag_inst (
      .dest_out(i_ml_rd_flag), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk100m), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(clk163m84),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(wr_ml_end)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );

//  xpm_cdc_single #(
//      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
//      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
//      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
//      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
//   )
//   xpm_cdc_hs_rd_flag_inst (
//      .dest_out(i_hs_rd_flag), // 1-bit output: src_in synchronized to the destination clock domain. This output is
//                           // registered.

//      .dest_clk(clk100m), // 1-bit input: Clock signal for the destination clock domain.
//      .src_clk(clk163m84),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
//      .src_in(wr_hs_end)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
//   );     
 
    

read_deal read_deal_inst(
    .i_clk100m          (clk100m),
    .i_rst_n            (rst_n),
    .i_down_gear        (fifo_gear_out),
    
    .i_ml_rd_flag       (i_ml_rd_flag),
//    .i_hs_rd_flag       (i_hs_rd_flag),
    
    .i_fifo_out         (test_fifo_out),
    .i_fifo_valid       (test_fifo_valid),
    .fifo_empty          (fifo_empty),
    
    .o_ml_rd_en         (o_ml_rd_en),
    .o_hs_rd_en         (o_hs_rd_en)
    );


//-------------------------------------------------------

//assign fifo_wr_en = !fifo_full && data_en_rr && wr_en;
assign fifo_wr_en = !fifo_full && data_en_rr;
assign fifo_rd_en = !fifo_empty && (o_ml_rd_en || o_hs_rd_en);

fifo_tx_data fifo_tx_data_inst (
//  .rst(!rstn_rr),                      // input wire rstfifo_rst
   .rst(fifo_rst),                      // input wire rstfifo_rst
  .wr_clk(clk163m84),                // input wire wr_clk
  .rd_clk(clk100m),                // input wire rd_clk
  .din(ml_data_in),                      // input wire [7 : 0] din
  .wr_en(ml_data_valid),                  // input wire wr_en
  .rd_en(fifo_rd_en),                  // input wire rd_en
  .dout(fifo_out),                    // output wire [7 : 0] dout
  .full(fifo_full),                    // output wire full
  .almost_empty(),      // output wire almost_full
  .empty(fifo_empty),                  // output wire empty
  .rd_data_count(),  // output wire [12 : 0] rd_data_count
  .wr_data_count()  // output wire [12 : 0] wr_data_count
);



assign test_fifo_out = fifo_out;
assign test_fifo_valid = fifo_rd_en;


//-------------------------hs module
HighSpeed_mod HighSpeed_mod_inst(
    .i_clk163m84                    (clk163m84),
    .i_clk100m                      (clk100m),
    .i_rst_n                        (rstn_rr),
    .i_rstn                         (rst_n),
    
    .i_hspeed_in                    (hs_data_in),
    .i_hspeed_valid                 (hs_data_valid),
    
    .o_hs_data                      (o_hs_data),
    .o_hs_data_valid                (o_hs_data_valid)
    
    );
    
always @(posedge clk100m or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        data_out     <= 8'd0;
        data_valid   <= 1'b0;
    end 
    else case(fifo_gear_out)  
        8'h42: begin
            data_out        <=o_hs_data;
            data_valid      <=o_hs_data_valid;
        end 
        8'h43:begin
             data_out        <=o_hs_data;
             data_valid     <=o_hs_data_valid;
        end 
        8'h52,8'h51,8'h4F,8'h4E,8'h4D,8'h4C,8'h4B,8'h4A,8'h49:begin
             data_out        <=fifo_out;
             data_valid     <=fifo_rd_en;
        
        end     
        default:begin
            data_out        <=8'd0;
            data_valid     <=1'b0;
        end    
    endcase  

end 
  
// assign data_out   = fifo_out;
//assign data_valid = fifo_rd_en;   
endmodule
