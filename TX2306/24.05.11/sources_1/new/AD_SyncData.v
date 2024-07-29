`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/20 21:37:08
// Design Name: 
// Module Name: AD_SyncData
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


module AD_SyncData(
   input  wire [13:0]    sub_value,

   input  wire           ad_rst_n,
   
   input  wire           adc_clk100m,
   input  wire           adc_clk_b,
   input  wire [13:0]    adc_data_a,
   input  wire [13:0]    adc_data_b,
   
   output wire [13:0]   ad_data_i,
   output wire [13:0]   ad_data_q,
   output wire          ad_data_valid
    );
    
 ///---------------fifo_data
    wire        full_A;
    wire        empty_A;
    wire [13:0] fifo_out_A;
    wire        fifo_rden_A;
    
    wire        full_B;
    wire        empty_B;
    wire [13:0] fifo_out_B;
    wire        fifo_rden_B;
    
    wire        fifo_out_valid_A;
    wire        fifo_out_valid_B;
    
    wire        fifo_rden;
    
/************reg*********************/
    
    reg [13:0]  fifo_out_I = 0;
    reg [13:0]  fifo_out_Q = 0;
    reg         fifo_out_valid =0;
    reg [31:0]   en_cnt;         
    reg         fifo_wr_en;
    
//    assign fifo_rden_A = !empty_A;
//    assign fifo_rden_B = !empty_B;

    always @(posedge adc_clk100m or negedge ad_rst_n)begin
        if(ad_rst_n ==1'b0)begin
            en_cnt  <= 32'd0;
        end
        else if(en_cnt == 32'd100_000_000)begin
            en_cnt <= en_cnt;
        end
        else begin
            en_cnt <= en_cnt + 1'b1;
        end
    end
    
    always @(posedge adc_clk100m or negedge ad_rst_n)begin
        if(ad_rst_n ==1'b0)begin
            fifo_wr_en <= 1'b0;
        end 
        else if(en_cnt == 32'd100_000_000)begin
            fifo_wr_en <= 1'b1;
        end
        else begin
            fifo_wr_en <= 1'b0;
        end 
    end
    
    assign fifo_rden = !empty_A && (!empty_B);
    
    fifo_AD fifo_AD_instA (
      .rst(!ad_rst_n),        // input wire rst
      .wr_clk(adc_clk100m),  // input wire wr_clk
      .rd_clk(adc_clk100m),  // input wire rd_clk
      .din (adc_data_a),        // input wire [13 : 0] din
      .wr_en(fifo_wr_en),    // input wire wr_en
      .rd_en(fifo_rden),    // input wire rd_en
      .dout(fifo_out_A),      // output wire [13 : 0] dout
      .full(full_A),      // output wire full
      .empty(empty_A) ,   // output wire empty
       .valid(fifo_out_valid_A)    // output wire valid
    );  
    
    fifo_AD fifo_AD_instB (
      .rst(!ad_rst_n),        // input wire rst
      .wr_clk(adc_clk_b),  // input wire wr_clk
      .rd_clk(adc_clk100m),  // input wire rd_clk
      .din  (adc_data_b),        // input wire [13 : 0] din
      .wr_en(fifo_wr_en),    // input wire wr_en
      .rd_en(fifo_rden),    // input wire rd_en
      .dout(fifo_out_B),      // output wire [13 : 0] dout
      .full(full_B),      // output wire full
      .empty(empty_B) ,   // output wire empty
       .valid()    // output wire valid
    ); 
    
    //---------------------------
// wire [13:0]   value_a;
// wire [13:0]   value_b;
// vio_ad vio_ad_inst (
//      .clk(adc_clk100m),                // input wire clk
//      .probe_out0(value_a),  // output wire [13 : 0] probe_out0
//      .probe_out1(value_b)  // output wire [13 : 0] probe_out1
//    );   
    
//    wire        fifo_full;
//    wire        fifo_empty;
//    wire        fifo_wren;
//    wire        fifo_rden;
//    wire [23:0] fifo_out;
    
    
//    assign fifo_wren = fifo_rden_A && fifo_rden_B && !fifo_full;
//    assign fifo_rden = !fifo_empty;
    
//    fifo_AD_IQ fifo_AD_IQ_inst (
//      .clk(adc_clk100m),      // input wire clk
//      .srst(!ad_rst_n),    // input wire srst
//      .din({fifo_out_A,fifo_out_B}),      // input wire [23 : 0] din
//      .wr_en(fifo_wren),  // input wire wr_en
//      .rd_en(fifo_rden),  // input wire rd_en
//      .dout(fifo_out),    // output wire [23 : 0] dout
//      .full(fifo_full),    // output wire full
//      .empty(fifo_empty)  // output wire empty
//    );


always @(posedge adc_clk100m)begin
    fifo_out_I <= {~{fifo_out_A[13]},fifo_out_A[12:0]};
    fifo_out_Q <= {~{fifo_out_B[13]},fifo_out_B[12:0]};
    fifo_out_valid <= fifo_out_valid_A;
end 


assign ad_data_i = fifo_out_I;
assign ad_data_q = fifo_out_Q;
assign ad_data_valid = fifo_out_valid;


//always @(posedge adc_clk100m or negedge ad_rst_n)begin
//    if(ad_rst_n ==1'b0)begin
//        ad_data_i <= 14'd0;
//        ad_data_q <= 14'd0;
//        ad_data_valid <= 1'b0;
//    end 
//    else begin
////        ad_data_i <= fifo_out_A- sub_value;
////        ad_data_q <= fifo_out_B- sub_value;
        
//        ad_data_i <= {~{fifo_out_A[13]},fifo_out_A[12:0]};
//        ad_data_q <= {~{fifo_out_B[13]},fifo_out_B[12:0]};
 
//        ad_data_valid <= fifo_out_valid_A;
//    end 
////    else begin
////        ad_data_i <= ad_data_i;
////        ad_data_q <= ad_data_q;
////        ad_data_valid <= 1'b0;
////    end 
//end 
    
//    assign ad_data_i = fifo_out[23:14];
//    assign ad_data_q = fifo_out[13:0];
//    assign ad_data_valid = fifo_rden;
    
//    ila_adIQ ila_adIQ_inst (
//        .clk(adc_clk100m), // input wire clk
    
    
//        .probe0(fifo_rden_A), // input wire [0:0]  probe0  
//        .probe1(fifo_out_A), // input wire [13:0]  probe1 
//        .probe2(fifo_rden_B), // input wire [0:0]  probe2 
//        .probe3(fifo_out_B), // input wire [13:0]  probe3 
//        .probe4(ad_data_valid), // input wire [0:0]  probe4 
//        .probe5(ad_data_i), // input wire [13:0]  probe5 
//        .probe6(ad_data_q), // input wire [13:0]  probe6
//        .probe7(sub_value) // input wire [13:0]  probe6
//    );   
    
endmodule