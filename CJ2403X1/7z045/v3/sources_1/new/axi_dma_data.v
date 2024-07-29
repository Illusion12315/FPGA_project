`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/12 17:21:08
// Design Name: 
// Module Name: axi_dma_data
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


module axi_dma_data(
  input                             PL_CLK                 ,
  input [0:0]                       RESETn                 ,
  
  /************USER Interface**********************/
  // FIFO Interface for Packet Transmit
  output                            fifo_wrreq_pkt_tx       ,             // fifo write request
  output     [127:0]                fifo_data_pkt_tx        ,              // fifo write data
  input                             fifo_prog_full_pkt_tx   ,         // fifo program full
        
  // FIFO Interface for Packet Receive
  output                            fifo_rdreq_pkt_rx       ,             // fifo read request
  input      [127 :0]               fifo_q_pkt_rx           ,                 // fifo write data
  input                             fifo_empty_pkt_rx       ,             // fifo empty
  input                             fifo_prog_empty_pkt_rx  ,        // fifo program empty
  
  
  /***********AXI_Stream**************************/
  input [127:0]                     M_AXIS_MM2S_0_tdata     ,
  input [15 :0]                     M_AXIS_MM2S_0_tkeep     ,
  input                             M_AXIS_MM2S_0_tlast     ,
  output                            M_AXIS_MM2S_0_tready    ,
  input                             M_AXIS_MM2S_0_tvalid    ,

  output [31:0]                     S_AXIS_S2MM_0_tdata     ,
  output [3 :0]                     S_AXIS_S2MM_0_tkeep     ,
  output                            S_AXIS_S2MM_0_tlast     ,
  input                             S_AXIS_S2MM_0_tready    ,
  output                            S_AXIS_S2MM_0_tvalid     
    
    );
    

    
/*******************wire***********************************/
wire                               fifo_wr_full                ;
wire                               fifo_rd_empty               ;
wire                               fifo_wr_en                  ;
wire                               fifo_rd_en                  ;
wire [31:0]                        fifo_dout                   ;

/*******************reg***********************************/
  reg [3 :0]                       r_last_cnt                ;
  
 /*****************assign*********************************/
 assign fifo_wr_en               = !fifo_prog_empty_pkt_rx &&  !fifo_wr_full;
 assign fifo_rdreq_pkt_rx        = fifo_wr_en                               ;
 assign fifo_rd_en               = !fifo_rd_empty && S_AXIS_S2MM_0_tready   ;
 assign  S_AXIS_S2MM_0_tdata     = fifo_dout                                ;
 assign  S_AXIS_S2MM_0_tkeep     = 4'hf                                     ;
 assign  S_AXIS_S2MM_0_tlast     = (fifo_rd_en && r_last_cnt=='d15)?1'b1:1'b0   ;   
 assign  S_AXIS_S2MM_0_tvalid    = !fifo_rd_empty                           ;
 
 
 assign M_AXIS_MM2S_0_tready    = !fifo_prog_full_pkt_tx    ;
 assign fifo_data_pkt_tx        = M_AXIS_MM2S_0_tdata       ;
 assign fifo_wrreq_pkt_tx       = M_AXIS_MM2S_0_tvalid      ;
 
 
 dma_data_ds dma_data_ds_inst (
  .clk      (PL_CLK         ),      // input wire clk
  .srst     (!RESETn        ),    // input wire srst
  .din      (fifo_q_pkt_rx  ),      // input wire [127 : 0] din
  .wr_en    (fifo_wr_en     ),  // input wire wr_en
  .rd_en    (fifo_rd_en     ),  // input wire rd_en
  .dout     (fifo_dout      ),    // output wire [31 : 0] dout
  .full     (fifo_wr_full ),    // output wire full
  .empty    (fifo_rd_empty)  // output wire empty
);
 
 /******************always********************************/
 always @(posedge PL_CLK,negedge RESETn)begin
    if(!RESETn)
        r_last_cnt <= 'd0;
    else if(fifo_rd_en && r_last_cnt=='d15)
        r_last_cnt <= 'd0;
    else if(fifo_rd_en)
        r_last_cnt <= r_last_cnt + 1;
     else 
        r_last_cnt <= r_last_cnt;
 end    


 
//  always @(posedge PL_CLK,negedge RESETn)begin
//    if(!RESETn)
//        ri_S_AXIS_S2MM_0_tlast <= 'd0;
//    else if(fifo_rd_en && r_last_cnt=='d3)
//        ri_S_AXIS_S2MM_0_tlast <= 1;
//     else 
//         ri_S_AXIS_S2MM_0_tlast <= 'd0; 
// end   
 
    ila_axi_dma ila_axi_dma_inst (
	.clk   (PL_CLK), // input wire clk


	.probe0(M_AXIS_MM2S_0_tdata), // input wire [127:0]  probe0  
	.probe1(M_AXIS_MM2S_0_tkeep), // input wire [15:0]  probe1 
	.probe2(M_AXIS_MM2S_0_tlast), // input wire [0:0]  probe2 
	.probe3(M_AXIS_MM2S_0_tready), // input wire [0:0]  probe3 
	.probe4(M_AXIS_MM2S_0_tvalid), // input wire [0:0]  probe4 
	.probe5(r_last_cnt         ), // input wire [3:0]  probe9 
	.probe6(fifo_rdreq_pkt_rx  ), // input wire [0:0]  probe10
	.probe7(fifo_q_pkt_rx      ), // input wire [127:0]  probe10
	.probe8(fifo_wr_en        ), // input wire [0:0]  probe10
	.probe9(fifo_wr_full      ), // input wire [0:0]  probe10
	.probe10(S_AXIS_S2MM_0_tready ), // input wire [0:0]  probe10
	.probe11(fifo_rd_empty      ), // input wire [0:0]  probe10
	.probe12(S_AXIS_S2MM_0_tlast      ), // input wire [0:0]  probe10
	.probe13(fifo_dout      )// input wire [31:0]  probe10
); 
 

endmodule
