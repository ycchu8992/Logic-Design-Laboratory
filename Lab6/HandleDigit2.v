module HandleDigit2(
    input [1:0] state,
    input btnu,
    input [4:0] counter,
    input [4:0] Point,
    input val2,
    output reg nvl2
);

    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;
    always @(*) begin
        case (state)
            INITIAL:begin
                if(btnu) nvl2 = 4'd0;
                else nvl2 = 4'd13;
            end
            GAME:begin
                if( counter > 0 && Point < 10) begin
                    if(counter < 10)begin
                        case(counter)
                            5'd0:nvl2 = 4'd0;
                            5'd1:nvl2 = 4'd1;
                            5'd2:nvl2 = 4'd2;
                            5'd3:nvl2 = 4'd3;
                            5'd4:nvl2 = 4'd4;
                            5'd5:nvl2 = 4'd5;
                            5'd6:nvl2 = 4'd6;
                            5'd7:nvl2 = 4'd7;
                            5'd8:nvl2 = 4'd8;
                            5'd9:nvl2 = 4'd9;
                            default:nvl2 = 4'd0;
                        endcase
                    end else if( counter > 9 && counter < 20 )begin
                        case(counter-10)
                            5'd0:nvl2 = 4'd0;
                            5'd1:nvl2 = 4'd1;
                            5'd2:nvl2 = 4'd2;
                            5'd3:nvl2 = 4'd3;
                            5'd4:nvl2 = 4'd4;
                            5'd5:nvl2 = 4'd5;
                            5'd6:nvl2 = 4'd6;
                            5'd7:nvl2 = 4'd7;
                            5'd8:nvl2 = 4'd8;
                            5'd9:nvl2 = 4'd9;
                            default:nvl2 = 4'd0;
                        endcase
                    end else if( counter > 19 && counter < 30 )begin
                        case(counter-20)
                            5'd0:nvl2 = 4'd0;
                            5'd1:nvl2 = 4'd1;
                            5'd2:nvl2 = 4'd2;
                            5'd3:nvl2 = 4'd3;
                            5'd4:nvl2 = 4'd4;
                            5'd5:nvl2 = 4'd5;
                            5'd6:nvl2 = 4'd6;
                            5'd7:nvl2 = 4'd7;
                            5'd8:nvl2 = 4'd8;
                            5'd9:nvl2 = 4'd9;
                            default:nvl2 = 4'd0;
                        endcase
                    end else begin
                        case(counter-30)
                            5'd0:nvl2 = 4'd0;
                            5'd1:nvl2 = 4'd1;
                            default:nvl2 = 0;
                        endcase
                    end
                end else begin
                    if(Point > 9) nvl2 = 4'd10;
                    else nvl2 = 4'd0;
                end
            end
            FINAL:begin
                if(btnu) nvl2 = 4'd0;
                else nvl2 = val2;
            end 
            default:begin
                if(btnu) nvl2 = 4'd0;
                else nvl2 = val2;
            end
        endcase
    end
endmodule