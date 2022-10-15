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

module lab1_2 (
    input wire [5:0] source_0,
    input wire [5:0] source_1,
    input wire [5:0] source_2,
    input wire [5:0] source_3,
    output reg [3:0] result
); 
    /* Note that result can be either reg or wire. 
    * It depends on how you design your module. */
    // add your design here 
    
    reg [3:0] request_t;
    wire [3:0] grant;
    reg [5:0] source;

    lab1_1 arbiter(
        .request (request_t),
        .grant (grant));

    always@(*)begin
        case (source_3[5:4])
            2'b00: request_t[3] = 1'b0;
            default: request_t[3] = 1'b1;
        endcase
    end
    always@(*)begin
        case (source_2[5:4])
            2'b00: request_t[2] = 1'b0;
            default: request_t[2] = 1'b1;
        endcase
    end

    always@(*)begin
        case (source_1[5:4])
            2'b00: request_t[1] = 1'b0;
            default: request_t[1] = 1'b1;
        endcase
    end

    always @(*) begin
        case (source_0[5:4])
            2'b00: request_t[0] = 1'b0;
            default: request_t[0] = 1'b1;
        endcase
    end

    always @(*)begin
        case(grant)
            4'b0001: source = source_0;
            4'b0010: source = source_1;
            4'b0100: source = source_2;
            default: source = source_3;
        endcase
    end

    always @(*)begin
        case(source[5:4])
            2'b01: result = source[3:0] & 4'b1010;
            2'b10: result = source[3:0] + 4'd3;
            2'b11: result = source[3:0] << 2;
            default: result = 4'b0;
        endcase
    end

endmodule
