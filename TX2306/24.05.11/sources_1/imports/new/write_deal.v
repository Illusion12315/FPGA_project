`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/16 20:11:37
// Design Name: 
// Module Name: write_deal
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


module write_deal(
     input           clk163m84,
     input           rst_n,
     input [7:0]     w_down_gear_r,
     input [7:0]     w_down_gear_rr,
     
     input           data_valid,
     input [7:0]     data_in,
     input           fifo_full,
     
     output reg         wr_ml_end,
     output reg         wr_hs_end,
     
     output reg         fifo_rst

    );
    
parameter W_IDLE     = 4'd0;
parameter W_SYNC     = 4'd1;
parameter W_START    = 4'd2;

parameter W_MLCTL    = 4'd3;
parameter W_ML_WAIT  = 4'd4;
parameter W_ML_END   = 4'd5;

parameter W_HSCTL    = 4'd6;
parameter W_HS_WAITE = 4'd7;
parameter W_HS_END   = 4'd8;
//parameter W_END       =4'd;


reg [3:0]   w_state;

//reg [7:0]   w_down_gear_r,w_down_gear_rr;
reg [15:0]   w_down_byte;


reg         wr_en ;
reg [15:0]  wr_cnt;
reg [3:0]   delay_cnt;

reg [15:0]  hs_cnt;

//always @(posedge clk163m84)begin
//    w_down_gear_r <= down_gear;
//    w_down_gear_rr <= w_down_gear_r;
//end 

always @(posedge clk163m84 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        fifo_rst <= 1'b0;
    end 
    else if(w_down_gear_rr != w_down_gear_r)begin
         fifo_rst <= 1'b1;
    end 
    else begin
        fifo_rst <= 1'b0;
    end 
end 






always @(posedge clk163m84 or negedge rst_n)begin
    if(rst_n==1'b0)begin
        w_down_byte <= 16'd0;
    end 
    else case(w_down_gear_rr)
        8'h52:begin w_down_byte <= 16'd48;end
        8'h51:begin w_down_byte <= 16'd20;end
        8'h4F:begin w_down_byte <= 16'd40;end
        8'h4E:begin w_down_byte <= 16'd40;end
        8'h4D:begin w_down_byte <= 16'd80;end
        8'h4C:begin w_down_byte <= 16'd80;end
        8'h4B:begin w_down_byte <= 16'd160;end
        8'h4A:begin w_down_byte <= 16'd160;end
        8'h49:begin w_down_byte <= 16'd320;end
        8'h48:begin w_down_byte <= 16'd160;end
        8'h47:begin w_down_byte <= 16'd160;end
        8'h46:begin w_down_byte <= 16'd160;end
        8'h45:begin w_down_byte <= 16'd160;end
        8'h44:begin w_down_byte <= 16'd160;end
        8'h43:begin w_down_byte <= 16'd320;end
        8'h42:begin w_down_byte <= 16'd480;end
        8'h41:begin w_down_byte <= 16'd480;end

        
        default:begin w_down_byte <= 16'd0;end
    endcase  
end 

//-------------wire FIFO state 
always @(posedge clk163m84 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
       w_state <= 4'd0;
        
       wr_en     <= 1'b0;
       wr_cnt    <= 16'd0;
       hs_cnt    <= 16'd0;
       delay_cnt <= 4'd0;
       wr_ml_end <= 1'b0;
       wr_hs_end <= 1'b0;
    end 
    else case(w_state)
        W_IDLE:begin
             wr_en     <= 1'b0;
             wr_cnt    <= 16'd0;
             hs_cnt    <= 16'd0;
             delay_cnt <= 4'd0;
             wr_ml_end <= 1'b0;
             wr_hs_end <= 1'b0;
             if(w_down_gear_rr !=0)begin
                w_state <= W_SYNC;
             end 
             else begin
                w_state <= w_state;
             end 
        end 
        W_SYNC:begin
            
             wr_cnt    <= 16'd0;
             delay_cnt <= 4'd0;
             wr_ml_end <= 1'b0;
             wr_hs_end <= 1'b0;
             hs_cnt    <= 16'd0;
             
             if(w_down_gear_rr== w_down_gear_r)begin
                w_state <= W_MLCTL;
                wr_en     <= 1'b1;
             end 
             else begin
                w_state <= W_IDLE;
                wr_en   <= 1'b0;
             end 
        end 
//        W_START:begin
//             wr_cnt    <= 16'd0;
//             delay_cnt <= 4'd0;
//             wr_ml_end <= 1'b0;
//             wr_hs_end <= 1'b0;
//             hs_cnt    <= 16'd0;
             
////             if(w_down_gear_rr!= w_down_gear_r)begin
////                w_state <= W_IDLE;
////             end 
             
//             if(w_down_gear_rr == 8'h43 || w_down_gear_rr == 8'h42)begin
//                w_state <= W_HSCTL;
//             end 
//             else begin
//                w_state <= W_MLCTL;
//             end 
//        end 
       W_MLCTL:begin
            delay_cnt <= 4'd0;
            wr_hs_end <= 1'b0;
            wr_ml_end <= 1'b0;
            hs_cnt    <= 16'd0;
             if(w_down_gear_rr!= w_down_gear_r)begin
                w_state <= W_IDLE;
             end 
            else if(wr_cnt == w_down_byte)begin
                w_state <= W_ML_WAIT;
            end 
            else if(data_valid==1'b1)begin
                wr_cnt <= wr_cnt + 1'b1;
                w_state <= W_MLCTL;
            end 
            else begin
                wr_cnt <= wr_cnt;
                
                w_state <= w_state;
            end 
       end 
    W_ML_WAIT:begin
            hs_cnt    <= 16'd0;
            wr_ml_end <= 1'b0;
           if(w_down_gear_rr!= w_down_gear_r)begin
                w_state <= W_IDLE;
             end 
            if(delay_cnt == 4'd7)begin
                wr_ml_end <= 1'b1;
                delay_cnt <= 4'd0;
                w_state   <= W_ML_END;
                
            end 
            else begin
                delay_cnt <= delay_cnt + 1'b1;
            end 
    end 
    W_ML_END:begin
        wr_ml_end <= 1'b0;
        hs_cnt    <= 16'd0;
        if(w_down_gear_rr!= w_down_gear_r)begin
                w_state <= W_IDLE;
         end 
         else if(delay_cnt == 4'd7)begin
               wr_ml_end <= 1'b0;
               delay_cnt <= 4'd0;
               w_state   <= W_IDLE;
        end 
       else begin
          delay_cnt <= delay_cnt + 1'b1;
          wr_ml_end <= wr_ml_end;
          
          w_state   <= w_state;
       end 
        
    end 

//------------------HS
//       W_HSCTL:begin
//            wr_ml_end <= 1'b0;
//            delay_cnt <= 4'd0;
////             if(w_down_gear_rr!= w_down_gear_r)begin
////                w_state <= W_IDLE;
////             end 
//            if((wr_cnt == w_down_byte) && (hs_cnt == 16'd1280))begin
//                wr_hs_end <= 1'b0;
                
//                w_state <= W_HS_WAITE;
//            end 
//            else if(data_valid==1'b1 && (hs_cnt == 16'd1280))begin
//                wr_hs_end <= 1'b1;
//                hs_cnt    <= 16'd1;
//                wr_cnt <= wr_cnt + 1'b1;
//            end 
//            else if(data_valid==1'b1)begin
//                wr_cnt <= wr_cnt +1'b1;
//                hs_cnt <= hs_cnt + 1'b1;
//                wr_hs_end <= 1'b0;
//            end 
//            else begin
//                w_state <= w_state;
//            end 
//       end 
//      W_HS_WAITE:begin
//            wr_ml_end <= 1'b0;
////             if(w_down_gear_rr!= w_down_gear_r)begin
////                w_state <= W_IDLE;
////             end 
//            if(delay_cnt == 4'd6)begin
//                w_state <= W_HS_END;
//                delay_cnt <= 4'd0;
//                wr_hs_end <= 1'b1;
//            end 
//            else begin
//                w_state    <= w_state;
//                delay_cnt  <= delay_cnt + 1'b1;
//                wr_hs_end  <= 1'b0;
//            end 
//      end 
//     W_HS_END:begin
//            wr_ml_end <= 1'b0;
////            if(w_down_gear_rr!= w_down_gear_r)begin
////                w_state <= W_IDLE;
////             end 
//            if(delay_cnt == 4'd5)begin
//                w_state    <= W_IDLE;
//                delay_cnt  <= 4'd0;
//                wr_hs_end  <= 1'b0;
//            end 
//            else begin
//                w_state <= W_HS_END;
//                delay_cnt <= delay_cnt + 1'b1;
//                wr_hs_end <= 1'b1;
//            end 
//     end 
     default:begin
        w_state <= W_IDLE;
     end 
    endcase
end 

//ila_write_deal ila_write_deal_inst (
//	.clk(clk163m84), // input wire clk


//	.probe0(data_valid), // input wire [0:0]  probe0  
//	.probe1(data_in), // input wire [7:0]  probe1 
//	.probe2(wr_ml_end), // input wire [0:0]  probe2 
//	.probe3(wr_hs_end), // input wire [0:0]  probe3 
//	.probe4(w_state), // input wire [3:0]  probe4 
//	.probe5(w_down_gear_rr), // input wire [7:0]  probe5 
//	.probe6(w_down_byte), // input wire [15:0]  probe6 
//	.probe7(wr_cnt), // input wire [15:0]  probe7 
//	.probe8(delay_cnt), // input wire [3:0]  probe8 
//	.probe9(hs_cnt), // input wire [15:0]  probe9
//	.probe10(fifo_full) // input wire [15:0]  probe9
//);
    
endmodule
