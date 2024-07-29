module lvds_s2p 
(   clk         ,
    clk_m_144   ,
    rst_n       ,
    rstn        ,
    s2p_din     ,

//    dout_start  ,
     dout_en  ,
    
    s2p_dout    
);

//input output
    input            clk        ;
    input            clk_m_144  ;  
    input            rst_n      ;
    input            rstn       ;
    input   [3:0]    s2p_din    ;
    
    output           s2p_dout   ;
//    output           dout_start ;
    output            dout_en ;
    
//reg

    reg     [0:0]    s2p_din_d0     ; 
    reg     [0:0]    s2p_din_d1     ;
    
    reg     [13:0]   wraddr         ;
    reg     [11:0]   rdaddr         ;
   
    reg     [14:0]   cnt_din        ;
    reg     [14:0]   cnt_din_d1     ;
    wire     [14:0]   cnt_din_d2     ;
    reg              s2p_vldout     ;
    reg              s2p_vldout_d1  ;
    reg              dout_start     ;
    reg              read_start     ;
    reg     [7:0]    read_start_d1  ;
    reg     [7:0]    dout1_d1       ;
    reg              read_vld       ;
    reg     [11:0]   rdaddr_1d      ;
    reg     [11:0]   rdaddr_2d      ;
    reg              vldin_flag     ; 
    reg              vldin_flag_d1  ; 
    wire     [8:0]    s2p_dout       ;  
//wire    
   
    wire    [7:0]    dout1          ;
    wire             read_finish    ;


//s2p din vld
    always @ (posedge clk or negedge rstn)begin
        if(!rstn) begin
            vldin_flag <= 1'b0;
            vldin_flag_d1 <= 1'b0;
        end
        else begin
            vldin_flag <= s2p_din[3];
            vldin_flag_d1 <= vldin_flag;
        end
    end

//s2p data          
    always @ (posedge clk or negedge rstn)begin
        if(!rstn)begin
            s2p_din_d0 <= 1'd0;
            s2p_din_d1 <= 1'b0;
        end
        else begin 
            s2p_din_d0 <= s2p_din[0];
            s2p_din_d1 <= s2p_din_d0;
        end
    end  
    
 
// ila_bit ila_bit_inst (
//	.clk(clk), // input wire clk


//	.probe0(vldin_flag), // input wire [0:0]  probe0  
//	.probe1(s2p_din_d0) // input wire [0:0]  probe1
//);
    


    always @ (posedge clk or negedge rstn)begin
        if(!rstn)
            read_start <= 1'd0;
        else if((~vldin_flag) & vldin_flag_d1)
            read_start <= 1'b1;
        else
            read_start <= 1'd0;
    end  
 wire xpm_read_start;
    
    xpm_cdc_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   xpm_cdc_read_start_inst (
      .dest_out(xpm_read_start), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk_m_144), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(read_start)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );   
    
    always @ (posedge clk_m_144 )begin
        read_start_d1 <= {read_start_d1[6:0],xpm_read_start};
    end  
              
    always @ (posedge clk or negedge rstn)begin
        if(!rstn)
            cnt_din <= 15'd0 ;
        else if(read_start)
            cnt_din <= wraddr; 
        else 
            cnt_din <= cnt_din; 
    end   



    
//   always @ (posedge clk_m_144 or negedge rst_n )begin
//    if(rst_n ==1'b0)begin
//        cnt_din_d1 <= 15'd0 ;
//        cnt_din_d2 <= 15'd0;
//    end 
//    else begin
//        cnt_din_d1 <= cnt_din ;
//        cnt_din_d2 <= cnt_din_d1;
//    end 
//    end  
 //----------------------
 wire   fifo_full;
 wire   fifo_empty;
 wire   fifo_wr_en;
 wire   fifio_rd_en;
 
 assign fifo_wr_en = !fifo_full;
 assign fifio_rd_en = !fifo_empty;
 fifo_s2p fifo_s2p_inst (
  .rst(!rstn),        // input wire rst
  .wr_clk(clk),  // input wire wr_clk
  .rd_clk(clk_m_144),  // input wire rd_clk
  .din(cnt_din),        // input wire [14 : 0] din
  .wr_en(fifo_wr_en),    // input wire wr_en
  .rd_en(fifio_rd_en),    // input wire rd_en
  .dout(cnt_din_d2),      // output wire [14 : 0] dout
  .full(fifo_full),      // output wire full
  .empty(fifo_empty)    // output wire empty
);

