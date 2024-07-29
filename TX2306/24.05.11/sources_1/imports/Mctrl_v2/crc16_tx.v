`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/29 14:44:11
// Design Name: 
// Module Name: crc16_sim
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


module crc16_tx
#(
	parameter POLYNOMIAL = 16'h8005  ,//Ö§³Ö1021,8005
	parameter INIT_VALUE  = 16'hFFFF
)
(
	input		wire				clk_in		,	
	input       wire                rst_n,
	input		wire	[7:0]		data_in		,
	input		wire				valid_in	,
	output		wire	[15:0]		crc_out	    ,
	output      wire               crc_out_valid,

	
	output      reg [7:0]          o_data_crc,
	output      wire                o_data_crc_valid
);

wire    [15:0]  crc_reg_ini		;

reg		[15:0]	  crc_reg		=0	;
reg              crc_valid_r = 1'b0;


assign      	crc_reg_ini =   INIT_VALUE   ;
assign      	crc_out  =   ~crc_reg ;
assign          crc_out_valid = crc_valid_r;


	
always @(posedge clk_in or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        crc_reg <= crc_reg_ini;
        
        crc_valid_r <= 1'b0;
    end 
    else if(valid_in)begin
        crc_reg[0] 	<= data_in[7]^data_in[6]^data_in[5]^data_in[4]^data_in[3]^data_in[2]^data_in[1]^data_in[0]
		        							^crc_reg[15]^crc_reg[14]^crc_reg[13]^crc_reg[12]^crc_reg[11]^crc_reg[10]^crc_reg[09]^crc_reg[08];
        					crc_reg[1] 	<= data_in[7]^data_in[6]^data_in[5]^data_in[4]^data_in[3]^data_in[2]^data_in[1]
        								  ^crc_reg[15]^crc_reg[14]^crc_reg[13]^crc_reg[12]^crc_reg[11]^crc_reg[10]^crc_reg[09];
        					crc_reg[2] 	<= data_in[1]^data_in[0]^crc_reg[09]^crc_reg[08];
        					crc_reg[3] 	<= data_in[2]^data_in[1]^crc_reg[10]^crc_reg[09];
        					crc_reg[4] 	<= data_in[3]^data_in[2]^crc_reg[11]^crc_reg[10];
        					crc_reg[5] 	<= data_in[4]^data_in[3]^crc_reg[12]^crc_reg[11];
        					crc_reg[6] 	<= data_in[5]^data_in[4]^crc_reg[13]^crc_reg[12];
        					crc_reg[7] 	<= data_in[6]^data_in[5]^crc_reg[14]^crc_reg[13];
        					crc_reg[8] 	<= data_in[7]^data_in[6]^crc_reg[15]^crc_reg[14]^crc_reg[0];
        					crc_reg[9] 	<= data_in[7]^crc_reg[15]^crc_reg[1];
        					crc_reg[10]	<= crc_reg[2];
        					crc_reg[11]	<= crc_reg[3];
        					crc_reg[12]	<= crc_reg[4];
        					crc_reg[13]	<= crc_reg[5];
        					crc_reg[14]	<= crc_reg[6];
        					crc_reg[15]	<= data_in[7]^data_in[6]^data_in[5]^data_in[4]^data_in[3]^data_in[2]^data_in[1]^data_in[0]
        								   ^crc_reg[15]^crc_reg[14]^crc_reg[13]^crc_reg[12]^crc_reg[11]^crc_reg[10]
        								   ^crc_reg[9]^crc_reg[8]^crc_reg[7];
            crc_valid_r <= 1'b1;
    end 

    else begin
        crc_reg <= crc_reg_ini;
        crc_valid_r <= 1'b0;
    end 
end 


//------------------------------
reg valid_in_r;
reg crc_valid_r1,crc_valid_r2;

wire neg_valid_in;
wire neg_crc_valid_r;

reg [15:0] crc_out_r;

always @(posedge clk_in)begin
    crc_out_r <= crc_out;
end 

always @(posedge clk_in)begin
    valid_in_r <= valid_in;   
end 

always @(posedge clk_in)begin
    crc_valid_r1 <= crc_valid_r;   
    crc_valid_r2 <= crc_valid_r1;
end 

assign neg_valid_in = !valid_in && valid_in_r;
assign neg_crc_valid_r = !crc_valid_r && crc_valid_r1;

always @(posedge clk_in or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        o_data_crc <= 7'd0;
    end 
    else if(valid_in)begin
        o_data_crc <= data_in;
    end 
    else if(neg_valid_in)begin
        o_data_crc <= crc_out[15:8];
        
    end 
    else if(neg_crc_valid_r)begin
        o_data_crc <= crc_out_r[7:0];
    end 
end 

assign o_data_crc_valid = crc_valid_r2 | crc_valid_r;

endmodule
