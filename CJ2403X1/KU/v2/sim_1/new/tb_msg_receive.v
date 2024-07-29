`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             tb_msg_receive
// Create Date:           2024/06/21 09:45:38
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\KU115\cfg_ku_top_v1\cfg_ku_top_v1.srcs\sim_1\new\tb_msg_receive.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none


module msg_receive_tb;

// Parameters

//Ports
    reg                                 sys_clk_i                  ;
    reg                                 rst_n_i                    ;
    wire                                rd_en_o                    ;
    reg                [ 127: 0]        rd_din_i                   ;
    reg                                 rd_empty_i                 ;
    wire                                prased_valid               ;

    reg                [ 127: 0]        msg_header                 ;


initial begin
    sys_clk_i = 0;
    rst_n_i = 0;
    rd_empty_i = 'd1;
    #100
    rst_n_i = 1;
    #100
    msg_header_compose(
        32'hfdf7_eb90,
        16'h00,
        4'h1,                                                       // msg type
        16'h46,                                                     // frame cnt
        8'h13,                                                      // src
        8'h00,                                                      // des
        8'h01,                                                      // data type
        8'h02,                                                      // data channel
        16'h12                                                      // msg len
    );
    send_o_pkg_data(msg_header);
    #50
    send_o_pkg_data(128'h12345678910111213141516);
    send_o_pkg_data(128'h12345678910111213141516);
    send_o_pkg_data(128'h12345678910111213141516);

    #100
    msg_header_compose(
        32'hfdf7_eb90,
        16'h02,
        4'h1,                                                       // msg type
        16'h46,                                                     // frame cnt
        8'h13,                                                      // src
        8'h00,                                                      // des
        8'h01,                                                      // data type
        8'h02,                                                      // data channel
        16'h26                                                      // msg len
    );
    send_o_pkg_data(msg_header);
    #50
    send_o_pkg_data(128'h12345678910111213141516);
    send_o_pkg_data(128'h12345678910111213141516);
    send_o_pkg_data(128'h12345678910111213141516);
    #50
    send_o_pkg_data(128'h12345678910111213141516);
    send_o_pkg_data(128'h12345678910111213141516);
    send_o_pkg_data(128'h12345678910111213141516);
    send_o_pkg_data(128'h12345678910111213141516);
    #50
    send_o_pkg_data(128'h12345678910111213141516);
    send_o_pkg_data(128'h12345678910111213141516);
    send_o_pkg_data(128'h12345678910111213141516);
    send_o_pkg_data(128'h12345678910111213141516);
end

msg_receive_driver  msg_receive_driver_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),
    .rd_en_o                            (rd_en_o                   ),
    .rd_din_i                           (rd_din_i                  ),
    .rd_empty_i                         (rd_empty_i                )
  );

always #5  sys_clk_i = ! sys_clk_i ;                                // period 10ns

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
    end
endtask

task send_o_pkg_data;
    input              [ 127: 0]        msg                        ;
    begin
        #50
        @(posedge sys_clk_i);
        rd_empty_i = 'd0;
        rd_din_i = msg;
        #10
        rd_empty_i = 'd1;
    end
endtask

endmodule