module HitHandler(
    input [1:0] state,
    input [8:0] hit,
    input [15:0] LED,
    input [3:0] nums,
    input [26:0] sCnt,
    output reg [8:0] nhit
);
    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;

    always @(*) begin
        case (state)
            GAME:begin
                if( sCnt < 27'd100000000) begin
                    nhit = hit;
                    if(nums)begin
                        if( LED[16-nums] && !hit[nums-1] ) nhit[nums-1] = 1;
                        else nhit = hit;
                    end else nhit = hit;
                end
                else begin
                    nhit = 9'b0;
                end
            end
            default:begin
                nhit = 9'b0;
            end
        endcase
    end
endmodule