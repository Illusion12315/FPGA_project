
module cl2304_blk2711_warpper (
    input                               clk_100m                   ,
    input                               hw_rst_n                   ,
    input                               sys_rst_n                  ,
    //
    input                               rx_100m                    ,
    input                               rx_200m                    ,
    input                               rx_reset_n                 ,
    //���̵�
    output                              LED_R                      ,
    output                              LED_G                      ,
    //�Ĵ���Э�����
    input                               hf_lb_en_i                 ,
    input                               tx_send_en_i               ,
    input              [  15:0]         send_k_num                 ,//��������K����� 
    input                               data_mod_i                 ,//ģʽѡ��0Ϊԭʼģʽ��1Ϊѹ��ģʽ
    input                               loop_mod_i                 ,//�ػ�ģʽ����
    //ddr3 fifo
    input                               ddr3_ui_clk                ,
    output             [ 127:0]         rx_data                    ,
    output                              rx_valid                   ,
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
// ********************************************************************************** // 
//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
wire                                    pw_rst_done                ;
wire                   [  15:0]         send_data_num              ;

wire                                    frame_start_flag           ;

wire                                    fifo_us_wrclk              ;
wire                                    fifo_us_wrreq              ;
wire                   [  15:0]         fifo_us_data               ;
wire                                    fifo_us_prog_full          ;

wire                                    fifo_ds_rdclk              ;
wire                                    fifo_ds_rdreq              ;
wire                   [  15:0]         fifo_ds_q                  ;
wire                                    fifo_ds_empty              ;

wire                                    prog_full                  ;

wire                                    fifo_ds_rdreq_o            ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// regs
//---------------------------------------------------------------------
reg                                     tx_send_en_r1,tx_send_en_r2;
reg                    [  15:0]         send_k_num_r1,send_k_num_r2;
reg                                     data_mod_r1,data_mod_r2    ;
reg                                     loop_mod_r1,loop_mod_r2    ;
reg                                     hf_lb_en_r1,hf_lb_en_r2    ;
reg                    [  15:0]         RX_Data_r1,RX_Data_r2      ;
reg                                     RKMSB_r1,RKMSB_r2          ;
reg                                     RKLSB_r1,RKLSB_r2          ;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// async 
//---------------------------------------------------------------------
always@(posedge clk_100m)begin
    tx_send_en_r1<=tx_send_en_i;
    tx_send_en_r2<=tx_send_en_r1;
end

// always@(posedge clk_100m)begin
//     send_k_num_r1<=send_k_num;
//     send_k_num_r2<=send_k_num_r1;
// end

always@(posedge clk_100m)begin
    data_mod_r1<=data_mod_i;
    data_mod_r2<=data_mod_r1;
end

always@(posedge clk_100m)begin
    loop_mod_r1<=loop_mod_i;
    loop_mod_r2<=loop_mod_r1;
end

always@(posedge clk_100m)begin
    hf_lb_en_r1<=hf_lb_en_i;
    hf_lb_en_r2<=hf_lb_en_r1;
end
//rx_100m
always@(posedge rx_100m)begin
    RKLSB_r1<=RKLSB;
    RKLSB_r2<=RKLSB_r1;
end

always@(posedge rx_100m)begin
    RKMSB_r1<=RKMSB;
    RKMSB_r2<=RKMSB_r1;
end

always@(posedge rx_100m)begin
    RX_Data_r1<=RX_Data;
    RX_Data_r2<=RX_Data_r1;
end
//---------------------------------------------------------------------
// 2711_warpper
//---------------------------------------------------------------------
blk2711_wrapper  blk2711_wrapper_inst (
    .clk_100m                          (clk_100m                  ),
    .hw_rst_n                          (hw_rst_n                  ),
    .sys_rst_n                         (sys_rst_n                 ),

    .rx_100m                           (rx_100m                   ),
    .rx_200m                           (rx_200m                   ),
    .rx_reset_n                        (rx_reset_n                ),

    .pw_rst_done                       (pw_rst_done               ),
    .send_data_num                     (send_data_num             ),//�����������ݸ���  ������K�뽻�淢��
    .send_k_num                        (16'h4E20                  ),//��������K����� 
    .frame_start_flag                  (frame_start_flag          ),//������ʼ�������ݱ�־
    .loop_mod_i                        (loop_mod_r2               ),

    .fifo_us_wrclk                     (fifo_us_wrclk             ),//���Ͷ� дfifo�ӿ� 
    .fifo_us_wrreq                     (fifo_us_wrreq             ),
    .fifo_us_data                      (fifo_us_data              ),
    .fifo_us_prog_full                 (fifo_us_prog_full         ),

    .fifo_ds_rdclk                     (fifo_ds_rdclk             ),//���ն� ��fifo�ӿ�
    .fifo_ds_rdreq                     (fifo_ds_rdreq             ),
    .fifo_ds_q                         (fifo_ds_q                 ),
    .fifo_ds_empty                     (fifo_ds_empty             ),
    //------------ 2711 CTRL ------------//
    .LOOP_EN                           (LOOP_EN                   ),
    .ENABLE                            (ENABLE                    ),
    .LCKREFN                           (LCKREFN                   ),
    .PRBSEN                            (PRBSEN                    ),
    .TESTEN                            (TESTEN                    ),
    .PRE                               (PRE                       ),
    //------------ DATA & DATA_CTRL ------------//
    .TKMSB                             (TKMSB                     ),
    .TKLSB                             (TKLSB                     ),
    .RKMSB                             (RKMSB_r1                  ),
    .RKLSB                             (RKLSB_r1                  ),

    .TX_Data                           (TX_Data_r1                ),
    .RX_Data                           (RX_Data_r1                ) 
  );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// RX
//---------------------------------------------------------------------
rx_receive_logic  rx_receive_logic_inst (
    .sys_clk_i                         (clk_100m                  ),
    .rst_n_i                           (sys_rst_n                 ),
    .data_mod_i                        (data_mod_r2               ),

    .fifo_prog_full_ddr3_us            (prog_full                 ),
    //debug
    .TX_Data                           (TX_Data                   ),
    .RX_Data                           (RX_Data                   ),
    .fifo_us_wrreq                     (fifo_us_wrreq             ),
    .fifo_us_data                      (fifo_us_data              ),
    .fifo_us_prog_full                 (fifo_us_prog_full         ),
    .frame_start_flag                  (frame_start_flag          ),
    .LOOP_EN                           (LOOP_EN                   ),

    .LED_R                             (LED_R                     ),
    .LED_G                             (LED_G                     ),

    .fifo_ds_rdclk                     (fifo_ds_rdclk             ),
    .fifo_ds_rdreq_r                   (fifo_ds_rdreq             ),//����PCIE����
    .fifo_ds_rdreq_o                   (fifo_ds_rdreq_o           ),
    .fifo_ds_q                         (fifo_ds_q                 ),
    .fifo_ds_empty                     (fifo_ds_empty             ) 
  );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// TX
//---------------------------------------------------------------------
blk2711_tx_warpper  blk2711_tx_warpper_inst (
    .sys_clk_i                         (clk_100m                  ),
    .rst_n_i                           (sys_rst_n                 ),
    .send_data_num                     (send_data_num             ),

    .fifo_us_wrclk                     (fifo_us_wrclk             ),
    .fifo_us_wrreq                     (fifo_us_wrreq             ),
    .fifo_us_data                      (fifo_us_data              ),
    .fifo_us_prog_full                 (fifo_us_prog_full         ),

    .tx_send_en_i                      (tx_send_en_r2             ),
    .data_mod_i                        (data_mod_r2               ),

    .pw_rst_done                       (pw_rst_done               ),
    .frame_start_flag                  (frame_start_flag          ) 
  );
// ********************************************************************************** // 
//---------------------------------------------------------------------
// blk2ddr3 16ת256bit
//---------------------------------------------------------------------
wire                                    fifo_16to128_rd_en         ;
wire                                    empty                      ;
reg                    [  15:0]         data_in                    ;
reg                                     write_data_en              ;

assign fifo_16to128_rd_en = ~empty;

always@(posedge fifo_ds_rdclk or negedge sys_rst_n)begin
    if (!sys_rst_n) begin
        write_data_en<='d0;
    end
    else if (data_mod_r2) begin
        write_data_en<=fifo_ds_rdreq;
    end
    else
        write_data_en<=fifo_ds_rdreq_o;
end

always@(posedge fifo_ds_rdclk or negedge sys_rst_n)begin
    if (!sys_rst_n) begin
        data_in<='d0;
    end
    else if (!hf_lb_en_r2) begin
        data_in<=fifo_ds_q;
    end
    else
        data_in<={fifo_ds_q[7:0],fifo_ds_q[15:8]};
end

fifo_2711_16to128 fifo_2711_16to128_inst (
    .rst                               (!sys_rst_n                ),// input wire rst
    .wr_clk                            (fifo_ds_rdclk             ),// input wire wr_clk
    .wr_en                             (write_data_en             ),// input wire wr_en
    .din                               (data_in                   ),// input wire [15 : 0] din
    .full                              (                          ),// output wire full
    .prog_full                         (prog_full                 ),// output wire prog_full

    .rd_clk                            (ddr3_ui_clk               ),// input wire rd_clk
    .rd_en                             (fifo_16to128_rd_en        ),// input wire rd_en
    .dout                              (rx_data                   ),// output wire [127 : 0] dout
    .empty                             (empty                     ),// output wire empty
    .valid                             (rx_valid                  ) // output wire valid
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// debug
//---------------------------------------------------------------------
ila_rx_receive_debug ila_rx_receive_debug_inst (
    .clk                               (rx_100m                   ),// input wire clk


    .probe0                            (RKMSB_r2                  ),// input wire [0:0]  probe0  
    .probe1                            (RX_Data_r2                ),// input wire [15:0]  probe1 
    .probe2                            (RKLSB_r2                  ) // input wire [0:0]  probe2
);
endmodule