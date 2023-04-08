module HandlePoints(
    input [1:0] state,
    input btnu,
    input [15:0] LED,
    input [4:0] Point,
    input [8:0] hit,
    input [3:0] nums,
    output reg [4:0] nPoint
);
    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;
    
    always @(*) begin
        case (state)
            INITIAL:begin
                if(btnu) nPoint = 0;
                else nPoint = 0;
            end
            GAME:begin
                nPoint = 0;
                if(nums)begin
                    if(LED[16-nums] && !hit[nums-1]) nPoint = Point+1;
                    else nPoint = Point;
                end else nPoint = Point;
            end
            FINAL:begin
            if(btnu) nPoint = 5'd0;
                else nPoint = Point;
            end 
            default:begin
                if(btnu) nPoint = 5'd0;
                else nPoint = 5'd0;
            end
        endcase
    end
endmodule