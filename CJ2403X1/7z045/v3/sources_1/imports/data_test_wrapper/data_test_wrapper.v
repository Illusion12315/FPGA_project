`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         ACQNOVA
// Engineer:       Long Lian
// 
// Create Date: 2023/07/14 15:14:39
// Design Name: 
// Module Name: data_test_wrapper
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


module data_test_wrapper
    # ( 
        parameter       WR_DATA_WIDTH           =   128, 
        parameter       RD_DATA_WIDTH           =   128     
    )
    
    (
        // Clock and Reset# Interface
        input                                   log_clk,                    // Logic Clock, Rising Edge
        input                                   log_rst_n,                  // Logic Reset, Low Active 
        
        // Status Signals
        input                                   link_up,                

        // Data Path Ctrl
        input                                   wr_data_en,
        input                                   rd_data_en,
        input       [7:0]                       channel_flag,

        //---------------------------------------------------------------------   
        // FIFO Interface for Upstream
        input                                   fifo_wrclk_us,              // fifo write clock
        output                                  fifo_wrreq_us,              // fifo write request
        output      [WR_DATA_WIDTH-1:0]         fifo_data_us,               // fifo write data
        input                                   fifo_prog_full_us,          // fifo program full
        
        //---------------------------------------------------------------------   
        // FIFO Interface for Downstream
        input                                   fifo_rdclk_ds,              // fifo read clock
        output                                  fifo_rdreq_ds,              // fifo read request
        input       [RD_DATA_WIDTH-1:0]         fifo_q_ds,                  // fifo read data
        input                                   fifo_empty_ds               // fifo empty        
    );
    

//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
    wire                                    wr_rst_n;
    wire                                    rd_rst_n;


//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------  
    reg                                     wr_log_rst_n_r              =   1'b0;
    reg                                     wr_log_rst_n_r2             =   1'b0;        
    reg                                     rd_log_rst_n_r              =   1'b0;
    reg                                     rd_log_rst_n_r2             =   1'b0;        


// ********************************************************************************** // 
//---------------------------------------------------------------------
// I/O Connections assignments
//---------------------------------------------------------------------    
assign          wr_rst_n                =   wr_log_rst_n_r2;
assign          rd_rst_n                =   rd_log_rst_n_r2;
    
    
// ********************************************************************************** // 
//---------------------------------------------------------------------
//  Input Register
//---------------------------------------------------------------------
always@(posedge fifo_wrclk_us)
    begin
        wr_log_rst_n_r     <=  log_rst_n;
        wr_log_rst_n_r2    <=  wr_log_rst_n_r;
    end
always@(posedge fifo_rdclk_ds)
    begin
        rd_log_rst_n_r     <=  log_rst_n;
        rd_log_rst_n_r2    <=  rd_log_rst_n_r;
    end


// ********************************************************************************** // 
//---------------------------------------------------------------------
//  递增数造数写入FIFO
//---------------------------------------------------------------------
reg         link_up_r       =   1'b0;  
reg         link_up_r2      =   1'b0;   
always@(posedge fifo_wrclk_us)
    begin
        link_up_r   <=  link_up;
        link_up_r2  <=  link_up_r;
    end

reg         wr_data_en_r    =   1'b0; 
reg         wr_data_en_r2   =   1'b0; 
always@(posedge fifo_wrclk_us)
    begin
        wr_data_en_r    <=  wr_data_en;
        wr_data_en_r2   <=  wr_data_en_r;
    end

reg         fifo_prog_full_us_r     =   1'b1;
always@(posedge fifo_wrclk_us)
    begin
        fifo_prog_full_us_r    <=  fifo_prog_full_us; 
    end

reg     [7:0]       wr_ch_flag_r    =   8'd0; 
reg     [7:0]       wr_ch_flag_r2   =   8'd0; 
always@(posedge fifo_wrclk_us)
    begin
        wr_ch_flag_r    <=  channel_flag;
        wr_ch_flag_r2   <=  wr_ch_flag_r;
    end
    
wire                            wr_valid;
reg     [55:0]                  wr_data_cnt         =   56'd0;
reg                             fifo_wrreq_us_r     =   1'b0;
reg     [WR_DATA_WIDTH-1:0]     fifo_data_us_r      =   {WR_DATA_WIDTH{1'b0}};
assign      wr_valid        =   link_up_r2 && wr_data_en_r2 && ~fifo_prog_full_us_r;
assign 	    fifo_wrreq_us   =   fifo_wrreq_us_r;
assign 	    fifo_data_us    =   fifo_data_us_r;
always@(posedge fifo_wrclk_us or negedge wr_rst_n)
    begin
        if(!wr_rst_n)begin
            wr_data_cnt <=  56'd0;
        end else if(wr_valid)begin
            wr_data_cnt <=  wr_data_cnt + 56'd2;
        end else begin
            wr_data_cnt <=  wr_data_cnt;
        end
    end

always@(posedge fifo_wrclk_us or negedge wr_rst_n)
    begin
        if(!wr_rst_n)begin
            fifo_wrreq_us_r <=  1'b0;
        end else if(wr_valid)begin
            fifo_wrreq_us_r <=  1'b1;
        end else begin
            fifo_wrreq_us_r <=  1'b0;
        end
    end

always@(posedge fifo_wrclk_us or negedge wr_rst_n)
    begin
        if(!wr_rst_n)begin
            fifo_data_us_r  <=  {WR_DATA_WIDTH{1'b0}};
        end else begin
            fifo_data_us_r  <=  {wr_ch_flag_r2, wr_data_cnt, 
                                 wr_ch_flag_r2, wr_data_cnt + 1};
        end
    end


// ********************************************************************************** // 
//---------------------------------------------------------------------
//  FIFO读取数据
//---------------------------------------------------------------------
reg         rd_data_en_r    =   1'b0;   
reg         rd_data_en_r2   =   1'b0;
assign      fifo_rdreq_ds   =   !fifo_empty_ds && rd_data_en_r2;
always@(posedge fifo_rdclk_ds)
    begin
        rd_data_en_r    <=  rd_data_en;
        rd_data_en_r2   <=  rd_data_en_r;
    end


// ********************************************************************************** // 
//---------------------------------------------------------------------
//  数据校验检测
//---------------------------------------------------------------------
reg     [7:0]       rd_ch_flag_r    =   8'd0; 
reg     [7:0]       rd_ch_flag_r2   =   8'd0; 
always@(posedge fifo_rdclk_ds)
    begin
        rd_ch_flag_r    <=  channel_flag;
        rd_ch_flag_r2   <=  rd_ch_flag_r;
    end

reg                             fifo_rdreq_ds_r     =   1'b0;
reg     [RD_DATA_WIDTH-1:0]     fifo_q_ds_r         =   {RD_DATA_WIDTH{1'b0}};
reg     [RD_DATA_WIDTH-1:0]     rd_sim_data         =   {RD_DATA_WIDTH{1'b0}};
reg     [55:0]                  rd_data_cnt         =   56'd0;
reg     [7:0]                   rd_error_cnt        =   8'd0;
always@(posedge fifo_rdclk_ds)
    begin
        fifo_rdreq_ds_r <=  fifo_rdreq_ds;
        fifo_q_ds_r     <=  fifo_q_ds;
        rd_sim_data     <=  {rd_ch_flag_r2, rd_data_cnt, 
                             rd_ch_flag_r2, rd_data_cnt + 1};
    end
                              
always@(posedge fifo_rdclk_ds or negedge rd_rst_n)
    begin
        if(!rd_rst_n)begin
            rd_data_cnt <=  56'd0;
        end else if(fifo_rdreq_ds)begin
            rd_data_cnt <=  rd_data_cnt + 56'd2;
        end else begin
            rd_data_cnt <=  rd_data_cnt;
        end
    end
    
always@(posedge fifo_rdclk_ds or negedge rd_rst_n)
    begin
        if(!rd_rst_n)begin
            rd_error_cnt    <=  8'd0;
        end else if(fifo_rdreq_ds_r && (fifo_q_ds_r != rd_sim_data))begin
            rd_error_cnt    <=  rd_error_cnt + 8'd1;
        end else begin
            rd_error_cnt    <=  rd_error_cnt;
        end
    end       


// ********************************************************************************** // 
//---------------------------------------------------------------------
//  速率检测
//---------------------------------------------------------------------
reg     [15:0]                  wr_data_v_MB        =   16'd0;
reg     [31:0]                  wr_data_v_cnt       =   32'd0;
reg     [31:0]                  wr_time_cnt         =   32'd0;
always@(posedge fifo_wrclk_us or negedge wr_rst_n)
    begin
        if(!wr_rst_n)begin
            wr_data_v_MB    <=  0;
            wr_data_v_cnt   <=  0;
            wr_time_cnt     <=  0;
        end else begin
            if(wr_time_cnt == 199_999_999) begin                        
                wr_data_v_MB    <=  wr_data_v_cnt >> 15;    // 速率单位： MB/s     
                wr_data_v_cnt   <=  0;
                wr_time_cnt     <=  0;
            end else begin
                wr_data_v_MB    <=  wr_data_v_MB;
                wr_time_cnt     <=  wr_time_cnt + 1'b1;
                if(fifo_wrreq_us) begin
                    wr_data_v_cnt   <=  wr_data_v_cnt + 1'b1;
                end else begin
                    wr_data_v_cnt   <=  wr_data_v_cnt;
                end
            end
        end
    end

reg     [15:0]                  rd_data_v_MB        =   16'd0;
reg     [31:0]                  rd_data_v_cnt       =   32'd0;
reg     [31:0]                  rd_time_cnt         =   32'd0;
always@(posedge fifo_rdclk_ds or negedge rd_rst_n)
    begin
        if(!rd_rst_n)begin
            rd_data_v_MB    <=  0;
            rd_data_v_cnt   <=  0;
            rd_time_cnt     <=  0;
        end else begin
            if(rd_time_cnt == 199_999_999) begin                        
                rd_data_v_MB    <=  rd_data_v_cnt >> 15;    // 速率单位： MB/s     
                rd_data_v_cnt   <=  0;
                rd_time_cnt     <=  0;
            end else begin
                rd_data_v_MB    <=  rd_data_v_MB;
                rd_time_cnt     <=  rd_time_cnt + 1'b1;
                if(fifo_rdreq_ds) begin
                    rd_data_v_cnt   <=  rd_data_v_cnt + 1'b1;
                end else begin
                    rd_data_v_cnt   <=  rd_data_v_cnt;
                end
            end
        end
    end

 
// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//---------------------------------------------------------------------   
ila_fifo_data_test
    u_ila_fifo_wr_test
    (
        .clk        (fifo_wrclk_us),            // input wire clk
        .probe0     (fifo_wrreq_us),            // input wire [0:0]  probe0 
        .probe1     (fifo_data_us),             // input wire [127:0]  probe1
        .probe2     (fifo_prog_full_us),        // input wire [0:0]  probe2
        .probe3     (wr_data_v_MB),             // input wire [15:0]  probe3
        .probe4     (wr_data_cnt),              // input wire [55:0]  probe4 
        .probe5     (wr_ch_flag_r2)             // input wire [7:0]  probe5
    ); 
    
ila_fifo_data_test
    u_ila_fifo_rd_test
    (
        .clk        (fifo_rdclk_ds),            // input wire clk
        .probe0     (fifo_rdreq_ds),            // input wire [0:0]  probe0 
        .probe1     (fifo_q_ds),                // input wire [127:0]  probe1
        .probe2     (fifo_empty_ds),            // input wire [0:0]  probe2
        .probe3     (rd_data_v_MB),             // input wire [15:0]  probe3
        .probe4     (rd_data_cnt),              // input wire [55:0]  probe4 
        .probe5     (rd_error_cnt)              // input wire [7:0]  probe5 
    ); 
        
    
endmodule