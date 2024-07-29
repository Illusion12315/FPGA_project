`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/14 10:46:56
// Design Name: 
// Module Name: config_ts_table
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// for business(bsn) and broadcase(bb), the first clk input byte_rd and timeslot, the next clk output ts_vld for 319 to 0.
//for circuit, the first clk input bit_rd and timeslot, the third clk output bit_vld for bit_stream.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module config_ts_table(
    input               sys_clk,
    input               rst_n,
    
    input               config_vld,
    input   [7:0]       config_data,
    
    input               bsn_byte_rd,
    input   [9:0]       bsn_timeslot,
    output              bsn_ts_vld,
    
    input               bb_byte_rd,
    input   [9:0]       bb_timeslot,
    output              bb_ts_vld,
    
    input               ctrl_byte_rd,
    input   [9:0]       ctrl_timeslot,
    output              ctrl_ts_vld,
    
    input               circuit_bit_rd,
    input   [9:0]       circuit_timeslot,
    output  reg         circuit_bit_vld
    
    );
    
//*************************************************************

parameter       TIMESLOT_BIT_MAX =   3840;  //480Byte * 8
parameter       TIMESLOT_MAX =   1024;  //timeslot max:32, ldpc max:32
parameter       BLOCK_MAX_BYTE = 480;   //ldpc max byte num

//*************************************************************
//byte or bit sel for 32 timeslot 
reg     [BLOCK_MAX_BYTE-1:0]     bsn_byte_sel        [TIMESLOT_MAX-1:0];
reg     [BLOCK_MAX_BYTE-1:0]     bb_byte_sel         [TIMESLOT_MAX-1:0];
reg     [BLOCK_MAX_BYTE-1:0]     ctrl_byte_sel       [TIMESLOT_MAX-1:0];
reg     [11:0]      circuit_bit_start   [TIMESLOT_MAX-1:0];
reg     [11:0]      circuit_bit_end     [TIMESLOT_MAX-1:0];

//*******************config byte and bit sel table*************************

reg                 config_vld_d1;
reg                 config_vld_d2;
reg     [7:0]       config_data_d1;
reg     [7:0]       config_vld_cnt;

reg     [1:0]       byte_sel_type;
reg     [4:0]       timeslot_cfg;
reg     [4:0]       ldpc_cfg;
wire    [9:0]       timeslot_ldpc_cfg;
reg     [BLOCK_MAX_BYTE-1:0]     byte_sel_cfg;


always @(posedge sys_clk)
begin
    if(!rst_n) begin
        config_vld_d1   <=  1'd0;
        config_vld_d2   <=  1'd0;
        config_data_d1  <=  8'd0;
    end
    else begin
        config_vld_d1   <=  config_vld;
        config_vld_d2   <=  config_vld_d1;
        config_data_d1  <=  config_data;
    end
end


always @(posedge sys_clk)
begin
    if(!rst_n) begin
        config_vld_cnt  <=  8'd0;
    end
    else begin
        if(config_vld) begin
            config_vld_cnt <= config_vld_cnt + 'd1;
        end
        else begin
            config_vld_cnt <= 8'd0;
        end
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        byte_sel_type   <=  'd0;
        timeslot_cfg    <=  'd0;
        ldpc_cfg        <=  'd0;
        byte_sel_cfg    <=  'd0;
    end
    else begin
        if(config_vld_d1 && (config_vld_cnt == 'd1)) begin
            byte_sel_type <= config_data_d1[1:0];
        end
        else if(config_vld_d1 && (config_vld_cnt== 'd2)) begin
            timeslot_cfg <= config_data_d1[4:0];
        end
        else if(config_vld_d1 && (config_vld_cnt== 'd3)) begin
            ldpc_cfg <= config_data_d1[4:0];
        end
        else if(config_vld_d1 && (config_vld_cnt > 'd3)) begin
            byte_sel_cfg <= {byte_sel_cfg[BLOCK_MAX_BYTE-9:0], config_data_d1};
        end
        else begin
            byte_sel_type   <=  'd0;
            timeslot_cfg    <=  'd0;
            ldpc_cfg        <=  'd0;
            byte_sel_cfg    <=  'd0;
        end         
    end
end

assign  timeslot_ldpc_cfg = {timeslot_cfg, ldpc_cfg};

integer i;
initial begin
    for (i = 0; i < TIMESLOT_MAX; i = i + 1) begin
        if ((i == (4 << 5)) || (i == (20 << 5))) begin
            bsn_byte_sel[i] <= 'd0;
            bb_byte_sel[i]  <=  'hFFFFF0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
            ctrl_byte_sel[i] <= 'd0;
            circuit_bit_start[i]    <=  'd0;
            circuit_bit_end[i]      <=  'd0;
        end
        else begin
            bsn_byte_sel[i] <= 'd0;
            bb_byte_sel[i]  <=  'd0;
            ctrl_byte_sel[i]  <=  'd0;
            circuit_bit_start[i]    <=  'd0;
            circuit_bit_end[i]      <=  'd0;
        end
    end
end


always @(posedge sys_clk)
begin
    if(!config_vld_d1 && config_vld_d2) begin
        if (byte_sel_type == 'd0) begin
            bsn_byte_sel[timeslot_ldpc_cfg] <= byte_sel_cfg;
        end
        else if (byte_sel_type == 'd1) begin
            bb_byte_sel[timeslot_ldpc_cfg] <= byte_sel_cfg;
        end
        else if (byte_sel_type == 'd2) begin
            circuit_bit_start[timeslot_ldpc_cfg] <=  byte_sel_cfg[475:464];
            circuit_bit_end[timeslot_ldpc_cfg]   <=  byte_sel_cfg[459:448];
        end
        else if (byte_sel_type == 'd3) begin
            ctrl_byte_sel[timeslot_ldpc_cfg] <= byte_sel_cfg;
        end
        else begin
            bsn_byte_sel[timeslot_ldpc_cfg] <= bsn_byte_sel[timeslot_ldpc_cfg];
            bb_byte_sel[timeslot_ldpc_cfg] <= bb_byte_sel[timeslot_ldpc_cfg];
            ctrl_byte_sel[timeslot_ldpc_cfg] <= ctrl_byte_sel[timeslot_ldpc_cfg];
            circuit_bit_start[timeslot_ldpc_cfg] <= circuit_bit_start[timeslot_ldpc_cfg];
            circuit_bit_end[timeslot_ldpc_cfg] <= circuit_bit_end[timeslot_ldpc_cfg];
        end
    end  
end


//***********************bsn and bb table lookup**********************************

reg     [BLOCK_MAX_BYTE-1:0]     bsn_byte_sel_rd;
reg     [BLOCK_MAX_BYTE-1:0]     bb_byte_sel_rd;
reg     [BLOCK_MAX_BYTE-1:0]     ctrl_byte_sel_rd;


always @(posedge sys_clk)
begin
    if(!rst_n) begin
        bsn_byte_sel_rd <= 'd0;
    end
    else if (bsn_byte_rd) begin
        bsn_byte_sel_rd <= bsn_byte_sel[bsn_timeslot];
    end
    else begin
        bsn_byte_sel_rd <= bsn_byte_sel_rd << 1;
    end
end

assign bsn_ts_vld = bsn_byte_sel_rd[BLOCK_MAX_BYTE-1];

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        bb_byte_sel_rd <= 'd0;
    end
    else if (bb_byte_rd) begin
        bb_byte_sel_rd <= bb_byte_sel[bb_timeslot];
    end
    else begin
        bb_byte_sel_rd <= bb_byte_sel_rd << 1;
    end
end

assign bb_ts_vld = bb_byte_sel_rd[BLOCK_MAX_BYTE-1];

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        ctrl_byte_sel_rd <= 'd0;
    end
    else if (ctrl_byte_rd) begin
        ctrl_byte_sel_rd <= ctrl_byte_sel[ctrl_timeslot];
    end
    else begin
        ctrl_byte_sel_rd <= ctrl_byte_sel_rd << 1;
    end
end

assign ctrl_ts_vld = ctrl_byte_sel_rd[BLOCK_MAX_BYTE-1];

//***********************circuit table lookup**********************************

reg     [11:0]      circuit_bit_cnt;
reg     [9:0]       circuit_timeslot_rd;

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        circuit_bit_cnt <= 'd0;
    end
    else begin
        if (circuit_bit_rd) begin
            circuit_bit_cnt <= 'd1;
        end
        else if((circuit_bit_cnt > 0) && (circuit_bit_cnt < TIMESLOT_BIT_MAX)) begin
            circuit_bit_cnt <= circuit_bit_cnt + 1;
        end
        else begin
            circuit_bit_cnt <= 'd0;
        end
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        circuit_timeslot_rd <= 'd0;
    end
    else begin
        if (circuit_bit_rd) begin
            circuit_timeslot_rd <= circuit_timeslot;
        end
        else begin
            circuit_timeslot_rd <= circuit_timeslot_rd;
        end
    end
end

always @(posedge sys_clk)
begin
    if(!rst_n) begin
        circuit_bit_vld <= 'd0;
    end
    else if (circuit_bit_cnt > 0) begin
        if ((circuit_bit_cnt >= circuit_bit_start[circuit_timeslot_rd] + 1) && 
            (circuit_bit_cnt < circuit_bit_end[circuit_timeslot_rd] + 1)) begin
            circuit_bit_vld <= 'd1;
        end
        else begin
            circuit_bit_vld <= 'd0;
        end
    end
    else begin
        circuit_bit_vld <= 'd0;
    end
end



endmodule
