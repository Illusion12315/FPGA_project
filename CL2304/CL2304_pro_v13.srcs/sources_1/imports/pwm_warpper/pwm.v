module pwm (
    input                               sys_clk_i                  ,
    input                               rst_n_i                    ,

    input              [  15:0]         duty_cycle                 ,
    output                              pwm_o                       
);
localparam                              MAX_CNT = 10_000           ;
reg                    [  15:0]         period_cnt                 ;
reg                    [  15:0]         duty_cycle_r1,duty_cycle_r2;

assign pwm_o = (period_cnt>duty_cycle_r2)?'d0:'d1;

always@(posedge sys_clk_i)begin
    duty_cycle_r1<=duty_cycle;
    duty_cycle_r2<=duty_cycle_r1;
end

always@(posedge sys_clk_i or negedge rst_n_i)begin
    if (!rst_n_i) begin
        period_cnt<='d0;
    end
    else if (period_cnt == MAX_CNT) begin
        period_cnt<='d0;
    end
    else
        period_cnt<=period_cnt+'d1;
end
endmodule