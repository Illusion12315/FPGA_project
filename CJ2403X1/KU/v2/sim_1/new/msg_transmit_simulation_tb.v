`timescale 1ns/1ns
module msg_transmit_simulation_tb;

    // Parameters

    //Ports
    reg                                 sys_clk_i                  ;
    reg                                 rst_n_i                    ;
    reg                                 msg_sim_en                 ;
    wire                                msg_sim_done_pluse         ;
    reg                [  31: 0]        sim_frame_header           ;
    reg                [  15: 0]        sim_frame_len              ;
    reg                [   3: 0]        sim_frame_type             ;
    reg                [  15: 0]        sim_frame_cnt              ;
    reg                [   7: 0]        sim_src_id                 ;
    reg                [   7: 0]        sim_des_id                 ;
    reg                [   7: 0]        sim_data_type              ;
    reg                [   7: 0]        sim_data_channel           ;
    reg                [  15: 0]        sim_data_field_len         ;
    wire                                msg_sim_vld_o              ;
    wire               [ 127: 0]        msg_sim_data_o             ;

initial begin
    sys_clk_i = 0;
    rst_n_i = 0;
    msg_sim_en = 0;

    sim_frame_header = 32'hfdf7eb90;
    sim_frame_len = 'h00;
    sim_frame_type = 'h2;
    sim_frame_cnt = 16'h1234;
    sim_src_id = 8'h14;
    sim_des_id = 8'h25;
    sim_data_type = 8'h25;
    sim_data_channel = 8'h14;
    sim_data_field_len = 'd12;


    # 100
    rst_n_i = 1;
    # 100
    msg_sim_en = 1;
    #200
    $stop;
end


msg_transmit_simulation  msg_transmit_simulation_inst (
    .sys_clk_i                          (sys_clk_i                 ),
    .rst_n_i                            (rst_n_i                   ),
    .msg_sim_en_i                       (msg_sim_en                ),
    .msg_state_done_pluse_o             (msg_sim_done_pluse        ),
    .sim_frame_header                   (sim_frame_header          ),
    .sim_frame_len                      (sim_frame_len             ),
    .sim_frame_type                     (sim_frame_type            ),
    .sim_frame_cnt                      (sim_frame_cnt             ),
    .sim_src_id                         (sim_src_id                ),
    .sim_des_id                         (sim_des_id                ),
    .sim_data_type                      (sim_data_type             ),
    .sim_data_channel                   (sim_data_channel          ),
    .sim_data_field_len                 (sim_data_field_len        ),
    .msg_sim_vld_o                      (msg_sim_vld_o             ),
    .msg_sim_data_o                     (msg_sim_data_o            ) 
);

always #5  sys_clk_i = ! sys_clk_i ;

endmodule