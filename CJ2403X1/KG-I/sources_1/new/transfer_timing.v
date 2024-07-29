`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/12 09:23:44
// Design Name: 
// Module Name: transfer_timing
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


module transfer_timing(
	input                                    sys_clk_100m,
	input                                    rst_n_i,
	// input                                 internal_sw_srst_n,
	input              [19:0]                gpio_switch,
	input                                    adc_acq_start_pluse,//它只有一个周期
    output  reg       [15: 0]                wr_dout_o,   
	output  reg                              wr_en_o                              
    );

localparam                          S_IDLE                      = 0     ;
localparam                          S_GATHER                    = 1     ;



reg    [3:0]    data_cnt;	
reg    [2:0]    state;

always@(posedge sys_clk_100m or negedge rst_n_i)begin
    if(!rst_n_i)
        state <= S_IDLE;
    else case(state)
        S_IDLE:
            if(adc_acq_start_pluse)
                state <= S_GATHER;
        S_GATHER:
            if(data_cnt == 'd9)
                state <= S_IDLE;
        default:state<=state;
    endcase
end

always@(posedge sys_clk_100m or negedge rst_n_i)begin
    if(!rst_n_i)
       data_cnt<='d0;
    else case(state)
       S_GATHER:data_cnt<=data_cnt+'d1;
       default:data_cnt<='d0;
    endcase
end

always@(posedge sys_clk_100m or negedge rst_n_i)begin
    if (!rst_n_i) begin
        wr_en_o <= 'd0;
        wr_dout_o <= 'd0;
    end
    else case (state)
        S_GATHER: begin
            wr_en_o <= 'd1;
            case (data_cnt)
                0: wr_dout_o <= {7'b0, gpio_switch[0 ], 7'b0, gpio_switch[1 ]};
                1: wr_dout_o <= {7'b0, gpio_switch[2 ], 7'b0, gpio_switch[3 ]};
                2: wr_dout_o <= {7'b0, gpio_switch[4 ], 7'b0, gpio_switch[5 ]};
                3: wr_dout_o <= {7'b0, gpio_switch[6 ], 7'b0, gpio_switch[7 ]};
                4: wr_dout_o <= {7'b0, gpio_switch[8 ], 7'b0, gpio_switch[9 ]};
                5: wr_dout_o <= {7'b0, gpio_switch[10], 7'b0, gpio_switch[11]};
                6: wr_dout_o <= {7'b0, gpio_switch[12], 7'b0, gpio_switch[13]};
                7: wr_dout_o <= {7'b0, gpio_switch[14], 7'b0, gpio_switch[15]};
                8: wr_dout_o <= {7'b0, gpio_switch[16], 7'b0, gpio_switch[17]};
                9: wr_dout_o <= {7'b0, gpio_switch[18], 7'b0, gpio_switch[19]};
                default: wr_dout_o <= 'd0;
            endcase
        end
        default: begin
            wr_en_o <= 'd0;
            wr_dout_o <= 'd0;
        end
    endcase
end

ila_transfer_timing u_ila_transfer_timing (
	.clk(sys_clk_100m), // input wire clk
	.probe0(gpio_switch), // input wire [19:0]  probe0  
	.probe1(adc_acq_start_pluse), // input wire [0:0]  probe1 
	.probe2(wr_dout_o), // input wire [15:0]  probe2 
	.probe3(wr_en_o), // input wire [0:0]  probe3 
	.probe4(state), // input wire [2:0]  probe4 
	.probe5(data_cnt) // input wire [3:0]  probe5 
	
);



endmodule
