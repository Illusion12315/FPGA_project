`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/17 10:34:57
// Design Name: 
// Module Name: sdl_add_head
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


module sdl_add_head(
    input                   sys_clk,
    input                   rst_n,
    
    input   [7:0]           frame_data,
    input                   frame_data_vld,
    input   [7:0]           frame_type,
    input   [7:0]           data_type,
    input   [15:0]          frame_len,
    input                   frame_len_vld,

    output  reg [7:0]       lvds_data,
    output  reg             lvds_data_vld,
    output  reg [15:0]      lvds_data_len,
    output  reg             lvds_len_vld
    );
//*************************************************************     
parameter      LVDS_HEAD_LEN       =      'd44;
parameter      JJM_HEAD_LEN       =      'd38;

//************************************************************* 

wire                fifo_almost_empty;
wire                fifo_empty;
reg                 fifo_rd_en;
reg                 fifo_rd_en_d1;
wire    [7:0]       fifo_out_data;

sdl_head_fifo u_sdl_head_fifo (
  .clk(sys_clk),                    // input wire clk
  .rst(!rst_n),                    // input wire rst
  .din(frame_data),                    // input wire [7 : 0] din
  .wr_en(frame_data_vld),                // input wire wr_en
  .rd_en(fifo_rd_en),                // input wire rd_en
  .dout(fifo_out_data),                  // output wire [7 : 0] dout
  .full(),                  // output wire full
  .empty(fifo_empty),                // output wire empty
  .almost_empty(fifo_almost_empty),  // output wire almost_empty
  .wr_rst_busy(),    // output wire wr_rst_busy
  .rd_rst_busy()    // output wire rd_rst_busy
);


reg     [10:0]          data_cnt;
reg     [15:0]          frame_len_tmp;
reg     [7:0]           frame_type_tmp;

reg     [15:0]          total_len;
reg     [15:0]          seg_len;
reg     [15:0]          cfg_len;
reg     [15:0]          conti_cnt;

always @(posedge sys_clk)
begin
    if(!rst_n)
        begin
        frame_len_tmp <= 16'd0;
        frame_type_tmp <= 8'd0;
        total_len <= 16'd0;
        seg_len <= 16'd0;
        cfg_len <= 16'd0;
        end
    else if (frame_len_vld)
        begin
        frame_len_tmp <= frame_len;
        frame_type_tmp <= frame_type;
        total_len <= frame_len + JJM_HEAD_LEN;
        seg_len <= frame_len + JJM_HEAD_LEN;
        cfg_len <= frame_len + 'd32;
        end
    else
        begin
        frame_len_tmp <= frame_len_tmp;
        frame_type_tmp <= frame_type_tmp;
        total_len <= total_len;
        seg_len <= seg_len;
        cfg_len <= cfg_len;
        end
end


always @(posedge sys_clk)
begin
    if(!rst_n)
        conti_cnt <= 16'd0;
    else if (frame_len_vld)
        conti_cnt <= conti_cnt + 1;
    else
        conti_cnt <= conti_cnt;
end

always @(posedge sys_clk)
begin
    if(!rst_n)
        data_cnt <= 11'd0;
    else if (frame_data_vld)
        data_cnt <= data_cnt + 1;
    else if ((data_cnt > 0) && (!fifo_empty))
        data_cnt <= data_cnt + 1;
    else
        data_cnt <= 11'd0;
end

always @(posedge sys_clk)
begin
    if(!rst_n)
        begin
        lvds_data_len <= 16'd0;
        lvds_len_vld <= 1'b0;
        end
    else if (frame_len_vld)
        begin
        lvds_data_len = frame_len + LVDS_HEAD_LEN;
        lvds_len_vld <= 1'b1;
        end
    else
        begin
        lvds_data_len <= lvds_data_len;
        lvds_len_vld <= 1'b0;
        end
end

always @(posedge sys_clk)
begin
    if(!rst_n)
        fifo_rd_en <= 1'b0;
    else if ((data_cnt >= (LVDS_HEAD_LEN -2)) && (!fifo_almost_empty))
        fifo_rd_en <= 1'b1;
    else
        fifo_rd_en <= 1'b0;
end

always @(posedge sys_clk)
begin
    if(!rst_n)
        fifo_rd_en_d1 <= 1'b0;
    else
        fifo_rd_en_d1 <= fifo_rd_en;
end

always @(posedge sys_clk)
begin
    if(!rst_n)
        lvds_data_vld <= 1'b0;
    else if ((frame_data_vld) || (!fifo_almost_empty) || fifo_rd_en_d1)
        lvds_data_vld <= 1'b1;
    else
        lvds_data_vld <= 1'b0;
end


wire    [47:0]      time_stamp;
wire    [7:0]       satel_id;
wire    [7:0]       beam_id;
wire    [15:0]      sync_head;
wire    [15:0]      channel_mang;


assign  time_stamp = 48'h000000000000;
assign  satel_id = 8'h01;
assign  beam_id = 8'h01;
assign  sync_head = 16'hEB90;
assign  channel_mang = 16'h520A;

always @(posedge sys_clk or negedge rst_n )begin
    if(!rst_n)begin
          lvds_data    <= 8'd0;
    end
    else if(fifo_rd_en_d1)begin
        lvds_data <= fifo_out_data;
    end
    else if(frame_len_vld)begin
        lvds_data <= frame_type;
    end 
    else if(lvds_data_vld)begin
        case(data_cnt)
           11'd1:begin     lvds_data <= 16'h00;                 end
           11'd2:begin     lvds_data <= total_len[15:8];        end 
           11'd3:begin     lvds_data <= total_len[7:0];         end
           11'd4:begin     lvds_data <= seg_len[15:8];          end
           11'd5:begin     lvds_data <= seg_len[7:0];           end
           11'd6:begin     lvds_data <= time_stamp[47:40];      end
           11'd7:begin     lvds_data <= time_stamp[39:32];      end
           11'd8:begin     lvds_data <= time_stamp[31:24];      end
           11'd9:begin     lvds_data <= time_stamp[23:16];      end
           11'd10:begin    lvds_data <= time_stamp[15:8];       end
           11'd11:begin    lvds_data <= time_stamp[7:0]  ;      end
           11'd12:begin    lvds_data<= satel_id;                end
           11'd13:begin    lvds_data<= beam_id;                 end
           11'd14:begin    lvds_data<= sync_head[15:8];         end
           11'd15:begin    lvds_data<= sync_head[7:0];          end
           11'd16:begin    lvds_data <=cfg_len[15:8];           end
           11'd17:begin    lvds_data <=cfg_len[7:0];            end
           11'd18:begin    lvds_data <=conti_cnt[15:8];         end
           11'd19:begin    lvds_data <=conti_cnt[7:0];          end
           11'd20:begin    lvds_data <= channel_mang[15:8];     end
           11'd21:begin    lvds_data <= channel_mang[7:0];      end
           11'd22:begin    lvds_data <= data_type;              end
           
           11'd23, 11'd24, 11'd25, 11'd26, 11'd27, 11'd28, 11'd29, 11'd30, 11'd31, 11'd32,
           11'd33, 11'd34, 11'd35, 11'd36, 11'd37, 11'd38, 11'd39, 11'd40, 11'd41, 11'd42, 11'd43:
                  begin     lvds_data <= data_cnt - 11'd23;   end

        default:begin lvds_data <= lvds_data;   end
        endcase
    end 
   else begin
        lvds_data    <= 8'd0;
   end 
end 



endmodule
