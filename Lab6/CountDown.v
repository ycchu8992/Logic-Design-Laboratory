module CounDown(
    input wire sec,
    input wire RST,
    input wire btnu,
    input wire state,
    input wire Point,
    output reg [4:0] counter
);

    reg [4:0] ncounter;
    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;

    always @(posedge sec) begin
        if(RST) counter <= 5'd30;
        else counter <= ncounter;
    end
    always @(*) begin
        case (state)
            INITIAL:begin
                if(btnu) ncounter = 5'd30;
                else ncounter = 5'd30;
            end
            GAME:begin
                if( counter > 0 && Point < 10) ncounter = counter - 1;
                else ncounter = 0;
            end
            FINAL:begin
                if(btnu) ncounter = 5'd30;
                else ncounter = 5'd30;
            end 
            default:begin
                if(btnu) ncounter = 5'd30;
                else ncounter = counter - 1;
            end
        endcase
    end
endmodule