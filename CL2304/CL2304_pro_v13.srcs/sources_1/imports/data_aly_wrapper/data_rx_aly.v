`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     ACQNOVA
// Engineer:    Long Lian
// 
// Create Date: 2020/11/30 11:30:43
// Design Name: 
// Module Name: data_rx_aly
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


module data_rx_aly
    # (
    parameter                           WR_DATA_WIDTH              =   128,
    parameter                           RD_DATA_WIDTH              =   256 
    )
    
    (
        // Clock and Reset# Interface
    input                               log_clk                    ,// Logic Clock, Rising Edge
    input                               log_rst_n                  ,// Logic Reset, Low Active 

        // Data Path Select
    input                               record_en                  ,// '1' Enable Record
    input                               sim_data_en                ,// '1' Enable Sim
        
        // Data Path Ctrl
    input                               record_ch                  ,
    input              [   7:0]         channel_flag               ,

        // Status Signals
    output                              record_full_flag           ,
    output             [  31:0]         data_rate                  ,

        // RX Interface 
    input                               rx_valid                   ,
    input              [WR_DATA_WIDTH-1:0]rx_data                    ,
        
        // FIFO Interface for Analysis Receive
    input                               fifo_rdclk_aly_rx          ,// Read Clock         
    input                               fifo_rdreq_aly_rx          ,// fifo read request
    output             [RD_DATA_WIDTH-1:0]fifo_q_aly_rx              ,// fifo read data
    output                              fifo_empty_aly_rx           // fifo empty 
    );


//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
wire                                    sys_rst_n                  ;
    // FIFO Interface for Analysis Transmit
wire                                    fifo_wrreq_aly_rx          ;
wire                   [WR_DATA_WIDTH-1:0]fifo_data_aly_rx           ;
wire                                    fifo_prog_full_aly_rx      ;
    

//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
reg                                     log_rst_n_r         =   1'b0;
reg                                     log_rst_n_r2        =   1'b0;
    // Data Path Select
reg                                     record_en_r         =   1'b0;
reg                                     record_en_r2        =   1'b0;
reg                                     sim_data_en_r       =   1'b0;
reg                                     sim_data_en_r2      =   1'b0;
    // Data Path Ctrl
reg                                     record_ch_r         =   1'b0;
reg                                     record_ch_r2        =   1'b0;
reg                    [   7:0]         channel_flag_r      =   8'd0;
reg                    [   7:0]         channel_flag_r2     =   8'd0;
    // Data Interface for Aurora RX 
reg                                     rx_valid_r          =   1'b0;
reg                                     rx_valid_r2         =   1'b0;
reg                    [WR_DATA_WIDTH-1:0]rx_data_r           =   {WR_DATA_WIDTH{1'b0}};
reg                    [WR_DATA_WIDTH-1:0]rx_data_r2          =   {WR_DATA_WIDTH{1'b0}};
    // Data Anaylsis States
reg                    [   3:0]         rx_aly_fsm          =   4'h0;
reg                    [  31:0]         rx_aly_cnt          =   32'd0;
reg                                     rx_aly_wrreq        =   1'b0;
reg                    [WR_DATA_WIDTH-1:0]rx_aly_data         =   {WR_DATA_WIDTH{1'b0}};
    // Sim Data
reg                                     sim_en              =   1'b0;
reg                    [  55:0]         sim_cnt             =   56'd0;
    

//---------------------------------------------------------------------  
// Parameter
//---------------------------------------------------------------------   
localparam                              rx_aly_init                 =   4'h0;
localparam                              rx_aly_idle                 =   4'h1;
localparam                              rx_aly_record               =   4'h2;
localparam                              rx_sim_data                 =   4'h3;
localparam                              rx_add_zero                 =   4'h4;


// ********************************************************************************** // 
//---------------------------------------------------------------------
// I/O Connections assignments
//---------------------------------------------------------------------    
assign          sys_rst_n               =   log_rst_n_r2;


// ********************************************************************************** // 
//---------------------------------------------------------------------
//  Input Register
//---------------------------------------------------------------------
always@(posedge log_clk)
    begin
        log_rst_n_r     <=  log_rst_n;
        log_rst_n_r2    <=  log_rst_n_r;
    end

always@(posedge log_clk)
    begin
        record_en_r     <=  record_en;
        record_en_r2    <=  record_en_r;
    end

always@(posedge log_clk)
    begin
        sim_data_en_r   <=  sim_data_en;
        sim_data_en_r2  <=  sim_data_en_r;
    end
        
always@(posedge log_clk)
    begin
        record_ch_r     <=  record_ch;
        record_ch_r2    <=  record_ch_r;
    end
    
always@(posedge log_clk)
    begin
        channel_flag_r  <=  channel_flag;
        channel_flag_r2 <=  channel_flag_r;
    end
    
always@(posedge log_clk)
    begin
        rx_valid_r      <=  rx_valid;
        rx_valid_r2     <=  rx_valid_r;
    end

always@(posedge log_clk)
    begin
        rx_data_r       <=  rx_data;
        rx_data_r2      <=  rx_data_r;
    end


// ********************************************************************************** // 
//--------------------------------------------------------------------- 
//  Data Anaylsis States
//---------------------------------------------------------------------
always@(posedge log_clk or negedge sys_rst_n)
    begin
        if(!sys_rst_n) begin
            rx_aly_fsm  <=  rx_aly_init;
        end else begin
            case(rx_aly_fsm)
                rx_aly_init:
                    begin
                        if(rx_aly_cnt == 32'd50) begin
                            rx_aly_fsm  <=  rx_aly_idle;
                        end else begin
                            rx_aly_fsm  <=  rx_aly_fsm;
                        end
                    end

                rx_aly_idle:
                    begin
                        if(record_en_r2 && record_ch_r2) begin
                            rx_aly_fsm  <=  rx_aly_record;
                        end else begin
                            rx_aly_fsm  <=  rx_aly_fsm;
                        end
                    end
                
                rx_aly_record:
                    begin
                        if(record_en_r2 && record_ch_r2 && sim_data_en_r2) begin
                            rx_aly_fsm  <=  rx_sim_data;
                        end else if(record_en_r2 && record_ch_r2)begin
                            rx_aly_fsm  <=  rx_aly_fsm;
                        end else begin
                            rx_aly_fsm  <=  rx_add_zero;
                        end
                    end
                    
                rx_sim_data:
                    begin
                        if(record_en_r2 && record_ch_r2 && sim_data_en_r2) begin
                            rx_aly_fsm  <=  rx_aly_fsm;
                        end else begin
                            rx_aly_fsm  <=  rx_add_zero;
                        end
                    end
                    
                rx_add_zero:
                    begin
                        if(rx_aly_cnt > 32'd524288) begin           //  >16MB
                            rx_aly_fsm  <=  rx_aly_fsm;
                        end else begin
                            rx_aly_fsm  <=  rx_aly_init;
                        end
                    end
                    
                default:
                    begin
                        rx_aly_fsm  <=  rx_aly_init;
                    end
            endcase
        end
    end

always@(posedge log_clk or negedge sys_rst_n)
    begin
        if(!sys_rst_n) begin
            rx_aly_cnt  <=  32'd0;
        end else begin
            case(rx_aly_fsm)
                rx_aly_init:
                    begin
                        rx_aly_cnt  <=  rx_aly_cnt + 32'd1;
                    end
                rx_add_zero:
                    begin
                        if(!fifo_prog_full_aly_rx) begin
                            rx_aly_cnt  <=  rx_aly_cnt + 32'd1;
                        end else begin
                            rx_aly_cnt  <=  rx_aly_cnt;
                        end
                    end
                rx_aly_idle, rx_aly_record, rx_sim_data:
                    begin
                        rx_aly_cnt  <=  32'd0;
                    end
                default:
                    begin
                        rx_aly_cnt  <=  32'd0;
                    end
            endcase
        end
    end
    
always@(posedge log_clk or negedge sys_rst_n)
    begin
        if(!sys_rst_n) begin
            sim_en  <=  1'b0;
        end else if((rx_aly_fsm == rx_sim_data) && !fifo_prog_full_aly_rx)begin
            sim_en  <=  1'b1;
        end else begin
            sim_en  <=  1'b0;
        end
    end

always@(posedge log_clk or negedge sys_rst_n)
    begin
        if(!sys_rst_n) begin
            sim_cnt <=  56'd0;
        end else if(sim_en)begin
//            sim_cnt <=  sim_cnt + 56'd4;
            sim_cnt <=  sim_cnt + 56'd2;
        end else begin
            sim_cnt <=  sim_cnt;
        end
    end
        
    
// ********************************************************************************** // 
//---------------------------------------------------------------------
//  RX Anaylsis Data to FIFO
//---------------------------------------------------------------------
always@(posedge log_clk or negedge sys_rst_n)
    begin
        if(!sys_rst_n)begin
            rx_aly_wrreq    <=  1'b0;
            rx_aly_data     <=  {WR_DATA_WIDTH{1'b0}};
        end else begin
            case(rx_aly_fsm)
                rx_aly_init, rx_aly_idle:
                    begin
                        rx_aly_wrreq    <=  1'b0;
                        rx_aly_data     <=  {WR_DATA_WIDTH{1'b0}};
                    end
                rx_aly_record:
                    begin
                        rx_aly_wrreq    <=  rx_valid_r2;
                        rx_aly_data     <=  rx_data_r2;
                    end
                    
                rx_sim_data:
                    begin
                        rx_aly_wrreq    <=  sim_en;
                        rx_aly_data     <=  {channel_flag_r2, sim_cnt,
                                             channel_flag_r2, sim_cnt + 1};
//                                             channel_flag_r2, sim_cnt + 2, 
//                                             channel_flag_r2, sim_cnt + 3};
                    end
                    
                rx_add_zero:
                    begin
                        rx_aly_wrreq    <=  1'b1;
                        rx_aly_data     <=  {WR_DATA_WIDTH{1'b0}};
                    end
                    
                default:
                    begin
                        rx_aly_wrreq    <=  1'b0;
                        rx_aly_data     <=  {WR_DATA_WIDTH{1'b0}};
                    end
            endcase
        end
    end

assign      fifo_wrreq_aly_rx   =   rx_aly_wrreq;
assign      fifo_data_aly_rx    =   rx_aly_data;

fifo_rx_aly_256to256                                                //fifo_rx_aly_128to256
    u_rx_fifo
    (
    .rst                               (!sys_rst_n                ),// input wire rst
    .wr_clk                            (log_clk                   ),// input wire wr_clk
    .rd_clk                            (fifo_rdclk_aly_rx         ),// input wire rd_clk
    .din                               (fifo_data_aly_rx          ),// input wire [127 : 0] din
    .wr_en                             (fifo_wrreq_aly_rx         ),// input wire wr_en
    .rd_en                             (fifo_rdreq_aly_rx         ),// input wire rd_en
    .dout                              (fifo_q_aly_rx             ),// output wire [255 : 0] dout
    .full                              (record_full_flag          ),// output wire full
    .empty                             (fifo_empty_aly_rx         ),// output wire empty
    .prog_full                         (fifo_prog_full_aly_rx     ) // output wire prog_full
    );


// ********************************************************************************** // 
//---------------------------------------------------------------------
//  ËÙÂÊ¼ì²â
//---------------------------------------------------------------------
reg                    [  31:0]         data_rate_r         =   32'd0;
reg                    [  31:0]         data_rate_cnt       =   32'd0;
reg                    [  31:0]         time_cnt            =   32'd0;

assign      data_rate   =   data_rate_r;

always@(posedge log_clk or negedge sys_rst_n)
    begin
        if(!sys_rst_n)begin
            data_rate_r     <=  32'd0;
            data_rate_cnt   <=  32'd0;
            time_cnt        <=  32'd0;
        end else if(time_cnt >= 32'd199_999_999)begin
            data_rate_r     <=  data_rate_cnt >> 5;                 //  Unit:KB/s
            data_rate_cnt   <=  32'd0;
            time_cnt        <=  32'd0;
        end else begin
            data_rate_r     <=  data_rate_r;
            time_cnt        <=  time_cnt + 32'd1;
            if(fifo_wrreq_aly_rx)begin
                data_rate_cnt   <=  data_rate_cnt + 32'd1;
            end else begin
                data_rate_cnt   <=  data_rate_cnt;
            end
        end
    end
    

// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//---------------------------------------------------------------------   
ila_rx_aly
    u_ila_rx_aly
    (
    .clk                               (log_clk                   ),// input wire clk
    .probe0                            (record_en_r2              ),// input wire [0:0]  probe0  
    .probe1                            (record_ch_r2              ),// input wire [0:0]  probe1 
    .probe2                            (rx_valid_r2               ),// input wire [0:0]  probe2
    .probe3                            (rx_data_r2                ),// input wire [127:0]  probe3         
    .probe4                            (fifo_wrreq_aly_rx         ),// input wire [0:0]  probe4 
    .probe5                            (fifo_data_aly_rx          ),// input wire [127:0]  probe5 
    .probe6                            (fifo_prog_full_aly_rx     ),// input wire [0:0]  probe6 
    .probe7                            (data_rate_r               ) // input wire [31:0]  probe7
    );


endmodule
