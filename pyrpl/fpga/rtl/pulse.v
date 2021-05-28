module pulse (
    input start,
    input clk,
    output OUT
);

    reg [12-1:0] count;
    reg is_counting;
    reg res;
    
    always @(posedge clk) begin
        if (start == 1'b1) begin
            count<=12'b0;
            is_counting<=1'b1;
            res<=1'b1;
            end
        else if ((is_counting == 1'b1) && (count[11] != 1'b1)) begin
            count<=count+1;
            end 
        else if (count[11]==1'b1) begin
            is_counting <= 1'b0;
            count <=12'b0;
            res<=1'b0;
            end
    end

    assign OUT = res;

endmodule
