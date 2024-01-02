`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/06 16:28:27
// Design Name: 
// Module Name: blk2711_wrapper
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

module blk2711_wrapper(
    input                               clk_100m                   ,
    input                               hw_rst_n                   ,
    input                               sys_rst_n                  ,
    //
    input                               rx_100m                    ,
    input                               rx_200m                    ,
    input                               rx_reset_n                 ,
    //status
    output reg                          pw_rst_done                ,
    input              [  15:0]         send_data_num              ,//�����������ݸ���  ������K�뽻�淢��
    input              [  15:0]         send_k_num                 ,//��������K����� 
    output                              frame_start_flag           ,//������ʼ�������ݱ�־
    input                               loop_mod_i                 ,
    
    //data  
    input                               fifo_us_wrclk              ,//���Ͷ� дfifo�ӿ�        
    input                               fifo_us_wrreq              ,
    input              [  15:0]         fifo_us_data               ,
    output                              fifo_us_prog_full          ,
    //data
    input                               fifo_ds_rdclk              ,//���ն� ��fifo�ӿ�
    input                               fifo_ds_rdreq              ,
    output             [  15:0]         fifo_ds_q                  ,
    output                              fifo_ds_empty              ,
    
//------------ 2711 CTRL ------------//
      
    output                              LOOP_EN                    ,//�ػ�ʹ�ܣ�����Ч                
    output                              ENABLE                     ,//����ʹ�ܣ�����Ч                
    output                              LCKREFN                    ,//���ն�ʱ������ʹ�ܣ�����Ч           
    output                              PRBSEN                     ,//α�������ʹ�ܣ�����Ч             
    output                              TESTEN                     ,//1'b0 ����ģʽʹ�ܣ�����Ч         
    output                              PRE                        ,//Ԥ���أ�Զ���봫��ʱ��1�����ź�������������Ч 
//------------ DATA & DATA_CTRL ------------//
    output                              TKMSB                      ,//���Ͷ� ��8λK���־    
    output                              TKLSB                      ,//���Ͷ� ��8λK���־    
    input                               RKMSB                      ,//���ն� ��8λK���־    
    input                               RKLSB                      ,//���ն� ��8λK���־    
    
    output             [  15:0]         TX_Data                    ,//��������           
    input              [  15:0]         RX_Data                     //��������           
    );

// registers
//---------------------------------------------------------------------  
//
reg                                     device_en   = 'd0          ;
reg                                     lckrefn_r   = 'd0          ;
reg                                     loop_en_r   = 'd0          ;
reg                    [  31:0]         rst_cnt     = 'd0          ;

reg                    [  15:0]         frame_header= 16'hFDF7     ;//����ͷ
reg                    [  15:0]         frame_tail  = 16'hF7FD     ;//����β
//---------------------------------------------------------------------
// wires
//--------------------------------------------------------------------- 
wire                                    fifo_us_rdclk              ;
wire                                    fifo_us_empty              ;
wire                                    fifo_us_rdreq              ;
wire                   [  15:0]         fifo_us_q                  ;
wire                                    fifo_us_valid              ;

wire                                    fifo_ds_wrclk              ;
wire                                    fifo_ds_prog_full          ;
wire                                    fifo_ds_wrreq              ;
wire                   [   7:0]         fifo_ds_rx_data            ;

//---------------------------------------------------------------------
// Assign
//--------------------------------------------------------------------- 
localparam                              time_10ms      = 32'd1_000_000;

assign      PRBSEN          = 1'b0;
assign      TESTEN          = 1'b0;
assign      PRE             = 1'b0;
assign      LOOP_EN         = loop_en_r;
assign      ENABLE          = device_en;
assign      LCKREFN         = lckrefn_r;

assign      fifo_us_rdclk   = clk_100m;
assign      fifo_ds_wrclk   = rx_200m;

always@(posedge fifo_us_rdclk )begin
    frame_header   <= 16'hFDF7;
    frame_tail     <= 16'hF7FD;
end

//---------------------------------------------------------------------
// ��ʼ��
//--------------------------------------------------------------------- 
    always@(posedge clk_100m or negedge hw_rst_n)begin
        if(!hw_rst_n)begin
            device_en   <= 'd0;
            lckrefn_r   <= 'd0;
            loop_en_r   <= 'd0;
            pw_rst_done <= 'd0;
            rst_cnt     <= 'd0;
        end
        else if(rst_cnt >= time_10ms)begin
            pw_rst_done <= 1'b1;
            rst_cnt     <= rst_cnt;
            loop_en_r   <= loop_mod_i;
        end
        else begin
            rst_cnt     <= rst_cnt + 'd1;
            pw_rst_done <= 1'b0;
            case(rst_cnt)
                32'd100:begin
                    device_en   <= 'd1;
                end
                32'd5_000:begin
                    lckrefn_r   <= 'd1;
                end
                32'd10_000:begin
                    loop_en_r   <= loop_mod_i;
                end
//                32'd100_000:begin
//                    loop_en_r   <= 'b0;
//                end
                default:begin
                    device_en   <= device_en;
                    lckrefn_r   <= lckrefn_r;
                    loop_en_r   <= loop_en_r;
                end
            endcase
        end
    end

// ********************************************************************************** //     
//    
fifo_2711_us fifo_2711_us (
    .rst                               (!sys_rst_n                ),// input wire rst
    .wr_clk                            (fifo_us_wrclk             ),// input wire wr_clk
    .rd_clk                            (fifo_us_rdclk             ),// input wire rd_clk
    .din                               (fifo_us_data              ),// input wire [15 : 0] din
    .wr_en                             (fifo_us_wrreq             ),// input wire wr_en
    .rd_en                             (fifo_us_rdreq             ),// input wire rd_en
    .dout                              (fifo_us_q                 ),// output wire [15 : 0] dout
    .full                              (                          ),// output wire full
    .empty                             (fifo_us_empty             ),// output wire empty
    .prog_full                         (fifo_us_prog_full         ) // output wire prog_full
);

//   
blk2711_fsm  blk2711_fsm
        (
    .rx_100m                           (rx_100m                   ),
    .log_rst_n                         (sys_rst_n                 ),
             
    .rx_reset_n                        (rx_reset_n                ),
        
    .pw_rst_done                       (pw_rst_done               ),
    .send_data_num                     (send_data_num             ),
    .send_k_num                        (send_k_num                ),
    .frame_start_flag                  (frame_start_flag          ),
    .frame_header                      (frame_header              ),
    .frame_tail                        (frame_tail                ),
               
    .fifo_us_rdclk                     (fifo_us_rdclk             ),
    .fifo_us_empty                     (fifo_us_empty             ),
    .fifo_us_rdreq                     (fifo_us_rdreq             ),
    .fifo_us_q                         (fifo_us_q                 ),
        
    .fifo_ds_wrclk                     (fifo_ds_wrclk             ),
    .fifo_ds_prog_full                 (fifo_ds_prog_full         ),
    .fifo_ds_wrreq                     (fifo_ds_wrreq             ),
    .fifo_ds_rx_data                   (fifo_ds_rx_data           ),
    
   
    //------------ DATA & DATA_CTRL ------------//
    .TKMSB                             (TKMSB                     ),
    .TKLSB                             (TKLSB                     ),
    .RKMSB                             (RKMSB                     ),
    .RKLSB                             (RKLSB                     ),
        
    .TX_Data                           (TX_Data                   ),
    .RX_Data                           (RX_Data                   ) 
        );
        
//  
fifo_2711_ds fifo_2711_ds (
    .rst                               (!sys_rst_n || !rx_reset_n ),// input wire rst
    .wr_clk                            (fifo_ds_wrclk             ),// input wire wr_clk
    .rd_clk                            (fifo_ds_rdclk             ),// input wire rd_clk
    .din                               (fifo_ds_rx_data           ),// input wire [7 : 0] din
    .wr_en                             (fifo_ds_wrreq             ),// input wire wr_en
    .rd_en                             (fifo_ds_rdreq             ),// input wire rd_en
    .dout                              (fifo_ds_q                 ),// output wire [15: 0] dout
    .full                              (                          ),// output wire full
    .empty                             (fifo_ds_empty             ),// output wire empty
    .prog_full                         (fifo_ds_prog_full         ),// output wire prog_full
    .prog_empty                        (                          ) // output wire prog_empty
);
 
endmodule
