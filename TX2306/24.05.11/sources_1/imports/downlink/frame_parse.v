`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/13 16:10:07
// Design Name: 
// Module Name: frame_parse
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


module frame_parse(
    input                   sys_clk,
    input                   rst_n,
    
    input                   ldpc_vld,
    input       [7:0]       ldpc_da,
    input       [7:0]       timeslot_in,
    input       [7:0]       ldpc_in,
    
    output  reg             byte_rd,
    output  reg [9:0]       timeslot,
    input                   ts_vld,
    
    output  reg [7:0]       frame_data,
    output  reg             data_vld,
    output  reg [15:0]      frame_len,
    output  reg             len_vld

    );
    
//*************************************************************
parameter       RAM_MAX_BYTE = 'd8192;   //ram max byte num


//**************************input proc*********************************** 

reg                 ldpc_vld_d1;
reg                 ldpc_vld_d2;
reg [7:0]           ldpc_da_d1;
reg [7:0]           ldpc_da_d2;
reg [7:0]           ldpc_da_d3;

reg [12:0]          write_addr;


always @(posedge sys_clk)
begin
    if(!rst_n)
        begin
        ldpc_da_d1 <= 8'd0;
        ldpc_da_d2 <= 8'd0;
        ldpc_da_d3 <= 8'd0;
        ldpc_vld_d1 <= 1'b0;
        ldpc_vld_d2 <= 1'b0;
        end
    else 
        begin
        ldpc_da_d1 <= ldpc_da;
        ldpc_da_d2 <= ldpc_da_d1;
        ldpc_da_d3 <= ldpc_da_d2;
        ldpc_vld_d1 <= ldpc_vld;
        ldpc_vld_d2 <= ldpc_vld_d1;
        end
end


always @(posedge sys_clk)
begin
    if(!rst_n)
        begin
        byte_rd <= 'd0;
        timeslot <= 'd0;
        end
    else if(ldpc_vld && !ldpc_vld_d1)
        begin
        byte_rd <= 'd1;
        timeslot <= {timeslot_in[4:0], ldpc_in[4:0]};
        end
    else
        begin
        byte_rd <= 'd0;
        timeslot <= timeslot;
        end
end



always @(posedge sys_clk)
begin
    if(!rst_n)
        write_addr <= 'd0;
    else if (ldpc_vld_d2 && ts_vld)
        begin
        if (write_addr == (RAM_MAX_BYTE - 1))
            write_addr <= 'd0;
        else
            write_addr <= write_addr + 1;
        end
    else
        write_addr <= write_addr;
end

//************************************************************* 

reg     [12:0]      head_addr;      //check one byte by one byte 
reg     [12:0]      read_addr;
wire    [7:0]       read_outb;
wire    [12:0]      ram_left;

//frame_parse_ram u_frame_parse_ram (
//  .clka(sys_clk),    // input wire clka
//  .ena(rst_n),      // input wire ena
//  .wea(ldpc_vld_d2 && ts_vld),      // input wire [0 : 0] wea
//  .addra(write_addr),  // input wire [12 : 0] addra
//  .dina(ldpc_da_d2),    // input wire [7 : 0] dina
//  .clkb(sys_clk),    // input wire clkb
//  .enb(1'b1),      // input wire enb
//  .addrb(read_addr),  // input wire [12 : 0] addrb
//  .doutb(read_outb)  // output wire [7 : 0] doutb
//);

frame_parse_ram u_frame_parse_ram (
  .a(write_addr),        // input wire [12 : 0] a
  .d(ldpc_da_d2),        // input wire [7 : 0] d
  .dpra(read_addr),  // input wire [12 : 0] dpra
  .clk(sys_clk),    // input wire clk
  .we(ldpc_vld_d2 && ts_vld),      // input wire we
  .qdpo(read_outb)    // output wire [7 : 0] qdpo
);

assign ram_left = (write_addr >= head_addr)?(write_addr - head_addr):(write_addr + RAM_MAX_BYTE - head_addr);

//***********************output proc************************************** 

parameter FRAME_MIN_LEN     =   'd34;
parameter FRAME_MAX_LEN     =   'd1540;
parameter STATE_MIX_CNT     =   'd10;   

//state machine
parameter IDLE          =   3'd0;
parameter GET_HEAD      =   3'd1;
parameter CRC_CHECK     =   3'd2;
parameter DATA_WAIT     =   3'd3;
parameter DATA_GET      =   3'd4;
parameter STATE_WAIT    =   3'd5;

reg     [2:0]       top_state;
reg     [15:0]      state_period_cnt;

reg     [15:0]      data_len_2B;
reg     [15:0]      crc16_get;

reg     [7:0]       crc16_data_in;
reg                 crc16_vld_in;
wire    [15:0]      crc16_out;
wire                crc16_out_vld;


always @(posedge sys_clk)
begin
if (!rst_n)
    begin
    top_state   <=  IDLE;
    state_period_cnt <= 16'd0;
    frame_len <= 16'd0;
    head_addr   <= 'd0;
    read_addr   <= 'd0;
    data_len_2B <= 16'd0;
    crc16_get   <= 16'd0;
    crc16_data_in <= 8'd0;
    crc16_vld_in <= 1'b0;
    frame_data <= 'd0;
    data_vld <= 'd0;
    len_vld <= 'd0;
    end
else
    begin
    case(top_state)
        IDLE:begin                    
            if (ram_left > 4)
                begin
                if (state_period_cnt == 0)
                    begin
                    read_addr <= head_addr;
                    state_period_cnt <= state_period_cnt + 1;
                    end
                else if (state_period_cnt == 1)
                    begin
                    read_addr = (read_addr == RAM_MAX_BYTE -1)? 'd0 : (read_addr + 1);
                    state_period_cnt <= state_period_cnt + 1;
                    end
                else if (state_period_cnt == 2)
                    begin
                    read_addr = (read_addr == RAM_MAX_BYTE -1)? 'd0 : (read_addr + 1);
                    data_len_2B[15:8] <= read_outb;
                    state_period_cnt <= state_period_cnt + 1;
                    end
                else if (state_period_cnt == 3)
                    begin
                    read_addr = (read_addr == RAM_MAX_BYTE -1)? 'd0 : (read_addr + 1);
                    data_len_2B[7:0] <= read_outb;
                    state_period_cnt <= state_period_cnt + 1;
                    end
                else if (state_period_cnt == 4)
                    begin
                    read_addr = (read_addr == RAM_MAX_BYTE -1)? 'd0 : (read_addr + 1);
                    crc16_get[15:8] <= read_outb;
                    state_period_cnt <= 0;
                    top_state <= GET_HEAD;
                    end
                end
            else
                begin
                state_period_cnt <= 'd0;
                end
            end
        GET_HEAD:begin
            if (ram_left > 4)
                begin
                if (state_period_cnt == 0)
                    begin
                    read_addr <= (head_addr + 3 >= RAM_MAX_BYTE)?(head_addr + 3 - RAM_MAX_BYTE):(head_addr + 3);
                    state_period_cnt <= state_period_cnt + 1;
                    end
                else if (state_period_cnt == 2)
                    begin
                    crc16_get[7:0] <= read_outb;
                    state_period_cnt <= 0;
                    top_state <= CRC_CHECK;
                    end
                else
                    begin
                    state_period_cnt <= state_period_cnt + 1;
                    end
                end
            else
                begin
                state_period_cnt <= 'd0;
                end
            end
        CRC_CHECK:begin
            if (state_period_cnt == 0)
                begin
                crc16_data_in <= data_len_2B[15:8];
                crc16_vld_in <= 1'b1;
                end
            else if (state_period_cnt == 1)
                begin
                crc16_data_in <= data_len_2B[7:0];
                crc16_vld_in <= 1'b1;
                end
            else
                begin
                crc16_data_in <= 8'd0;
                crc16_vld_in <= 1'b0;
                end
                
            if (crc16_out_vld)
                begin
                if ((crc16_out == crc16_get) && (data_len_2B > FRAME_MIN_LEN) && (data_len_2B <= FRAME_MAX_LEN))
                    begin
                    top_state <= DATA_WAIT;
                    state_period_cnt <= 16'd0;
                    frame_len <= data_len_2B;
                    end
                else
                    begin
                    head_addr = (head_addr == RAM_MAX_BYTE -1)? 'd0 : (head_addr + 1);
                    top_state <= GET_HEAD;
                    state_period_cnt <= 16'd0;
                    end
                //first 3 Bytes ready for next check
                data_len_2B[15:8] <= data_len_2B[7:0];
                data_len_2B[7:0] <= crc16_get[15:8];
                crc16_get[15:8] <= crc16_get[7:0];
                end
            else
                begin
                state_period_cnt <= state_period_cnt + 1;
                end
            end
        DATA_WAIT:begin
            if (ram_left >= frame_len)
                begin
                state_period_cnt <= 16'd0;
                top_state <= DATA_GET;
                end
            end
        DATA_GET:begin
            if (state_period_cnt == 0)
                begin
                read_addr <= head_addr;
                state_period_cnt <= state_period_cnt + 1;
                end
            else if (state_period_cnt == 1)
                begin
                read_addr = (read_addr == RAM_MAX_BYTE -1)? 'd0 : (read_addr + 1);
                state_period_cnt <= state_period_cnt + 1;
                end
            else if (state_period_cnt == 2)
                begin
                read_addr = (read_addr == RAM_MAX_BYTE -1)? 'd0 : (read_addr + 1);
                frame_data <= read_outb;
                data_vld <= 1'd1;
                len_vld <= 1'd1;
                state_period_cnt <= state_period_cnt + 1;
                end
            else if ((state_period_cnt >= 2) && (state_period_cnt <= frame_len + 1))
                begin
                read_addr = (read_addr == RAM_MAX_BYTE -1)? 'd0 : (read_addr + 1);
                frame_data <= read_outb;
                data_vld <= 1'd1;
                len_vld <= 1'd0;
                state_period_cnt <= state_period_cnt + 1;
                end
            else if (state_period_cnt == frame_len + 1)
                begin
                frame_data <= 'd0;
                data_vld <= 1'd0;
                len_vld <= 1'd0;
                state_period_cnt <= 0;
                head_addr = (head_addr == RAM_MAX_BYTE -1)? 'd0 : (head_addr + 1);
                top_state <= STATE_WAIT;
                end
            else
                begin
                frame_data <= 'd0;
                data_vld <= 1'd0;
                len_vld <= 1'd0;
                state_period_cnt <= 0;
                top_state <= STATE_WAIT;
                end
            end
        STATE_WAIT:begin
            if (state_period_cnt == STATE_MIX_CNT)
                begin
                top_state <= GET_HEAD;
                state_period_cnt <= 16'd0;
                end
            else
                begin
                state_period_cnt <= state_period_cnt + 1;
                end
            end
        default:
            top_state   <=  IDLE;
    endcase
    end
end


crc16_head u_crc16_head(
    .clk_in(sys_clk),
    .rst_n(rst_n),
    .data_in(crc16_data_in),
    .valid_in(crc16_vld_in),
    .crc_out(crc16_out),
    .crc_out_valid(crc16_out_vld)
);

//***********************debug info**************************************
wire	[31:0]	cap_data;
wire			cap_en;
reg		[31:0]	cap_cnt;

always @(posedge sys_clk)
begin
    if(!rst_n)
        cap_cnt <= 'd0;
    else if (cap_en)
        begin
        if ({ldpc_da_d3, ldpc_da_d2, ldpc_da_d1, ldpc_da} == cap_data)
            cap_cnt <= cap_cnt + 1;
        else
            cap_cnt <= cap_cnt;
        end
    else
        cap_cnt <= 'd0;
end


endmodule
