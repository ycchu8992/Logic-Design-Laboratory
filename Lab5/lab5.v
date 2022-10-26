module DEBOUNCE(
	input wire clk,
    input wire BTNR,
    input wire BTNU,
    input wire BTND,
    input wire BTNL,
	output wire pb_db_r,
    output wire pb_db_u,
    output wire pb_db_d,
    output wire pb_db_l
);

	debounce btnr_db(.clk(clk), .pb(BTNR), .pb_debounced(pb_db_r));
    debounce btnu_db(.clk(clk), .pb(BTNU), .pb_debounced(pb_db_u));
    debounce btnd_db(.clk(clk), .pb(BTND), .pb_debounced(pb_db_d));
    debounce btnl_db(.clk(clk), .pb(BTNL), .pb_debounced(pb_db_l));
endmodule

module ONEPULSE(
	input wire clk,
    input wire pb_in_r,
    input wire pb_in_u,
    input wire pb_in_d,
    input wire pb_in_l,
	output reg pb_out_r,
    output reg pb_out_u,
    output reg pb_out_d,
    output reg pb_out_l
);
	one_pulse btnr_op(.clk(clk), .pb_in(pb_in_r), .pb_out(pb_out_r));    
    one_pulse btnu_op(.clk(clk), .pb_in(pb_in_u), .pb_out(pb_out_u));
    one_pulse btnd_op(.clk(clk), .pb_in(pb_in_d), .pb_out(pb_out_d)); 
    one_pulse btnl_op(.clk(clk), .pb_in(pb_in_l), .pb_out(pb_out_l));
endmodule


