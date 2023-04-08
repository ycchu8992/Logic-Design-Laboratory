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

    HitHandler Hit_Handler(
        .state(wstate),
        .hit(whit),
        .LED(wLED),
        .nums(wnums),
        .sCnt(wsCnt),
        .nhit(wnhit)
    );

    LEDHandler LED_Handler(
        .state(wstate),
        .hit(whit),
        .LED(wLED),
        .nums(wnums),
        .LFSR1(wLFSR1),
        .LFSR2(wLFSR2),
        .LFSR3(wLFSR3),
        .LFSR4(wLFSR4),
        .LFSR5(wLFSR5),
        .LFSR6(wLFSR6),
        .LFSR7(wLFSR7),
        .LFSR8(wLFSR8),
        .LFSR9(wLFSR9),
        .next_led(wnext_led)
    );

    RandomHandler Random_Handler(
        .sec(sec_clk),
        .RST(RST),
        .btnu(btnu),
        .state(wstate),
        .Point(wPoint),
        .LFSR1(wLFSR1),
        .LFSR2(wLFSR2),
        .LFSR3(wLFSR3),
        .LFSR4(wLFSR4),
        .LFSR5(wLFSR5),
        .LFSR6(wLFSR6),
        .LFSR7(wLFSR7),
        .LFSR8(wLFSR8),
        .LFSR9(wLFSR9)
    );

    CounDown CountDown30(
        .sec(sec_clk),
        .RST(RST),
        .btnu(btnu),
        .state(wstate),
        .Point(wPoint),
        .counter(wcounter)
    );

    debounce btnu_db(
        .clk(clk),
        .pb(start),
        .pb_debounced(db_u)
    );

    OnePulse btnu_op(
        .signal_single_pulse(btnu),
        .signal(db_u),
        .clock(clk)
    );

    debounce RST_db(
        .clk(clk),
        .pb(rst),
        .pb_debounced(db_rst)
    );

    OnePulse RST_op(
        .signal_single_pulse(RST),
        .signal(db_rst),
        .clock(clk)
    );

    MyClockDivider #(.n(10**8)) SecClk(
        .clk(clk),
        .clk_div(sec_clk)
    );

    MyClockDivider #(.n(2**14)) DisPlay(
        .clk(clk),
        .clk_div(seg)
    );

    KeyboardDecoder key_de (
        .key_down(wkey_down),
        .last_change(last_change),
        .key_valid(wbeen_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(RST),
        .clk(clk)
    );
    wire F_LED;
    assign wLED = LED;

    HandlePoints Points_Handler(
        .state(wstate),
        .btnu(btnu),
        .LED(wLED),
        .Point(wPoint),
        .hit(whit),
        .nums(wnums),
        .nPoint(wnPoint)
    );

    HandleDigit0 Digit0_Handler(
        .state(wstate),
        .btnu(btnu),
        .counter(wcounter),
        .Point(wPoint),
        .val0(wval0),
        .nvl0(wnvl0)
    );

    SequentialHandler SqHandler(
        .clk(clk),
        .RST(RST),
        .nstate(wnstate),
        .nPoint(wnPoint),
        .nvl3(wnvl3),
        .nvl2(wnvl2),
        .nvl1(wnvl1),
        .nvl0(wnvl0),
        .nhit(wnhit),
        .next_led(wnext_led),
        .state(wstate),
        .Point(wPoint),
        .val3(wval3),
        .val2(wval2),
        .val1(wval1),
        .val0(wval0),
        .hit(whit),
        .sCnt(wsCnt),
        .LED(F_LED)
    );

    always@(*) LED = F_LED;

    HandleDigit1 Digit1_Handler(
        .state(wstate),
        .btnu(btnu),
        .counter(wcounter),
        .Point(wPoint),
        .val1(wval1),
        .nvl1(wnvl1)
    );

    HandleDigit2 Digit2_Handler(
        .state(wstate),
        .btnu(btnu),
        .counter(wcounter),
        .Point(wPoint),
        .val2(wval2),
        .nvl2(wnvl2)
    );

    HandleDigit3 Digit3_Handler(
        .state(wstate),
        .btnu(btnu),
        .counter(wcounter),
        .Point(wPoint),
        .val3(wval3),
        .nvl3(wnvl3)
    );

    HandleState State_Handler(
        .state(wstate),
        .btnu(btnu),
        .counter(wcounter),
        .Point(wPoint),
        .nstate(wnstate)
    );


    KeyBoardHandler KB_Handler(
        .clk(clk),
        .RST(RST),
        .key_down(wkey_down),
        .last_change(last_change),
        .been_ready(wbeen_ready),
        .nums(wnums)
    );


    always@(*) DIGIT = F_DIGIT;
    always@(*) DISPLAY = F_DISPLAY;

    SegmentDisplay Segment_Handler(
        .Dclk(seg),
        .val3(wval3),
        .val2(wval2),
        .val1(wval1),
        .val0(wval0),
        .DIGIT(F_DIGIT),
        .DISPLAY(F_DISPLAY)
    );

endmodule