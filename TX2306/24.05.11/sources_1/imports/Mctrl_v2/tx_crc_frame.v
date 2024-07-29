`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/21 15:34:02
// Design Name: 
// Module Name: tx_frame
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


module tx_crc_frame(
    input  wire                         i_clk163m84                ,
    input  wire                         i_rst_n                    ,
    
    input  wire        [   7: 0]        i_data_in                  ,
    input  wire                         i_data_valid               ,

    input              [   7: 0]        info_unit_idenf_i          ,
    
    output reg         [   7: 0]        o_data_out                 ,
    output reg                          o_data_valid                
    );

    parameter                           R_IDLE                    = 4'd0,
                                        R_WAIR                    = 4'd1,
                                        R_READ                    = 4'd2;

    reg                [   3: 0]        r_state                    ;

    reg                [   7: 0]        info_type                  ;
    reg                [   7: 0]        segm_mark                  ;
    reg                [  15: 0]        info_fram_leng             ;
    reg                [  15: 0]        leng                       ;
 
    reg                [  47: 0]        sour_addr                  ;
    reg                [  47: 0]        dest_addr                  ;
    reg                [   7: 0]        info_unit_idenf            ;
    reg                [  15: 0]        info_unit_leng             ;

    reg                                 r_data_valid1,r_data_valid2  ;
    reg                [   7: 0]        r_data_in1,r_data_in2      ;
    reg                [  15: 0]        r_wr_byte                  ;
    reg                [   5: 0]        r_frame_cnt                ;
    reg                [   3: 0]        r_frame_scnt               ;
    reg                                 r_frame_flag               ;
    reg                                 r_rd_en                    ;
    reg                                 r_rd_done                  ;

    wire                                w_wrdone_flag              ;

    wire                                fifo_full                  ;
    wire                                fifo_empty                 ;
    wire                                fifo_wr_en                 ;
    wire                                fifo_rd_en                 ;
    wire               [   7: 0]        fifo_dout                  ;


    assign                              w_wrdone_flag             = r_data_valid2 && !r_data_valid1;




always @(posedge i_clk163m84)begin
    r_data_in1 <= i_data_in;
    r_data_in2 <= r_data_in1;
end
always @(posedge i_clk163m84)begin
    r_data_valid1 <= i_data_valid;
    r_data_valid2 <= r_data_valid1;
end



always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(i_rst_n == 1'b0)begin
        r_wr_byte <= 16'd0;
    end
    else if(r_rd_done==1'b1 )begin
         r_wr_byte <= 16'd0;
    end
    else if(r_data_valid2==1'b1)begin
        r_wr_byte <= r_wr_byte + 1'b1 ;
    end
    else begin
        r_wr_byte <= r_wr_byte;
    end
end

//-----------------------------------fifo deal
    assign                              fifo_wr_en                = r_data_valid2 && !fifo_full;
    assign                              fifo_rd_en                = r_rd_en;

fifo_tx_deal fifo_tx_deal_inst (
    .rst                                (!i_rst_n                  ),// input wire rst
    .wr_clk                             (i_clk163m84               ),// input wire wr_clk
    .rd_clk                             (i_clk163m84               ),// input wire rd_clk
    .din                                (r_data_in2                ),// input wire [7 : 0] din
    .wr_en                              (fifo_wr_en                ),// input wire wr_en
    .rd_en                              (fifo_rd_en                ),// input wire rd_en
    .dout                               (fifo_dout                 ),// output wire [7 : 0] dout
    .full                               (fifo_full                 ),// output wire full
    .empty                              (fifo_empty                ),// output wire empty
    .almost_empty                       (                          ) // output wire almost_empty
);

//-----------------state 
always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(i_rst_n == 1'b0)begin
        r_frame_cnt <= 6'd0;
        r_frame_scnt <=4'd0;
        
        r_frame_flag <= 1'b0;
    end

    else case(r_frame_scnt)
        4'd0:begin
            r_frame_cnt <= 6'd0;
            r_frame_flag <= 1'b0;
            if(w_wrdone_flag==1'b1)begin
                r_frame_scnt <= 4'd1;
            end
            else begin
                r_frame_scnt <= 4'd0;
            end
        end
        4'd1:begin
           
            if(r_frame_cnt == 6'd21)begin
                r_frame_cnt <= 6'd0;
                r_frame_scnt <= 4'd0;
                r_frame_flag <= 1'b0;
            end
            else begin
                r_frame_cnt <= r_frame_cnt + 1'b1;
                r_frame_scnt <= 4'd1;
                r_frame_flag <= 1'b1;
            end
    end
    endcase
end

always @(posedge i_clk163m84 or negedge i_rst_n)begin
    if(i_rst_n ==1'b0)begin
        r_state <= R_IDLE;
        
        r_rd_en  <= 1'b0;
        r_rd_done <= 1'b0;
    end
    
    else case(r_state)
        R_IDLE:begin
            r_rd_en <= 1'b0;
            r_rd_done <= 1'b0;
            if(r_frame_flag==1'b1)begin
                r_state <= R_WAIR;
//                r_rd_en <= 1'b1;
            end
            else begin
                r_state <= R_IDLE;
            end
        end
        R_WAIR:begin
//            r_rd_en <= 1'b0;
             r_rd_done <= 1'b0;
            if(r_frame_cnt== 6'd21)begin
                r_state <= R_READ;
                 r_rd_en <= 1'b1;
            end
            else begin
                r_state <= r_state;
            end
        end
        R_READ:begin
            if(fifo_empty==1'b1)begin
                r_state <= R_IDLE;
                
                 r_rd_en <= 1'b0;
                  r_rd_done <= 1'b1;
            end
            else begin
                r_state <= r_state;
                
                r_rd_en <= 1'b1;
                r_rd_done <= 1'b0;
            end
        end
        default:begin
                r_state <= R_IDLE;
                
                r_rd_en  <= 1'b0;
                r_rd_done <= 1'b0;
        end
    endcase
end

always @(posedge i_clk163m84)begin
    info_type         <= 8'h04;
    segm_mark         <= 8'h00;
    info_fram_leng   <= r_wr_byte + 4'd15;
    leng             <= r_wr_byte + 4'd15;
    
    sour_addr         <= 48'hFFFF_FFFF_FFFF;
    dest_addr         <= 48'hFFFF_FFFF_FFFF;
    info_unit_idenf   <= info_unit_idenf_i;                         //信息单元标识
    info_unit_leng    <= r_wr_byte;
end

always @(posedge i_clk163m84 or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin

        o_data_valid      <= 1'b0;
        o_data_out        <= 8'd0;
    end
    else if(r_state == R_READ && fifo_empty==1'b0)begin
        o_data_valid      <= fifo_rd_en;
        o_data_out        <= fifo_dout;
    end
    else if(r_frame_flag==1'b1)begin
        o_data_valid     <= 1'b1;
        case(r_frame_cnt)
            6'd1:begin   o_data_out <= info_type[7:0];    end
            6'd2:begin   o_data_out <= segm_mark[7:0];    end
            6'd3:begin   o_data_out <= info_fram_leng[15:8];    end
            6'd4:begin   o_data_out <= info_fram_leng[7:0];    end
            6'd5:begin   o_data_out <= leng[15:8];     end
            6'd6:begin   o_data_out <= leng[7:0];      end
            
            6'd7:begin   o_data_out <= sour_addr[47:40];    end
            6'd8:begin   o_data_out <= sour_addr[39:32];    end
            6'd9:begin   o_data_out <= sour_addr[31:24];    end
            6'd10:begin   o_data_out <= sour_addr[23:16];    end
            6'd11:begin   o_data_out <= sour_addr[15:8];     end
            6'd12:begin   o_data_out <= sour_addr[7:0];      end
            6'd13:begin   o_data_out <= dest_addr[47:40];    end
            6'd14:begin   o_data_out <= dest_addr[39:32];    end
            6'd15:begin   o_data_out <= dest_addr[31:24];    end
            6'd16:begin  o_data_out <= dest_addr[23:16];    end
            6'd17:begin  o_data_out <= dest_addr[15:8];     end
            6'd18:begin  o_data_out <= dest_addr[7:0];      end
            6'd19:begin  o_data_out <= info_unit_idenf;     end
            6'd20:begin  o_data_out <= info_unit_leng[15:8];end
            6'd21:begin  o_data_out <= info_unit_leng[7:0]; end
            
            default:begin o_data_out <= o_data_out;         end
        endcase
    end
    else begin
        o_data_valid      <= 1'b0;
        o_data_out        <= 8'd0;
    end
end

//ila_crc_tx ila_crc_tx_inst (
//    .clk                                (i_clk163m84               ),// input wire clk


//    .probe0                             (i_data_in                 ),// input wire [7:0]  probe0  
//    .probe1                             (i_data_valid              ),// input wire [0:0]  probe1 
//    .probe2                             (o_data_out                ),// input wire [7:0]  probe2 
//    .probe3                             (o_data_valid              ),// input wire [0:0]  probe3 
//    .probe4                             (r_state                   ),// input wire [3:0]  probe4 
//    .probe5                             (info_type                 ),// input wire [7:0]  probe5 
//    .probe6                             (segm_mark                 ),// input wire [7:0]  probe6 
//    .probe7                             (info_fram_leng            ),// input wire [15:0]  probe7 
//    .probe8                             (leng                      ),// input wire [15:0]  probe8 
//    .probe9                             (sour_addr                 ),// input wire [47:0]  probe9 
//    .probe10                            (dest_addr                 ),// input wire [47:0]  probe10 
//    .probe11                            (info_unit_idenf           ),// input wire [7:0]  probe11 
//    .probe12                            (info_unit_leng            ),// input wire [15:0]  probe12 
//    .probe13                            (r_wr_byte                 ),// input wire [15:0]  probe13 
//    .probe14                            (r_frame_cnt               ),// input wire [5:0]  probe14 
//    .probe15                            (r_frame_scnt              ),// input wire [3:0]  probe15 
//    .probe16                            (r_frame_flag              ),// input wire [0:0]  probe16 
//    .probe17                            (r_rd_en                   ),// input wire [0:0]  probe17 
//    .probe18                            (r_rd_done                 ),// input wire [0:0]  probe18 
//    .probe19                            (w_wrdone_flag             ) // input wire [0:0]  probe19
//);

endmodule