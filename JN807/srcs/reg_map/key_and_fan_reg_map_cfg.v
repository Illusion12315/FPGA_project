
/*
* @Author       : Chen Xiong Zhi
* @Date         : 2022-08-16 08:39:08
* @LastEditTime : 2025-01-09 06:08:05
* @LastEditors  : Chen Xiong Zhi
* @Description  : key_and_fan reg map cfg
* @FilePath     : g:\project\JN807\new_build\srcs\reg_map\key_and_fan_reg_map_cfg.v
*/

module key_and_fan_reg_map_cfg
(
    //System
    input               sys_clk_i            ,
    input               rst_n_i              ,

    //Ram interface
    input               ram_wr_en_i          ,
    input      [32-1:0] ram_wr_addr_i        ,
    input      [32-1:0] ram_wr_data_i        ,
    input               ram_rd_en_i          ,
    input      [32-1:0] ram_rd_addr_i        ,
    output reg [32-1:0] ram_rd_data_o        ,

    //reg map
    output              pwm5_ch_en           ,//output slv_reg000 pwm5_ch_en [ 1-1:0]
    output              pwm4_ch_en           ,//output slv_reg000 pwm4_ch_en [ 1-1:0]
    output              pwm3_ch_en           ,//output slv_reg000 pwm3_ch_en [ 1-1:0]
    output              pwm2_ch_en           ,//output slv_reg000 pwm2_ch_en [ 1-1:0]
    output              pwm1_ch_en           ,//output slv_reg000 pwm1_ch_en [ 1-1:0]
    output     [ 2-1:0] avs_address          ,//output slv_reg000 avs_address [ 2-1:0]
    output              avs_read             ,//output slv_reg000 avs_read [ 1-1:0]
    output              avs_write            ,//output slv_reg000 avs_write [ 1-1:0]
    output     [32-1:0] avs_writedata        ,//output slv_reg001 avs_writedata [32-1:0]
    output reg [ 2-1:0] cdiv                 ,//output slv_reg002 cdiv [ 2-1:0]
    output reg          mlb                  ,//output slv_reg002 mlb [ 1-1:0]
    output reg          write_data_flag      ,//output slv_reg002 write_data_flag [ 1-1:0]
    output reg          read_data_flag       ,//output slv_reg002 read_data_flag [ 1-1:0]
    output reg          key_rst              ,//output slv_reg002 key_rst [ 1-1:0]
    output reg          start                ,//output slv_reg002 start [ 1-1:0]
    input      [ 4-1:0] rd_reg002            ,//input slv_reg002 rd_reg002 [ 4-1:0]
    output reg [ 8-1:0] keyboard_cmd         ,//output slv_reg003 keyboard_cmd [ 8-1:0]
    input      [ 8-1:0] rd_reg003            ,//input slv_reg003 rd_reg003 [ 8-1:0]
    output reg [ 8-1:0] keyboard_txd         ,//output slv_reg004 keyboard_txd [ 8-1:0]
    input      [ 8-1:0] rd_reg004            ,//input slv_reg004 rd_reg004 [ 8-1:0]
    input      [32-1:0] rdata                ,//input slv_reg005 rdata [32-1:0]
    output reg          read_status          ,//output slv_reg006 read_status [ 1-1:0]
    input               done                 ,//input slv_reg006 done [ 1-1:0]
    input      [32-1:0] pwm1_total_num       ,//input slv_reg007 pwm1_total_num [32-1:0]
    input      [32-1:0] pwm1_high_num        ,//input slv_reg008 pwm1_high_num [32-1:0]
    input      [32-1:0] pwm2_total_num       ,//input slv_reg009 pwm2_total_num [32-1:0]
    input      [32-1:0] pwm2_high_num        ,//input slv_reg00a pwm2_high_num [32-1:0]
    input      [32-1:0] pwm3_total_num       ,//input slv_reg00b pwm3_total_num [32-1:0]
    input      [32-1:0] pwm3_high_num        ,//input slv_reg00c pwm3_high_num [32-1:0]
    input      [32-1:0] pwm4_total_num       ,//input slv_reg00d pwm4_total_num [32-1:0]
    input      [32-1:0] pwm4_high_num        ,//input slv_reg00e pwm4_high_num [32-1:0]
    input      [32-1:0] pwm5_total_num       ,//input slv_reg00f pwm5_total_num [32-1:0]
    input      [32-1:0] pwm5_high_num        ,//input slv_reg010 pwm5_high_num [32-1:0]
    input               pic_pwm8             ,//input slv_reg011 pic_pwm8 [ 1-1:0]
    input               pic_pwm7             ,//input slv_reg011 pic_pwm7 [ 1-1:0]
    input               pic_pwm6             ,//input slv_reg011 pic_pwm6 [ 1-1:0]
    input               pic_pwm5             ,//input slv_reg011 pic_pwm5 [ 1-1:0]
    input               pic_pwm4             ,//input slv_reg011 pic_pwm4 [ 1-1:0]
    input               pic_pwm3             ,//input slv_reg011 pic_pwm3 [ 1-1:0]
    input               pic_pwm2             ,//input slv_reg011 pic_pwm2 [ 1-1:0]
    input               pic_pwm1              //input slv_reg011 pic_pwm1 [ 1-1:0]
);

