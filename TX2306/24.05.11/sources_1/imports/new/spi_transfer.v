`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/19 11:23:12
// Design Name: 
// Module Name: spi_transfer
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


module spi_transfer(
    //global clock
    input       clk,
    input       rst_n,
    
    //spi interface
    input       spi_rd_en,
    input       spi_cs,//Chip select enable,default:1
    input       spi_sck,//Data transfer clock
    //input     spi_miso,//Master output and slave input
    output  reg  spi_miso,//Master input and slave  output
    
    //user interface
    input       txd_en,//transfer enable
    input [63:0] txd_data,//transfer data
    
    output reg  txd_flag  //transfer complete signal
    );
    
    //------------------------------------------------
    //mcu data sync to fpga
    reg spi_cs_r0,  spi_cs_r1;
    reg spi_sck_r0, spi_sck_r1;
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                spi_cs_r0 <=1; spi_cs_r1 <=1; //chip select enable
                spi_sck_r0 <=0;spi_sck_r1 <=0; //data transfer clock
            end 
         else
            begin
                spi_cs_r0 <=spi_cs;     spi_cs_r1 <=spi_cs_r0;
                spi_sck_r0 <=spi_sck;   spi_sck_r1 <=spi_sck_r0; 
            end 
    end 
    wire    mcu_cs = spi_cs_r1;
    wire    mcu_write_flag =(spi_sck_r1 & ~spi_sck_r0)?1'b1:1'b0; //negedge of sck;
    wire    mcu_write_done =(~spi_cs_r1 & spi_cs_r0)?1'b1:1'b0;//posedge of cs;
    
    //-----------------------------------
    //shift signal,transfer data
    localparam SPI_MISO_DEFAULT = 1'b1;
    localparam  T_IDLE =1'b0; //test the flag to transfer data
    localparam  T_SEND =1'b1;   //spi transfer data
    
    reg [1:0]   txd_state;
    reg [6:0]   txd_cnt;
    
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                spi_miso <= SPI_MISO_DEFAULT;
                txd_cnt <=0;
                txd_state <=0;
            end 
         else
            begin
                case(txd_state)
                    T_IDLE:
                        begin
                            spi_miso <= SPI_MISO_DEFAULT;
                            txd_cnt <= 0;
                            if(txd_en && spi_rd_en)
                                txd_state <= T_SEND;
                            else
                                txd_state <=T_IDLE;
                        end 
                     T_SEND:    //spi transfer data
                        begin
                            if(mcu_write_done ==1'b1)
                                txd_state <= T_IDLE;
                            else
                                txd_state <= T_SEND;
                            if(mcu_cs == 1'b0)
                                begin
                                    if(mcu_write_flag)  //spi sck negedge
                                        begin
                                            spi_miso <=txd_data[7'd63-txd_cnt[6:0]];
                                            
                                            if(txd_cnt == 7'd63)begin
                                                txd_cnt <= 7'd0;
                                            end 
                                            else begin
                                                txd_cnt <= txd_cnt +1'b1;
                                            end 
                                        end 
                                    else
                                        begin
                                            spi_miso <= spi_miso;
                                            txd_cnt <= txd_cnt;
                                        end 
                                end 
                             else
                                begin
                                    spi_miso <=SPI_MISO_DEFAULT;
                                    txd_cnt <=0;
                                end 
                        end 
                endcase
            end 
    end 
    
 //--------------------------------------
 //output spi transfer flag
 always @(posedge clk or negedge rst_n)
 begin
    if(!rst_n)
        txd_flag <=0;
     else
        txd_flag <= mcu_write_done;
 end 
endmodule
