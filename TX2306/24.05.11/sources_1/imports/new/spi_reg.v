`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/10 06:37:02
// Design Name: 
// Module Name: spi_reg
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


module spi_reg(
    input           clk,
    input           rst_n,
    
       //user interface
   input             rxd_flag,
   input    [63:0]   rxd_data,
   

   output [31:0]     down_freq,
   output [31:0]     up_freq,
   output [31:0]     up_step_freq,
   output [31:0]     down_step_freq,
   output [31:0]     kq_demodule_sig,
   output [31:0]     kq_module_sig,
   output [31:0]     demod_bias_init_value,
   output [31:0]     mod_bias_init_value,
   output [46:0]     init_tod_in,
   output [31:0]     satel_ground_delay,
   output [27:0]     address_data,
   output [31:0]    ls_sync_shixi0, 
   output [31:0]    ls_sync_shixi1, 
   output [31:0]    ls_sync_shixi2, 
   output [31:0]    ls_sync_shixi3, 
   output [31:0]    ls_sync_shixi4, 
   output [31:0]    ls_sync_shixi5, 
   output [31:0]    ls_sync_shixi6, 
   output [31:0]    ls_sync_shixi7, 
   output [31:0]    ls_sync_shixi8, 
   output [31:0]    ls_sync_shixi9, 
   output [31:0]    ls_sync_shixi10,
   output [31:0]    ls_sync_shixi11,
   output [31:0]    ls_sync_shixi12,
   output [31:0]    ls_sync_shixi13,
   output [31:0]    ls_sync_shixi14,
   output [31:0]    ls_sync_shixi15,
   output [31:0]    ls_yw_shixi0 ,   
   output [31:0]    ls_yw_shixi1 ,   
   output [31:0]    ls_yw_shixi2 ,   
   output [31:0]    ls_yw_shixi3 ,   
   output [31:0]    ls_yw_shixi4 ,   
   output [31:0]    ls_yw_shixi5 ,   
   output [31:0]    ls_yw_shixi6 ,   
   output [31:0]    ls_yw_shixi7 ,   
   output [31:0]    ls_ctr_shixi0,   
   output [31:0]    ls_ctr_shixi1,   
   output [31:0]    ls_ctr_shixi2,   
   output [31:0]    ls_ctr_shixi3,   
   output [31:0]    ls_ctr_shixi4,   
   output [31:0]    ls_ctr_shixi5,   
   output [31:0]    ls_ctr_shixi6,   
   output [31:0]    ls_ctr_shixi7,   
   output [31:0]    ms_sync_shixi,   
   output [31:0]    ms_gdctr_shixi,  
   output [31:0]    ms_ctroryw_shixi,
   output [31:0]    soft_rstn ,   
   output [31:0]    kd_module_reg,
   output [31:0]    kd_satel_ground_delay_reg,
   output [31:0]    kd_coar_sync_reg,
   output [31:0]    kd_fine_sync_reg
    );
    
 reg            rxd_flag_r,rxd_flag_rr;
 reg [63:0]     rxd_data_r,rxd_data_rr;
 
 reg [31:0]     down_freq_r;
 reg [31:0]     up_freq_r;
 reg [31:0]     up_step_freq_r;
 reg [31:0]     down_step_freq_r;
 reg [31:0]     kq_demodule_sig_r;
 reg [31:0]     kq_module_sig_r;
 reg [31:0]     demod_bias_init_value_r;
 reg [31:0]     mod_bias_init_value_r;
 reg [15:0]     init_tod_hig_r;
 reg [31:0]     init_tod_low_r;
 reg [31:0]     satel_ground_delay_r;
 reg [27:0]     address_data_r;
 reg [31:0]     ls_sync_shixi_r0;
 reg [31:0]     ls_sync_shixi_r1;
 reg [31:0]     ls_sync_shixi_r2;
 reg [31:0]     ls_sync_shixi_r3;
 reg [31:0]     ls_sync_shixi_r4;
 reg [31:0]     ls_sync_shixi_r5;
 reg [31:0]     ls_sync_shixi_r6;
 reg [31:0]     ls_sync_shixi_r7;
 reg [31:0]     ls_sync_shixi_r8;
 reg [31:0]     ls_sync_shixi_r9;
 reg [31:0]     ls_sync_shixi_r10;
 reg [31:0]     ls_sync_shixi_r11;
 reg [31:0]     ls_sync_shixi_r12;
 reg [31:0]     ls_sync_shixi_r13;
 reg [31:0]     ls_sync_shixi_r14;
 reg [31:0]     ls_sync_shixi_r15;
 reg [31:0]     ls_yw_shixi_r0;
 reg [31:0]     ls_yw_shixi_r1;
 reg [31:0]     ls_yw_shixi_r2;
 reg [31:0]     ls_yw_shixi_r3;
 reg [31:0]     ls_yw_shixi_r4;
 reg [31:0]     ls_yw_shixi_r5;
 reg [31:0]     ls_yw_shixi_r6;
 reg [31:0]     ls_yw_shixi_r7;
 reg [31:0]     ls_ctr_shixi_r0;
 reg [31:0]     ls_ctr_shixi_r1;
 reg [31:0]     ls_ctr_shixi_r2;
 reg [31:0]     ls_ctr_shixi_r3;
 reg [31:0]     ls_ctr_shixi_r4;
 reg [31:0]     ls_ctr_shixi_r5;
 reg [31:0]     ls_ctr_shixi_r6;
 reg [31:0]     ls_ctr_shixi_r7;
 reg [31:0]     ms_sync_shixi_r; //1bit
 reg [31:0]     ms_gdctr_shixi_r;//1bit
 reg [31:0]     ms_ctroryw_shixi_r;
 reg [31:0]     soft_rstn_r;
 reg [31:0]     kd_module_reg_r;
 reg [31:0]     kd_satel_ground_delay_reg_r;
 reg [31:0]     kd_coar_sync_reg_r;
 reg [31:0]     kd_fine_sync_reg_r;
 
 
 
   assign down_freq         =down_freq_r;
   assign up_freq           =up_freq_r   ;
   assign up_step_freq     =up_step_freq_r;  
   assign down_step_freq   =down_step_freq_r; 
   assign kq_demodule_sig  =kq_demodule_sig_r;
   assign kq_module_sig    =kq_module_sig_r;
   assign demod_bias_init_value = demod_bias_init_value_r;
   assign mod_bias_init_value   = mod_bias_init_value_r;
   assign init_tod_in= {init_tod_hig_r,init_tod_low_r};
   
 assign     satel_ground_delay = satel_ground_delay_r;
 assign     address_data       =address_data_r;
 assign     ls_sync_shixi0        =ls_sync_shixi_r0;
 assign     ls_sync_shixi1        =ls_sync_shixi_r1;
 assign     ls_sync_shixi2        =ls_sync_shixi_r2;
 assign     ls_sync_shixi3        =ls_sync_shixi_r3;
 assign     ls_sync_shixi4        =ls_sync_shixi_r4;
 assign     ls_sync_shixi5        =ls_sync_shixi_r5;
 assign     ls_sync_shixi6        =ls_sync_shixi_r6;
 assign     ls_sync_shixi7        =ls_sync_shixi_r7;
 assign     ls_sync_shixi8        =ls_sync_shixi_r8;
 assign     ls_sync_shixi9        =ls_sync_shixi_r9;
 assign     ls_sync_shixi10       =ls_sync_shixi_r10;
 assign     ls_sync_shixi11       =ls_sync_shixi_r11;
 assign     ls_sync_shixi12       =ls_sync_shixi_r12;
 assign     ls_sync_shixi13       =ls_sync_shixi_r13;
 assign     ls_sync_shixi14       =ls_sync_shixi_r14;
 assign     ls_sync_shixi15       =ls_sync_shixi_r15;
 assign     ls_yw_shixi0          =ls_yw_shixi_r0;
 assign     ls_yw_shixi1          =ls_yw_shixi_r1;
 assign     ls_yw_shixi2          =ls_yw_shixi_r2;
 assign     ls_yw_shixi3          =ls_yw_shixi_r3;
 assign     ls_yw_shixi4          =ls_yw_shixi_r4;
 assign     ls_yw_shixi5          =ls_yw_shixi_r5;
 assign     ls_yw_shixi6          =ls_yw_shixi_r6;
 assign     ls_yw_shixi7          =ls_yw_shixi_r7;
 assign     ls_ctr_shixi0     =ls_ctr_shixi_r0;
 assign     ls_ctr_shixi1     =ls_ctr_shixi_r1;
 assign     ls_ctr_shixi2     =ls_ctr_shixi_r2;
 assign     ls_ctr_shixi3     =ls_ctr_shixi_r3;
 assign     ls_ctr_shixi4     =ls_ctr_shixi_r4;
 assign     ls_ctr_shixi5     =ls_ctr_shixi_r5;
 assign     ls_ctr_shixi6     =ls_ctr_shixi_r6;
 assign     ls_ctr_shixi7     =ls_ctr_shixi_r7;
 assign     ms_sync_shixi     =ms_sync_shixi_r; //1bit
 assign     ms_gdctr_shixi    =ms_gdctr_shixi_r;//1bit
 assign     ms_ctroryw_shixi  =ms_ctroryw_shixi_r;
 assign     soft_rstn         =soft_rstn_r;
 assign     kd_module_reg     =kd_module_reg_r;
 assign     kd_satel_ground_delay_reg =kd_satel_ground_delay_reg_r;
 assign     kd_coar_sync_reg  = kd_coar_sync_reg_r;
 assign     kd_fine_sync_reg  = kd_fine_sync_reg_r;
 
 always @(posedge clk)begin
    rxd_flag_r  <= rxd_flag;
    rxd_flag_rr <= rxd_flag_r;
 end 
 
 always @(posedge clk)begin
    rxd_data_r <= rxd_data;
    rxd_data_rr <= rxd_data_r;
 end 
 
 
 always @(posedge clk or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        down_freq_r     <= 32'd0;
        up_freq_r       <= 32'd0;
        up_step_freq_r  <= 32'd0;
        down_step_freq_r<= 32'd0;
        kq_demodule_sig_r <= 32'd0;
        kq_module_sig_r   <= 32'd0;
        demod_bias_init_value_r <= 32'd0;
        mod_bias_init_value_r   <= 32'd0;
        init_tod_hig_r           <= 16'd0;
        init_tod_low_r           <= 16'd0;
        satel_ground_delay_r     <=32'd0;
        address_data_r           <= 28'd0;
        ls_sync_shixi_r0         <=32'd0;
        ls_sync_shixi_r1         <=32'd0;
        ls_sync_shixi_r2         <=32'd0;
        ls_sync_shixi_r3         <=32'd0;
        ls_sync_shixi_r4         <=32'd0;
        ls_sync_shixi_r5         <=32'd0;
        ls_sync_shixi_r6         <=32'd0;
        ls_sync_shixi_r7         <=32'd0;
        ls_sync_shixi_r8         <=32'd0;
        ls_sync_shixi_r9         <=32'd0;
        ls_sync_shixi_r10        <=32'd0;
        ls_sync_shixi_r11        <=32'd0;
        ls_sync_shixi_r12        <=32'd0;
        ls_sync_shixi_r13        <=32'd0;
        ls_sync_shixi_r14        <=32'd0;
        ls_sync_shixi_r15        <=32'd0;
        ls_yw_shixi_r0         <=32'd0;
        ls_yw_shixi_r1         <=32'd0;
        ls_yw_shixi_r2         <=32'd0;
        ls_yw_shixi_r3         <=32'd0;
        ls_yw_shixi_r4         <=32'd0;
        ls_yw_shixi_r5         <=32'd0;
        ls_yw_shixi_r6         <=32'd0;
        ls_yw_shixi_r7         <=32'd0;
        ls_ctr_shixi_r0         <=32'd0;
        ls_ctr_shixi_r1         <=32'd0;
        ls_ctr_shixi_r2         <=32'd0;
        ls_ctr_shixi_r3         <=32'd0;
        ls_ctr_shixi_r4         <=32'd0;
        ls_ctr_shixi_r5         <=32'd0;
        ls_ctr_shixi_r6         <=32'd0;
        ls_ctr_shixi_r7         <=32'd0; 
        ms_sync_shixi_r         <=32'd0;    
        ms_gdctr_shixi_r        <=32'd0;   
        ms_ctroryw_shixi_r      <=32'd0; 
        
        soft_rstn_r                <=32'd0;
        kd_module_reg_r            <=32'd0;
        kd_satel_ground_delay_reg_r<=32'd0;
        kd_coar_sync_reg_r         <=32'd0;
        kd_fine_sync_reg_r         <=32'd0;
        
    end 
    else if(rxd_flag_rr)begin
        case(rxd_data_rr[63:32])
            32'h43C0_3100:begin down_freq_r                     <= rxd_data_rr[31:0];end
            32'h43C0_3104:begin up_freq_r                       <= rxd_data_rr[31:0];end
            32'h43C0_3108:begin up_step_freq_r                  <= rxd_data_rr[31:0];end 
            32'h43C0_310B:begin up_step_freq_r                  <= rxd_data_rr[31:0];end 
            32'h43C0_3110:begin kq_demodule_sig_r               <= rxd_data_rr[31:0];end  // ?
            32'h43C0_3114:begin kq_module_sig_r                 <= rxd_data_rr[31:0];end  //?
            32'h43C0_3118:begin demod_bias_init_value_r         <= rxd_data_rr[31:0];end 
            32'h43C0_311B:begin mod_bias_init_value_r           <= rxd_data_rr[31:0];end 
            32'h43C0_311B:begin mod_bias_init_value_r           <= rxd_data_rr[31:0];end 
            32'h43C0_3120:begin init_tod_hig_r                  <= rxd_data_rr[15:0];end 
            32'h43C0_3124:begin init_tod_low_r                  <= rxd_data_rr[31:0];end
            32'h43C0_3128:begin satel_ground_delay_r            <= rxd_data_rr[31:0];end 
            32'h43C0_312B:begin address_data_r                  <= rxd_data_rr[27:0];end 
            32'h43C0_3130:begin ls_sync_shixi_r0                <= rxd_data_rr[31:0];end 
            32'h43C0_3134:begin ls_sync_shixi_r1                <= rxd_data_rr[31:0];end 
            32'h43C0_3138:begin ls_sync_shixi_r2                <= rxd_data_rr[31:0];end 
            32'h43C0_313B:begin ls_sync_shixi_r3                <= rxd_data_rr[31:0];end 
            32'h43C0_3140:begin ls_sync_shixi_r4                <= rxd_data_rr[31:0];end 
            32'h43C0_3144:begin ls_sync_shixi_r5                <= rxd_data_rr[31:0];end 
            32'h43C0_3148:begin ls_sync_shixi_r6                <= rxd_data_rr[31:0];end 
            32'h43C0_314B:begin ls_sync_shixi_r7                <= rxd_data_rr[31:0];end
            32'h43C0_3150:begin ls_sync_shixi_r8                <= rxd_data_rr[31:0];end 
            32'h43C0_3154:begin ls_sync_shixi_r9                <= rxd_data_rr[31:0];end 
            32'h43C0_3158:begin ls_sync_shixi_r10               <= rxd_data_rr[31:0];end 
            32'h43C0_315B:begin ls_sync_shixi_r11               <= rxd_data_rr[31:0];end 
            32'h43C0_3160:begin ls_sync_shixi_r12               <= rxd_data_rr[31:0];end 
            32'h43C0_3164:begin ls_sync_shixi_r13               <= rxd_data_rr[31:0];end 
            32'h43C0_3168:begin ls_sync_shixi_r14               <= rxd_data_rr[31:0];end 
            32'h43C0_316B:begin ls_sync_shixi_r15               <= rxd_data_rr[31:0];end  
            32'h43C0_3170:begin ls_yw_shixi_r0                <= rxd_data_rr[31:0];end 
            32'h43C0_3174:begin ls_yw_shixi_r1                <= rxd_data_rr[31:0];end 
            32'h43C0_3178:begin ls_yw_shixi_r2                <= rxd_data_rr[31:0];end 
            32'h43C0_317B:begin ls_yw_shixi_r3                <= rxd_data_rr[31:0];end 
            32'h43C0_3180:begin ls_yw_shixi_r4                <= rxd_data_rr[31:0];end 
            32'h43C0_3184:begin ls_yw_shixi_r5                <= rxd_data_rr[31:0];end 
            32'h43C0_3188:begin ls_yw_shixi_r6                <= rxd_data_rr[31:0];end 
            32'h43C0_318B:begin ls_yw_shixi_r7                <= rxd_data_rr[31:0];end            
            32'h43C0_3190:begin ls_ctr_shixi_r0                <= rxd_data_rr[31:0];end 
            32'h43C0_3194:begin ls_ctr_shixi_r1                <= rxd_data_rr[31:0];end 
            32'h43C0_3198:begin ls_ctr_shixi_r2                <= rxd_data_rr[31:0];end 
            32'h43C0_319B:begin ls_ctr_shixi_r3                <= rxd_data_rr[31:0];end 
            32'h43C0_31A0:begin ls_ctr_shixi_r4                <= rxd_data_rr[31:0];end 
            32'h43C0_31A4:begin ls_ctr_shixi_r5                <= rxd_data_rr[31:0];end 
            32'h43C0_31A8:begin ls_ctr_shixi_r6                <= rxd_data_rr[31:0];end 
            32'h43C0_31AB:begin ls_ctr_shixi_r7                <= rxd_data_rr[31:0];end
            32'h43C0_31B0:begin ms_sync_shixi_r                <= rxd_data_rr[31:0];end 
            32'h43C0_31B4:begin ms_gdctr_shixi_r               <= rxd_data_rr[31:0];end 
            32'h43C0_31B8:begin ms_ctroryw_shixi_r             <= rxd_data_rr[31:0];end
            32'h43C0_303C:begin soft_rstn_r                    <= rxd_data_rr[31:0];end 
            32'h43C0_3028:begin kd_module_reg_r                <= rxd_data_rr[31:0];end
            32'h43C0_3030:begin kd_satel_ground_delay_reg_r    <= rxd_data_rr[31:0];end 
            32'h43C0_3034:begin kd_coar_sync_reg_r             <= rxd_data_rr[31:0];end 
            32'h43C0_3040:begin kd_fine_sync_reg_r             <= rxd_data_rr[31:0];end
        endcase
    end 
 end 
    
    
endmodule
