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

    wire db_btnr;
    wire db_btnu;
    wire db_btnd;
    wire db_btnl;

    reg btnr;
    debounce btnr_db(.clk(clk), .pb(BTNR), .pb_debounced(db_btnr));
    one_pulse btnr_op(.clk(clk), .pb_in(db_btnr), .pb_out(btnr));

    
    reg btnu;
    debounce btnu_db(.clk(clk), .pb(BTNU), .pb_debounced(db_btnu));
    one_pulse btnu_op(.clk(clk), .pb_in(db_btnu), .pb_out(btnu));

    
    reg btnd;
    debounce btnd_db(.clk(clk), .pb(BTND), .pb_debounced(db_btnd));
    one_pulse btnd_op(.clk(clk), .pb_in(db_btnd), .pb_out(btnd));

    
    reg btnl;
    debounce btnl_db(.clk(clk), .pb(BTNL), .pb_debounced(db_btnl));
    one_pulse btnl_op(.clk(clk), .pb_in(db_btnl), .pb_out(btnl));


    reg [2:0] state;
    reg [2:0] n_state;

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
                if(btnr) n_state = (/*condition*/)?CORRECT:WRONG;
                else if(btnl) n_state = IDLE;
                else n_state = GUESS;
            end
            WRONG:begin
                if(btnr) n_state = GUESS;
                else if(btnl) n_state = IDLE;
                else n_state = WRONG;
            end
            CORRECT:begin
                if(counter >= 5) n_state = IDLE;
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
