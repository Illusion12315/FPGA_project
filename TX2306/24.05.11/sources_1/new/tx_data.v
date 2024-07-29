`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/24 20:19:36
// Design Name: 
// Module Name: lvds_tx_data
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


module tx_data(

    input               clk100m,
    input               clk163m84,
    input               rst_n,

    
    input               ldpc_vld,
    input  [7:0]        ldpc_da,
     input [7:0]                o_ldpc_cnt              ,
     input [7:0]                o_slottimesw_cnt        ,
    
    output  reg [7:0]   txdata,
    output  reg         txen,
    output       [15:0] data_len,
    output              len_en
    
    );
    
 parameter  IDLE        = 4'd0;
 parameter  S_STAR      = 4'd1;
 parameter  S_SDL       = 4'd2;
 parameter  S_END       = 4'd3;
 
 reg    [3:0]   state;
 

  
 
 //-------------frame_info
 reg [7:0]   info_type;
 reg [7:0]   segm_mark;
 reg [15:0]  info_fram_leng;
 reg [15:0]  din_leng;
 reg [15:0]  leng;
 reg [47:0]  time_stamp;
 reg [7:0]   satel_num;
 reg [7:0]   beram_num;
 reg [15:0]  sync_head;
 reg [15:0]  cfg_leng;
 reg [15:0]  conti_cnt;
 reg [15:0]  channel_mang;
 reg [175:0]   reser_r;
// reg [7:0]    sdl_data;
 

//  wire       ldpc_neg_flag;  
  reg        ldpc_vld_r,ldpc_vld_rr;
  reg [7:0]  ldpc_da_r,ldpc_da_rr;
  reg [15:0] byte_cnt;
  reg [15:0] byte_cnt_r;
  reg [15:0] byte_cnt_rr;
  reg [15:0] byte_cnt_rrr;
  reg        rd_en_flag;
  reg        rd_flag;
  reg        rd_flag_r,rd_flag_rr;
  reg [11:0] tx_cnt;
  reg [11:0] data_cnt;
  reg        frame_end_flag;
  
  reg       len_en_r,len_en_rr;
  
  wire [7:0] o_ldpc_cnt_r;
  wire [7:0] o_slottimesw_cnt_r;
  
  
  reg rst_n_r,rst_n_rr;
  
always @(posedge clk163m84)begin
    rst_n_r   <= rst_n;
    rst_n_rr  <= rst_n_r;

end 

wire        s_fifo_en;
wire [15:0] s_ffio_in;
wire        s_fifo_rd;
wire [15:0] s_fifo_dout;
wire        s_fifo_empty;
wire        s_fifo_full;

assign s_ffio_in = {o_ldpc_cnt,o_slottimesw_cnt};
assign s_fifo_en = !s_fifo_full;
assign s_fifo_rd = !s_fifo_empty;

assign o_ldpc_cnt_r         = s_fifo_dout[15:8];
assign o_slottimesw_cnt_r   = s_fifo_dout[7:0];


fifo_slot fifo_slot_inst (
  .rst(!rst_n_rr),        // input wire rst
  .wr_clk(clk163m84),  // input wire wr_clk
  .rd_clk(clk100m),  // input wire rd_clk
  .din(s_ffio_in),        // input wire [15 : 0] din
  .wr_en(s_fifo_en),    // input wire wr_en
  .rd_en(s_fifo_rd),    // input wire rd_en
  .dout(s_fifo_dout),      // output wire [15 : 0] dout
  .full(s_fifo_full),      // output wire full
  .empty(s_fifo_empty)    // output wire empty
);




//always @(posedge clk100m)begin
//    o_ldpc_cnt_r    <= o_ldpc_cnt;
//    o_ldpc_cnt_rr   <= o_ldpc_cnt_r;
//end 

//always @(posedge clk100m)begin
//    o_slottimesw_cnt_r    <= o_slottimesw_cnt;
//    o_slottimesw_cnt_rr   <= o_slottimesw_cnt_r;
//end 

always @(posedge clk100m)begin
    len_en_r <= txen;
    len_en_rr <= len_en_r;
end 

assign data_len = din_leng;
assign len_en = !len_en_rr && len_en_r;
  
  
//  assign  ldpc_neg_flag = !ldpc_da_r && ldpc_da_rr;
  always @(posedge clk100m)begin
        ldpc_vld_r  <= ldpc_vld;
        ldpc_vld_rr <= ldpc_vld_r;
  end 
  always @(posedge clk100m)begin
        ldpc_da_r   <= ldpc_da;
        ldpc_da_rr  <= ldpc_da_r;
  end 
  
  always @(posedge clk100m or negedge rst_n)begin
     if(rst_n ==1'b0)begin
         byte_cnt <= 16'd0;
     end 
     else if(frame_end_flag==1'b1)begin
        byte_cnt <= 16'd0;
     end 
     else if(ldpc_vld_rr)begin
         byte_cnt <= byte_cnt + 1'b1;
     end    
     else begin
         byte_cnt <= byte_cnt;
     end    
  end
  
 always @(posedge clk100m or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        rd_flag <= 1'b0;
    end 
    else if(frame_end_flag==1'b1)begin
        rd_flag<= 1'b0;
    end 
    else if(!ldpc_vld_r && ldpc_vld_rr)begin
        rd_flag <= 1'b1;
    end 
    else begin
        rd_flag <= rd_flag;
    end 
 end 
 
 //---------------------
 always @(posedge clk100m or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        time_stamp <= 48'd0;
    end 
    else begin
        time_stamp <= time_stamp + 1'b1;
    end 
 end 
 
  always @(posedge clk100m or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        conti_cnt <= 16'd0;
    end 
    else if(frame_end_flag==1'b1) begin
        conti_cnt <= conti_cnt + 1'b1;
    end 
    else begin
        conti_cnt <= conti_cnt;
    end 
 end 
 
 always @(posedge  clk100m or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        byte_cnt_r <=16'd0;
    end
    else if(frame_end_flag==1'b1)begin
         byte_cnt_r <=16'd0;
    end 
    else if(!ldpc_vld_r && ldpc_vld_rr)begin
        byte_cnt_r <= byte_cnt;
    end 
    else begin
        byte_cnt_r <= byte_cnt_r;
    end  
   end 
   
//---------------------------------
always @(posedge clk100m or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        byte_cnt_rr <= 16'd0;
        byte_cnt_rrr <= 16'd0;
    end 
    else begin
        byte_cnt_rr  <= byte_cnt_r;
        byte_cnt_rrr <= byte_cnt_rr;
    end 
end 
always @(posedge clk100m or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        rd_flag_r <= 1'b0;
        rd_flag_rr <= 1'b0;
    end 
    else begin
        rd_flag_r  <= rd_flag;
        rd_flag_rr <= rd_flag_r;
    end 
end


  
 always @(posedge clk100m or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        info_type       <= 8'd0;
        segm_mark       <= 8'd0;
        info_fram_leng  <= 16'd0;
        leng            <= 16'd0;
        satel_num       <=8'd0;
        beram_num       <=8'd0;
       
       din_leng         <= 16'd0;
       
       sync_head        <=16'd0;
       cfg_leng         <=16'd0;
       channel_mang     <=16'd0;
       reser_r         <= 176'd0;

    end 
    else begin
        info_type         <= 8'h0b;
        segm_mark         <= 8'h00;
//        info_fram_leng    <= byte_cnt_r + 6'd44;
        din_leng          <= byte_cnt_rrr + 6'd45;
        info_fram_leng    <= byte_cnt_rrr + 6'd39;
        leng              <= byte_cnt_rrr + 6'd39;
        
        satel_num         <=8'hA1;
        beram_num         <= 8'hA3;
        sync_head         <= 16'hEB90;
        cfg_leng          <= byte_cnt_rrr + 5'd31;
        channel_mang      <= 16'h520A;
        
        reser_r[175:168]        <=8'hBB;
        reser_r[167:160]        <=8'd20;
        reser_r[159:152]        <=8'd19;
        reser_r[151:144]        <=8'd18;
        reser_r[143:136]        <=8'd17;
        reser_r[135:128]        <=8'd16;
        reser_r[127:120]        <=8'd15;
        reser_r[119:112]        <=8'd14;
        reser_r[111:104]        <=o_slottimesw_cnt_r;
        reser_r[103:96]         <=o_ldpc_cnt_r;
        reser_r[95:88]          <=8'd11; 
        reser_r[87:80]          <=8'd10; 
        reser_r[79:72]          <=8'h09; 
        reser_r[71:64]          <=8'h08; 
        reser_r[63:56]          <=8'h07; 
        reser_r[55:48]          <=8'h06; 
        reser_r[47:40]          <=8'h05; 
        reser_r[39:32]          <=8'h04; 
        reser_r[31:24]          <=8'h03; 
        reser_r[23:16]          <=8'h02; 
        reser_r[15:8]           <=8'h01;  
        reser_r[7:0]            <=8'hAA;   
    end 
end 
  
  //-------------------------------------
  wire          fifo_wr_en;
  wire          fifo_rd_en;
  wire          fifo_full;
  wire          fifo_empty;
  wire [7:0]    fifo_out;
  
//  wire [12:0]   rd_data_count;
//  wire [12:0]   wr_data_count;
  
  assign fifo_wr_en = !fifo_full && ldpc_vld_rr;
  assign fifo_rd_en = !fifo_empty && rd_en_flag;
  
fifo_lvds_tx fifo_lvds_tx_inst (
  .rst(!rst_n),        // input wire rst
  .wr_clk(clk100m),  // input wire wr_clk
  .rd_clk(clk100m),  // input wire rd_clk
  .din(ldpc_da_rr),        // input wire [7 : 0] din
  .wr_en(fifo_wr_en),    // input wire wr_en
  .rd_en(fifo_rd_en),    // input wire rd_en
  .dout(fifo_out),      // output wire [7 : 0] dout
  .full(fifo_full),      // output wire full
  .empty(fifo_empty)  // output wire empty
//  .rd_data_count(rd_data_count),  // output wire [12 : 0] rd_data_count
//  .wr_data_count(wr_data_count)  // output wire [12 : 0] wr_data_count
);

//-------------------------------------

always @(posedge clk100m or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        state <= IDLE;
        
        txen      <= 1'b0;
        tx_cnt <= 12'd0;
        data_cnt <= 12'd0;
        rd_en_flag <= 1'b0;
        
        frame_end_flag <= 1'b0;
    end 
    else case(state)
        IDLE:begin
            tx_cnt <= 12'd0;
            data_cnt <= 12'd0;
            rd_en_flag <= 1'b0;       
            frame_end_flag <= 1'b0;
            if(rd_flag_rr)begin
                 state <= S_STAR;
//                 txen      <= 1'b1;
            end 
            else begin
                state <= state;
            end 
        end 
       S_STAR:begin
            frame_end_flag <= 1'b0;
            txen      <= 1'b1;
            if(tx_cnt == 12'd43)begin
             tx_cnt <= tx_cnt;
             state   <= S_SDL;
             
//              data_cnt <= data_cnt+1'b1;
              rd_en_flag <= 1'b1;
                
            end 
            else begin
                tx_cnt <= tx_cnt+1'b1;

                
                state <= state;
            end 
       end 
       S_SDL:begin
//            rd_en_flag <= 1'b1;
            if(data_cnt == byte_cnt_rrr+1'b1)begin
                data_cnt <= 12'd0;
                tx_cnt   <= 12'd0;
                
                frame_end_flag <= 1'b1;
                txen     <= 1'b0;
                state    <= S_END;
            end 
            else begin
                data_cnt <= data_cnt+ 1'b1;
                txen     <= txen;
                state    <= state;
            end 
       end    
       
       S_END:begin
              rd_en_flag <= 1'b0;
              frame_end_flag <= 1'b0; 
              txen      <= 1'b0;
              tx_cnt <= 12'd0;
              data_cnt <= 12'd0;
               
               if(data_cnt == 12'd5)begin
                 state <= IDLE;
                 data_cnt <= 12'd0;
               end 
               else begin
                 data_cnt <= data_cnt + 1'b1;
               end 
       end 
       
       default:begin
            state <= IDLE;
       end  
    endcase    
end     
//end 
always @(posedge clk100m or negedge rst_n )begin
    if(rst_n ==1'b0)begin
          txdata    <= 8'd0;
//          txen      <= 1'b0;
    end 
    else if(state == S_SDL)begin
        txdata <= fifo_out;
    end 
    else if(rd_flag_rr==1'b1)begin
//        txen      <= 1'b1;
        case(tx_cnt)
           11'd0:begin     txdata <= info_type;             end 
           11'd1:begin     txdata <= segm_mark;             end
           11'd2:begin     txdata <= info_fram_leng[15:8];  end 
           11'd3:begin     txdata <= info_fram_leng[7:0];   end
           11'd4:begin     txdata <= leng[15:8];            end
           11'd5:begin     txdata <= leng[7:0];             end
           11'd6:begin     txdata <= time_stamp[47:40];     end
           11'd7:begin     txdata <= time_stamp[39:32];     end
           11'd8:begin     txdata <= time_stamp[31:24];     end
           11'd9:begin     txdata <= time_stamp[23:16];     end
           11'd10:begin    txdata <= time_stamp[15:8];      end
           11'd11:begin    txdata <= time_stamp[7:0]  ;     end
           11'd12:begin    txdata<= satel_num;             end
           11'd13:begin    txdata<= beram_num;             end
           11'd14:begin    txdata<= sync_head[15:8];       end
           11'd15:begin    txdata<= sync_head[7:0];        end
           11'd16:begin    txdata <=cfg_leng[15:8];        end
           11'd17:begin    txdata <=cfg_leng[7:0];         end
           11'd18:begin    txdata <=conti_cnt[15:8];       end
           11'd19:begin    txdata <=conti_cnt[7:0];        end
           11'd20:begin    txdata <= channel_mang[15:8];  end
           11'd21:begin    txdata <= channel_mang[7:0];  end
           
           11'd22:begin    txdata <= reser_r[175:168];   end
           11'd23:begin    txdata <= reser_r[167:160];    end
           11'd24:begin    txdata <= reser_r[159:152];       end 
           11'd25:begin    txdata <= reser_r[151:144];       end 
           11'd26:begin    txdata <= reser_r[143:136];       end 
           11'd27:begin    txdata <= reser_r[135:128];       end 
           11'd28:begin    txdata <= reser_r[127:120];       end 
           11'd29:begin    txdata <= reser_r[119:112];       end 
           11'd30:begin    txdata <= reser_r[111:104];       end 
           11'd31:begin    txdata <= reser_r[103:96];       end 
           11'd32:begin    txdata <= reser_r[95:88];       end 
           11'd33:begin    txdata <= reser_r[87:80];       end
           11'd34:begin    txdata <= reser_r[79:72];       end
           11'd35:begin    txdata <= reser_r[71:64];       end
           11'd36:begin    txdata <= reser_r[63:56];       end
           11'd37:begin    txdata <= reser_r[55:48];       end
           11'd38:begin    txdata <= reser_r[47:40];       end
           11'd39:begin    txdata <= reser_r[39:32];       end
           11'd40:begin    txdata <= reser_r[31:24];       end
           11'd41:begin    txdata <= reser_r[23:16];       end
           11'd42:begin    txdata <= reser_r[15:8];        end
           11'd43:begin    txdata <= reser_r[7:0];         end

        default:begin txdata <= txdata;end
        endcase
    end 
   else begin
        txdata    <= 8'd0;
   end 
end 

 ila_lvds_tx ila_lvds_tx_inst (
	.clk(clk100m), // input wire clk


	.probe0(txdata), // input wire [7:0]  probe0  
	.probe1(txen), // input wire [0:0]  probe1 
	.probe2(data_len), // input wire [15:0]  probe2 
	.probe3(state), // input wire [3:0]  probe3 
	.probe4(byte_cnt_rrr), // input wire [15:0]  probe4 
	.probe5(tx_cnt), // input wire [11:0]  probe5 
	.probe6(data_cnt), // input wire [11:0]  probe6 
	.probe7(rd_en_flag), // input wire [0:0]  probe7 
	.probe8(frame_end_flag), // input wire [0:0]  probe8 
	.probe9(rd_flag_rr), // input wire [0:0]  probe9 
	.probe10(fifo_rd_en), // input wire [0:0]  probe10 
	.probe11(fifo_empty), // input wire [0:0]  probe11 
	.probe12(fifo_out), // input wire [7:0]  probe12
	.probe13(ldpc_vld_rr), // input wire [0:0]  probe13 
	.probe14(ldpc_da_rr), // input wire [7:0]  probe14 
	.probe15(byte_cnt) // input wire [15:0]  probe15
);

//ila_sdl ila_sdl_inst (
//	.clk(clk163m84), // input wire clk


//	.probe0(ldpc_vld_rr), // input wire [0:0]  probe0  
//	.probe1(ldpc_da), // input wire [7:0]  probe1 
//	.probe2(byte_cnt) // input wire [15:0]  probe2
//);

endmodule
