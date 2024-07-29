`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/13 13:55:00
// Design Name: 
// Module Name: downlink_parse
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


module downlink_parse(
    input               clk100m,
    input               clk163m84,
    input               rst_n_100m,
    input               rst_n_163m84,
    
    //data from demod, clk with 100m
    input               ldpc_vld,
    input   [7:0]       ldpc_data,
    
    //clk with 163.84MHz. need hold until ldpc finish.
    input   [7:0]       i_DL_GearEverySlot,
    input   [7:0]       i_slottimesw_cnt,   //from 1 to 32
    input   [7:0]       i_ldpc_cnt,
    
    //config from control bus, clk with 100m
    input               config_vld,
    input   [7:0]       config_data,
    
    //output sdl with lvds head, clk with 100m
    output  [7:0]       lvds_data,
    output              lvds_data_vld,
    output  [15:0]      lvds_data_len,
    output              lvds_len_vld,
    
	output	[31:0]		sdl_bsn_cnt,
	output	[31:0]		sdl_bb_cnt,
	output	[31:0]		sdl_circuit_cnt,
    output              o_p2s_rstn
    );


//*************************************************************
//downlink info from 163.84M to 100M.

wire    [7:0]       w_DL_GearEverySlot;
wire    [7:0]       w_slottimesw_id ;
wire    [7:0]       w_ldpc_id       ;
reg     [7:0]       slottimesw_id   ;
reg     [7:0]       ldpc_id         ;

info_clk_convert u_info_clk_convert(
    .clk163m84          (clk163m84          ),
    .clk100m            (clk100m            ),
    .rst_n_100m         (rst_n_100m         ),
    .rst_n_163m84       (rst_n_163m84       ),
    
    .i_DL_GearEverySlot (i_DL_GearEverySlot ),
    .i_slottimesw_cnt   (i_slottimesw_cnt   ),
    .i_ldpc_cnt         (i_ldpc_cnt         ),
    
    .o_DL_GearEverySlot (w_DL_GearEverySlot ),
    .o_slottimesw_id    (w_slottimesw_id    ),
    .o_ldpc_id          (w_ldpc_id          ),
    .o_p2s_rstn         (o_p2s_rstn         )
);

always @(posedge clk100m)
begin
    if(!rst_n_100m)
        slottimesw_id   <=  8'd0;
    else begin
        slottimesw_id   <=  w_slottimesw_id - 1;
    end
end

always @(posedge clk100m)
begin
    if(!rst_n_100m)
        ldpc_id   <=  8'd0;
    else begin
        ldpc_id   <=  w_ldpc_id - 1;
    end
end

//*************************************************************
//config data table

wire                bsn_byte_rd;
wire    [9:0]       bsn_timeslot;
wire                bsn_ts_vld;

wire                bb_byte_rd;
wire    [9:0]       bb_timeslot;
wire                bb_ts_vld;

wire                ctrl_byte_rd;
wire    [9:0]       ctrl_timeslot;
wire                ctrl_ts_vld;

wire                circuit_bit_rd;
wire    [9:0]       circuit_timeslot;
wire                circuit_bit_vld;

config_ts_table u_config_ts_table(
    .sys_clk            (clk100m            ),
    .rst_n              (rst_n_100m         ),
    
    .config_data        (config_data        ),
    .config_vld         (config_vld         ),
    
    .bsn_byte_rd        (bsn_byte_rd        ),
    .bsn_timeslot       (bsn_timeslot       ),
    .bsn_ts_vld         (bsn_ts_vld         ),
    
    .bb_byte_rd         (bb_byte_rd         ),
    .bb_timeslot        (bb_timeslot        ),
    .bb_ts_vld          (bb_ts_vld  		),
    
    .ctrl_byte_rd       (ctrl_byte_rd       ),
    .ctrl_timeslot      (ctrl_timeslot      ),
    .ctrl_ts_vld        (ctrl_ts_vld  		),
	
    .circuit_bit_rd     (circuit_bit_rd     ),
    .circuit_timeslot   (circuit_timeslot   ),  
    .circuit_bit_vld    (circuit_bit_vld    )
);

//*************************from byte to sdl****************************

wire    [7:0]       bsn_f2chk_data;
wire                bsn_f2chk_data_vld;
wire    [15:0]      bsn_f2chk_len;
wire                bsn_f2chk_len_vld;

wire    [7:0]       bsn_frame_data;
wire                bsn_frame_data_vld;
wire    [15:0]      bsn_frame_len;
wire                bsn_frame_len_vld;

wire    [7:0]       bb_f2chk_data;
wire                bb_f2chk_data_vld;
wire    [15:0]      bb_f2chk_len;
wire                bb_f2chk_len_vld;

wire    [7:0]       bb_frame_data;
wire                bb_frame_data_vld;
wire    [15:0]      bb_frame_len;
wire                bb_frame_len_vld;

wire    [7:0]       ctrl_f2chk_data;
wire                ctrl_f2chk_data_vld;
wire    [15:0]      ctrl_f2chk_len;
wire                ctrl_f2chk_len_vld;

wire    [7:0]       ctrl_frame_data;
wire                ctrl_frame_data_vld;
wire    [15:0]      ctrl_frame_len;
wire                ctrl_frame_len_vld;

wire    [7:0]       circuit_frame_data;
wire                circuit_frame_data_vld;
wire    [7:0]       circuit_frame_type;
wire    [15:0]      circuit_frame_len;
wire                circuit_frame_len_vld;

frame_parse bsn_frame_parse(
    .sys_clk            (clk100m            ),
    .rst_n              (rst_n_100m         ),
    
    .ldpc_da            (ldpc_data          ),
    .ldpc_vld           (ldpc_vld           ),
    .timeslot_in        (slottimesw_id      ),
    .ldpc_in        	(ldpc_id      		),
    
    .byte_rd            (bsn_byte_rd        ),
    .timeslot           (bsn_timeslot       ),
    .ts_vld             (bsn_ts_vld         ),
    
    .frame_data         (bsn_f2chk_data     ),
    .data_vld           (bsn_f2chk_data_vld ),
    .frame_len          (bsn_f2chk_len      ),
    .len_vld            (bsn_f2chk_len_vld  )
);

frame_check bsn_frame_check(
    .sys_clk            (clk100m            ),
    .rst_n              (rst_n_100m         ),
    
    .frame_data_in      (bsn_f2chk_data     ),
    .data_vld_in        (bsn_f2chk_data_vld ),
    .frame_len_in       (bsn_f2chk_len      ),
    .len_vld_in        	(bsn_f2chk_len_vld  ),
    
    .frame_data_out     (bsn_frame_data     ),
    .data_vld_out       (bsn_frame_data_vld ),
    .frame_len_out      (bsn_frame_len      ),
    .len_vld_out        (bsn_frame_len_vld  )
);

frame_parse bb_frame_parse(
    .sys_clk            (clk100m            ),
    .rst_n              (rst_n_100m         ),
    
    .ldpc_da            (ldpc_data          ),
    .ldpc_vld           (ldpc_vld           ),
    .timeslot_in        (slottimesw_id      ),
    .ldpc_in        	(ldpc_id      		),
    
    .byte_rd            (bb_byte_rd        ),
    .timeslot           (bb_timeslot       ),
    .ts_vld             (bb_ts_vld         ),
    
    .frame_data         (bb_f2chk_data     ),
    .data_vld           (bb_f2chk_data_vld ),
    .frame_len          (bb_f2chk_len      ),
    .len_vld            (bb_f2chk_len_vld  )
);

frame_check bb_frame_check(
    .sys_clk            (clk100m            ),
    .rst_n              (rst_n_100m         ),
    
    .frame_data_in      (bb_f2chk_data     ),
    .data_vld_in        (bb_f2chk_data_vld ),
    .frame_len_in       (bb_f2chk_len      ),
    .len_vld_in        	(bb_f2chk_len_vld  ),
    
    .frame_data_out     (bb_frame_data     ),
    .data_vld_out       (bb_frame_data_vld ),
    .frame_len_out      (bb_frame_len      ),
    .len_vld_out        (bb_frame_len_vld  )
);

frame_parse ctrl_frame_parse(
    .sys_clk            (clk100m            ),
    .rst_n              (rst_n_100m         ),
    
    .ldpc_da            (ldpc_data          ),
    .ldpc_vld           (ldpc_vld           ),
    .timeslot_in        (slottimesw_id      ),
    .ldpc_in        	(ldpc_id      		),
    
    .byte_rd            (ctrl_byte_rd        ),
    .timeslot           (ctrl_timeslot       ),
    .ts_vld             (ctrl_ts_vld         ),
    
    .frame_data         (ctrl_f2chk_data     ),
    .data_vld           (ctrl_f2chk_data_vld ),
    .frame_len          (ctrl_f2chk_len      ),
    .len_vld            (ctrl_f2chk_len_vld  )
);

frame_check ctrl_frame_check(
    .sys_clk            (clk100m            ),
    .rst_n              (rst_n_100m         ),
    
    .frame_data_in      (ctrl_f2chk_data     ),
    .data_vld_in        (ctrl_f2chk_data_vld ),
    .frame_len_in       (ctrl_f2chk_len      ),
    .len_vld_in        	(ctrl_f2chk_len_vld  ),
    
    .frame_data_out     (ctrl_frame_data     ),
    .data_vld_out       (ctrl_frame_data_vld ),
    .frame_len_out      (ctrl_frame_len      ),
    .len_vld_out        (ctrl_frame_len_vld  )
);

circuit_parse u_circuit_parse(
    .sys_clk            (clk100m            ),
    .rst_n              (rst_n_100m         ),
    
    .ldpc_data          (ldpc_data          ),
    .ldpc_vld           (ldpc_vld           ),
    .timeslot_in        (slottimesw_id      ),
    .ldpc_in        	(ldpc_id      		),
    
    .bit_rd             (circuit_bit_rd     ),
    .timeslot           (circuit_timeslot   ),
    .bit_vld            (circuit_bit_vld    ),
    
    .frame_data         (circuit_frame_data     ),
    .frame_data_vld     (circuit_frame_data_vld ),
    .frame_type         (circuit_frame_type     ),
    .frame_len          (circuit_frame_len      ),
    .frame_len_vld      (circuit_frame_len_vld  )
);

//************************* three way to one way **************************

wire    [7:0]   sdl_frame_data;
wire            sdl_frame_data_vld;
wire    [7:0]   sdl_frame_type;
wire    [7:0]   sdl_data_type;
wire    [15:0]  sdl_frame_len;
wire            sdl_frame_len_vld;

frame_shape u_frame_shape(
    .sys_clk            (clk100m),
    .rst_n              (rst_n_100m),
    
    .bsn_frame_data     (bsn_frame_data),
    .bsn_frame_data_vld (bsn_frame_data_vld),
    .bsn_frame_type     (8'h8B),
    .bsn_frame_len      (bsn_frame_len),
    .bsn_frame_len_vld  (bsn_frame_len_vld),
    
    .bb_frame_data      (bb_frame_data),
    .bb_frame_data_vld  (bb_frame_data_vld),
    .bb_frame_type      (8'h8B),
    .bb_frame_len       (bb_frame_len),
    .bb_frame_len_vld   (bb_frame_len_vld),
    
    .ctrl_frame_data    (ctrl_frame_data),
    .ctrl_frame_data_vld (ctrl_frame_data_vld),
    .ctrl_frame_type      (8'h8B),
    .ctrl_frame_len     (ctrl_frame_len),
    .ctrl_frame_len_vld (ctrl_frame_len_vld),
	
    .circuit_frame_data (circuit_frame_data),
    .circuit_frame_data_vld (circuit_frame_data_vld),
    .circuit_frame_type (circuit_frame_type),
    .circuit_frame_len  (circuit_frame_len),
    .circuit_frame_len_vld  (circuit_frame_len_vld),    
    
    .sdl_frame_data     (sdl_frame_data),
    .sdl_frame_data_vld (sdl_frame_data_vld),
    .sdl_frame_type     (sdl_frame_type),
    .sdl_data_type      (sdl_data_type),
    .sdl_frame_len      (sdl_frame_len),
    .sdl_frame_len_vld  (sdl_frame_len_vld),
	
    .sdl_bsn_cnt  		(sdl_bsn_cnt),
    .sdl_bb_cnt  		(sdl_bb_cnt),
    .sdl_circuit_cnt  	(sdl_circuit_cnt)
);

//************************* sdl add lvds head **************************

sdl_add_head u_sdl_add_head(
    .sys_clk            (clk100m),
    .rst_n              (rst_n_100m),
    
    .frame_data         (sdl_frame_data),
    .frame_data_vld     (sdl_frame_data_vld),
    .frame_type         (sdl_frame_type),
    .data_type          (sdl_data_type),
    .frame_len          (sdl_frame_len),
    .frame_len_vld      (sdl_frame_len_vld),
    
    .lvds_data          (lvds_data),
    .lvds_data_vld      (lvds_data_vld),
    .lvds_data_len      (lvds_data_len),
    .lvds_len_vld       (lvds_len_vld)
);


ila_downlink_parse u_ila_downlink_parse (
	.clk(clk100m), // input wire clk


	.probe0(config_vld), // input wire [0:0]  probe0  
	.probe1(config_data), // input wire [7:0]  probe1 
	.probe2(ldpc_vld), // input wire [0:0]  probe2 
	.probe3(ldpc_data), // input wire [7:0]  probe3 
	.probe4(w_slottimesw_id), // input wire [7:0]  probe4 
	.probe5(bsn_byte_rd), // input wire [0:0]  probe5 
	.probe6(bsn_timeslot), // input wire [9:0]  probe6 
	.probe7(bsn_ts_vld), // input wire [0:0]  probe7 
	.probe8(bb_byte_rd), // input wire [0:0]  probe8 
	.probe9(bb_timeslot), // input wire [9:0]  probe9 
	.probe10(bb_ts_vld), // input wire [0:0]  probe10 
	.probe11(ctrl_byte_rd), // input wire [0:0]  probe8 
	.probe12(ctrl_timeslot), // input wire [9:0]  probe9 
	.probe13(ctrl_ts_vld), // input wire [0:0]  probe10 
	.probe14(circuit_bit_rd), // input wire [0:0]  probe11 
	.probe15(circuit_timeslot), // input wire [9:0]  probe12 
	.probe16(circuit_bit_vld), // input wire [0:0]  probe13 
	.probe17(sdl_frame_data), // input wire [7:0]  probe14 
	.probe18(sdl_frame_data_vld), // input wire [0:0]  probe15 
	.probe19(sdl_frame_type), // input wire [7:0]  probe16 
	.probe20(sdl_frame_len), // input wire [15:0]  probe17 
	.probe21(sdl_frame_len_vld), // input wire [0:0]  probe18 
	.probe22(lvds_data), // input wire [7:0]  probe19 
	.probe23(lvds_data_vld), // input wire [0:0]  probe20 
	.probe24(lvds_data_len), // input wire [15:0]  probe21 
	.probe25(lvds_len_vld), // input wire [0:0]  probe22
	.probe26(w_DL_GearEverySlot)  // input wire [7:0]  probe26
);

ila_frame_parse bsn_ila_frame_parse (
	.clk(clk100m), // input wire clk


	.probe0(bsn_frame_parse.ldpc_vld), // input wire [0:0]  probe0  
	.probe1(bsn_frame_parse.ldpc_da), // input wire [7:0]  probe1 
	.probe2(bsn_frame_parse.ldpc_da_d1), // input wire [7:0]  probe2 
	.probe3(bsn_frame_parse.ldpc_da_d2), // input wire [7:0]  probe3 
	.probe4(bsn_frame_parse.ldpc_da_d3), // input wire [7:0]  probe4 
	.probe5(bsn_frame_parse.timeslot_in), // input wire [7:0]  probe5 
	.probe6(bsn_frame_parse.ldpc_in), // input wire [7:0]  probe6 
	.probe7(bsn_frame_parse.ts_vld), // input wire [0:0]  probe7 
	.probe8(bsn_frame_parse.write_addr), // input wire [12:0]  probe8 
	.probe9(bsn_frame_parse.head_addr), // input wire [12:0]  probe9 
	.probe10(bsn_frame_parse.read_addr), // input wire [12:0]  probe10 
	.probe11(bsn_frame_parse.read_outb), // input wire [7:0]  probe11 
	.probe12(bsn_frame_parse.ram_left), // input wire [12:0]  probe12 
	.probe13(bsn_frame_parse.top_state), // input wire [2:0]  probe13 
	.probe14(bsn_frame_parse.state_period_cnt), // input wire [15:0]  probe14 
	.probe15(bsn_frame_parse.data_len_2B), // input wire [15:0]  probe15 
	.probe16(bsn_frame_parse.crc16_get), // input wire [15:0]  probe16 
	.probe17(bsn_frame_parse.frame_data), // input wire [7:0]  probe17 
	.probe18(bsn_frame_parse.data_vld), // input wire [0:0]  probe18 
	.probe19(bsn_frame_parse.frame_len), // input wire [15:0]  probe19 
	.probe20(bsn_frame_parse.len_vld) // input wire [0:0]  probe20
);


ila_frame_check bsn_ila_frame_check (
	.clk(clk100m), // input wire clk


	.probe0(bsn_frame_check.data_vld_in), // input wire [0:0]  probe0  
	.probe1(bsn_frame_check.frame_data_in), // input wire [7:0]  probe1 
	.probe2(bsn_frame_check.frame_data_in_d1), // input wire [7:0]  probe2 
	.probe3(bsn_frame_check.frame_data_in_d2), // input wire [7:0]  probe3 
	.probe4(bsn_frame_check.crc_out), // input wire [15:0]  probe4 
	.probe5(bsn_frame_check.crc_out_vld), // input wire [0:0]  probe5 
	.probe6(bsn_frame_check.check_result), // input wire [0:0]  probe6 
	.probe7(bsn_frame_check.frame_data_out), // input wire [7:0]  probe7 
	.probe8(bsn_frame_check.data_vld_out) // input wire [0:0]  probe8
);

vio_frame_parse bsn_vio_frame_parse (
  .clk(clk100m),                // input wire clk
  .probe_in0(bsn_frame_parse.cap_cnt),    // input wire [31 : 0] probe_in0
  .probe_in1(bsn_frame_check.frame_cnt),    // input wire [31 : 0] probe_in1
  .probe_out0(bsn_frame_parse.cap_data),  // output wire [31 : 0] probe_out0
  .probe_out1(bsn_frame_parse.cap_en)  // output wire [0 : 0] probe_out1
);

endmodule
