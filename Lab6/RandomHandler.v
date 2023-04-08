module RandomHandler(
    input wire sec,
    input wire RST,
    input wire btnu,
    input wire state,
    input wire Point,
    output reg [15:0] LFSR1,
    output reg [15:0] LFSR2,
    output reg [15:0] LFSR3,
    output reg [15:0] LFSR4,
    output reg [15:0] LFSR5,
    output reg [15:0] LFSR6,
    output reg [15:0] LFSR7,
    output reg [15:0] LFSR8,
    output reg [15:0] LFSR9
);

    reg [4:0] ncounter;

    reg [15:0] LFSR [8:0];

    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;

    integer i;

    parameter [15:0] seeds [8:0] = {
        16'b0001_0000_0000_0000,
        16'b0000_0000_0000_0100,
        16'b0000_0000_0000_0001,
        16'b0000_0000_0010_0000,
        16'b0000_0001_0000_0000,
        16'b0000_0000_1000_0000,
        16'b0010_0000_0000_0010,
        16'b0000_1000_0000_0000,
        16'b1000_0100_0000_0000
    };
    
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

    always @(posedge sec) begin
        if(RST) begin
            for (i=0; i < 9; i=i+1) begin
                LFSR[i] <= seeds[i];
            end
        end
        else begin
            for (i=0; i < 9; i=i+1) begin
                LFSR[i] <= {LFSR[i][5]^(LFSR[i][3]^(LFSR[i][2]^LFSR[i][0])), LFSR[i][15:1]};
            end
        end
    end

endmodule