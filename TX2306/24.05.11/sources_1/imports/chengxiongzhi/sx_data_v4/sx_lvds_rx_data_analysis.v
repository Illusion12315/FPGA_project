`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/22 11:44:23
// Design Name: 
// Module Name: lvds_rx
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


module sx_lvds_rx_data_analysis(
    input                               clk_m_144                  ,
    input                               rst_n                      ,
    
    input              [   7:0]         s2p_dout                   ,
    input                               dout_start                 ,
    
    output reg         [  15:0]         channel_mang_r             ,
//    output  reg         channel_flag,
    output             [   7:0]         o_yworcirc_data            ,
    output                              o_yworcirc_data_valid      ,

    output                              o_info_start_flag          ,
    output                              byte_cnt_equal_25          ,
    
    output             [   7:0]         o_info_type                 
//    output   [7:0]   o_circyw_data,
//    output           o_circyw_data_valid

    );
    
    parameter                           IDLE   = 4'd0              ;
    parameter                           HEAD   = 4'd1              ;
    parameter                           S_SECT = 4'd2              ;
    parameter                           S_SDL  = 4'd3              ;
    parameter                           S_CIRC = 4'd4              ;
 
 
reg                    [   3:0]         state                      ;
    
reg                    [   7:0]         s2p_dout_r,s2p_dout_rr     ;
reg                                     dout_start_r,dout_start_rr ;
 
reg                    [  10:0]         byte_cnt_r                 ;
 
reg                    [   7:0]         info_type                  ;
reg                    [   7:0]         segm_mark                  ;
reg                    [  15:0]         info_fram_leng             ;
reg                    [  15:0]         leng                       ;
reg                    [  47:0]         time_stamp                 ;
reg                    [   7:0]         satel_num                  ;
reg                    [   7:0]         beram_num                  ;

reg                    [  15:0]         sync_head                  ;
reg                    [  15:0]         cfg_leng                   ;
reg                    [  15:0]         conti_cnt                  ;
reg                    [  15:0]         channel_mang               ;
reg                    [   7:0]         reser                      ;
// reg         channel_flag;

reg                    [  15:0]         yw_link_def                ;
reg                    [  23:0]         source_addr                ;
reg                    [  23:0]         desti_addr                 ;
reg                    [  15:0]         circyw_leng                ;

reg                    [  10:0]         data_cnt                   ;
 
reg                    [   7:0]         yw_data                    ;
reg                                     yw_data_valid              ;
 
reg                    [   7:0]         circyw_data                ;
reg                                     circyw_data_valid          ;
 
reg                    [   7:0]         r_yworcirc_data            ;
reg                                     r_yworcirc_data_valid      ;
wire                   [   4:0]         Info_Low                   ;
 assign o_yworcirc_data         = r_yworcirc_data;
 assign o_yworcirc_data_valid   = r_yworcirc_data_valid;
 assign o_info_type             = info_type;
 assign Info_Low                = info_type[3:0];
reg                    [  11:0]         ywdata_cnt                 ;
always @(posedge clk_m_144 or negedge rst_n) begin
    if(!rst_n) begin
        ywdata_cnt <= 'b0;
    end
    else if(circyw_data_valid) begin
        ywdata_cnt <= ywdata_cnt + 'b1;
    end
    else begin
        ywdata_cnt <= 'b0;
    end
end
ila_lvds_rx ila_lvds_rx_inst (
    .clk                               (clk_m_144                 ),// input wire clk


    .probe0                            (state                     ),// input wire [3:0]  probe0  
    .probe1                            (dout_start_rr             ),// input wire [0:0]  probe1 
    .probe2                            (s2p_dout_rr               ),// input wire [7:0]  probe2 
    .probe3                            (byte_cnt_r                ),// input wire [10:0]  probe3 
    .probe4                            (info_type                 ),// input wire [7:0]  probe4 
    .probe5                            (segm_mark                 ),// input wire [7:0]  probe5 
    .probe6                            (info_fram_leng            ),// input wire [15:0]  probe6 
    .probe7                            (leng                      ),// input wire [15:0]  probe7 
    .probe8                            (time_stamp                ),// input wire [47:0]  probe8 
    .probe9                            (satel_num                 ),// input wire [7:0]  probe9 
    .probe10                           (beram_num                 ),// input wire [7:0]  probe10 
    .probe11                           (sync_head                 ),// input wire [15:0]  probe11 
    .probe12                           (cfg_leng                  ),// input wire [15:0]  probe12 
    .probe13                           (conti_cnt                 ),// input wire [15:0]  probe13 
    .probe14                           (channel_mang              ),// input wire [15:0]  probe14 
    .probe15                           (reser                     ),// input wire [7:0]  probe15 
    .probe16                           (yw_link_def               ),// input wire [15:0]  probe16 
    .probe17                           (source_addr               ),// input wire [23:0]  probe17 
    .probe18                           (desti_addr                ),// input wire [23:0]  probe18 
    .probe19                           (circyw_leng               ),// input wire [15:0]  probe19 
    .probe20                           (data_cnt                  ),// input wire [10:0]  probe20 
    .probe21                           (yw_data                   ),// input wire [7:0]  probe21 
    .probe22                           (yw_data_valid             ),// input wire [0:0]  probe22 
    .probe23                           (circyw_data               ),// input wire [7:0]  probe23 
    .probe24                           (circyw_data_valid         ),// input wire [0:0]  probe24
    .probe25                           (channel_mang_r            ),// input wire [15:0]  probe24
    .probe26                           (ywdata_cnt                ) // input wire [11:0]  probe24
);
 
 always @(posedge clk_m_144)begin
    dout_start_r <= dout_start;
    dout_start_rr <= dout_start_r;
 end
 always @(posedge clk_m_144)begin
    s2p_dout_r  <= s2p_dout;
    s2p_dout_rr <= s2p_dout_r;
 end
 

wire                                    sig_pose                   ;
wire                                    sig_nege                   ;

assign sig_pose = !dout_start_rr && dout_start_r;
assign sig_nege = !dout_start_r && dout_start_rr;

 always @(posedge clk_m_144 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        byte_cnt_r    <= 11'd0;
        yw_data_valid <= 1'b0;
        yw_data       <= 8'd0;
        circyw_data         <= 8'd0;
        circyw_data_valid   <= 1'b0;
        data_cnt        <= 11'd0;

        
        state      <= IDLE;
    end
   else case(state)
     IDLE:begin
        yw_data_valid <= 1'b0;
        yw_data       <= yw_data;
        
        circyw_data         <= circyw_data;
        circyw_data_valid   <= 1'b0;
        data_cnt        <= 11'd0;
        
//        channel_flag    <= 1'b0;
        
        byte_cnt_r     <= 11'd0;
        
        if(sig_pose)begin
            state <= HEAD;
        end
        else begin
            state <= state;
        end
     end
   
      HEAD:begin
        yw_data_valid <= 1'b0;
        yw_data       <= yw_data;
        
        circyw_data         <=circyw_data;
        circyw_data_valid   <= 1'b0;
        data_cnt        <= 11'd0;
        if(sig_nege)begin
            state <= IDLE;
        end
        else if(dout_start_rr== 1'b1 && byte_cnt_r== 11'd43)begin
             state <= S_SECT;
        end

        else if(dout_start_rr== 1'b1)begin
            byte_cnt_r <= byte_cnt_r + 1'b1;
        end
        else begin
            byte_cnt_r <= byte_cnt_r;
        end
        
      end
      S_SECT:begin
//        circyw_data         <= circyw_data;
//        circyw_data_valid   <= 1'b0;
        if(sig_nege)begin
            state <= IDLE;
        end
        else if(dout_start_rr== 1'b1 && (Info_Low == 4'd11 || Info_Low == 4'd12))begin
             yw_data_valid <= 1'b1;
             yw_data       <= s2p_dout_rr;
             state          <=S_SDL;
             data_cnt       <= data_cnt + 1'b1;
        end
        else if(dout_start_rr== 1'b1 && Info_Low == 4'd13)begin
             byte_cnt_r <= byte_cnt_r + 1'b1;
                 if(dout_start_rr== 1'b1 && byte_cnt_r == 11'd53)begin
                    state <= S_CIRC;
                    
                    circyw_data         <= s2p_dout_rr;
                    circyw_data_valid   <= 1'b1;
                    data_cnt       <= data_cnt + 1'b1;
                 end
                 else begin
                    state <= state;
                 end
        end
      end
      S_SDL:begin
        if(data_cnt == info_fram_leng-6'd38)begin
                data_cnt <= 11'd0;
                yw_data_valid <= 1'b0;
                yw_data       <= yw_data;
                
                state    <= IDLE;
            end
        else begin
            data_cnt <= data_cnt + 1'b1;
            yw_data_valid <= yw_data_valid;
            yw_data       <= s2p_dout_rr;
        end
      end
      S_CIRC:begin
            yw_data_valid <= 1'b0;
            yw_data       <= yw_data;
            if(data_cnt == info_fram_leng- 6'd48)begin
                 data_cnt          <= 11'd0;
                 circyw_data       <= circyw_data;
                 circyw_data_valid <= 1'b0;
                 
                 state              <= IDLE;
            end
            else begin
                data_cnt            <= data_cnt + 1'b1;
                circyw_data         <= s2p_dout_rr;
                circyw_data_valid   <= circyw_data_valid;
            end
      
      end
//      S_CIRC:begin
//            yw_data_valid <= 1'b0;
//            yw_data       <= yw_data;
//            if(dout_start_rr==1'b1)begin
//                circyw_data         <= s2p_dout_rr;
//                circyw_data_valid   <= 1'b1;
                
//                if(data_cnt == circyw_leng-1'b1)begin
//                    data_cnt <= 11'd0;
//                    state    <= IDLE;
//                end 
//                else begin
//                    data_cnt <= data_cnt + 1'b1;
//                end 
//            end 
//            else begin
//                    state <= state;
//            end 
//      end 
         default:begin state <=  IDLE; end
   endcase
   
 end
 
 
 
 always @(posedge clk_m_144 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        info_type       <= 8'd0;
        segm_mark       <= 8'd0;
        info_fram_leng  <= 16'd0;
        leng            <= 16'd0;
        time_stamp      <=48'd0;
        satel_num       <=8'd0;
        beram_num       <=8'd0;

       sync_head      <=16'd0;
       cfg_leng       <=16'd0;
       conti_cnt      <=16'd0;
       channel_mang   <=16'd0;
       reser          <=8'd0;
       
       yw_link_def   <=16'd0 ;
       source_addr   <=24'd0;
       desti_addr    <=24'd0 ;
       circyw_leng   <=16'd0 ;
    end
    else if(dout_start_rr)begin
        case(byte_cnt_r)
         11'd0:begin  info_type             <=  s2p_dout_rr; end
         11'd1:begin  segm_mark             <=  s2p_dout_rr; end
         11'd2:begin  info_fram_leng[15:8]  <=  s2p_dout_rr; end
         11'd3:begin  info_fram_leng[7:0]   <=  s2p_dout_rr; end
         11'd4:begin  leng[15:8]            <=  s2p_dout_rr; end
         11'd5:begin  leng[7:0]             <=  s2p_dout_rr; end
         11'd6:begin  time_stamp[47:40]     <=  s2p_dout_rr; end
         11'd7:begin  time_stamp[39:32]     <=  s2p_dout_rr; end
         11'd8:begin  time_stamp[31:24]     <=  s2p_dout_rr; end
         11'd9:begin  time_stamp[23:16]     <=  s2p_dout_rr; end
         11'd10:begin time_stamp[15:8]      <=  s2p_dout_rr; end
         11'd11:begin time_stamp[7:0]       <=  s2p_dout_rr; end
         11'd12:begin satel_num             <=  s2p_dout_rr; end
         11'd13:begin beram_num             <=  s2p_dout_rr; end
         11'd14:begin sync_head[15:8]       <=  s2p_dout_rr; end
         11'd15:begin sync_head[7:0]        <=  s2p_dout_rr; end
         11'd16:begin cfg_leng[15:8]        <=  s2p_dout_rr; end
         11'd17:begin cfg_leng[7:0]         <=  s2p_dout_rr; end
         11'd18:begin conti_cnt[15:8]       <=  s2p_dout_rr; end
         11'd19:begin conti_cnt[7:0]        <=  s2p_dout_rr; end
         11'd20:begin channel_mang[15:8]   <=  s2p_dout_rr; end
         11'd21:begin channel_mang[7:0]    <=  s2p_dout_rr; end
//         11'd22:begin channel_mang[15:8]    <=  s2p_dout_rr; end 
//         11'd23:begin channel_mang[7:0]     <=  s2p_dout_rr; end 
         11'd22,11'd23,11'd24,11'd25,11'd26,11'd27,11'd28,11'd29,11'd30,11'd31,11'd32,
         11'd33,11'd34,11'd35,11'd36,11'd37,11'd38,11'd39,11'd40,11'd41,11'd42,11'd43:
                begin  reser                <=  s2p_dout_rr; end
         11'd44:begin  yw_link_def[15:8]    <=  s2p_dout_rr; end
         11'd45:begin  yw_link_def[7:0]     <=  s2p_dout_rr; end
         11'd46:begin  source_addr[23:16]   <=  s2p_dout_rr; end
         11'd47:begin  source_addr[15:8]    <=  s2p_dout_rr; end
         11'd48:begin  source_addr[7:0]     <=  s2p_dout_rr; end
         11'd49:begin  desti_addr [23:16]   <=  s2p_dout_rr; end
         11'd50:begin  desti_addr[15:8]     <=  s2p_dout_rr; end
         11'd51:begin  desti_addr[7:0]      <=  s2p_dout_rr; end
         11'd52:begin  circyw_leng[15:8]    <=  s2p_dout_rr; end
         11'd53:begin  circyw_leng[7:0]     <=  s2p_dout_rr; end
     
        default begin
            info_type       <=info_type     ;
            segm_mark       <=segm_mark     ;
            info_fram_leng  <=info_fram_leng;
            leng            <=leng          ;
            time_stamp      <=time_stamp    ;
            satel_num       <=satel_num     ;
            beram_num       <=beram_num     ;

           sync_head      <=sync_head   ;
           cfg_leng       <=cfg_leng    ;
           conti_cnt      <=conti_cnt   ;
           channel_mang   <=channel_mang;
           reser          <=reser       ;
           
          yw_link_def   <=yw_link_def ;
          source_addr   <=source_addr;
          desti_addr    <=desti_addr  ;
          circyw_leng   <=circyw_leng ;
        end
        endcase
 
    end
        else begin
            info_type       <=info_type     ;
            segm_mark       <=segm_mark     ;
            info_fram_leng  <=info_fram_leng;
            leng            <=leng          ;
            time_stamp      <=time_stamp    ;
            satel_num       <=satel_num     ;
            beram_num       <=beram_num     ;

           sync_head      <=sync_head   ;
           cfg_leng       <=cfg_leng    ;
           conti_cnt      <=conti_cnt   ;
           channel_mang   <=channel_mang;
           reser          <=reser       ;
           
          yw_link_def   <=yw_link_def ;
          source_addr   <=source_addr;
          desti_addr    <=desti_addr  ;
          circyw_leng   <=circyw_leng ;
       end
 end
 
 
 always @(posedge clk_m_144 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
         channel_mang_r    <= 16'd0;
    end
    else if(byte_cnt_r== 11'd23)begin
        channel_mang_r    <= channel_mang;
    end
    else begin
        channel_mang_r    <= channel_mang_r;
    end
 end
 
always @(posedge clk_m_144 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
         r_yworcirc_data        <= 8'd0;
         r_yworcirc_data_valid  <= 1'b0;
    end
    else if(Info_Low == 4'd11 || Info_Low == 4'd12)begin
         r_yworcirc_data        <= yw_data;
         r_yworcirc_data_valid  <= yw_data_valid;
    end
    else if(Info_Low == 4'd13)begin
        r_yworcirc_data        <= circyw_data;
        r_yworcirc_data_valid  <= circyw_data_valid;
    end
    else begin
        r_yworcirc_data        <= 8'd0;
        r_yworcirc_data_valid  <= 1'b0;
    end
end


assign o_info_start_flag = (byte_cnt_r == 11'd23)? 'd1: 'd0;

assign byte_cnt_equal_25 = (byte_cnt_r == 11'd25)? 'd1: 'd0;


endmodule
