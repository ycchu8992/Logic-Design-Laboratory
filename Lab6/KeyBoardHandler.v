module KeyBoardHandler(
    input clk,
    input RST,
    input [511:0] key_down,
    input [8:0] last_change,
    input been_ready,
    output reg [3:0] nums
);
    parameter FINAL = 2'b10;
    parameter GAME = 2'b01;
    parameter INITIAL = 2'b00;

    reg [3:0] key_num;

    parameter [8:0] KEY_CODES [0:19] = {
        9'b0_0100_0101,	// 0 => 45
        9'b0_0001_0110,	// 1 => 16
        9'b0_0001_1110,	// 2 => 1E
        9'b0_0010_0110,	// 3 => 26
        9'b0_0010_0101,	// 4 => 25
        9'b0_0010_1110,	// 5 => 2E
        9'b0_0011_0110,	// 6 => 36
        9'b0_0011_1101,	// 7 => 3D
        9'b0_0011_1110,	// 8 => 3E
        9'b0_0100_0110,	// 9 => 46
        
        9'b0_0111_0000, // right_0 => 70
        9'b0_0110_1001, // right_1 => 69
        9'b0_0111_0010, // right_2 => 72
        9'b0_0111_1010, // right_3 => 7A
        9'b0_0110_1011, // right_4 => 6B
        9'b0_0111_0011, // right_5 => 73
        9'b0_0111_0100, // right_6 => 74
        9'b0_0110_1100, // right_7 => 6C
        9'b0_0111_0101, // right_8 => 75
        9'b0_0111_1101  // right_9 => 7D
    };

    always @ (posedge clk, posedge RST) begin
        if (RST) begin
            nums <= 4'b0;
        end else begin
            if (been_ready && key_down[last_change] == 1'b1) begin
                if (key_num != 4'b1111)begin
                    nums <= key_num;
                end else nums <= nums;
            end else nums <= nums;
        end
    end

    always @ (*) begin
	case (last_change)
            KEY_CODES[00] : key_num = 4'b0000;
            KEY_CODES[01] : key_num = 4'b0001;
            KEY_CODES[02] : key_num = 4'b0010;
            KEY_CODES[03] : key_num = 4'b0011;
            KEY_CODES[04] : key_num = 4'b0100;
            KEY_CODES[05] : key_num = 4'b0101;
            KEY_CODES[06] : key_num = 4'b0110;
            KEY_CODES[07] : key_num = 4'b0111;
            KEY_CODES[08] : key_num = 4'b1000;
            KEY_CODES[09] : key_num = 4'b1001;
            KEY_CODES[10] : key_num = 4'b0000;
            KEY_CODES[11] : key_num = 4'b0001;
            KEY_CODES[12] : key_num = 4'b0010;
            KEY_CODES[13] : key_num = 4'b0011;
            KEY_CODES[14] : key_num = 4'b0100;
            KEY_CODES[15] : key_num = 4'b0101;
            KEY_CODES[16] : key_num = 4'b0110;
            KEY_CODES[17] : key_num = 4'b0111;
            KEY_CODES[18] : key_num = 4'b1000;
            KEY_CODES[19] : key_num = 4'b1001;
            default		  : key_num = 4'b1111;
        endcase
    end	
endmodule