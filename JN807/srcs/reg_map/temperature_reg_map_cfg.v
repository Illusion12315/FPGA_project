
/*
* @Author       : Chen Xiong Zhi
* @Date         : 2022-08-16 08:39:08
* @LastEditTime : 2025-01-09 06:08:05
* @LastEditors  : Chen Xiong Zhi
* @Description  : temperature reg map cfg
* @FilePath     : g:\project\JN807\new_build\srcs\reg_map\temperature_reg_map_cfg.v
*/

module temperature_reg_map_cfg
(
    //System
    input           sys_clk_i              ,
    input           rst_n_i                ,

    //Ram interface
    input           ram_wr_en_i            ,
    input  [32-1:0] ram_wr_addr_i          ,
    input  [32-1:0] ram_wr_data_i          ,
    input           ram_rd_en_i            ,
    input  [32-1:0] ram_rd_addr_i          ,
    output reg [32-1:0] ram_rd_data_o          ,

    //reg map
    input  [32-1:0] ch0_temp               ,//input slv_reg000 ch0_temp [32-1:0]
    input  [32-1:0] ch1_temp               ,//input slv_reg001 ch1_temp [32-1:0]
    input  [32-1:0] ch2_temp               ,//input slv_reg002 ch2_temp [32-1:0]
    input  [32-1:0] ch3_temp               ,//input slv_reg003 ch3_temp [32-1:0]
    input  [32-1:0] ch4_temp               ,//input slv_reg004 ch4_temp [32-1:0]
    input  [32-1:0] ch5_temp               ,//input slv_reg005 ch5_temp [32-1:0]
    input  [32-1:0] ch6_temp               ,//input slv_reg006 ch6_temp [32-1:0]
    input  [32-1:0] ch7_temp               ,//input slv_reg007 ch7_temp [32-1:0]
    input           i_vop_pos_pg           ,//input slv_reg009 i_vop_pos_pg [ 1-1:0]
    input           i_vop_neg_pg           ,//input slv_reg009 i_vop_neg_pg [ 1-1:0]
    input           i_tmp275_alert         ,//input slv_reg009 i_tmp275_alert [ 1-1:0]
    input           i_ocp_da_trig          ,//input slv_reg009 i_ocp_da_trig [ 1-1:0]
    input           i_cv_limit_switch      ,//input slv_reg009 i_cv_limit_switch [ 1-1:0]
    input  [ 3-1:0] i_out_dip_switch       ,//input slv_reg009 i_out_dip_switch [ 3-1:0]
    input  [ 4-1:0] i_dip_switch           ,//input slv_reg009 i_dip_switch [ 4-1:0]
    input  [ 8-1:0] i_fault_pan             //input slv_reg009 i_fault_pan [ 8-1:0]
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
localparam SLV_REG009 = 32'h0 + 32'h24;

//----------------------------local wire/reg declaration------------------------------------------

//slv_reg000
wire [32-1:0] slv_reg000       ;//rd

//slv_reg001
wire [32-1:0] slv_reg001       ;//rd

//slv_reg002
wire [32-1:0] slv_reg002       ;//rd

//slv_reg003
wire [32-1:0] slv_reg003       ;//rd

//slv_reg004
wire [32-1:0] slv_reg004       ;//rd

//slv_reg005
wire [32-1:0] slv_reg005       ;//rd

//slv_reg006
wire [32-1:0] slv_reg006       ;//rd

//slv_reg007
wire [32-1:0] slv_reg007       ;//rd

//slv_reg009
wire [32-1:0] slv_reg009       ;//rd

//----------------------------control logic---------------------------------------------
wire ram_wr_en     = ram_wr_en_i                                   ;
wire ram_rd_en     = ram_rd_en_i                                   ;

//--------------------------------processing------------------------------------------------

//slv_reg000
assign slv_reg000[31:0]      = ch0_temp;

//slv_reg001
assign slv_reg001[31:0]      = ch1_temp;

//slv_reg002
assign slv_reg002[31:0]      = ch2_temp;

//slv_reg003
assign slv_reg003[31:0]      = ch3_temp;

//slv_reg004
assign slv_reg004[31:0]      = ch4_temp;

//slv_reg005
assign slv_reg005[31:0]      = ch5_temp;

//slv_reg006
assign slv_reg006[31:0]      = ch6_temp;

//slv_reg007
assign slv_reg007[31:0]      = ch7_temp;

//slv_reg009
assign slv_reg009[31:1]               = 31'h0            ;
assign slv_reg009[0]                  = i_vop_pos_pg     ;
assign slv_reg009[1]                  = i_vop_neg_pg     ;
assign slv_reg009[2]                  = i_tmp275_alert   ;
assign slv_reg009[3]                  = i_ocp_da_trig    ;
assign slv_reg009[4]                  = i_cv_limit_switch;
assign slv_reg009[7:5]                = i_out_dip_switch ;
assign slv_reg009[11:8]               = i_dip_switch     ;
assign slv_reg009[19:12]              = i_fault_pan      ;
assign slv_reg009[11:0]               = 12'h0            ;

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
        SLV_REG009:
            ram_rd_data_o <= slv_reg009;
        default:
            ram_rd_data_o <= 'h5555_AAAA;
    endcase
end


endmodule
