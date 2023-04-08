module HandleDigit3(
    input [1:0] state,
    input btnu,
    input [4:0] counter,
    input [4:0] Point,
    input val3,
    output reg nvl3
);

    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;

    always @(*) begin
        case (state)
            INITIAL:begin
                if(btnu) nvl3 = 4'd3;
                else nvl3 = 4'd13;
            end
            GAME:begin
                if( counter > 0 && Point < 10) begin
                    if(counter < 10)begin
                        nvl3 = 0;
                    end else if( counter > 9 && counter < 20 )begin
                        nvl3 = 1;
                    end else if( counter > 19 && counter < 30 )begin
                        nvl3 = 2;
                    end else begin
                        nvl3 = 3;
                    end
                end else begin
                    if(Point > 9) nvl3 = 4'd13;
                    else nvl3 = 4'd0;
                end
            end
            FINAL:begin
                if(btnu) nvl3 = 4'd3;
                else nvl3 = val3;
            end 
            default:begin
                if(btnu) nvl3 = 4'd3;
                else nvl3 = val3;
            end
        endcase
    end
endmodule