`timescale 1ns / 1ps
  
module axi_param_ctrl#
    (
    parameter   integer  C_AXI_ADDR_0    =  32'h4000_F000      ,
    parameter   integer  C_AXI_ADDR_ch0  =  32'h4000_0000      
//    parameter   integer  C_AXI_ADDR_ch1  =  32'h4000_1000      ,
//    parameter   integer  C_AXI_ADDR_ch2  =  32'h4000_2000      ,
//    parameter   integer  C_AXI_ADDR_ch3  =  32'h4000_3000      
    
    )(
    input                   axiclk              ,
    input                   rst_n               ,
    //-----------------------------------------------------//
    // 应用程序交互指令参数
    output                  o_hp_sw_rst_n       ,
    output [31:0]           o_GPIO_en         ,
    output                  o_SyncPulse         ,
 
    output [31:0]           o_DMA_len           ,
    
    input                   i_S_AXIS_tlast      ,
    
//    output  reg [2:0]      work_mode =0          ,           //'0'：空闲模式，'1'：连续采集模式，'2'：脉冲采集模式，'3'：回放模式。
//    output  reg [31:0]     record_delay_time=0   , 
//    output  reg [31:0]     gain_set=0            ,
//    output  reg [0 :0]     clk_sel =0            ,           //'0'：内时钟模式，'1'：外时钟模式，，默认是内时钟；
//    input                   fifo_empty_ddr4_ds1   ,
//    input                   fifo_prog_full_ddr4_us1,
//    input       [31:0]      record_time         ,           //单位 3.33 ns
//    input                   gt_reset_done       ,
//    input       [3:0]       gt_qplllock         ,             
//    input       [3:0]       synced              ,
//    input       [19:0]      ad9518_clk_freq     , 
//    output  reg [31:0]      PS_HP_one_data_number=1024,
//    input                   phy_init_done       ,
    //-----------------------------------------------------//
    // axi interface
    input       [31:0]      S_AXI_WDATA_ext     ,
    input       [31:0]      axi_araddr          ,
    input       [31:0]      axi_awaddr          ,
    output reg  [31:0]      S_AXI_RDATA_ext     ,
    input                   slv_reg_rden        ,
    input                   slv_reg_wren        
    
    // parameter interface
//    output                   hp_sw_rst_n         
    //hp0
//    input                    hp0_wr_fifo_full        ,
//    input                    hp0_wr_fifo_empty       ,
    
//    output reg               hp0_wr_enable           ,
//    output reg  [48:0]       hp0_wr_start_addr       ,
//    output reg  [31:0]       hp0_wr_len              ,
//    input        [31:0]       hp0_wr_len_real        ,
//    input                    hp0_wr_finish           ,
//    //----------PL   hp  read  control
//    input                    hp0_rd_fifo_full        ,
//    input                    hp0_rd_fifo_empty       ,
    
//    output reg               hp0_rd_enable           ,
//    output reg  [48:0]       hp0_rd_start_addr       ,
//    output reg  [31:0]       hp0_rd_len              ,
//    input                    hp0_rd_finish                       
     );
     
 /**********************reg**********************/
    reg                         hp_sw_rst       ;
    reg                         ro_SyncPulse    ;
    reg [31:0]                  ro_GPIO_en    ;
    reg [31:0]                  ro_DMA_len      ;
    
    assign o_hp_sw_rst_n  =     !hp_sw_rst      ;
    assign o_SyncPulse    =     ro_SyncPulse    ;
    assign o_GPIO_en    =       ro_GPIO_en    ;
    assign o_DMA_len      =     ro_DMA_len      ;

    /////////////////////////////////////    AXI write   //////////////////////////////////////////////
    always @( posedge axiclk )
    if ( ~rst_n )
        begin
            hp_sw_rst               <=   1'b0           ; //同步复位               
        end 
    else begin
        if (slv_reg_wren) begin
            case(axi_awaddr)
            // ADC -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
            (C_AXI_ADDR_0        ) :  hp_sw_rst               <=  S_AXI_WDATA_ext[0:0];           //addr=32'hA000_F000  
            (C_AXI_ADDR_0   + 1*4) :  ro_GPIO_en              <=  S_AXI_WDATA_ext[31:0];           //addr=32'hA000_F004                              
            (C_AXI_ADDR_0   + 2*4) :  ro_SyncPulse            <=  S_AXI_WDATA_ext[0:0];           //addr=32'hA000_F008
            (C_AXI_ADDR_0   + 3*4) :  ro_DMA_len              <=  S_AXI_WDATA_ext     ;           //addr=32'hA000_F00C
//            (C_AXI_ADDR_0   + 5*4) :  clk_sel[0:0]            <=  S_AXI_WDATA_ext[0:0];           //addr=32'hA000_F014  
//            (C_AXI_ADDR_0   + 18*4) : PS_HP_one_data_number   <=  S_AXI_WDATA_ext[31:0];          //addr=32'hA000_F014
            endcase
        end 
    end   
            
//    always @( posedge axiclk )
//    if ( ~rst_n )
//        begin
////            PL_PS_RUN_LED          <=    1'b0           ;
//            hp0_wr_enable           <=   1'b0           ;
//            hp0_wr_start_addr       <=   49'h3000_0000   ;
//            hp0_wr_len              <=   32'h0640_0000   ;    // in 8byte                  
//        end 
//    else begin
//        if (slv_reg_wren) begin
//            case(axi_awaddr)
//            // ADC -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*          
//            //------------------------------------------------------------------------------------------------------//                                                                                
//            (C_AXI_ADDR_ch0 + 1*4) :  hp0_wr_enable           <=  S_AXI_WDATA_ext[0]  ;             //addr=32'hA000_0004                              
//            (C_AXI_ADDR_ch0 + 2*4) :  hp0_wr_start_addr[31:0] <=  S_AXI_WDATA_ext     ;             //addr=32'hA000_0008
//            (C_AXI_ADDR_ch0 + 3*4) :  hp0_wr_len              <=  S_AXI_WDATA_ext     ;             //addr=32'hA000_000C                   
//            endcase
//        end 
//    end
    
    /////////////////////////////////////    AXI hp  read data order part //////////////////////////////////////////////
//    always @( posedge axiclk )
//    if ( ~rst_n )
//        begin            
//            hp0_rd_enable           <=   1'b0           ;
//            hp0_rd_start_addr       <=   49'h0000   ;
//            hp0_rd_len              <=   32'h1000   ;    // in 8byte
//     end 
//     else begin
//       if (slv_reg_wren) begin
//           case(axi_awaddr)           
//           // ADC -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*       
//           (C_AXI_ADDR_ch0 + 32'h24)  :  hp0_rd_enable           <=  S_AXI_WDATA_ext[0]  ;             //addr=32'hA000_0024                              
//           (C_AXI_ADDR_ch0 + 32'h28)  :  hp0_rd_start_addr[31:0] <=  S_AXI_WDATA_ext     ;             //addr=32'hA000_0028
//           (C_AXI_ADDR_ch0 + 32'h2C)  :  hp0_rd_len              <=  S_AXI_WDATA_ext     ;             //addr=32'hA000_002C
//           //------------------------------------------------------------------------------------------------------//                      
//           endcase
//       end 
//   end
    
    /////////////////////////////////////    AXI read   //////////////////////////////////////////////
    reg                     check_ch0;
    reg                     check_ch1;
    reg                     check_ch2;
    reg  [31:0]             hp_id_check;        
    always @( posedge axiclk )
    if ( ~rst_n )begin
        hp_id_check <= 0;
    end else begin
        hp_id_check <= 32'h646d_6e00;        // 32'h646d_6e00对应ACSII码 dma00 做为PS端HP的判断

    end
    always @( posedge axiclk )
    if ( ~rst_n )begin
        S_AXI_RDATA_ext <= 32'd0 ;
    end else begin
        if (slv_reg_rden) begin
            case(axi_araddr)            
            // ADC -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
             C_AXI_ADDR_0          : S_AXI_RDATA_ext        <= {31'b0, hp_sw_rst    }    ;    //addr=32'hA000_F000
            (C_AXI_ADDR_0   + 1*4) : S_AXI_RDATA_ext        <= ro_GPIO_en                ;    //addr=32'hA000_F004                              
            (C_AXI_ADDR_0   + 2*4) : S_AXI_RDATA_ext        <= {31'b0,ro_SyncPulse  }    ;   //addr=32'hA000_F008
            (C_AXI_ADDR_0   + 3*4) : S_AXI_RDATA_ext        <=  ro_DMA_len               ;    //addr=32'hA000_F00C
            (C_AXI_ADDR_0   + 4*4) : S_AXI_RDATA_ext        <= {31'b0, i_S_AXIS_tlast}     ;    //addr=32'hA000_F010     
//            (C_AXI_ADDR_0   + 6*4) : begin
//                                     S_AXI_RDATA_ext[7:0]   <= { 7'b0, phy_init_done    }   ;
//                                     S_AXI_RDATA_ext[15:8]  <= { 7'b0, fifo_empty_ddr4_ds1 }   ;
//                                     S_AXI_RDATA_ext[23:16] <= { 7'b0, fifo_prog_full_ddr4_us1}   ;
//                                     S_AXI_RDATA_ext[31:24] <=  8'b0   ;
//                                     end
//            (C_AXI_ADDR_0   + 7*4) : S_AXI_RDATA_ext        <=  record_time[31:0]             ;  
//            (C_AXI_ADDR_0   + 8*4) : S_AXI_RDATA_ext[31:0]  <= { 16'b0, 4'b0,synced,4'b0,
//                                                                gt_qplllock, 7'b0, gt_reset_done}   ;
//            (C_AXI_ADDR_0   + 9*4) : S_AXI_RDATA_ext        <= {12'b0, ad9518_clk_freq[19:0]    };         
//            //hp0
//            (C_AXI_ADDR_ch0      ) : S_AXI_RDATA_ext        <=  hp_id_check                 ;   //addr=32'hA000_0000
//            (C_AXI_ADDR_ch0 +1*4 ) : begin                                                      //addr=32'hA000_0004
//                                     S_AXI_RDATA_ext[7:0]   <= { 7'b0, hp0_wr_enable    }   ;
//                                     S_AXI_RDATA_ext[15:8]  <= { 7'b0, hp0_wr_fifo_full }   ;
//                                     S_AXI_RDATA_ext[23:16] <= { 7'b0, hp0_wr_fifo_empty}   ;
//                                     S_AXI_RDATA_ext[31:24] <= { 7'b0, hp0_wr_finish    }   ;
//                                     end
//            (C_AXI_ADDR_ch0 +2*4) :  S_AXI_RDATA_ext        <=  hp0_wr_start_addr[31:0]     ;   //addr=32'hA000_0008
//            (C_AXI_ADDR_ch0 +3*4) :  S_AXI_RDATA_ext        <=  hp0_wr_len                  ;   //addr=32'hA000_000C    
//            (C_AXI_ADDR_ch0 +8*4) :  S_AXI_RDATA_ext        <=  hp0_wr_len_real             ;   //addr=32'hA000_0020  
            
//            (C_AXI_ADDR_ch0 +32'h24) :  begin
//                                     S_AXI_RDATA_ext[7:0]   <= { 7'b0, hp0_rd_enable    }   ;   //addr=32'hA000_0100   
//                                     S_AXI_RDATA_ext[15:8]  <= { 7'b0, hp0_rd_fifo_full }   ;
//                                     S_AXI_RDATA_ext[23:16] <= { 7'b0, hp0_rd_fifo_empty}   ;
//                                     S_AXI_RDATA_ext[31:24] <= { 7'b0, hp0_rd_finish    }   ; 
//                                     end
//            (C_AXI_ADDR_ch0 +32'h28) :  S_AXI_RDATA_ext     <=  hp0_rd_start_addr[31:0]     ;   //addr=32'hA000_0028
//            (C_AXI_ADDR_ch0 +32'h2C) :  S_AXI_RDATA_ext     <=  hp0_rd_len                  ;   //addr=32'hA000_002C   
            //------------------------------------------------------------------------------------------------------//  
            default:                 S_AXI_RDATA_ext        <=  32'h0 ;
            endcase
        end 
    end
       
//  ila_0 your_instance_name (
//	.clk(axiclk), // input wire clk

//	.probe0(rst_n                  ), // input wire [0:0]  probe0  
//	.probe1(hp0_rd_start_addr[31:0]), // input wire [0:0]  probe1 
//	.probe2(hp0_rd_len             ), // input wire [0:0]  probe2
//	.probe3(hp0_wr_enable          ), // input wire [0:0]  probe0  
//	.probe4(hp0_wr_start_addr[31:0]), // input wire [0:0]  probe1 
//	.probe5(hp0_wr_len             ), // input wire [0:0]  probe2
//	.probe6(S_AXI_WDATA_ext        ), // input wire [0:0]  probe2
//	.probe7(axi_araddr             ), // input wire [0:0]  probe2
//	.probe8(axi_awaddr             ), // input wire [0:0]  probe2
//	.probe9(S_AXI_RDATA_ext        ), // input wire [0:0]  probe2
//	.probe10(slv_reg_rden          ), // input wire [0:0]  probe2
//	.probe11(slv_reg_wren          )  // input wire [0:0]  probe2

//);

ila_param ila_param_inst (
	.clk       (axiclk), // input wire clk


	.probe0    (S_AXI_WDATA_ext), // input wire [31:0]  probe0  
	.probe1    (axi_araddr     ), // input wire [31:0]  probe1 
	.probe2    (axi_awaddr     ), // input wire [31:0]  probe2 
	.probe3    (S_AXI_RDATA_ext), // input wire [31:0]  probe3 
	.probe4    (slv_reg_rden   ), // input wire [0:0]  probe4 
	.probe5    (slv_reg_wren   ), // input wire [0:0]  probe5 
	.probe6    (o_hp_sw_rst_n ), // input wire [0:0]  probe6 
	.probe7    (o_SyncPulse   ), // input wire [0:0]  probe7 
	.probe8    (ro_GPIO_en   ),  // input wire [31:0]  probe8 
	.probe9    (o_DMA_len     ), // input wire [31:0]  probe9 
	.probe10   (rst_n) // input wire [0:0]  probe10
);              

endmodule