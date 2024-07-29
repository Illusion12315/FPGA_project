module test_sim_data (
    input                               sys_clk_i                  ,
    input                               rst_n_i                    ,
    input  wire                         guding_ctrl_en_i           ,
    input  wire                         ctrl_en_i                  ,
    input  wire                         yw_en_i                    ,
    input  wire                         circuit_en_i               ,

    input  wire                         in_turn_send_i             ,

    input  wire        [  31:0]         send_period_i              ,//ctrl period. default 1s

    input  wire        [   7:0]         dangwei_N                  ,//C0  C1  C2  C3 C4 C5 C6 C7 CA
                                                                    //320 160 160 80 80 40 40 20 10
    output reg         [   7:0]         s2p_dout_o                 ,
    output reg                          dout_start                  
);
reg                                     guding_ctrl_en             ;
reg                                     ctrl_en                    ;
reg                                     yw_en                      ;
reg                                     circuit_en                 ;

reg                    [   7:0]         rom_guding_ctrl[0:2047]    ;
reg                    [   7:0]         rom_ctrl[0:2047]           ;
reg                    [   7:0]         rom_yw[0:2047]             ;
reg                    [   7:0]         rom_circuit[0:2047]        ;
localparam                              TIME_1s = 163_840_000      ;

integer i;

always@(posedge sys_clk_i)begin
    //sdl + guding_ctrl ----------------------------------------------------------
    rom_guding_ctrl[0] <= 8'hbb;
    rom_guding_ctrl[1] <= 8'h0;
    rom_guding_ctrl[2] <= 8'h07;
    rom_guding_ctrl[3] <= 8'hF9;
    rom_guding_ctrl[4] <= 8'h07;
    rom_guding_ctrl[5] <= 8'hF9;
    //地址
    rom_guding_ctrl[6] <= 8'hff;
    rom_guding_ctrl[7] <= 8'hff;
    rom_guding_ctrl[8] <= 8'hff;
    rom_guding_ctrl[9] <= 8'hff;
    rom_guding_ctrl[10] <= 8'hff;
    rom_guding_ctrl[11] <= 8'hff;

    rom_guding_ctrl[12] <= 8'hff;
    rom_guding_ctrl[13] <= 8'hff;
    rom_guding_ctrl[14] <= 8'hff;
    rom_guding_ctrl[15] <= 8'hff;
    rom_guding_ctrl[16] <= 8'hff;
    rom_guding_ctrl[17] <= 8'hff;
    
    rom_guding_ctrl[18] <= 8'hff;

    rom_guding_ctrl[19] <= 8'hff;

    for (i = 22; i<=2047; i = i+1) begin
        rom_guding_ctrl[i] <= i-19;
    end

    {rom_guding_ctrl[20],rom_guding_ctrl[21]} <= {5'd9,dangwei_N,3'd1};
    //sdl + ctrl ----------------------------------------------------------
    rom_ctrl[0] <= 8'hbb;
    rom_ctrl[1] <= 8'h0;
    rom_ctrl[2] <= 8'h07;
    rom_ctrl[3] <= 8'hF9;
    rom_ctrl[4] <= 8'h07;
    rom_ctrl[5] <= 8'hF9;
    //地址
    rom_ctrl[6] <= 8'hff;
    rom_ctrl[7] <= 8'hff;
    rom_ctrl[8] <= 8'hff;
    rom_ctrl[9] <= 8'hff;
    rom_ctrl[10] <= 8'hff;
    rom_ctrl[11] <= 8'hff;

    rom_ctrl[12] <= 8'hff;
    rom_ctrl[13] <= 8'hff;
    rom_ctrl[14] <= 8'hff;
    rom_ctrl[15] <= 8'hff;
    rom_ctrl[16] <= 8'hff;
    rom_ctrl[17] <= 8'hff;
    
    rom_ctrl[18] <= 8'hff;

    rom_ctrl[19] <= 8'hff;
    for (i = 22; i<=2047; i = i+1) begin
        rom_ctrl[i] <= i-20;
    end

    {rom_ctrl[20],rom_ctrl[21]} <= {5'd9,dangwei_N,3'd2};
    //sdl + yw ------------------------------------------------------------
    rom_yw[0] <= 8'hbb;
    rom_yw[1] <= 8'h0;
    rom_yw[2] <= 8'h07;
    rom_yw[3] <= 8'hF9;
    rom_yw[4] <= 8'h07;
    rom_yw[5] <= 8'hF9;
    //地址
    rom_yw[6] <= 8'hff;
    rom_yw[7] <= 8'hff;
    rom_yw[8] <= 8'hff;
    rom_yw[9] <= 8'hff;
    rom_yw[10] <= 8'hff;
    rom_yw[11] <= 8'hff;

    rom_yw[12] <= 8'hff;
    rom_yw[13] <= 8'hff;
    rom_yw[14] <= 8'hff;
    rom_yw[15] <= 8'hff;
    rom_yw[16] <= 8'hff;
    rom_yw[17] <= 8'hff;
    
    rom_yw[18] <= 8'hff;

    rom_yw[19] <= 8'hff;

    for (i = 22; i<=2047; i = i+1) begin
        rom_yw[i] <= i-21;
    end

    {rom_yw[20],rom_yw[21]} <= {5'd9,dangwei_N,3'd3};
    //circuit ------------------------------------------------------------
    rom_circuit[0] <= 8'hbd;
    rom_circuit[1] <= 8'h0;
    rom_circuit[2] <= 8'h07;
    rom_circuit[3] <= 8'hF9;
    rom_circuit[4] <= 8'h07;
    rom_circuit[5] <= 8'hF9;
    //地址
    rom_circuit[6] <= 8'hff;
    rom_circuit[7] <= 8'hff;
    rom_circuit[8] <= 8'hff;
    rom_circuit[9] <= 8'hff;
    rom_circuit[10] <= 8'hff;
    rom_circuit[11] <= 8'hff;

    rom_circuit[12] <= 8'hff;
    rom_circuit[13] <= 8'hff;
    rom_circuit[14] <= 8'hff;
    rom_circuit[15] <= 8'hff;
    rom_circuit[16] <= 8'hff;
    rom_circuit[17] <= 8'hff;
    
    rom_circuit[18] <= 8'hff;

    rom_circuit[19] <= 8'hff;

    for (i = 22; i<=2047; i = i+1) begin
        rom_circuit[i] <= i-22;
    end
    {rom_circuit[20],rom_circuit[21]} <= {5'd9,dangwei_N,3'd3};
