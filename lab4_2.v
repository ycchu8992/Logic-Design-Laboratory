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
module lab4_2 ( 
    input wire clk,
    input wire rst,
    input wire start,
    input wire direction,
    input wire increase,
    input wire decrease,
    input wire select,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY,
    output reg max,
    output reg min,
    output reg d2,
    output reg d1,
    output reg d0
 ); 
     
    wire start_t;
    wire startBtn;

    wire direction_t;
    wire directionBtn;

    wire select_t;
    wire selectBtn;

    wire increase_t;
    wire increaseBtn;

    wire decrease_t;
    wire decreaseBtn;

    reg clk_cnt;
    wire clkCNT;
    reg clk_display;
    wire clk_show;

    MyClockDivider #(.n(10**7)) clk_CNT(
        .clk(clk),
        .clk_div(clkCNT)
    );

    MyClockDivider #(.n(2**3)) clkTemp(
        .clk(clk),
        .clk_div(clk_db)
    );

    MyClockDivider #(.n(2**14)) display(
        .clk(clk),
        .clk_div(clk_show)
    );

    debounce start_btn(.clk(clk_db), .pb(start), .pb_debounced(start_t));
    one_pulse start_pulse(.clk(clk), .pb_in(start_t), .pb_out(startBtn));
    
    debounce direction_btn(.clk(clk_db), .pb(direction), .pb_debounced(direction_t));
    one_pulse direction_pulse(.clk(clk), .pb_in(direction_t), .pb_out(directionBtn));

    debounce select_btn(.clk(clk_db), .pb(select), .pb_debounced(select_t));
    one_pulse select_pulse(.clk(clk), .pb_in(select_t), .pb_out(selectBtn));

    debounce increase_btn(.clk(clk_db), .pb(increase), .pb_debounced(increase_t));
    one_pulse increase_pulse(.clk(clk), .pb_in(increase_t), .pb_out(increaseBtn));

    debounce decrease_btn(.clk(clk_db), .pb(decrease), .pb_debounced(decrease_t));
    one_pulse decrease_pulse(.clk(clk), .pb_in(decrease_t), .pb_out(decreaseBtn));

    reg clkTecUse;
    wire tec_use;
    Delay clkd(.clk(clk),.clkToDelay(clkCNT),.clk_out(tec_use));
    always @(*) begin
        clkTecUse = tec_use;
    end

    parameter init = 2'b00;
    parameter count = 2'b01;
    parameter stop = 2'b10;

    // dir = 1'd0 means up while 1'd1 means down
    reg dir = 1'd0; 
    reg next_dir;

    reg [3:0] cnt[3:0], next_cnt[3:0];
    reg [3:0] cnt_save[3:0], next_cnt_save[3:0];

    reg[1:0] state, next_state;
    reg [3:0] state_save,next_state_save;

    reg cnt1 = 1,n_cnt1;
    reg cnt2 = 1,n_cnt2;
    reg spec_cnt = 1;
    reg spec_cnt2 = 1;

    reg [3:0] value;

    reg next_min;
    reg next_max;

    reg n_d2, n_d1, n_d0;
    reg d0_save, n_d0_save, d1_save, n_d1_save, d2_save, n_d2_save;

    integer i;
    integer j;

    always @(*) begin
        clk_cnt = clkCNT;
    end

    always @(*) begin
        clk_display = clk_show;
    end
    
    always@(posedge clk)begin
        if(rst) begin
            dir <= 1'd0;
        end
        else begin
            dir <= next_dir;
        end
    end

    always @(*) begin
        next_dir = dir;
        case(state)
            init:begin
                if(startBtn) next_dir = 1'd0;
                else next_dir = dir;
            end
            count:begin
                if(directionBtn) next_dir = ~dir;
                else next_dir = dir;              
            end
            default:next_dir = dir;
        endcase
    end

    always @(posedge clk_cnt or negedge rst) begin
        if(rst) begin
            for( i = 0 ; i <= 3 ; i = i + 1 )begin
                cnt[i] <= 12;
            end
        end
        else begin
            for( i = 0 ; i <= 3 ; i = i + 1 )begin
                cnt[i] <= cnt_save[i];
            end
        end
    end

    always @(*) begin
        next_cnt[0] = cnt[0];
        next_cnt[1] = cnt[1];
        next_cnt[2] = cnt[2];
        next_cnt[3] = cnt[3];
        case(state)
            init:begin
                if(startBtn)begin
                    next_cnt[0] = 0;
                    next_cnt[1] = 5;
                    next_cnt[2] = 0;
                    next_cnt[3] = 12;
                end else begin
                    next_cnt[0] = 12;
                    next_cnt[1] = 12;
                    next_cnt[2] = 12;
                    next_cnt[3] = 12;
                end
            end
            count:begin
                if(!startBtn)begin
                    if(dir== 1'd0)begin
                        next_cnt[3] = 10;
                        if(cnt[0] + 1 <= 9)begin
                            next_cnt[0] = cnt[0] + 1;
                            next_cnt[1] = cnt[1];
                            next_cnt[2] = cnt[2];
                        end
                        else if(cnt[1] + 1 <= 9)begin
                            next_cnt[0] = 0;
                            next_cnt[1] = cnt[1] + 1;
                            next_cnt[2] = cnt[2];
                        end
                        else if(cnt[2] + 1 <= 9)begin
                            next_cnt[0] = 0;
                            next_cnt[1] = 0;
                            next_cnt[2] = cnt[2] + 1;
                        end
                        else begin
                            next_cnt[0] = cnt[0];
                            next_cnt[1] = cnt[1];
                            next_cnt[2] = cnt[2];
                        end
                    end
                    else begin
                        next_cnt[3] = 11;
                        if(cnt[0] >= 1)begin
                            next_cnt[0] = cnt[0] - 1;
                            next_cnt[1] = cnt[1];
                            next_cnt[2] = cnt[2];
                        end
                        else if(cnt[1] >= 1)begin
                            next_cnt[0] = 9;
                            next_cnt[1] = cnt[1] - 1;
                            next_cnt[2] = cnt[2];
                        end
                        else if(cnt[2] >= 1)begin
                            next_cnt[0] = 9;
                            next_cnt[1] = 9;
                            next_cnt[2] = cnt[2] - 1;
                        end
                        else begin
                            next_cnt[0] = cnt[0];
                            next_cnt[1] = cnt[1];
                            next_cnt[2] = cnt[2];
                        end
                    end
                end else begin
                    next_cnt[0] = cnt[0];
                    next_cnt[1] = cnt[1];
                    next_cnt[2] = cnt[2];
                    next_cnt[3] = 12;
                end                 
            end
            stop:begin
                if(startBtn)begin
                    if(dir == 1'd0)begin
                        next_cnt[3] = 10;
                        if(cnt[0] + 1 <= 9)begin
                            next_cnt[0] = cnt[0] + 1;
                            next_cnt[1] = cnt[1];
                            next_cnt[2] = cnt[2];
                        end
                        else if(cnt[1] + 1 <= 9)begin
                            next_cnt[0] = 0;
                            next_cnt[1] = cnt[1] + 1;
                            next_cnt[2] = cnt[2];
                        end
                        else if(cnt[2] + 1 <= 9)begin
                            next_cnt[0] = 0;
                            next_cnt[1] = 0;
                            next_cnt[2] = cnt[2] + 1;
                        end
                        else begin
                            next_cnt[0] = cnt[0];
                            next_cnt[1] = cnt[1];
                            next_cnt[2] = cnt[2];
                        end
                    end
                    else begin
                        next_cnt[3] = 11;
                        if(cnt[0] >= 1)begin
                            next_cnt[0] = cnt[0] - 1;
                            next_cnt[1] = cnt[1];
                            next_cnt[2] = cnt[2];
                        end
                        else if(cnt[1] >= 1 )begin
                            next_cnt[0] = 9;
                            next_cnt[1] = cnt[1] - 1;
                            next_cnt[2] = cnt[2];
                        end
                        else if(cnt[2] >= 1 )begin
                            next_cnt[0] = 9;
                            next_cnt[1] = 9;
                            next_cnt[2] = cnt[2] - 1;
                        end
                        else begin
                            next_cnt[0] = cnt[0];
                            next_cnt[1] = cnt[1];
                            next_cnt[2] = cnt[2];
                        end
                    end
                end else begin
                    if(increaseBtn)begin
                        next_cnt[3] = cnt[3];
                        if(d2)begin
                            next_cnt[0] = cnt[0];
                            next_cnt[1] = cnt[1];                            
                            if(cnt[2] + 1 <= 9) next_cnt[2] = cnt[2] + 1;
                            else next_cnt[2] = 0;
                        end 
                        else if(d1)begin
                            next_cnt[0] = cnt[0];
                            next_cnt[2] = cnt[2];
                            if(cnt[1] + 1 <= 9) next_cnt[1] = cnt[1] + 1;
                            else next_cnt[1] = 0;
                        end else if(d0)begin
                            next_cnt[1] = cnt[1];
                            next_cnt[2] = cnt[2];
                            if(cnt[0] + 1 <= 9) next_cnt[0] = cnt[0] + 1;
                            else next_cnt[0] = 0;
                        end
                    end else if(decreaseBtn)begin
                        next_cnt[3] = cnt[3];
                        if(d2)begin
                            next_cnt[0] = cnt[0];
                            next_cnt[1] = cnt[1];
                            if(cnt[2] != 0) next_cnt[2] = cnt[2] - 1;
                            else next_cnt[2] = 9;
                        end 
                        else if(d1)begin
                            next_cnt[0] = cnt[0];
                            next_cnt[2] = cnt[2];
                            if(cnt[1] != 0) next_cnt[1] = cnt[1] - 1;
                            else next_cnt[1] = 9;
                        end
                        else if(d0)begin
                            next_cnt[1] = cnt[1];
                            next_cnt[2] = cnt[2];
                            if(cnt[0] != 0) next_cnt[0] = cnt[0] - 1;
                            else next_cnt[0] = 9;
                        end
                    end else if(direction_t)begin
                        next_cnt[0] = cnt[0];
                        next_cnt[1] = cnt[1];
                        next_cnt[2] = cnt[2];
                        if(dir == 1'd0) next_cnt[3] = 10;
                        else next_cnt[3] = 11;
                    end else begin
                        next_cnt[0] = cnt[0];
                        next_cnt[1] = cnt[1];
                        next_cnt[2] = cnt[2];
                        next_cnt[3] = 12;
                    end
                end
            end
        endcase
    end

    always @(posedge clk_display) begin
        case(DIGIT)
            4'b1110:begin
                value <= cnt[1];
                DIGIT <= 4'b1101;
            end
            4'b1101:begin
                value <= cnt[2];
                DIGIT <= 4'b1011;
            end
            4'b1011:begin
                value <= cnt[3];
                DIGIT <= 4'b0111;
            end
            4'b0111:begin
                value <= cnt[0];
                DIGIT <= 4'b1110;
            end
            default:begin
                value <= cnt[0];
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
            4'd10:DISPLAY = 7'b101_1100;
            4'd11:DISPLAY = 7'b110_0011;
            4'd12:DISPLAY = 7'b011_1111;
            default:DISPLAY = 7'b111_1111;
        endcase
    end

    always @(posedge clk) begin
        min <= next_min;
        max <= next_max;
    end
    always @(*) begin
        next_min = min;
        next_max = max;
        case(state)
            init:begin
                next_min = 0;
                next_max = 0;
            end 
            count:begin
                next_min = 0;
                next_max = 0;
                if(cnt[0] == 9 && cnt[1] == 9 && cnt[2] == 9 )  next_max = 1;
                else if( cnt[0] == 0 && cnt[1] == 0 && cnt[2] == 0 ) next_min = 1;
            end
            stop:begin
                next_min = min;
                next_max = max;
            end
        endcase
    end

    always @(posedge clk_cnt) begin
        if(rst)begin
            d2 <= 0;
            d1 <= 0;
            d0 <= 0;
        end
        else begin
            d2 <= d2_save;
            d1 <= d1_save;
            d0 <= d0_save;
        end
    end
    always @(posedge clk) begin
        d2_save <= n_d2_save;
        d1_save <= n_d1_save;
        d0_save <= n_d0_save;
    end
    always @(*) begin
        if(cnt2)begin
            n_d2_save = n_d2;
            n_d1_save = n_d1;
            n_d0_save = n_d0;
        end
        else begin
            n_d2_save = d2_save;
            n_d1_save = d1_save;
            n_d0_save = d0_save;
        end
    end
    always @(*) begin
        case(state)
            init:begin
                n_d2  = 0;
                n_d1  = 0;
                n_d0  = 0;
                if(startBtn)begin
                    n_d2  = 0;
                    n_d1  = 0;
                    n_d0  = 1;
                end
            end
            count:begin
                n_d2  = 0;
                n_d1  = 0;
                n_d0  = 0;
                if(startBtn)begin
                    n_d2  = 0;
                    n_d1  = 0;
                    n_d0  = 1;
                end
            end
            stop:begin
                if(selectBtn)begin
                    if(d0 == 1)begin
                        n_d2  = 0;
                        n_d1  = 1;
                        n_d0  = 0;
                    end else if(d1 == 1)begin
                        n_d2  = 1;
                        n_d1  = 0;
                        n_d0  = 0;
                    end else if(d2 == 1)begin
                        n_d2  = 0;
                        n_d1  = 0;
                        n_d0  = 1;
                    end else begin
                        n_d2  = 0;
                        n_d1  = 0;
                        n_d0  = 1;
                    end
                end else begin
                    n_d2  = d2;
                    n_d1  = d1;
                    n_d0  = d0;
                end
            end
            default:begin
                n_d2  = 0;
                n_d1  = 0;
                n_d0  = 0;
            end
        endcase  
    end

    always @(posedge clk_cnt) begin
        if(rst)begin
            state <= init;
        end
        else begin
            state <= state_save;
        end
    end

    always @(posedge clk) begin
        state_save <= next_state_save;
        for(j = 0;j <= 3 ;j = j + 1 )begin
            cnt_save[j] <= next_cnt_save[j];
        end 
    end

    always @(*) begin
        if(cnt1)begin
            next_state_save = next_state;
        end
        else begin
            next_state_save = state_save;
        end
    end

    always @(*) begin
        if(cnt1&&cnt2)begin
            for(j = 0;j <= 3 ;j = j + 1 )begin
                next_cnt_save[j] = next_cnt[j];
            end
        end
        else begin
            for(j = 0;j <= 3 ;j = j + 1 )begin
                next_cnt_save[j] = cnt_save[j];
            end
        end
    end

    always @(*) begin
        next_state = init;
        case(state)
            init:begin
                next_state = next_state;
                if(startBtn) next_state = stop;
                else next_state = init;
            end
            count:begin
                if(startBtn) next_state = stop;
                else next_state = count;
            end
            stop:begin
                if(startBtn) next_state = count;
                else next_state = stop;
            end
        endcase
    end


    always @(posedge clk or negedge spec_cnt or posedge clkTecUse) begin
        if(!spec_cnt && !clkTecUse) cnt1 <= 1;
        else cnt1 <= n_cnt1;
    end

    always @(posedge clk or negedge spec_cnt2 or posedge clkTecUse) begin
        if(!spec_cnt2 && !clkTecUse) cnt2 <= 1;
        else cnt2 <= n_cnt2;
    end

    always @(*) begin
        spec_cnt = ~clk_cnt;
        spec_cnt2 = ~clk_cnt;
    end

    always @(*) begin
        n_cnt1 = cnt1;
        case(state)
            init:begin
                if(startBtn && cnt1) begin
                    n_cnt1=0;
                end
            end
            count:begin
                if(startBtn && cnt1) begin
                    n_cnt1=0;
                end
            end
            stop:begin
                if(startBtn && cnt1) begin
                    n_cnt1=0;
                end
            end
        endcase
    end

    always @(*) begin
        n_cnt2 = cnt2;
        case(state)
            init:begin
                if( ( startBtn || selectBtn || increaseBtn || decreaseBtn )  && cnt2) begin
                    n_cnt2=0;
                end
            end
            count:begin
                if( ( startBtn || selectBtn || increaseBtn || decreaseBtn )  && cnt2) begin
                    n_cnt2=0;
                end
            end
            stop:begin
                if( (  startBtn || selectBtn || increaseBtn || decreaseBtn )  && cnt2) begin
                    n_cnt2=0;
                end
            end
        endcase
    end

endmodule

module Delay(
    input wire clk,
    input wire clkToDelay,
    output reg clk_out
);

    reg clk_temp;
    reg clk_to_delay;

    always@(posedge clk)begin
        clk_temp <= clk_to_delay;
    end

    always @(*) begin
        if(clk_to_delay && !clk_temp) clk_out = ~clk;
        else clk_out = clk_to_delay;
    end

    always @(*) begin
        clk_to_delay = clkToDelay;
    end
endmodule