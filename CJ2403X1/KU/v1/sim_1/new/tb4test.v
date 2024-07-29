`timescale 1ns/1ns

module tb4test ();

    localparam                          US_CHANNEL                = 6     ;
    reg                                 sys_clk_i                  ;
    reg                                 rst_n_i                    ;

    reg                [  47: 0]        msg_header                 ;
    reg                [  31: 0]        pkg_num                    ;


    reg                [US_CHANNEL*128-1: 0]rd_din_i             ='d0;
    reg                [US_CHANNEL-1: 0]rd_empty_i               =-1;


initial begin
    sys_clk_i = 0;
    #100
    msg_header_compose(32'hfdf7eb90,16'h00);
    fork
        begin
            send_full_msg0(0);
        end
        
        send_full_msg1(1);
        
        // send_full_msg(2);

    join
end


always # 5 sys_clk_i = ~sys_clk_i;


task msg_header_compose;
    input              [  31: 0]        header                     ;
    input              [  15: 0]        frame_len                  ;
    begin
        msg_header = {header,frame_len};
        
        pkg_num = (frame_len + 1) * 4;
    end
endtask


task send_o_pkg_data;
    input              [   7: 0]        channel_num                ;
    input              [  47: 0]        msg                        ;
    begin
        @(posedge sys_clk_i) begin
            rd_empty_i[channel_num] = 1'd0;
            rd_din_i[128*channel_num +: 128] = msg;
        end
        @(posedge sys_clk_i)
            rd_empty_i[channel_num] = 1'd1;
    end
endtask

task send_full_msg0;
    input              [   7: 0]        channel_num                ;
    integer                             j                          ;
    begin
        $display($time,,"start to send msg !!!");
        for (j = 0; j<pkg_num; j=j+1) begin
            if (j==0) begin
                send_o_pkg_data0(msg_header);
                $display($time,,"assert !!!");
            end
            else begin
                send_o_pkg_data0(128'h0102030405060708090a0b0c0e0f);
            end
        end
        $display($time,,"send msg successfull !!!");
    end
endtask

task send_full_msg1;
    input              [   7: 0]        channel_num                ;
    integer                             j                          ;
    begin
        $display($time,,"start to send msg !!!");
        for (j = 0; j<pkg_num; j=j+1) begin
            if (j==0) begin
                send_o_pkg_data1(msg_header);
                $display($time,,"assert !!!");
            end
            else begin
                send_o_pkg_data1(128'h0102030405060708090a0b0c0e0f);
            end
        end
        $display($time,,"send msg successfull !!!");
    end
endtask

task send_o_pkg_data0;
    input              [  47: 0]        msg                        ;
    begin
        @(posedge sys_clk_i) begin
            rd_empty_i[0] = 1'd0;
            rd_din_i[128*0 +: 128] = msg;
        end
        @(posedge sys_clk_i)
            rd_empty_i[0] = 1'd1;
    end
endtask

task send_o_pkg_data1;
    input              [  47: 0]        msg                        ;
    begin
        @(posedge sys_clk_i) begin
            rd_empty_i[1] = 1'd0;
            rd_din_i[128*1 +: 128] = msg;
        end
        @(posedge sys_clk_i)
            rd_empty_i[1] = 1'd1;
    end
endtask
endmodule