//----------------------------local parameter---------------------------------------------
localparam SLV_REG000 = 32'h0 + 32'h0 ;
localparam SLV_REG001 = 32'h0 + 32'h4 ;
localparam SLV_REG002 = 32'h0 + 32'h8 ;
localparam SLV_REG003 = 32'h0 + 32'hc ;
localparam SLV_REG004 = 32'h0 + 32'h10;
localparam SLV_REG005 = 32'h0 + 32'h14;
localparam SLV_REG006 = 32'h0 + 32'h18;
localparam SLV_REG007 = 32'h0 + 32'h1c;
localparam SLV_REG008 = 32'h0 + 32'h20;
localparam SLV_REG009 = 32'h0 + 32'h24;
localparam SLV_REG00A = 32'h0 + 32'h28;
localparam SLV_REG00B = 32'h0 + 32'h2c;
localparam SLV_REG00C = 32'h0 + 32'h30;
localparam SLV_REG00D = 32'h0 + 32'h34;
localparam SLV_REG00E = 32'h0 + 32'h38;
localparam SLV_REG00F = 32'h0 + 32'h3c;
localparam SLV_REG010 = 32'h0 + 32'h40;
localparam SLV_REG011 = 32'h0 + 32'h44;

//----------------------------local wire/reg declaration------------------------------------------

//slv_reg000
reg  [32-1:0] slv_reg000_reg ;//wr
wire [32-1:0] slv_reg000     ;//rd

//slv_reg001
reg  [32-1:0] slv_reg001_reg ;//wr
wire [32-1:0] slv_reg001     ;//rd

//slv_reg002
wire [32-1:0] slv_reg002     ;//rd

//slv_reg003
wire [32-1:0] slv_reg003     ;//rd

//slv_reg004
wire [32-1:0] slv_reg004     ;//rd

//slv_reg005
wire [32-1:0] slv_reg005     ;//rd

//slv_reg006
wire [32-1:0] slv_reg006     ;//rd

//slv_reg007
wire [32-1:0] slv_reg007     ;//rd

//slv_reg008
wire [32-1:0] slv_reg008     ;//rd

//slv_reg009
wire [32-1:0] slv_reg009     ;//rd

//slv_reg00a
wire [32-1:0] slv_reg00a     ;//rd

//slv_reg00b
wire [32-1:0] slv_reg00b     ;//rd

//slv_reg00c
wire [32-1:0] slv_reg00c     ;//rd

//slv_reg00d
wire [32-1:0] slv_reg00d     ;//rd

