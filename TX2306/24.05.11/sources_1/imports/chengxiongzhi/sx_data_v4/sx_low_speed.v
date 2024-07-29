`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/24 11:54:42
// Design Name: 
// Module Name: sx_data
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


module sx_low_speed(
    input                   clk163m84,
    input                   rst_n,
    
    input   [15:0]         channel_mang,
//    input                  channel_flag,
    input   [7:0]          yw_data,
    input                  yw_data_valid,
    input  [7:0]           i_info_type,
//    input   [7:0]          i_circyw_data,
//    input                  i_circyw_data_valid,
    
    
    input  [15:0]           tx_data1_length_out          ,//�������ݳ��ȣ���λ�ֽ�
    input                   tx_data1_ask_out            ,
    input  [15:0]           tx_data2_length_out          ,//�������ݳ��ȣ���λ�ֽ�
    input                   tx_data2_ask_out            ,
    output reg  [ 7:0]      tx_data1_in                 ,//���п�������
    output reg              tx_data1_valid_in           ,//���п�������ʹ��
    output reg  [ 7:0]      tx_data2_in                 ,//����ҵ������
    output reg              tx_data2_valid_in           ,//����ҵ������ʹ��
    
    
    
    output  reg [7:0]           up_gear
    );
//parameter   IDLE            = 4'd0;
//parameter   S_START         = 4'd1;
//parameter   S_REMAIN_YW     = 4'd2;
//parameter   S_REMAIN_GD     = 4'd3;
//parameter   S_SECGD         = 4'd4;
//parameter   S_SECYW         = 4'd5;
//parameter   S_GD            = 4'd6;
//parameter   S_YW            = 4'd7;
//parameter   S_YWEMPTY       = 4'd8;
//parameter   S_GDEMPTY       = 4'd9;

parameter   IDLE        = 9'b000000000,
            S_START     = 9'b000000001,
            S_SECGD     = 9'b000000010,
            S_SECYW     = 9'b000000100,
            S_REMAIN_YW = 9'b000001000,
            S_REMAIN_GD = 9'b000010000,
            S_GD        = 9'b000100000,
            S_YW        = 9'b001000000,
            S_YWEMPTY   = 9'b010000000,
            S_GDEMPTY   = 9'b100000000;

reg [8:0]    state;  

reg  [15:0]     tx_data1_length_out_r;
reg  [15:0]     tx_data1_length_out_rr;
reg             tx_data1_ask_out_r;
reg             tx_data1_ask_out_rr;
reg  [15:0]     tx_data2_length_out_r;
reg  [15:0]     tx_data2_length_out_rr;
reg             tx_data2_ask_out_r;
reg             tx_data2_ask_out_rr;
reg [15:0]      byte_cnt;

reg  [2:0]      frame_type;




always @(posedge clk163m84)begin
    tx_data1_length_out_r       <= tx_data1_length_out;    
    tx_data1_length_out_rr      <= tx_data1_length_out_r;   
    tx_data1_ask_out_r          <=tx_data1_ask_out;       
    tx_data1_ask_out_rr         <=tx_data1_ask_out_r;      
  end     

always @(posedge clk163m84)begin   
    tx_data2_length_out_r     <=tx_data2_length_out;    
    tx_data2_length_out_rr    <=tx_data2_length_out_r;   
    tx_data2_ask_out_r        <=tx_data2_ask_out;       
    tx_data2_ask_out_rr       <=tx_data2_ask_out_r;      
end




always @(posedge clk163m84 or negedge rst_n)begin
    if(rst_n==1'b0)begin
        up_gear    <= 8'd0;
        frame_type <= 3'd0;
    end 
    else begin
       up_gear    <= channel_mang[10:3];
       frame_type <= channel_mang[2:0];
    end 
end




//----------------fifo_ctrl
//reg         rd_en;
reg        fifo_rd_en;
wire        fifo_wr_en;
wire        fifo_full;
//wire        fifo_rd_en;
wire        fifo_empty;
wire [7:0]  fifo_out;
wire        valid;
wire        almost_empty;



assign fifo_wr_en =!fifo_full && yw_data_valid;
    wire [12:0] data_count;
fifo_up_data fifo_up_data_inst (
  .clk(clk163m84),      // input wire clk
  .srst(!rst_n),    // input wire srst
  .din(yw_data),      // input wire [7 : 0] din
  .wr_en(fifo_wr_en),  // input wire wr_en
  .rd_en(fifo_rd_en),  // input wire rd_en
  .dout(fifo_out),    // output wire [7 : 0] dout
  .full(fifo_full),    // output wire full
  .empty(fifo_empty),  // output wire empty
  .almost_empty(almost_empty),  // output wire almost_empty
  .valid(valid),                // output wire valid
  .data_count(data_count)
);
    wire    remain_vld;
assign remain_vld = (data_count == 'b1) ? 'b1 : 'b0; 
always @(posedge clk163m84 or negedge rst_n)begin
    if(rst_n ==1'b0)begin

        fifo_rd_en                  <= 1'b0;
        byte_cnt                    <= 16'd0;
        
        state                       <= IDLE;
        
    end   
    else case(state)
        IDLE:begin
            byte_cnt                    <= 16'd0;
            fifo_rd_en                  <= 1'b0;
            
            if(fifo_empty == 1'b0)begin
                state       <= S_START;
            end 
            else begin
                state       <= state;
            end 

        end 
       S_START:begin
            if(frame_type == 3'd1)begin
                state <= S_SECGD;
            end 
            else if(frame_type ==3'd2)begin
                state <= S_SECYW;
            end 
            else begin
                state <= state;
            end 
       end 
     S_SECGD:begin
            if(remain_vld)
                state <= S_REMAIN_GD;
            else if((tx_data1_length_out_rr == tx_data1_length_out_r) && tx_data1_ask_out_rr)begin
               state <= S_GD;
            end 

            else begin
                state <= S_START;
            end 
     end 
    S_SECYW:begin
            if(remain_vld) begin
                state <= S_REMAIN_YW;
            end
            else if((tx_data2_length_out_rr == tx_data2_length_out_r) && tx_data2_ask_out_rr)begin
                state <= S_YW;
            end 
            else begin
                state <= S_START;
            end 
    end   
  
  //-------------------------------------------
        S_REMAIN_YW: begin
            fifo_rd_en <= 'b1;
            state <= S_YW;
            byte_cnt <= byte_cnt + 'b1;
        end
        S_REMAIN_GD:begin
            fifo_rd_en <= 'b1;
            state <= S_GD;
            byte_cnt <= byte_cnt + 'b1;
        end 
        
        
        S_GD:begin

//                if(byte_cnt == tx_data1_length_out_rr-1'b1)begin
                if(byte_cnt == tx_data1_length_out_rr)begin
                    fifo_rd_en             <= 1'b0;
                    byte_cnt               <= 16'd0;
                    state                  <= IDLE;
                end 
//                    if(!fifo_empty)begin
                else if(almost_empty)begin
                        fifo_rd_en                  <= 1'b1;
                        byte_cnt                    <= byte_cnt + 1'b1;
                        state                       <= S_GDEMPTY;
                    end 
                else begin
                    fifo_rd_en                  <= 1'b1;
                    byte_cnt                    <= byte_cnt +1'b1;
                    state                       <= state;
                end 
           
        end 

     S_YW:begin
//            if(byte_cnt == tx_data2_length_out_rr-1'b1)begin
             if(byte_cnt == tx_data2_length_out_rr)begin
                    fifo_rd_en             <= 1'b0;
                    byte_cnt               <= 16'd0;
                    state                  <= IDLE;
                end 
//            else if(fifo_empty)begin
            else if(almost_empty)begin
                 fifo_rd_en                  <= 1'b0;
                 byte_cnt                    <= byte_cnt + 1'b1;
                 state                       <= S_YWEMPTY;
            end 
            else begin
                    fifo_rd_en                  <= 1'b1;
                    byte_cnt                    <= byte_cnt + 1'b1;
                    state                       <= state;
                end 

            end 

      S_YWEMPTY:begin
            fifo_rd_en             <= 1'b0;
//            if(byte_cnt == tx_data2_length_out_rr-2'd1)begin
             if(byte_cnt == tx_data2_length_out_rr)begin
//                    fifo_rd_en             <= 1'b0;
                    byte_cnt               <= 16'd0;
                    state                  <= IDLE;
                end 
           else begin
                  byte_cnt <= byte_cnt + 1'b1;
            
           end 
      end 
   S_GDEMPTY:begin
        fifo_rd_en             <= 1'b0;
//            if(byte_cnt == tx_data2_length_out_rr-2'd1)begin
             if(byte_cnt == tx_data1_length_out_rr)begin
//                    fifo_rd_en             <= 1'b0;
                    byte_cnt               <= 16'd0;
                    state                  <= IDLE;
                end 
           else begin
                  byte_cnt <= byte_cnt + 1'b1;
            
           end 
   end 

     default:begin
        fifo_rd_en                  <= 1'b0;
        byte_cnt                    <= 16'd0;
        
        state                       <= IDLE;
     end 
     endcase
end   

reg [7:0]   fifo_out_r;

always @(posedge clk163m84 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        fifo_out_r <= 8'd0;
    end 
    else begin
        fifo_out_r <= fifo_out;
    end 
end 

always @(posedge clk163m84 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        tx_data1_in                 <=8'd0;//���п�������
        tx_data1_valid_in           <=1'b0;//���п�������ʹ��
        tx_data2_in                 <=8'd0;//����ҵ������
        tx_data2_valid_in           <=1'b0;//����ҵ������ʹ��
    end 
    else case(state)
        S_GD:begin
            tx_data1_in                 <=fifo_out;//���п�������
            tx_data1_valid_in           <=fifo_rd_en;//���п�������ʹ��
            tx_data2_in                 <=8'd0;//����ҵ������
            tx_data2_valid_in           <=1'b0;//����ҵ������ʹ��
        end 
        S_YW:begin
            tx_data1_in                 <=8'd0;//���п�������
            tx_data1_valid_in           <=1'b0;//���п�������ʹ��
            tx_data2_in                 <=fifo_out;//����ҵ������
            tx_data2_valid_in           <=fifo_rd_en;//����ҵ������ʹ��
        end 
        S_YWEMPTY:begin
            tx_data1_in                 <=8'd0;//���п�������
            tx_data1_valid_in           <=1'b0;//���п�������ʹ��
            tx_data2_in                 <=8'hAA;//����ҵ������
            tx_data2_valid_in           <=1'b1;//����ҵ������ʹ��
        end 
        S_GDEMPTY:begin
            tx_data1_in                 <=8'hAA;//���п�������
            tx_data1_valid_in           <=1'b1;//���п�������ʹ��
            tx_data2_in                 <=8'd0;//����ҵ������
            tx_data2_valid_in           <=1'b0;//����ҵ������ʹ��
        end
        default:begin
            tx_data1_in                 <=8'd0;//���п�������
            tx_data1_valid_in           <=1'b0;//���п�������ʹ��
            tx_data2_in                 <=8'd0;//����ҵ������
            tx_data2_valid_in           <=1'b0;//����ҵ������ʹ��
        end 
    endcase
 end
    reg [11:0] ywdata_cnt1,ywdata_cnt2;
always @(posedge clk163m84 or negedge rst_n) begin
    if(!rst_n) begin
        ywdata_cnt1 <= 'b0;
    end
    else if(yw_data_valid) begin
        ywdata_cnt1 <= ywdata_cnt1 + 'b1;
    end
    else begin
        ywdata_cnt1 <= 'b0;
    end
end
always @(posedge clk163m84 or negedge rst_n) begin
    if(!rst_n) begin
        ywdata_cnt2 <= 'b0;
    end
    else if(tx_data2_valid_in) begin
        ywdata_cnt2 <= ywdata_cnt2 + 'b1;
    end
    else begin
        ywdata_cnt2 <= 'b0;
    end
end
ila_sx_data ila_sx_data_inst (
	.clk(clk163m84), // input wire clk


	.probe0(state), // input wire [3:0]  probe0  
	.probe1(tx_data1_length_out_rr), // input wire [15:0]  probe1 
	.probe2(tx_data1_ask_out_rr), // input wire [0:0]  probe2 
	.probe3(tx_data2_length_out_rr), // input wire [15:0]  probe3 
	.probe4(tx_data2_ask_out_rr), // input wire [0:0]  probe4 
	.probe5(byte_cnt), // input wire [15:0]  probe5 
	.probe6(frame_type), // input wire [2:0]  probe6 
	.probe7(almost_empty), // input wire [0:0]  probe7 
	.probe8(valid), // input wire [0:0]  probe8 
	.probe9(up_gear), // input wire [7:0]  probe9 
	.probe10(frame_type), // input wire [0:0]  probe10 
	.probe11(fifo_rd_en), // input wire [0:0]  probe11 
	.probe12(fifo_wr_en), // input wire [0:0]  probe12 
	.probe13(fifo_full), // input wire [0:0]  probe13 
	.probe14(fifo_out), // input wire [7:0]  probe14 
	.probe15(fifo_empty), // input wire [0:0]  probe15 
	.probe16(yw_data), // input wire [7:0]  probe16
	.probe17(yw_data_valid), // input wire [0:0]  probe15 
	.probe18(tx_data1_in), // input wire [7:0]  probe16
	.probe19(tx_data1_valid_in), // input wire [0:0]  probe15 
	.probe20(tx_data2_in), // input wire [7:0]  probe16
	.probe21(tx_data2_valid_in), // input wire [0:0]  probe15 
	.probe22(ywdata_cnt1), // input wire [12:0]  probe15 
	.probe23(ywdata_cnt2) // input wire [12:0]  probe15 
);
  
    
endmodule
