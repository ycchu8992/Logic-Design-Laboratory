module mem_addr_gen(
    input clk,
    input rst,
    input en,
    input dir,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    output [16:0] pixel_addr
);
    
   reg [7:0] position, next_position;
  
   assign pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1)+ position*320 )% 76800;  //640*480 --> 320*240 

    always @ (posedge clk or posedge rst) begin
        if(rst) position <= 0;
        else position <= next_position;
    end

    always@(*)begin
        if(en)begin
            if(dir)begin
                if(position > 0) next_position = position - 1;
                else next_position = 239;
            end else begin
                if(position < 239) next_position = position + 1;
                else next_position = 0;
            end
        end else begin
            next_position = position;
        end
    end
    
endmodule
