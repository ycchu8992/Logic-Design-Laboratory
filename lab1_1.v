`timescale 1ns/100ps
module lab1_1 (
    input wire [3:0] request,
    output reg [3:0] grant
); 

    always@(*)begin
        if(request[3] == 1'b1)
            grant = 4'b1000;
        else if(request[2] == 1'b1)
            grant = 4'b0100;
        else if(request[1] == 1'b1)
            grant = 4'b0010;
        else if(request[0] == 1'b1)
            grant = 4'b0001;
        else
            grant = 4'b0000;
    end

endmodule