end


initial begin
    //sdl + guding_ctrl
    //sdl + ctrl
    //sdl + yw
    //circuit 
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// guding kongzhi
//---------------------------------------------------------------------
reg                                     guding_ctrl_start_flag     ;
reg                                     guding_ctrl_work_en        ;
reg                    [  10:0]         guding_ctrl_cnt            ;

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        guding_ctrl_work_en<='d0;
    else if (guding_ctrl_cnt == 2047) begin
        guding_ctrl_work_en<='d0;
    end
    else if (guding_ctrl_start_flag) begin
        guding_ctrl_work_en<='d1;
    end
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        guding_ctrl_cnt<='d0;
    else if (guding_ctrl_work_en) begin
        guding_ctrl_cnt<=guding_ctrl_cnt+'d1;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// kongzhi sdl
//---------------------------------------------------------------------
reg                                     ctrl_start_flag            ;
reg                                     ctrl_work_en               ;
reg                    [  10:0]         ctrl_cnt                   ;

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        ctrl_work_en<='d0;
    else if (ctrl_cnt == 2047) begin
        ctrl_work_en<='d0;
    end
    else if (ctrl_start_flag) begin
        ctrl_work_en<='d1;
    end
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        ctrl_cnt<='d0;
    else if (ctrl_work_en) begin
        ctrl_cnt<=ctrl_cnt+'d1;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// yw sdl
//---------------------------------------------------------------------
reg                                     yw_start_flag              ;
reg                                     yw_work_en                 ;
reg                    [  10:0]         yw_cnt                     ;

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        yw_work_en<='d0;
    else if (yw_cnt == 2047) begin
        yw_work_en<='d0;
    end
    else if (yw_start_flag) begin
        yw_work_en<='d1;
    end
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        yw_cnt<='d0;
    else if (yw_work_en) begin
        yw_cnt<=yw_cnt+'d1;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// dianlu
