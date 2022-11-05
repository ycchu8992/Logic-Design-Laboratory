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
module lab4_1 ( 
    input wire clk,
    input wire rst,
    input wire start,
    input wire direction,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY,
    output reg max,
    output reg min
); 
    
    wire start_t;
    wire startBtn;

    wire direction_t;
    wire directionBtn;

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


    reg clkTecUse;
    wire tec_use;
    Delay clkd(.clk(clk),.clkToDelay(clkCNT),.clk_out(tec_use));
    always @(*) begin
        clkTecUse = tec_use;
    end

    reg[1:0] state, next_state;

    parameter init = 2'b00;
    parameter count = 2'b01;
    parameter stop = 2'b10;

    // dir = 1'd0 means up while 1'd1 means down
    reg dir = 1'd0; 
    reg next_dir;

    reg [3:0] cnt[3:0], next_cnt[3:0];
    reg [3:0] cnt_save[3:0], next_cnt_save[3:0];
    reg [3:0] state_save,next_state_save;

    reg cnt1 = 1,n_cnt1;
    reg spec_cnt = 1;

    reg [3:0] value;

    reg next_min;
    reg next_max;

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
        next_cnt[0] = cnt[0];//0;
        next_cnt[1] = cnt[1];//5;
        next_cnt[2] = cnt[2];//0;
        next_cnt[3] = cnt[3];//10;
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
                    next_cnt[0] = cnt[0];
                    next_cnt[1] = cnt[1];
                    next_cnt[2] = cnt[2];
                    if(direction_t)begin
                        if(dir == 1'd0) next_cnt[3] = 10;
                        else next_cnt[3] = 11;
                    end else begin
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
            state <= init;
        end
        else begin
            state <= state_save;//next_state;
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
            for(j = 0;j <= 3 ;j = j + 1 )begin
                next_cnt_save[j] = next_cnt[j];
            end
        end
        else begin
            next_state_save = state_save;
            for(j = 0;j <= 3 ;j = j + 1 )begin
                next_cnt_save[j] = cnt_save[j];
            end
        end
    end

    always @(posedge clk or negedge spec_cnt or posedge clkTecUse) begin
        if(!spec_cnt && !clkTecUse) begin
            cnt1 <= 1;
        end
        else begin
            cnt1 <= n_cnt1;
        end
    end

    always @(*) begin
        spec_cnt = ~clk_cnt;
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
