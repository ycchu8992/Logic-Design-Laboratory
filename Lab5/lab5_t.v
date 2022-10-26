`timescale 1ns/1ns
	  		  	
`define CYCLE_TIME 20.0

module lab5_t();

    reg clk;
    reg rst;
    reg r;
    reg u;
    reg d;
    reg l;
    wire [15:0] led;
    wire [3:0] DIGIT;
    wire [6:0] DISPLAY;

    always #5 clk = ~clk;

    lab5 main(
        .clk(clk),
        .rst(rst),
        .BTNR(r),
        .BTNU(u),
        .BTND(d),
        .BTNL(l),
        .LED(led),
        .DIGIT(DIGIT),
        .DISPLAY(DISPLAY)
    );

    initial begin
        clk = 0;
        rst = 1;
        r=0;
        u=0;
        d=0;
        l=0;

        #10000
        rst = 0;
        
        #10000
        r = 1;
        #10000
        r = 0;

        #10000
        r = 1;//
        #10000
        r = 0;
        #10000
        r = 1;//
        #10000
        r = 0;
        #10000
        r = 1;//
        #10000
        r = 0;
        #10000
        r = 1;//
        #10000
        r = 0;

        #10000
        r = 1;//
        #10000
        r = 0;
        #10000
        r = 1;//
        #10000
        r = 0;
        #10000
        r = 1;//
        #10000
        r = 0;
        #10000
        r = 1;//
        #10000
        r = 0;
    end

endmodule