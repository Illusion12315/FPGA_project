`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/20 10:43:39
// Design Name: 
// Module Name: ad9680_cfg_600msps
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


module sim_spi(                   //3-wire spi     addr 13bit   data 8bit
input                   clk,
input                   rst_n,

output                  sclk,
output                  mosi,
output                  csb,
//output                  reset,

output reg             finish

);

//debug

wire[7:0]                       vio_test_mode;
wire[7:0]                       vio_test_mode_jesd;
wire[7:0]                       vio_reg_data;
wire[15:0]                      vio_addr_rd;
wire                            vio_rd_en;
reg                             vio_rd_en_d0 = 'd0;
wire                            vio_rd_en_pos;


wire                             sdo;
wire                             sdi;
wire                             sdio_out_en;
reg                              sdio_out_en_reg = 'd0;

assign sdio_out_en = sdio_out_en_reg;

assign mosi = 1'b1 ? sdi : 1'bz;
//assign sdo = mosi;

parameter                       F25M_2 = 8;
parameter                       F25M = 16;
reg                              SDO_r1,SDO_r2;// ‰»Îºƒ¥Ê
always@(posedge clk or negedge rst_n)
if(~rst_n) begin
    SDO_r1 <= 0;
    SDO_r2 <= 0;
end
else begin
    SDO_r1 <= sdo;
    SDO_r2 <= SDO_r1;
end  

parameter config_l = 5;  

reg [31:0]                   adder [0:5] ;
reg [31:0]                   sdata [0:5] ; 
reg[15:0]                   time_cnt;

always@(posedge clk)
begin

    adder[0 ] <= 32'h43C0_3100;  sdata[0 ] <= 32'h2CCC_1122;        //7:4 ƒ£ƒ‚ ‰»Î≤Ó∑÷∂ÀΩ” 0000 = 400≈∑ƒ∑ 0001 = 200≈∑ƒ∑ 0010 = 100≈∑ƒ∑ 0110 = 50≈∑ƒ∑
    adder[1 ] <= 32'h43C0_3100;  sdata[1 ] <= 32'h44CC_1122;        //7:4 0000 = 1.0xª∫≥ÂµÁ¡˜(ƒ¨»œ) 0001 = 1.5xª∫≥ÂµÁ¡˜ 0010 = 2.0xª∫≥ÂµÁ¡˜ 0011 = 2.5xª∫≥ÂµÁ¡˜ 0100 = 3.0xª∫≥ÂµÁ¡˜ 0101 = 3.5xª∫≥ÂµÁ¡˜ 1111 = 8.5xª∫≥ÂµÁ¡˜

    adder[2] <= 32'h8025_1122;  sdata[2] <= 32'h08CC_1122;        
    adder[3] <= 32'h8028_1122;  sdata[3] <= 32'h00CC_1122;        
    adder[4] <= 32'h8030_1122;  sdata[4] <= 32'h18CC_1122;       
    adder[5] <= 32'h803F_1122;  sdata[5] <= 32'h80CC_1122;       
   
//   sdata[0 ] <= 8'h2C;        //7:4 ƒ£ƒ‚ ‰»Î≤Ó∑÷∂ÀΩ” 0000 = 400≈∑ƒ∑ 0001 = 200≈∑ƒ∑ 0010 = 100≈∑ƒ∑ 0110 = 50≈∑ƒ∑
//   sdata[1 ] <= 8'h44;        //7:4 0000 = 1.0xª∫≥ÂµÁ¡˜(ƒ¨»œ) 0001 = 1.5xª∫≥ÂµÁ¡˜ 0010 = 2.0xª∫≥ÂµÁ¡˜ 0011 = 2.5xª∫≥ÂµÁ¡˜ 0100 = 3.0xª∫≥ÂµÁ¡˜ 0101 = 3.5xª∫≥ÂµÁ¡˜ 1111 = 8.5xª∫≥ÂµÁ¡˜

//    sdata[2] <= 8'h08;        
//    sdata[3] <= 8'h00;        
//    sdata[4] <= 8'h18;       
//    sdata[5] <= 8'h80;    

          
end 

(*MARK_debug="true"*)  reg                  rSCLK;
(*MARK_debug="true"*)  reg                  rCSN;
(*MARK_debug="true"*)  reg                  rSDI;

(*MARK_debug="true"*)  reg[31:0]            cnt;// ±÷”º∆ ˝
(*MARK_debug="true"*)  reg [7:0]            k;//ºƒ¥Ê∆˜–Ú¡–º∆ ˝
(*MARK_debug="true"*)  reg [8:0]            i; //◊¥Ã¨

(*MARK_debug="true"*)  reg [63:0]           txdata;
(*MARK_debug="true"*)  reg [63:0]           rxdata;


assign sdi = rSDI;
assign sclk = rSCLK;
assign csb = rCSN;  


always@(posedge clk or negedge rst_n) 
if(~rst_n)
begin
    i <= 0;
    k <= 0;
    cnt  <= 0;
    txdata <= 0;
    rxdata <= 0;
    finish <= 0;
    time_cnt <= 0;
//    reset_reg <= 0;
    
    rSCLK <= 1;
    rCSN <= 1;//avtive low
    rSDI <= 0;
    sdio_out_en_reg <= 0;
end  
else
begin
    case( i )
        9'd0:
            begin                 
                rSCLK  <= 1;
                rCSN  <= 1;//avtive low
                rSDI   <= 0;
                finish <= 1'b0;
                k  <= 0;
                txdata <= 0;
                rxdata <= 0;
                sdio_out_en_reg <= 0;
                
                i <= 1;
//                if(cnt>=32'd300000) begin cnt<=0;i<=1; end
////                else if(cnt >= 32'd30000) begin cnt <= cnt + 1; reset_reg <= 0; end
////                else if(cnt >= 32'd1000) begin cnt <= cnt + 1; reset_reg <= 1; end
//                else         begin cnt<=cnt+1'b1; end
                
            end
        9'd1:
            begin
               txdata <= {adder[k],sdata[k]};     
               i  <= i + 1'b1;
            end
        9'd2:
            begin
               rCSN <= 0;
               if(cnt==F25M-1)   begin cnt <= 0;i<=i+1'b1;end
               else              begin cnt <= cnt +1'b1;   end
            end     
        8'd3:
            begin
                i <= 200;
//                  i <= 216;
            end        
                                
       9'd200,9'd201,9'd202,9'd203,9'd204,9'd205,9'd206,9'd207,9'd208,9'd209,
       9'd210,9'd211,9'd212,9'd213,9'd214,9'd215,                     
       9'd216,9'd217,9'd218,9'd219,9'd220,9'd221,9'd222,9'd223,9'd224,9'd225,
       9'd226,9'd227,9'd228,9'd229,9'd230,9'd231:
        begin
           sdio_out_en_reg <= 1;
           rSDI <=  txdata[263-i];                  //–¥ºƒ¥Ê∆˜
           if(cnt==F25M_2) rxdata[231-i] <= SDO_r2;    //∂¡ºƒ¥Ê∆˜
           
           if(cnt==0)         rSCLK <= 1'b0;
           if(cnt==F25M_2)    rSCLK <= 1'b1; 
           
           if(cnt==F25M-1)   begin cnt <= 0;i<=i+1'b1;end
           else              begin cnt <= cnt +1'b1;   end
       end                
                                     
       9'd232,9'd233,9'd234,9'd235,
       9'd236,9'd237,9'd238,9'd239,
       9'd240,9'd241,9'd242,9'd243,
       9'd244,9'd245,9'd246,9'd247,
       
       9'd248,9'd249,9'd250,9'd251,
       9'd252,9'd253,9'd254,9'd255,
       9'd256,9'd257,9'd258,9'd259,
       9'd260,9'd261,9'd262,9'd263:
        begin
           rSDI <=  txdata[263-i];                  //–¥ºƒ¥Ê∆˜
           if(cnt==F25M_2) rxdata[263-i] <= SDO_r2;    //∂¡ºƒ¥Ê∆˜
           
           sdio_out_en_reg <= !txdata[63];
           
           if(cnt==0)         rSCLK <= 1'b0;
           if(cnt==F25M_2)    rSCLK <= 1'b1; 
           
           if(cnt==F25M-1)   begin cnt <= 0;i<=i+1'b1;end
           else              begin cnt <= cnt +1'b1;   end
       end       
       
       9'd264:
           if(cnt==F25M-1)   begin cnt <= 0;i<=i+1'b1;end
           else              begin cnt <= cnt +1'b1;  end               
               
       9'd265:
        begin    
           rCSN <= 1;              
           if(cnt==32'd500)   begin cnt <= 0;i<=i+1'b1;end
           else              begin cnt <= cnt +1'b1;   end
        end
       9'd266:
        begin
            if(k == 0 || k == 2)
                begin
                    if(cnt == 32'd28_0000)//»Ì∏¥Œª∫Û–Ëµ»¥˝5ms
                        begin
                            cnt <= 0;
                            i <= i + 1;
                        end
                    else
                        begin
                            cnt <= cnt + 1;
                            i <= i;
                        end
                end
            else if(k == 17) 
                begin
                    if(rxdata[0] == 1'b1)  i <= i + 1;
                    else begin k <= 0; i <= 0;end
                end
            else if(k == 48)
                begin
                    if(rxdata[7] == 1'b1) i <= i + 1;
                    else begin k <= 0; i <= 0;end
                end
            else
                begin   
                    i <= i + 1;
                end
        end
       9'd267:                
        begin
            if( k < config_l )  begin k <= k + 1'b1;i<=1;end
            else                 i<=i+1'b1;
        end
      9'd268:       
         begin
            finish <= 1;
            if(vio_rd_en_pos)
                begin
                    i <= 1;
                    k <= 70;
                end
            else
                begin
                    i <= i;
                    k <= k;
                end
         end 
                       
      default:i<=0;
    endcase 
end   

//ila_spi_cfg u_ila_ad9680_cfg_600m(
//    .clk                (clk),
//    .probe0             (i),
//    .probe1             (k),
//    .probe2             (rCSN),
//    .probe3             (rSDI),
//    .probe4             (SDO_r2),
//    .probe5             (rSCLK),
//    .probe6             (txdata),
//    .probe7             (rxdata),
//    .probe8             (sdio_out_en)
//    );


endmodule
