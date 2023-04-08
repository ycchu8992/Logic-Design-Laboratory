module SequentialHandler(
    input clk,
    input RST,
    input [1:0] nstate,
    input [4:0] nPoint,
    input [3:0] nvl3,
    input [3:0] nvl2,
    input [3:0] nvl1,
    input [3:0] nvl0,
    input [8:0] nhit,
    input [15:0] next_led,
    output reg [1:0] state,
    output reg [4:0] Point,
    output reg [3:0] val3,
    output reg [3:0] val2,
    output reg [3:0] val1,
    output reg [3:0] val0,
    output reg [8:0] hit,
    output reg [26:0] sCnt,
    output reg [15:0] LED
);
    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;
    reg [26:0] nsCnt;

    always @(posedge clk) begin
        if(RST) LED <= 16'b0;
        else LED <= next_led;
    end

    always @(posedge clk) begin
        if(RST) sCnt <= 27'd0;
        else sCnt <= nsCnt;
    end

    always @(*) begin
        case (state)
            GAME:begin
                if( sCnt < 27'd100000000 ) nsCnt = sCnt + 27'd1;
                else nsCnt = 27'd0;
            end
            default: nsCnt = 27'd0;
        endcase
    end

    always @(posedge clk) begin
        if(RST) hit <= 9'b0;
        else hit <= nhit;
    end
    /*---------------------------
    Control the state
    ---------------------------*/
    always @(posedge clk) begin
        if(RST) state <= INITIAL;
        else state <= nstate;
    end

    /*----------------------------------
    Handle Points
    -----------------------------------*/
    always @(posedge clk) begin
        if(RST) Point <= 5'd0;
        else Point <= nPoint;  
    end

    /*----------------------------------
    Handle digit 0 
    -----------------------------------*/
    always @(posedge clk) begin
        if(RST) val0 <= 4'd13;
        else val0 <= nvl0;
    end

    /*----------------------------------
    Handle digit 1 
    -----------------------------------*/
    always @(posedge clk) begin
        if(RST) val1 <= 4'd13;
        else val1 <= nvl1;
    end

    /*----------------------------------
    Handle digit 2 
    -----------------------------------*/
    always @(posedge clk) begin
        if(RST) val2 <= 4'd13;
        else val2 <= nvl2;
    end

    /*----------------------------------
    Handle digit 3 
    -----------------------------------*/
    always @(posedge clk) begin
        if(RST) val3 <= 4'd13;
        else val3 <= nvl3;
    end

endmodule