module clock_divider #(parameter n=25)(
    input clk,
    output clk_div
);
    wire [n-1:0] next_num;
    reg [n-1:0] num = 0;

    always@(posedge clk) begin
        num <= next_num;
    end

    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module lab3_1
(
    input clk,
    input rst,
    input en,
    input speed,
    output reg [15:0] led
);

wire clk_27, clk_24;
reg clk_use, next_clk_use;

reg [15:0] next_led, led_save, next_led_save;

clock_divider #(.n(27)) clk27(
    .clk(clk),
    .clk_div(clk_27)
);

clock_divider #(.n(24)) clk24(
    .clk(clk),
    .clk_div(clk_24)
);

always@(posedge clk)begin
    clk_use <= next_clk_use;
end

always@(*)begin 
    if(speed) next_clk_use = clk_27;
    else next_clk_use = clk_24;
end

always@(posedge clk_use)begin
    if(rst) led_save <= {1'b1,15'b0};
    else led_save <= next_led_save;
end

always@(*)begin
    if(en) begin
        if(led_save == 16'b1)begin
            next_led_save = {1'b1,15'b0};
        end
        else begin
            next_led_save = led_save >> 1;
        end
    end
    else begin
        next_led_save = led_save;
    end
end


always@(posedge clk)begin
    if(rst) led <= {1'b1,15'b0};
    else led <= led_save;
end

/*
always@(*)begin
    next_led = led_save;;
end
*/

endmodule