//wr_addr
    always @ (posedge clk or negedge rstn)begin
        if(!rstn) 
            wraddr <= 12'd0;     
        else if(vldin_flag_d1 == 1'b1)
            wraddr <= wraddr + 1'b1;
        else
            wraddr <= 12'd0; 
    end

    assign read_finish=(rdaddr == ((cnt_din_d2>>2'd3)-2'd2))?1:0;

    always @ (posedge clk_m_144 or negedge rst_n)begin
        if(!rst_n) 
            read_vld <= 12'd0;     
        else if(read_start_d1[7] & (cnt_din_d2 > 3'd5))
            read_vld <= 12'd1;
        else if(read_vld & read_finish)
            read_vld <= 12'd0; 
    end

//rdaddr
    always @ (posedge clk_m_144 or negedge rst_n)begin
        if(!rst_n)
            rdaddr <= 12'd0;
        else if(read_vld)
            begin
//                if(rdaddr == 12'd23)
//                    rdaddr <= 12'd44;
//                else
                    rdaddr <= rdaddr + 1'b1 ;
            end
        else 
            rdaddr <= 12'b0;
    end



    always @ (posedge clk_m_144 )begin
           rdaddr_1d <= rdaddr;
    end
 
    
   always @ (posedge clk_m_144 or negedge rst_n)begin
       if(!rst_n)
           s2p_vldout <= 1'd0;
       else if(rdaddr_1d > 12'd13)
           s2p_vldout <= 1'b1 ;
       else 
           s2p_vldout <= 1'b0;
   end

   always @ (posedge clk_m_144 or negedge rst_n)begin
        if(!rst_n)
            s2p_vldout_d1 <= 1'd0;
        else
            s2p_vldout_d1 <= s2p_vldout;
   end

   always @ (posedge clk_m_144 or negedge rst_n)begin
      if(!rst_n)
            dout_start <= 1'd0;
      else if(s2p_vldout & (!s2p_vldout_d1))
            dout_start <= 1'b1 ;
      else
            dout_start <= 1'b0;
   end

//   always @ (posedge clk_m_144 or negedge rst_n)begin
//       if(!rst_n)
//           s2p_dout <= 9'd0;
//       else 
//           s2p_dout <= {s2p_vldout_d1,dout1_d1[0],dout1_d1[1],dout1_d1[2],dout1_d1[3],
//                        dout1_d1[4],dout1_d1[5],dout1_d1[6],dout1_d1[7]};
//   end

assign  s2p_dout = {s2p_vldout_d1,dout1_d1[0],dout1_d1[1],dout1_d1[2],dout1_d1[3],
                                  dout1_d1[4],dout1_d1[5],dout1_d1[6],dout1_d1[7]};

   always @ (posedge clk_m_144 or negedge rst_n)begin
        if(!rst_n)
            dout1_d1 <= 1'd0;
        else
            dout1_d1 <= dout1;
   end


//-----------------
reg    dout_en_r;
reg    s2p_vldout_dr;

always @(posedge clk_m_144 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        s2p_vldout_dr <= 1'b0;
    end 
    else begin
        s2p_vldout_dr <=s2p_vldout_d1;
    end 
end 


always @(posedge clk_m_144 or negedge rst_n)begin
    if(rst_n ==1'b0)begin
        dout_en_r <= 1'b0;
    end 
    else if(!s2p_vldout_d1 && s2p_vldout_dr)begin
        dout_en_r <= 1'b0;
    end 
    else if(rdaddr_1d==12'd2)begin
        dout_en_r <= 1'b1;
    end 
    else begin
        dout_en_r <= dout_en_r;
    end 
end 

assign dout_en = dout_en_r;


//ip 
RAM_16384X1_2048X8   RAM (
      .clka             (clk             ) ,       // input wire clka
      .ena              (1'b1            ) ,       // input wire ena
      .wea              (vldin_flag_d1   ) ,       // input wire [0 : 0] wea
      .addra            (wraddr          ) ,       // input wire [13 : 0] addra
      .dina             (s2p_din_d1      ) ,       // input wire [0 : 0] dina
      .clkb             (clk_m_144       ) ,       // input wire clkb
      .enb              (1'b1            ) ,       // input wire enb
      .addrb            (rdaddr_1d       ) ,       // input wire [11 : 0] addrb
      .doutb            (dout1           )         // output wire [7 : 0] doutb
);


////////////////////////////////////////////////////////////////////////////////////

//ILA_S2P   U_ILA_S2P_144   (
//                        .clk        ( clk_m_144           ), // input wire clk
                      
//                        .probe0     ( rdaddr              ), // input wire [11:0]  probe0 
//                        .probe1     ( s2p_vldout          ), // input wire [0:0]  probe1 
//                        .probe2     ( s2p_vldout_d1       ), // input wire [0:0]  probe2 
//                        .probe3     ( dout_start          ), // input wire [0:0]  probe3            
//                        .probe4     ( read_start_d1       ), // input wire [7:0]  probe4     
//                        .probe5     ( read_vld            ), // input wire [0:0]  probe5    
//                        .probe6     ( s2p_dout            ), // input wire [8:0]  probe6    
//                        .probe7     ( rdaddr_1d           ), // input wire [11:0] probe7    
//                        .probe8     ( dout1               ), // input wire [7:0]  probe8    
//                        .probe9     ( read_finish         ), // input wire [0:0]  probe9    
//                        .probe10    ( cnt_din_d2          ) , // input wire [14:0] probe10    
//                        .probe11    (dout_en), // input wire [0:0]  probe11 
//	                    .probe12    (s2p_vldout_dr) // input wire [0:0]  probe12
                       
//                        );

endmodule


 