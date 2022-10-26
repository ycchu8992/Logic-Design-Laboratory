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

    parameter IDLE = 3'b000;
    parameter SET = 3'b001;
    parameter GUESS = 3'b010;
    parameter WRONG = 3'b011;
    parameter CORRECT = 3'b100;


    wire db_r, db_u, db_d, db_l;
    reg btnr, btnu, btnd, btnl;
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


    reg [2:0] state, n_state;

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
                if(btnr) n_state = GUESS;
                else if(btnl) n_state = IDLE;
                else n_state = SET;                
            end
            GUESS:begin
                if(btnr) n_state = (1)?CORRECT:WRONG;//
                else if(btnl) n_state = IDLE;
                else n_state = GUESS;
            end
            WRONG:begin
                if(btnr) n_state = GUESS;
                else if(btnl) n_state = IDLE;
                else n_state = WRONG;
            end
            CORRECT:begin
                if(1) n_state = IDLE;//
                else n_state = CORRECT;
            end
            default:begin
                n_state = state;
            end
        endcase
    end

    always@(posedge clk)begin
        
    end

endmodule

