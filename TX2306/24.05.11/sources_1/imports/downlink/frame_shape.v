`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/15 20:01:29
// Design Name: 
// Module Name: frame_shape
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


module frame_shape(
    input               sys_clk,
    input               rst_n,
    
    input   [7:0]       bsn_frame_data,
    input               bsn_frame_data_vld,
    input   [7:0]       bsn_frame_type,
    input   [15:0]      bsn_frame_len,
    input               bsn_frame_len_vld,
    
    input   [7:0]       bb_frame_data,
    input               bb_frame_data_vld,
    input   [7:0]       bb_frame_type,
    input   [15:0]      bb_frame_len,
    input               bb_frame_len_vld,
    
    input   [7:0]       ctrl_frame_data,
    input               ctrl_frame_data_vld,
    input   [7:0]       ctrl_frame_type,
    input   [15:0]      ctrl_frame_len,
    input               ctrl_frame_len_vld,
    
    input   [7:0]       circuit_frame_data,
    input               circuit_frame_data_vld,
    input   [7:0]       circuit_frame_type,
    input   [15:0]      circuit_frame_len,
    input               circuit_frame_len_vld,
    
    output  reg [7:0]   sdl_frame_data,
    output  reg         sdl_frame_data_vld,
    output  reg [7:0]   sdl_frame_type,
    output  reg [7:0]   sdl_data_type,
    output  reg [15:0]  sdl_frame_len,
    output  reg         sdl_frame_len_vld,
    
    output  reg [31:0]  sdl_bsn_cnt,
    output  reg [31:0]  sdl_bb_cnt,
    output  reg [31:0]  sdl_circuit_cnt

    );
    
//*********************** parameter define *********************************
parameter      DATA_TYPE_BSN       =      'd0;
parameter      DATA_TYPE_BB        =      'd1;
parameter      DATA_TYPE_CIRCUIT   =      'd2;
parameter      DATA_TYPE_CTRL      =      'd3;

//************************** bsn fifo ***********************************


reg                 bsn_fifo_rd_en;
wire    [7:0]       bsn_fifo_dout;
wire                bsn_fifo_empty;
wire                bsn_fifo_almost_empty;

reg     [7:0]       bsn_frame_type_d;
reg     [15:0]      bsn_frame_len_d;

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        bsn_frame_type_d <= 'd0;
        bsn_frame_len_d <= 'd0;
    end
    else if(bsn_frame_len_vld) begin
        bsn_frame_type_d   <=  bsn_frame_type;
        bsn_frame_len_d   <=  bsn_frame_len;
    end
    else begin
        bsn_frame_type_d   <=  bsn_frame_type_d;
        bsn_frame_len_d   <=  bsn_frame_len_d;
    end
end


fifo_sdl_shape bsn_fifo_sdl_shape (
  .clk(sys_clk),                    // input wire clk
  .rst(!rst_n),                    // input wire rst
  .din(bsn_frame_data),                    // input wire [7 : 0] din
  .wr_en(bsn_frame_data_vld),                // input wire wr_en
  .rd_en(bsn_fifo_rd_en),                // input wire rd_en
  .dout(bsn_fifo_dout),                  // output wire [7 : 0] dout
  .full( ),                  // output wire full
  .empty(bsn_fifo_empty),                // output wire empty
  .almost_empty(bsn_fifo_almost_empty),  // output wire almost_empty
  .wr_rst_busy( ),    // output wire wr_rst_busy
  .rd_rst_busy( )    // output wire rd_rst_busy
);

//************************** bb fifo ***********************************

reg                 bb_fifo_rd_en;
wire    [7:0]       bb_fifo_dout;
wire                bb_fifo_empty;
wire                bb_fifo_almost_empty;

reg     [7:0]       bb_frame_type_d;
reg     [15:0]      bb_frame_len_d;

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        bb_frame_type_d <= 'd0;
        bb_frame_len_d <= 'd0;
    end
    else if(bb_frame_len_vld) begin
        bb_frame_type_d   <=  bb_frame_type;
        bb_frame_len_d   <=  bb_frame_len;
    end
    else begin
        bb_frame_type_d   <=  bb_frame_type_d;
        bb_frame_len_d   <=  bb_frame_len_d;
    end
end


fifo_sdl_shape bb_fifo_sdl_shape (
  .clk(sys_clk),                    // input wire clk
  .rst(!rst_n),                    // input wire rst
  .din(bb_frame_data),                    // input wire [7 : 0] din
  .wr_en(bb_frame_data_vld),                // input wire wr_en
  .rd_en(bb_fifo_rd_en),                // input wire rd_en
  .dout(bb_fifo_dout),                  // output wire [7 : 0] dout
  .full( ),                  // output wire full
  .empty(bb_fifo_empty),                // output wire empty
  .almost_empty(bb_fifo_almost_empty),  // output wire almost_empty
  .wr_rst_busy( ),    // output wire wr_rst_busy
  .rd_rst_busy( )    // output wire rd_rst_busy
);

//************************** ctrl fifo ***********************************

reg                 ctrl_fifo_rd_en;
wire    [7:0]       ctrl_fifo_dout;
wire                ctrl_fifo_empty;
wire                ctrl_fifo_almost_empty;

reg     [7:0]       ctrl_frame_type_d;
reg     [15:0]      ctrl_frame_len_d;

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        ctrl_frame_type_d <= 'd0;
        ctrl_frame_len_d <= 'd0;
    end
    else if(ctrl_frame_len_vld) begin
        ctrl_frame_type_d   <=  ctrl_frame_type;
        ctrl_frame_len_d   <=  ctrl_frame_len;
    end
    else begin
        ctrl_frame_type_d   <=  ctrl_frame_type_d;
        ctrl_frame_len_d   <=  ctrl_frame_len_d;
    end
end


fifo_sdl_shape ctrl_fifo_sdl_shape (
  .clk(sys_clk),                    // input wire clk
  .rst(!rst_n),                    // input wire rst
  .din(ctrl_frame_data),                    // input wire [7 : 0] din
  .wr_en(ctrl_frame_data_vld),                // input wire wr_en
  .rd_en(ctrl_fifo_rd_en),                // input wire rd_en
  .dout(ctrl_fifo_dout),                  // output wire [7 : 0] dout
  .full( ),                  // output wire full
  .empty(ctrl_fifo_empty),                // output wire empty
  .almost_empty(ctrl_fifo_almost_empty),  // output wire almost_empty
  .wr_rst_busy( ),    // output wire wr_rst_busy
  .rd_rst_busy( )    // output wire rd_rst_busy
);

//************************** circuit fifo ***********************************

reg                 circuit_fifo_rd_en;
wire    [7:0]       circuit_fifo_dout;
wire                circuit_fifo_empty;
wire                circuit_fifo_almost_empty;

reg     [7:0]       circuit_frame_type_d;
reg     [15:0]      circuit_frame_len_d;

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        circuit_frame_type_d <= 'd0;
        circuit_frame_len_d <= 'd0;
    end
    else if(circuit_frame_len_vld) begin
        circuit_frame_type_d   <=  circuit_frame_type;
        circuit_frame_len_d   <=  circuit_frame_len;
    end
    else begin
        circuit_frame_type_d   <=  circuit_frame_type_d;
        circuit_frame_len_d   <=  circuit_frame_len_d;
    end
end


fifo_sdl_shape circuit_fifo_sdl_shape (
  .clk(sys_clk),                    // input wire clk
  .rst(!rst_n),                    // input wire rst
  .din(circuit_frame_data),                    // input wire [7 : 0] din
  .wr_en(circuit_frame_data_vld),                // input wire wr_en
  .rd_en(circuit_fifo_rd_en),                // input wire rd_en
  .dout(circuit_fifo_dout),                  // output wire [7 : 0] dout
  .full( ),                  // output wire full
  .empty(circuit_fifo_empty),                // output wire empty
  .almost_empty(circuit_fifo_almost_empty),  // output wire almost_empty
  .wr_rst_busy( ),    // output wire wr_rst_busy
  .rd_rst_busy( )    // output wire rd_rst_busy
);

//************************** read state machine ********************************
//state machine
parameter IDLE          =   3'd0;
parameter READ_BSN      =   3'd1;
parameter READ_BB       =   3'd2;
parameter READ_CIRCUIT  =   3'd3;
parameter READ_CTRL     =   3'd4;


reg     [2:0]       top_state;
reg     [10:0]      state_period_cnt;
reg                 fifo_almost_empty_d1;
reg                 fifo_rd_en_d1;

always @(posedge sys_clk)
begin
if (!rst_n)
    begin
    top_state   <=  IDLE;
    state_period_cnt <= 'd0;
    bsn_fifo_rd_en <= 'd0;
    bb_fifo_rd_en <= 'd0;
    ctrl_fifo_rd_en <= 'd0;
    circuit_fifo_rd_en <= 'd0;
    fifo_rd_en_d1 <= 'd0;
    sdl_frame_data <= 'd0;
    sdl_frame_data_vld <= 'd0;
    sdl_frame_type <= 'd0;
    sdl_data_type <= 'd0;
    sdl_frame_len <= 'd0;
    sdl_frame_len_vld <= 'd0;
    fifo_almost_empty_d1 <= 'd0;
    sdl_bsn_cnt <= 'd0;
    sdl_bb_cnt <= 'd0;
    sdl_circuit_cnt <= 'd0;
    end
else
    begin
    case(top_state)
        IDLE: begin
            fifo_rd_en_d1 <= 'd0;
            sdl_frame_data <= 'd0;
            sdl_frame_data_vld <= 'd0;
            sdl_frame_type <= 'd0;
            sdl_data_type <= 'd0;
            sdl_frame_len <= 'd0;
            sdl_frame_len_vld <= 'd0;
            
            if (!bsn_fifo_almost_empty) begin
                state_period_cnt <= 'd0;
                top_state <= READ_BSN;
            end
            else if (!bb_fifo_almost_empty) begin
                state_period_cnt <= 'd0;
                top_state <= READ_BB;
            end
            else if (!ctrl_fifo_almost_empty) begin
                state_period_cnt <= 'd0;
                top_state <= READ_CTRL;
            end
            else if (!circuit_fifo_almost_empty) begin
                state_period_cnt <= 'd0;
                top_state <= READ_CIRCUIT;
            end
            else begin
                top_state <= IDLE;
            end
        end
        READ_BSN: begin
            fifo_almost_empty_d1 <= bsn_fifo_almost_empty;
            state_period_cnt <= state_period_cnt + 1;
            
            if (!bsn_fifo_almost_empty) begin
                bsn_fifo_rd_en <= 1'b1;
            end
            else begin
                bsn_fifo_rd_en <= 1'b0;
            end
            
            sdl_frame_data <= bsn_fifo_dout;
            fifo_rd_en_d1 <= bsn_fifo_rd_en;
            sdl_frame_data_vld <= fifo_rd_en_d1;
            
            if (state_period_cnt == 2) begin
                sdl_frame_type <= bsn_frame_type_d;
                sdl_data_type <= DATA_TYPE_BSN;
                sdl_frame_len <= bsn_frame_len_d;
                sdl_frame_len_vld <= 1'b1;
                sdl_bsn_cnt <= sdl_bsn_cnt + 'd1;
            end
            else begin
                sdl_frame_len_vld <= 1'b0;
            end
            
            if (!fifo_rd_en_d1 && sdl_frame_data_vld) begin
                top_state <= IDLE;
            end
        end
        READ_BB: begin
            fifo_almost_empty_d1 <= bb_fifo_almost_empty;
            state_period_cnt <= state_period_cnt + 1;
            
            if (!bb_fifo_almost_empty) begin
                bb_fifo_rd_en <= 1'b1;
            end
            else begin
                bb_fifo_rd_en <= 1'b0;
            end
            
            sdl_frame_data <= bb_fifo_dout;
            fifo_rd_en_d1 <= bb_fifo_rd_en;
            sdl_frame_data_vld <= fifo_rd_en_d1;
            
            if (state_period_cnt == 2) begin
                sdl_frame_type <= bb_frame_type_d;
                sdl_data_type <= DATA_TYPE_BB;
                sdl_frame_len <= bb_frame_len_d;
                sdl_frame_len_vld <= 1'b1;
                sdl_bb_cnt <= sdl_bb_cnt + 'd1;
            end
            else begin
                sdl_frame_len_vld <= 1'b0;
            end
            
            if (!fifo_rd_en_d1 && sdl_frame_data_vld) begin
                top_state <= IDLE;
            end
        end
        READ_CTRL: begin
            fifo_almost_empty_d1 <= ctrl_fifo_almost_empty;
            state_period_cnt <= state_period_cnt + 1;
            
            if (!ctrl_fifo_almost_empty) begin
                ctrl_fifo_rd_en <= 1'b1;
            end
            else begin
                ctrl_fifo_rd_en <= 1'b0;
            end
            
            sdl_frame_data <= ctrl_fifo_dout;
            fifo_rd_en_d1 <= ctrl_fifo_rd_en;
            sdl_frame_data_vld <= fifo_rd_en_d1;
            
            if (state_period_cnt == 2) begin
                sdl_frame_type <= ctrl_frame_type_d;
                sdl_data_type <= DATA_TYPE_CTRL;
                sdl_frame_len <= ctrl_frame_len_d;
                sdl_frame_len_vld <= 1'b1;
                sdl_bsn_cnt <= sdl_bsn_cnt + 'd1;
            end
            else begin
                sdl_frame_len_vld <= 1'b0;
            end
            
            if (!fifo_rd_en_d1 && sdl_frame_data_vld) begin
                top_state <= IDLE;
            end
        end
        READ_CIRCUIT: begin
            fifo_almost_empty_d1 <= circuit_fifo_almost_empty;
            state_period_cnt <= state_period_cnt + 1;
            
            if (!circuit_fifo_almost_empty) begin
                circuit_fifo_rd_en <= 1'b1;
            end
            else begin
                circuit_fifo_rd_en <= 1'b0;
            end
            
            sdl_frame_data <= circuit_fifo_dout;
            fifo_rd_en_d1 <= circuit_fifo_rd_en;
            sdl_frame_data_vld <= fifo_rd_en_d1;
            
            if (state_period_cnt == 2) begin
                sdl_frame_type <= circuit_frame_type_d;
                sdl_data_type <= DATA_TYPE_CIRCUIT;
                sdl_frame_len <= circuit_frame_len_d;
                sdl_frame_len_vld <= 1'b1;
                sdl_circuit_cnt <= sdl_circuit_cnt + 'd1;
            end
            else begin
                sdl_frame_len_vld <= 1'b0;
            end
            
            if (!fifo_rd_en_d1 && sdl_frame_data_vld) begin
                top_state <= IDLE;
            end
        end
        default: begin
            top_state   <=  IDLE;
        end
    endcase
    end
end



endmodule
