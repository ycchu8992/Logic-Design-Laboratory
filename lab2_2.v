module Decoder (
    input clk,
    input rst,
    input [11:0] one_bit_err_in_data,
    input one_bit_err_in_valid,
    output reg [7:0] out_plaintext,
    output reg out_plaintext_valid
);

reg [11:0] next_out_plaintext;
reg next_out_plaintext_valid;

reg [2:0] state;
reg [2:0] next_state;

reg [6:0] counter;
reg [6:0] next_counter;

reg [7:0] len_counter;
reg [7:0] next_len_counter;

reg [7:0] one_bit_err_in_data_len, next_one_bit_err_in_data_len;


parameter [2:0] init = 3'b000;
parameter [2:0] get_data = 3'b001;
parameter [2:0] detect_err= 3'b010;
parameter [2:0] fix_err = 3'b011;
parameter [2:0] decrypt = 3'b100;
parameter [2:0] out_text= 3'b101;

parameter MAX_INPUT_LEN = 'd255;

integer i,j;

reg [3:0] parity[254:0],next_parity[254:0];

reg [11:0] data_save[254:0], next_data_save[254:0];

reg [7:0] plaintext_save[254:0], next_plaintext_save[254:0];

always@(posedge clk) begin
    if(rst) state <= init;
    else state <= next_state;
end

always@(posedge clk) begin
    if(rst) begin
        counter <= 7'b0;
        len_counter <= 8'b0;
    end
    else begin
        counter <= next_counter;
        len_counter <= next_len_counter;
    end
end

always @(*) begin
    case(state)
        init: begin
            if (one_bit_err_in_valid) begin
                next_counter = 1;
                next_len_counter = 1;
            end
            else begin
                next_counter = 0;
                next_len_counter = 0;
            end
        end
        get_data: begin
            if (one_bit_err_in_valid != 1 && one_bit_err_in_data_len != 0) begin
                next_counter = 0;
                next_len_counter = 0;
            end
            else begin
                next_counter = counter + 1;
                next_len_counter = len_counter + 1;
            end
        end
        detect_err: begin
            if (len_counter == one_bit_err_in_data_len) begin
                next_counter = 0;
                next_len_counter = 0;
            end
            else begin
                next_counter = counter + 1;
                next_len_counter = len_counter + 1;
            end
        end
        fix_err: begin
            if (len_counter == one_bit_err_in_data_len) begin
                next_counter = 0;
                next_len_counter = 0;
            end
            else begin
                next_counter = counter + 1;
                next_len_counter = len_counter + 1;
            end
        end
        decrypt: begin
            if (len_counter == one_bit_err_in_data_len) begin
                next_counter = 0;
                next_len_counter = 0;
            end
            else begin
                next_counter = counter + 1;
                next_len_counter = len_counter + 1;
            end
        end
        out_text: begin
            if (len_counter == one_bit_err_in_data_len) begin
                next_counter = 0;
                next_len_counter = 0;
            end
            else begin
                next_counter = counter + 1;
                next_len_counter = len_counter + 1;
            end
        end
        default : begin
            next_counter = 0;
            next_len_counter = 0;
        end
    endcase
end

always@(*)begin
    case(state)
        init:begin
            if (one_bit_err_in_valid != 0) next_state = get_data;
            else next_state = init;
        end
        get_data:begin
            if (one_bit_err_in_valid != 1 && one_bit_err_in_data_len != 0) next_state = detect_err;
            else next_state = get_data;
        end
        detect_err:begin
            if(len_counter == one_bit_err_in_data_len) next_state = fix_err;
            else next_state = detect_err;
        end
        fix_err:begin
            if(len_counter == one_bit_err_in_data_len) next_state = decrypt;
            else next_state = fix_err;
        end
        decrypt:begin
            if(len_counter == one_bit_err_in_data_len) next_state = out_text;
            else next_state = decrypt;
        end
        out_text:begin
            if(len_counter == one_bit_err_in_data_len) next_state = init;
            else next_state = out_text;
        end
        default:begin
            next_state = init;
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        one_bit_err_in_data_len <= 0;
    end
    else begin
        one_bit_err_in_data_len <= next_one_bit_err_in_data_len;
    end
