module HandleDigit1(
    input [1:0] state,
    input btnu,
    input [4:0] counter,
    input [4:0] Point,
    input val1,
    output reg nvl1
);
    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;
    always @(*) begin
        case (state)
            INITIAL:begin
                if(btnu) nvl1 = 4'd0;
                else nvl1 = 4'd13;
            end
            GAME:begin
                if( counter > 0 && Point < 10) begin
                    if(Point < 10)begin
                        nvl1 = 0;
                    end else if( Point > 9 && Point < 20 )begin
                        nvl1 = 1;
                    end else if( Point > 19 && Point < 30 )begin
                        nvl1 = 2;
                    end else begin
                        nvl1 = 3;
                    end
                end else begin
                    if(Point > 9) nvl1 = 4'd11;
                    else nvl1 = val1;
                end
            end
            FINAL:begin
                if(btnu) nvl1 = 4'd0;
                else nvl1 = val1;
            end 
            default:begin
                if(btnu) nvl1 = 4'd0;
                else nvl1 = val1;
            end
        endcase
    end
endmodule