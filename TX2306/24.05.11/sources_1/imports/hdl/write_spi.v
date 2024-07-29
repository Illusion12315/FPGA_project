//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/14 11:26:45
// Design Name: 
// Module Name: write_spi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// SPI写操作，将write_data转换成SPI信号线的CLK、SDIO、CSB。写操作不区分3wire和4wire。
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module write_spi(
	input clk,
	input rst_n,
	input [23:0] write_data,		//要写的数据，1rw+2ww+13a+8d
	input write_data_valid,			//写数据有效
	//
	output reg sclk_w,				//输出到SPI时钟管脚
	output reg write_data_out,		//输出到SDIO数据管脚
	output reg csb_w,				//输出到SPI片选管脚
	//
	output reg once_end_w			//SPI一次写完成
	// output reg write_en
    );
//edge detection
reg 	write_data_valid_r;
wire 	write_data_valid_p;
always @(posedge clk)
begin
	if(!rst_n)
	write_data_valid_r	<=0;
	else
	write_data_valid_r	<=write_data_valid;
end
assign write_data_valid_p = !write_data_valid_r&&write_data_valid;


//start sig
reg work_sig;
always @(posedge clk)
begin
	if(!rst_n)
	work_sig	<=0;
	else begin
		if(write_data_valid_p)
		work_sig	<=1;
		else 
		work_sig	<=0;
	end
end
//registe data	
reg [23:0] 	transfer_data_r;
always @(posedge clk)
begin
	if(!rst_n)
	transfer_data_r	<=0;
	else begin
		if(write_data_valid_p)
		transfer_data_r	<=write_data;
		else
		transfer_data_r	<=transfer_data_r;
	end
end
	
	
	
//frequency division 
reg time_en;

reg [1:0] r1;
always @(posedge clk)
begin
    if(!rst_n)
    begin
    r1  <= 2'b01;
    end
    else
        begin
        if(time_en)
            begin
                r1  <={r1[0],r1[1]};      
            end
        else
            begin
                r1  <= 2'b01;
            end
        end
end

always @(posedge clk)
begin
    if(!rst_n)
    begin
        sclk_w  <=0;
    end   
    else
    begin
		if(time_en)
		begin
			if(r1[0])  
				sclk_w  <=1;
			else
				sclk_w  <=0;
		end
		else 
		sclk_w  <=0;
	end
end 

//negedge
reg sclk_w_r;
wire sclk_w_n;
always @(posedge clk)
begin
	if(!rst_n)
	sclk_w_r	<=0;
	else
	sclk_w_r	<=sclk_w;
end

assign sclk_w_n=!sclk_w&&sclk_w_r;

//work
reg [4:0] i;
always @(posedge clk)
begin
	if(!rst_n)
	begin
	write_data_out	<=0;
	csb_w			<=1;
	i 				<=0;
	once_end_w		<=0;
	time_en			<=0;
	end
	else begin
		case(i)
		5'd0:begin
			once_end_w		<=0;
			if(work_sig)
			begin
				i				<=i+1;
				time_en			<=1;
				write_data_out	<=transfer_data_r[23];
				csb_w			<=0;	
			end
			else
				i	<=0;
		end
		5'd1,5'd2,5'd3,5'd4,5'd5,5'd6,5'd7,5'd8,5'd9,5'd10,5'd11,5'd12,5'd13,5'd14,5'd15,
		5'd16,5'd17,5'd18,5'd19,5'd20,5'd21,5'd22,5'd23:
			begin
			if(sclk_w)
				begin
				once_end_w		<=0;
				i				<=i+1;
				write_data_out	<=transfer_data_r[23-i];				//high out first
				end
			end
		5'd24:begin
		if(sclk_w)
			begin
			write_data_out		<=0;
			csb_w			<=1;	
			time_en			<=0;
			i				<=0;
			once_end_w		<=1;
			end
		end
		default :begin
			once_end_w		<=0;
			write_data_out	<=0;
			csb_w			<=1;	
			time_en			<=0;
			i				<=0;
		end
		endcase
	end
end

// always @(posedge clk)
// begin
	// if(!rst_n)	begin
		// time_en			<=0;
		// end
	// else begin
	// if()




// end



endmodule
