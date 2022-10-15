module clock_divider #(parameter n=25)(
    input clk,
    output clk_div
);
    wire [n-1:0] next_num;
    reg [n-1:0] num = 0;

    always@(posedge clk) begin
        num <= next_num;
    end

    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module lab3_2
(
    input clk,
    input rst,
    input en,
    input speed,
    input freeze,
    output reg [15:0] led
);

reg [15:0] next_led, led_save, next_led_save;

reg [2:0] state, next_state;
parameter init = 3'b000;
parameter racing = 3'b001;
parameter M_finish = 3'b010;
parameter M_win = 3'b011;
parameter C_finish = 3'b100;
parameter C_win = 3'b101;

reg [11:0] car_path_led, next_car_path_led;
reg [11:0] morto_path_led, next_morto_path_led;
reg [1:0] car_point, next_car_point;
reg [1:0] morto_point, next_morto_point;
reg [3:0] counter = 4'b0, next_counter;


wire clk_27, clk_24;
reg clk_use, next_clk_use;
reg clk_use2, next_clk_use2;

clock_divider #(.n(27)) clk27(//6
    .clk(clk),
    .clk_div(clk_27)
);

clock_divider #(.n(24)) clk24(//3
    .clk(clk),
    .clk_div(clk_24)
);

always@(posedge clk)begin
    clk_use <= next_clk_use;
end

always@(posedge clk)begin
    clk_use2 <= next_clk_use2;
end

always@(*)begin
    case(state)
        init:begin
            next_clk_use2 = clk_27;
        end
        racing:begin
            next_clk_use2 = clk_24;
        end
        default:begin
            next_clk_use2 = clk_27;
        end
    endcase
end

always@(*)begin
    case(state)
        racing:begin
            if(speed == 0 || counter > 3) begin
                next_clk_use = clk_27;
            end
            else begin
                next_clk_use = clk_24;
            end 
        end
        default:begin
            next_clk_use = clk_27;
        end
    endcase
end

always@(posedge clk_use or negedge rst)begin//
    if(rst) begin
        car_path_led <= {2'b11,10'b00};
        car_point <= 2'b0;
        counter <= 0;
    end
    else begin
        car_path_led <= next_car_path_led;
        car_point <= next_car_point;
        counter <= next_counter;
    end
end

always@(*)begin
    next_car_path_led = car_path_led;
    next_car_point = car_point;
    next_counter = counter;
    case(state)
        init:begin
            next_car_path_led = {2'b11,10'b0};
            next_car_point = 2'b0;                      
        end
        racing:begin
            if(en) begin
                next_car_path_led = car_path_led >> 1;
            end
            if (speed) begin
                next_counter = counter + 1;
            end
            else if(counter!=0)begin
                next_counter = 4;
            end
        end
        C_win:begin
            next_car_path_led = 12'b1111_1111_1111;
            next_car_point = car_point;
            next_counter = 0;
        end
        C_finish:begin
            next_car_path_led = {2'b11,10'b0};
            next_car_point = car_point+1;
            next_counter = 0;
        end
        M_finish:begin                                  
            next_car_path_led = {2'b11,10'b0};          
            next_car_point = car_point;
            next_counter = 0;                
        end                                             
        M_win:begin                                     
            next_car_path_led = {2'b11,10'b0};          
            next_car_point = 2'b0;
            next_counter = 0;                      
        end                                             
        default:begin
            next_car_path_led = {2'b11,10'b0};
            next_car_point = car_point;
            next_counter = 0; 
        end
    endcase
end

always@(posedge clk_27 or negedge rst)begin//
    if(rst) begin
        morto_path_led <= {3'b0,1'b1,8'b0};
        morto_point <= 2'b0;
    end
    else begin
        morto_path_led <= next_morto_path_led;
        morto_point <= next_morto_point;
    end
end

always@(*)begin
    next_morto_path_led = morto_path_led;
    next_morto_point = morto_point;
    case(state)
        init:begin
            next_morto_path_led = {3'b0,1'b1,8'b0};
            next_morto_point = 2'b0;                    
        end
        racing:begin
            if(en && freeze !=1 ) next_morto_path_led = morto_path_led >> 1;
        end
        M_win:begin
            next_morto_path_led = 12'b1111_1111_1111;
            next_morto_point = morto_point;
        end
        M_finish:begin
            next_morto_path_led = {3'b0,1'b1,8'b0};
            next_morto_point = morto_point+1;
        end
        C_finish:begin                                  
            next_morto_path_led = {3'b0,1'b1,8'b0};     
            next_morto_point = morto_point;             
        end                                             
        C_win:begin                                     
            next_morto_path_led = {3'b0,1'b1,8'b0};     
            next_morto_point = 2'b0;                    
        end                                             
        default:begin
            next_morto_path_led = {3'b0,1'b1,8'b0};
            next_morto_point = morto_point;
        end   
    endcase
end

always@(posedge clk)begin
    if(rst) led <= {2'b0,4'b1101,10'b0};
    else led <= {car_point, car_path_led | morto_path_led, morto_point};
end

always@(posedge clk_use2 or negedge rst)begin//
    if(rst) state <= init;
    else state <= next_state;
end

always@(*)begin
    case(state)
        init:begin
            if(en) next_state = racing;
            else next_state = init;
        end
        racing:begin
            if(morto_path_led == 12'b1 && morto_point == 2'b11) next_state = M_win;
            else if(morto_path_led == 12'b1 && morto_point != 2'b11) next_state = M_finish;
            else if(car_path_led == 12'b11 && car_point != 2'b11) next_state = C_finish;
            else if (car_path_led == 12'b11 && car_point == 2'b11) next_state = C_win;
            else next_state = racing;
        end
        C_win:begin
            next_state = init;
        end
        M_win:begin
            next_state = init;
        end
        C_finish:begin
            next_state = racing;
        end
        M_finish:begin
            next_state = racing;
        end
        default:begin
            next_state = init;
        end
    endcase
end

endmodule

//-------------bug to fix---------------
//1.init停得有點久。
//2.speed up 時如何即時讀取。
