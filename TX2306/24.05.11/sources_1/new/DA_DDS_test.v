`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/20 21:56:53
// Design Name: 
// Module Name: DA_DDS_test
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


module DA_DDS_test(
        input           clk163m84,
        input           clk100m,
        input           rst_n,
        
        output          dac_clk_a ,
        output          dac_clk_b ,
        output [11:0]   dac_dat_i ,
        output [11:0]   dac_dat_q ,
        output          dac_wrta  ,
        output          dac_wrtb  
    );
    
    wire           s_axis_phase_tvalid;
    wire [63:0]    s_axis_phase_tdata;
    wire [31:0]    phase_off;
    wire [31:0]    phase_inc;
    wire           m_axis_data_tvalid;
    wire [31:0]    m_axis_data_tdata;      
    
    wire           vio_clk;
    wire           vio_wrta;
    wire           vio_data;
    
    reg [31:0]     phase_off_r,phase_off_rr;
    reg [31:0]     phase_inc_r,phase_inc_rr;
    reg            s_axis_data_tvalid_r,s_axis_data_tvalid_rr;
    
    assign s_axis_phase_tdata = {phase_off_rr,phase_inc_rr};
    
    assign dac_clk_a = vio_clk? !clk163m84 : clk163m84;
    assign dac_clk_b = vio_clk? !clk163m84 : clk163m84;

    assign dac_wrta  = vio_wrta? !clk163m84 : clk163m84;
    assign dac_wrtb  = vio_wrta? !clk163m84 : clk163m84;
    
    assign dac_dat_i = vio_data? {!m_axis_data_tdata[11],m_axis_data_tdata[10:0] }: m_axis_data_tdata[11:0];
    assign dac_dat_q = vio_data? {!m_axis_data_tdata[27],m_axis_data_tdata[26:16] } : m_axis_data_tdata[27:16];
    
    
   vio_test vio_test_inst (
       .clk(clk100m),                // input wire clk
       .probe_out0(s_axis_phase_tvalid),  // output wire [0 : 0] probe_out0
       .probe_out1(phase_off),  // output wire [31 : 0] probe_out1
       .probe_out2(phase_inc),  // output wire [31 : 0] probe_out2,
       .probe_out3(vio_clk),  // output wire [0 : 0] probe_out3
       .probe_out4(vio_wrta),  // output wire [0 : 0] probe_out4
       .probe_out5(vio_data)  // output wire [0 : 0] probe_out5

     ); 
    
    
    
    
    always @(posedge clk163m84)begin
       phase_off_r <= phase_off;
       phase_off_rr <= phase_off_r;
    end 
    
    always @(posedge clk163m84)begin
       phase_inc_r <= phase_inc;
       phase_inc_rr <= phase_inc_r;
    end 
    
    always @(posedge clk163m84)begin
       s_axis_data_tvalid_r <= s_axis_phase_tvalid;
       s_axis_data_tvalid_rr <= s_axis_data_tvalid_r;
    end 
    
     
     

     
     
    
    dds_compiler_0 dds_compiler_0_inst (
       .aclk(clk163m84),                                // input wire aclk
       .aclken (rst_n),                            // input wire aclken
       .aresetn(rst_n),                          // input wire aresetn
       .s_axis_phase_tvalid(s_axis_data_tvalid_rr),  // input wire s_axis_phase_tvalid
       .s_axis_phase_tdata(s_axis_phase_tdata),    // input wire [63 : 0] s_axis_phase_tdata
       .m_axis_data_tvalid(m_axis_data_tvalid),    // output wire m_axis_data_tvalid
       .m_axis_data_tdata(m_axis_data_tdata),      // output wire [31 : 0] m_axis_data_tdata
       .m_axis_phase_tvalid(),  // output wire m_axis_phase_tvalid
       .m_axis_phase_tdata()    // output wire [23 : 0] m_axis_phase_tdata
     );
     
     ila_DAtest ila_DAtest_inst (
         .clk(clk163m84), // input wire clk
     
     
         .probe0(phase_off_rr), // input wire [31:0]  probe0  
         .probe1(phase_inc_rr), // input wire [31:0]  probe1 
         .probe2(dac_dat_i), // input wire [11:0]  probe2 
         .probe3(dac_dat_q), // input wire [11:0]  probe3 
         .probe4(m_axis_data_tvalid), // input wire [0:0]  probe4
         .probe5(s_axis_data_tvalid_rr) // input wire [0:0]  probe4
     ); 
endmodule
