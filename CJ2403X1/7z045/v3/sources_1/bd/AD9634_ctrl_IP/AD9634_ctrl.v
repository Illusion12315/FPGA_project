
`timescale 1 ns / 1 ps

	module AD9634_ctrl #
	(
		// users to add parameters here

		// user parameters ends
		// do not modify the parameters beyond this line

		// width of s_axi data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// width of s_axi address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 6
	)
	(
		// users to add ports here

		// user ports ends
		// do not modify the ports beyond this line

		// global clock signal
		input wire  s_axi_aclk,
		// global reset signal. this signal is active low
		input wire  s_axi_aresetn,
		// write address (issued by master, acceped by slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
		// write channel protection type. this signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] s_axi_awprot,
		// write address valid. this signal indicates that the master signaling
    		// valid write address and control information.
		input wire  s_axi_awvalid,
		// write address ready. this signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  s_axi_awready,
		// write data (issued by master, acceped by slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
		// write strobes. this signal indicates which byte lanes hold
    		// valid data. there is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
		// write valid. this signal indicates that valid write
    		// data and strobes are available.
		input wire  s_axi_wvalid,
		// write ready. this signal indicates that the slave
    		// can accept the write data.
		output wire  s_axi_wready,
		// write response. this signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] s_axi_bresp,
		// write response valid. this signal indicates that the channel
    		// is signaling a valid write response.
		output wire  s_axi_bvalid,
		// response ready. this signal indicates that the master
    		// can accept a write response.
		input wire  s_axi_bready,
		// read address (issued by master, acceped by slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		// protection type. this signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] s_axi_arprot,
		// read address valid. this signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  s_axi_arvalid,
		// read address ready. this signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  s_axi_arready,
		// read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		// read response. this signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] s_axi_rresp,
		// read valid. this signal indicates that the channel is
    		// signaling the required read data.
		output wire  s_axi_rvalid,
		// read ready. this signal indicates that the master can
    		// accept the read data and response information.
		input wire  s_axi_rready,
		input wire MISO_i,
		output wire RST_o,
		output wire MOSI_o,
		output wire SCLK_o,
		output wire CS_N_o,
		output wire gt_reset_o,
		output wire data_valid_o,
		input wire[3:0] gt_qplllock_i,
		output wire start_sync_o,
		input wire[3:0] synced_i,
		output wire adc_sync_o
	);
	wire SPI_busy;
	wire[15:0] SPI_dout;
	// axi4lite signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// addr_lsb is used for addressing 32/64 bit registers/memories
	// addr_lsb = 2 for 32 bits (n downto 2)
	// addr_lsb = 3 for 64 bits (n downto 3)
	localparam integer addr_lsb = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer opt_mem_addr_bits = 3;
	//----------------------------------------------
	//-- signals for user logic register space example
	//------------------------------------------------
	//-- number of slave registers 16
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg4;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg5;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg6;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg7;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg8;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg9;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg10;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg11;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg12;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg13;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg14;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg15;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	// i/o connections assignments

	assign s_axi_awready	= axi_awready;
	assign s_axi_wready	= axi_wready;
	assign s_axi_bresp	= axi_bresp;
	assign s_axi_bvalid	= axi_bvalid;
	assign s_axi_arready	= axi_arready;
	assign s_axi_rdata	= axi_rdata;
	assign s_axi_rresp	= axi_rresp;
	assign s_axi_rvalid	= axi_rvalid;
	// implement axi_awready generation
	// axi_awready is asserted for one s_axi_aclk clock cycle when both
	// s_axi_awvalid and s_axi_wvalid are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge s_axi_aclk )
	begin
	  if ( s_axi_aresetn == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && s_axi_awvalid && s_axi_wvalid && aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. this design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (s_axi_bready && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// implement axi_awaddr latching
	// this process is used to latch the address when both 
	// s_axi_awvalid and s_axi_wvalid are valid. 

	always @( posedge s_axi_aclk )
	begin
	  if ( s_axi_aresetn == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && s_axi_awvalid && s_axi_wvalid && aw_en)
	        begin
	          // write address latching 
	          axi_awaddr <= s_axi_awaddr;
	        end
	    end 
	end       

	// implement axi_wready generation
	// axi_wready is asserted for one s_axi_aclk clock cycle when both
	// s_axi_awvalid and s_axi_wvalid are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge s_axi_aclk )
	begin
	  if ( s_axi_aresetn == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && s_axi_wvalid && s_axi_awvalid && aw_en )
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. this design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// implement memory mapped register select and write logic generation
	// the write data is accepted and written to memory mapped registers when
	// axi_awready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted. write strobes are used to
	// select byte enables of slave registers while writing.
	// these registers are cleared when reset (active low) is applied.
	// slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && s_axi_wvalid && axi_awready && s_axi_awvalid;

	always @( posedge s_axi_aclk )
	begin
	  if ( s_axi_aresetn == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
	      slv_reg3 <= 0;
	      slv_reg4 <= 0;
	      slv_reg5 <= 0;
	      slv_reg6 <= 0;
	      slv_reg7 <= 0;
	      slv_reg8 <= 0;
	      slv_reg9 <= 0;
	      slv_reg10 <= 0;
	      slv_reg11 <= 0;
	      slv_reg12 <= 0;
	      slv_reg13 <= 0;
	      slv_reg14 <= 0;
	      slv_reg15 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[addr_lsb+opt_mem_addr_bits:addr_lsb] )
	          4'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 3
	                slv_reg3[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'h4:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 4
	                slv_reg4[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'h5:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 5
	                slv_reg5[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'h6:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 6
	                slv_reg6[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'h7:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 7
	                slv_reg7[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'h8:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 8
	                slv_reg8[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'h9:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 9
	                slv_reg9[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'ha:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 10
	                slv_reg10[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'hb:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 11
	                slv_reg11[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'hc:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 12
	                slv_reg12[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'hd:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 13
	                slv_reg13[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'he:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 14
	                slv_reg14[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          4'hf:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( s_axi_wstrb[byte_index] == 1 ) begin
	                // respective byte enables are asserted as per write strobes 
	                // slave register 15
	                slv_reg15[(byte_index*8) +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
	                      slv_reg4 <= slv_reg4;
	                      slv_reg5 <= slv_reg5;
	                      slv_reg6 <= slv_reg6;
	                      slv_reg7 <= slv_reg7;
	                      slv_reg8 <= slv_reg8;
	                      slv_reg9 <= slv_reg9;
	                      slv_reg10 <= slv_reg10;
	                      slv_reg11 <= slv_reg11;
	                      slv_reg12 <= slv_reg12;
	                      slv_reg13 <= slv_reg13;
	                      slv_reg14 <= slv_reg14;
	                      slv_reg15 <= slv_reg15;
	                    end
	        endcase
	      end
	  end
	end    

	// implement write response logic generation
	// the write response and response valid signals are asserted by the slave 
	// when axi_wready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted.  
	// this marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge s_axi_aclk )
	begin
	  if ( s_axi_aresetn == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && s_axi_awvalid && ~axi_bvalid && axi_wready && s_axi_wvalid)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'okay' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (s_axi_bready && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// implement axi_arready generation
	// axi_arready is asserted for one s_axi_aclk clock cycle when
	// s_axi_arvalid is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// the read address is also latched when s_axi_arvalid is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge s_axi_aclk )
	begin
	  if ( s_axi_aresetn == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && s_axi_arvalid)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // read address latching
	          axi_araddr  <= s_axi_araddr;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// implement axi_arvalid generation
	// axi_rvalid is asserted for one s_axi_aclk clock cycle when both 
	// s_axi_arvalid and axi_arready are asserted. the slave registers 
	// data are available on the axi_rdata bus at this instance. the 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge s_axi_aclk )
	begin
	  if ( s_axi_aresetn == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && s_axi_arvalid && ~axi_rvalid)
	        begin
	          // valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'okay' response
	        end   
	      else if (axi_rvalid && s_axi_rready)
	        begin
	          // read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// implement memory mapped register select and read logic generation
	// slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & s_axi_arvalid & ~axi_rvalid;
	always @(*)
	begin
	      // address decoding for reading registers
	      case ( axi_araddr[addr_lsb+opt_mem_addr_bits:addr_lsb] )
	        4'h0   : reg_data_out <= slv_reg0;
	        4'h1   : reg_data_out <= slv_reg1;
	        4'h2   : reg_data_out <= slv_reg2;
	        4'h3   : reg_data_out <= slv_reg3;
	        4'h4   : reg_data_out <= {{31{1'b0}},SPI_busy};
	        4'h5   : reg_data_out <= {{16{1'b0}},SPI_dout};
	        4'h6   : reg_data_out <= slv_reg6;
	        4'h7   : reg_data_out <= slv_reg7;
	        4'h8   : reg_data_out <= {{28{1'b0}},gt_qplllock_i};
	        4'h9   : reg_data_out <= slv_reg9;
	        4'ha   : reg_data_out <= {{28{1'b0}},synced_i};
	        4'hb   : reg_data_out <= slv_reg11;
	        4'hc   : reg_data_out <= slv_reg12;
	        4'hd   : reg_data_out <= slv_reg13;
	        4'he   : reg_data_out <= slv_reg14;
	        4'hf   : reg_data_out <= slv_reg15;
	        default : reg_data_out <= 0;
	      endcase
	end

	// output register or memory read data
	always @( posedge s_axi_aclk )
	begin
	  if ( s_axi_aresetn == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // when there is a valid read address (s_axi_arvalid) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// add user logic here
	AD9634_spi_interface #(
			.NO_OF_CLKS(100)
		) inst_AD9634_spi_interface (
			.ADDR_i     (slv_reg1[7:0]),
			.COMMD_i    (slv_reg2[15:0]),
			.clk_i      (s_axi_aclk),
			.rst_i      (slv_reg0[0]),
			.MISO_i     (MISO_i),
			.SPI_send_i (slv_reg3[0]),
			.RST_o      (RST_o),
			.MOSI_o     (MOSI_o),
			.SCLK_o     (SCLK_o),
			.CS_N_o     (CS_N_o),
			.SPI_busy_o (SPI_busy),
			.dout_o     (SPI_dout)
		);

	assign gt_reset_o = slv_reg6[0];
	assign data_valid_o = slv_reg7[0];
	assign start_sync_o = slv_reg9[0];
	assign adc_sync_o = slv_reg11[0];
	// user logic ends

	endmodule
