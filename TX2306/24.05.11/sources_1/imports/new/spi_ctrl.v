`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/09 23:40:39
// Design Name: 
// Module Name: spi_ctrl
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


module spi_ctrl(
    input           clk,
    input          rst_n,
    
    //spi interface
    input          spi_cs,//chip select enable,default£ºL
    input          spi_sck, //Data transfer clock
    input          spi_mosi,//Master output and slaver input
    
    input          rxd_flag,
    input          txd_flag,
    
    output reg    spi_cs_r3,
    output reg    spi_sck_r3,
    output reg    spi_mosi_r3,
    
    output  reg        spi_wr_en_r,
    output  reg       spi_rd_en_r
    );
    
    
 parameter  IDLE        = 4'b0001;
 parameter  SEC_LOW     = 4'b0010;
 parameter  WR_CTRL      = 4'b0100;
 parameter  RD_CTRL      = 4'b1000;
 
 reg [3:0]  state;
    
  //mcu data sync to fpga
    reg spi_cs_r0,spi_cs_r1,spi_cs_r2;
    reg spi_sck_r0,spi_sck_r1,spi_sck_r2;
    reg spi_mosi_r0,spi_mosi_r1,spi_mosi_r2;
    
//    reg spi_wr_en_r,spi_rd_en_r;
    
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
  
     always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                spi_cs_r2 <= 1; spi_cs_r3 <=1;//chip select enable
                spi_sck_r2<=1;  spi_sck_r3 <=1;//data transfer clock
                spi_mosi_r2<=0; spi_mosi_r3<=0;//Master output and slave input
            end 
          else
            begin
                spi_cs_r2 <= spi_cs_r1;    spi_cs_r3 <=spi_cs_r2;
                spi_sck_r2<=spi_sck_r1;     spi_sck_r3 <=spi_sck_r2;
                spi_mosi_r2<=spi_mosi_r1;  spi_mosi_r3<=spi_mosi_r2;
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
            
            spi_wr_en_r <= 1'b0;
            spi_rd_en_r <= 1'b0;
            
            state <= IDLE;
        end
      else case(state)
        IDLE:begin
            spi_wr_en_r <= 1'b0;
            spi_rd_en_r <= 1'b0;
            if(mcu_cs ==1'b0 && mcu_read_flag==1'b1)begin
                rxd_data_r[7'd63] <=mcu_data;
                state <= SEC_LOW;
            end 
            else begin
                state <= state;
            end 
        end 
        SEC_LOW:begin
            if(rxd_data_r[63] == 1'b0)begin
                state <= WR_CTRL;
            end 
            else begin
                state <= RD_CTRL;
            end 
        end 
       WR_CTRL:begin
            spi_wr_en_r <= 1'b1;
            spi_rd_en_r <= 1'b0;
            if(rxd_flag==1'b1)begin
                state <= IDLE;
            end 
            else begin
                state <= state;
            end 
       end  
       RD_CTRL:begin
            spi_wr_en_r <= 1'b0;
            spi_rd_en_r <= 1'b1;
            if(txd_flag==1'b1)begin
                state <= IDLE;
            end 
            else begin
                state <= state;
            end 
       end 
       default:begin
            rxd_cnt <= 0;
            rxd_data_r <=0;
            
            spi_wr_en_r <= 1'b0;
            spi_rd_en_r <= 1'b0;
            
            state <= IDLE;
       end 
      
      endcase

 end   
    
endmodule
