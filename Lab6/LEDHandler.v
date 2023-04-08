module LEDHandler(
    input [1:0] state,
    input [8:0] hit,
    input [15:0] LED,
    input [3:0] nums,
    input [15:0] LFSR1,
    input [15:0] LFSR2,
    input [15:0] LFSR3,
    input [15:0] LFSR4,
    input [15:0] LFSR5,
    input [15:0] LFSR6,
    input [15:0] LFSR7,
    input [15:0] LFSR8,
    input [15:0] LFSR9,
    output reg [15:0] next_led
);
    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;

    reg [15:0] LFSR [8:0];

    always @(*) begin
        LFSR[0] = LFSR1;
        LFSR[1] = LFSR2;
        LFSR[2] = LFSR3;
        LFSR[3] = LFSR4;
        LFSR[4] = LFSR5;
        LFSR[5] = LFSR6;
        LFSR[6] = LFSR7;
        LFSR[7] = LFSR8;
        LFSR[8] = LFSR9;
    end

    integer j;
    always @(*) begin
        case (state)
            GAME:begin
                for (j=0;j<7;j=j+1) begin next_led[j] = 0; end
                if(nums)begin
                    if( LED[16-nums] && !hit[nums-1])begin
                        for (j=7;j<16;j=j+1) begin
                            if(j==(16-nums)) next_led[j] = 0;
                            else if(hit[15-j]) next_led[j] = 0;
                            else next_led[j] = LFSR[15-j][15];
                        end
                    end
                    else begin
                        for (j=7;j<16;j=j+1) begin
                            if(hit[15-j]) next_led[j] = 0;
                            else next_led[j] = LFSR[15-j][15];
                        end
                    end
                end else begin
                    for (j=7;j<16;j=j+1) begin
                        if(hit[15-j]) next_led[j] = 0;
                        else next_led[j] = LFSR[15-j][15];
                    end
                end
            end
            default: next_led = 16'b0;
        endcase   
    end
endmodule