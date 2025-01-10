`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/11 11:38:58
// Design Name: 
// Module Name: fan_pwm
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


module fan_pwm(
	input					csi_clk		,   // 100MHz
	input					csi_reset		, // high active 
	
	input	[1:0]			avs_address	,
	input					avs_read		,
	output	reg [31:0]		avs_readdata ,
	input					avs_write	,
	input		 [31:0]		avs_writedata ,
	
	input                   cpu_total_read_valid,
	input                   cpu_high_read_valid,
	output reg[31:0]        poc_pwm_total_num,
	output reg[31:0]        poc_pwm_high_num,
	
	input             		pwm_in,    
	output	 			    coe_pwm_out 
);
reg [31:0]			total_pwm_cnt;
reg [31:0]			high_out_cnt;
reg					pwm_out_en;
reg 				pwm_default_out;
reg [31:0]			total_counter;
reg 				pwm_output;

assign coe_pwm_out = pwm_out_en ? pwm_output : pwm_default_out;

// according to avs_address to receive configuration 
// include total_pwm_cnt, high_out_cnt, pwm_out_en, pwm_default_out
always@(posedge csi_clk) begin
	if(csi_reset) begin
		total_pwm_cnt <= 32'h1000;
		high_out_cnt <= 32'h400;
		pwm_out_en <= 1'b0;
		pwm_default_out <= 1'b0;	
	end	
	else begin
		if(avs_write)begin
		case(avs_address) 
			2'b00: 
				total_pwm_cnt <= avs_writedata;
			2'b01:
				high_out_cnt <= avs_writedata;
			2'b10:
				pwm_out_en <= avs_writedata[0];
			2'b11:
				pwm_default_out <= avs_writedata[0];
			endcase		
		end	
	end
end

// for pwm_output according to total_pwm_cnt, high_out_cnt
// frequency = 100MHz/total_pwm_cnt 
// duty cycle = high_out_cnt/total_pwm_cnt * 100%
always@(posedge csi_clk)begin
	if(csi_reset) begin
		total_counter <= 32'h0;
		pwm_output <= 1'b1;
	end	
	else begin
		if(pwm_out_en) begin	
			if(total_counter<(total_pwm_cnt - 1)) begin
				total_counter<= total_counter + 32'h1;
			end
			else begin
				total_counter<= 1'b0;
			end
			
			if(total_counter < high_out_cnt) begin
			 	pwm_output <= 1'b1;
			end
			else if(total_counter < (total_pwm_cnt - 1)) begin
				pwm_output <= 1'b0;
			end
			else begin
				pwm_output <= 1'b0;	
			end	
		end
		else begin
			total_counter <= 32'h0;
		end
	end  
end

// for pwm_in delay 
reg					delay1_pwm_in;
reg					delay2_pwm_in;
reg 				delay3_pwm_in;
wire 				detect_rise_edge;
wire 				detect_fall_edge;
always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin 
		delay1_pwm_in	<= 1'b0;
		delay2_pwm_in	<= 1'b0;
		delay3_pwm_in	<= 1'b0;
	end
	else begin
		delay1_pwm_in	<= pwm_in;
		delay2_pwm_in	<= delay1_pwm_in;
		delay3_pwm_in	<= delay2_pwm_in;
	end
end

assign detect_rise_edge = delay2_pwm_in & ~delay3_pwm_in;
assign detect_fall_edge = ~delay2_pwm_in & delay3_pwm_in;


reg					pwm_in_total_cnt_en;
// when rising_edge pwm_in_total_cnt_en 0->1->0->1->...
always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin 
		pwm_in_total_cnt_en <= 0;
	end
	else if(detect_rise_edge) begin
		pwm_in_total_cnt_en <= ~pwm_in_total_cnt_en;  
	end
end

// for pwm_in_total_cnt add 1  when  pwm_in_total_cnt_en
reg[31:0]			pwm_in_total_cnt;
always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin
		pwm_in_total_cnt <= 0;
	end
	else if(!pwm_in_total_cnt_en & detect_fall_edge) begin
		pwm_in_total_cnt <= 0;
	end
	else if(pwm_in_total_cnt_en) begin
		pwm_in_total_cnt <= pwm_in_total_cnt + 1;
	end
end

reg 				pwm_in_high_cnt_en;
always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin
		pwm_in_high_cnt_en <= 0;
	end
	else if(!pwm_in_total_cnt_en) begin
		pwm_in_high_cnt_en <= 0;
	end
	else if(detect_fall_edge) begin
		pwm_in_high_cnt_en <= 0;
	end
	else if(detect_rise_edge) begin
		pwm_in_high_cnt_en <= 1;
	end
end

reg[31:0] 			pwm_in_high_cnt;
always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin 
		pwm_in_high_cnt <= 0;
	end
	else if(!pwm_in_total_cnt_en & detect_fall_edge) begin
		pwm_in_high_cnt <= 0;
	end
	else if(pwm_in_high_cnt_en) begin
		pwm_in_high_cnt <= pwm_in_high_cnt + 1;
	end
end

reg 				total_load;
reg 				delay_total_load;
wire				total_load_rise;
assign total_load_rise = ~delay_total_load & total_load;

reg 				delay_high_load;
reg 				high_load;
wire 				high_load_rise;
assign high_load_rise = ~delay_high_load & high_load;

reg 				total_load_en;
always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin
		total_load_en <= 0;
	end
	else if(total_load_rise) begin
		total_load_en <= 0;
	end
	else if(!pwm_in_total_cnt_en & detect_rise_edge) begin
		total_load_en <= 1;
	end
end

reg 				high_load_en;
always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin
		high_load_en <= 0;
	end
	else if(high_load_rise) begin 
		high_load_en <= 0;
	end
	else if(!pwm_in_total_cnt_en & detect_rise_edge) begin
		high_load_en <= 1;
	end
end

reg[31:0] 			pwm_in_total_num, pwm_in_high_num;
always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin
		pwm_in_total_num <= 0;
	end
	else if(!pwm_in_total_cnt_en & detect_rise_edge) begin 
		pwm_in_total_num <= pwm_in_total_cnt;
	end
end

always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin 
		pwm_in_high_num <= 0;
	end
	else if(!pwm_in_total_cnt_en & detect_rise_edge) begin 
		pwm_in_high_num <= pwm_in_high_cnt;
	end
end


always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin 
		total_load <= 0;
	end
	else if(cpu_total_read_valid) begin 
		total_load <= 0;
	end
	else if(total_load_rise) begin 
		total_load <= 0;
	end
	else if(total_load_en) begin 
		total_load <= 1;
	end
end

always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin 
		high_load <= 0;
	end
	else if(cpu_high_read_valid) begin 
		high_load <= 0;
	end
	else if(high_load_rise) begin 
		high_load <= 0;
	end
	else if(high_load_en) begin 
		high_load <= 1;
	end
end

always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin 
		delay_total_load <= 0;
	end
	else begin
		delay_total_load <= total_load;
	end
end

always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin
		poc_pwm_total_num <=0;
	end
	else if(total_load) begin
		poc_pwm_total_num <= pwm_in_total_num;
	end
end

always@(posedge csi_clk or posedge csi_reset) begin
	if(csi_reset) begin
		poc_pwm_high_num <=0;
	end
	else if(high_load) begin
		poc_pwm_high_num <= pwm_in_high_num;
	end
end

endmodule
