////////////////////////////////////////////////////////////////////////////////
////                                                                        ////
//// Project Name: SPI (Verilog)                                            ////
////                                                                        ////
//// Module Name: spi_master                                                ////
////                                                                        ////
////                                                                        ////
////  This file is part of the Ethernet IP core project                     ////
////  http://opencores.com/project,spi_verilog_master_slave                 ////
////                                                                        ////
////  Author(s):                                                            ////
////      Santhosh G (santhg@opencores.org)                                 ////
////                                                                        ////
////  Refer to Readme.txt for more information                              ////
////                                                                        ////
////////////////////////////////////////////////////////////////////////////////
////                                                                        ////
//// Copyright (C) 2014, 2015 Authors                                       ////
////                                                                        ////
//// This source file may be used and distributed without                   ////
//// restriction provided that this copyright statement is not              ////
//// removed from the file and that any derivative work contains            ////
//// the original copyright notice and the associated disclaimer.           ////
////                                                                        ////
//// This source file is free software; you can redistribute it             ////
//// and/or modify it under the terms of the GNU Lesser General             ////
//// Public License as published by the Free Software Foundation;           ////
//// either version 2.1 of the License, or (at your option) any             ////
//// later version.                                                         ////
////                                                                        ////
//// This source is distributed in the hope that it will be                 ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied             ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR                ////
//// PURPOSE.  See the GNU Lesser General Public License for more           ////
//// details.                                                               ////
////                                                                        ////
//// You should have received a copy of the GNU Lesser General              ////
//// Public License along with this source; if not, download it             ////
//// from http://www.opencores.org/lgpl.shtml                               ////
////                                                                        ////
////////////////////////////////////////////////////////////////////////////////
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  SPI MODE 3
		CHANGE DATA @ NEGEDGE
		read data @posedge

 RSTB-active low asyn reset, CLK-clock, T_RB=0-rx  1-TX, mlb=0-LSB 1st 1-msb 1st
 START=1- starts data transmission cdiv 0=clk/4 1=clk/8   2=clk/16  3=clk/32
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1 ns / 1 ps

module spi_master_keyboard(rstb,clk,mlb,start,keyboard_cmd, keyboard_txd, cdiv,din,write_data_flag,read_data_flag,read_status,ss,sck,dout,done,rdata,inout_sel);
    input rstb,clk,mlb,start;
    input [7:0] keyboard_cmd; // keyboard command
    input [7:0] keyboard_txd; // keyboard data
    input [1:0] cdiv;  //clock divider
	input din;
	input write_data_flag;
	input read_data_flag;
	input read_status;
	output reg ss; 
	output reg sck; 
	output reg dout; 
    output reg done;
	output reg [7:0] rdata; //received data
	output reg inout_sel;

parameter idle=4'h0;	
parameter ss_delay = 4'h1;
parameter sendcmd=4'h2;
parameter senddat=4'h3;
parameter senddat_wait = 4'h4;
parameter receivedat=4'h5; 
parameter receivedat_wait = 4'h6;
parameter finish=4'h7;
parameter stop =4'h9;

(*mark_debug = "true"*) reg [3:0] cur,nxt;
(*mark_debug = "true"*)	reg [7:0] treg,rreg;
(*mark_debug = "true"*)	reg [7:0] tdat;
(*mark_debug = "true"*)	reg [3:0] nbit;
(*mark_debug = "true"*)	reg [11:0] mid,cnt;
(*mark_debug = "true"*)	reg shift,clr;
(*mark_debug = "true"*)	reg[3:0] nbit_buf;

//state transistion
always@(negedge clk or negedge rstb) begin
 if(rstb==0) 
   cur<=stop;
 else 
   cur<=nxt;
 end	

always@(negedge clk or negedge rstb) begin
 if(rstb==0) 
   mid<=1024;
 else 
   case (cdiv)
	2'b00: mid=2;
	2'b01: mid=4;
	2'b10: mid=8;
	2'b11: mid=1024;
   endcase
 end
 
