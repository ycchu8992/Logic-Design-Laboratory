module SegmentDisplay (
    input Dclk,
    input [3:0] val3,
    input [3:0] val2,
    input [3:0] val1,
    input [3:0] val0,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY
);
    reg [3:0] value;

    /*---------------------------
    7-Segment Display Controller
    ---------------------------*/
    always @(posedge Dclk) begin
        case(DIGIT)
            4'b1110:begin
                value <= val1;
                DIGIT <= 4'b1101;
            end
            4'b1101:begin
                value <= val2;
                DIGIT <= 4'b1011;
            end
            4'b1011:begin
                value <= val3;
                DIGIT <= 4'b0111;
            end
            4'b0111:begin
                value <= val0;
                DIGIT <= 4'b1110;
            end
            default:begin
                value <= val0;
                DIGIT <= 4'b1110;
            end
        endcase
    end
    always @(*) begin
        case(value)
            4'd0:DISPLAY = 7'b100_0000;
            4'd1:DISPLAY = 7'b111_1001;
            4'd2:DISPLAY = 7'b010_0100;
            4'd3:DISPLAY = 7'b011_0000;
            4'd4:DISPLAY = 7'b001_1001;
            4'd5:DISPLAY = 7'b001_0010;
            4'd6:DISPLAY = 7'b000_0010;
            4'd7:DISPLAY = 7'b111_1000;
            4'd8:DISPLAY = 7'b000_0000;
            4'd9:DISPLAY = 7'b001_0000;
            4'd10:DISPLAY = 7'b110_0010;//w
            4'd11:DISPLAY = 7'b100_1111;//I
            4'd12:DISPLAY = 7'b100_1000;//N
            4'd13:DISPLAY = 7'b011_1111;//-
            default:DISPLAY = 7'b111_1111;
        endcase
    end
endmodule