//slv_reg00e
wire [32-1:0] slv_reg00e     ;//rd

//slv_reg00f
wire [32-1:0] slv_reg00f     ;//rd

//slv_reg010
wire [32-1:0] slv_reg010     ;//rd

//slv_reg011
wire [32-1:0] slv_reg011     ;//rd

//----------------------------control logic---------------------------------------------
wire ram_wr_en     = ram_wr_en_i                                   ;
wire ram_rd_en     = ram_rd_en_i                                   ;

//slv_reg000
wire slv_reg000_wr = ( ram_wr_addr_i == SLV_REG000 ) && ram_wr_en  ;

//slv_reg001
wire slv_reg001_wr = ( ram_wr_addr_i == SLV_REG001 ) && ram_wr_en  ;

//slv_reg002
wire slv_reg002_wr = ( ram_wr_addr_i == SLV_REG002 ) && ram_wr_en  ;

//slv_reg003
wire slv_reg003_wr = ( ram_wr_addr_i == SLV_REG003 ) && ram_wr_en  ;

//slv_reg004
wire slv_reg004_wr = ( ram_wr_addr_i == SLV_REG004 ) && ram_wr_en  ;

//slv_reg006
wire slv_reg006_wr = ( ram_wr_addr_i == SLV_REG006 ) && ram_wr_en  ;

//--------------------------------processing------------------------------------------------

//slv_reg000
assign slv_reg000[31:9]         = 23'h0                ;
assign pwm5_ch_en               = slv_reg000_reg[8]    ;
assign slv_reg000[8]            = pwm5_ch_en           ;
assign pwm4_ch_en               = slv_reg000_reg[7]    ;
assign slv_reg000[7]            = pwm4_ch_en           ;
assign pwm3_ch_en               = slv_reg000_reg[6]    ;
assign slv_reg000[6]            = pwm3_ch_en           ;
assign pwm2_ch_en               = slv_reg000_reg[5]    ;
assign slv_reg000[5]            = pwm2_ch_en           ;
assign pwm1_ch_en               = slv_reg000_reg[4]    ;
assign slv_reg000[4]            = pwm1_ch_en           ;
assign avs_address              = slv_reg000_reg[3:2]  ;
assign slv_reg000[3:2]          = avs_address          ;
assign avs_read                 = slv_reg000_reg[1]    ;
assign slv_reg000[1]            = avs_read             ;
assign avs_write                = slv_reg000_reg[0]    ;
assign slv_reg000[0]            = avs_write            ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg000_reg <= 'h0;
    else if( slv_reg000_wr )
        slv_reg000_reg <= ram_wr_data_i;
end


//slv_reg001
assign avs_writedata              = slv_reg001_reg[31:0] ;
assign slv_reg001[31:0]           = avs_writedata        ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg001_reg <= 'h0;
    else if( slv_reg001_wr )
        slv_reg001_reg <= ram_wr_data_i;
end


//slv_reg002
assign slv_reg002[31:8]             = 24'h0          ;
assign slv_reg002[4]                = 1'h0           ;
assign slv_reg002[3:0]              = rd_reg002      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        cdiv <= 2'h0;
    else if( slv_reg002_wr )
        cdiv <= ram_wr_data_i[7:6];
end

always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        mlb <= 1'h0;
    else if( slv_reg002_wr )
        mlb <= ram_wr_data_i[5];
end

always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        write_data_flag <= 1'h0;
    else if( slv_reg002_wr )
        write_data_flag <= ram_wr_data_i[3];
end

always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        read_data_flag <= 1'h0;
    else if( slv_reg002_wr )
        read_data_flag <= ram_wr_data_i[2];
end

always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        key_rst <= 1'h1;
    else if( slv_reg002_wr )
        key_rst <= ram_wr_data_i[1];
end

always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        start <= 1'h0;
    else if( slv_reg002_wr )
        start <= ram_wr_data_i[0];
