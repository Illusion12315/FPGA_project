`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/30 16:52:12
// Design Name: 
// Module Name: Test_sx_data
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


module Test_sx_data();
   reg  clk;
   reg  rst;
initial begin
    clk = 0 ;
    rst = 1;
    #10000
    rst = 0;
end
always #5 clk = ~clk;
    wire[15:0]  channel_mang; 
assign channel_mang = {5'b0,8'hC0,3'h2};
    reg [15:0]  cnt;
    reg         cnt_flag;
    reg [4:0]   state;
    reg         tx_data2_ask_out;
    reg         yw_data_valid;
    reg [7:0]   yw_data      ;
    reg [11:0]  Busi_length;
always @(posedge clk) begin
    if(rst) begin
        cnt <= 'hFFFF;
        cnt_flag <= 'b0;
    end
    else begin
        if(cnt == 'd4999) begin
            cnt <= 'b0;
            cnt_flag <= 'b1;
        end
        else begin
            cnt <= cnt + 'b1;
            cnt_flag <= 'b0;
        end
    end
end
always @(posedge clk) begin     //320 319 321 322  200  640 641 639 
    if(rst) begin
        state <= 'b0;
        yw_data <= 'b0;
        yw_data_valid <= 'b0;
        tx_data2_ask_out <= 'b0;
        Busi_length <= 'b0;
    end
    else begin
        case(state) 
            'd0: begin
                if(cnt_flag) begin
                    state <= 'd1;
                end
            end
            'd1: begin  //321
                Busi_length = 'd321;
                if(cnt_flag) begin
                    state <= 'd2;
                end
                if(cnt >= 'd1000 && cnt < 'd1321) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2328) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd2: begin  //321
                Busi_length = 'd321;
                if(cnt_flag) begin
                    state <= 'd3;
                end
                if(cnt >= 'd1000 && cnt < 'd1321) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2328) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd3: begin  //320
                Busi_length = 'd323;
                if(cnt_flag) begin
                    state <= 'd4;
                end
                if(cnt >= 'd1000 && cnt < 'd1323) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2328) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd4: begin  //320
                Busi_length = 'd320;
                if(cnt_flag) begin
                    state <= 'd5;
                end
                if(cnt >= 'd1000 && cnt < 'd1320) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2328) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd5: begin  //319
                Busi_length = 'd319;
                if(cnt_flag) begin
                    state <= 'd6;
                end
                if(cnt >= 'd1000 && cnt < 'd1319) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2328) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd6: begin  //319
                Busi_length = 'd319;
                if(cnt_flag) begin
                    state <= 'd7;
                end
                if(cnt >= 'd1000 && cnt < 'd1319) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2328) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd7: begin  //640
                Busi_length = 'd640;
                if(cnt_flag) begin
                    state <= 'd8;
                end
                if(cnt >= 'd1000 && cnt < 'd1640) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2655) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd8: begin  //640
                Busi_length = 'd640;
                if(cnt_flag) begin
                    state <= 'd9;
                end
                if(cnt >= 'd1000 && cnt < 'd1640) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2655) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd9: begin  //639
                Busi_length = 'd639;
                if(cnt_flag) begin
                    state <= 'd10;
                end
                if(cnt >= 'd1000 && cnt < 'd1639) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2655) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd10: begin  //639
                Busi_length = 'd639;
                if(cnt_flag) begin
                    state <= 'd11;
                end
                if(cnt >= 'd1000 && cnt < 'd1639) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2655) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd11: begin  //641
                Busi_length = 'd641;
                if(cnt_flag) begin
                    state <= 'd12;
                end
                if(cnt >= 'd1000 && cnt < 'd1641) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2655) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd12: begin  //641
                Busi_length = 'd641;
                if(cnt_flag) begin
                    state <= 'd13;
                end
                if(cnt >= 'd1000 && cnt < 'd1641) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd2000 && cnt < 'd2655) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd13: begin  //1200
                Busi_length = 'd1200;
                if(cnt_flag) begin
                    state <= 'd14;
                end
                if(cnt >= 'd1000 && cnt < 'd2200) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd3000 && cnt < 'd4205) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
            'd14: begin  //1601
                Busi_length = 'd1601;
                if(cnt_flag) begin
                    state <= 'd0;
                end
                if(cnt >= 'd1000 && cnt < 'd2601) begin
                    yw_data <= yw_data + 'b1;
                    yw_data_valid <= 'b1;
                end
                else begin
                    yw_data <= yw_data;
                    yw_data_valid <= 'b0;
                end
                if(cnt >= 'd3000 && cnt < 'd4605) begin 
                    tx_data2_ask_out <= 'b1;
                end
                else begin 
                    tx_data2_ask_out <= 'b0;
                end                
            end
        endcase
    end
end
 sx_data sx_data_inst(
    .clk163m84              (clk),
    .rst_n                  (~rst),
    
    .channel_mang           (channel_mang), 
    .yw_data                (yw_data      ),
    .yw_data_valid          (yw_data_valid),
//    .i_info_type            (w_info_type), 
    
    .tx_data1_length_out    ('d320 ),
    .tx_data1_ask_out       (     ),
    .tx_data2_length_out    ('d320 ),
    .tx_data2_ask_out       (tx_data2_ask_out    ) 
    );
endmodule
