`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/18 10:33:46
// Design Name: 
// Module Name: Top_sim
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


module Top_sim();

    localparam                          US_CHANNEL                = 6     ;
    // 0x12 0x13 0x14 0x15 0x16 0x1d
    // 0    1    2    3    4    5
    localparam                          TOTAL_NUM                 = 114   ;
    localparam                          ZX_CHANNEL                = 2     ;


    integer                             us_channel                 ;
    reg                [ 127: 0]        msg_header                 ;
    integer                             pkg_num                    ;
    integer                             i,j                        ;




    reg                                 sys_clk_i                  ;
    reg                                 time_period_25ms_pluse     ;
    reg                                 rst_n_i                    ;
    
    wire               [{US_CHANNEL+ZX_CHANNEL}-1: 0]rd_clk_o      ;
    wire               [{US_CHANNEL+ZX_CHANNEL}-1: 0]rd_en_o       ;
    reg                [{US_CHANNEL+ZX_CHANNEL}*128-1: 0]rd_din_i='d0  ;
    reg                [{US_CHANNEL+ZX_CHANNEL}-1: 0]rd_empty_i  =-1;

    wire               [ZX_CHANNEL-1: 0]zx_us_rd_clk               ;
    wire               [ZX_CHANNEL-1: 0]zx_us_rd_en                ;
    wire               [ZX_CHANNEL*128-1: 0]zx_us_rd_dout          ;
    wire               [ZX_CHANNEL-1: 0]zx_us_rd_empty             ;
    wire               [ZX_CHANNEL*8-1: 0]zx_us_prased_src_id_r1   ;
    wire               [ZX_CHANNEL*8-1: 0]zx_us_prased_des_id_r1   ;
    wire               [ZX_CHANNEL*8-1: 0]zx_us_prased_data_type_r1  ;
    wire               [ZX_CHANNEL*8-1: 0]zx_us_prased_data_channel_r1  ;
    wire               [ZX_CHANNEL*16-1: 0]zx_us_prased_data_field_len_r1  ;
    wire               [ZX_CHANNEL-1: 0]zx_us_timming_valid        ;
    wire               [ZX_CHANNEL*128-1: 0]zx_us_timming_data     ;
    wire               [ZX_CHANNEL-1: 0]zx_us_burst_valid          ;
    wire               [ZX_CHANNEL*128-1: 0]zx_us_burst_data       ;

    wire               [ZX_CHANNEL-1: 0]us_burst_rd_en             ;
    wire               [ZX_CHANNEL*128-1: 0]us_burst_dout          ;
    wire               [ZX_CHANNEL-1: 0]us_burst_empty             ;
    wire               [ZX_CHANNEL*12-1: 0]us_burst_cache_count    ;

    wire               [US_CHANNEL-1: 0]us_rd_clk                  ;
    wire               [US_CHANNEL-1: 0]us_rd_en                   ;
    wire               [US_CHANNEL*128-1: 0]us_rd_dout             ;
    wire               [US_CHANNEL-1: 0]us_rd_empty                ;

    wire               [US_CHANNEL*8-1: 0]us_prased_src_id_r1      ;
    wire               [US_CHANNEL*8-1: 0]us_prased_des_id_r1      ;
    wire               [US_CHANNEL*8-1: 0]us_prased_data_type_r1   ;
    wire               [US_CHANNEL*8-1: 0]us_prased_data_channel_r1  ;
    wire               [US_CHANNEL*16-1: 0]us_prased_data_field_len_r1  ;
    wire               [US_CHANNEL-1: 0]us_timming_valid           ;
    wire               [US_CHANNEL*128-1: 0]us_timming_data        ;
    wire               [US_CHANNEL-1: 0]us_burst_valid             ;
    wire               [US_CHANNEL*128-1: 0]us_burst_data          ;

    wire               [TOTAL_NUM-1: 0] us_timming_rd_en           ;
    wire               [TOTAL_NUM*128-1: 0]us_timming_dout         ;
    wire               [TOTAL_NUM-1: 0] us_timming_empty           ;
    wire               [TOTAL_NUM*12-1: 0]us_timming_cache_count   ;

    wire                                us_timming_flow_vld        ;
    wire               [ 127: 0]        us_timming_flow            ;
    reg                                 us_timming_flow_prog_full  ;

initial begin
    sys_clk_i = 0;
    rst_n_i   = 0;
    time_period_25ms_pluse = 0;
    #100
    rst_n_i = 1;
    $monitor($time,,"rd_empty_i = %h",rd_empty_i);
    #200
    us_channel = 0;
    msg_header_compose(
        32'hfdf7_eb90,
        16'h00,
        4'h1,                                                       // msg type
        16'h46,                                                     // frame cnt
        8'h12,                                                      // src
        8'h00,                                                      // des
        8'h01,                                                      // data type
        8'h02,                                                      // data channel
        16'h12                                                      // msg len
    );
    send_full_msg(us_channel);
    #100
    fork
        begin: c0
            
            send_full_msg_ch0();
        end

        begin: c1
            #2
            msg_header_compose(
                32'hfdf7_eb90,
                16'h00,
                4'h1,                                               // msg type
                16'h46,                                             // frame cnt
                8'h13,                                              // src
                8'h00,                                              // des
                8'h01,                                              // data type
                8'h02,                                              // data channel
                16'h12                                              // msg len
            );
            send_full_msg_ch1();
        end

        begin: c2
            #20
            send_full_msg_ch2();
        end

    join

    #500
    time_period_25ms_pluse = 1;
    #10
    time_period_25ms_pluse = 0;
end





// ********************************************************************************** // 
//---------------------------------------------------------------------
// instance
//---------------------------------------------------------------------







// ********************************************************************************** // 
//---------------------------------------------------------------------
// upstream data
//---------------------------------------------------------------------

msg_receive_wrapper#(
    .CHANNEL                            (US_CHANNEL                ) 
)
us_msg_receive_wrapper_inst(
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),

    .rd_en_o                            (rd_en_o[US_CHANNEL-1 :0]  ),
    .rd_din_i                           (rd_din_i[US_CHANNEL*128-1:0]),
    .rd_empty_i                         (rd_empty_i[US_CHANNEL-1 :0]),

    .prased_src_id_r1                   (us_prased_src_id_r1       ),
    .prased_des_id_r1                   (us_prased_des_id_r1       ),
    .prased_data_type_r1                (us_prased_data_type_r1    ),
    .prased_data_channel_r1             (us_prased_data_channel_r1 ),
    .prased_data_field_len_r1           (us_prased_data_field_len_r1),

    .us_timming_valid_o                 (us_timming_valid          ),
    .us_timming_data_o                  (us_timming_data           ),

    .us_burst_valid_o                   (us_burst_valid            ),
    .us_burst_data_o                    (us_burst_data             ) 
);

us_timming_wrapper#(
    .US_CHANNEL                         (US_CHANNEL + ZX_CHANNEL   ),
    .TOTAL_NUM                          (TOTAL_NUM                 ) 
)
us_timming_wrapper_inst(
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),

    .prased_src_id_r1                   ({zx_us_prased_src_id_r1,us_prased_src_id_r1}),
    .prased_des_id_r1                   ({zx_us_prased_des_id_r1,us_prased_des_id_r1}),
    .prased_data_type_r1                ({zx_us_prased_data_type_r1,us_prased_data_type_r1}),
    .prased_data_channel_r1             ({zx_us_prased_data_channel_r1,us_prased_data_channel_r1}),
    .prased_data_field_len_r1           ({zx_us_prased_data_field_len_r1,us_prased_data_field_len_r1}),

    .us_timming_valid_i                 ({zx_us_timming_valid,us_timming_valid}),
    .us_timming_data_i                  ({zx_us_timming_data,us_timming_data}),

    .us_burst_valid_i                   (us_burst_valid            ),
    .us_burst_data_i                    (us_burst_data             ),

    .us_timming_rd_en_i                 (us_timming_rd_en          ),
    .us_timming_dout_o                  (us_timming_dout           ),
    .us_timming_empty_o                 (us_timming_empty          ),
    .us_timming_cache_count_o           (us_timming_cache_count    ) 
);

us_data_forwarding#(
    .TOTAL_NUM                          (TOTAL_NUM                 ) 
)
us_data_forwarding_inst(
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),
    .time25ms_pluse_i                   (time_period_25ms_pluse    ),

    .us_burst_rd_en_o                   (us_burst_rd_en            ),
    .us_burst_dout_i                    (us_burst_dout             ),
    .us_burst_empty_i                   (us_burst_empty            ),
    .us_burst_cache_count_i             (us_burst_cache_count      ),

    .us_timming_rd_en_o                 (us_timming_rd_en          ),
    .us_timming_dout_i                  (us_timming_dout           ),
    .us_timming_empty_i                 (us_timming_empty          ),
    .us_timming_cache_count_i           (us_timming_cache_count    ),

    .us_timming_flow_vld_o              (us_timming_flow_vld       ),
    .us_timming_flow_o                  (us_timming_flow           ),
    .us_timming_flow_prog_full_i        (us_timming_flow_prog_full ) 
);

// ********************************************************************************** // 
//---------------------------------------------------------------------
// ZX data
//---------------------------------------------------------------------
msg_receive_wrapper#(
    .CHANNEL                            (ZX_CHANNEL                ) 
)
zx_us_msg_receive_wrapper_inst(
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),

    .rd_en_o                            (rd_en_o[US_CHANNEL+ZX_CHANNEL-1:US_CHANNEL]),// [1] ZX1, [0] ZX2
    .rd_din_i                           (rd_din_i[(US_CHANNEL+ZX_CHANNEL)*128-1:US_CHANNEL*128]),
    .rd_empty_i                         (rd_empty_i[US_CHANNEL+ZX_CHANNEL-1:US_CHANNEL]),

    .prased_src_id_r1                   (zx_us_prased_src_id_r1    ),
    .prased_des_id_r1                   (zx_us_prased_des_id_r1    ),
    .prased_data_type_r1                (zx_us_prased_data_type_r1 ),
    .prased_data_channel_r1             (zx_us_prased_data_channel_r1),
    .prased_data_field_len_r1           (zx_us_prased_data_field_len_r1),

    .us_timming_valid_o                 (zx_us_timming_valid       ),
    .us_timming_data_o                  (zx_us_timming_data        ),

    .us_burst_valid_o                   (zx_us_burst_valid         ),// [1] ZX1, [0] ZX2
    .us_burst_data_o                    (zx_us_burst_data          ) 
);

zx_us_burst_cache_wrapper#(
    .ZX_CHANNEL                         (ZX_CHANNEL                ) 
)
zx_us_burst_cache_wrapper(
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),

    .zx_us_burst_valid_i                (zx_us_burst_valid         ),
    .zx_us_burst_data_i                 (zx_us_burst_data          ),

    .us_burst_rd_en_i                   (us_burst_rd_en            ),
    .us_burst_dout_o                    (us_burst_dout             ),
    .us_burst_empty_o                   (us_burst_empty            ),
    .us_burst_cache_count_o             (us_burst_cache_count      ) 
);





















always #5  sys_clk_i = ! sys_clk_i ;                                // period 10ns

// ********************************************************************************** // 
//---------------------------------------------------------------------
// task
//---------------------------------------------------------------------
task msg_header_compose;
    input              [  31: 0]        header                     ;
    input              [  15: 0]        frame_len                  ;
    input              [   3: 0]        frame_type                 ;
    input              [  15: 0]        frame_cnt                  ;
    input              [   7: 0]        src_id                     ;
    input              [   7: 0]        des_id                     ;
    input              [   7: 0]        data_type                  ;
    input              [   7: 0]        data_channel               ;
    input              [  15: 0]        vld_data_len               ;
    begin
        msg_header = {header,frame_len,12'h0,frame_type,frame_cnt,src_id,des_id,data_type,data_channel,vld_data_len};
        
        pkg_num = (frame_len + 1) * 4;
    
    end
endtask

task send_o_pkg_data;
    input              [   7: 0]        channel                    ;
    input              [ 127: 0]        msg                        ;
    begin
        #50
        @(posedge sys_clk_i) begin
            rd_empty_i[channel] = 1'd0;
            rd_din_i[128*channel +: 128] = msg;
        end
        @(posedge sys_clk_i)
            rd_empty_i[channel] = 1'd1;
    end
endtask

task send_full_msg;
    input              [   7: 0]        channel                    ;
    integer                             j                          ;
    begin
        $display($time,,"start to send msg !!!");
                for (j = 0; j<pkg_num; j=j+1) begin
                    if (j==0) begin
                        #10
                        send_o_pkg_data(channel,msg_header);
                        $display($time,,"assert !!!");
                    end
                    else begin
                        #20
                        send_o_pkg_data(channel,128'h0102030405060708090a0b0c0e0f);
                    end
                end
        $display($time,,"send msg successfull !!!");
    end
endtask




// ********************************************************************************** // 
//---------------------------------------------------------------------
// 
//---------------------------------------------------------------------
task send_full_msg_ch0;
    integer                             j                          ;
    begin
        $display($time,,"start to send msg !!!");
                for (j = 0; j<pkg_num; j=j+1) begin
                    if (j==0) begin
                        #10
                        send_o_pkg_data_ch0(msg_header);
                        $display($time,,"assert !!!");
                    end
                    else begin
                        #20
                        send_o_pkg_data_ch0(128'h0102030405060708090a0b0c0e0f);
                    end
                end
        $display($time,,"send msg successfull !!!");
    end
endtask

task send_full_msg_ch1;
    integer                             j                          ;
    begin
        $display($time,,"start to send msg !!!");
                for (j = 0; j<pkg_num; j=j+1) begin
                    if (j==0) begin
                        #10
                        send_o_pkg_data_ch1(msg_header);
                        $display($time,,"assert !!!");
                    end
                    else begin
                        #20
                        send_o_pkg_data_ch1(128'h0102030405060708090a0b0c0e0f);
                    end
                end
        $display($time,,"send msg successfull !!!");
    end
endtask

task send_full_msg_ch2;
    integer                             j                          ;
    begin
        $display($time,,"start to send msg !!!");
                for (j = 0; j<pkg_num; j=j+1) begin
                    if (j==0) begin
                        #10
                        send_o_pkg_data_ch2(msg_header);
                        $display($time,,"assert !!!");
                    end
                    else begin
                        #20
                        send_o_pkg_data_ch2(128'h0102030405060708090a0b0c0e0f);
                    end
                end
        $display($time,,"send msg successfull !!!");
    end
endtask

task send_full_msg_ch3;
    integer                             j                          ;
    begin
        $display($time,,"start to send msg !!!");
                for (j = 0; j<pkg_num; j=j+1) begin
                    if (j==0) begin
                        #10
                        send_o_pkg_data_ch3(msg_header);
                        $display($time,,"assert !!!");
                    end
                    else begin
                        #20
                        send_o_pkg_data_ch3(128'h0102030405060708090a0b0c0e0f);
                    end
                end
        $display($time,,"send msg successfull !!!");
    end
endtask

task send_full_msg_ch4;
    integer                             j                          ;
    begin
        $display($time,,"start to send msg !!!");
                for (j = 0; j<pkg_num; j=j+1) begin
                    if (j==0) begin
                        #10
                        send_o_pkg_data_ch4(msg_header);
                        $display($time,,"assert !!!");
                    end
                    else begin
                        #20
                        send_o_pkg_data_ch4(128'h0102030405060708090a0b0c0e0f);
                    end
                end
        $display($time,,"send msg successfull !!!");
    end
endtask

task send_full_msg_ch5;
    integer                             j                          ;
    begin
        $display($time,,"start to send msg !!!");
                for (j = 0; j<pkg_num; j=j+1) begin
                    if (j==0) begin
                        #10
                        send_o_pkg_data_ch5(msg_header);
                        $display($time,,"assert !!!");
                    end
                    else begin
                        #20
                        send_o_pkg_data_ch5(128'h0102030405060708090a0b0c0e0f);
                    end
                end
        $display($time,,"send msg successfull !!!");
    end
endtask
// ********************************************************************************** // 
//---------------------------------------------------------------------
// 
//---------------------------------------------------------------------
task send_o_pkg_data_ch0;
    input              [ 127: 0]        msg                        ;
    reg                [ 127: 0]        msg_intask                 ;
    begin
        msg_intask = msg;
        #50
        @(posedge sys_clk_i) begin
            rd_empty_i[0] = 1'd0;
            rd_din_i[128*0 +: 128] = msg_intask;
        end
        @(posedge sys_clk_i)
            rd_empty_i[0] = 1'd1;
    end
endtask

task send_o_pkg_data_ch1;
    input              [ 127: 0]        msg                        ;
    reg                [ 127: 0]        msg_intask                 ;
    begin
        msg_intask = msg;
        #50
        @(posedge sys_clk_i) begin
            rd_empty_i[1] = 1'd0;
            rd_din_i[128*1 +: 128] = msg_intask;
        end
        @(posedge sys_clk_i)
            rd_empty_i[1] = 1'd1;
    end
endtask

task send_o_pkg_data_ch2;
    input              [ 127: 0]        msg                        ;
    reg                [ 127: 0]        msg_intask                 ;
    begin
        msg_intask = msg;
        #50
        @(posedge sys_clk_i) begin
            rd_empty_i[2] = 1'd0;
            rd_din_i[128*2 +: 128] = msg_intask;
        end
        @(posedge sys_clk_i)
            rd_empty_i[2] = 1'd1;
    end
endtask

task send_o_pkg_data_ch3;
    input              [ 127: 0]        msg                        ;
    reg                [ 127: 0]        msg_intask                 ;
    begin
        msg_intask = msg;
        #50
        @(posedge sys_clk_i) begin
            rd_empty_i[3] = 1'd0;
            rd_din_i[128*3 +: 128] = msg_intask;
        end
        @(posedge sys_clk_i)
            rd_empty_i[3] = 1'd1;
    end
endtask

task send_o_pkg_data_ch4;
    input              [ 127: 0]        msg                        ;
    reg                [ 127: 0]        msg_intask                 ;
    begin
        msg_intask = msg;
        #50
        @(posedge sys_clk_i) begin
            rd_empty_i[4] = 1'd0;
            rd_din_i[128*4 +: 128] = msg_intask;
        end
        @(posedge sys_clk_i)
            rd_empty_i[4] = 1'd1;
    end
endtask

task send_o_pkg_data_ch5;
    input              [ 127: 0]        msg                        ;
    reg                [ 127: 0]        msg_intask                 ;
    begin
        msg_intask = msg;
        #50
        @(posedge sys_clk_i) begin
            rd_empty_i[5] = 1'd0;
            rd_din_i[128*5 +: 128] = msg_intask;
        end
        @(posedge sys_clk_i)
            rd_empty_i[5] = 1'd1;
    end
endtask

endmodule
