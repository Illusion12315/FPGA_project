`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/16 21:17:15
// Design Name: 
// Module Name: read_deal
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


module read_deal(
    input           i_clk100m,
    input           i_rst_n,
    input [7:0]     i_down_gear,
    
    input           i_ml_rd_flag,
    input           i_hs_rd_flag,
    
    input [7:0]     i_fifo_out,
    input           i_fifo_valid,
    input           fifo_empty,
    
    output   reg    o_ml_rd_en,
    output   reg    o_hs_rd_en,
    output   reg    o_p2s_rstn
    );
    
parameter R_IDLE  =  4'd0;
parameter R_SYNC  =  4'd1;
parameter R_STAR  =  4'd2;

parameter W_MLCTL    = 4'd3;
parameter W_ML_WAIT  = 4'd4;

parameter W_HSCTL    = 4'd6;
parameter W_HS_WAITE = 4'd7;

reg [3:0]      r_state;

reg [7:0]      r_down_gear_r,r_down_gear_rr;
reg [15:0]     r_down_byte;
reg [15:0]     r_cnt;
reg [3:0]      r_delay_cnt;
reg [15:0]     hs_rd_data;

//ila_read_deal ila_read_deal_inst (
//	.clk(i_clk100m), // input wire clk


//	.probe0(i_ml_rd_flag), // input wire [0:0]  probe0  
//	.probe1(i_hs_rd_flag), // input wire [0:0]  probe1 
//	.probe2(o_ml_rd_en), // input wire [0:0]  probe2 
//	.probe3(o_hs_rd_en), // input wire [0:0]  probe3 
//	.probe4(r_state), // input wire [3:0]  probe4 
//	.probe5(r_down_gear_rr), // input wire [7:0]  probe5 
//	.probe6(r_down_byte), // input wire [15:0]  probe6 
//	.probe7(r_cnt), // input wire [15:0]  probe7 
//	.probe8(r_delay_cnt), // input wire [3:0]  probe8 
//	.probe9(hs_rd_data), // input wire [15:0]  probe9
	
//	.probe10(i_fifo_valid), // input wire [3:0]  probe8 
//	.probe11(i_fifo_out), // input wire [15:0]  probe9  fifo_empty
//	.probe12(fifo_empty) // input wire [15:0]  probe9  fifo_empty
//);

always @(posedge i_clk100m)begin
    r_down_gear_r <= i_down_gear;
    r_down_gear_rr <= r_down_gear_r;
end 

always @(posedge i_clk100m or negedge i_rst_n)begin
    if(i_rst_n == 1'b0)begin
        o_p2s_rstn <= 1'b1;
    end 
    else if(r_down_gear_rr == !r_down_gear_r)begin
         o_p2s_rstn <= 1'b0;
    end 
    else begin
         o_p2s_rstn <= 1'b1;
    end 
end 

//----High Speed data cnt
always @(posedge i_clk100m or negedge i_rst_n)begin
    if(i_rst_n==1'b0)begin
        hs_rd_data <= 16'd0;
    end 
    else if(r_down_gear_rr==8'h43 || r_down_gear_rr == 8'h42)begin
        hs_rd_data <= 16'd1280;
    end 
    else begin
        hs_rd_data <= 16'd0;
    end 
 end 

always @(posedge i_clk100m or negedge i_rst_n)begin
    if(i_rst_n ==1'b0)begin
        r_down_byte <= 16'd0;
    end 
    else case(r_down_gear_rr)
        8'h52:begin r_down_byte <= 16'd48;end
        8'h51:begin r_down_byte <= 16'd20;end
        8'h4F:begin r_down_byte <= 16'd40;end
        8'h4E:begin r_down_byte <= 16'd40;end
        8'h4D:begin r_down_byte <= 16'd80;end
        8'h4C:begin r_down_byte <= 16'd80;end
        8'h4B:begin r_down_byte <= 16'd160;end
        8'h4A:begin r_down_byte <= 16'd160;end
        8'h49:begin r_down_byte <= 16'd320;end
        8'h48:begin r_down_byte <= 16'd160;end
        8'h47:begin r_down_byte <= 16'd160;end
        8'h46:begin r_down_byte <= 16'd160;end
        8'h45:begin r_down_byte <= 16'd160;end
        8'h44:begin r_down_byte <= 16'd160;end
        8'h43:begin r_down_byte <= 16'd320;end
        8'h42:begin r_down_byte <= 16'd480;end
        8'h41:begin r_down_byte <= 16'd480;end
        
        
        default:begin r_down_byte <= 16'd0;end
    endcase
end 




always @(posedge i_clk100m or negedge i_rst_n)begin
    if(i_rst_n == 1'b0)begin
         r_cnt        <= 16'd0;
         r_delay_cnt  <= 4'd0;
         o_ml_rd_en   <= 1'b0;
         o_hs_rd_en   <= 1'b0;
         
         r_state     <= R_IDLE;
    end 
    else case(r_state)
        R_IDLE:begin
            r_cnt        <= 16'd0;
            r_delay_cnt  <= 4'd0;
            o_ml_rd_en   <= 1'b0;
            o_hs_rd_en   <= 1'b0;
            
            if(r_down_gear_rr != 0)begin
                r_state <= R_SYNC;
            end 
            else begin
                r_state <= r_state;
            end 
        end 
      R_SYNC:begin
            r_cnt        <= 16'd0;
            r_delay_cnt  <= 4'd0;
            o_ml_rd_en   <= 1'b0;
            o_hs_rd_en   <= 1'b0;
            
            if(r_down_gear_rr == r_down_gear_r)begin
//                r_state <= R_STAR;
                r_state <= W_MLCTL;
            end 
            else begin
                r_state <= R_IDLE;
            end 
      end 
//    R_STAR:begin
//            r_cnt        <= 16'd0;
//            r_delay_cnt  <= 4'd0;
//            o_ml_rd_en   <= 1'b0;
//            o_hs_rd_en   <= 1'b0;
////            if(r_down_gear_rr != r_down_gear_r)begin
////                 r_state <= R_IDLE;
////            end 
            
//            if(r_down_gear_rr==8'h43 || r_down_gear_rr == 8'h42)begin
//                r_state <= W_HSCTL;
//            end 
//            else begin
//                r_state <= W_MLCTL;
//            end 
//    end 
    W_MLCTL:begin
        o_hs_rd_en   <= 1'b0;
         if(r_down_gear_rr != r_down_gear_r)begin
           r_state <= R_IDLE;
//           o_ml_rd_en  <= 1'b0;
       end 
        else if(i_ml_rd_flag==1'b1)begin
            o_ml_rd_en  <= 1'b1;
            r_cnt       <= r_cnt + 1'b1;
            
            r_state     <= W_ML_WAIT;
        end 
        else begin
            o_ml_rd_en <= 1'b0;
            r_cnt      <= 16'd0;
            r_state  <= W_MLCTL;
        end 
    end 
   W_ML_WAIT:begin
       o_hs_rd_en   <= 1'b0;
       if(r_down_gear_rr != r_down_gear_r)begin
           r_state <= R_IDLE;
       end 
       else if(r_cnt == r_down_byte)begin
            o_ml_rd_en  <= 1'b0;
            r_cnt       <= 16'd0;
            
            r_state     <= R_IDLE;
        end 
        else begin
            o_ml_rd_en  <= o_ml_rd_en;
            r_cnt       <= r_cnt + 1'b1;
            
            r_state     <= W_ML_WAIT;
        end 
   end 

//------------------------HS
//    W_HSCTL:begin

//        r_delay_cnt  <= 4'd0;
//        o_ml_rd_en   <= 1'b0;
////       if(r_down_gear_rr != r_down_gear_r)begin
////           r_state <= R_IDLE;
////       end     
//        if(i_hs_rd_flag==1'b1)begin
//            o_hs_rd_en <= 1'b1;
//            r_cnt      <= r_cnt + 1'b1;
//            r_state    <= W_HS_WAITE;
//        end 
//        else begin
//            o_hs_rd_en <= 1'b0;
//            r_state    <= r_state;
//            r_cnt      <= 16'd0;
//        end       
//    end 
//    W_HS_WAITE:begin
//            o_ml_rd_en <= 1'b0;
//            r_delay_cnt  <= 4'd0;
////         if(r_down_gear_rr != r_down_gear_r)begin
////           r_state <= R_IDLE;
////       end 
//        if(r_cnt == hs_rd_data)begin
//                r_cnt       <= 16'd0;
//                o_hs_rd_en  <= 1'b0;
                
//                r_state     <= R_IDLE;
//           end 
//           else begin
//                r_cnt <= r_cnt + 1'b1;
//                o_hs_rd_en <= o_hs_rd_en;
                
//                r_state <= W_HS_WAITE;
//           end 
//    end 
    default:begin
        r_state <= R_IDLE;
    end 
    endcase   
    
end 
    
    
    
    
endmodule