module lab5(
    input wire clk,
    input wire rst,
    input wire BTNR,
    input wire BTNU,
    input wire BTND,
    input wire BTNL,
    output reg [15:0] LED,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY
);

    reg [2:0] state, n_state;
    reg [15:0] n_led;
    reg [3:0] value;


    parameter IDLE = 3'b000;
    parameter SET = 3'b001;
    parameter GUESS = 3'b010;
    parameter WRONG = 3'b011;
    parameter CORRECT = 3'b100;


    wire db_r, db_u, db_d, db_l;
    reg btnr, btnu, btnd, btnl;
    reg sec;

    reg [3:0] cnt, n_cnt;
    reg [3:0] cnt2, n_cnt2;
    reg clk_display;


    reg [3:0] val_0,val_1,val_2,val_3;
    reg [3:0] nvl_0,nvl_1,nvl_2,nvl_3;
    reg [3:0] sv0, sv1, sv2, sv3;
    reg [3:0] nsv_0, nsv_1, nsv_2, nsv_3;

    clock_divider #(.n(2**27)) CLK(.clk(clk), .clk_div(sec));

    clock_divider #(.n(2**14)) display(.clk(clk),.clk_div(clk_show));
    always @(*) begin
        clk_display = clk_show;
    end

    DEBOUNCE DB(
        .clk(clk),
        .BTNR(BTNR),
        .BTNU(BTNU),
        .BTND(BTND),
        .BTNL(BTNL),
        .pb_db_r(db_r),
        .pb_db_u(db_u),
        .pb_db_d(db_d),
        .pb_db_l(db_l)
    );
    ONEPULSE OP(
        .clk(clk),
        .pb_in_r(db_r),
        .pb_in_u(db_u),
        .pb_in_d(db_d),
        .pb_in_l(db_l),
        .pb_out_r(btnr),
        .pb_out_u(btnu),
        .pb_out_d(btnd),
        .pb_out_l(btnl)
    );

    //state
    always @(posedge clk) begin
        if(rst) state <= IDLE;
        else state <= n_state;
    end
    always@(*)begin
        case(state)
            IDLE:begin
                if(btnr) n_state = SET;
                else n_state = IDLE;
            end
            SET:begin
                if( btnr && cnt > 4 ) n_state = GUESS;
                else if(btnl) n_state = IDLE;
                else n_state = SET;                
            end
            GUESS:begin
                if(btnr && cnt > 4 ) n_state = ( (val_0 == sv0) && (val_1 == sv1) && (val_2 == sv2) && (val_3 == sv3) )?CORRECT:WRONG;
                else if(btnl) n_state = IDLE;
                else n_state = GUESS;
            end
            WRONG:begin
                if(btnr) n_state = GUESS;
                else if(btnl) n_state = IDLE;
                else n_state = WRONG;
            end
            CORRECT:begin
                if(cnt2 > 4) n_state = IDLE;
                else n_state = CORRECT;
            end
            default:begin
                n_state = state;
            end
        endcase
    end

    //val_3
    always@(posedge clk)begin
        if(rst) val_3 <= 4'd12;
        else val_3 <= nvl_3;
    end
    always@(*)begin
        case(state)
            IDLE:begin
                if(btnr) nvl_3 = 4'd0;
                else nvl_3 = 4'd12;
            end
            SET:begin
                if(LED[11])begin
                    if(btnu && val_3 < 4'd9) nvl_3 = val_3 + 1;
                    else if(btnd && val_3 > 4'd0) nvl_3 = val_3 - 1;
                    else nvl_3 = val_3;
                end else if( btnr && cnt > 4 ) nvl_3 = 0;
                else nvl_3 = val_3;
            end
            GUESS:begin
                if(LED[7])begin
                    if(btnu && val_3 < 4'd9) nvl_3 = val_3 + 1;
                    else if(btnd && val_3 > 4'd0) nvl_3 = val_3 - 1;
                    else nvl_3 = val_3;
                end else if( btnr && cnt > 4 )begin
                    nvl_3 = (val_0 == sv0) + (val_1 == sv1) + (val_2 == sv2) + (val_3 == sv3);
                end
                else nvl_3 = val_3;
            end
            WRONG:begin
                if(btnr) nvl_3 = 4'd0;
                else nvl_3 = 4'd12;
            end
            CORRECT:begin
                if(cnt2 > 4) nvl_3 = 4'd12;
                else nvl_3 = val_3;
            end
        endcase
    end

    //val_2
    always@(posedge clk)begin
        if(rst) val_2 <= 4'd12;
        else val_2 <= nvl_2;
    end
    always@(*)begin
        case(state)
            IDLE:begin
                if(btnr) nvl_2 = 4'd0;
                else nvl_2 = 4'd12;
            end
            SET:begin
                if(LED[10])begin
                    if(btnu && val_2 < 4'd9) nvl_2 = val_2 + 1;
                    else if(btnd && val_2 > 4'd0) nvl_2 = val_2 - 1;
                    else nvl_2 = val_2;
                end else if( btnr && cnt > 4 ) nvl_2 = 0;
                else nvl_2 = val_2;
            end
            GUESS:begin
                if(LED[6])begin
                    if(btnu && val_2 < 4'd9) nvl_2 = val_2 + 1;
                    else if(btnd && val_2 > 4'd0) nvl_2 = val_2 - 1;
                    else nvl_2 = val_2;
                end else if( btnr && cnt > 4 )begin
                    nvl_2 = 4'd10;
                end
                else nvl_2 = val_2;
            end
            WRONG:begin
                if(btnr) nvl_2 = 4'd0;
                else if(btnl) nvl_2 = 4'd12;
                else nvl_2 = val_2;
            end
            CORRECT:begin
                if(cnt2 > 4) nvl_2 = 4'd12;
                else nvl_2 = val_2;
            end
            
        endcase
    end

    //val_1
    always@(posedge clk)begin
        if(rst) val_1 <= 4'd12;
        else val_1 <= nvl_1;
    end
    always@(*)begin
        case(state)
            IDLE:begin
                if(btnr) nvl_1 = 4'd0;
                else nvl_1 = 4'd12;
            end
            SET:begin
                if(LED[9])begin
                    if(btnu && val_1 < 4'd9) nvl_1 = val_1 + 1;
                    else if(btnd && val_1 > 4'd0) nvl_1 = val_1 - 1;
                    else nvl_1 = val_1;
                end else if( btnr && cnt > 4 ) nvl_1 = 0;
                else nvl_1 = val_1;
            end
            GUESS:begin
                if(LED[5])begin
                    if(btnu && val_1 < 4'd9) nvl_1 = val_1 + 1;
                    else if(btnd && val_1 > 4'd0) nvl_1 = val_1 - 1;
                    else nvl_1 = val_1;
                end else if( btnr && cnt > 4 )begin
                    nvl_1 = (val_0 == sv1 || val_0 == sv2 || val_0 == sv3) + (val_1 == sv0 || val_1 == sv2 || val_1 == sv3) + (val_2 == sv0 || val_2 == sv1 || val_2 == sv3) + (val_3 == sv0 || val_3 == sv1 || val_3 == sv2);
                end
                else nvl_1 = val_1;
            end
            WRONG:begin
                if(btnr) nvl_1 = 4'd0;
                else nvl_1 = 4'd12;
            end
            CORRECT:begin
                if(cnt2 > 4) nvl_1 = 4'd12;
                else nvl_1 = val_1;
            end
        endcase
    end
    
    //val_0
    always@(posedge clk)begin
        if(rst) val_0 <= 4'd12;
        else val_0 <= nvl_0;
    end
    always@(*)begin
        case(state)
            IDLE:begin
                if(btnr) nvl_0 = 4'd0;
                else nvl_0 = 4'd12;
            end
            SET:begin
                if( btnr && cnt > 4 ) nvl_0 = 0;
                else if(LED[8])begin
                    if(btnu && val_0 < 4'd9) nvl_0 = val_0 + 1;
                    else if(btnd && val_0 > 4'd0) nvl_0 = val_0 - 1;
                    else nvl_0 = val_0;
                end
                else nvl_0 = val_0;
            end
            GUESS:begin
                if( btnr && cnt > 4 ) nvl_0 = 4'b11;
                else if(LED[4])begin
                    if(btnu && val_0 < 4'd9) nvl_0 = val_0 + 1;
                    else if(btnd && val_0 > 4'd0) nvl_0 = val_0 - 1;
                    else nvl_0 = val_0;
                end
                else nvl_0 = val_0;
            end
            WRONG:begin
                if(btnr) nvl_0 = 4'd0;
                else nvl_0 = 4'd12;
            end
            CORRECT:begin
                if(cnt2 > 4) nvl_0 = 4'd12;
                else nvl_0 = val_0;
            end 
        endcase
    end

    //save the answer
    always@(posedge clk)begin
        if(rst)begin
            sv0 <= 0;
            sv1 <= 0;
            sv2 <= 0;
            sv3 <= 0;
        end else begin
            sv0 <= nsv_0;
            sv1 <= nsv_1;
            sv2 <= nsv_2;
            sv3 <= nsv_3;
        end
    end
    always@(*)begin
        case(state)
            SET:begin
                if( btnr && cnt > 4 ) begin
                    nsv_0 = val_0;
                    nsv_1 = val_1;
                    nsv_2 = val_2;
                    nsv_3 = val_3;
                end
                else begin
                    nsv_0 = sv0;
                    nsv_1 = sv1;
                    nsv_2 = sv2;
                    nsv_3 = sv3;
                end
            end
            default: begin
                nsv_0 = sv0;
                nsv_1 = sv1;
                nsv_2 = sv2;
                nsv_3 = sv3;
            end
        endcase
    end

    //7-segment
    always @(posedge clk_display) begin
        case(DIGIT)
            4'b1110:begin
                value <= val_1;
                DIGIT <= 4'b1101;
            end
            4'b1101:begin
                value <= val_2;
                DIGIT <= 4'b1011;
            end
            4'b1011:begin
                value <= val_3;
                DIGIT <= 4'b0111;
            end
            4'b0111:begin
                value <= val_0;
                DIGIT <= 4'b1110;
            end
            default:begin
                value <= val_0;
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
            4'd10:DISPLAY = 7'b000_1000;//a
            4'd11:DISPLAY = 7'b000_0011;//b
            4'd12:DISPLAY = 7'b011_1111;//-
            default:DISPLAY = 7'b111_1111;
        endcase
    end


    //led
    always@(posedge clk)begin
        if(rst) LED <= {4'b1111, 12'b0};
        else LED <= n_led;
    end
    always @(*) begin
        case(state)
            IDLE:begin
                if(btnr) n_led= {4'b0,1'b1,11'b0};
                else n_led = {4'b1111, 12'b0};
            end
            SET:begin
                if( btnr && cnt < 5 ) n_led = LED >> 1;
                else if( btnr && cnt > 4 ) n_led = {8'b0, 1'b1, 7'b0};
                else if(btnl) n_led = {4'b1111, 12'b0};
                else n_led = LED;                 
            end
            GUESS:begin
                if( btnr && cnt < 5 ) n_led = LED >> 1;
                else if( btnr && cnt > 4 ) n_led = ( (val_0 == sv0) && (val_1 == sv1) && (val_2 == sv2) && (val_3 == sv3) )?{16'b0}:{12'b0,4'b1111};
                else if(btnl) n_led = {4'b1111, 12'b0};
                else n_led = LED;
            end
            WRONG:begin
                if(btnr) n_led = {8'b0, 1'b1, 7'b0};
                else if(btnl) n_led = {4'b1111, 12'b0};
                else n_led = LED;
            end
            CORRECT:begin
                if(cnt2 > 4) n_led = {4'b1111, 12'b0};
                else n_led = ~LED;
            end
            default:begin
                n_led = LED;
            end
        endcase        
    end


    //counter for btn
    always @(posedge clk) begin
        if(rst) cnt <= 0;
        else cnt <= n_cnt; 
    end
    always@(*)begin
        case(state)
            SET:begin
                if(btnr && cnt < 5) n_cnt = cnt + 1;
                else if(btnr && cnt > 4) n_cnt = 0;
                else if(btnl) n_cnt = 0;
                else n_cnt = cnt;
            end
            GUESS:begin
                if(btnr && cnt < 5) n_cnt = cnt + 1;
                else if(btnr && cnt > 4) n_cnt = 0;
                else if(btnl) n_cnt = 0;
                else n_cnt = cnt;
            end
            default:n_cnt = 0;
        endcase
    end

    //counter for 1 sec
    always@(posedge sec)begin
        cnt2 <= n_cnt2;
    end
    always@(*)begin
        case(state)
            CORRECT:begin
                n_cnt2 = cnt2 + 1;
            end
            default:begin
                n_cnt2 = 0;
            end
        endcase
    end

endmodule

