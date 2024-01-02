`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         ACQNOVA
// Engineer:       Long Lian
// 
// Create Date: 2023/03/01 18:32:57
// Design Name: 
// Module Name: reg_file
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


module reg_file
    # (
    parameter                           UART_CHANNEL            =   2,
    parameter                           REG_NUM                 =   50,
    parameter                           BLK2711_CHANNEL         =   4,
    parameter                           AXI_ADDR_WIDTH          =   32,
    parameter                           AXI_DATA_WIDTH          =   32 
    )
    
    (
        // Clock and Reset# Interface
    input                               log_clk                    ,// Logic Clock, Rising Edge
    input                               log_rst_n                  ,// Logic Reset, Low Active 
        
        // Software Reset#
    output                              sw_reset_n                 ,// Software Reset#  
                
        // PCIE Ctrl Status Signals
    input                               pcie_lnk_up                ,
    input                               upstream_valid             ,
    input                               downstream_valid           ,
    input              [  31:0]         upstream_valid_ch          ,
    input              [  31:0]         downstream_valid_ch        ,
    output             [  31:0]         downstream_flag            ,
        
        // Data Path Select
    output                              record_en                  ,
    output                              play_en                    ,
        
        // Data Path Ctrl
    output             [  31:0]         record_num                 ,
    output             [  31:0]         play_num                   ,

        // DMA Transfer Length
    output             [  31:0]         dma_xfer_len               ,
        
        // Status Signals
    input              [  15:0]         measured_temp              ,
    input              [  15:0]         measured_vcc               ,
    input                               phy_init_done              ,
        //pps_time
    input              [  31:0]         pps_time                   ,
        //pwm
    output             [  15:0]         duty_cycle1                ,
    output             [  15:0]         duty_cycle2                ,
        //BLK2711
    output             [BLK2711_CHANNEL-1:0]hf_lb_en                   ,
    output             [BLK2711_CHANNEL*16-1:0]send_k_num                 ,
    output             [BLK2711_CHANNEL-1:0]tx_send_en                 ,
    output             [BLK2711_CHANNEL-1:0]data_mod                   ,
    output             [BLK2711_CHANNEL-1:0]loop_mod                   ,

        //uart0~5
    output             [UART_CHANNEL-1:0]fifo_uart_tx_wren          ,
    output             [UART_CHANNEL-1:0]uart_tx_wren_start         ,
    output             [UART_CHANNEL-1:0]uart_tx_wren_end           ,
    output             [UART_CHANNEL*8-1:0]uart_tx_data               ,
    input              [UART_CHANNEL-1:0]fifo_uart_tx_prog_full     ,

    output             [UART_CHANNEL*16-1:0]uart_bps                   ,//uart波特率
    output             [UART_CHANNEL*4-1:0]uart_data_bit              ,//数据位
    output             [UART_CHANNEL*2-1:0]uart_stop_bit              ,//停止位
    output             [UART_CHANNEL*2-1:0]uart_parity_bit            ,//校验位

    output             [UART_CHANNEL-1:0]fifo_uart_rx_rden          ,
    input              [UART_CHANNEL-1:0]fifo_uart_rx_empty         ,
    input              [UART_CHANNEL*8-1:0]uart_rx_data               ,

    //pps_uart
    output                              pps_fifo_uart_tx_wren      ,
    output             [   7:0]         pps_uart_tx_data           ,
    output                              pps_uart_tx_wren_start     ,
    output                              pps_uart_tx_wren_end       ,
    input                               pps_uart_tx_prog_full      ,

    output             [  15:0]         pps_uart_bps               ,//uart波特率
    output             [   7:0]         pps_uart_data_bit          ,//数据位
    output             [   1:0]         pps_uart_stop_bit          ,//停止位
    output             [   1:0]         pps_uart_parity_bit        ,//校验位

    output                              pps_fifo_uart_rx_rden      ,
    input                               pps_fifo_uart_rx_empty     ,
    input              [   7:0]         pps_uart_rx_data           ,

    //ad7606
    output                              ad7606_start_signal        ,
    output             [   2:0]         os                         ,
    input              [  15:0]         ch1_data                   ,
    input              [  15:0]         ch2_data                   ,
    input              [  15:0]         ch3_data                   ,
    input              [  15:0]         ch4_data                   ,
    input              [  15:0]         ch5_data                   ,
    input              [  15:0]         ch6_data                   ,
    input              [  15:0]         ch7_data                   ,
    input              [  15:0]         ch8_data                   ,
		// RAM Interface                                                	
    input                               ram_wren                   ,// Write Enable
    input              [AXI_ADDR_WIDTH-1:0]ram_waddr                  ,// Write Address
    input              [AXI_DATA_WIDTH-1:0]ram_wdata                  ,// Write Data
    input                               ram_rden                   ,// Read Enable
    input              [AXI_ADDR_WIDTH-1:0]ram_raddr                  ,// Read Address
    output             [AXI_DATA_WIDTH-1:0]ram_rdata                   // Read Data
    );
    
    
//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
    wire                                    sys_rst_n;
    

//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
reg                                     log_rst_n_r     =   1'b0   ;
reg                                     log_rst_n_r2    =   1'b0   ;

reg                    [  15:0]         measured_temp_r =   16'd0  ;
reg                    [  15:0]         measured_temp_r2=   16'd0  ;
reg                    [  15:0]         measured_vcc_r  =   16'd0  ;
reg                    [  15:0]         measured_vcc_r2 =   16'd0  ;
    
// RAM Interface
reg                                     ram_wren_r      =   1'b0   ;
reg         [AXI_ADDR_WIDTH-1:0]        ram_waddr_r     =   {AXI_ADDR_WIDTH{1'b0}};
reg         [AXI_DATA_WIDTH-1:0]        ram_wdata_r     =   {AXI_DATA_WIDTH{1'b0}};
reg                                     ram_rden_r      =   1'b0   ;
reg         [AXI_ADDR_WIDTH-1:0]        ram_raddr_r     =   {AXI_ADDR_WIDTH{1'b0}};
reg         [AXI_DATA_WIDTH-1:0]        ram_rdata_r     =   {AXI_DATA_WIDTH{1'b0}};
reg         [31:0]                      wr_reg_r            [REG_NUM-1:0];
reg         [31:0]                      rd_reg_r            [REG_NUM-1:0];

reg                    [  15:0]         ch1_data_r1,ch1_data_r2    ;
reg                    [  15:0]         ch2_data_r1,ch2_data_r2    ;
reg                    [  15:0]         ch3_data_r1,ch3_data_r2    ;
reg                    [  15:0]         ch4_data_r1,ch4_data_r2    ;
reg                    [  15:0]         ch5_data_r1,ch5_data_r2    ;
reg                    [  15:0]         ch6_data_r1,ch6_data_r2    ;
reg                    [  15:0]         ch7_data_r1,ch7_data_r2    ;
reg                    [  15:0]         ch8_data_r1,ch8_data_r2    ;

reg                                     pcie_lnk_up_r1,pcie_lnk_up_r2;
reg                                     phy_init_done_r1,phy_init_done_r2;
// ********************************************************************************** // 
//---------------------------------------------------------------------
// I/O Connections assignments
//---------------------------------------------------------------------    
assign          sys_rst_n           =   log_rst_n_r2;
assign          ram_rdata           =   ram_rdata_r;


always@(posedge log_clk)
    begin
        pcie_lnk_up_r1     <=  pcie_lnk_up;
        pcie_lnk_up_r2    <=  pcie_lnk_up_r1;
    end
always@(posedge log_clk)
    begin
        phy_init_done_r1     <=  phy_init_done;
        phy_init_done_r2    <=  phy_init_done_r1;
    end

//7606
always@(posedge log_clk)
    begin
        ch1_data_r1     <=  ch1_data;
        ch1_data_r2    <=  ch1_data_r1;
    end
always@(posedge log_clk)
    begin
        ch2_data_r1     <=  ch2_data;
        ch2_data_r2    <=  ch2_data_r1;
    end
always@(posedge log_clk)
    begin
        ch3_data_r1     <=  ch3_data;
        ch3_data_r2    <=  ch3_data_r1;
    end
always@(posedge log_clk)
    begin
        ch4_data_r1     <=  ch4_data;
        ch4_data_r2    <=  ch4_data_r1;
    end
always@(posedge log_clk)
    begin
        ch5_data_r1     <=  ch5_data;
        ch5_data_r2    <=  ch5_data_r1;
    end
always@(posedge log_clk)
    begin
        ch6_data_r1     <=  ch6_data;
        ch6_data_r2    <=  ch6_data_r1;
    end
always@(posedge log_clk)
    begin
        ch7_data_r1     <=  ch7_data;
        ch7_data_r2    <=  ch7_data_r1;
    end
// always@(posedge log_clk)
//     begin
//         ch8_data_r1     <=  ch8_data;
//         ch8_data_r2    <=  ch8_data_r1;
//     end
//7606end
always@(posedge log_clk)
    begin
        log_rst_n_r     <=  log_rst_n;
        log_rst_n_r2    <=  log_rst_n_r;
    end
    
always@(posedge log_clk)
    begin
        measured_temp_r     <=  measured_temp;
        measured_temp_r2    <=  measured_temp_r;
    end
    
always@(posedge log_clk)
    begin
        measured_vcc_r     <=  measured_vcc;
        measured_vcc_r2    <=  measured_vcc_r;
    end

always@(posedge log_clk or negedge sys_rst_n)
    begin
        if(!sys_rst_n)begin
            ram_wren_r <= 1'b0;
            ram_rden_r <= 1'b0;
        end else begin
            ram_wren_r <= ram_wren;
            ram_rden_r <= ram_rden;
        end
    end
    
always@(posedge log_clk)
    begin
        ram_waddr_r <= ram_waddr;
        ram_wdata_r <= ram_wdata;
        ram_raddr_r <= ram_raddr;
    end   


generate
    begin : reg_ctrl
        genvar  i;
        for(i = 0; i <= REG_NUM - 1; i = i + 1)
            begin : num
                always@(posedge log_clk or negedge sys_rst_n)
                    begin
                        if(!sys_rst_n)begin
                            wr_reg_r[i] <=  32'h0000_0000;
                        end else if(ram_wren_r && (ram_waddr_r[31:2] == i))begin
                            wr_reg_r[i] <=  ram_wdata_r;
                        end else begin
                            wr_reg_r[i] <=  wr_reg_r[i];
                        end
                    end
            end
    end
endgenerate


// ********************************************************************************** // 
//---------------------------------------------------------------------
// Start of Register File Code
//---------------------------------------------------------------------    
// 0x00(DWORD)/0x00(Byte) --> Control(CTRL) Register
assign          sw_reset_n          =   !wr_reg_r[0][0];
assign          record_en           =   wr_reg_r[0][1];
assign          play_en             =   wr_reg_r[0][2];

always@(posedge log_clk)
    begin
        rd_reg_r[0][29:0]   <=  wr_reg_r[0][29:0];
        rd_reg_r[0][30]     <=  upstream_valid;
        rd_reg_r[0][31]     <=  downstream_valid;
    end

// 0x01(DWORD)/0x04(Byte)
always@(posedge log_clk)
    begin
        rd_reg_r[1] <=  upstream_valid_ch;
    end

// 0x02(DWORD)/0x08(Byte) 
assign      downstream_flag =   wr_reg_r[2];    

// 0x03(DWORD)/0x0C(Byte)
always@(posedge log_clk)
    begin
        rd_reg_r[3] <=  downstream_valid_ch;
    end

// 0x04(DWORD)/0x10(Byte)
assign      record_num      =   wr_reg_r[4];    

// 0x05(DWORD)/0x14(Byte)
assign      play_num        =   wr_reg_r[5];    

// 0x06(DWORD)/0x18(Byte)
reg     [31:0]      dma_xfer_len_r  =   32'h0100_0000;   // 16MB
  
assign      dma_xfer_len    =   dma_xfer_len_r;    
      
always@(posedge log_clk or negedge sys_rst_n)
    begin
        if(!sys_rst_n)begin
            dma_xfer_len_r  <= 32'h0100_0000;
        end else if(ram_wren_r && (ram_waddr_r[9:2] == 8'h06))begin
            dma_xfer_len_r  <= ram_wdata_r;
        end else begin
            dma_xfer_len_r  <= dma_xfer_len_r;
        end
    end

// 0x07(DWORD)/0x1C(Byte)
always@(posedge log_clk)
    begin
        rd_reg_r[7] <=  {16'h0000, measured_temp_r2};
    end

// 0x08(DWORD)/0x20(Byte)
always@(posedge log_clk)
    begin
        rd_reg_r[8] <=  {16'h0000, measured_vcc_r2};
    end

// 0x09(DWORD)/0x24(Byte)
always@(posedge log_clk)
    begin
        rd_reg_r[9][0]   <=  pcie_lnk_up_r2;
        rd_reg_r[9][1]   <=  phy_init_done_r2;
    end

//---------------------------------------blk2711寄存器[0~3]--------------------------------//

// 0x0A(DWORD)/0x28(Byte)
// 0x0B(DWORD)/0x2C(Byte)
generate
    begin
        genvar i;
        for(i=0;i<BLK2711_CHANNEL;i=i+1)
            begin:blk_mod
                assign tx_send_en[i] = wr_reg_r[10][4*i];
                assign loop_mod[i] = wr_reg_r[10][4*i+1];
                assign data_mod[i] = wr_reg_r[10][4*i+2];
                assign hf_lb_en[i] = wr_reg_r[10][4*i+3];

                assign send_k_num[16*i+15:16*i] = wr_reg_r[11+i][15:0];
            end
    end
endgenerate
// 0x0C(DWORD)/0x30(Byte)
// 0x0D(DWORD)/0x34(Byte)
// 0x0E(DWORD)/0x38(Byte)
//---------------------------------------pps_time--------------------------------//
// 0x0F(DWORD)/0x3C(Byte)
always@(posedge log_clk)
begin
    rd_reg_r[15] <= pps_time;
end
//---------------------------------------PWM--------------------------------//
// 0x10(DWORD)/0x40(Byte)
assign duty_cycle1 = wr_reg_r[16][15:0];
assign duty_cycle2 = wr_reg_r[16][31:16];
//---------------------------------------uart_empty_full--------------------------------//
// 0x11(DWORD)/0x44(Byte)
always@(posedge log_clk)
begin
    rd_reg_r[17][0] <= fifo_uart_rx_empty[0];
    rd_reg_r[17][1] <= fifo_uart_rx_empty[1];
    rd_reg_r[17][2] <= 1 ; //fifo_uart_rx_empty[2];
    rd_reg_r[17][3] <= 1 ; //fifo_uart_rx_empty[3];
    rd_reg_r[17][4] <= 1 ; //fifo_uart_rx_empty[4];
    rd_reg_r[17][5] <= 1 ; //fifo_uart_rx_empty[5];
    rd_reg_r[17][6] <= pps_fifo_uart_rx_empty;

    rd_reg_r[17][16] <= fifo_uart_tx_prog_full[0];
    rd_reg_r[17][17] <= fifo_uart_tx_prog_full[1];
    rd_reg_r[17][18] <= 1 ; //fifo_uart_tx_prog_full[2];
    rd_reg_r[17][19] <= 1 ; //fifo_uart_tx_prog_full[3];
    rd_reg_r[17][20] <= 1 ; //fifo_uart_tx_prog_full[4];
    rd_reg_r[17][21] <= 1 ; //fifo_uart_tx_prog_full[5];
    rd_reg_r[17][22] <= pps_uart_tx_prog_full;
end
//---------------------------------------uart[0~6]--------------------------------//
generate
    begin
        genvar i;
        for(i=0;i<UART_CHANNEL;i=i+1)
            begin:uart
                assign fifo_uart_tx_wren[i] = ram_wren_r && (ram_waddr_r[31:2] == 18+3*i) && !fifo_uart_tx_prog_full[i];
                assign uart_tx_data[8*i+7:8*i] = wr_reg_r[18+3*i][7:0];
                assign uart_tx_wren_start[i] = wr_reg_r[18+3*i][30];
                assign uart_tx_wren_end[i] = wr_reg_r[18+3*i][31];

                assign uart_data_bit[4*i+3:4*i] = wr_reg_r[19+3*i][3:0];
                assign uart_stop_bit[2*i+1:2*i] = wr_reg_r[19+3*i][5:4];
                assign uart_parity_bit[2*i+1:2*i] = wr_reg_r[19+3*i][7:6];
                assign uart_bps[16*i+15:16*i] = wr_reg_r[19+3*i][31:16];
                
                assign fifo_uart_rx_rden[i] = ram_rden_r && (ram_raddr_r[31:2] == 20+3*i) && !fifo_uart_rx_empty[i];
                always@(posedge log_clk)
                    begin
                        rd_reg_r[20+3*i][7:0] <= uart_rx_data[8*i+7:8*i];
                    end
            end
    end
endgenerate
// 0x12(DWORD)/0x48(Byte)
// 0x13(DWORD)/0x4C(Byte)
// 0x14(DWORD)/0x50(Byte)
// 0x15(DWORD)/0x54(Byte)
// 0x16(DWORD)/0x58(Byte)
// 0x17(DWORD)/0x5C(Byte)
// 0x18(DWORD)/0x60(Byte)
// 0x19(DWORD)/0x64(Byte)
// 0x1A(DWORD)/0x68(Byte)
// 0x1B(DWORD)/0x6C(Byte)
// 0x1C(DWORD)/0x70(Byte)
// 0x1D(DWORD)/0x74(Byte)
// 0x1E(DWORD)/0x78(Byte)
// 0x1F(DWORD)/0x7C(Byte)
// 0x20(DWORD)/0x80(Byte)
// 0x21(DWORD)/0x84(Byte)
// 0x22(DWORD)/0x88(Byte)
// 0x23(DWORD)/0x8C(Byte)
//---------------------------------------pps--------------------------------//
// 0x24(DWORD)/0x90(Byte)
assign pps_fifo_uart_tx_wren = ram_wren_r && (ram_waddr_r[31:2] == 8'h24) && !pps_uart_tx_prog_full;
assign pps_uart_tx_data = wr_reg_r[36][7:0];
assign pps_uart_tx_wren_start = wr_reg_r[36][30];
assign pps_uart_tx_wren_end = wr_reg_r[36][31];
// 0x25(DWORD)/0x94(Byte)
assign pps_uart_data_bit = wr_reg_r[37][3:0];
assign pps_uart_stop_bit = wr_reg_r[37][5:4];
assign pps_uart_parity_bit = wr_reg_r[37][7:6];
assign pps_uart_bps = wr_reg_r[37][31:16];
// 0x26(DWORD)/0x98(Byte)
assign pps_fifo_uart_rx_rden = ram_rden_r && (ram_raddr_r[31:2] == 8'h26) && !pps_fifo_uart_rx_empty;
always@(posedge log_clk)
    begin
        rd_reg_r[38][7:0] <= pps_uart_rx_data;
    end
//---------------------------------------AD7606--------------------------------//
// 0x27(DWORD)/0x9C(Byte)
assign os = wr_reg_r[39][2:0];
assign ad7606_start_signal = wr_reg_r[39][31];
// 0x28(DWORD)/0xA0(Byte)
always@(posedge log_clk)
    begin
        rd_reg_r[40][15:0] <= ch1_data_r2;
        rd_reg_r[40][31:16] <= ch2_data_r2;
    end
// 0x29(DWORD)/0xA4(Byte)
always@(posedge log_clk)
    begin
        rd_reg_r[41][15:0] <= ch3_data_r2;
        rd_reg_r[41][31:16] <= ch4_data_r2;
    end
// 0x2A(DWORD)/0xA8(Byte)
always@(posedge log_clk)
    begin
        rd_reg_r[42][15:0] <= ch5_data_r2;
        rd_reg_r[42][31:16] <= ch6_data_r2;
    end
// 0x2B(DWORD)/0xAC(Byte)
// always@(posedge log_clk)
//     begin
//         rd_reg_r[43][15:0] <= ch7_data_r2;
//         rd_reg_r[43][31:16] <= ch8_data_r2;
//     end
// 0x2C(DWORD)/0xB0(Byte)
// 0x2D(DWORD)/0xB4(Byte)
// 0x2E(DWORD)/0xB8(Byte)
// 0x2F(DWORD)/0xBC(Byte)
// 0x30(DWORD)/0xC0(Byte)
// 0x31(DWORD)/0xC4(Byte)
// 0x32(DWORD)/0xC8(Byte)
// 0x33(DWORD)/0xCC(Byte)  
// 0x34(DWORD)/0xD0(Byte)  
// 0x35(DWORD)/0xD4(Byte)  
// 0x36(DWORD)/0xD8(Byte)  
// 0x37(DWORD)/0xDC(Byte)  
// 0x38(DWORD)/0xE0(Byte)  
// 0x39(DWORD)/0xE4(Byte)  
// 0x3A(DWORD)/0xE8(Byte)  
// 0x3B(DWORD)/0xEC(Byte)  
// 0x3C(DWORD)/0xF0(Byte)  
// 0x3D(DWORD)/0xF4(Byte)  
// 0x3E(DWORD)/0xF8(Byte)  
// 0x3F(DWORD)/0xFC(Byte)  
// 0x40(DWORD)/0x100(Byte) 
// 0x41(DWORD)/0x104(Byte) 
// 0x42(DWORD)/0x108(Byte) 
// 0x43(DWORD)/0x10C(Byte) 
// 0x44(DWORD)/0x110(Byte) 
// 0x45(DWORD)/0x114(Byte) 
// 0x46(DWORD)/0x118(Byte)


// Read Register File
always@(posedge log_clk or negedge sys_rst_n)
    begin
        if(!sys_rst_n)begin
            ram_rdata_r  <=  32'd0;
        end else if(ram_raddr_r[31:2] < REG_NUM) begin
            case(ram_raddr_r[31:2])
                30'd0   :  begin   ram_rdata_r  <=  rd_reg_r[0];        end     // 0x00(DWORD)/0x00(Byte) 
                30'd1   :  begin   ram_rdata_r  <=  rd_reg_r[1];        end     // 0x01(DWORD)/0x04(Byte)                  
                30'd3   :  begin   ram_rdata_r  <=  rd_reg_r[3];        end     // 0x03(DWORD)/0x0C(Byte) 
                30'd7   :  begin   ram_rdata_r  <=  rd_reg_r[7];        end     // 0x07(DWORD)/0x1C(Byte) 
                30'd8   :  begin   ram_rdata_r  <=  rd_reg_r[8];        end     // 0x08(DWORD)/0x20(Byte) 
                30'd9   :  begin   ram_rdata_r  <=  rd_reg_r[9];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd15  :  begin   ram_rdata_r  <=  rd_reg_r[15];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd17  :  begin   ram_rdata_r  <=  rd_reg_r[17];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd20  :  begin   ram_rdata_r  <=  rd_reg_r[20];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd23  :  begin   ram_rdata_r  <=  rd_reg_r[23];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd26  :  begin   ram_rdata_r  <=  rd_reg_r[26];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd29  :  begin   ram_rdata_r  <=  rd_reg_r[29];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd32  :  begin   ram_rdata_r  <=  rd_reg_r[32];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd35  :  begin   ram_rdata_r  <=  rd_reg_r[35];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd38  :  begin   ram_rdata_r  <=  rd_reg_r[38];        end     // 0x09(DWORD)/0x24(Byte) 
                //ad7606
                30'd40  :  begin   ram_rdata_r  <=  rd_reg_r[40];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd41  :  begin   ram_rdata_r  <=  rd_reg_r[41];        end     // 0x09(DWORD)/0x24(Byte) 
                30'd42  :  begin   ram_rdata_r  <=  rd_reg_r[42];        end     // 0x09(DWORD)/0x24(Byte) 
                // 30'd43  :  begin   ram_rdata_r  <=  rd_reg_r[43];        end     // 0x09(DWORD)/0x24(Byte) 
                default :
                    begin
                        ram_rdata_r <=  wr_reg_r[ram_raddr_r[31:2]]; 
                    end
            endcase
        end else begin
            ram_rdata_r <=  32'hAAAA_5555;
        end
    end

// ********************************************************************************** // 
//---------------------------------------------------------------------
// DEBUG
//---------------------------------------------------------------------   
ila_ram_reg u_ila_ram_reg
    (
    .clk                               (log_clk                   ),// input wire clk
    .probe0                            (ram_wren_r                ),// input wire [0:0]  probe0  
    .probe1                            (ram_waddr_r               ),// input wire [31:0]  probe1 
    .probe2                            (ram_wdata_r               ),// input wire [31:0]  probe2 
    .probe3                            (ram_rden_r                ),// input wire [0:0]  probe3 
    .probe4                            (ram_raddr_r               ),// input wire [31:0]  probe4 
    .probe5                            (ram_rdata_r               ),// input wire [31:0]  probe5 
    .probe6                            (wr_reg_r[10]              ),// input wire [31:0]  probe6
    .probe7                            (rd_reg_r[17]              ),// input wire [31:0]  probe7
    .probe8                            (rd_reg_r[15]              ),// input wire [31:0]  probe8
    .probe9                            (rd_reg_r[0]               ) // input wire [31:0]  probe9
    );

// vio_ram_reg vio_ram_reg_inst (
//     .clk                               (log_clk                   ),// input wire clk
//     .probe_in0                         (rd_reg_r[7]               ),// input wire [31 : 0] probe_in0
//     .probe_in1                         (rd_reg_r[8]               ) // input wire [31 : 0] probe_in1
// );
endmodule