//---------------------------------------------------------------------
reg                                     circuit_start_flag         ;
reg                                     circuit_work_en            ;
reg                    [  10:0]         circuit_cnt                ;

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        circuit_work_en<='d0;
    else if (circuit_cnt == 2047) begin
        circuit_work_en<='d0;
    end
    else if (circuit_start_flag) begin
        circuit_work_en<='d1;
    end
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)
        circuit_cnt<='d0;
    else if (circuit_work_en) begin
        circuit_cnt<=circuit_cnt+'d1;
    end
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// period_ctrl
//---------------------------------------------------------------------
reg                    [   1:0]         in_turn_cnt                ;
reg                    [  31:0]         period_cnt                 ;

//轮询
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        guding_ctrl_en<='d0;
        ctrl_en<='d0;
        yw_en<='d0;
        circuit_en<='d0;
    end
    else if (in_turn_send_i) begin
        case (in_turn_cnt)
            0: {yw_en,circuit_en,ctrl_en,guding_ctrl_en} <= 4'b1000;
            1: {yw_en,circuit_en,ctrl_en,guding_ctrl_en} <= 4'b0100;
            2: {yw_en,circuit_en,ctrl_en,guding_ctrl_en} <= 4'b0010;
            default: {yw_en,circuit_en,ctrl_en,guding_ctrl_en} <= 4'b0001;
        endcase
    end
    else begin
        guding_ctrl_en<=guding_ctrl_en_i;
        ctrl_en<=ctrl_en_i;
        yw_en<=yw_en_i;
        circuit_en<=circuit_en_i;
    end
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        period_cnt<='d0;
        in_turn_cnt<='d0;
    end
    else if (period_cnt >= TIME_1s)begin
        period_cnt<='d0;
        in_turn_cnt<=in_turn_cnt+'d1;
    end
    else begin
        period_cnt<=period_cnt+'d1;
    end
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        guding_ctrl_start_flag<='d0;
        ctrl_start_flag<='d0;
        yw_start_flag<='d0;
        circuit_start_flag<='d0;
    end
    else case ({guding_ctrl_en,ctrl_en,yw_en,circuit_en})
        4'b1000: begin
            ctrl_start_flag<='d0;
            yw_start_flag<='d0;
            circuit_start_flag<='d0;
            if (period_cnt == send_period_i) begin
                guding_ctrl_start_flag<='d1;
            end
            else
                guding_ctrl_start_flag<='d0;
        end
        4'b0100: begin
            guding_ctrl_start_flag<='d0;
            yw_start_flag<='d0;
            circuit_start_flag<='d0;
            if (period_cnt == send_period_i) begin
                ctrl_start_flag<='d1;
            end
            else
                ctrl_start_flag<='d0;
        end
        4'b0010: begin
            guding_ctrl_start_flag<='d0;
            ctrl_start_flag<='d0;
            circuit_start_flag<='d0;
            if (period_cnt == send_period_i) begin
                yw_start_flag<='d1;
            end
            else
                yw_start_flag<='d0;
        end
        4'b0001: begin
            guding_ctrl_start_flag<='d0;
            yw_start_flag<='d0;
            ctrl_start_flag<='d0;
            if (period_cnt == send_period_i) begin
                circuit_start_flag<='d1;
            end
            else
                circuit_start_flag<='d0;
        end
        default:begin
            guding_ctrl_start_flag<='d0;
            ctrl_start_flag<='d0;
            yw_start_flag<='d0;
            circuit_start_flag<='d0;
        end
    endcase
end
// ********************************************************************************** // 
//---------------------------------------------------------------------
// choose
//---------------------------------------------------------------------
always@(posedge sys_clk_i or negedge rst_n_i)begin
    if(!rst_n_i)begin
        dout_start<='d0;
        s2p_dout_o<='d0;
    end
    else case ({guding_ctrl_work_en,ctrl_work_en,yw_work_en,circuit_work_en})
        4'b1000: begin
            dout_start<='d1;
            s2p_dout_o<=rom_guding_ctrl[guding_ctrl_cnt];
        end
        4'b0100: begin
            dout_start<='d1;
            s2p_dout_o<=rom_ctrl[ctrl_cnt];
        end
        4'b0010: begin
            dout_start<='d1;
            s2p_dout_o<=rom_yw[yw_cnt];
        end
        4'b0001: begin
            dout_start<='d1;
            s2p_dout_o<=rom_circuit[circuit_cnt];
        end
        default: begin
            dout_start<='d0;
            s2p_dout_o<='d0;
        end
    endcase
end
endmodule