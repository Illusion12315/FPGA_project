`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/15 11:42:38
// Design Name: 
// Module Name: circuit_parse
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


module circuit_parse(
    input                   sys_clk,
    input                   rst_n,
    
    input       [7:0]       ldpc_data,
    input                   ldpc_vld,
    input       [7:0]       timeslot_in,
    input       [7:0]       ldpc_in,
    
    output  reg             bit_rd,
    output  reg [9:0]       timeslot,
    input                   bit_vld,
    
    output  reg [7:0]       frame_data,
    output  reg             frame_data_vld,
    output  reg [7:0]       frame_type,
    output  reg [15:0]      frame_len,
    output  reg             frame_len_vld

    );
    
//************************ parameter *********************************
parameter       CIRCUIT_DATA_LEN    = 'd48 ;
parameter       CIRCUIT_HEAD_LEN    = 'd10 ;
parameter       FIFO_RD_START       = 'd512 ;       //at least CIRCUIT_DATA_LEN*8
parameter       FIFO_RD_END         = 'd560 ;       //FIFO_RD_START + CIRCUIT_DATA_LEN
parameter       FIFO_RST_START      = 'd640 ;       //must large than FIFO_RD_END
parameter       FIFO_RST_END        = 'd660 ;       //FIFO_RST_START + 20

//************************ frame period control *********************************
//timeslot 0 is used for sync status, so we use it to clear status.

wire                sync_flag;
reg     [15:0]      sync_clk_cnt;
reg                 fifo_rst;

assign sync_flag = ((timeslot_in == 0) && (ldpc_in == 0)) ? 1'b1 : 1'b0;

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        sync_clk_cnt   <=  'd0;
    end
    else if(sync_flag) begin
        sync_clk_cnt   <=  sync_clk_cnt + 'd1;
    end
    else begin
        sync_clk_cnt <= 'd0;
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        fifo_rst   <=  'd0;
    end
    else if(sync_clk_cnt == FIFO_RST_START) begin
        fifo_rst   <=  'd1;
    end
    else if(sync_clk_cnt == FIFO_RST_END) begin
        fifo_rst   <=  'd0;
    end
    else begin
        fifo_rst <= fifo_rst;
    end
end


//************************ FIFO 0 input and output ******************************

reg                 ldpc_vld_d1;
reg                 ldpc_vld_d2;

reg                 fifo_0_rd_en;
wire                fifo_0_dout;
wire                fifo_0_empty;
wire                fifo_0_almost_empty;


fifo_circuit_0 u_fifo_circuit_0 (
  .clk(sys_clk),                    // input wire clk
  .rst(!rst_n || fifo_rst),                    // input wire rst
  .din(ldpc_data),                    // input wire [7 : 0] din
  .wr_en(ldpc_vld),                // input wire wr_en
  .rd_en(fifo_0_rd_en),                // input wire rd_en
  .dout(fifo_0_dout),                  // output wire [0 : 0] dout
  .full( ),                  // output wire full
  .empty(fifo_0_empty),                // output wire empty
  .almost_empty(fifo_0_almost_empty),  // output wire almost_empty
  .wr_rst_busy( ),    // output wire wr_rst_busy
  .rd_rst_busy( )    // output wire rd_rst_busy
);


always @(posedge sys_clk)
begin
    if(!rst_n) begin
        ldpc_vld_d1   <=  1'd0;
        ldpc_vld_d2   <=  1'd0;
    end
    else begin
        ldpc_vld_d1   <=  ldpc_vld;
        ldpc_vld_d2   <=  ldpc_vld_d1;
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        bit_rd <= 1'b0;
        timeslot   <=  'd0;
    end
    else if (ldpc_vld_d1 && !ldpc_vld_d2) begin
        bit_rd   <=  1'b1;
        timeslot <= {timeslot_in[4:0], ldpc_in[4:0]};
    end
    else begin
        bit_rd   <=  1'b0;
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        fifo_0_rd_en   <=  1'd0;
    end
    else if (ldpc_vld_d1 && !ldpc_vld_d2) begin
        fifo_0_rd_en   <=  1'b1;
    end
    else if (fifo_0_almost_empty || fifo_0_empty) begin
        fifo_0_rd_en <= 1'b0;
    end
    else begin
        fifo_0_rd_en <= fifo_0_rd_en;
    end
end


//************************ FIFO 1 input and output ******************************

reg                 fifo_1_din;
wire                fifo_1_wr_en;
reg                 fifo_1_rd_en;
reg                 fifo_1_rd_en_d1;
reg                 fifo_1_rd_en_d2;
wire        [7:0]   fifo_1_dout;
wire                fifo_1_empty;
wire        [15:0]  circuit_len;


assign  fifo_1_wr_en = bit_vld;
assign  circuit_len = 'd48;

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        fifo_1_din   <=  1'd0;
    end
    else begin
        fifo_1_din <= fifo_0_dout;
    end
end

fifo_circuit_1 u_fifo_circuit_1 (
  .clk(sys_clk),                  // input wire clk
  .rst(!rst_n || fifo_rst),                  // input wire rst
  .din(fifo_1_din),                  // input wire [0 : 0] din
  .wr_en(fifo_1_wr_en),              // input wire wr_en
  .rd_en(fifo_1_rd_en),              // input wire rd_en
  .dout(fifo_1_dout),                // output wire [7 : 0] dout
  .full( ),                // output wire full
  .empty(fifo_1_empty),              // output wire empty
  .wr_rst_busy( ),  // output wire wr_rst_busy
  .rd_rst_busy( )  // output wire rd_rst_busy
);


always @(posedge sys_clk)
begin
    if(!rst_n) begin
        fifo_1_rd_en   <=  'd0;
    end
    else if((sync_clk_cnt == FIFO_RD_START) && (!fifo_1_empty)) begin
        fifo_1_rd_en   <=  'd1;
    end
    else if(sync_clk_cnt == FIFO_RD_END) begin
        fifo_1_rd_en   <=  'd0;
    end
    else begin
        fifo_1_rd_en <= fifo_1_rd_en;
    end
end

//************************ add head for circuit frame ******************************

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        fifo_1_rd_en_d1 <= 'd0;
        fifo_1_rd_en_d2 <= 'd0;
    end
    else begin
        fifo_1_rd_en_d1 <= fifo_1_rd_en;
        fifo_1_rd_en_d2 <= fifo_1_rd_en_d1;
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        frame_type <= 'd0;
        frame_len <= 'd0;
        frame_len_vld <= 'd0;
    end
    else if((!fifo_1_empty) && (sync_clk_cnt == FIFO_RD_START-8)) begin
        frame_type <=  8'h0D;
        frame_len <= CIRCUIT_DATA_LEN + CIRCUIT_HEAD_LEN;
        frame_len_vld <= 'd1;
    end
    else begin
        frame_len_vld <= 'd0;
    end
end



wire    [15:0]      link_id;
wire    [23:0]      src_addr;
wire    [23:0]      dst_addr;
wire    [15:0]      payload_len;

assign  link_id = 16'h0001;
assign  src_addr = 24'hffffff;
assign  dst_addr = 24'hffffff;
assign  payload_len = CIRCUIT_DATA_LEN + CIRCUIT_HEAD_LEN;

always @(posedge sys_clk or negedge rst_n )begin
    if(!rst_n)begin
          frame_data    <= 8'd0;
    end
    else if(fifo_1_rd_en_d1)begin
        frame_data <= fifo_1_dout;
    end
    else begin
        if (!fifo_1_empty) begin
            case(sync_clk_cnt)
                (FIFO_RD_START-8): begin    frame_data <= link_id[15:8];        end
                (FIFO_RD_START-7): begin    frame_data <= link_id[7:0];         end
                (FIFO_RD_START-6): begin    frame_data <= src_addr[23:16];      end 
                (FIFO_RD_START-5): begin    frame_data <= src_addr[15:8];       end
                (FIFO_RD_START-4): begin    frame_data <= src_addr[7:0];        end
                (FIFO_RD_START-3): begin    frame_data <= dst_addr[23:16];      end
                (FIFO_RD_START-2): begin    frame_data <= dst_addr[15:8];       end
                (FIFO_RD_START-1): begin    frame_data <= dst_addr[7:0];        end
                (FIFO_RD_START  ): begin    frame_data <= payload_len[15:8];    end
                (FIFO_RD_START+1): begin    frame_data <= payload_len[7:0];     end

            default:begin                   frame_data <= 'd0;          end
            endcase
        end
        else begin
            frame_data <= 'd0;
        end
    end 
end 

always @(posedge sys_clk or negedge rst_n )begin
    if(!rst_n)begin
        frame_data_vld    <= 1'b0;
    end
    else if(fifo_1_rd_en_d1)begin
        frame_data_vld <= 1'b1;
    end
    else begin
        if (!fifo_1_empty) begin
            case(sync_clk_cnt)
                (FIFO_RD_START-8): begin    frame_data_vld <= 1'b1;         end
                (FIFO_RD_START-7): begin    frame_data_vld <= 1'b1;         end
                (FIFO_RD_START-6): begin    frame_data_vld <= 1'b1;         end 
                (FIFO_RD_START-5): begin    frame_data_vld <= 1'b1;         end
                (FIFO_RD_START-4): begin    frame_data_vld <= 1'b1;         end
                (FIFO_RD_START-3): begin    frame_data_vld <= 1'b1;         end
                (FIFO_RD_START-2): begin    frame_data_vld <= 1'b1;         end
                (FIFO_RD_START-1): begin    frame_data_vld <= 1'b1;         end
                (FIFO_RD_START  ): begin    frame_data_vld <= 1'b1;         end
                (FIFO_RD_START+1): begin    frame_data_vld <= 1'b1;         end

            default:begin                   frame_data_vld <= 1'b0;         end
            endcase
        end
        else begin
            frame_data_vld <= 1'b0;
        end
    end 
end 


    
endmodule
