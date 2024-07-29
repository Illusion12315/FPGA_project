`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2022 03:47:07 PM
// Design Name: 
// Module Name: lvds_p2s
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


module lvds_p2s(
	clk,
	rst_n,
//input
	din_sof,
	din_vld,
	din_eof,
	din,
	din_len,
//output
	dout,
	dout_vld,
	dout_sof,
	cnt_sdl_output
);
////////////////////////////////////////////////////////////
//input	
input		clk;
input		rst_n;
input		din_sof;
input		din_vld;
input		din_eof;
input	[7:0]	din;
input	[15:0]	din_len;
//output
output	[3:0]	dout;
output			dout_vld;
output			dout_sof;
output	reg	[31:0] cnt_sdl_output;

//len ram
wire	        len_wren;
reg [8:0]       len_wraddr;
reg	[8:0]       len_rdaddr;
reg [15:0]      len_dout;
//data fifo
wire            flag_rden;
wire            empty;
wire            full;
wire            almost_empty;
wire            almost_full;
wire [18:0] 	rd_data_count;
wire [15:0]	    wr_data_count;
reg	            fifo_rden;
wire	        fifo_rddata;

reg	            fifo_rden_d1;
reg	            fifo_rden_d2;
reg	            fifo_rden_d3;
reg	            fifo_rddata_d1;
////////////////////reg & wire/////////////////
reg   [15:0]    cnt_rdlen;
reg   [16:0]    wait_len;
reg   [15:0]    dout_len;
wire  [15:0]    len_dout_d0;
reg             sdl_eof;

//////////////////// code /////////////////
assign len_wren = din_sof;

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		len_wraddr <= 9'd0;
	else if(len_wren)
		len_wraddr <= len_wraddr + 1'b1;
	else
		len_wraddr <= len_wraddr;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		wait_len <= 17'd0;
	else
		wait_len <= {len_dout,4'd0};
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		dout_len <= 16'd0;
//	else if(len_dout<272)
//	    dout_len <= 4352 - {len_dout,3'd0};
	else
		dout_len <= {len_dout,3'd0};
end

//assign flag_rden_2 = ((cnt_rdlen == (wait_len -2'd2)) && (len_dout > 1'd0));
assign flag_rden = (cnt_rdlen == (wait_len - 1'd1));

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		len_rdaddr <= 9'd0;
	else if(flag_rden)
		len_rdaddr <= len_rdaddr + 1'b1;
	else
		len_rdaddr <= len_rdaddr;
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		len_dout <= 16'd0;
	else if(flag_rden)
        len_dout <= 16'd0;
	else if(!empty)
		len_dout <= len_dout_d0;
	else
		len_dout <= len_dout;
end


//length ram
SDPRAM_16X512_16X512 U_SDPRAM_16X512_16X512 (
  .clka(clk),    // input wire clka
  .ena(len_wren),      // input wire ena
  .wea(1'b1),      // input wire [0 : 0] wea
  .addra(len_wraddr),  // input wire [8 : 0] addra
  .dina(din_len),    // input wire [15 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(len_rdaddr),  // input wire [8 : 0] addrb
  .doutb(len_dout_d0)  // output wire [15 : 0] doutb
);


SYNCFIFO_8X32768_1X262144 SYNCFIFO_8X32768_1X262144 (
  .clk(clk),                      // input wire clk
  .srst(!rst_n),                    // input wire srst
  .din(din),                      // input wire [7 : 0] din
  .wr_en(din_vld),                  // input wire wr_en
  .rd_en(fifo_rden),                  // input wire rd_en
  .dout(fifo_rddata),                    // output wire [0 : 0] dout
  .full(full),                    // output wire full
  .almost_full(almost_full),      // output wire almost_full
  .empty(empty),                  // output wire empty
  .almost_empty(almost_empty),    // output wire almost_empty
  .rd_data_count(rd_data_count),  // output wire [18 : 0] rd_data_count
  .wr_data_count(wr_data_count)  // output wire [15 : 0] wr_data_count
);

//////////////////////////////////////////////
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt_rdlen <= 16'd0;
	else if(flag_rden)
		cnt_rdlen <= 16'd0;
	else if((cnt_rdlen < (wait_len - 1'd1)) && (len_dout > 1'd0))
		cnt_rdlen <= cnt_rdlen + 1'b1;
	else
		cnt_rdlen <= cnt_rdlen;
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		sdl_eof <= 1'b0;
	else if(cnt_rdlen > dout_len - 1'd1)
		sdl_eof <= 1'b1;
	else
		sdl_eof <= 1'b0;
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		fifo_rden <= 1'b0;
	else if(sdl_eof)
		fifo_rden <= 1'b0;
	else if(|cnt_rdlen)
		fifo_rden <= 1'b1;
	else
		fifo_rden <= fifo_rden;
end



always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		fifo_rden_d1    <= 1'b0;
		fifo_rden_d2    <= 1'b0;
		fifo_rden_d3    <= 1'b0;
		fifo_rddata_d1  <= 1'b0;
	end
	else begin
		fifo_rden_d1    <= fifo_rden   ;
		fifo_rden_d2    <= fifo_rden_d1;
		fifo_rden_d3    <= fifo_rden_d2;
		fifo_rddata_d1  <= fifo_rddata ;	
	end
end

assign dout     = {fifo_rden_d2,2'b0,fifo_rddata_d1};
assign dout_vld = fifo_rden_d2;
assign dout_sof = fifo_rden_d2 & (!fifo_rden_d3);



//cnt_sdl
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt_sdl_output <= 32'd0;
	else if(dout_sof)
		cnt_sdl_output <= cnt_sdl_output + 1'b1;
	else
		cnt_sdl_output <= cnt_sdl_output;
end


//VIO_IN
//VIO_P2S U_VIO_P2S(
//	.clk(clk),
//	.probe_in0(cnt_sdl_output)
//);
//reg [15:0]  rd_cnt;

//always @(posedge clk or negedge rst_n)begin
//    if(rst_n ==1'b0)begin
//        rd_cnt <= 16'd0;
//    end 
//    else if(dout_vld)begin
//        rd_cnt <= rd_cnt + 1'b1;
//    end 
//    else begin
//        rd_cnt <= 16'd0;
//    end 
    
//end 

//////---ILA
//ILA_P2S U_ILA_P2S(
//	.clk  (clk),

//	.probe0       (din_sof        ),  // input wire [0  :0]  probe0 
//	.probe1       (din_vld      ),  // input wire [0 :0]  probe1 
//	.probe2       (din_eof      ),  // input wire [0 :0]  probe2 
//	.probe3       (din       ),  // input wire [7  :0]  probe3 
//	.probe4       (din_len    ),  // input wire [15 :0]  probe4 

//	.probe5       (dout    ),  // input wire [3 :0]  probe5 
//	.probe6       (dout_vld  ),  // input wire [0  :0]  probe6 
//	.probe7       (dout_sof),  // input wire [0 :0]  probe7 

//	.probe8       (len_wren      ),  // input wire [0  :0]  probe8 
//	.probe9       (len_wraddr     ),  // input wire [8  :0]  probe9 
//	.probe10      (len_rdaddr  ),  // input wire [8 :0]  probe10 
//	.probe11      (len_dout  ),  // input wire [15 :0]  probe11 

//	.probe12      (flag_rden        ),  // input wire [0  :0]  probe12 
//	.probe13      (empty       ),  // input wire [0  :0]  probe13 
//	.probe14      (full     ),  // input wire [0:0]  probe14 

//	.probe15      (rd_data_count     ),  // input wire [19 :0]  probe15 
//	.probe16      (wr_data_count           ),  // input wire [15  :0]  probe16 
//	.probe17      (fifo_rden           ),  // input wire [0  :0]  probe17 
//	.probe18      (fifo_rddata        ),  // input wire [0 :0]  probe18 
//	.probe19      (cnt_rdlen        ),   // input wire [15 :0]  probe19  
	
//	.probe20      (dout_len  ),  // input wire [15 :0]  probe20 
//    .probe21      (wait_len  ),  // input wire [16 :0]  probe21 
    
//	.probe22      (len_dout_d0        ),  // input wire [15  :0]  probe22 
//	.probe23      (sdl_eof        )  // input wire [0  :0]  probe23 
////	.probe24      (rd_cnt        ) // input wire [15  :0]  probe22 

	
//);


endmodule
