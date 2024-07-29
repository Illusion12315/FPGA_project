`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     ACQNOVA
// Engineer:    Long Lian
// 
// Create Date: 2020/02/20 13:24:47
// Design Name: 
// Module Name: data_xfer
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


module data_xfer
    # (
        parameter       CHANNEL_NUM             =   4,
        parameter       DATA_WIDTH              =   256
    )
    
    (
        // Clock and Reset# Interface
        input                                   log_clk,                    // Logic Clock, Rising Edge
        input                                   log_rst_n,                  // Logic Reset, Low Active 
        
        // Data Path Select
        input                                   record_en,                  // '1' Enable Record
        input                                   play_en,                    // '1' Enable Play      

        // Data Path Ctrl
        input       [31:0]                      record_num,
        input       [31:0]                      play_num,
                
        // DMA Transfer Length 
        input       [31:0]                      dma_xfer_len,    
        input       [CHANNEL_NUM-1:0]           ddr3_data_rdy,
        input       [CHANNEL_NUM*32-1:0]        ddr3_data_usedw,  
        
        // PCIE Ctrl Status Signals
        input                                   pcie_lnk_up,
        output                                  upstream_valid,             // 上行数据链路有效标志，上位机读取                                
        output                                  downstream_valid,           // 下行数据链路有效标志，上位机读取                                
        output      [31:0]                      upstream_valid_ch,          // 上行采集通道DDR缓存数据准备有效标志，上位机读取，共可标志32通道              
        output      [31:0]                      downstream_valid_ch,        // 下行回放通道DDR缓存空间准备有效标志，上位机读取，共可标志32通道              
        input       [31:0]                      downstream_flag,            // 下行回放数据通道标志，上位机下发                                
        
        // Status Signals
        input                                   phy_init_done, 
        output      [CHANNEL_NUM-1:0]           channel_valid, 
                
        // Data Rate
        output      [CHANNEL_NUM*32-1:0]        channel_rate,
           
        // Data Quantity
        output      [CHANNEL_NUM*32-1:0]        quantity,  

        //---------------------------------------------------------------------
        //  Analysis interface       
        //---------------------------------------------------------------------     
        // FIFO Interface for Analysis Transmit
        output      [CHANNEL_NUM-1:0]           fifo_wrreq_aly_tx,         
        output      [CHANNEL_NUM*DATA_WIDTH-1:0]    fifo_data_aly_tx,          
        input       [CHANNEL_NUM-1:0]           fifo_prog_full_aly_tx,                 
        // FIFO Interface for Analysis Receive     
        output      [CHANNEL_NUM-1:0]           fifo_rdreq_aly_rx,         
        input       [CHANNEL_NUM*DATA_WIDTH-1:0]    fifo_q_aly_rx,             
        input       [CHANNEL_NUM-1:0]           fifo_empty_aly_rx,         
                           
        //---------------------------------------------------------------------
        //  DDR3 Interface  
        //---------------------------------------------------------------------     
        // FIFO Interface for DDR3 SDRAM Upstream
        output      [CHANNEL_NUM-1:0]           fifo_wrreq_ddr3_us,        
        output      [CHANNEL_NUM*DATA_WIDTH-1:0]    fifo_data_ddr3_us,         
        input       [CHANNEL_NUM-1:0]           fifo_prog_full_ddr3_us,    
        // FIFO Interface for DDR3 SDRAM Downstream
        output      [CHANNEL_NUM-1:0]           fifo_rdreq_ddr3_ds,        
        input       [CHANNEL_NUM*DATA_WIDTH-1:0]    fifo_q_ddr3_ds,            
        input       [CHANNEL_NUM-1:0]           fifo_empty_ddr3_ds,        
                                        
        //---------------------------------------------------------------------
        //  PCIE Interface
        //---------------------------------------------------------------------
        // FIFO Interface for PCIE Upstream
        output      [CHANNEL_NUM-1:0]           fifo_wrreq_pcie_us,         
        output      [CHANNEL_NUM*DATA_WIDTH-1:0]    fifo_data_pcie_us,          
        input       [CHANNEL_NUM-1:0]           fifo_prog_full_pcie_us,

        // FIFO Interface for PCIE Downstream
        output      [CHANNEL_NUM-1:0]           fifo_rdreq_pcie_ds,       
        input       [CHANNEL_NUM*DATA_WIDTH-1:0]    fifo_q_pcie_ds,           
        input       [CHANNEL_NUM-1:0]           fifo_empty_pcie_ds                          
    );


//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
    wire                                    sys_rst_n;


//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
    reg                                     log_rst_n_r         =   1'b0;
    reg                                     log_rst_n_r2        =   1'b0;        
    // Data Path Select
    reg                                     record_en_r         =   1'b0;
    reg                                     record_en_r2        =   1'b0;
    reg                                     play_en_r           =   1'b0;
    reg                                     play_en_r2          =   1'b0;
    // Data Path Ctrl
    reg         [31:0]                      record_num_r        =   32'd0;
    reg         [31:0]                      record_num_r2       =   32'd0;
    reg         [31:0]                      play_num_r          =   32'd0;
    reg         [31:0]                      play_num_r2         =   32'd0;   
    // Status Interface
    reg         [3:0]                       data_path_fsm;
    reg         [CHANNEL_NUM-1:0]           record_ch           =   {CHANNEL_NUM{1'b0}};
    reg         [CHANNEL_NUM-1:0]           play_ch             =   {CHANNEL_NUM{1'b0}};
    reg         [CHANNEL_NUM-1:0]           channel_valid_r     =   {CHANNEL_NUM{1'b0}};
    //  Analysis Interface
    // FIFO Interface for Analysis Transmit
    reg         [CHANNEL_NUM-1:0]           fifo_wrreq_aly_tx_r     =   {CHANNEL_NUM{1'b0}};
    reg         [DATA_WIDTH-1:0]            fifo_data_aly_tx_r      [CHANNEL_NUM-1:0];
    reg         [CHANNEL_NUM-1:0]           fifo_prog_full_aly_tx_r =   {CHANNEL_NUM{1'b1}};   
    //  DDR3 Interface  
    reg                                     phy_init_done_r     =   1'b0; 
    reg                                     phy_init_done_r2    =   1'b0; 
    reg         [CHANNEL_NUM-1:0]           ddr3_data_rdy_r     =   {CHANNEL_NUM{1'b0}};        
    reg         [CHANNEL_NUM-1:0]           ddr3_data_rdy_r2    =   {CHANNEL_NUM{1'b0}};    
    reg         [31:0]                      ddr3_data_usedw_r       [CHANNEL_NUM-1:0];
    reg         [31:0]                      ddr3_data_usedw_r2      [CHANNEL_NUM-1:0];
    // FIFO Interface for DDR3 SDRAM Upstream
    reg         [CHANNEL_NUM-1:0]           fifo_wrreq_ddr3_us_r        =   {CHANNEL_NUM{1'b0}};
    reg         [DATA_WIDTH-1:0]            fifo_data_ddr3_us_r     [CHANNEL_NUM-1:0];
    reg         [CHANNEL_NUM-1:0]           fifo_prog_full_ddr3_us_r    =   {CHANNEL_NUM{1'b1}};
    
    reg         [CHANNEL_NUM-1:0]           fifo_wrreq_ddr3_us_p        =   {CHANNEL_NUM{1'b0}};
    reg         [DATA_WIDTH-1:0]            fifo_data_ddr3_us_p     [CHANNEL_NUM-1:0];
    //  PCIE Interface  
    reg         [CHANNEL_NUM-1:0]           upstream_valid_ch_r     =   {CHANNEL_NUM{1'b0}};
    reg         [CHANNEL_NUM-1:0]           downstream_valid_ch_r   =   {CHANNEL_NUM{1'b1}};
    reg                                     pcie_lnk_up_r       =   1'b0;
    reg                                     pcie_lnk_up_r2      =   1'b0;
    reg         [31:0]                      dma_xfer_len_r      =   32'd0;
    reg         [31:0]                      dma_xfer_len_r2     =   32'd0;
    // FIFO Interface for PCIE Upstream
    reg         [CHANNEL_NUM-1:0]           fifo_wrreq_pcie_us_r        =   {CHANNEL_NUM{1'b0}};
    reg         [DATA_WIDTH-1:0]            fifo_data_pcie_us_r     [CHANNEL_NUM-1:0];
    reg         [CHANNEL_NUM-1:0]           fifo_prog_full_pcie_us_r    =   {CHANNEL_NUM{1'b1}};
    
    // Channel Selection Interface
    reg         [3:0]                       channel_fsm             [CHANNEL_NUM-1:0];
    reg         [CHANNEL_NUM-1:0]           channel_en          =   {CHANNEL_NUM{1'b0}};
    reg         [CHANNEL_NUM-1:0]           channel_wrreq       =   {CHANNEL_NUM{1'b0}};
    reg         [DATA_WIDTH-1:0]            channel_data            [CHANNEL_NUM-1:0];     
    reg         [31:0]                      channel_count           [CHANNEL_NUM-1:0];
    reg         [31:0]                      threshold           =   32'd0;
    
    // Data Rate
    reg         [31:0]                      channel_rate_r          [CHANNEL_NUM-1:0];
    reg         [31:0]                      channel_rate_cnt        [CHANNEL_NUM-1:0];         
    reg         [31:0]                      channel_time_cnt        [CHANNEL_NUM-1:0];         
    // Data Quantity
    reg                                     cnt_inc                 [CHANNEL_NUM-1:0];
    reg         [15:0]                      cnt_8kb                 [CHANNEL_NUM-1:0];
    reg                                     flag_8kb                [CHANNEL_NUM-1:0];
    reg         [31:0]                      quantity_r              [CHANNEL_NUM-1:0];


// ********************************************************************************** // 
//---------------------------------------------------------------------  
// Parameter
//--------------------------------------------------------------------- 

//---------------------------------------------------------------------
// Data path state variable assignments (sequential coded) 
//---------------------------------------------------------------------
localparam      data_path_init              =   4'h0;
localparam      data_path_idle              =   4'h1;
localparam      data_path_judge             =   4'h2;
localparam      data_record                 =   4'h3;
localparam      data_play                   =   4'h4;


// ********************************************************************************** // 
//---------------------------------------------------------------------
// I/O Connections assignments
//---------------------------------------------------------------------    
assign          sys_rst_n               =   log_rst_n_r2;

assign          upstream_valid          =   |upstream_valid_ch;
assign          downstream_valid        =   |downstream_valid_ch;
assign          upstream_valid_ch       =   {{(32-CHANNEL_NUM){1'b0}}, upstream_valid_ch_r};
assign          downstream_valid_ch     =   {{(32-CHANNEL_NUM){1'b0}}, downstream_valid_ch_r};


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
        play_en_r       <=  play_en;
        play_en_r2      <=  play_en_r;
    end
    
always@(posedge log_clk)
    begin
        record_num_r    <=  record_num;
        record_num_r2   <=  record_num_r;   
    end    
    
always@(posedge log_clk)
    begin
        play_num_r      <=  play_num; 
        play_num_r2     <=  play_num_r;     
    end
    
always@(posedge log_clk)
    begin
        phy_init_done_r     <=  phy_init_done;
        phy_init_done_r2    <=  phy_init_done_r;
    end    
    
always@(posedge log_clk)
    begin
        ddr3_data_rdy_r     <=  ddr3_data_rdy;
        ddr3_data_rdy_r2    <=  ddr3_data_rdy_r;     
    end

always@(posedge log_clk)
    begin
        pcie_lnk_up_r       <=  pcie_lnk_up;
        pcie_lnk_up_r2      <=  pcie_lnk_up_r; 
    end    
    
always@(posedge log_clk)
    begin
        dma_xfer_len_r      <=  dma_xfer_len;
        dma_xfer_len_r2     <=  dma_xfer_len_r;   
    end

always@(posedge log_clk)
    begin
        threshold       <=  (dma_xfer_len_r2 >> 5) - 1; 
    end    
    
always@(posedge log_clk)
    begin
        fifo_prog_full_aly_tx_r     <=  fifo_prog_full_aly_tx;
        fifo_prog_full_ddr3_us_r    <=  fifo_prog_full_ddr3_us;
        fifo_prog_full_pcie_us_r    <=  fifo_prog_full_pcie_us;
    end    


// ********************************************************************************** // 
//---------------------------------------------------------------------
// Status
//---------------------------------------------------------------------    
//  采集回放导入导出状态
always@(posedge log_clk or negedge sys_rst_n)
    begin
        if(!sys_rst_n)begin        
            data_path_fsm <=  data_path_init;            
        end else begin
            case(data_path_fsm)
                data_path_init:
                    begin
                        data_path_fsm <=  data_path_idle;
                    end
                    
                data_path_idle:
                    begin
                        if((phy_init_done_r2 == 1'b1) && (pcie_lnk_up_r2 == 1'b1)) begin
                            data_path_fsm <=  data_path_judge;
                        end else begin
                            data_path_fsm <=  data_path_fsm;
                        end
                    end
                    
                data_path_judge:
                    begin
                        if((record_en_r2 == 1'b1) && (record_en_r == 1'b1)) begin
                            data_path_fsm <=  data_record;
                        end else if((play_en_r2 == 1'b1) && (play_en_r == 1'b1))  begin
                            data_path_fsm <=  data_play;
                        end else begin
                            data_path_fsm <=  data_path_fsm;
                        end
                    end
                    
                data_record:            //  采集
                    begin
                        data_path_fsm <=  data_path_fsm;
                    end
                    
                data_play:              //  回放
                    begin
                        data_path_fsm <=  data_path_fsm;
                    end
                                                    
                default:
                    begin
                        data_path_fsm <=  data_path_init;
                    end
            endcase
        end
    end


generate
    begin: gen_data_xfer
        genvar  i;
        for (i = 0; i <= CHANNEL_NUM - 1; i = i + 1)
            begin : ch
                //  数据有效判断，当开始采集后检测到rx端有数据，则判断数据有效，高有效            
                assign      channel_valid[i]        =   channel_valid_r[i];
                
                always@(posedge log_clk or negedge sys_rst_n)begin
                    if(!sys_rst_n)begin
                        ddr3_data_usedw_r[i]   <= 'd0;
                        ddr3_data_usedw_r2[i]  <= 'd0;
                    end else begin
                        ddr3_data_usedw_r[i]   <= ddr3_data_usedw[32*i +: 32];
                        ddr3_data_usedw_r2[i]  <= ddr3_data_usedw_r[i];                       
                    end
                end
                
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            channel_valid_r[i]  <=  1'b0;
                        end else begin
                            if(fifo_rdreq_aly_rx[i]) begin
                                channel_valid_r[i]  <=  1'b1;
                            end else begin
                                channel_valid_r[i]  <=  channel_valid_r[i];
                            end                                                                                                   
                        end
                    end        

                //  数据满足一次PCIE上传大小标志，高有效            
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            upstream_valid_ch_r[i]  <=  1'b0;
                        end else begin
                            if(channel_fsm[i] == 4'h2) begin
                                upstream_valid_ch_r[i]  <=  1'b1;
                            end else begin
                                upstream_valid_ch_r[i]  <=  1'b0;
                            end                                                                                                   
                        end
                    end   
                    
                //  回放时，缓存空间足够一次PCIE传输大小，低有效            
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            downstream_valid_ch_r[i]  <=  1'b0;
                        end else begin
                            if(play_ch[i] && (ddr3_data_usedw_r2[i] < 32'h0100_0000 - 32'h0008_0000)) begin      //  1GB - 32MB
                                downstream_valid_ch_r[i]  <=  1'b1;
                            end else begin
                                downstream_valid_ch_r[i]  <=  1'b0;
                            end                                                                                                   
                        end
                    end    
                    
                //  采集通道
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            record_ch[i]    <=  1'b0;
                        end else begin
                            if((data_path_fsm == data_record) && (record_num_r2[i] == 1'b1)) begin
                                record_ch[i]    <=  1'b1;
                            end else begin
                                record_ch[i]    <=  record_ch[i];
                            end
                        end
                    end

                //  回放通道
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            play_ch[i]      <=  1'b0;
                        end else begin
                            if((data_path_fsm == data_play) && (play_num_r2[i] == 1'b1)) begin
                                play_ch[i]      <=  1'b1;
                            end else begin
                                play_ch[i]      <=  play_ch[i];
                            end
                        end
                    end        
                    
                //  DDR3的读写切换控制，采集回放链路共用   
                assign      fifo_wrreq_ddr3_us[i]                           =   (record_ch[i] == 1'b1)      ?   fifo_wrreq_ddr3_us_r[i]     :       // 采集
                                                                                (play_ch[i] == 1'b1)        ?   fifo_wrreq_ddr3_us_p[i]     :       // 回放
                                                                                 1'b0;                                                                
                                                     
                assign      fifo_data_ddr3_us[DATA_WIDTH*i +: DATA_WIDTH]   =   (record_ch[i] == 1'b1)      ?   fifo_data_ddr3_us_r[i]      :       // 采集
                                                                                (play_ch[i] == 1'b1)        ?   fifo_data_ddr3_us_p[i]      :       // 回放
                                                                                {DATA_WIDTH{1'b0}};            
                
                assign      fifo_rdreq_ddr3_ds[i]                           =   (record_ch[i] == 1'b1)      ?   channel_en[i] && (!fifo_empty_ddr3_ds[i]) && (!fifo_prog_full_pcie_us_r[i]) :       // 采集
                                                                                (play_ch[i] == 1'b1)        ?   (!fifo_empty_ddr3_ds[i]) && (!fifo_prog_full_aly_tx_r[i])       :   // 回放
                                                                                1'b0;                

                // ********************************************************************************** // 
                //---------------------------------------------------------------------
                //  数据采集
                //---------------------------------------------------------------------      
                //  读取解析模块的数据写入DDR3
                assign      fifo_rdreq_aly_rx[i]    =   record_ch[i] && !fifo_empty_aly_rx[i] && !fifo_prog_full_ddr3_us[i];

                //  采集的数据写入DDR3通道
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin            
                            fifo_wrreq_ddr3_us_r[i]     <=  1'b0;               
                        end else begin
                            fifo_wrreq_ddr3_us_r[i]     <=  fifo_rdreq_aly_rx[i];                           
                        end                
                    end   
                                             
                always@(posedge log_clk)
                    begin
                        fifo_data_ddr3_us_r[i]      <=  fifo_q_aly_rx[DATA_WIDTH*i +: DATA_WIDTH];
                    end

                //  通道数据采集状态机，各通道从DDR3读取一定数据量写入PCIE
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin     
                            channel_fsm[i]  <=  4'h0;
                        end else begin
                            case(channel_fsm[i])
                                4'h0:
                                    begin
                                        if(record_ch[i]) begin
                                            channel_fsm[i]  <=  4'h1;
                                        end else begin
                                            channel_fsm[i]  <=  channel_fsm[i];
                                        end                                            
                                    end
                                    
                                4'h1:
                                    begin
                                        if(ddr3_data_rdy_r2[i]) begin
                                            channel_fsm[i]  <=  4'h2;
                                        end else begin
                                            channel_fsm[i]  <=  channel_fsm[i];
                                        end                                                                                        
                                    end
                                    
                                4'h2:
                                    begin
                                        if(fifo_rdreq_ddr3_ds[i]) begin                                                    
                                            if(channel_count[i] == threshold) begin                           
                                                channel_fsm[i]  <=  4'h1;                
                                            end else begin               
                                                channel_fsm[i]  <=  channel_fsm[i];                            
                                            end
                                        end else begin                                                      
                                            channel_fsm[i]  <=  channel_fsm[i];                           
                                        end                                            
                                    end
                                    
                                default:
                                    begin
                                        channel_fsm[i]  <=  4'h0;
                                    end                                    
                            endcase
                        end
                    end
                    
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin     
                            channel_en[i]   <=  1'b0; 
                        end else if((channel_fsm[i] == 4'h1) && ddr3_data_rdy_r2[i])begin
                            channel_en[i]   <=  1'b1; 
                        end else if((channel_fsm[i] == 4'h2) && fifo_rdreq_ddr3_ds[i] && (channel_count[i] == threshold))begin
                            channel_en[i]   <=  1'b0; 
                        end else begin
                            channel_en[i]   <=  channel_en[i];
                        end
                    end

                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin     
                            channel_data[i] <=  {DATA_WIDTH{1'b0}};
                        end else begin
                            case(channel_fsm[i])
                                4'h2:
                                    begin
                                        channel_data[i] <=  fifo_q_ddr3_ds[DATA_WIDTH*i +: DATA_WIDTH];                                        
                                    end
                                    
                                default:
                                    begin
                                        channel_data[i] <=  {DATA_WIDTH{1'b0}};
                                    end                                    
                            endcase
                        end
                    end
                    
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin     
                            channel_count[i]    <=  32'd0;
                        end else begin
                            case(channel_fsm[i])
                                4'h2:
                                    begin
                                        if(fifo_rdreq_ddr3_ds[i])begin
                                            channel_count[i]    <=  channel_count[i] + 32'd1;  
                                        end else begin
                                            channel_count[i]    <=  channel_count[i]; 
                                        end
                                    end
                                default:
                                    begin
                                        channel_count[i]    <=  32'd0;
                                    end
                            endcase
                        end
                    end            
                                    
                                                    
                //  写入PCIE    
                assign      fifo_wrreq_pcie_us[i]                           =   fifo_wrreq_pcie_us_r[i];
                assign      fifo_data_pcie_us[DATA_WIDTH*i +: DATA_WIDTH]   =   fifo_data_pcie_us_r[i];
                
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin      
                            channel_wrreq[i]        <=  1'b0;    
                            fifo_wrreq_pcie_us_r[i] <=  1'b0;  
                        end else begin   
                            channel_wrreq[i]        <=  record_ch[i] && fifo_rdreq_ddr3_ds[i];
                            fifo_wrreq_pcie_us_r[i] <=  channel_wrreq[i];               
                        end
                    end
  
                always@(posedge log_clk)
                    begin
                        fifo_data_pcie_us_r[i]  <=  { channel_data[i][0   +: 8], channel_data[i][8   +: 8], channel_data[i][16  +: 8],  channel_data[i][24  +: 8],
                                                      channel_data[i][32  +: 8], channel_data[i][40  +: 8], channel_data[i][48  +: 8],  channel_data[i][56  +: 8],
                                                      channel_data[i][64  +: 8], channel_data[i][72  +: 8], channel_data[i][80  +: 8],  channel_data[i][88  +: 8],
                                                      channel_data[i][96  +: 8], channel_data[i][104 +: 8], channel_data[i][112 +: 8],  channel_data[i][120 +: 8],
                                                     
                                                      channel_data[i][128 +: 8], channel_data[i][136 +: 8], channel_data[i][144 +: 8],  channel_data[i][152 +: 8],
                                                      channel_data[i][160 +: 8], channel_data[i][168 +: 8], channel_data[i][176 +: 8],  channel_data[i][184 +: 8],
                                                      channel_data[i][192 +: 8], channel_data[i][200 +: 8], channel_data[i][208 +: 8],  channel_data[i][216 +: 8],
                                                      channel_data[i][224 +: 8], channel_data[i][232 +: 8], channel_data[i][240 +: 8],  channel_data[i][248 +: 8]};  
                    end
                                  

                // ********************************************************************************** // 
                //---------------------------------------------------------------------
                //  数据回放
                //---------------------------------------------------------------------      
                //  读出PCIE    
                assign      fifo_rdreq_pcie_ds[i]       =   play_ch[i] && !fifo_empty_pcie_ds[i] && !fifo_prog_full_ddr3_us_r[i];
                
                //  回放的数据写入DDR3通道
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin            
                            fifo_wrreq_ddr3_us_p[i] <=  1'b0;               
                        end else begin
                            fifo_wrreq_ddr3_us_p[i] <=  fifo_rdreq_pcie_ds[i];                              
                        end                
                    end

                always@(posedge log_clk)
                    begin
                        fifo_data_ddr3_us_p[i]      <=  {fifo_q_pcie_ds[DATA_WIDTH*i+0   +: 8], fifo_q_pcie_ds[DATA_WIDTH*i+8   +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+16  +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+24  +: 8],
                                                         fifo_q_pcie_ds[DATA_WIDTH*i+32  +: 8], fifo_q_pcie_ds[DATA_WIDTH*i+40  +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+48  +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+56  +: 8],
                                                         fifo_q_pcie_ds[DATA_WIDTH*i+64  +: 8], fifo_q_pcie_ds[DATA_WIDTH*i+72  +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+80  +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+88  +: 8],
                                                         fifo_q_pcie_ds[DATA_WIDTH*i+96  +: 8], fifo_q_pcie_ds[DATA_WIDTH*i+104 +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+112 +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+120 +: 8],

                                                         fifo_q_pcie_ds[DATA_WIDTH*i+128 +: 8], fifo_q_pcie_ds[DATA_WIDTH*i+136 +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+144 +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+152 +: 8],
                                                         fifo_q_pcie_ds[DATA_WIDTH*i+160 +: 8], fifo_q_pcie_ds[DATA_WIDTH*i+168 +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+176 +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+184 +: 8],
                                                         fifo_q_pcie_ds[DATA_WIDTH*i+192 +: 8], fifo_q_pcie_ds[DATA_WIDTH*i+200 +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+208 +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+216 +: 8],
                                                         fifo_q_pcie_ds[DATA_WIDTH*i+224 +: 8], fifo_q_pcie_ds[DATA_WIDTH*i+232 +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+240 +: 8],  fifo_q_pcie_ds[DATA_WIDTH*i+248 +: 8]};
                   end
                                        
                //  从DDR3读取回放数据进入解析模块
                assign      fifo_wrreq_aly_tx[i]                            =   fifo_wrreq_aly_tx_r[i];
                assign      fifo_data_aly_tx[DATA_WIDTH*i +: DATA_WIDTH]    =   fifo_data_aly_tx_r[i];
                
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin            
                            fifo_wrreq_aly_tx_r[i]  <=  1'b0;               
                        end else begin
                            fifo_wrreq_aly_tx_r[i]  <=  play_ch[i] && fifo_rdreq_ddr3_ds[i];                              
                        end                
                    end

                always@(posedge log_clk)
                    begin
                        fifo_data_aly_tx_r[i]   <=  fifo_q_ddr3_ds[DATA_WIDTH*i +: DATA_WIDTH];
                    end                

                // ********************************************************************************** // 
                //--------------------------------------------------------------------- 
                //  Data Rate    
                //---------------------------------------------------------------------
                assign      channel_rate[32*i +: 32]    =   channel_rate_r[i];
                
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            channel_rate_r[i]       <=  32'd0;
                            channel_rate_cnt[i]     <=  32'd0;
                            channel_time_cnt[i]     <=  32'd0;
                        end else if(channel_time_cnt[i] >= 32'd199_999_999) begin
                            channel_rate_r[i]       <=  channel_rate_cnt[i] >> 5;           //  Unit:KB/s
                            channel_rate_cnt[i]     <=  32'd0;
                            channel_time_cnt[i]     <=  32'd0;
                        end else begin
                            channel_rate_r[i]       <=  channel_rate_r[i];
                            channel_time_cnt[i]     <=  channel_time_cnt[i] + 32'd1;
                            if(fifo_wrreq_pcie_us[i] || fifo_rdreq_pcie_ds[i]) begin
                                channel_rate_cnt[i] <=  channel_rate_cnt[i] + 32'd1;
                            end else begin
                                channel_rate_cnt[i] <=  channel_rate_cnt[i];
                            end
                        end
                    end   

                // ********************************************************************************** // 
                //---------------------------------------------------------------------
                // Data Quantity
                //--------------------------------------------------------------------- 
                assign      quantity[32*i +: 32]        =   quantity_r[i];
                
                // 8192 byte Counter
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            cnt_inc[i]  <=  1'b0;
                        end else if(data_path_fsm == data_record) begin
                            cnt_inc[i]  <=  fifo_rdreq_ddr3_ds[i];
                        end else if(data_path_fsm == data_play) begin
                            cnt_inc[i]  <=  fifo_wrreq_ddr3_us[i];
                        end else begin
                            cnt_inc[i]  <=  1'b0;
                        end
                    end
                
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            cnt_8kb[i]  <=  0;
                            flag_8kb[i] <=  1'b0;
                        end else begin
                            if(cnt_inc[i] && (cnt_8kb[i] == 255)) begin
                                cnt_8kb[i]  <=  0;
                            end else if (cnt_inc[i]) begin
                                cnt_8kb[i]  <=  cnt_8kb[i] + 1'b1;
                            end
                                
                            if(cnt_inc[i] && (cnt_8kb[i] == 255)) begin
                                flag_8kb[i] <=  1'b1;
                            end else begin
                                flag_8kb[i] <=  1'b0;
                            end
                        end
                    end
                
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n) begin
                            quantity_r[i]   <=  0;
                        end else begin
                            if(flag_8kb[i]) begin
                                quantity_r[i]   <=  quantity_r[i] + 1'b1;
                            end else begin
                                quantity_r[i]   <=  quantity_r[i];
                            end
                        end
                    end  
                               
            end
    end
endgenerate            
 
    
// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//--------------------------------------------------------------------- 
//ila_wr_data 
//    u_ila_wr_data 
//    (
//        .clk            (log_clk),                      // input wire clk
//        .probe0         (record_en_r2),                 // input wire [0:0]  probe0          
//        .probe1         (record_num_r2),                // input wire [3:0]  probe1 
//        .probe2         ({ddr3_data_rdy_r2, upstream_valid_ch_r}),      // input wire [7:0]  probe2 
        
//        .probe3         (fifo_wrreq_pcie_us_r[2]),      // input wire [0:0]  probe3 
//        .probe4         (fifo_data_pcie_us_r[2]),       // input wire [255:0]  probe4 
//        .probe5         (fifo_prog_full_pcie_us_r[2]),  // input wire [0:0]  probe5        
//        .probe6         (fifo_wrreq_ddr3_us_r[2]),      // input wire [0:0]  probe6 
//        .probe7         (fifo_data_ddr3_us_r[2]),       // input wire [255:0]  probe7         
//        .probe8         (fifo_prog_full_ddr3_us[2]),    // input wire [0:0]  probe8 
//        .probe9         (fifo_rdreq_ddr3_ds[2]),        // input wire [0:0]  probe9 
//        .probe10        (fifo_q_ddr3_ds[767:512]),      // input wire [255:0]  probe10 
//        .probe11        (fifo_empty_ddr3_ds[2]),        // input wire [0:0]  probe12 
//        .probe12        (fifo_rdreq_aly_rx[2]),         // input wire [0:0]  probe12 
//        .probe13        (fifo_q_aly_rx[767:512]),       // input wire [255:0]  probe13 
//        .probe14        (fifo_empty_aly_rx[2]),         // input wire [0:0]  probe14                        
//        .probe15        (channel_fsm[2]),               // input wire [3:0]  probe15 
//        .probe16        (channel_count[2]),             // input wire [31:0]  probe16 
//        .probe17        (channel_en[2]),                // input wire [3:0]  probe17 
//        .probe18        (channel_data[2]),              // input wire [0:0]  probe18 
//        .probe19        (data_rd_cnt[2]),               // input wire [255:0]  probe19   
//        .probe20        (error_rd_cnt[2]),              // input wire [59:0]  probe20 
//        .probe21        (ddr3_data_usedw_r2[2])         // input wire [7:0]  probe21
//    ); 

    
//ila_rd_data 
//    u_ila_rd_data 
//    (
//        .clk            (log_clk),                      // input wire clk
//        .probe0         (play_en_r2),                   // input wire [0:0]  probe0          
//        .probe1         (play_num_r2),                  // input wire [3:0]  probe1 
//        .probe2         (downstream_valid_ch_r),        // input wire [3:0]  probe2 
         
//        .probe3         (fifo_rdreq_pcie_ds[2]),        // input wire [0:0]  probe3 
//        .probe4         (fifo_q_pcie_ds[767:512]),      // input wire [255:0]  probe4 
//        .probe5         (fifo_empty_pcie_ds[2]),        // input wire [0:0]  probe5        
//        .probe6         (fifo_wrreq_ddr3_us_p[2]),      // input wire [0:0]  probe6 
//        .probe7         (fifo_data_ddr3_us_p[2]),       // input wire [255:0]  probe7         
//        .probe8         (fifo_prog_full_ddr3_us[2]),    // input wire [0:0]  probe8 
//        .probe9         (fifo_rdreq_ddr3_ds[2]),        // input wire [0:0]  probe9 
//        .probe10        (fifo_q_ddr3_ds[767:512]),      // input wire [255:0]  probe10 
//        .probe11        (fifo_empty_ddr3_ds[2]),        // input wire [0:0]  probe12 
//        .probe12        (fifo_wrreq_aly_tx_r[2]),       // input wire [0:0]  probe12 
//        .probe13        (fifo_data_aly_tx_r[2]),        // input wire [255:0]  probe13 
//        .probe14        (fifo_prog_full_aly_tx_r[2]),   // input wire [0:0]  probe14                        
//        .probe15        (quantity_r),                   // input wire [31:0]  probe15   
//        .probe16        (channel_rate_r[0]),            // input wire [31:0]  probe16  
//        .probe17        (channel_rate_r[1]),            // input wire [31:0]  probe17  
//        .probe18        (channel_rate_r[2]),            // input wire [31:0]  probe18  
//        .probe19        (channel_rate_r[3])             // input wire [31:0]  probe19  
//    ); 
        

endmodule

