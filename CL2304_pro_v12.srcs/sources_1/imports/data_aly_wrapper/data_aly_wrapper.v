`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     ACQNOVA
// Engineer:    Long Lian
// 
// Create Date: 2020/11/27 09:39:22
// Design Name: 
// Module Name: data_aly_wrapper
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


module data_aly_wrapper
    # (
    parameter                           CHANNEL_NUM             =   4,
    
    parameter                           WR_DATA_WIDTH           =   128,
    parameter                           RD_DATA_WIDTH           =   256 
    )

    (
        // Clock and Reset# Interface
    input                               log_clk                    ,// Logic Clock, Rising Edge
    input                               log_rst_n                  ,// Logic Reset, Low Active 
        
        // Data Path Select
    input                               record_en                  ,// '1' Enable Record
    input                               play_en                    ,// '1' Enable Record
    input                               sim_data_en                ,// '1' Enable Sim
        
        // Data Path Ctrl
    input              [  31:0]         record_num                 ,
    input              [  31:0]         play_num                   ,

        // Status Signals
    output             [CHANNEL_NUM-1:0]record_full_flag           ,
    output             [CHANNEL_NUM-1:0]play_empty_flag            ,
    output             [CHANNEL_NUM*32-1:0]rx_aly_data_rate           ,
    output             [CHANNEL_NUM*32-1:0]tx_aly_data_rate           ,
                     
        //---------------------------------------------------------------------
        //  Data Interface
        //---------------------------------------------------------------------                                              
//        // TX Interface 
//        output      [CHANNEL_NUM*DATA_WIDTH-1:0]tx_data,                  
//        output      [CHANNEL_NUM-1:0]           tx_valid,              
//        input       [CHANNEL_NUM-1:0]           tx_ready,  

        // RX Interface 
    input              [CHANNEL_NUM*WR_DATA_WIDTH-1:0]rx_data                    ,
    input              [CHANNEL_NUM-1:0]rx_valid                   ,

        //---------------------------------------------------------------------
        //  Analysis Interface
        //---------------------------------------------------------------------   
//        // FIFO Interface for Analysis Transmit
    input              [CHANNEL_NUM-1:0]fifo_wrclk_aly_tx          ,// Write Clock
    input              [CHANNEL_NUM-1:0]fifo_wrreq_aly_tx          ,// fifo write request
    input              [CHANNEL_NUM*RD_DATA_WIDTH-1:0]fifo_data_aly_tx           ,// fifo write data
    output             [CHANNEL_NUM-1:0]fifo_prog_full_aly_tx      ,// fifo program full                   
        // FIFO Interface for Analysis Receive     
    input              [CHANNEL_NUM-1:0]fifo_rdclk_aly_rx          ,// Read Clock
    input              [CHANNEL_NUM-1:0]fifo_rdreq_aly_rx          ,// fifo read request
    output             [CHANNEL_NUM*RD_DATA_WIDTH-1:0]fifo_q_aly_rx              ,// fifo read data
    output             [CHANNEL_NUM-1:0]fifo_empty_aly_rx           // fifo empty   
    );


//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
            
            
//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------


// ********************************************************************************** // 
//---------------------------------------------------------------------  
// Parameter
//--------------------------------------------------------------------- 


// ********************************************************************************** // 
//---------------------------------------------------------------------
// I/O Connections assignments
//---------------------------------------------------------------------    


// ********************************************************************************** // 
//---------------------------------------------------------------------
//  ¸´Î»
//---------------------------------------------------------------------
                    

generate
    begin : data_aly
        genvar  i;
        for (i = 0; i <= CHANNEL_NUM - 1; i = i + 1)
            begin : ch
                // ********************************************************************************** // 
                //---------------------------------------------------------------------
                //  RX Data Analysis
                //---------------------------------------------------------------------
                data_rx_aly
                    # (
                        .WR_DATA_WIDTH                     (WR_DATA_WIDTH),
                        .RD_DATA_WIDTH                     (RD_DATA_WIDTH)
                    )
                    
                    rx_aly_inst
                    (
                        // Clock and Reset# Interface
                        .log_clk                        (log_clk),
                        .log_rst_n                      (log_rst_n),
                        
                        // Data Path Select
                        .record_en                      (record_en),
                        .sim_data_en                    (sim_data_en),
                        
                        // Data Path Ctrl
                        .record_ch                      (record_num[i]),
                        .channel_flag                   (i+1),
                       
                        // Status Signals
                        .record_full_flag               (record_full_flag[i]),
                        .data_rate                      (rx_aly_data_rate[32*i +: 32]),
                        
                        // RX Interface 
                        .rx_valid                       (rx_valid[i]),
                        .rx_data                        (rx_data[WR_DATA_WIDTH*i +: WR_DATA_WIDTH]),
                
                        // FIFO Interface for Analysis Receive
                        .fifo_rdclk_aly_rx              (fifo_rdclk_aly_rx[i]),
                        .fifo_rdreq_aly_rx              (fifo_rdreq_aly_rx[i]),
                        .fifo_q_aly_rx                  (fifo_q_aly_rx[RD_DATA_WIDTH*i +: RD_DATA_WIDTH]),
                        .fifo_empty_aly_rx              (fifo_empty_aly_rx[i])
                    );


               // ********************************************************************************** // 
//                //---------------------------------------------------------------------
//                //  RX Data Analysis
//                //---------------------------------------------------------------------
//                data_tx_aly
//                    # (
//                        .DATA_WIDTH                     (DATA_WIDTH)
//                    )
                    
//                    tx_aly_inst
//                    (
//                        // Clock and Reset# Interface
//                        .log_clk                        (log_clk),
//                        .log_rst_n                      (log_rst_n),
                        
//                        // Data Path Select
//                        .play_en                        (play_en),
                        
//                        // Data Path Ctrl
//                        .play_ch                        (play_num[i]),
//                        .channel_flag                   (i+1),

//                        // Status Signals
//                        .play_empty_flag                (play_empty_flag[i]),  
//                        .data_rate                      (tx_aly_data_rate[32*i +: 32]),

//                        // FIFO Interface for Analysis Transmit     
//                        .fifo_wrclk_aly_tx              (fifo_wrclk_aly_tx[i]), 
//                        .fifo_wrreq_aly_tx              (fifo_wrreq_aly_tx[i]),
//                        .fifo_data_aly_tx               (fifo_data_aly_tx[DATA_WIDTH*i +: DATA_WIDTH]),
//                        .fifo_prog_full_aly_tx          (fifo_prog_full_aly_tx[i]),    
                        
//                        // TX Interface
//                        .tx_data                        (tx_data[DATA_WIDTH*i +: DATA_WIDTH]),
//                        .tx_valid                       (tx_valid[i]),
//                        .tx_ready                       (tx_ready[i])                   
//                    );                
                    
            end
    end
endgenerate         
        
 
// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//--------------------------------------------------------------------- 


endmodule
