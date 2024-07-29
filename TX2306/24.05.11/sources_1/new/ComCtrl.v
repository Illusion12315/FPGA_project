`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/30 19:17:36
// Design Name: 
// Module Name: ComCtrl
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


module ComCtrl(
    input                     clk,
    input                     rst_n,
    
    input           [7:0]     up_gear,
    input           [7:0]     down_gear,
    
    output reg    [ 7:0]    rx_rate_in            ,//���з������ʲ���
    output reg    [ 7:0]    rx_mod_in             ,//���е��Ʒ�ʽ����
    output reg    [ 7:0]    rx_encode_in          ,//���б��뷽ʽ����
    output reg    [ 7:0]    rx_spread_in          ,//������Ƶ���Ӳ���
  

    output reg    [ 7:0]    tx_mode_in                  ,//����ģʽ
    output reg    [ 7:0]    tx_rate_in                  ,//�������ʲ���
    output reg    [ 7:0]    tx_mod_in                   ,//���е��Ʒ�ʽ����
    output reg    [ 7:0]    tx_encode_in                ,//���б��뷽ʽ����
    output reg    [ 7:0]    tx_div_in                    //���зּ�����
    );
    
    reg [7:0]   up_gear_r,up_gear_rr;
    reg [7:0]   down_gear_r,down_gear_rr;
    
    

    
 
 //--------------------------------------
 always @(posedge clk)begin
    up_gear_r <= up_gear;
    up_gear_rr <= up_gear_r;
 end 
 
  always @(posedge clk)begin
    down_gear_r <= down_gear;
    down_gear_rr <= down_gear_r;
 end   
 
 
 //-----------------sx_parameter--begin
 always @(posedge clk or negedge rst_n)begin
    if(rst_n ==1'b0)begin
            tx_mode_in     <=8'd0              ;//����ģʽ
            tx_rate_in     <=8'd0              ;//�������ʲ���
            tx_mod_in      <=8'd0              ;//���е��Ʒ�ʽ����
            tx_encode_in   <=8'd0              ;//���б��뷽ʽ����
            tx_div_in      <=8'd0              ;//���зּ�����   
    end  
    else case(up_gear_rr)
         8'h8E:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h0D;tx_div_in <= 8'h08;end  //501
         8'h8F:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h0C;tx_div_in <= 8'h07;end  //502
         8'h8C:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h0D;tx_div_in <= 8'h07;end  //503
         8'h8D:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h0C;tx_div_in <= 8'h06;end  //504
         8'h8A:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h0D;tx_div_in <= 8'h06;end  //505
         8'h8B:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h0C;tx_div_in <= 8'h05;end  //506
         8'h88:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h0D;tx_div_in <= 8'h05;end  //507
         8'h94:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h17;tx_div_in <= 8'h05;end  //508         
         8'h89:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h0C;tx_div_in <= 8'h04 ;end  //509
         8'h86:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h0D;tx_div_in <= 8'h04;end  //50A
         8'h93:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h17;tx_div_in <= 8'h04;end  //50B
         8'h87:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h06;tx_encode_in <= 8'h0C;tx_div_in <= 8'h03;end  //50C
         8'h84:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h07;tx_encode_in <= 8'h0D;tx_div_in <= 8'h04;end  //50D
         8'h92:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h07;tx_encode_in <= 8'h17;tx_div_in <= 8'h04;end  //50E
         8'h85:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h07;tx_encode_in <= 8'h0C;tx_div_in <= 8'h03;end  //50F
         8'h82:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h07;tx_encode_in <= 8'h0D;tx_div_in <= 8'h03;end  //510       
         8'h91:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h07;tx_encode_in <= 8'h17;tx_div_in <= 8'h03;end  //511
         8'h83:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h07;tx_encode_in <= 8'h0C;tx_div_in <= 8'h02;end  //512
         8'h80:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h07;tx_encode_in <= 8'h0D;tx_div_in <= 8'h02;end  //513
         8'h90:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h07;tx_encode_in <= 8'h17;tx_div_in <= 8'h02;end  //514
         8'h81:begin tx_mode_in <= 8'h05;tx_rate_in <= 8'h0C;tx_mod_in <= 8'h07;tx_encode_in <= 8'h0C;tx_div_in <= 8'h01;end  //515
         
         
        8'hC7:begin tx_mode_in <= 8'h06;tx_rate_in <= 8'h0D ; tx_mod_in <= 8'h09 ; tx_encode_in <= 8'h0F ; tx_div_in <= 8'h01 ;  end //516                                                                                      
        8'hC6:begin tx_mode_in <= 8'h06;tx_rate_in <= 8'h0D ; tx_mod_in <= 8'h09 ; tx_encode_in <= 8'h10 ; tx_div_in <= 8'h01 ;  end //517                                                                                      
        8'hC5:begin tx_mode_in <= 8'h06;tx_rate_in <= 8'h0E ; tx_mod_in <= 8'h09 ; tx_encode_in <= 8'h11 ; tx_div_in <= 8'h01 ;  end //518                                                                                        
        8'hC4:begin tx_mode_in <= 8'h06;tx_rate_in <= 8'h0E ; tx_mod_in <= 8'h09 ; tx_encode_in <= 8'h12 ; tx_div_in <= 8'h01 ;  end //519                                                                                        
        8'hC3:begin tx_mode_in <= 8'h06;tx_rate_in <= 8'h0F ; tx_mod_in <= 8'h09 ; tx_encode_in <= 8'h13 ; tx_div_in <= 8'h01 ;  end //51A                                                                                       
        8'hC2:begin tx_mode_in <= 8'h06;tx_rate_in <= 8'h0F ; tx_mod_in <= 8'h09 ; tx_encode_in <= 8'h14 ; tx_div_in <= 8'h01 ;  end //51B 
        8'hC1:begin tx_mode_in <= 8'h06;tx_rate_in <= 8'h10 ; tx_mod_in <= 8'h09 ; tx_encode_in <= 8'h15 ; tx_div_in <= 8'h01 ;  end //51C 
        8'hC0:begin tx_mode_in <= 8'h06;tx_rate_in <= 8'h10 ; tx_mod_in <= 8'h09 ; tx_encode_in <= 8'h16 ; tx_div_in <= 8'h01 ;  end //51D                                                                                     
        8'hCA:begin tx_mode_in <= 8'h06;tx_rate_in <= 8'h0D ; tx_mod_in <= 8'h08 ; tx_encode_in <= 8'h0E ; tx_div_in <= 8'h01 ;  end //51E 
         
         default:begin
            tx_mode_in     <=8'd0              ;//����ģʽ
            tx_rate_in     <=8'd0              ;//�������ʲ���
            tx_mod_in      <=8'd0              ;//���е��Ʒ�ʽ����
            tx_encode_in   <=8'd0              ;//���б��뷽ʽ����
            tx_div_in      <=8'd0              ;//���зּ�����   
         
         end 
    
    endcase
 end    
 
  //-----------------sx_parameter--end  
  
  
   //-----------------xx_parameter--begin
   always @(posedge clk or negedge rst_n)begin
        if(rst_n ==1'b0)begin
                rx_rate_in    <=     8'd0 ;//���з������ʲ���
                rx_mod_in     <=     8'd0 ;//���е��Ʒ�ʽ����
                rx_encode_in  <=     8'd0 ;//���б��뷽ʽ����
                rx_spread_in  <=     8'd0 ;//������Ƶ���Ӳ���
        end 
        else case(down_gear_rr)
              8'h52:begin rx_rate_in <= 8'h07 ; rx_mod_in <= 8'h03 ; rx_encode_in <= 8'h08 ; rx_spread_in <= 8'h01 ;end
              8'h51:begin rx_rate_in <= 8'h08 ; rx_mod_in <= 8'h05 ; rx_encode_in <= 8'h05 ; rx_spread_in <= 8'h01 ;end
              8'h4F:begin rx_rate_in <= 8'h08 ; rx_mod_in <= 8'h05 ; rx_encode_in <= 8'h06 ; rx_spread_in <= 8'h01 ;end
              8'h4E:begin rx_rate_in <= 8'h09 ; rx_mod_in <= 8'h05 ; rx_encode_in <= 8'h09 ; rx_spread_in <= 8'h01 ;end
              8'h4D:begin rx_rate_in <= 8'h09 ; rx_mod_in <= 8'h05 ; rx_encode_in <= 8'h0A ; rx_spread_in <= 8'h01 ;end
              8'h4C:begin rx_rate_in <= 8'h0A ; rx_mod_in <= 8'h05 ; rx_encode_in <= 8'h0B ; rx_spread_in <= 8'h01 ;end
              8'h4B:begin rx_rate_in <= 8'h0A ; rx_mod_in <= 8'h05 ; rx_encode_in <= 8'h0C ; rx_spread_in <= 8'h01 ;end
              8'h4A:begin rx_rate_in <= 8'h0B ; rx_mod_in <= 8'h05 ; rx_encode_in <= 8'h0D ; rx_spread_in <= 8'h01 ;end
              8'h49:begin rx_rate_in <= 8'h0B ; rx_mod_in <= 8'h05 ; rx_encode_in <= 8'h0E ; rx_spread_in <= 8'h01 ;end
              8'h48:begin rx_rate_in <= 8'h0C ; rx_mod_in <= 8'h06 ; rx_encode_in <= 8'h0D ; rx_spread_in <= 8'h04 ;end //gaosu
              8'h47:begin rx_rate_in <= 8'h0C ; rx_mod_in <= 8'h06 ; rx_encode_in <= 8'h0D ; rx_spread_in <= 8'h03 ;end
              8'h46:begin rx_rate_in <= 8'h0C ; rx_mod_in <= 8'h06 ; rx_encode_in <= 8'h0D ; rx_spread_in <= 8'h02 ;end 
              8'h45:begin rx_rate_in <= 8'h0C ; rx_mod_in <= 8'h06 ; rx_encode_in <= 8'h0D ; rx_spread_in <= 8'h01 ;end 
              8'h44:begin rx_rate_in <= 8'h0C ; rx_mod_in <= 8'h07 ; rx_encode_in <= 8'h0D ; rx_spread_in <= 8'h01 ;end 
              8'h43:begin rx_rate_in <= 8'h0C ; rx_mod_in <= 8'h07 ; rx_encode_in <= 8'h0E ; rx_spread_in <= 8'h01 ;end 
              8'h42:begin rx_rate_in <= 8'h0C ; rx_mod_in <= 8'h07 ; rx_encode_in <= 8'h0F ; rx_spread_in <= 8'h01 ;end //gaosu
              
              default:begin
                  rx_rate_in    <=     8'd0 ;//���з������ʲ���
                  rx_mod_in     <=     8'd0 ;//���е��Ʒ�ʽ����
                  rx_encode_in  <=     8'd0 ;//���б��뷽ʽ����
                  rx_spread_in  <=     8'd0 ;//������Ƶ���Ӳ���
              end   
        
        endcase
   end 
   
   //-----------------xx_parameter--end 
   
//ila_ctrl ila_ctrl_inst (
//	.clk(clk), // input wire clk
//	.probe0(up_gear_rr),   // input wire [7:0]  probe0  
//	.probe1(down_gear_rr)  // input wire [7:0]  probe1 
//	.probe2(rx_rate_in  ), // input wire [7:0]  probe2 
//	.probe3(rx_mod_in   ), // input wire [7:0]  probe3 
//	.probe4(rx_encode_in), // input wire [7:0]  probe4 
//	.probe5(rx_spread_in), // input wire [7:0]  probe5 
//	.probe6(tx_mode_in  ), // input wire [7:0]  probe6 
//	.probe7(tx_rate_in  ), // input wire [7:0]  probe7 
//	.probe8(tx_mod_in   ), // input wire [7:0]  probe8 
//	.probe9(tx_encode_in), // input wire [7:0]  probe9 
//	.probe10(tx_div_in   ) // input wire [7:0]  probe10
//);
                                                                                                  
endmodule




                                                                                                  
