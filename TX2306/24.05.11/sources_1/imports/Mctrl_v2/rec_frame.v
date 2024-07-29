`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/25 00:15:44
// Design Name: 
// Module Name: rec_frame
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


module rec_frame(
    input  wire                         i_clk163m84                ,
    input  wire                         i_clk20m                   ,
    input  wire                         i_rstn                     ,
    input  wire                         i_rst_n                    ,
    
    input  wire                         i_data_in                  ,
    input  wire                         i_data_en                  ,
    input  wire                         i_data_crc_valid           ,
    input  wire        [  15:0]         i_data_crc                 ,
    
    output wire                         o_crc_ok                   ,
    output wire        [  15:0]         o_rd_cnt                   ,
    output wire        [   7:0]         o_para_type                ,
    output wire        [   7:0]         o_ram_in                   ,
    
    output wire        [   7:0]         o_1to8_data                ,
    output wire                         o_1to8_valid                
    );

localparam                              R_IDEL        = 4'd0       ,
                                        R_START       = 4'd1,
                                        R_WAIT        = 4'd2,
                                        R_LENG        = 4'd3,
                                        R_RDATA       = 4'd4,
                                        R_CRC         = 4'd5,
                                        R_REND        = 4'd6;
reg                    [   3:0]         r_state                    ;
reg                                     r_data_in1,r_data_in2      ;
reg                                     r_data_en1,r_data_en2,r_data_en3,r_data_en4;
reg                    [  12:0]         r_addr_wr                  ;
reg                    [   9:0]         r_addr_rd                  ;
reg                    [  15:0]         r_rd_cnt                   ;
reg                                     r_ram_valid                ;
reg                                     r_data_valid               ;
reg                                     r_fram_leng_flag           ;

reg                    [   7:0]         r_info_type                ;
reg                    [   7:0]         r_segm_mark                ;
reg                    [  15:0]         r_info_fram_leng           ;
reg                    [  15:0]         r_leng                     ;
reg                    [  47:0]         r_sour_addr                ;
reg                    [  47:0]         r_dest_addr                ;
reg                    [   7:0]         r_info_unit_idenf          ;
reg                    [  15:0]         r_info_unit_leng           ;
reg                    [   7:0]         r_parm_type                ;

reg                    [  15:0]         data_crc_r1,data_crc_r2,data_crc_r3;

reg                                     r_data_crc_valid1,r_data_crc_valid2;
reg                    [  15:0]         r_rec_crc                  ;
reg                                     r_crc_ok                   ;
reg                                     r_crc_err                  ;

wire                                    w_wr_done_flag             ;
wire                                    w_rd_done_flag             ;
wire                   [   7:0]         w_ram_dout                 ;
wire                   [   7:0]         ram_dout                   ;



assign w_wr_done_flag = r_data_en4 && !r_data_en3;
//----------------------------
 always @(posedge i_clk20m)begin
    r_data_in1   <= i_data_in;
    r_data_in2   <= r_data_in1;
  end
 always @(posedge i_clk20m)begin
    r_data_en1   <= i_data_en;
    r_data_en2  <= r_data_en1;
    r_data_en3 <= r_data_en2;
    r_data_en4 <= r_data_en3;
 end

 always @(posedge i_clk20m or negedge i_rstn)begin
    if(i_rstn ==1'b0)begin
        r_addr_wr <= 13'd0;
    end
    else if(r_data_en2==1'b0)begin
        r_addr_wr <= 13'd0;
    end
    else if(r_data_en2==1'b1)begin
        r_addr_wr <= r_addr_wr + 1'b1;
    end
    else begin
        r_addr_wr <= r_addr_wr;
    end
 end
 
 ila_ram_in ila_ram_in_inst (
    .clk                               (i_clk20m                  ),// input wire clk


    .probe0                            (r_data_en2                ),// input wire [0:0]  probe0  
    .probe1                            (r_data_in2                ),// input wire [0:0]  probe1 
    .probe2                            (w_wr_done_flag            ),// input wire [0:0]  probe2 
    .probe3                            (r_addr_wr                 ) // input wire [12:0]  probe3
);

block_1to8 block_1to8_inst (
    .clka                              (i_clk20m                  ),// input wire clka
    .wea                               (r_data_en2                ),// input wire [0 : 0] wea
    .addra                             (r_addr_wr                 ),// input wire [12 : 0] addra
    .dina                              (r_data_in2                ),// input wire [0 : 0] dina
    .clkb                              (i_clk163m84               ),// input wire clkb
    .addrb                             (r_addr_rd                 ),// input wire [9 : 0] addrb
    .doutb                             (ram_dout                  ) // output wire [7 : 0] doutb
);

assign w_ram_dout ={ram_dout[0],ram_dout[1],ram_dout[2],ram_dout[3],ram_dout[4],ram_dout[5],ram_dout[6],ram_dout[7]};

xpm_cdc_single #(
   .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
   .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
   .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
)
xpm_cdc_single_inst (
   .dest_out(w_rd_done_flag), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                            // registered.
   .dest_clk(i_clk163m84),  // 1-bit input: Clock signal for the destination clock domain.
   .src_clk(i_clk20m),      // 1-bit input: optional; required when SRC_INPUT_REG = 1
   .src_in(w_wr_done_flag)  // 1-bit input: Input signal to be synchronized to dest_clk domain.
);

always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(i_rst_n==1'b0)begin
        r_state  <= R_IDEL;
        
        r_rd_cnt <= 16'd0;
        r_addr_rd <= 10'd0;
        r_ram_valid <= 1'b0;
        r_data_valid <= 1'b0;
        
        r_rec_crc    <= 16'd0;
    end
    else case(r_state)
        R_IDEL:begin
            r_rd_cnt <= 16'd0;
            r_addr_rd <= 10'd0;
            r_ram_valid <= 1'b0;
            r_data_valid <= 1'b0;
             r_rec_crc    <= 16'd0;
            if(w_rd_done_flag==1'b1)begin
                r_state <= R_START;
            end
            else begin
                r_state <= r_state;
            end
        end
       R_START:begin
//            r_ram_valid <= 1'b1;
            r_addr_rd <= r_addr_rd+ 1'b1;
            r_rd_cnt  <= 16'd0;
            r_data_valid <= 1'b0;
             r_rec_crc    <= 16'd0;
            
            r_state  <= R_WAIT;
       end
       R_WAIT:begin
            r_rd_cnt  <= r_rd_cnt + 1'b1;
            r_data_valid <= 1'b0;
             r_rec_crc    <= 16'd0;
            if(r_addr_rd==10'd1)begin
              r_addr_rd <= r_addr_rd+ 1'b1;
              r_ram_valid <= 1'b1;
              
              r_state   <= R_LENG;
            end
            else begin
                r_addr_rd <= r_addr_rd +1'b1;
                r_ram_valid <= 1'b0;
                
                r_state <= r_state;
            end
       end
       R_LENG:begin
              r_data_valid <= 1'b0;
              r_rd_cnt <= r_rd_cnt + 1'b1;
              r_rec_crc    <= 16'd0;
              if(r_fram_leng_flag == 1'b1)begin
                  r_addr_rd <= r_addr_rd+ 1'b1;
                  r_ram_valid <= 1'b1;
              
                  r_state   <= R_RDATA;
            end
            else begin
                  r_addr_rd <= r_addr_rd+ 1'b1;
                  r_ram_valid <= 1'b1;
                  
                  r_state  <= r_state;
            end
       end
       R_RDATA:begin

              r_rec_crc  <= 16'd0;
              r_ram_valid <= 1'b1;
              if(r_rd_cnt == r_info_fram_leng+3'd4)begin
                  r_data_valid <= 1'b0;
                  r_rd_cnt <= r_rd_cnt + 1'b1;
                  r_addr_rd <= r_addr_rd + 1'b1;
                  r_state <= R_CRC;
                   
             end
             else if(r_rd_cnt == 16'd21)begin
                  r_data_valid <= 1'b1;
                  r_rd_cnt <= r_rd_cnt + 1'b1;
                  r_addr_rd <= r_addr_rd + 1'b1;
                  r_state <= r_state;

             end
             else begin
                r_rd_cnt <= r_rd_cnt + 1'b1;
                r_addr_rd <= r_addr_rd + 1'b1;
                r_state <= r_state;

                r_data_valid <= r_data_valid;

            end
       end
       R_CRC:begin
              r_data_valid <= 1'b0;
              if(r_rd_cnt == r_info_fram_leng+3'd6)begin
                    r_state <= R_REND;
                    r_rd_cnt <= 16'd0;
                    r_addr_rd <= 10'd0;
                    r_ram_valid <= 1'b0;
            
                    r_rec_crc[7:0] <= w_ram_dout;
             end
             else if(r_rd_cnt == r_info_fram_leng+3'd5)begin
                    r_state <= R_CRC;
                    r_rd_cnt <= r_rd_cnt + 1'b1;
                    r_addr_rd <= r_addr_rd + 1'b1;
                    r_ram_valid <= r_ram_valid;
                    r_rec_crc[15:8] <= w_ram_dout;
             end
             else begin
                    r_state <= R_CRC;
                    r_rd_cnt <= r_rd_cnt + 1'b1;
                    r_addr_rd <= r_addr_rd + 1'b1;
                    r_ram_valid <= r_ram_valid;
                    r_rec_crc <= r_rec_crc;
             end
       end
       R_REND:begin
            if(r_crc_ok==1'b1)begin
                 r_state <= R_IDEL;
            end
            else if(r_crc_err==1'b1)begin
                r_state <= R_IDEL;
            end
           else begin
                r_state <= r_state;
           end
       end
       default:begin
                r_state  <= R_IDEL;
       end
    endcase
end

ila_ram_out ila_ram_out_inst (
    .clk                               (i_clk163m84               ),// input wire clk


    .probe0                            (r_state                   ),// input wire [3:0]  probe0  
    .probe1                            (r_rd_cnt                  ),// input wire [15:0]  probe1 
    .probe2                            (r_addr_rd                 ),// input wire [9:0]  probe2 
    .probe3                            (r_ram_valid               ),// input wire [0:0]  probe3 
    .probe4                            (r_data_valid              ),// input wire [0:0]  probe4 
    .probe5                            (r_rec_crc                 ),// input wire [15:0]  probe5 
    .probe6                            (r_crc_ok                  ),// input wire [0:0]  probe6 
    .probe7                            (r_crc_err                 ),// input wire [0:0]  probe7 
    .probe8                            (w_ram_dout                ),// input wire [7:0]  probe8
    .probe9                            (i_data_crc                ),// input wire [15:0]  probe9 
    .probe10                           (r_data_crc_valid1         ),// input wire [0:0]  probe10 
    .probe11                           (r_data_crc_valid2         ) // input wire [0:0]  probe11
);

always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(i_rst_n == 1'b0)begin
       r_info_type            <=8'd0;
       r_segm_mark            <=8'd0;
       r_info_fram_leng       <=16'd0;
       r_leng                 <=16'd0;
       r_sour_addr            <=48'd0;
       r_dest_addr            <=48'd0;
       r_info_unit_idenf      <=8'd0;
       r_info_unit_leng       <=16'd0;
       r_parm_type            <=8'd0;
    end
    else case(r_rd_cnt)
        16'd1:begin r_info_type             <= w_ram_dout;end
        16'd2:begin r_segm_mark             <= w_ram_dout;end
        16'd3:begin r_info_fram_leng[15:8]  <= w_ram_dout;end
        16'd4:begin r_info_fram_leng[7:0]   <= w_ram_dout;end
        16'd5:begin r_leng[15:8]            <= w_ram_dout;end
        16'd6:begin r_leng[7:0]             <= w_ram_dout;end
        16'd7:begin r_sour_addr[47:40]      <= w_ram_dout;end
        16'd8:begin r_sour_addr[39:32]      <= w_ram_dout;end
        16'd9:begin r_sour_addr[31:24]      <= w_ram_dout;end
        16'd10:begin r_sour_addr[23:16]     <= w_ram_dout;end
        16'd11:begin r_sour_addr[15:8]      <= w_ram_dout;end
        16'd12:begin r_sour_addr[7:0]       <= w_ram_dout;end
        16'd13:begin r_dest_addr[47:40]     <= w_ram_dout;end
        16'd14:begin r_dest_addr[39:32]     <= w_ram_dout;end
        16'd15:begin r_dest_addr[31:24]     <= w_ram_dout;end
        16'd16:begin r_dest_addr[23:16]     <= w_ram_dout;end
        16'd17:begin r_dest_addr[15:8]      <= w_ram_dout;end
        16'd18:begin r_dest_addr[7:0]       <= w_ram_dout;end
        16'd19:begin r_info_unit_idenf      <= w_ram_dout;end
        16'd20:begin r_info_unit_leng[15:8] <= w_ram_dout;end
        16'd21:begin r_info_unit_leng[7:0]  <= w_ram_dout;end
        16'd22:begin r_parm_type            <= w_ram_dout;end
        default:begin
               r_info_type            <=r_info_type       ;
               r_segm_mark            <=r_segm_mark       ;
               r_info_fram_leng       <=r_info_fram_leng  ;
               r_leng                 <=r_leng            ;
               r_sour_addr            <=r_sour_addr       ;
               r_dest_addr            <=r_dest_addr       ;
               r_info_unit_idenf      <=r_info_unit_idenf ;
               r_info_unit_leng       <=r_info_unit_leng  ;
               r_parm_type            <= r_parm_type;
        end
    endcase
end


always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(i_rst_n == 1'b0)begin
        r_fram_leng_flag <= 1'b0;
    end
    else if(r_state == R_REND)begin
        r_fram_leng_flag <= 1'b0;
    end
    else if(r_rd_cnt==16'd4)begin
         r_fram_leng_flag <= 1'b1;
    end
    else begin
        r_fram_leng_flag <= r_fram_leng_flag;
    end
    end

assign o_1to8_data = w_ram_dout;
assign o_1to8_valid = r_data_valid;

//-----------------------CRC_CAMP
always @(posedge i_clk163m84 )begin
    r_data_crc_valid1 <=i_data_crc_valid;
    r_data_crc_valid2 <= r_data_crc_valid1;
end

always @(posedge i_clk163m84)begin
    data_crc_r1 <= i_data_crc;
    data_crc_r2 <= data_crc_r1;
    data_crc_r3 <= data_crc_r2;
end

always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(i_rst_n ==1'b0)begin
        r_crc_ok <= 1'b0;
        r_crc_err <= 1'b0;
    end
    else if(!r_data_crc_valid1 && r_data_crc_valid2)begin
        if(data_crc_r2 == r_rec_crc)begin
           r_crc_ok <= 1'b1;
           r_crc_err <= 1'b0;
        end
        else begin
           r_crc_ok <= 1'b0;
           r_crc_err <= 1'b1;
        end
    end
    else begin
        r_crc_ok <= 1'b0;
        r_crc_err <= 1'b0;
    end
end


    assign  o_crc_ok    = r_crc_ok;
    assign  o_rd_cnt    = r_rd_cnt;
    assign  o_para_type = r_parm_type;
    assign  o_ram_in    = w_ram_dout;
    
    
    
    
    
endmodule