end

always @(posedge clk) begin
    if (rst) begin
        for (i=0; i<MAX_INPUT_LEN; i=i+1) begin
            parity[i] <= 0;
        end
    end
    else begin
        for (i=0; i<MAX_INPUT_LEN; i=i+1) begin
            parity[i] <= next_parity[i];
        end
    end
end

always @(*) begin
    case(state)
        init : begin
            if (one_bit_err_in_valid == 1) begin
                next_one_bit_err_in_data_len = 1;
            end
            else begin
                next_one_bit_err_in_data_len = 0;
            end
        end
        get_data : begin
            if (one_bit_err_in_valid != 1 && one_bit_err_in_data_len != 0) begin
                next_one_bit_err_in_data_len = one_bit_err_in_data_len;
            end
            else begin
                next_one_bit_err_in_data_len = one_bit_err_in_data_len + 1;
            end
        end
        default : begin
            next_one_bit_err_in_data_len = one_bit_err_in_data_len;
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        for (i=0; i<MAX_INPUT_LEN; i=i+1) begin
            data_save[i] <= 0;
            plaintext_save[i] <= 0;
        end
    end
    else begin
        for (i=0; i<MAX_INPUT_LEN; i=i+1) begin
            data_save[i] <= next_data_save[i];
            plaintext_save[i] <= next_plaintext_save[i];
        end
    end
end


always @(*) begin
    for (i=0; i<MAX_INPUT_LEN; i=i+1) begin
        next_data_save[i] = data_save[i];
        next_plaintext_save[i] = plaintext_save[i];
        next_parity[i] = parity[i];
    end
    
    case(state)
        init: begin 
            if (one_bit_err_in_valid) begin
                next_data_save[0] = one_bit_err_in_data;
            end
        end
        get_data : begin
            if (one_bit_err_in_valid) begin
                next_data_save[len_counter] = one_bit_err_in_data;
            end
        end
        detect_err : begin
            if (len_counter != one_bit_err_in_data_len) begin
                next_parity[len_counter][0] = data_save[len_counter][10] ^ data_save[len_counter][8] ^ data_save[len_counter][6] ^ data_save[len_counter][4] ^ data_save[len_counter][2] ^ data_save[len_counter][0];
                next_parity[len_counter][1] = data_save[len_counter][10] ^ data_save[len_counter][9] ^ data_save[len_counter][6] ^ data_save[len_counter][5] ^ data_save[len_counter][2] ^ data_save[len_counter][1];
                next_parity[len_counter][2] = data_save[len_counter][11] ^ data_save[len_counter][6] ^ data_save[len_counter][5] ^ data_save[len_counter][4] ^ data_save[len_counter][3];
                next_parity[len_counter][3] = data_save[len_counter][11] ^ data_save[len_counter][10] ^ data_save[len_counter][9] ^ data_save[len_counter][8] ^ data_save[len_counter][7];
            end
        end
        fix_err : begin
            if (len_counter != one_bit_err_in_data_len && parity[len_counter] != 0) begin 
                if(data_save[len_counter][parity[len_counter]-1] == 0)begin
                    next_data_save[len_counter][parity[len_counter]-1] = 1;
                end
                else begin
                    next_data_save[len_counter][parity[len_counter]-1] = 0;
                end
            end
        end
        decrypt:begin
            if (len_counter != one_bit_err_in_data_len) begin
                next_plaintext_save[len_counter] = {data_save[len_counter][11:8],data_save[len_counter][6:4],data_save[len_counter][2]};
            end  
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        out_plaintext <= 0;
        out_plaintext_valid <= 0;
    end
    else begin
        out_plaintext <= next_out_plaintext;
        out_plaintext_valid <= next_out_plaintext_valid;
    end
end

always @(*) begin
    case(state)
        out_text : begin
            if (len_counter != one_bit_err_in_data_len) begin
                next_out_plaintext_valid = 1;
                next_out_plaintext = plaintext_save[len_counter] - counter;
            end
            else begin
                next_out_plaintext_valid = 0;
                next_out_plaintext = 0;
            end
        end
        default : begin
            next_out_plaintext = 0;
            next_out_plaintext_valid = 0;
        end
    endcase
end

endmodule