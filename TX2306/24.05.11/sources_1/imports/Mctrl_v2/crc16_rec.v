`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/13 15:42:48
// Design Name: 
// Module Name: crc_16
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
// �����������ݵ�crc16
//////////////////////////////////////////////////////////////////////////////////


module crc16_rec
#(
    parameter                           POLYNOMIAL = 16'h8005      ,//֧��1021,8005
    parameter                           INIT_VALUE  = 16'hFFFF      
)
(
    input  wire                         clk_in                     ,
    input  wire                         rst_n                      ,
//	input		wire				start_in	,
    input  wire        [   7:0]         data_in                    ,
    input  wire                         valid_in                   ,
    output wire        [  15:0]         crc_out                    ,
    output wire                         crc_out_valid               
	
//	output      reg [7:0]          o_data_crc,
//	output      reg                o_data_crc_valid
);
wire                   [  15:0]         crc_reg_ini                ;
reg                    [  15:0]         crc_reg		=0                ;
reg                                     crc_valid_r = 1'b0         ;
//reg             crc_reg_valid;
assign          crc_reg_ini =   INIT_VALUE   ;
assign          crc_out  =  ~ crc_reg ;
assign          crc_out_valid = crc_valid_r;

always @(posedge clk_in or negedge rst_n)begin
    if(rst_n == 1'b0)begin
         crc_reg <= crc_reg_ini;
         crc_valid_r <= 1'b0;
    end
    else if(valid_in)
        begin
            crc_reg[0]     <= data_in[7]^data_in[6]^data_in[5]^data_in[4]^data_in[3]^data_in[2]^data_in[1]^data_in[0]
                            ^crc_reg[15]^crc_reg[14]^crc_reg[13]^crc_reg[12]^crc_reg[11]^crc_reg[10]^crc_reg[09]^crc_reg[08];
            crc_reg[1]     <= data_in[7]^data_in[6]^data_in[5]^data_in[4]^data_in[3]^data_in[2]^data_in[1]
                          ^crc_reg[15]^crc_reg[14]^crc_reg[13]^crc_reg[12]^crc_reg[11]^crc_reg[10]^crc_reg[09];
            crc_reg[2]     <= data_in[1]^data_in[0]^crc_reg[09]^crc_reg[08];
            crc_reg[3]     <= data_in[2]^data_in[1]^crc_reg[10]^crc_reg[09];
            crc_reg[4]     <= data_in[3]^data_in[2]^crc_reg[11]^crc_reg[10];
            crc_reg[5]     <= data_in[4]^data_in[3]^crc_reg[12]^crc_reg[11];
            crc_reg[6]     <= data_in[5]^data_in[4]^crc_reg[13]^crc_reg[12];
            crc_reg[7]     <= data_in[6]^data_in[5]^crc_reg[14]^crc_reg[13];
            crc_reg[8]     <= data_in[7]^data_in[6]^crc_reg[15]^crc_reg[14]^crc_reg[0];
            crc_reg[9]     <= data_in[7]^crc_reg[15]^crc_reg[1];
            crc_reg[10]    <= crc_reg[2];
            crc_reg[11]    <= crc_reg[3];
            crc_reg[12]    <= crc_reg[4];
            crc_reg[13]    <= crc_reg[5];
            crc_reg[14]    <= crc_reg[6];
            crc_reg[15]    <= data_in[7]^data_in[6]^data_in[5]^data_in[4]^data_in[3]^data_in[2]^data_in[1]^data_in[0]
                           ^crc_reg[15]^crc_reg[14]^crc_reg[13]^crc_reg[12]^crc_reg[11]^crc_reg[10]
                           ^crc_reg[9]^crc_reg[8]^crc_reg[7];

            crc_valid_r <= 1'b1;
        end
    else begin
            crc_reg        <= crc_reg_ini;
            crc_valid_r    <= 1'b0;
    end
end

//ila_crc ila_crc_inst (
//	.clk(clk_in), // input wire clk


//	.probe0(data_in), // input wire [7:0]  probe0  
//	.probe1(valid_in), // input wire [0:0]  probe1 
//	.probe2(crc_out), // input wire [15:0]  probe2 
//	.probe3(o_data_crc), // input wire [7:0]  probe3 
//	.probe4(crc_reg_ini), // input wire [15:0]  probe4 
//	.probe5(crc_reg), // input wire [15:0]  probe5 
//	.probe6(crc_valid_r), // input wire [0:0]  probe6 
//	.probe7(s_cnt), // input wire [3:0]  probe7 
//	.probe8(data_in_r), // input wire [7:0]  probe8 
//	.probe9(valid_in_r), // input wire [0:0]  probe9 
//	.probe10(o_data_crc_valid) // input wire [0:0]  probe10
//);

//ila_crc16 ila_crc16_inst (
//    .clk                               (clk_in                    ),// input wire clk


//    .probe0                            (data_in                   ),// input wire [7:0]  probe0  
//    .probe1                            (valid_in                  ),// input wire [0:0]  probe1 
//    .probe2                            (crc_out                   ),// input wire [15:0]  probe2 
//    .probe3                            (crc_reg_ini               ),// input wire [15:0]  probe3 
//    .probe4                            (crc_valid_r               ),// input wire [0:0]  probe4 
//    .probe5                            (crc_reg                   ) // input wire [15:0]  probe5
//);
    
endmodule
