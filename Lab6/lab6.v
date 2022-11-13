module MyClockDivider #(parameter n=100)(
    input clk,
    output wire clk_div  
);
    reg CLK_Out;
    integer counter = 0;
    always @(posedge clk) begin
        counter <= counter + 1;
        if(counter >= n-1) counter <= 0;
    end
    always @(posedge clk) begin
        CLK_Out <= (((n-1) >> 1) >= counter)?1'b0:1'b1;
    end
    assign clk_div = CLK_Out;
endmodule
module lab6 (
    input wire clk,
    input wire rst,
    input wire start,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    output reg [15:0] LED,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY
);

reg [1:0] state, nstate;
reg [3:0] value;
parameter FINAL = 2'b10;
parameter GAME = 2'b01;
parameter INITIAL = 2'b00;
reg sec, Dclk;
reg [4:0] counter, ncounter, Point, nPoint;
reg [3:0] val3, val2, val1, val0;
reg [3:0] nvl3, nvl2, nvl1, nvl0;
reg [15:0] next_led;
reg [15:0] LFSR [8:0];
parameter [8:0] LEFT_SHIFT_CODES  = 9'b0_0001_0010;
parameter [8:0] RIGHT_SHIFT_CODES = 9'b0_0101_1001;

parameter [15:0] seeds [8:0] = {
    16'b0001_0100_0101_1000,
    16'b1010_1010_0001_0110,
    16'b0011_1001_1010_1101,
    16'b0101_0010_0010_1010,
    16'b0101_0001_0101_0101,
    16'b0101_0101_0101_0100,
    16'b1010_0101_0101_0010,
    16'b1000_1011_1010_1010,
    16'b1001_0100_0101_0010
};

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

reg [3:0] nums;
reg [3:0] key_num;
reg [9:0] last_key;
	
wire [511:0] key_down;
wire [8:0] last_change;
wire been_ready;

debounce btnu_db(.clk(clk), .pb(start), .pb_debounced(db_u));
OnePulse btnu_op(.signal_single_pulse(btnu), .signal(db_u), .clock(clk));

/*----------------------------------------------
Real clock on FPGA and convert their type to reg 
-----------------------------------------------*/
MyClockDivider #(.n(10**8)) SecClk(.clk(clk),.clk_div(sec_clk));
MyClockDivider #(.n(2**14)) DisPlay(.clk(clk),.clk_div(seg));
always @(*) begin sec = sec_clk; end
always @(*) begin Dclk = seg; end


always @(posedge clk) begin
    if(rst) LED <= 16'b0;
    else LED <= next_led;
end

integer i;
always @(posedge sec) begin
    if(rst) begin
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

integer j;
always @(*) begin
    case (state)
        GAME:begin
            for (j=0; j < 16; j=j+1) begin
                if(j<7) next_led[j] = 0;
                else next_led[j] = LFSR[15-j][15];
            end
        end
        default:begin
            next_led = 16'b0;
        end
    endcase   
end

/*----------------------------------
Counter for that update every seconds
-----------------------------------*/
always @(posedge sec) begin
    if(rst) counter <= 5'd30;
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
            else ncounter = counter - 1;
        end 
        default:begin
            if(btnu) ncounter = 5'd30;
            else ncounter = counter - 1;
        end
    endcase
end

/*----------------------------------
Handle Points
-----------------------------------*/
always @(posedge clk) begin
    if(rst) Point <= 5'd0;
    else Point <= nPoint;  
end
always @(*) begin
    case (state)
        INITIAL:begin
            if(btnu) nPoint = 0;
            else nPoint = 0;
        end
        GAME:begin
            nPoint = 0;
            if(LED[16-nums])begin
                nPoint = Point+1;
            end else begin
                nPoint = Point;
            end 
        end
        FINAL:begin
           if(btnu) nPoint = 5'd0;
            else nPoint = Point;
        end 
        default:begin
            if(btnu) nPoint = 5'd0;
            else nPoint = 5'd0;
        end
    endcase
end

/*----------------------------------
Handle digit 0 
-----------------------------------*/
always @(posedge clk) begin
    if(rst) val0 <= 4'd13;
    else val0 <= nvl0;
end
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

/*----------------------------------
Handle digit 1 
-----------------------------------*/
always @(posedge clk) begin
    if(rst) val1 <= 4'd13;
    else val1 <= nvl1;
end
always @(*) begin
    case (state)
        INITIAL:begin
            if(btnu) nvl1 = 4'd0;
            else nvl1 = 4'd13;
        end
        GAME:begin
            if( counter > 0 && Point < 10) begin
                if(Point < 10)begin
                    nvl1 = 0;
                end else if( Point > 9 && Point < 20 )begin
                    nvl1 = 1;
                end else if( Point > 19 && Point < 30 )begin
                    nvl1 = 2;
                end else begin
                    nvl1 = 3;
                end
            end else begin
                if(Point > 9) nvl1 = 4'd11;
                else nvl1 = val1;
            end
        end
        FINAL:begin
            if(btnu) nvl1 = 4'd0;
            else nvl1 = val1;
        end 
        default:begin
            if(btnu) nvl1 = 4'd0;
            else nvl1 = val1;
        end
    endcase
end

/*----------------------------------
Handle digit 2 
-----------------------------------*/
always @(posedge clk) begin
    if(rst) val2 <= 4'd13;
    else val2 <= nvl2;
end
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

/*----------------------------------
Handle digit 3 
-----------------------------------*/
always @(posedge clk) begin
    if(rst) val3 <= 4'd13;
    else val3 <= nvl3;
end
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

/*---------------------------
Control the state
---------------------------*/
always @(posedge clk) begin
    if(rst) state <= INITIAL;
    else state <= nstate;
end
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

/*---------------------------
KeyBoard Controller
---------------------------*/
KeyboardDecoder key_de (
	.key_down(key_down),
	.last_change(last_change),
	.key_valid(been_ready),
	.PS2_DATA(PS2_DATA),
	.PS2_CLK(PS2_CLK),
	.rst(rst),
	.clk(clk)
);
always @ (posedge clk, posedge rst) begin
	if (rst) begin
		nums <= 4'b0;
	end else begin
		if (been_ready && key_down[last_change] == 1'b1) begin
			if (key_num != 4'b1111)begin
				nums <= key_num;
            end else nums <= 4'b0;
		end else nums <= 4'b0;
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