always@(negedge clk or negedge rstb)
if(rstb==0) inout_sel <= 0;
else if(cur == idle) inout_sel <= 0;
else if((cur == receivedat_wait)&&(nbit_buf == 4'h9)) inout_sel <= 1;

always@(negedge clk or negedge rstb)
if(rstb==0) done=1'b0;
else if(read_status) done=1'b0;
//else if((((cur == sendcmd) && !write_data_flag && !read_data_flag)|(cur == senddat)|(cur == receivedat))&&(nbit_buf==4'h8)) done=1'b1;
else if((cur == stop)&&(nbit_buf==4'h9)) done=1'b1;

reg delay_flag;
reg[10:0] delay_cnt;
always@(negedge clk or negedge rstb)
if(rstb==0) delay_cnt<=1'b0;
else if(delay_flag) delay_cnt<=delay_cnt + 1;

//FSM i/o
always @(start or cur or nbit or cdiv or rreg or delay_cnt or keyboard_cmd or write_data_flag or keyboard_txd or read_data_flag) begin
		 nxt=cur;
		 clr=0;  
		 shift=0;//
		 ss=1;
		 delay_flag = 0;
		 case(cur)
			idle:begin
				if(start==1)
		               begin
		               	tdat = keyboard_cmd;
						ss=0;
						nxt=ss_delay;
						delay_flag = 1;	 
						end
				ss=1;
		        end //idle
		    ss_delay:begin
		    	if(delay_cnt == 11'h7ff)
		               begin		               	
						shift=1;
						clr=0;
						ss=0;
						nxt=sendcmd;	 
						end
				ss=0;
				delay_flag = 1;
		        end 

			sendcmd:begin
				ss=0;
				delay_flag = 0;
				if(nbit!=8)
					begin shift=1; end
				else if(write_data_flag) begin
					shift=1;
					tdat = keyboard_txd;
					nxt = senddat_wait;
				end
				else if(read_data_flag) begin
					nxt = receivedat_wait;
				end
				else begin
					    shift=1;
						rdata=rreg;
						nxt=finish;
					end
				end//send
			senddat_wait:begin
				shift=1;
				ss=0;
				if(nbit==4'hb)begin
					ss=0;
				   nxt = senddat;
				end
			end	
			senddat:begin
			if(nbit!=8)
					begin shift=1;
						ss=0;
						 end	
			else begin
						//rdata=rreg;
						ss=0;
						nxt=finish;
					end
			end
			receivedat_wait:begin
				shift=1;
				ss=0;
				if(nbit==4'hb)begin
				   nxt = receivedat;
				   ss=0;
				end
			end
			receivedat:begin
				if(nbit!=8)
					begin shift=1;
						ss=0;
						 end	
			else begin
						//rdata=rreg;
						ss=0;
						nxt=finish;
					end
			end
			
			finish:begin
				if(nbit!=9)begin
					shift=1;
					ss=0;
				end
				else begin
					rdata=rreg;
					ss=0;
					nxt=stop;
				end
				 end
				 
			stop:begin
				shift=0;
				ss=1;
				clr=1;
				delay_flag = 0;
				nxt=idle;
			end	 
			
			default: nxt=stop;
      endcase
    end//always
    

reg sck_reg;
//setup falling edge (shift dout) sample rising edge (read din)
always@(negedge clk or posedge clr)
  if(clr==1) sck_reg<=1;
  else if((shift==1)&&(cnt==mid)) sck_reg<=~sck_reg;

always@(negedge clk or posedge clr)
if(clr==1) cnt<=0;
else if ((shift==1)&&(cnt==mid)) cnt<=0;
else if (shift==1) cnt<=cnt+1;

always@(posedge sck_reg or posedge clr )
 if(clr==1) nbit<=0;
 else if(nbit == 4'hb) nbit<=1;
 else nbit<=nbit+1;

always@(negedge clk or negedge rstb)
if(!rstb) nbit_buf <= 0;
else nbit_buf <= nbit;

reg sck_buf3,sck_buf2,sck_buf1,sck_buf0;
always@(negedge clk or negedge rstb)
if(!rstb) {sck_buf3,sck_buf2,sck_buf1,sck_buf0} <= 0;
else {sck_buf3,sck_buf2,sck_buf1,sck_buf0} <= {sck_buf2,sck_buf1,sck_buf0,sck_reg};

wire sck_reg_falledge;
assign sck_reg_falledge = sck_buf3 & ~sck_buf2;

reg trig;
always@(negedge clk or negedge rstb)
if(!rstb) trig <= 0;
else if(sck_reg_falledge && (nbit_buf == 4'h0)) trig <= 1;
else if((nbit_buf == 4'h1)) trig <= 0;

reg sck_out_ctl;
always@(negedge clk or negedge rstb)
if(!rstb) sck_out_ctl <= 1;
else if(trig) sck_out_ctl <= 1;
else if(sck_reg_falledge && (nbit_buf == 4'h8)) sck_out_ctl <= 0;
else if(sck_reg_falledge && (nbit_buf == 4'hb)) sck_out_ctl <= 1;
else if(nbit_buf == 4'h0) sck_out_ctl <= 0;

//always@(posedge clk or posedge rstb)
always@(posedge clk or negedge rstb)
  if(!rstb) sck <= 1;
  else sck <= sck_out_ctl && sck_reg;

//sample @ fall edge (read din)
//always@(negedge sck_reg or posedge clr ) // or negedge rstb
// if(clr==1)  rreg=8'hFF;  
// else if(mlb==0) rreg={din,rreg[7:1]};//LSB first, din@msb -> right shift
// else  rreg={rreg[6:0],din};//MSB first, din@lsb -> left shift
reg din_tmp;
always @ ( posedge clk or negedge rstb ) begin 
	if ( !rstb ) begin 
		din_tmp <= 1'b1;
	end else begin 
		din_tmp <= din;
	end 
end 
always@(negedge sck_reg or posedge clr ) // or negedge rstb
 if(clr==1)  rreg=8'hFF;  
 else if(mlb==0) rreg={din_tmp,rreg[7:1]};//LSB first, din@msb -> right shift
 else  rreg={rreg[6:0],din_tmp};//MSB first, din@lsb -> left shift

always@(negedge sck_reg or posedge clr) begin
 if(clr==1) begin
      treg=8'hFF;
	  dout=1;  
  end  
 else begin
		if(nbit==0) begin //load data into TREG
			treg=tdat; 
			dout=mlb?treg[7] & ~inout_sel:treg[0] & ~inout_sel;
		end //nbit_if
		else if(nbit==4'hb) begin //load data into TREG
			treg=tdat; 
			dout=mlb?treg[7] & ~inout_sel:treg[0] & ~inout_sel;
		end //nbit_if
		else begin
			if(mlb==0) //LSB first, shift right
				begin 
					treg={1'b1,treg[7:1]}; 
					dout=treg[0] & ~inout_sel; 
					end
			else//MSB first shift LEFT
				begin 
					treg={treg[6:0],1'b1}; 
					dout=treg[7] & ~inout_sel; 
					end
		end
 end //rst
end //always


endmodule
