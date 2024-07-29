`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/19 10:50:50
// Design Name: 
// Module Name: spi_receiver
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


module spi_receiver(
    //global clock
    input           clk,
    input          rst_n,
    
    //spi interface
    input          spi_wr_en,
    input          spi_cs,//chip select enable,default：L
    input          spi_sck, //Data transfer clock
    input          spi_mosi,//Master output and slaver input
  //output          spi_miso,//Master input and slaver output
  //inout          spi_miso,//三线制用inout
   
   //user interface
   output   reg         rxd_flag,
   output   reg [63:0]   rxd_data
    );
    
 //---------------------------------------
 //mcu data sync to fpga
    reg spi_cs_r0,spi_cs_r1;
    reg spi_sck_r0,spi_sck_r1;
    reg spi_mosi_r0,spi_mosi_r1;
    
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                spi_cs_r0 <= 1; spi_cs_r1 <=1;//chip select enable
                spi_sck_r0<=1;  spi_sck_r1 <=1;//data transfer clock
                spi_mosi_r0<=0; spi_mosi_r1<=0;//Master output and slave input
            end 
          else
            begin
                spi_cs_r0 <= spi_cs;    spi_cs_r1 <=spi_cs_r0;
                spi_sck_r0<=spi_sck;     spi_sck_r1 <=spi_sck_r0;
                spi_mosi_r0<=spi_mosi;  spi_mosi_r1<=spi_mosi_r0;
            end 
    
    end 
 wire   mcu_cs = spi_cs_r1;
 wire   mcu_data=spi_mosi_r1;
 wire   mcu_read_flag=(~spi_sck_r1 & spi_sck_r0)?1'b1:1'b0;
 wire   mcu_read_done=(~spi_cs_r1 & spi_cs_r0)?1'b1:1'b0;
 
 //---------------------------------
 //sample signal,receive data
 reg [6:0]  rxd_cnt;
 reg [63:0]  rxd_data_r;
 always @(posedge clk or negedge rst_n)
 begin
    if(!rst_n)
        begin
            rxd_cnt <= 0;
            rxd_data_r <=0;
        end
    else if(mcu_cs ==1'b0 && spi_wr_en)
        begin
            if(mcu_read_flag)
                begin
                    rxd_data_r[7'd63-rxd_cnt[6:0]] <=mcu_data;
                    
                    
//                    rxd_cnt <= rxd_cnt+1'b1;
                    if(rxd_cnt == 7'd63)begin
                        rxd_cnt <= 7'd0;
                    end 
                    else begin
                        rxd_cnt <= rxd_cnt+1'b1;
                    end 
                    //rxd_flag <=1'b0;
                end 
             else
                begin
                    rxd_cnt <= rxd_cnt;
                    rxd_data_r <= rxd_data_r;
                   // rxd_flag <=rxd_flag;
                end 
         end 
     else
        begin
            rxd_cnt <=0;
            rxd_data_r <= rxd_data_r;
          //  rxd_flag <=rxd_flag;
        end 
 end
 
 //---------------------------------------------
 //output spi receive data and receiver flag
 always @(posedge clk or negedge rst_n)
 begin
    if(!rst_n)
        begin
            rxd_flag <=0;
            rxd_data <=0;
        end 
    else if(mcu_read_done)
        begin
            rxd_flag <=1'b1;
            rxd_data <=rxd_data_r;
        end 
    else
        begin
            rxd_flag <=1'b0;
            rxd_data <=rxd_data;
        end 
 end 
endmodule
