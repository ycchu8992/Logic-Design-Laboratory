module MyClockDivider #(parameter n=100)(
    input clk,
    output wire clk_div  
);
    reg CLK_Out;
    integer counter = 0;
    always @(posedge clk) begin
        counter <= counter + 1;
        if(counter >= n-1) counter <= 0;
    end
    always @(posedge clk) begin
        CLK_Out <= (((n-1) >> 1) >= counter)?1'b0:1'b1;
    end
    assign clk_div = CLK_Out;
endmodule