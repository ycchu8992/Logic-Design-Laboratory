module Encoder (
    input clk,
    input rst,
    input [7:0] in_data,
    input in_valid,
    output reg [11:0] out_data,
    output reg out_valid
);

reg [11:0] next_out_data;
reg next_out_valid;
reg [2:0] state;
reg [2:0] next_state;
reg [6:0] counter;
reg [6:0] next_counter;
reg [7:0] len_counter;
reg [7:0] next_len_counter;
reg [7:0] in_data_len, next_in_data_len;


parameter [2:0] init = 3'b000;
parameter [2:0] get_data = 3'b001;
parameter [2:0] encrypt= 3'b010;
parameter [2:0] protect = 3'b011;
parameter [2:0] gen_out= 3'b100;

parameter MAX_INPUT_LEN = 'd255;

integer i;
integer j;

// output_data_save
reg [7:0] output_data_save[254:0], next_output_data_save[254:0];

reg [11:0] err_pro_data_save[254:0], next_err_pro_data_save[254:0];

//state update
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
            if (in_valid) begin
                next_counter = 1;
                next_len_counter = 1;
            end
            else begin
                next_counter = 0;
                next_len_counter = 0;
            end
        end
        get_data: begin
            if (!in_valid && in_data_len != 0) begin
                next_counter = 0;
                next_len_counter = 0;
            end
            else begin
                next_counter = counter + 1;
                next_len_counter = len_counter + 1;
            end
        end
        encrypt: begin
            if (len_counter == in_data_len) begin
                next_counter = 0;
                next_len_counter = 0;
            end
            else begin
                next_counter = counter + 1;
                next_len_counter = len_counter + 1;
            end
        end
        protect: begin
            if (len_counter == in_data_len) begin
                next_counter = 0;
                next_len_counter = 0;
            end
            else begin
                next_counter = counter + 1;
                next_len_counter = len_counter + 1;
            end
        end
        gen_out: begin
            if (len_counter == in_data_len) begin
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

//state transition
always@(*)begin
    case(state)
        init:begin
            if (in_valid != 0) next_state = get_data;
            else next_state = init;
        end
        get_data:begin
            if (in_valid != 1 && in_data_len != 0) next_state = encrypt;
            else next_state = get_data;
        end
        encrypt:begin
            if(len_counter == in_data_len) next_state = protect;
            else next_state = encrypt;
        end
        protect:begin
            if(len_counter == in_data_len) next_state = gen_out;
            else next_state = protect;
        end
        gen_out:begin
            if(len_counter == in_data_len) next_state = init;
            else next_state = gen_out;
        end
        default:begin
            next_state = init;
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        in_data_len <= 0;
    end
    else begin
        in_data_len <= next_in_data_len;
    end
end

always @(*) begin
    case(state)
        init : begin
            if (in_valid == 1) begin
                next_in_data_len = 1;
            end
            else begin
                next_in_data_len = 0;
            end
        end
        get_data : begin
            if (in_valid != 1 && in_data_len != 0) begin
                next_in_data_len = in_data_len;
            end
            else begin
                next_in_data_len = in_data_len + 1;
            end
        end
        default : begin
            next_in_data_len = in_data_len;
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        for (i=0; i<MAX_INPUT_LEN; i=i+1) begin
            output_data_save[i] <= 0;
            err_pro_data_save[i] <= 0;
        end
    end
    else begin
        for (i=0; i<MAX_INPUT_LEN; i=i+1) begin
            output_data_save[i] <= next_output_data_save[i];
            err_pro_data_save[i] <= next_err_pro_data_save[i];
        end
    end
end


always @(*) begin
    for (i=0; i<MAX_INPUT_LEN; i=i+1) begin
        next_output_data_save[i] = output_data_save[i];
        next_err_pro_data_save[i] = err_pro_data_save[i];
    end
    case(state)
        init: begin 
            if (in_valid) begin
                next_output_data_save[0] = in_data;
            end
        end
        get_data : begin
            if (in_valid) begin
                next_output_data_save[len_counter] = in_data;
            end
        end
        encrypt : begin
            if (len_counter != in_data_len) begin
                next_output_data_save[len_counter] = output_data_save[len_counter] + counter;
            end  
        end
        protect:begin
            if (len_counter != in_data_len) begin
                for(i=0, j=0; i<12; i=i+1)begin
                    case(i)
                        0:next_err_pro_data_save[len_counter][0] = output_data_save[len_counter][6] ^ output_data_save[len_counter][4] ^ output_data_save[len_counter][3] ^ output_data_save[len_counter][1] ^ output_data_save[len_counter][0];
                        1:next_err_pro_data_save[len_counter][1] = output_data_save[len_counter][6] ^ output_data_save[len_counter][5] ^ output_data_save[len_counter][3] ^ output_data_save[len_counter][2] ^ output_data_save[len_counter][0];
                        3:next_err_pro_data_save[len_counter][3] = output_data_save[len_counter][7] ^ output_data_save[len_counter][3] ^ output_data_save[len_counter][2] ^ output_data_save[len_counter][1];
                        7:next_err_pro_data_save[len_counter][7] = output_data_save[len_counter][7] ^ output_data_save[len_counter][6] ^ output_data_save[len_counter][5] ^ output_data_save[len_counter][4];
                        default:begin
                            next_err_pro_data_save[len_counter][i] = output_data_save[len_counter][j];
                            j=j+1;
                        end
                    endcase
                end
                
            end  
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        out_data <= 0;
        out_valid <= 0;
    end
    else begin
        out_data <= next_out_data;
        out_valid <= next_out_valid;
    end
end

always @(*) begin
    case(state)
        gen_out : begin
            if (len_counter != in_data_len) begin
                next_out_valid = 1;
                next_out_data = err_pro_data_save[len_counter];
            end
            else begin
                next_out_valid = 0;
                next_out_data = 0;
            end
        end
        default : begin
            next_out_data = 0;
            next_out_valid = 0;
        end
    endcase
end

endmodule