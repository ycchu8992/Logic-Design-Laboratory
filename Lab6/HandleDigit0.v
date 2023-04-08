module HandleDigit0(
    input [1:0] state,
    input btnu,
    input [4:0] counter,
    input [4:0] Point,
    input val0,
    output reg nvl0
);
    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;
    always @(*) begin
        case (state)
            INITIAL:begin
                if(btnu) nvl0 = 4'd0;
                else nvl0 = 4'd13;
            end
            GAME:begin
                if( counter > 0 && Point < 10) begin
                    if(Point < 10)begin
                        case(Point)
                            5'd0:nvl0 = 4'd0;
                            5'd1:nvl0 = 4'd1;
                            5'd2:nvl0 = 4'd2;
                            5'd3:nvl0 = 4'd3;
                            5'd4:nvl0 = 4'd4;
                            5'd5:nvl0 = 4'd5;
                            5'd6:nvl0 = 4'd6;
                            5'd7:nvl0 = 4'd7;
                            5'd8:nvl0 = 4'd8;
                            5'd9:nvl0 = 4'd9;
                            default:nvl0 = 4'd0;
                        endcase
                    end else if( Point > 9 && Point < 20 )begin
                        case(Point-10)
                            5'd0:nvl0 = 4'd0;
                            5'd1:nvl0 = 4'd1;
                            5'd2:nvl0 = 4'd2;
                            5'd3:nvl0 = 4'd3;
                            5'd4:nvl0 = 4'd4;
                            5'd5:nvl0 = 4'd5;
                            5'd6:nvl0 = 4'd6;
                            5'd7:nvl0 = 4'd7;
                            5'd8:nvl0 = 4'd8;
                            5'd9:nvl0 = 4'd9;
                            default:nvl0 = 4'd0;
                        endcase
                    end else if( Point > 19 && Point < 30 )begin
                        case(Point-20)
                            5'd0:nvl0 = 4'd0;
                            5'd1:nvl0 = 4'd1;
                            5'd2:nvl0 = 4'd2;
                            5'd3:nvl0 = 4'd3;
                            5'd4:nvl0 = 4'd4;
                            5'd5:nvl0 = 4'd5;
                            5'd6:nvl0 = 4'd6;
                            5'd7:nvl0 = 4'd7;
                            5'd8:nvl0 = 4'd8;
                            5'd9:nvl0 = 4'd9;
                            default:nvl0 = 4'd0;
                        endcase
                    end else begin
                        case(Point-30)
                            5'd0:nvl0 = 4'd0;
                            5'd1:nvl0 = 4'd1;
                            default:nvl0 = 4'd0;
                        endcase
                    end
                end else begin
                    if(Point > 9) nvl0 = 4'd12;
                    else nvl0 = val0;
                end
            end
            FINAL:begin
                if(btnu) nvl0 = 4'd0;
                else nvl0 = val0;
            end 
            default:begin
                if(btnu) nvl0 = 4'd0;
                else nvl0 = val0;
            end
        endcase
    end
endmodule