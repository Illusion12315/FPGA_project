`timescale 1ns/100ps


module lvds(  
    input                      clk_100m                ,
    input                      rst_n                   ,
    input                      rstn                 ,
    input                      clk_m_144            ,
    
    input                      p2s_rstn,
   
    // LVD
    input   [3:0]              dat_in_p                ,
    input   [3:0]              dat_in_n                ,
    input                      clk_in_p                ,
    input                      clk_in_n                ,
    input                      dat_vld_in              ,
   
    output  [3:0]              dat_out_p               ,        
    output  [3:0]              dat_out_n               ,        
    output                     clk_to_pins_p           ,        
    output                     clk_to_pins_n           ,        
    output                     dat_vld_o               ,
    //from690to7045
    input   [15:0]             frame_len               ,
    input                      fd_in                   ,
    input                      vld_in                  ,
    input                      eof_in                  ,
    input   [7:0]              dat_in                  ,
    //from7045to690
    output                     dout_start                ,
    //output                     fl_vld                  ,
    output   [8:0]             s2p_dout                 ,
    //cnt
    output  reg [31:0]             rt_rev_cnt              ,
    output  reg [31:0]             fl_send_cnt           ,
    output  reg [31:0]             cnt_sdl_output   
    ); 


wire                           locked                  ;    
wire        [3:0]              data_out                ; 
wire                           clk_out                 ;
wire        [3:0]              data_out_lvds           ;
wire                           dat_vld_to_device_tmp   ;
wire                           data_to_fd_vld          ;
wire        [3:0]              data_to_lvds            ;
wire                           data_to_sys_vld         ;
wire        [7:0]              data_to_sys             ;
wire                           data_to_sys_fd          ;


//reg         [31:0]             rt_rev_cnt              ;
reg                            dat_vld_in_r            ;
//reg         [31:0]             fl_send_cnt             ;

reg rstn_r,rstn_rr;

always @(posedge clk_100m)begin
    rstn_r  <= rstn;
    rstn_rr <= rstn_r;
end 

//assign locked = rst_n;
assign locked = rstn_rr;

(*keep="TRUE"*) reg   [3:0]     data_out_tmp           ;
(*keep="TRUE"*) reg   [3:0]     data_out_tmp_1d        ;
(*keep="TRUE"*) reg   [3:0]     data_out_tmp_2d        ;


//////////////////////////////////

lvds_s2p  u_lvds_s2p
(  //.clk             ( clk_out  )                ,
   .clk             ( clk_100m  )                ,
    .clk_m_144      (clk_m_144)                 ,
   .rst_n         (   rst_n)             ,
   .rstn          (rstn_rr)         ,
   .s2p_din     (   data_out)        ,

   .dout_en    (dout_start)    ,
   .s2p_dout   ( s2p_dout )
);
wire data_out_d1;
reg  data_out_d2;
assign  data_out_d1=data_out[3];

always@(posedge clk_100m )begin
    data_out_d2<=data_out_d1;
end


reg [31:0]cnt_s2p_in;
always@(posedge clk_100m or negedge  rstn_rr)begin
    if(!rstn_rr)
        cnt_s2p_in<= 'd0;
     else if (!data_out_d2 & data_out_d1 )
        cnt_s2p_in <= cnt_s2p_in+1'b1;
     else
        cnt_s2p_in <= cnt_s2p_in;
end


//MOD_IN_VIO U_CNT_S2P_IN(
//    .clk               (clk_100m           ), // input wire clk                 
//    .probe_in0         (cnt_s2p_in   ), // output wire [31 : 0] probe_out0
//    .probe_in1         (32'hffff_ffff  )  // output wire [31 : 0] probe_out1
//);

wire [3:0] cat_data;
wire    p2s_vldout;


// lvds_p2s u_lvds_p2s(

lvds_p2s   u_lvds_p2s(
//input
	.clk               (clk_100m ),
//	.rst_n             (rst_n),
	.rst_n             (rstn_rr && p2s_rstn),
	
	.din_sof            ( fd_in                 ),
	.din_vld            ( vld_in                ),
	.din_eof            ( eof_in                ),
	.din                ( dat_in                ),
	.din_len            ( frame_len                ),
//output
    .dout               (   cat_data             ),
    .dout_vld           (   p2s_vldout         ),  
	.dout_sof           (   data_to_fd_vld           ),   
	.cnt_sdl_output     (   cnt_sdl_output           )   
);
////////////////////////////////
 
 lvds_test_ip1 u_lvds_test_ip1
 (
  //from pin
  .DATA_IN_FROM_PINS_P          (dat_in_p               ),
  .DATA_IN_FROM_PINS_N          (dat_in_n               ),
  .CLK_IN_P                     (clk_in_p               ), 
  .CLK_IN_N                     (clk_in_n               ),
  .data_vld_from_pin            (dat_vld_in             ),
  
  //to sys
  .CLK_OUT                      (clk_out                ),
  .data_vld_to_device           (dat_vld_to_device_tmp  ),
  .DATA_IN_TO_DEVICE            (data_out_lvds          ),
  
  //to pin
  .clk_to_pins_p                (clk_to_pins_p          ),
  .clk_to_pins_n                (clk_to_pins_n          ),
  .data_vld_to_pin              (dat_vld_o              ),
  .DATA_OUT_TO_PINS_P           (dat_out_p              ),  
  .DATA_OUT_TO_PINS_N           (dat_out_n              ),  
  
  //from sys
  .clk_100m_from_dev            (clk_100m               ),
  .DATA_OUT_FROM_DEVICE         (cat_data               ),
  .data_vld_from_device         (p2s_vldout             ),

  .IO_RESET                     (!locked                )
  );


always @(posedge clk_out ) 
begin
	data_out_tmp      <= data_out_lvds    ;
	data_out_tmp_1d   <= data_out_tmp                             ;
	data_out_tmp_2d   <= data_out_tmp_1d                          ;
end
/*
data_recieve_690t  u_r_recdata_recieve_690t(
    .clk_bb                     ( clk_out               ),//clk_to_dev                                    ),
    .clk_core                   ( clk_100m              ),
    .data_in                    ( data_out_tmp_2d       ),//{dat_in_dev_vld,dat_in_to_dev}                ),
    .data_out                   ( data_out              )//data_out                                      )
    );
 */ 
reg rstn_r1,rstn_r2;
 
 always @(posedge clk_out)begin
    rstn_r1  <= rstn_rr;
    rstn_r2  <= rstn_r1;
 end 
receive_fifo u_receive_fifo(
     .clk_out                    ( clk_out               ),//clk_to_dev                                    ),
     .clk_100m                   ( clk_100m              ),
     .rst_n                      ( rstn_r2                 ),
     .data_out_tmp_2d            ( data_out_tmp_2d       ),//{dat_in_dev_vld,dat_in_to_dev}                ),
     .data_out                   ( data_out              )//data_out                                      )
     );
 
 
 reg [13:0] count_din;

 always@(posedge clk_out)
    if(!rstn_r2)
        count_din <= 14'd0;
    else if(data_out_tmp_2d[3])
        count_din <= count_din+1'd1;
    else
        count_din <= 14'd0;
  
  
  
//  ILA_RECEIVE_690T  U_ILA_RECEIVE_690T
//  (
//  .clk        (clk_out),
//  .probe0     ( data_out_tmp_2d          ), // input wire [3:0]  probe0 
//  .probe1     ( count_din               ) // input wire [13:0]  probe1 
//  //.probe2     ( u_lvds_s2p.cnt_din              ), // input wire [14:0]  probe2 
//  );
  
  
  

 
// ILA_S2P_100   U_ILA_S2P_100   (
//                            .clk        ( clk_100m                  ), // input wire clk
                           
//                            .probe0     ( u_lvds_s2p.s2p_din_d0           ), // input wire [0:0]  probe0 
//                            .probe1     ( u_lvds_s2p.wraddr               ), // input wire [13:0]  probe1 
//                            .probe2     ( u_lvds_s2p.cnt_din              ), // input wire [14:0]  probe2 
//                            .probe3     ( u_lvds_s2p.read_start           ), // input wire [0:0]  probe3            
//                            .probe4     ( u_lvds_s2p.vldin_flag           ), // input wire [0:0]  probe4     
//                            .probe5     ( u_lvds_s2p.vldin_flag_d1        ), // input wire [0:0]  probe5    
//                            .probe6     ( u_lvds_s2p.s2p_din              ), // input wire [3:0]  probe6    
//                            .probe7     ( u_lvds_s2p.s2p_din_d1           ) // input wire [0:0]  probe7    
//                            );
 

//////////////////////////end test
//dat_out_intf_modified  u_dat_out_intf_modified_demod(
//    .clk                        ( clk_100m              ),  
//    .rst_n                      ( locked                ),  
//    .rst_n_o                    ( locked                ),   
//    .fd_in                      ( fd_in                 ),  
//    .vld_in                     ( vld_in                ),  
//    .eof_in                     ( eof_in                ),  
//    .dat_in                     ( dat_in                ),  
//    .full_in                    ( 1'b0                  ),  

    
//    .full_o                     (                       ), 
//    .fd_o                       ( data_to_fd_vld        ),  
//    .dat_o                      ( data_to_lvds          )  
//);  

//rt_rev_cnt
//dat_vld_o is one pulse,freme head;
always @ (posedge clk_100m or negedge rstn_rr) begin
    if (!rstn_rr) begin
        rt_rev_cnt <= 32'd0;
    end
    else if (data_to_fd_vld) begin
        rt_rev_cnt <= rt_rev_cnt + 1'b1;
    end
    else begin
        rt_rev_cnt <= rt_rev_cnt;
    end
end

//dat_vld_in_r
//do dat_vld_in negedge lower_edge, do cnt
always @ (posedge clk_100m or negedge rstn_rr) begin
    if (!rstn_rr) begin
        dat_vld_in_r <= 1'd0;
    end
    else begin
        dat_vld_in_r <= dat_vld_to_device_tmp;
    end
end

//fl_send_cnt
//do dat_vld_in negedge lower_edge, do cnt
always @ (posedge clk_100m or negedge rstn_rr) begin
    if (!rstn_rr) begin
        fl_send_cnt <= 32'd0;
    end
    else if (dat_vld_in_r & (!dat_vld_to_device_tmp)) begin
        fl_send_cnt <= fl_send_cnt + 1'b1;
    end
    else begin
        fl_send_cnt <= fl_send_cnt;
    end
end

//-------------------------------ILA---------------------------------//
        
//ILA_MOD_LVDS   U_ILA_MOD_LVDS (
//    .clk           (clk_100m), // input wire clk
////u_lvds.u_lvds_s2p
//    .probe0     (u_lvds_s2p.vldin_flag_d0   ), // input wire [0:0]  probe0  
//    .probe1     (u_lvds_s2p.wraddr          ), // input wire [13:0] probe1 
//    .probe2     (u_lvds_s2p.s2p_din_d0      ), // input wire [0:0]  probe2 
//    .probe3     (u_lvds_s2p.rdaddr          ), // input wire [11:0] probe3 
//    .probe4     (u_lvds_s2p.dout1           ), // input wire [3:0]  probe4 
//    .probe5     (u_lvds_s2p.s2p_dout        ), // input wire [4:0]  probe5
////u_lvds.u_pre(data_pre_modified)   
//    .probe6     (u_data_pre_modified_mod.lvds_clk              ), // input wire [0:0]  probe6  
//    .probe7     (u_data_pre_modified_mod.data_vld              ), // input wire [0:0]  probe7 
//    .probe8     (u_data_pre_modified_mod.data_in               ), // input wire [3:0]  probe8 
//    .probe9     (u_data_pre_modified_mod.fl_start              ), // input wire [0:0]  probe9 
//    .probe10   (u_data_pre_modified_mod.fl_vld                ), // input wire [0:0]  probe10
//    .probe11   (u_data_pre_modified_mod.fl_data               ), // input wire [7:0]  probe11
//    .probe12   (u_data_pre_modified_mod.addra                 ), // input wire [11:0] probe12
//    .probe13   (u_data_pre_modified_mod.dina                  ), // input wire [3:0]  probe13
//    .probe14   (u_data_pre_modified_mod.addr_rd_b             ), // input wire [10:0] probe14
//    .probe15   (u_data_pre_modified_mod.doutb_b               ), // input wire [7:0]  probe15
//    .probe16   (u_data_pre_modified_mod.addr_rd_a             ), // input wire [10:0] probe16 
//    .probe17   (u_data_pre_modified_mod.doutb_a               ), // input wire [7:0]  probe17 
//    .probe18   (u_data_pre_modified_mod.ram_control           ), // input wire [0:0]  probe18 
//    .probe19   (u_data_pre_modified_mod.wea                   ), // input wire [0:0]  probe19 
//    .probe20   (u_data_pre_modified_mod.bbframe_sof           ), // input wire [0:0]  probe20
//    .probe21   (u_data_pre_modified_mod.bbframe_eof           ), // input wire [0:0]  probe21 
//    .probe22   (u_data_pre_modified_mod.eof_ena_out           ), // input wire [0:0]  probe22 
//    .probe23   (u_data_pre_modified_mod.rd_ena                ) // input wire [0:0]  probe23   
    
//);


endmodule
