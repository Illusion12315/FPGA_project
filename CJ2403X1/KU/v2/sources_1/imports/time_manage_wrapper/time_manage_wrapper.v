`timescale 1ns / 1ps
// ********************************************************************************** // 
// Company:               
// Engineer:              Chen Xiong Zhi
// 
// File name:             time_manage_wrapper
// Create Date:           2024/06/28 14:32:52
// Version:               V1.0
// PATH:                  C:\Users\Administrator\Desktop\project\CJ2403X1\project\AI2\AI2_top_v1\AI2_top_v1.srcs\sources_1\imports\time_manage_wrapper\time_manage_wrapper.v
// Descriptions:          
// 
// ********************************************************************************** // 
// `default_nettype none
// `define sim_valid


module time_manage_wrapper (
    input  wire                         sys_clk_i                  ,// clk 100m from VPX or osc
    input  wire                         rst_n_i                    ,

    input  wire                         gpio_start_trigger_i       ,

    output reg                          time_period_0_25ms_o       ,// aready sync to clk 100m
    output reg                          time_period_25ms_pluse_o    // aready sync to clk 100m
);

    localparam                          time_1s                   = 100_000_000;

`ifdef sim_valid
    localparam                          time_25ms                 = time_1s / 40_000;
`else
    localparam                          time_25ms                 = time_1s / 40;
`endif

    localparam                          S_IDLE                    = 0     ;
    localparam                          S_RESET                   = 1     ;
    localparam                          S_25MS_COUNT              = 2     ;

    reg                                 gpio_start_trigger_r1,gpio_start_trigger_r2  ;
    reg                [  23: 0]        clk_cnt                    ;
    reg                [   1: 0]        state                      ;

// ********************************************************************************** // 
//---------------------------------------------------------------------
// main code
//---------------------------------------------------------------------

always@(posedge sys_clk_i)begin
    case (state)
        S_RESET: begin
            time_period_0_25ms_o <= 'd1;
            time_period_25ms_pluse_o <= 'd0;
        end
        S_25MS_COUNT: begin
            time_period_0_25ms_o <= 'd0;
            time_period_25ms_pluse_o <= (clk_cnt >= time_25ms - 1);
        end
        default: begin
            time_period_0_25ms_o <= 'd0;
            time_period_25ms_pluse_o <= 'd0;
        end
    endcase
end

always@(posedge sys_clk_i)begin
    gpio_start_trigger_r1 <= gpio_start_trigger_i;
    gpio_start_trigger_r2 <= gpio_start_trigger_r1;
end

always@(posedge sys_clk_i)begin
    if (!rst_n_i)
        state <= S_IDLE;
    else case (state)
        S_IDLE:
            if(gpio_start_trigger_r2)
                state <= S_RESET;
        S_RESET:
            if(clk_cnt == time_25ms - 1)
                state <= S_25MS_COUNT;
        S_25MS_COUNT:
            if(~gpio_start_trigger_r2)
                state <= S_IDLE;
        default:state <= state;
    endcase
end

always@(posedge sys_clk_i)begin
    case (state)
        S_RESET: clk_cnt <= clk_cnt + 'd1;
        S_25MS_COUNT:
            if(clk_cnt >= time_25ms - 1)
                clk_cnt <= 'd0;
            else
                clk_cnt <= clk_cnt + 'd1;
        default: clk_cnt <= 'd0;
    endcase
end

endmodule