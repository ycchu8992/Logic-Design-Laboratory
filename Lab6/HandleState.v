module HandleState(
    input [1:0] state,
    input btnu,
    input [4:0] counter,
    input [4:0] Point,
    output reg [1:0] nstate
);
    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;
    always @(*) begin
        case (state)
            INITIAL:begin
                if(btnu) nstate = GAME;
                else nstate = INITIAL;
            end
            GAME:begin
                if( counter > 0 && Point < 10) nstate = GAME;
                else nstate = FINAL;
            end
            FINAL:begin
                if(btnu) nstate = GAME;
                else nstate = FINAL;
            end 
            default:begin
                nstate = INITIAL;
            end
        endcase
    end
endmodule