`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/06 19:40:45
// Design Name: 
// Module Name: blk2711_fsm
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

module blk2711_fsm(
    input                       rx_100m,
    input                       log_rst_n,
 
    input                       rx_reset_n,
    
    input                       pw_rst_done,
    input  [15:0]               send_data_num,
    input  [15:0]               send_k_num, 
      
    input  [15:0]               frame_header,   
    input  [15:0]               frame_tail,   
  
    output                      frame_start_flag,            
    
    input                       fifo_us_rdclk,
    input                       fifo_us_empty,   
    output                      fifo_us_rdreq,
    input [15:0]                fifo_us_q,

    input                       fifo_ds_wrclk,
    input                       fifo_ds_prog_full,    
    output [7:0]                fifo_ds_rx_data,
    output                      fifo_ds_wrreq,

//------------ DATA & DATA_CTRL ------------//
    output                      TKMSB,
    output                      TKLSB,
    input                       RKMSB,
    input                       RKLSB,
    
    output  [15:0]              TX_Data,
    input   [15:0]              RX_Data

    );
    
//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------  
reg [4:0]   tx_state            = 'd0;
reg [15:0]  state_cnt           = 'd0;
reg         TKMSB_r,TKLSB_r     = 'd0;
reg [15:0]  TX_Data_r           = 'd0;
reg         fifo_us_rdreq_r     = 'd0;

//
wire        fifo_xfer_full;
reg         fifo_xfer_wr_en     = 'd0;
reg [17:0]  fifo_xfer_din       = 'd0;

wire        fifo_xfer_empty;
wire        fifo_xfer_rd_en;
wire [8:0]  fifo_xfer_q;

reg [15:0]  rx_data_r               = 'd0;
reg         RKMSB_r = 1'b1,RKLSB_r  = 'd1;    
reg         fifo_ds_wrreq_r         = 'd0;
reg [7:0]   fifo_ds_rx_data_r       = 'd0;


//---------------------------------------------------------------------  
// Parameter
//---------------------------------------------------------------------     
localparam  TX_INIT        = 5'h0;
localparam  TX_IDLE        = 5'h1;
localparam  TX_SYNC_WAIT   = 5'h2;
localparam  TX_HEADER      = 5'h3;
localparam  TX_DATA_SEND   = 5'h4;
localparam  TX_TAIL        = 5'h5;

//---------------------------------------------------------------------
// Assign
//---------------------------------------------------------------------
assign      TKMSB           = TKMSB_r;
assign      TKLSB           = TKLSB_r;
assign      TX_Data         = TX_Data_r;

assign      frame_start_flag = (tx_state == TX_HEADER);

//---------------------------------------------------------------------
// Data Tx
//--------------------------------------------------------------------- 
// tx_state
always@(posedge fifo_us_rdclk or negedge log_rst_n)begin
    if(!log_rst_n)begin
        tx_state        <= 'd0;
    end
    else begin
        case(tx_state)
            TX_INIT:begin
                if(pw_rst_done)begin
                    tx_state    <= TX_IDLE;
                end
            end
            
            TX_IDLE:begin
                if(!fifo_us_empty)begin
                    tx_state    <= TX_SYNC_WAIT;
                end
                else begin
                    tx_state    <= tx_state;
                end
            end
            
            TX_SYNC_WAIT:begin
                if(state_cnt >= send_k_num - 'd1)begin
                    tx_state    <= TX_HEADER;
                end
                else begin
                    tx_state    <= tx_state;
                end
            end
            
            TX_HEADER: begin
                tx_state    <= TX_DATA_SEND;
            end
            
            TX_DATA_SEND:begin
                if(state_cnt >= send_data_num- 'd1 )begin
                    tx_state    <= TX_TAIL;
                end
                else if(fifo_us_rdreq_r)begin
                    tx_state    <= tx_state;
                end
                else begin
                    tx_state    <= tx_state;
                end
            end
 
            TX_TAIL: begin
                tx_state    <= TX_IDLE;
            end            
            
            default:begin
                tx_state    <= TX_INIT;
            end
        endcase
    end
end   
//state_cnt
always@(posedge fifo_us_rdclk or negedge log_rst_n)begin
    if(!log_rst_n)begin
        state_cnt       <= 'd0;
    end
    else begin
        case(tx_state)
            TX_INIT:begin
                state_cnt       <= 'd0;
            end
            
            TX_SYNC_WAIT:begin
                if(state_cnt >= send_k_num - 'd1)begin
                    state_cnt   <= 'd0;
                end
                else begin
                    state_cnt   <= state_cnt + 1;
                end
            end
            
            TX_DATA_SEND:begin
                if(state_cnt >= send_data_num- 'd1 )begin
                    state_cnt   <= 'd0;
                end
                else if(fifo_us_rdreq_r)begin
                    state_cnt   <= state_cnt + 'd1;
                end
                else begin
                    state_cnt   <= state_cnt;
                end
            end
            
            default:begin
                state_cnt   <= 'd0;
            end
        endcase
    end
end

always@(posedge fifo_us_rdclk) begin
    if((tx_state == TX_HEADER) || ((tx_state == TX_DATA_SEND)&& (state_cnt <= send_data_num- 'd2))) begin
        fifo_us_rdreq_r <= !fifo_us_empty;
    end
    else begin
        fifo_us_rdreq_r <= 'b0;
    end
end

assign  fifo_us_rdreq   = fifo_us_rdreq_r;

always@(posedge fifo_us_rdclk or negedge log_rst_n)begin
    if(!log_rst_n)begin
        TKMSB_r         <= 'b0;
        TKLSB_r         <= 'b1;
        TX_Data_r       <= 'd0;
    end
    else begin
        if(tx_state == TX_HEADER ) begin
            TKMSB_r         <= 'b1;
            TKLSB_r         <= 'b1;
            TX_Data_r       <= frame_header;
        end         
        else if(tx_state == TX_DATA_SEND && fifo_us_rdreq_r)begin
            TKMSB_r         <= 'b0;
            TKLSB_r         <= 'b0;
            TX_Data_r       <= fifo_us_q;
        end
        else if(tx_state == TX_TAIL ) begin
            TKMSB_r         <= 'b1;
            TKLSB_r         <= 'b1;
            TX_Data_r       <= frame_tail;
        end          
        else begin
            TKMSB_r         <= 'b0;
            TKLSB_r         <= 'b1;
            TX_Data_r       <= 16'hC5BC;
        end
    end
end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// DATA Rx
//--------------------------------------------------------------------- 
reg log_rst_n_r,log_rst_n_r2='d0;
wire   rx_rst_n;

assign rx_rst_n = log_rst_n_r2 && rx_reset_n;  //!log_rst_n || !rx_reset_n

always@(posedge rx_100m)begin
    log_rst_n_r   <= log_rst_n;
    log_rst_n_r2  <= log_rst_n_r;
end

always@(posedge rx_100m)begin
    rx_data_r   <= RX_Data;
    RKMSB_r     <= RKMSB;
    RKLSB_r     <= RKLSB;
end
//fifo_xfer_wr_en
always@(posedge rx_100m or negedge rx_rst_n)begin
    if(!rx_rst_n) begin
        fifo_xfer_wr_en <= 'd0;
    end
    else begin
//        if({RKMSB_r,RKLSB_r,rx_data_r} == 'h1C5BC) begin
//            fifo_xfer_wr_en   <= 'd0;
//        end
//        else if({RKMSB_r,RKLSB_r,rx_data_r} == 'h3FFFF) begin
//            fifo_xfer_wr_en   <= 'd0;
//        end 
        if({RKMSB_r,RKLSB_r,rx_data_r}== 'h3FDF7 ||{RKMSB_r,RKLSB_r,rx_data_r}== 'h3F7FD ) begin
             fifo_xfer_wr_en   <=  !fifo_xfer_full;
        end        
        else if({RKMSB_r,RKLSB_r}==0)begin
            fifo_xfer_wr_en   <=  !fifo_xfer_full;
        end
        else begin
            fifo_xfer_wr_en   <= 'd0;
        end
    end
end
//fifo_xfer_din
always@(posedge rx_100m or negedge rx_rst_n)begin
    if(!rx_rst_n) begin
        fifo_xfer_din   <= 'd0;
    end
    else begin
//        if({RKMSB_r,RKLSB_r,rx_data_r} == 'h1C5BC) begin
//            fifo_xfer_din     <= fifo_xfer_din;
//        end
//        else if({RKMSB_r,RKLSB_r,rx_data_r} == 'h3FFFF) begin
//            fifo_xfer_din     <= fifo_xfer_din;     
//        end 
        if({RKMSB_r,RKLSB_r,rx_data_r}== 'h3FDF7 ||{RKMSB_r,RKLSB_r,rx_data_r}== 'h3F7FD ) begin
            fifo_xfer_din     <= {RKMSB_r,rx_data_r[15:8],RKLSB_r,rx_data_r[7:0]};
        end
        else if({RKMSB_r,RKLSB_r}=='h0)begin
            fifo_xfer_din     <= {RKMSB_r,rx_data_r[15:8],RKLSB_r,rx_data_r[7:0]};
        end
        else begin
            fifo_xfer_din     <= fifo_xfer_din;  
        end
    end
end

assign  fifo_xfer_rd_en = !fifo_xfer_empty;

fifo_ds_xfer fifo_ds_xfer (
  .rst(!rx_rst_n),                      // input wire rst
  .wr_clk(rx_100m),                     // input wire wr_clk
  .rd_clk(fifo_ds_wrclk),               // input wire rd_clk
  .din(fifo_xfer_din),                  // input wire [17 : 0] din
  .wr_en(fifo_xfer_wr_en),              // input wire wr_en
  .rd_en(fifo_xfer_rd_en),              // input wire rd_en
  .dout(fifo_xfer_q),                   // output wire [8: 0] dout
  .full(fifo_xfer_full),                // output wire full
  .empty(fifo_xfer_empty)               // output wire empty
);
//fifo_ds_wrreq_r
always@(posedge fifo_ds_wrclk )begin
    if(fifo_xfer_rd_en)begin
//        if(!fifo_xfer_q[8] && !fifo_ds_prog_full)begin
        if(!fifo_ds_prog_full)begin
            fifo_ds_wrreq_r     <= 1'b1;
        end
        else begin
            fifo_ds_wrreq_r     <= 1'b0;
        end
    end
    else begin
        fifo_ds_wrreq_r     <= 1'b0;
    end
end

//fifo_ds_rx_data_r
always@(posedge fifo_ds_wrclk )begin
    if(fifo_xfer_rd_en)begin
//        if(!fifo_xfer_q[8] && !fifo_ds_prog_full)begin
        if(!fifo_ds_prog_full)begin
            fifo_ds_rx_data_r   <= fifo_xfer_q[7:0];
        end
        else begin
            fifo_ds_rx_data_r   <= fifo_ds_rx_data_r;
        end
    end
    else begin
        fifo_ds_rx_data_r   <= fifo_ds_rx_data_r;
    end
end

assign      fifo_ds_wrreq   = fifo_ds_wrreq_r;
assign      fifo_ds_rx_data = fifo_ds_rx_data_r;

//---------------------------------------------------------------------  
// debug 
//---------------------------------------------------------------------
//ila_tx ila_tx (
//	.clk(fifo_us_rdclk),       // input wire clk
//	.probe0(pw_rst_done),      // input wire [0:0]  probe0  
//	.probe1(tx_state),         // input wire [4:0]  probe1 
//	.probe2(state_cnt),        // input wire [15:0]  probe2 
//	.probe3(TX_Data_r),        // input wire [15:0]  probe3 
//	.probe4(TKMSB_r),          // input wire [0:0]  probe4 
//	.probe5(TKLSB_r),          // input wire [0:0]  probe5 
//	.probe6(fifo_us_rdreq_r),  // input wire [0:0]  probe6
//	.probe7(fifo_us_q),        // input wire [15:0]  probe6
//	.probe8(fifo_us_empty),    // input wire [15:0]  probe6
//	.probe9(frame_start_flag)  // input wire [15:0]  probe6
//);
////
ila_rx ila_rx (
	.clk(rx_100m),             // input wire clk
	.probe0(rx_rst_n),         // input wire [0:0]  probe0  
	.probe1(RKMSB_r),          // input wire [0:0]  probe1 
	.probe2(RKLSB_r),          // input wire [0:0]  probe2 
	.probe3(rx_data_r),        // input wire [15:0]  probe3 
	.probe4(fifo_xfer_wr_en),  // input wire [0:0]  probe4 
	.probe5(fifo_xfer_full),   // input wire [0:0]  probe5 
	.probe6(fifo_xfer_din)     // input wire [17:0]  probe6 
);
////
ila_xfer_out ila_xfer_out (
	.clk(fifo_ds_wrclk),       // input wire clk
	.probe0(fifo_xfer_rd_en),  // input wire [0:0]  probe0  
	.probe1(fifo_xfer_empty),  // input wire [0:0]  probe1 
	.probe2(fifo_xfer_q),      // input wire [8:0]  probe2 
	.probe3(fifo_ds_wrreq_r),  // input wire [0:0]  probe3 
	.probe4(fifo_ds_rx_data_r),// input wire [7:0]  probe4
	.probe5(fifo_ds_prog_full) // input wire [7:0]  probe4
);
endmodule
