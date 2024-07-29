`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         ACQNOVA
// Engineer:       Long Lian
// 
// Create Date: 2023/06/14 20:22:21
// Design Name: 
// Module Name: loopback_ctrl_mod
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


module loopback_ctrl_mod
    (
        // Clock and Reset# Interface
        input                                   clk_50m,
        
        // GT Loopback Ctrl
        input                                   loopback_sel,               // "0" 不回环;"1"内回环;
        output                                  loopback_rst,
        output      [2:0]                       loopback_in 
    );
    
    
//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------


//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
    reg                                     loopback_sel_r              =   1'b0;
    reg                                     loopback_sel_r2             =   1'b0;
    reg                                     loopback_rst_r              =   1'b1;
    reg         [2:0]                       loopback_in_r               =   3'b000;
    reg         [3:0]                       loopback_fsm                =   4'd0;
    reg         [31:0]                      loopback_cnt                =   32'd0;
    
    
//---------------------------------------------------------------------  
// Parameter
//---------------------------------------------------------------------  
localparam      time_1ms            =   32'd49_999;


// ********************************************************************************** // 
//---------------------------------------------------------------------
// I/O Connections assignments
//---------------------------------------------------------------------
assign      loopback_rst        =   loopback_rst_r;
assign      loopback_in         =   loopback_in_r;


// ********************************************************************************** // 
//---------------------------------------------------------------------
// Input Register
//---------------------------------------------------------------------
always@(posedge clk_50m)
    begin
        loopback_sel_r  <=  loopback_sel;
        loopback_sel_r2 <=  loopback_sel_r;
    end
    

//  光口协议内回环设置
always@(posedge clk_50m)
    begin
        case(loopback_fsm)
            4'd0:
                begin
                    if(loopback_sel_r2 == loopback_sel_r)begin
                        loopback_fsm    <=  loopback_fsm;
                    end else begin
                        loopback_fsm    <=  4'd1;
                    end
                end
            4'd1:
                begin
                    if(loopback_sel_r2) begin
                        loopback_fsm    <=  4'd2;
                    end else begin
                        loopback_fsm    <=  4'd3;
                    end
                end
            4'd2, 4'd3:
                begin   loopback_fsm    <=  4'd4;   end
            4'd4:
                begin
                    if(loopback_cnt == time_1ms) begin
                        loopback_fsm    <=  4'd5;                                
                    end else begin
                        loopback_fsm    <=  loopback_fsm;                                
                    end
                end 
            4'd5:
                begin   loopback_fsm    <=  4'd0;   end
            default:
                begin   loopback_fsm    <=  4'd0;   end
        endcase
    end

always@(posedge clk_50m)
    begin
        case(loopback_fsm)
            4'd4:       begin   loopback_cnt    <=  loopback_cnt + 32'd1;   end
            default:    begin   loopback_cnt    <=  32'd0;                  end
        endcase
    end

always@(posedge clk_50m)
    begin
        case(loopback_fsm)
            4'd4:       begin   loopback_rst_r  <=  1'b1;   end
            default:    begin   loopback_rst_r  <=  1'b0;   end
        endcase
    end

always@(posedge clk_50m)
    begin
        case(loopback_fsm)
            4'd2:       begin   loopback_in_r   <=  3'b010;         end
            4'd3:       begin   loopback_in_r   <=  3'b000;         end
            default:    begin   loopback_in_r   <=  loopback_in_r;  end
        endcase
    end    
    

// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//--------------------------------------------------------------------- 

    
endmodule