end


//slv_reg003
assign slv_reg003[31:8]          = 24'h0       ;
assign slv_reg003[7:0]           = rd_reg003   ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        keyboard_cmd <= 8'h0;
    else if( slv_reg003_wr )
        keyboard_cmd <= ram_wr_data_i[7:0];
end


//slv_reg004
assign slv_reg004[31:8]          = 24'h0       ;
assign slv_reg004[7:0]           = rd_reg004   ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        keyboard_txd <= 8'h0;
    else if( slv_reg004_wr )
        keyboard_txd <= ram_wr_data_i[7:0];
end


//slv_reg005
assign slv_reg005[31:0]   = rdata;

//slv_reg006
assign slv_reg006[31:1]         = 31'h0      ;
assign slv_reg006[0]            = done       ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        read_status <= 1'h0;
    else if( slv_reg006_wr )
        read_status <= ram_wr_data_i[0];
end


//slv_reg007
assign slv_reg007[31:0]            = pwm1_total_num;

//slv_reg008
assign slv_reg008[31:0]           = pwm1_high_num;

//slv_reg009
assign slv_reg009[31:0]            = pwm2_total_num;

//slv_reg00a
assign slv_reg00a[31:0]           = pwm2_high_num;

//slv_reg00b
assign slv_reg00b[31:0]            = pwm3_total_num;

//slv_reg00c
assign slv_reg00c[31:0]           = pwm3_high_num;

//slv_reg00d
assign slv_reg00d[31:0]            = pwm4_total_num;

//slv_reg00e
assign slv_reg00e[31:0]           = pwm4_high_num;

//slv_reg00f
assign slv_reg00f[31:0]            = pwm5_total_num;

//slv_reg010
assign slv_reg010[31:0]           = pwm5_high_num;

//slv_reg011
assign slv_reg011[31:8]      = 24'h0   ;
assign slv_reg011[7]         = pic_pwm8;
assign slv_reg011[6]         = pic_pwm7;
assign slv_reg011[5]         = pic_pwm6;
assign slv_reg011[4]         = pic_pwm5;
assign slv_reg011[3]         = pic_pwm4;
assign slv_reg011[2]         = pic_pwm3;
assign slv_reg011[1]         = pic_pwm2;
assign slv_reg011[0]         = pic_pwm1;

//reg map read
always @ ( * )
begin
    case( ram_rd_addr_i )
        SLV_REG000:
            ram_rd_data_o <= slv_reg000;
        SLV_REG001:
            ram_rd_data_o <= slv_reg001;
        SLV_REG002:
            ram_rd_data_o <= slv_reg002;
        SLV_REG003:
            ram_rd_data_o <= slv_reg003;
        SLV_REG004:
            ram_rd_data_o <= slv_reg004;
        SLV_REG005:
            ram_rd_data_o <= slv_reg005;
        SLV_REG006:
            ram_rd_data_o <= slv_reg006;
        SLV_REG007:
            ram_rd_data_o <= slv_reg007;
        SLV_REG008:
            ram_rd_data_o <= slv_reg008;
        SLV_REG009:
            ram_rd_data_o <= slv_reg009;
        SLV_REG00A:
            ram_rd_data_o <= slv_reg00a;
        SLV_REG00B:
            ram_rd_data_o <= slv_reg00b;
        SLV_REG00C:
            ram_rd_data_o <= slv_reg00c;
        SLV_REG00D:
            ram_rd_data_o <= slv_reg00d;
        SLV_REG00E:
            ram_rd_data_o <= slv_reg00e;
        SLV_REG00F:
            ram_rd_data_o <= slv_reg00f;
        SLV_REG010:
            ram_rd_data_o <= slv_reg010;
        SLV_REG011:
            ram_rd_data_o <= slv_reg011;
        default:
            ram_rd_data_o <= 'h5555_AAAA;
    endcase
end


endmodule
