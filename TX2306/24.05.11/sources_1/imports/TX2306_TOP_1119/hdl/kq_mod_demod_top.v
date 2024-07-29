`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2023 15:34:22 
// Design Name: 
// Module Name: demod_new_top
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

module kq_mod_demod_top(
    sys_clk100m,
    sys_clk20m,
    sys_rstn,
//    clk_144m          , 
//    da_clk163m84         ,
//    da_clk_100m           ,
//    da_rst_n             ,
	
    adc_dco_a        ,
    adc_dco_b        ,
    adc_d_a          ,
    adc_d_b          ,
    adc_or_a         ,
    adc_or_b         ,

    dac_clk_a        ,
    dac_clk_b        ,
    dac_dat_i_rr        ,
    dac_dat_q_rr        ,
    dac_wrta         ,
    dac_wrtb         ,
    
    clk_to_pins_p    ,
    clk_to_pins_n    ,
    dat_out_p        ,
    dat_out_n        ,
    dat_vld_o        ,

    clk_in_p         ,
    clk_in_n         ,
    dat_in_p         ,
    dat_in_n         ,
    dat_vld_in       ,
    
  //---------------hp spi
     sclk_spi_hp,
     cs_spi_hp,
     sdo_spi_hp  ,

     BCTRL_RX_CLK,
     BCTRL_RX_DATA,
     BCTRL_RX_EN,
 
     BCTRL_TX_CLK,
     BCTRL_TX_DATA,
     BCTRL_TX_EN
);
//-----------------------------------input--------------------------------------// 
    input                               sys_clk100m                ;
    input                               sys_clk20m                 ;
    input                               sys_rstn                   ;
//input           clk_144m   ;
//input           da_clk163m84;
//input           da_clk_100m;
//input           da_rst_n;
//lvds in  for tx	-�?�lvds only bit0 is used
    input                               clk_in_p                   ;
    input                               clk_in_n                   ;
    input              [   3: 0]        dat_in_p                   ;
    input              [   3: 0]        dat_in_n                   ;
    input                               dat_vld_in                 ;
//demod in for rx
    input                               adc_dco_a                  ;
    input                               adc_dco_b                  ;
    input              [  13: 0]        adc_d_a                    ;
    input              [  13: 0]        adc_d_b                    ;
    input                               adc_or_a                   ;
    input                               adc_or_b                   ;
//----------------------------------output--------------------------------------//
//mod out  for tx
    output                              dac_clk_a                  ;
    output                              dac_clk_b                  ;
    output reg         [  11: 0]        dac_dat_i_rr               ;
    output reg         [  11: 0]        dac_dat_q_rr               ;
    output                              dac_wrta                   ;
    output                              dac_wrtb                   ;
//lvds out  for rx	-�?�lvds only bit0 is used
    output                              clk_to_pins_p              ;
    output                              clk_to_pins_n              ;
    output             [   3: 0]        dat_out_p                  ;
    output             [   3: 0]        dat_out_n                  ;
    output                              dat_vld_o                  ;

//-------hp spi
    output                              sclk_spi_hp                ;
    output                              cs_spi_hp                  ;
    output                              sdo_spi_hp                 ;
	
    input  wire                         BCTRL_RX_CLK               ;
    input  wire                         BCTRL_RX_DATA              ;
    input  wire                         BCTRL_RX_EN                ;
  
    output wire                         BCTRL_TX_CLK               ;
    output wire                         BCTRL_TX_DATA              ;
    output wire                         BCTRL_TX_EN                ;


//assign dac_clk_a = 1'b0;
//assign dac_clk_b = 1'b1;
//assign dac_dat_i = 12'b0;
//assign dac_dat_q = 12'b0;
//assign dac_wrta = 1'b0;
//assign dac_wrta = 1'b0;



//assign dat_vld_o = 1'b0;


//---------------ADDA_CLK
    wire                                clk81m92                   ;
    wire                                clk163m84                  ;
    wire                                hp_clk                     ;
    wire                                rst_n                      ;
    wire                                vio_rstn                   ;

    wire                                clk100m                    ;
    wire                                adc_clk_b                  ;
    wire                                clk200m                    ;
    wire                                rstn                       ;

//------AD 
    wire               [  13: 0]        ad_data_i                  ;
    wire               [  13: 0]        ad_data_q                  ;
    wire                                ad_data_valid              ;

    wire                                da_vld_o                   ;//163.84M时钟域数\E6\8D?有�???
    wire               [  15: 0]        dai_o                      ;//163.84M时钟域实\EF\BF????
    wire               [  15: 0]        daq_o                      ;//163.84M时钟域虚\EF\BF????

//------------sxandxx
    wire               [   7: 0]        rx_rate_in                 ;//���з������ʲ���
    wire               [   7: 0]        rx_mod_in                  ;//���е��Ʒ�ʽ����
    wire               [   7: 0]        rx_encode_in               ;//���б��뷽ʽ����
    wire               [   7: 0]        rx_spread_in               ;//������Ƶ���Ӳ���
    wire                                ber_rst_in                 ;//��������ͳ�Ƹ�λ�źţ�����Ч

    wire               [  47: 0]        num_biterr_out             ;//���д���bit��
    wire               [  47: 0]        num_bitall_out             ;//�����ܵ�bit��
    wire               [  31: 0]        rx_freq_in                 ;//����Ƶ��ֵ
    wire                                rx_freq_en_in              ;//����Ƶ��ֵʹ�ܣ�����ʱ��\EF\BF???20ns
    wire               [  31: 0]        tx_freq_in                 ;//����Ƶ��ֵ
    wire                                tx_freq_en_in              ;//����Ƶ��ֵʹ�ܣ�����ʱ��\EF\BF???20ns

//-----------------------------
    wire               [   7: 0]        tx_mode_in                 ;//����ģʽ
    wire               [   7: 0]        tx_rate_in                 ;//�������ʲ���
    wire               [   7: 0]        tx_mod_in                  ;//���е��Ʒ�ʽ����
    wire               [   7: 0]        tx_encode_in               ;//���б��뷽ʽ����
    wire               [   7: 0]        tx_div_in                  ;//���зּ�����
    wire               [  27: 0]        address_data_in            ;//վ��ַ
    reg                [   7: 0]        tx_data1_in                ;//���п�������
    reg                                 tx_data1_valid_in          ;//���п�������ʹ��
    reg                [   7: 0]        tx_data2_in                ;//����ҵ������
    reg                                 tx_data2_valid_in          ;//����ҵ������ʹ��

    wire               [   7: 0]        tx_data1                   ;
    wire                                tx_data1_valid             ;
    wire               [   7: 0]        tx_data2                   ;
    wire                                tx_data2_valid             ;



    wire               [  15: 0]        dac_data_i_out             ;//DAC�����I·����
    wire               [  15: 0]        dac_data_q_out             ;//DAC�����Q·����
    wire                                dac_valid_out              ;//DAC�������ʹ�\EF\BF???
    wire               [  15: 0]        tx_data1_length_out        ;//�������ݳ��ȣ���λ�ֽ�
    wire                                tx_data1_ask_out           ;
    wire               [  15: 0]        tx_data2_length_out        ;//�������ݳ��ȣ���λ�ֽ�
    wire                                tx_data2_ask_out           ;
    wire                                o_ldpc_vld_r               ;
    wire               [   7: 0]        o_ldpc_da_r                ;
    wire               [   7: 0]        o_ldpc_cnt                 ;
    wire               [   7: 0]        o_slottimesw_cnt           ;

//-------------------------------MSPI_data
    //user interface
    wire               [  31: 0]        down_freq                  ;
    wire               [  31: 0]        up_freq                    ;
    wire               [  31: 0]        up_step_freq               ;
    wire               [  31: 0]        down_step_freq             ;
    wire               [  31: 0]        kq_demodule_sig            ;
    wire               [  31: 0]        kq_module_sig              ;
    wire               [  31: 0]        demod_bias_init_value      ;
    wire               [  31: 0]        mod_bias_init_value        ;
    wire               [  46: 0]        init_tod_in                ;
    wire               [  31: 0]        satel_ground_delay         ;
    wire               [  27: 0]        address_data               ;
    wire               [  31: 0]        ls_sync_shixi0             ;
    wire               [  31: 0]        ls_sync_shixi1             ;
    wire               [  31: 0]        ls_sync_shixi2             ;
    wire               [  31: 0]        ls_sync_shixi3             ;
    wire               [  31: 0]        ls_sync_shixi4             ;
    wire               [  31: 0]        ls_sync_shixi5             ;
    wire               [  31: 0]        ls_sync_shixi6             ;
    wire               [  31: 0]        ls_sync_shixi7             ;
    wire               [  31: 0]        ls_sync_shixi8             ;
    wire               [  31: 0]        ls_sync_shixi9             ;
    wire               [  31: 0]        ls_sync_shixi10            ;
    wire               [  31: 0]        ls_sync_shixi11            ;
    wire               [  31: 0]        ls_sync_shixi12            ;
    wire               [  31: 0]        ls_sync_shixi13            ;
    wire               [  31: 0]        ls_sync_shixi14            ;
    wire               [  31: 0]        ls_sync_shixi15            ;
    wire               [  31: 0]        ls_yw_shixi0               ;
    wire               [  31: 0]        ls_yw_shixi1               ;
    wire               [  31: 0]        ls_yw_shixi2               ;
    wire               [  31: 0]        ls_yw_shixi3               ;
    wire               [  31: 0]        ls_yw_shixi4               ;
    wire               [  31: 0]        ls_yw_shixi5               ;
    wire               [  31: 0]        ls_yw_shixi6               ;
    wire               [  31: 0]        ls_yw_shixi7               ;
    wire               [  31: 0]        ls_ctr_shixi0              ;
    wire               [  31: 0]        ls_ctr_shixi1              ;
    wire               [  31: 0]        ls_ctr_shixi2              ;
    wire               [  31: 0]        ls_ctr_shixi3              ;
    wire               [  31: 0]        ls_ctr_shixi4              ;
    wire               [  31: 0]        ls_ctr_shixi5              ;
    wire               [  31: 0]        ls_ctr_shixi6              ;
    wire               [  31: 0]        ls_ctr_shixi7              ;
    wire               [  31: 0]        ms_sync_shixi              ;
    wire               [  31: 0]        ms_gdctr_shixi             ;
    wire               [  31: 0]        ms_ctroryw_shixi           ;
    wire               [  31: 0]        soft_rstn                  ;
    wire               [  31: 0]        kd_module_reg              ;
    wire               [  31: 0]        kd_satel_ground_delay_reg  ;
    wire               [  31: 0]        kd_coar_sync_reg           ;
    wire               [  31: 0]        kd_fine_sync_reg           ;

    wire               [  47: 0]        us_data_cache_cnt          ;
    wire               [  31: 0]        GD_ctrl_cnt                ;
    wire               [  31: 0]        ctrl_sdl_cnt               ;
    wire               [  31: 0]        yw_sdl_cnt                 ;
    wire               [  31: 0]        DL_cnt                     ;

//reg                                     vio_rstn_r,vio_rstn_rr     ;
    reg                                 rst_n_r,rst_n_rr           ;
    wire                                sx_rstn                    ;

//vio ctrl
    wire               [  13: 0]        sub_value                  ;

    reg                [   7: 0]        up_gear                    ;
    wire               [   7: 0]        up_gear7045                ;
//wire                   [   7:0]         vio_down_gear              ;
//wire                   [   7:0]         vio_up_gear                ;

//wire                                    vio_ber_rst_in             ;
//wire                   [  27:0]         vio_address_data_in        ;//վ��ַ
//wire                   [   7:0]         vio_tx_data1_in            ;//���п�������
//wire                                    vio_tx_data1_valid_in      ;//���п�������ʹ��
//wire                   [   7:0]         vio_tx_data2_in            ;//����ҵ������
//wire                                    vio_tx_data2_valid_in      ;//����ҵ������ʹ��
//wire                                    vio_tx_data_select         ;

    wire                                vio_clk                    ;
    wire                                vio_wrta                   ;
    wire                                vio_data                   ;


//------------------M_SPI_Param
//wire        [   7: 0]        o_soft_rst_n               ;// 0x00   
//wire        [   7: 0]        o_FixedFre_or_FreHop_mod   ;// 0x10   
//wire        [  63: 0]        o_rx_freq                  ;// 0x11   
//wire        [  31: 0]        o_down_step_freq           ;// 0x12   
//wire        [  47: 0]        o_init_tod_in              ;// 0x13   
//wire        [  47: 0]        o_us_ds_para               ;// 0x14   
//wire        [ 255: 0]        o_ds_timeslot              ;// 0x15      
    wire               [   7: 0]        config_data                ;// 0x16 下行解帧范式配置
    wire                                config_vld                 ;
//wire        [   7: 0]        o_statistical_info_rst     ;// 0x18   
//wire        [  31: 0]        o_trans_latency_compens    ;// 0x05   
//wire        [  31: 0]        o_us_ms_addr_crc           ;// 0x06   
//wire        [  31: 0]        o_us_fre_offset_compens    ;// 0x07   
//wire        [ 135: 0]        o_us_sync_en               ;// 0x08   
//wire        [  23: 0]        o_us_send_choose           ;// 0x09   
//wire        [ 135: 0]        o_ls_carrier_cfg           ;// 0x0B   
//wire        [ 175: 0]        o_ms_timeslot              ;// 0x0C   
//wire        [ 103: 0]        o_ds_sync_data             ;// 0x20   
//wire        [  39: 0]        o_ms_ls_status             ;// 0x21   
//wire        [ 351: 0]        o_ds_statistics            ;// 0x22   
//wire        [ 415: 0]        o_us_statistics            ;// 0x23   
//wire        [  31: 0]        o_software_info            ;// 0x30   

    wire               [   7: 0]        w_MC_GlobalRst             ;// 0x00
    wire               [   7: 0]        w_MC_HopMode               ;// 0x10
    wire               [  63: 0]        w_MC_FreqBase              ;// 0x11
    wire               [  31: 0]        w_MC_DL_FreqOffset         ;// 0x12
    wire               [  47: 0]        w_MC_TOD_Initial           ;// 0x13
    wire               [  47: 0]        w_MC_FH_Param              ;// 0x14
    wire               [ 255: 0]        w_MC_GearEverySlot         ;// 0x15
    wire               [   7: 0]        w_MC_StatCLR               ;// 0x18
    wire               [  31: 0]        w_MC_SE_unidt              ;// 0x05
    wire               [  31: 0]        w_MC_UL_Address            ;// 0x06
    wire               [  31: 0]        w_MC_UL_FreqOffset         ;// 0x07
    wire               [ 135: 0]        w_MC_UL_Sync_Slot          ;// 0x08
    wire               [  23: 0]        w_MC_UL_TxDataSet          ;// 0x09
    wire               [ 135: 0]        w_MC_UL_LDR_CarrierSet     ;// 0x0B
    wire               [ 175: 0]        w_MC_UL_MDR_SlotSet        ;// 0x0C
    wire                                w_MC_UL_MDR_GDCtrlSlot     ;
    wire               [ 103: 0]        w_MC_DL_SyncInfo           ;// 0x20
    wire               [  39: 0]        w_MC_DL_StateInfo          ;// 0x21
    wire               [ 255: 0]        w_MC_DL_Statistics         ;// 0x22
    wire               [ 127: 0]        w_MC_UL_Statistics         ;// 0x23
    wire               [   3: 0]        w_MC_Version               ;// 0x30
//--------------------moulde-1------------------------
//-------------------------Signal Clock and Vio--begin
CoRefClk CoRefClk_inst(
//----debug--signal

//    .vio_up_gear                       (vio_up_gear               ),
//    .vio_down_gear                     (vio_down_gear             ),
////.vio_ber_rst_in                                             (vio_ber_rst_in  ),
//    .vio_address_data_in               (vio_address_data_in       ),//վ��ַ
//    .vio_tx_data1_in                   (vio_tx_data1_in           ),//���п�������
//    .vio_tx_data1_valid_in             (vio_tx_data1_valid_in     ),//���п�������ʹ��
//    .vio_tx_data2_in                   (vio_tx_data2_in           ),//����ҵ������
//    .vio_tx_data2_valid_in             (vio_tx_data2_valid_in     ),//����ҵ������ʹ��
//    .vio_tx_data_select                (vio_tx_data_select        ),

//.vio_clk                                                    (vio_clk ),  
//.vio_wrta                                                   (vio_wrta),
//.vio_data                                                   (vio_data),


    .adc_dco_a                          (adc_dco_a                 ),
    .adc_dco_b                          (adc_dco_b                 ),
   
    .adc_clk100m                        (clk100m                   ),
    .adc_clk_b                          (adc_clk_b                 ),
    .clk200m                            (clk200m                   ),
   
    .ad_clk81m92                        (clk81m92                  ),
    .ad_clk163m84                       (clk163m84                 ),
    .hp_clk                             (hp_clk                    ),
    .ad_rst_n                           (rst_n                     ),
//    .vio_rstn                          (vio_rstn                  ),
    .rstn                               (rstn                      ) 
   
   //--------Paramter Ctrl
//   .sub_value                   (sub_value)

    );
    
//-------------------------Signal Clock and Vio--end

//----------------------------moulde-2--------------
//----------------------------AD_signal---------begin


AD_RX AD_RX_inst(
    //demod in for rx

//    .sub_value          (sub_value),
    .sub_value                          (14'd8192                  ),
    
    .adc_d_a                            (adc_d_a                   ),
    .adc_d_b                            (adc_d_b                   ),
    .adc_or_a                           (adc_or_a                  ),
    .adc_or_b                           (adc_or_b                  ),
    
    .adc_clk100m                        (clk100m                   ),
    .adc_clk_b                          (adc_clk_b                 ),
    .ad_clk163m84                       (clk163m84                 ),
    .ad_clk81m92                        (clk81m92                  ),
    .ad_rst_n                           (rst_n                     ),
    
    .ad_data_i                          (ad_data_i                 ),
    .ad_data_q                          (ad_data_q                 ),
    .ad_data_valid                      (ad_data_valid             ) 
    );
    
//----------------------------AD_signal---------end 
 
    wire                                vio_dlyI1Q0_sel            ;
    wire               [   1: 0]        vio_ad100mdlynum           ;
    reg                [  13: 0]        ad_data_i_d0='d0           ;
    reg                [  13: 0]        ad_data_i_d1='d0           ;
    reg                [  13: 0]        ad_data_i_d2='d0           ;
    reg                [  13: 0]        ad_data_q_d0='d0           ;
    reg                [  13: 0]        ad_data_q_d1='d0           ;
    reg                [  13: 0]        ad_data_q_d2='d0           ;

    reg                [  13: 0]        ad_data_i_dly='d0          ;
    reg                [  13: 0]        ad_data_q_dly='d0          ;
always @(posedge clk100m)begin
    ad_data_i_d0 <= ad_data_i;
    ad_data_i_d1 <= ad_data_i_d0;
    ad_data_i_d2 <= ad_data_i_d1;
    ad_data_q_d0 <= ad_data_q;
    ad_data_q_d1 <= ad_data_q_d0;
    ad_data_q_d2 <= ad_data_q_d1;
end

always @(posedge clk100m)begin
    if(vio_dlyI1Q0_sel==1'b1)
        begin
            case(vio_ad100mdlynum)
                'd0:ad_data_i_dly <= ad_data_i_d0;
                'd1:ad_data_i_dly <= ad_data_i_d1;
                'd2:ad_data_i_dly <= ad_data_i_d2;
                default:ad_data_i_dly <= ad_data_i_d0;
            endcase
            ad_data_q_dly <= ad_data_q_d0;
        end
    else
        begin
            case(vio_ad100mdlynum)
                'd0:ad_data_q_dly <= ad_data_q_d0;
                'd1:ad_data_q_dly <= ad_data_q_d1;
                'd2:ad_data_q_dly <= ad_data_q_d2;
                default:ad_data_q_dly <= ad_data_q_d0;
            endcase
            ad_data_i_dly <= ad_data_i_d0;
        end
end

 
 //---------------------------moulde-3-------------
 //----------------AD_100Msps_to_163.81MHsps--begin
upsample100to163p84 upsample100to163p84_inst(
    .i_clk100                           (clk100m                   ),//100M时钟
//    .i_clk200                   (clk200m) ,//200M时钟
    .i_clk163                           (clk163m84                 ),//163.84M时钟
    .i_rst_n                            (rst_n_rr                  ),
    
//    .i_din_valid                (ad_data_valid),//100M时钟域数\E6\8D?有�???
//    .i_din_data_i               (ad_data_i),//100M时钟域实\EF\BF????     
//    .i_din_data_q               (ad_data_q),//100M时钟域虚\EF\BF????    

    .i_din_valid                        (ad_data_valid             ),//100M时钟域数\E6\8D?有�???
    .i_din_data_i                       (ad_data_i_dly             ),//100M时钟域实\EF\BF????     
    .i_din_data_q                       (ad_data_q_dly             ),//100M时钟域虚\EF\BF????   
    
    .da_vld_o                           (da_vld_o                  ),//163.84M时钟域数\E6\8D?有�???
    .dai_o                              (dai_o                     ),//163.84M时钟域实\EF\BF????
    .daq_o                              (daq_o                     ) //163.84M时钟域虚\EF\BF????
);
 
vio_ad100mdly vio_ad100mdly_u (
    .clk                                (clk100m                   ),// input wire clk
    .probe_out0                         (vio_dlyI1Q0_sel           ),// output wire [0 : 0] probe_out0
    .probe_out1                         (vio_ad100mdlynum          ) // output wire [1 : 0] probe_out1
);
 //----------------AD_100Msps_to_163.81MHsps--end
 

 
//---------------------------moulde-4-------------------------

//--------------------------sxandxx module---------------begin

always @(posedge clk163m84)begin
    rst_n_r  <= rst_n;
    rst_n_rr <= rst_n_r;
end

always @(posedge clk163m84 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        tx_data1_in         <= 8'd0;
        tx_data2_in         <= 8'd0;
        tx_data1_valid_in   <= 1'b0;
        tx_data2_valid_in   <= 1'b0;
        up_gear             <= 8'd0;
    end
    else begin
        tx_data1_in         <= tx_data1;
        tx_data2_in         <= tx_data2;
        tx_data1_valid_in   <= tx_data1_valid;
        tx_data2_valid_in   <= tx_data2_valid;
        up_gear             <= up_gear7045;
    end
end

    assign                              sx_rstn                   = rst_n_rr;

                  //spf
    wire                                uplink_40ms                ;
    wire                                sync_lock2                 ;
    wire                                w_DecScr_valid             ;
    wire               [   7: 0]        w_DecScr_data              ;
                
    wire                                w_ldpc_vld_r               ;
    wire               [   7: 0]        w_ldpc_da_r                ;
    wire               [   7: 0]        w_ldpc_cnt                 ;
    wire               [   7: 0]        w_slottimesw_cnt           ;
    wire               [   7: 0]        w_DL_GearEverySlot         ;

vio_StateOB u_vio_StateOB (
    .clk                                (clk163m84                 ),// input wire clk
    .probe_in0                          (sync_lock2                ),// input wire [0 : 0] probe_in0
    .probe_in1                          (up_gear                   ) // input wire [7 : 0] probe_in1
);
sxandxx sxandxx_inst(
    .sys_clk                            (clk163m84                 ),//

    .I_ADC_DATA_I                       (dai_o                     ),//
    .I_ADC_DATA_Q                       (daq_o                     ),//
    .adc_valid_in                       (da_vld_o                  ),//

    .i_UL_Gear                          (up_gear                   ),
    .tx_data1_in                        (tx_data1_in               ),//
    .tx_data1_valid_in                  (tx_data1_valid_in         ),//
    .tx_data2_in                        (tx_data2_in               ),//
    .tx_data2_valid_in                  (tx_data2_valid_in         ),//

    .rx_freq_in                         (rx_freq_in                ),//
    .rx_freq_en_in                      (rx_freq_en_in             ),//
    .tx_freq_in                         (tx_freq_in                ),//
    .tx_freq_en_in                      (tx_freq_en_in             ),//

    .o_DAC_DATA_I                       (dac_data_i_out            ),//
    .o_DAC_DATA_Q                       (dac_data_q_out            ),//

    .tx_data1_length_out                (tx_data1_length_out       ),//
    .tx_data1_ask_out                   (tx_data1_ask_out          ),//
    .tx_data2_length_out                (tx_data2_length_out       ),//
    .tx_data2_ask_out                   (tx_data2_ask_out          ),//

    .o_UL_Flag40ms                      (uplink_40ms               ),
    .sync_lock2                         (sync_lock2                ),//

    .o_DecScr_valid                     (w_DecScr_valid            ),//
    .o_DecScr_data                      (w_DecScr_data             ),//

    .o_ldpc_vld_r                       (w_ldpc_vld_r              ),//
    .o_ldpc_da_r                        (w_ldpc_da_r               ),//
    .o_ldpc_cnt                         (w_ldpc_cnt                ),//
    .o_slottimesw_cnt                   (w_slottimesw_cnt          ),//
    .o_DL_GearEverySlot                 (w_DL_GearEverySlot        ),
//---------------------控制接口-------------------------------//
    .i_MC_GlobalRst                     (w_MC_GlobalRst            ),//0x00 690T全局复位 1-690T复位 0-690T解复位
    .i_MC_HopMode                       (w_MC_HopMode              ),//0x10 定频、跳频模式选择 1-定频，0-跳频
    .i_MC_FreqBase                      (w_MC_FreqBase             ),//0x11 跳频基准频点
    .i_MC_DL_FreqOffset                 (w_MC_DL_FreqOffset        ),//0x12 下行频偏补偿值
    .i_MC_TOD_Initial                   (w_MC_TOD_Initial          ),//0x13 初始TOD值
    .i_MC_FH_Param                      (w_MC_FH_Param             ),//0x14 上下行跳频参数配置
    .i_MC_GearEverySlot                 (w_MC_GearEverySlot        ),//0x15 下行时隙档位配置
    .i_MC_StatCLR                       (w_MC_StatCLR              ),//0x18 统计信息清零
    
    .i_MC_SE_unidt                      (w_MC_SE_unidt             ),//0x05 星地传输延迟补偿值
    .i_MC_UL_Address                    (w_MC_UL_Address           ),//0x06 上行同步站地址和CRC
    .i_MC_UL_FreqOffset                 (w_MC_UL_FreqOffset        ),//0x07 上行频偏补偿值
    .i_MC_UL_Sync_Slot                  (w_MC_UL_Sync_Slot         ),//0x08 上行同步信道使能
    .i_MC_UL_TxDataSet                  (w_MC_UL_TxDataSet         ),//0x09 上行发送数据选择
    .i_MC_UL_LDR_CarrierSet             (w_MC_UL_LDR_CarrierSet    ),//0x0B 上行低速载波配置
    .i_MC_UL_MDR_SlotSet                (w_MC_UL_MDR_SlotSet       ),//0x0C 上行中速时隙配置
    .i_MC_UL_MDR_GDCtrlSlot             (w_MC_UL_MDR_GDCtrlSlot    ),
    
    .o_MC_DL_SyncInfo                   (w_MC_DL_SyncInfo          ),//0x20 同步信道下行同步数据
    .o_MC_DL_StateInfo                  (w_MC_DL_StateInfo         ),//0x21 中速/低速状态信息
    .o_MC_DL_Statistics                 (w_MC_DL_Statistics        ),//0x22 下行统计信息
    .o_MC_UL_Statistics                 (w_MC_UL_Statistics        ),//0x23 上行统计信息
    .o_MC_Version                       (w_MC_Version              ) //0x30 软件版本信息
    //==============================================================//    
);
     
    wire               [  11: 0]        dac_dat_i,dac_dat_q        ;
    reg                [  11: 0]        dac_dat_i_r,dac_dat_q_r    ;
    
//    assign dac_clk_a = vio_clk? !clk163m84 : clk163m84;
//    assign dac_clk_b = vio_clk? !clk163m84 : clk163m84;

//    assign dac_wrta  = vio_wrta? !clk163m84 : clk163m84;
//    assign dac_wrtb  = vio_wrta? !clk163m84 : clk163m84;

//    assign dac_dat_i = vio_data? {!dac_data_i_out[15],dac_data_i_out[14:4] }: dac_data_i_out[15:4];
//    assign dac_dat_q = vio_data? {!dac_data_q_out[15],dac_data_q_out[14:4] } : dac_data_q_out[15:4];
    
    assign                              dac_clk_a                 = 1'b0 ? !clk163m84 : clk163m84;
    assign                              dac_clk_b                 = 1'b0 ? !clk163m84 : clk163m84;

    assign                              dac_wrta                  = 1'b1 ? !clk163m84 : clk163m84;
    assign                              dac_wrtb                  = 1'b1 ? !clk163m84 : clk163m84;

    assign                              dac_dat_i                 = 1'b1 ? {!dac_data_i_out[15],dac_data_i_out[14:4] }: dac_data_i_out[15:4];
    assign                              dac_dat_q                 = 1'b1 ? {!dac_data_q_out[15],dac_data_q_out[14:4] } : dac_data_q_out[15:4];
    
    
always @(posedge clk163m84)begin
    dac_dat_i_r <= dac_dat_i;
    dac_dat_i_rr <= dac_dat_i_r;
end
always @(posedge clk163m84)begin
    dac_dat_q_r <= dac_dat_q;
    dac_dat_q_rr <= dac_dat_q_r;
end
     
 //--------------------------sxandxx module---------------end 
 
  //---------------------------moulde-5-------------
 //-------------------the up and down channel contrl------begin
 
    reg                                 uplink_freq_vld_r,uplink_freq_vld_rr,uplink_freq_vld_rrr  ;
    reg                                 downlink_freq_vld_r,downlink_freq_vld_rr,downlink_freq_vld_rrr  ;
    reg                [  31: 0]        uplink_freq_r,uplink_freq_rr  ;
    reg                [  31: 0]        downlink_freq_r,downlink_freq_rr  ;
 
    wire                                pose_uplink_flag           ;
    wire                                pose_downlink_flag         ;

//------------------
    wire               [  31: 0]        vio_up_freq                ;
    wire               [  31: 0]        vio_down_freq              ;
    wire                                vio_up_freq_en             ;
    wire                                vio_down_freq_en           ;
    wire                                vio_up_switch              ;
    wire                                vio_down_switch            ;

vio_freq u_vio_freq_inst (
    .clk                                (clk163m84                 ),// input wire clk
    .probe_out0                         (vio_up_switch             ),// output wire [0 : 0] probe_out0
    .probe_out1                         (vio_down_switch           ),// output wire [0 : 0] probe_out1
    .probe_out2                         (vio_up_freq_en            ),// output wire [0 : 0] probe_out2
    .probe_out3                         (vio_down_freq_en          ),// output wire [0 : 0] probe_out3
    .probe_out4                         (vio_up_freq               ),// output wire [31 : 0] probe_out4
    .probe_out5                         (vio_down_freq             ) // output wire [31 : 0] probe_out5
);

 always @(posedge clk163m84 or negedge rst_n_rr)begin
    if(rst_n_rr==1'b0)begin
        uplink_freq_vld_r   <=  1'b0;
        uplink_freq_vld_rr  <=  1'b0;
        uplink_freq_vld_rrr <=  1'b0;
    end
    else if(vio_up_switch==1'b1)begin
        uplink_freq_vld_r   <=  vio_up_freq_en;
        uplink_freq_vld_rr  <=  uplink_freq_vld_r;
        uplink_freq_vld_rrr <=  uplink_freq_vld_rr;
    end
    else begin
        uplink_freq_vld_r   <=  tx_freq_en_in;
        uplink_freq_vld_rr  <=  uplink_freq_vld_r;
        uplink_freq_vld_rrr <=  uplink_freq_vld_rr;
    end
 end
 
 always @(posedge clk163m84 or negedge rst_n_rr)begin
    if(rst_n_rr ==1'b0)begin
        uplink_freq_r <=  32'd0;
        uplink_freq_rr <= 32'd0;
    end
    else if(vio_up_switch==1'b1)begin
        uplink_freq_r <=  vio_up_freq;
        uplink_freq_rr <= uplink_freq_r;
    end
    else begin
        uplink_freq_r <=  tx_freq_in;
        uplink_freq_rr <= uplink_freq_r;
    end
 end
 
 always @(posedge clk163m84 or negedge rst_n_rr)begin
    if(rst_n_rr ==1'b0)begin
        downlink_freq_vld_r   <=  1'b0;
        downlink_freq_vld_rr  <=  1'b0;
        downlink_freq_vld_rrr <=  1'b0;
    end
    else if(vio_down_switch==1'b1)begin
        downlink_freq_vld_r   <=  vio_down_freq_en;
        downlink_freq_vld_rr  <=  downlink_freq_vld_r;
        downlink_freq_vld_rrr <=  downlink_freq_vld_rr;
    end
    else begin
        downlink_freq_vld_r   <=  rx_freq_en_in;
        downlink_freq_vld_rr  <=  downlink_freq_vld_r;
        downlink_freq_vld_rrr <=  downlink_freq_vld_rr;
    end
 end
 
  always @(posedge clk163m84 or negedge rst_n_rr)begin
    if(rst_n_rr==1'b0)begin
         downlink_freq_r <=  32'd0;
         downlink_freq_rr <= 32'd0;
    end
    else if(vio_down_switch==1'b1)begin
        downlink_freq_r <=  vio_down_freq;
        downlink_freq_rr <= downlink_freq_r;
    end
    else begin
        downlink_freq_r <=  rx_freq_in;
        downlink_freq_rr <= downlink_freq_r;
    end
 end
 
 
    assign                              pose_uplink_flag          = !uplink_freq_vld_rrr && uplink_freq_vld_rr;
    assign                              pose_downlink_flag        = !downlink_freq_vld_rrr && downlink_freq_vld_rr;
 
    reg                [  31: 0]        tx_freq_in_reg             ;
    wire                                uplink_vld_pos             ;
    assign                              uplink_vld_pos            = tx_freq_en_in && ~uplink_freq_vld_r;
always @(posedge clk163m84 or negedge rst_n_rr) begin
    if(rst_n_rr==1'b0) begin
        tx_freq_in_reg <= 'b0;
    end
    else if(uplink_vld_pos) begin
        tx_freq_in_reg <= tx_freq_in;
    end
end
 ila_sxandxx ila_sxandxx_inst (
    .clk                                (clk163m84                 ),// input wire clk
    .probe0                             (dai_o                     ),// input wire [15:0]  probe0  
    .probe1                             (dac_data_i_out            ),// input wire [15:0]  probe1 
    .probe2                             (tx_freq_in                ),// input wire [31:0]  probe3 
    .probe3                             (tx_freq_en_in             ),// input wire [0:0]  probe4 
    .probe4                             (rx_freq_in                ),// input wire [31:0]  probe5
    .probe5                             (rx_freq_en_in             ) // input wire [0:0]  probe6  
);

kq_hp_module kq_hp_module_inst(
    .clk163m84                          (clk163m84                 ),
    .hp_clk                             (hp_clk                    ),
    
    .rst_n                              (rst_n_rr                  ),
	
    .uplink_freq                        (uplink_freq_rr            ),
    .uplink_freq_vld                    (pose_uplink_flag          ),
    .downlink_freq                      (downlink_freq_rr          ),
    .downlink_freq_vld                  (pose_downlink_flag        ),

    .sclk_spi_hp                        (sclk_spi_hp               ),
    .cs_spi_hp                          (cs_spi_hp                 ),
    .sdo_spi_hp                         (sdo_spi_hp                ) 
    );
 
 //-------------------the up and down channel contrl------end 
 //---------------------------moulde-6-------------------------
    wire               [  15: 0]        frame_len                  ;
    wire                                fd_in                      ;
    wire                                vld_in                     ;
    wire                                eof_in                     ;
    wire               [   7: 0]        dat_in                     ;
    wire               [  31: 0]        rt_rev_cnt                 ;
    wire               [  31: 0]        fl_send_cnt                ;
    wire               [  31: 0]        cnt_sdl_output             ;



    reg                [  31: 0]        ctrl_timeslot              ;
    reg                [  31: 0]        busi_timeslot              ;
    reg                [  31: 0]        circuit_timeslot           ;

//    reg                                 lvds_rst_n_100m_r1         ;
//    reg                                 lvds_rst_n_100m_r2         ;
//    reg                                 lvds_rst_n_100m_r3         ;
//always@(posedge sys_clk100m or negedge lvds_rst_n)begin
//    if(!lvds_rst_n)begin
//        lvds_rst_n_100m_r1 <= 'd0;
//        lvds_rst_n_100m_r2 <= 'd0;
//        lvds_rst_n_100m_r3 <= 'd0;
//    end
//    else begin
//        lvds_rst_n_100m_r1 <= lvds_rst_n;
//        lvds_rst_n_100m_r2 <= lvds_rst_n_100m_r1;
//        lvds_rst_n_100m_r3 <= lvds_rst_n_100m_r2;
//    end
//end 
    wire                                lvds_rst_n                 ;
vio_rstn vio_lvds_top_rstn_inst(
    .clk                                (clk163m84                 ),

    .probe_out0                         (lvds_rst_n                ) 
);
    reg         r_LVDS_rst = 'b1 ;
    wire[1:0]   w_LVDS_reset_src ;
    wire[1:0]   w_LVDS_reset_dest;
assign w_LVDS_reset_src  = {r_LVDS_rst,lvds_rst_n};
always @(posedge clk163m84) begin
    r_LVDS_rst <= w_MC_GlobalRst[0];
end
xpm_cdc_array_single #(
   .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
   .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .SRC_INPUT_REG(1),  // DECIMAL; 0=do not register input, 1=register input
   .WIDTH(2)           // DECIMAL; range: 1-1024
)
lvds_rst_cdc_inst (
   .dest_out(w_LVDS_reset_dest), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                        // output is registered.

   .dest_clk(sys_clk100m), // 1-bit input: Clock signal for the destination clock domain.
   .src_clk(clk163m84),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
   .src_in(w_LVDS_reset_src)      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                        // domain. It is assumed that each bit of the array is unrelated to the others. This
                        // is reflected in the constraints applied to this macro. To transfer a binary value
                        // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.

);

 lvds_top lvds_top_inst(
    .clk_100m                           (sys_clk100m               ),
    .clk163m84                          (clk163m84                 ),
    .rst_n_163m84                       (lvds_rst_n&&(!w_MC_GlobalRst[0]) ),//rst_n_rr && 
    .rst_n_100m                         (w_LVDS_reset_dest[0] && !w_LVDS_reset_dest[1]),//sys_rstn && 
   
    // LVD
    .dat_in_p                           (dat_in_p                  ),
    .dat_in_n                           (dat_in_n                  ),
    .clk_in_p                           (clk_in_p                  ),
    .clk_in_n                           (clk_in_n                  ),
    .dat_vld_in                         (dat_vld_in                ),
   
    .dat_out_p                          (dat_out_p                 ),
    .dat_out_n                          (dat_out_n                 ),
    .clk_to_pins_p                      (clk_to_pins_p             ),
    .clk_to_pins_n                      (clk_to_pins_n             ),
    .dat_vld_o                          (dat_vld_o                 ),
    //from690to7045
//    .down_gear                         (vio_down_gear             ),
    .i_DL_GearEverySlot                 (w_DL_GearEverySlot        ),
    .i_DecScr_valid                     (w_DecScr_valid            ),
    .i_DecScr_data                      (w_DecScr_data             ),
    .i_ldpc_cnt                         (w_ldpc_cnt                ),
    .i_slottimesw_cnt                   (w_slottimesw_cnt          ),
    .uplink_40ms                        (uplink_40ms               ),
//    .frame_len               (16'd0), //16bit
//    .fd_in                   (1'b0),//1bit
//    .vld_in                  (1'b0),//1bit
//    .eof_in                  (1'b0),//1bit
//    .dat_in                  (8'd0),//8bit
    //from7045to690
//    .dout_start                (dout_start),
//    //output                     fl_vld                  ,
//    .s2p_dout                  (s2p_dout),
    //cnt
    .rt_rev_cnt                         (rt_rev_cnt                ),
    .fl_send_cnt                        (fl_send_cnt               ),
    .cnt_sdl_output                     (cnt_sdl_output            ),

    .us_data_cache_cnt                  (us_data_cache_cnt         ),

    .i_MC_StatCLR                       (w_MC_StatCLR              ),
    .GD_ctrl_cnt                        (GD_ctrl_cnt               ),
    .ctrl_sdl_cnt                       (ctrl_sdl_cnt              ),
    .yw_sdl_cnt                         (yw_sdl_cnt                ),
    .DL_cnt                             (DL_cnt                    ),

    .config_vld                         (config_vld                ),
    .config_data                        (config_data               ),

    .ctrl_timeslot_i                    (ctrl_timeslot             ),
    .busi_timeslot_i                    (busi_timeslot             ),
    .circuit_timeslot_i                 (circuit_timeslot          ),
    
        //----------------phy data
    .tx_data1_length_out                (tx_data1_length_out       ),
    .tx_data1_ask_out                   (tx_data1_ask_out          ),
    .tx_data2_length_out                (tx_data2_length_out       ),
    .tx_data2_ask_out                   (tx_data2_ask_out          ),
    .tx_data1_in                        (tx_data1                  ),
    .tx_data1_valid_in                  (tx_data1_valid            ),
    .tx_data2_in                        (tx_data2                  ),
    .tx_data2_valid_in                  (tx_data2_valid            ),
    .up_gear                            (up_gear7045               ) 
    );
 
    wire                                vio_para_en                ;
    wire               [   7: 0]        vio_para_type              ;
    wire                                vio_Mctrl_rstn_163m84      ;
    wire                                vio_rstn_20m               ;

vio_spi_tx vio_spi_tx_inst (
    .clk                                (clk163m84                 ),// input wire clk
    .probe_out0                         (vio_para_en               ),// output wire [0 : 0] probe_out0
    .probe_out1                         (vio_para_type             ),// output wire [7 : 0] probe_out1
    .probe_out2                         (vio_Mctrl_rstn_163m84     ) // output wire [0 : 0] probe_out2
);

vio_MCtrl_rst u_vio_Mctrl_rst (
    .clk                                (sys_clk20m                ),// input wire clk
    .probe_out0                         (vio_rstn_20m              ) // output wire [0 : 0] probe_out0
);

    wire               [ 415: 0]        UL_Statistics              ;
assign UL_Statistics = 
    {GD_ctrl_cnt, ctrl_sdl_cnt, yw_sdl_cnt, DL_cnt, 160'd0, w_MC_UL_Statistics};

MCtrl_top  MCtrl_top_inst (
    .i_clk163m84                        (clk163m84                 ),
    .i_clk20m                           (sys_clk20m                ),
    .i_rst_n                            (rst_n_rr && vio_Mctrl_rstn_163m84),// 163.84m
    .i_rstn                             (sys_rstn && vio_rstn_20m  ),// 20m

    .BCTRL_RX_CLK                       (BCTRL_RX_CLK              ),
    .BCTRL_RX_DATA                      (BCTRL_RX_DATA             ),
    .BCTRL_RX_EN                        (BCTRL_RX_EN               ),

    .BCTRL_TX_CLK                       (BCTRL_TX_CLK              ),
    .BCTRL_TX_DATA                      (BCTRL_TX_DATA             ),
    .BCTRL_TX_EN                        (BCTRL_TX_EN               ),

    .vio_para_type                      (vio_para_type             ),
    .vio_para_en                        (vio_para_en               ),
    // -------------------------690t to 7045------------------------
    .ds_sync_data_i                     (w_MC_DL_SyncInfo          ),// 0x20 [ 103: 0] 同步信道下行同步数据
    .ms_ls_status_i                     (w_MC_DL_StateInfo         ),// 0x21 [  39: 0] 中速/低速状态信息
    .ds_statistics_i                    (w_MC_DL_Statistics        ),// 0x22 [ 351: 0] 下行统计信息
    .us_statistics_i                    (UL_Statistics             ),// 0x23 [ 415: 0] 上行统计信息
    .us_data_cache_cnt_i                (us_data_cache_cnt         ),// 0x24 [  47: 0] 上行缓存剩余空间
    .software_info_i                    (w_MC_Version              ),// 0x30 [  31: 0] 软件版本信息
    // -------------------------7045 to 690t------------------------
    .o_soft_rst_n                       (w_MC_GlobalRst            ),// 0x00   [   7: 0]    复位功能 触发690T全局复位，包括通信信息、调制解调模块等的复位                     
    .o_FixedFre_or_FreHop_mod           (w_MC_HopMode              ),// 0x10   [   7: 0]    定频/跳频模式                                               
    .o_rx_freq                          (w_MC_FreqBase             ),// 0x11   [  63: 0]    跳频基准频点                                                
    .o_down_step_freq                   (w_MC_DL_FreqOffset        ),// 0x12   [  31: 0]    下行频偏补偿值                                               
    .o_init_tod_in                      (w_MC_TOD_Initial          ),// 0x13   [  47: 0]    初始TOD                                                 
    .o_us_ds_para                       (w_MC_FH_Param             ),// 0x14   [  47: 0]    上下行跳频参数配置                                             
    .o_ds_timeslot                      (w_MC_GearEverySlot        ),// 0x15   [ 255: 0]    下行时隙档位配置 
    .o_config                           (config_data               ),// 0x16   [   7: 0]    下行解帧范式配置,to lvds_tx.downlink_parse
    .o_config_valid                     (config_vld                ),
    .o_statistical_info_rst             (w_MC_StatCLR              ),// 0x18   [   7: 0]    统计信息清零                                                
    .o_trans_latency_compens            (w_MC_SE_unidt             ),// 0x05   [  31: 0]    星地传输延迟补偿值                                             
    .o_us_ms_addr_crc                   (w_MC_UL_Address           ),// 0x06   [  31: 0]    上行中速同步站地址和CRC                                         
    .o_us_fre_offset_compens            (w_MC_UL_FreqOffset        ),// 0x07   [  31: 0]    上行频偏补偿值                                               
    .o_us_sync_en                       (w_MC_UL_Sync_Slot         ),// 0x08   [ 135: 0]    上行中速/低速同步信道使能                                         
    .o_us_send_choose                   (w_MC_UL_TxDataSet         ),// 0x09   [  23: 0]    上行发送数据选择                                              
    .o_ls_carrier_cfg                   (w_MC_UL_LDR_CarrierSet    ),// 0x0B   [ 135: 0]    上行低速载波配置                                              
    .o_ms_timeslot                      (w_MC_UL_MDR_SlotSet       ) // 0x0C   [ 175: 0]    上行中速时隙配置                                              
//    .o_ds_sync_data                    (w_MC_DL_SyncInfo          ),// 0x20   [ 103: 0]    同步信道下行同步数据                                            
//    .o_ms_ls_status                    (w_MC_DL_StateInfo         ),// 0x21   [  39: 0]    中速/低速状态信息                                             
//    .o_ds_statistics                   (w_MC_DL_Statistics        ),// 0x22   [ 351: 0]    下行统计信息                                                
//    .o_us_statistics                   (w_MC_UL_Statistics        ),// 0x23   [ 415: 0]    上行统计信息                                                
//    .o_software_info                   (w_MC_Version              ) // 0x30   [  31: 0]    软件版本信息                                                
    
  );

always@(posedge clk163m84 or negedge vio_Mctrl_rstn_163m84)begin
    if(!vio_Mctrl_rstn_163m84)begin
        ctrl_timeslot<='d0;
        busi_timeslot<='d0;
        circuit_timeslot<='d0;
    end else case(w_MC_UL_MDR_SlotSet[175 -: 8])
        8'd1:begin
            ctrl_timeslot <= w_MC_UL_MDR_SlotSet[159 -: 32];
        end
        8'd2:begin
            busi_timeslot <= w_MC_UL_MDR_SlotSet[159 -: 32];
        end
        8'd3:begin
            circuit_timeslot <= w_MC_UL_MDR_SlotSet[159 -: 32];
        end
        default:begin
            ctrl_timeslot<=ctrl_timeslot;
            busi_timeslot<=busi_timeslot;
            circuit_timeslot<=circuit_timeslot;
        end
    endcase
end

endmodule
